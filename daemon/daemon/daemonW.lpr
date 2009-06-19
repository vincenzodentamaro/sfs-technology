  program daemon;


  uses

    Cthreads, Classes, Unix, Sysutils, inifiles, Process, BaseUnix
    ;

  type
  TsendThread = class(TThread)
  private

  protected
    procedure Execute; override;
    Function mount(var nomefilesfs,pID:String):String;
    Function flush(var pid:String):integer;
  public
  end;

  type
    DaemonStatus = (Run,Ready,Busy);


   Tprocedures = class

  Procedure checkloop ;
  Function is_sudo: boolean;
  Procedure suicide;
  Procedure sendError(Const text:String);
  end;


  var
  XProcess: Tprocess;
  shutdown:boolean;
  currentPid:String;
  proc:Tprocedures;
  send:TsendThread;
  semaphores:DaemonStatus;  // (not used for now) It represents the daemon's status

  Procedure Tprocedures.sendError(Const text:String);
  begin
  XProcess := Tprocess.Create(nil);
  XProcess.CommandLine := '/usr/sbin/sfs/SFSerror "'+text+'"';
  XProcess.Options := [poNewProcessGroup, poUsePipes];
  if sysutils.FileExists('/usr/sbin/sfs/SFSerror') then
   begin
     XProcess.Execute;
   end;

  end;

  Procedure Tprocedures.suicide;  //close the daemon cleaning any pending instance
  begin
  semaphores:=busy;
  sysutils.DeleteFile('/tmp/sfs/suicide');
  writeln('The Daemon is now halted!');
  shutdown:=true;
  unix.Shell('rm /tmp/sfs/*');
  exit;
  writeln('The Daemon is now halt!');

  end;

  Function TProcedures.is_sudo: boolean;   //to determinate if it is runnig in Super user mode or not!
 begin
  if fpgeteuid = 0 then result := true
   else result := false;
  End;


  procedure TsendThread.execute;  //this procedure read the file SFSsend.sfs and determinate the command to execute
  var
  inifile:Tinifile;
  mount_command:boolean;
  umount_command:boolean;
  sfsfile:string;
  pid:string;

  begin
            semaphores:=Busy;
            writeln('Command received... reading file /tmp/sfs/SFSsend.cfg');

            inifile := Tinifile.Create('/tmp/sfs/SFSsend.cfg');
            mount_command := inifile.ReadBool('DAEMON','mount',false);
            umount_command := inifile.ReadBool('DAEMON','umount',false);
            sfsfile := inifile.ReadString('DAEMON','sfsfile','');
            pid := inifile.ReadString('DAEMON','processID','');
            sysutils.DeleteFile('/tmp/sfs/SFSsend.cfg');

            if mount_command = true then if umount_command=false then send.mount(sfsfile,pid);
            if umount_command = true then if mount_command=false then send.flush(pid);


  end;

  Function TsendThread.mount(var nomefilesfs,pID:String):String;
  //this function mount the sfs file described into the SFSsend.cfg file
  //the univoke key is the sfslauncher's process ID

  Var
    process: cint;
    k: smallint;
    stop: boolean;
    f: textfile;
    carattere: Ppchar;
    stringa,parametrogenDefault,path: string;
  Begin
       semaphores:=Run;

    //extract the sfs filename without the absolute path
    writeln('I have to mount the file '+nomefilesfs);
    writeln('SFS instance  number: '+pID);


    parametrogenDefault:= sysutils.ExtractFileName(nomefilesfs);

    If Not sysutils.DirectoryExists('/.mounted/')Then unix.shell('mkdir /.mounted');
    If Not sysutils.DirectoryExists('/.mounted/'+pID)Then
      Begin
        path := '/.mounted/'+pID;
        unix.shell('mkdir '''+path+'''');
        writeln('mounting... '+parametrogenDefault+' '+path);
        process := unix.Shell('mount -t squashfs -o loop '''+nomefilesfs+''' '+'"'+path+'"');
        unix.WaitProcess(process);
         Try
          system.Assign(f,'/tmp/sfs/'+pID);
          rewrite(f);
          writeln(f,path);
          closefile(f);
         Except
         proc.sendError('Unable to comunicate with sfslauncher. Please check the /tmp/sfs permissions!');
         END;


      End;


    mount:=path;
    semaphores:=ready;
  End;


  Function TsendThread.flush(var pid:String):integer;
  //procedure for dismantling and cleaning
  var
  path:String;
  Begin
      semaphores:=Run;
    writeln('Flushing SFS instance number: '+pid);
    path := '/.mounted/'+pid;
    writeln('Unmounting, please wait ...');
    unix.Shell('umount -l -d '+'"'+path+'"'); //PROCEDURE OF UMOUNT IN USERMODE
    writeln('Flushing ...');
    unix.Shell('rmdir --ignore-fail-on-non-empty "'+path+'"');
    semaphores:=ready;
    if not sysutils.DirectoryExists(path)then result:=0 else result:=-1;

  End;







  Procedure Tprocedures.checkloop ;  //this procedure create 255 loop back devices were mount 255 sfs software simultaniously!
  Begin
    If Not sysutils.FileExists('/dev/loop255') Then
      Begin
        if fileexists('/usr/sbin/sfs/MAKEloop')then unix.Shell('rm /dev/loop*');
        unix.Shell('cp /usr/sbin/sfs/MAKEloop /dev');
        unix.Shell('chmod 777 /dev/MAKEloop');
        unix.Shell('cd /dev && exec ./MAKEloop loop');
        // migliorare questo punto
      End;
  End;

  /////////////////MAIN////////////////

  begin
  if proc.is_sudo = true then
   begin
     if not sysutils.DirectoryExists('/tmp/sfs')then sysutils.CreateDir('/tmp/sfs');
     if not sysutils.DirectoryExists('/etc/sfs')then sysutils.CreateDir('/etc/sfs');
     if sysutils.DirectoryExists('/.mounted')then unix.Shell('rm -R /.mounted/*');
     writeln('Checking loop-back devices...');
     unix.Shell('modprobe loop');
     proc.checkloop;
     unix.Shell('modprobe squashfs');
     shutdown:=false;
     writeln('The SFS daemon is now listening....');
     while shutdown=false do
        begin
          if sysutils.FileExists('/tmp/sfs/suicide') then proc.suicide;
          unix.Shell('chmod 777 -R /tmp/sfs && chmod 777 -R /etc/sfs');
          if sysutils.FileExists('/tmp/sfs/SFSsend.cfg')then
          begin
          send := TsendThread.Create(false);
          send.Execute;
          end;
          sleep(500);  // for the 99% of the time the daemon sleep, decreasing its overhead
     end;
     sysutils.DeleteFile('/tmp/sfs/SFSsend.cfg');
     end else writeln('Hey!! You must be root to launch this daemon!');

  end.

