program daemon;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,Unix,Sysutils,inifiles, process
  { add your units here };
type
  DaemonStatus = (Run,Ready,Busy);
  
  Tprocedures = class
procedure ReadSended;
Function mount(var nomefilesfs,pID:String):String;
Function flush(var pid:String):integer;
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
semaphores:DaemonStatus;

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

Procedure Tprocedures.suicide;
begin
semaphores:=busy;
sysutils.DeleteFile('/var/sfs-suicide');
writeln('The Daemon is now halted!');
shutdown:=true;
unix.Shell('rm /tmp/sfs/*');
exit;
writeln('The Daemon is now halt!');

end;

Function TProcedures.is_sudo: boolean;
var
sudoers:textfile;
Begin
  Try
    system.Assign(sudoers,'/var/sudoers');
    rewrite(sudoers);
    closefile(sudoers);
    result := true;
  Except
    result := false;
  End;
End;


procedure Tprocedures.ReadSended;
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
          
          if mount_command = true then if umount_command=false then mount(sfsfile,pid);
          if umount_command = true then if mount_command=false then flush(pid);


end;

Function Tprocedures.mount(var nomefilesfs,pID:String):String;
//funzione di montaggio

Var
  process: cint;
  k: smallint;
  stop: boolean;
  f: textfile;
  carattere: Ppchar;
  stringa,parametrogenDefault,path: string;
Begin
     semaphores:=Run;

  //estraggo il nome del file senza la relativa path
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


Function Tprocedures.flush(var pid:String):integer;
//procedura di smontaggio e pulizia
var
path:String;
Begin
    semaphores:=Run;
  writeln('Flushing SFS instance number: '+pid);
  path := '/.mounted/'+pid;
  writeln('Unmounting, please wait ...');
  unix.Shell('umount -l -d '+'"'+path+'"'); //PROCEDURA DI UMOUNT IN USERMODE
  writeln('Flushing ...');
  unix.Shell('rmdir --ignore-fail-on-non-empty "'+path+'"');
  semaphores:=ready;
  if not sysutils.DirectoryExists(path)then result:=0 else result:=-1;

End;







Procedure Tprocedures.checkloop ;
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
        if sysutils.FileExists('/var/sfs-suicide') then proc.suicide;
        unix.Shell('chmod 777 -R /tmp/sfs && chmod 777 -R /etc/sfs');
        if sysutils.FileExists('/tmp/sfs/SFSsend.cfg')then proc.ReadSended;
        sleep(500);
   end;
 end else writeln('Hey!! You must be root to launch this daemon!');
end.

