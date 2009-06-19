{
//////////////////////////--| SFS DAEMON |--////////////////////////////
* This multithread demon handle the mount/unmount command for a SFS file.
* It comunicates with sfslauncher and keep the sended commands and then
* execute the relative command.
* This daemon create a thread for any sended command and execute it.
*
* Author: Vincenzo Dentamaro (c) 2007-2008-2009
* Software Name: daemon
* Version: 1.1.0.1
* Date: 17 april 2009
* Site: http://code.google.com/p/sfs-technology/
*
 License:
   Permission is hereby granted, free of charge, to any person obtaining
   a copy of this software and associated documentation files (the
   "Software"), to deal in the Software without restriction, including
   without limitation the rights to use, copy, modify, merge, publish,
   distribute, sublicense, and/or sell copies of the Software, and to
   permit persons to whom the Software is furnished to do so, subject to
   the following conditions:

   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
   LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
   OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


}

Program daemon; // The SFS Technology daemon.

Uses 

Cthreads, Classes, Unix, Sysutils, inifiles, Process, BaseUnix;


Type
{
* This class create a thread object with the methods to read and handle
* the sended command. This class implements the methos to mount and unmount
* the sfs file.
*
}

  TsendThread = Class(TThread)
    Private 
      Function mount(Var nomefilesfs,pID:String): String;
      Function flush(Var pid:String): integer;
    Protected 
     Procedure Execute(const uniqueKey:String);


    Public
  End;

{
* This simple class defines some methods used by the daemon to make some check.
* It defines some important methods like suicide procedures to terminate
* the daemon execution and call "sendError" .
}

  Tprocedures = Class

    Procedure checkloop ;
    Function is_sudo: boolean;
    Procedure suicide;
    Procedure sendError(Const text:String);
  End;


Var 

  shutdown: boolean;
  currentPid: String;
  procedures: Tprocedures;
  send: array [0..32767] of TsendThread;
  i: integer;


//Define Thread Class methods
Procedure TsendThread.execute(const uniqueKey:String);
//this procedure read the file SFSsend.sfs and determinate the command to execute
var
inifile: Tinifile;
mount_command: boolean;
umount_command: boolean;
sfsfile: string;
pid: string;

Begin

  writeln('Command received... reading file /tmp/sfs/SFSsend.cfg');

  inifile := Tinifile.Create('/tmp/sfs/'+uniqueKey);
  mount_command := inifile.ReadBool('DAEMON','mount',false);
  umount_command := inifile.ReadBool('DAEMON','umount',false);
  sfsfile := inifile.ReadString('DAEMON','sfsfile','');
  pid := inifile.ReadString('DAEMON','processID','');
  sysutils.DeleteFile('/tmp/sfs/'+uniqueKey);

  If mount_command = true Then If umount_command=false Then self.mount(sfsfile,pid);
  If umount_command = true Then If mount_command=false Then self.flush(pid);

  self.Destroy; //destructor of the thread object

End;

Function TsendThread.mount(Var nomefilesfs,pID:String): String;
//this function mount the sfs file described into the SFSsend.cfg file
//the univoke key is the sfslauncher's process ID

Var
  proc: Tprocess;
  stop: boolean;
  f: textfile;
  parametrogenDefault,path: string;
Begin


  //extract the sfs filename without the absolute path
  writeln('I have to mount the file '+nomefilesfs);
  writeln('SFS instance  number: '+pID);

  proc := Tprocess.Create(Nil);
  proc.Options := [poWaitOnExit];

  parametrogenDefault := sysutils.ExtractFileName(nomefilesfs);

  If Not sysutils.DirectoryExists('/.mounted/')Then
     Begin
        proc.CommandLine := 'mkdir /.mounted';
        proc.Execute;
     End;
  If Not sysutils.DirectoryExists('/.mounted/'+pID)Then
    Begin
      path := '/.mounted/'+pID;
      proc.CommandLine := 'mkdir '''+path+'''';
      proc.Execute;
      proc.CommandLine := 'chmod 777 -R '''+path+'''';
      proc.Execute;
      writeln('mounting... '+parametrogenDefault+' '+path);
      proc.CommandLine := 'mount -t squashfs -o loop -r '''+nomefilesfs+''' '+'"'
                           +path+'"';
      proc.Execute;

      Try
        system.Assign(f,'/tmp/sfs/'+pID);
        rewrite(f);
        writeln(f,path);
        closefile(f);
      Except
        procedures.sendError(
                     'Unable to comunicate with sfslauncher. '
                    + 'Please check the /tmp/sfs permissions!'
        );
      End;


    End;


  mount := path;

End;


Function TsendThread.flush(Var pid:String): integer;
//procedure for dismantling and cleaning

Var
  path: String;
  proc: Tprocess;
Begin

  proc := Tprocess.Create(Nil);
  proc.Options := [poWaitOnExit];
  writeln('Flushing SFS instance number: '+pid);
  path := '/.mounted/'+pid;
  writeln('Unmounting, please wait ...');
  proc.CommandLine := 'umount -l -d '+'"'+path+'"';
  proc.Execute;
  //PROCEDURE OF UMOUNT IN USERMODE
  writeln('Flushing ...');
  proc.CommandLine := 'rmdir --ignore-fail-on-non-empty "'+path+'"';
  proc.Execute;

  If Not sysutils.DirectoryExists(path)Then result := 0
  Else result := -1;

End;




Procedure Tprocedures.sendError(Const text:String);
var
XProcess: Tprocess;
Begin
  XProcess := Tprocess.Create(Nil);
  XProcess.CommandLine := '/usr/sbin/sfs/SFSerror "'+text+'"';
  XProcess.Options := [poNewProcessGroup, poUsePipes];
  If sysutils.FileExists('/usr/sbin/sfs/SFSerror') Then
    Begin
      XProcess.Execute;
    End;

End;

Procedure Tprocedures.suicide;
var
proc: Tprocess;
//close the daemon cleaning any pending instance
Begin

  proc := Tprocess.Create(Nil);
  proc.CommandLine := 'rm /tmp/sfs/*';
  proc.Options := [poWaitOnExit];
  proc.Execute;
  sysutils.DeleteFile('/var/sfs-suicide');
  writeln('The Daemon is now halted!');
  shutdown := true;
  exit;
  writeln('The Daemon is now halt!');

End;


Function TProcedures.is_sudo: boolean;
//to determinate if it is runnig in Super user mode or not!
Begin
  If fpgeteuid = 0 Then result := true
  Else result := false;
End;





Procedure Tprocedures.checkloop ;
//this procedure create 255 loop back devices were mount 255 sfs software
// simultaniously!
Begin

  If Not sysutils.FileExists('/dev/loop255') Then
    Begin
      If fileexists('/usr/sbin/sfs/MAKEloop')Then
      Begin
         shell('rm /dev/loop*');
         shell('cp /usr/sbin/sfs/MAKEloop /dev');
         shell('chmod 777 /dev/MAKEloop');
         unix.Shell('cd /dev && exec ./MAKEloop loop');
      End; // migliorare questo punto
    End;
End;

/////////////////MAIN////////////////

Begin
  i := 0;

  If procedures.is_sudo = true Then
    Begin
      If Not sysutils.DirectoryExists('/tmp/sfs')Then
             sysutils.CreateDir('/tmp/sfs');
      If Not sysutils.DirectoryExists('/etc/sfs')Then
             sysutils.CreateDir('/etc/sfs');
      If sysutils.DirectoryExists('/.mounted')Then
             unix.Shell('rm -R /.mounted/*');
      writeln('Checking loop-back devices...');
      unix.Shell('modprobe loop');
      procedures.checkloop;
      unix.Shell('modprobe squashfs');
      shutdown := false;
      writeln('The SFS daemon is now listening....');
      While shutdown=false Do
        Begin
          If sysutils.FileExists('/var/sfs-suicide') Then procedures.suicide;
          unix.Shell('chmod 777 -R /tmp/sfs && chmod 777 -R /etc/sfs');
          If sysutils.FileExists('/tmp/sfs/SFSsend.cfg')Then
            Begin
              sysutils.RenameFile('/tmp/sfs/SFSsend.cfg','/tmp/sfs/'+inttostr(i));
              //create a thread object to handle the sended command
              send[i] := TsendThread.Create(false);
              send[i].Execute(inttostr(i));
              i := i + 1;
              if i = 32767 then i := 0;
            End;
          sleep(500);
          // for the 99% of the time the daemon sleep, decreasing its overhead
        End;
      sysutils.DeleteFile('/tmp/sfs/SFSsend.cfg');
    End
  Else writeln('Hey!! You must be root to launch this daemon!');

End.
