  // Title:	sfslauncher.lpr
  // Author: 	Vincenzo Dentamaro <vincenzodentamaro@hotmail.com>
  // Version:   1.1.0.2
  //
  // Copyright (C) 2007-2008-2009 UNIXTEAM <www.unixteam.net>
  //
  // Permission is hereby granted, free of charge, to any person obtaining
  // a copy of this software and associated documentation files (the
  // "Software"), to deal in the Software without restriction, including
  // without limitation the rights to use, copy, modify, merge, publish,
  // distribute, sublicense, and/or sell copies of the Software, and to
  // permit persons to whom the Software is furnished to do so, subject to
  // the following conditions:
  //
  // The above copyright notice and this permission notice shall be
  // included in all copies or substantial portions of the Software.
  //
  // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  // EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  // MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  // NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  // LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  // OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  // WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  // CROSS COMPILER SOURCE
  // THIS SOURCE FILE IS WRITTEN TO BE COMPILED FOR 32 BIT AND 64 BIT COMPUTER


  //By Vincenzo Dentamaro 2009


//version 1.0 beta beta beta beta beta beta beta beta beta beta beta beta beta beta
  //Divide et impera!

  Program sfslauncher;

  {$mode objfpc}{$H+}

  uses
  Cthreads,inifiles,Classes,sysutils,strutils,unix,baseunix,Process;

  Const
  {$IFDEF CPUX86_64}
    arch = '64';
    //Set the architecture constant to AMD64 or EM64T compatible architecture
  {$ELSE}

    //The default setting is the i386 (x86) architecture
     {$IFDEF arm}
       arch = 'arm';
    //set the architecture for the Acorn RISC Machine processors
     {$ELSE}
       arch = 'x86';
    //Default
     {$ENDIF}
  {$ENDIF}

  Type
    Toptions = (version,help,make_loop,desk_path,normale);





    Tfunctions = Class


                   Procedure _do ;

                   Procedure leggiparameters;

                   Procedure leggidescriptionid;

                   Procedure execute;

                   Procedure _onunmount;

                   Procedure config_file_size_check;

                   Procedure write_config;

                   Function  Systems(Const Command:AnsiString): cint;

                   Function  is_sudo: boolean;

                   Procedure sendMount(sfsfile,pid:String);

                   Procedure sendFlush(pid:String);

                   Procedure export_env_variables;

                   Function  leggiPath: string;

                   Procedure sendError(Const testo: String);

                   Procedure put_icon;

    End;

  Var
    sudoers: textfile;
    ps1: shortstring;
    ps2: shortstring;
    ps3: shortstring;
    parameters: textfile;
    descriptionid: textfile;
    descriptionid_file: string;
    parameters_file: string;
    parametri: ansistring;
    nomeprogramma: string;
    architettura: string;
    versione: string;
    autore: string;
    info: string;
    parametro1: ansistring;
    parametro2: ansistring;
    parametrogen,parametrogenDefault: ansistring;
    funzioni: Tfunctions;
    env_variables: array [0..31] Of string;
    num_of_var: smallint;
    num_of_var_glob: integer;
    inifile: Tinifile;
    env_var: Tinifile;
    env_file: string;
    isN: boolean;
    nomefilesfs: string;
    execproc: Tprocess;
    opzioni: Toptions;
    processID: string;
    path: ansistring;
    mimeTypes: String;
    XProcess: TProcess;




  Procedure Tfunctions.put_icon;



//It generate a file in the .desktop format for KDE and Gnome.
//The generated file will be inserted in the $HOME/.local/share/applications directory

// only if exists the icon.png file into the SFS package

  Var
    replaceflag: Treplaceflags;
    f,e: textfile;
    prog_name: string;
    arraydistringhe: array Of string;
    update_link: boolean;
    desk_pathvar: String;
    Begin

      If sysutils.FileExists(path+'/icon.png')Then
        Begin
          inifile := Tinifile.Create('/etc/sfs/config.conf');
          If inifile.ReadBool('GLOBAL','export_manifest',false) = true Then
           begin
            desk_pathvar:= inifile.ReadString('GLOBAL','manifest_dir',
                           '$HOME/.local/share/applications/');
            if desk_pathvar <= ' ' then desk_pathvar:='$HOME/.local/share/applications/';
            prog_name := nomefilesfs;
            

                unix.Shell('mkdir $HOME/.SFSicons');
                unix.Shell('mkdir $HOME/SFSsoftware');
                unix.Shell('cp '+path+'/icon.png '+'$HOME/.SFSicons/'+sysutils
                           .
                           ExtractFileName(
                           prog_name)+'.png');
                Try


                  writeln('Exporting on '+desk_pathvar+sysutils.
                          ExtractFileName(
                          prog_name)+'.desktop')
                  ;
                  unix.Shell(

                   'echo "[Desktop Entry]" > '+desk_pathvar
                             +sysutils.ExtractFileName(
                             prog_name)+'.desktop');
                  unix.Shell(

                   'echo "Encoding=UTF-8" >> '+desk_pathvar
                             +sysutils.ExtractFileName(
                             prog_name)+'.desktop');
                  unix.Shell('echo "Exec=/usr/sbin/sfs/sfslauncher '''+prog_name
                             +
                             '''" >> '+desk_pathvar+sysutils.
                             ExtractFileName(
                             prog_name)+'.desktop');
                  unix.Shell('echo "Icon='+'$HOME/.SFSicons/'+sysutils.
                             ExtractFileName(
                             prog_name)+'.png'+
                  '" >> '+desk_pathvar+
                  sysutils.ExtractFileName(

                                           prog_name
                  )+'.desktop');
                  unix.Shell('echo "Name='+nomeprogramma+
                             '" >> '+desk_pathvar+sysutils.
                             ExtractFileName
                             (prog_name)+'.desktop');
                  unix.Shell('echo "Comment='+info+
                             '" >> '+desk_pathvar+sysutils.
                             ExtractFileName(
                             prog_name)+'.desktop');
                  unix.Shell('echo "GenericName='+autore+
                             '" >> '+desk_pathvar+sysutils.
                             ExtractFileName
                             (prog_name)+'.desktop');
                  unix.Shell(


                 'echo "Type=Application" >> '+desk_pathvar
                             +sysutils.ExtractFileName(
                             prog_name)+'.desktop');
                  unix.Shell('echo "Version='+versione+
                             '" >> $HOME/.local/share/applications/'+sysutils.
                             ExtractFileName(
                             prog_name)+'.desktop');
                  unix.Shell(


       'echo "Categories=Application;SFS" >> '+desk_pathvar
                             +sysutils.ExtractFileName(
                             prog_name)+'.desktop');
                  unix.Shell('echo "X-Ubuntu-Gettext-Domain='+nomeprogramma+
                             '" >> '+desk_pathvar+sysutils.
                             ExtractFileName(
                             prog_name)+'.desktop');
                  If mimeTypes > ' ' Then
                         unix.Shell('echo "MimeType='+mimeTypes+
                                    '" >> '+desk_pathvar+
                                    sysutils.
                                    ExtractFileName(prog_name)
                                    +'.desktop');


                Except
                  writeln ('Unable to create file ' + desk_pathvar+sysutils.
                           ExtractFileName(prog_name)
                  +'.desktop');
                  senderror('Unable to create file ' + desk_pathvar+sysutils.
                            ExtractFileName(prog_name)
                  +'.desktop');
                End;
           End;
       End;
  End;





  Procedure Tfunctions.sendError(Const testo:String);
  Begin
    XProcess := Tprocess.Create(Nil);
    XProcess.CommandLine := '/usr/sbin/sfs/SFSerror "'+testo+'"';
    XProcess.Options := [poNewProcessGroup, poUsePipes];
    If sysutils.FileExists('/usr/sbin/sfs/SFSerror') Then
      Begin
        XProcess.Execute;
      End;

   End;

  Function Tfunctions.is_sudo: boolean;



//this simple boolean function is intended to be used for determinate if we are
//working in super user mode or not.
  Begin
    If fpgeteuid = 0 Then result := true
    Else result := false;
  End;



  Function Tfunctions.Systems(Const Command:AnsiString): cint;



//this maxi function create a process to handle the execution
//of the program contained into the sfs
  //Lanciamo la versione UTF-8 ANSISTRING della shell bash

  Var
    pid,savedpid   : cint;
    pstat          : cint;
    ign,intact,
    quitact        : SigactionRec;
    newsigblock,
    oldsigblock    : tsigset;

  Begin
    If command='' Then exit(1);
    ign.sa_handler := SigActionHandler(SIG_IGN);
    fpsigemptyset(ign.sa_mask);
    ign.sa_flags := 0;
    fpsigaction(SIGINT, @ign, @intact);
    fpsigaction(SIGQUIT, @ign, @quitact);
    fpsigemptyset(newsigblock);
    fpsigaddset(newsigblock,SIGCHLD);
    fpsigprocmask(SIG_BLOCK,newsigblock,oldsigblock);
    pid := fpfork;
    If pid=0 Then //here the child process start
      Begin
        fpsigaction(SIGINT,@intact,Nil);
        fpsigaction(SIGQUIT,@quitact,Nil);
        fpsigprocmask(SIG_SETMASK,@oldsigblock,Nil);
        fpexecl('/bin/bash',['-c',Command]);
        //for Ubuntu and Linux Tiger compatibility
        fpExit(127);
        // giong out from the procces (not from the function)
      End
    Else If (pid<>-1) Then // Ok il processo e' andato
           Begin
             savedpid := pid;

             Repeat
               pid := fpwaitpid(savedpid,@pstat,0);
             Until (pid<>-1) And (fpgeterrno()<>ESysEintr);
             If pid=-1 Then
               Systems := -1
             Else
               Systems := pstat;
           End
    Else // something is going bad!!
      systems := -1;
    fpsigaction(SIGINT,@intact,Nil);
    fpsigaction(SIGQUIT,@quitact,Nil);
    fpsigprocmask(SIG_SETMASK,@oldsigblock,Nil);
  End;


  Procedure Tfunctions.Write_config;



//this function read the configuration file and read the previously exported
//library or data path

//this is used to increase the dinamic library linking compatibility

  Var
    vars: smallint;
    i: integer;
    replaceflag: Treplaceflags;
    m: integer;
  Begin
    env_file := path+'/env_variables.conf';

    If  sysutils.FileExists(env_file) Then
      Begin
        inifile := Tinifile.Create('/etc/sfs/config.conf');
        num_of_var_glob := inifile.ReadInteger('ENVIRONMENT','num_of_var',0)+
                           num_of_var;
        vars := inifile.ReadInteger('ENVIRONMENT','num_of_var',0);
        m := 0;
        inifile.WriteInteger('ENVIRONMENT','num_of_var',num_of_var_glob);
        If  inifile.ReadInteger('ENVIRONMENT','num_of_var',0)>255 Then
          inifile.
          WriteInteger('ENVIRONMENT'

                       ,'num_of_var'

                       ,255);
        vars := vars+1;
        For i:=vars To 255 Do
          Begin
            m := m+1;
            If Not inifile.ValueExists('ENVIRONMENT','Variable'+inttostr(i))
              Then
              Begin
                If  sysutils.FileExists(env_file) Then
                  Begin
                    If  env_var.ValueExists('ENVIRONMENT','Variable'+inttostr(
                       m)) Then
                      inifile.WriteString(

                                          'ENVIRONMENT'

                                          ,

                                          'Variable'

                                          +

                                          inttostr

                                          (i
                      ),sysutils.StringReplace(env_var.ReadString(
                                               'ENVIRONMENT',
                                               'Variable'+inttostr(m),' '),
                      '$WORKDIR',path,replaceflag));
                  End;
              End;
          End;

      End;
  End;

  Procedure Tfunctions.sendMount(sfsfile,pid:String);
//send the mount command to the daemon

  Var
    ini2: Tinifile;

  Begin
    Try
      ini2 := Tinifile.Create('/tmp/sfs/SFSsend.cfg');
      ini2.WriteBool('DAEMON','mount',true);
      ini2.WriteBool('DAEMON','umount',false);
      ini2.WriteString('DAEMON','sfsfile',sfsfile);
      ini2.WriteString('DAEMON','processID',pid);
    Except
      funzioni.sendError(

                       'Error while accesing /tmp/sfs/SFSsend.cfg file, check'
                         + 'directory permission.');
    End;
  End;

  Procedure Tfunctions.sendFlush(pid:String);
//send the flush command to the daemon

  Var
    ini3: Tinifile;

  Begin
    Try
      ini3 := Tinifile.Create('/tmp/sfs/SFSsend.cfg');
      ini3.WriteBool('DAEMON','umount',true);
      ini3.WriteBool('DAEMON','mount',false);
      ini3.WriteString('DAEMON','sfsfile',nomefilesfs);
      ini3.WriteString('DAEMON','processID',pid);
    Except
      funzioni.sendError(

                       'Error while accesing /tmp/sfs/SFSsend.cfg file, check'
                         + 'directory permission.');
    End;

  End;


  Procedure Tfunctions.config_file_size_check;
//read and fix the configuration file

  Var
    f: file Of byte;
    size: int64;
    m: textfile;
    i: smallint;
    x,v: boolean;
    s: string;
  Begin
    If fileexists('/etc/sfs/config.conf') Then
      Begin
        assign(f,'/etc/sfs/config.conf');
        reset(f);
        size := filesize(f);
        closefile(f);
        writeln('Config.conf size '+inttostr(size)+' bytes');
        If size > 12779 Then
          //if the filesize is bigger then 12,48Kbytes it will be cut
          Begin

            Writeln(

                 'Oops the /etc/sfs/config.conf file is too big, cleaning....'
            );
            unix.Shell('cp /etc/sfs/config.conf /etc/sfs/config.conf_backup');
            writeln('Backup done in /etc/sfs/config.conf_backup file');
            inifile := Tinifile.Create('/etc/sfs/config.conf');
            x := inifile.ReadBool('GLOBAL','export_manifest',false);
            v := inifile.ReadBool('GLOBAL','update_link',false);
            s := inifile.ReadString('GLOBAL','manifest_dir','');
            sysutils.DeleteFile('/etc/sfs/config.conf');
            inifile := Tinifile.Create('/etc/sfs/config.conf');
            inifile.WriteBool('GLOBAL','export_manifest',x);
            inifile.WriteBool('GLOBAL','update_link',v);
            inifile.WriteString('GLOBAL','manifest_dir',s);

            For i:=0 To 255 Do
              inifile.DeleteKey('ENVIRONMENT','Variable'+inttostr(i));
            inifile.WriteInteger('ENVIRONMENT','num_of_var',0);

            writeln('File resizing done...');
          End;
      End;
  End;



  Procedure Tfunctions._onunmount;
  Begin

    If sysutils.FileExists(path+'/'+'on_unmount')Then unix.WaitProcess(unix.
                                                                       Shell(
                                                                       'exec '
                                                                       +path+
                                                                       '/'+


                                                                  'on_unmount'
      ));

  End;

  Function Tfunctions.leggiPath: string;
//this function return the mounted sfs path

  Var
    f: textfile;
    nomefile: string;
  Begin
    Try
      system.Assign(f,'/tmp/sfs/'+ProcessID);
      reset(f);
      readln(f,path);
      closefile(f);
      leggiPath := path;
      If leggipath = '' Then leggipath := sysutils.GetCurrentDir;
    Except
      leggiPath := sysutils.GetCurrentDir;
    End;

  End;

  Procedure  Tfunctions._do;
//the real main procedure of the sfslauncher

  Var
    datafile: Tdatetime ;
    data1,data2: integer;
    pid: string;
    i: integer;
    stop: boolean;
  Begin
        stop := false;

        If nomefilesfs > ' ' Then
          Begin
            If Not sysutils.FileExists('/tmp/homedir') Then unix.Shell(


                                                   'echo $HOME > /tmp/homedir'
              );

                    writeln('Mounting file '+nomefilesfs);
                    funzioni.sendMount(nomefilesfs,ProcessID);
                    i := 0;
                    while stop = false Do
                                 //here we are waiting the daemon respond
                                 Begin
                                   If Not sysutils.FileExists('/tmp/sfs/'+
                                      ProcessID)
                                     Then
                                     Begin
                                       If i=24 Then
                                         Begin
                                           funzioni.sendError(


'The daemon is not responding, make sure it is running.Key: sudo /etc/init.d/sfs restart  or /etc/init.d/rc.sfs restart'
                                           );
                                           exit;
                                         End;
                                       writeln(

                                        'Waiting for daemon''s response......'
                                       );
                                       i := i+1;
                                       sleep(500);
                                     End
                                   Else
                                     Begin
                                       stop := true;
                                     End;
                                 End;

                    writeln('File '+funzioni.leggiPath+' is mounted');
                    funzioni.leggiparameters;
                    writeln('The parameters to execute are: '+parametro1+' '+
                            paramstr(2)
            );
                    funzioni.leggidescriptionid;
                    writeln('Software name: '+nomeprogramma);
                    writeln('Architecture type: '+architettura);
                    writeln('Version: '+versione);
                    writeln('Autor & Productor: '+autore);
                    writeln('Infos: '+info);
                    funzioni.config_file_size_check;
                    funzioni.export_env_variables;
                    funzioni.put_icon;
                    If sysutils.AnsiLowerCaseFileName(sysutils.Trim(arch))=
                       AnsiLowerCaseFileName(architettura) Then
                      Begin
                        // OK...
                        funzioni.write_config;
                        writeln('Architecture '+arch+' accepted!');

                        funzioni.execute;
                        sysutils.DeleteFile('/tmp/sfs/'+ProcessID);
                      End
                    Else sendError(


'The software contained into the package is different from your machine''s architecture, can not execute the file !'
                      );
                    funzioni._onunmount;
                    funzioni.sendFlush(ProcessID);
                    writeln('Finished, exiting...');
          End;

  End;


  Procedure Tfunctions.execute;



//this procedre create the thread of the software inclused into the SFS package
// and provide to execute it.

  Var

    i: longint;
    variabili_tot: string;
    varstring: string;

  Begin

    If paramstr(2)>' ' Then
      Begin
        env_file := path+'/env_variables.conf';

        If  sysutils.FileExists(env_file) Then num_of_var_glob := inifile.
                                                                  ReadInteger(


                                                                 'ENVIRONMENT'
                                                                  ,
                                                                  'num_of_var'
                                                                  ,
                                                                  num_of_var);
        parametro2 := paramstr(2);

        If paramcount>2 Then
          Begin
            For i:=3 To paramcount Do
              Begin
                parametro2 := parametro2+' '+paramstr(i);
              End;
          End;
        If isN Then parametro2 := '';
        If parametro2 > ' 'Then parametri := parametro1+' '''+parametro2+''''
        Else parametri := parametro1+' ';

      End
    Else parametri := parametro1;
    writeln('Executing file: '+path+'/'+parametri);


    For i:=1 To num_of_var_glob Do
      Begin
        varstring := varstring+'export '+inifile.ReadString('ENVIRONMENT',
                     'Variable'+
                     inttostr(i),'')+
                     ' && ';
      End;
    variabili_tot := 'cd "'+path+'" && export WORKDIR='+path+' && '+varstring;
    Try
      unix.WaitProcess(funzioni.Systems(variabili_tot+' '+path+'/./'+parametri
      ));
      //si puo' anche usare exec!




//here i have exported the paths as a parameter to pass to the program inclused
// into the sfs

    Except
      writeln('Error '+inttostr(execproc.ExitStatus));
      funzioni.sendError('Error '+inttostr(execproc.ExitStatus));

    End;

  End;




  Procedure Tfunctions.export_env_variables;


//this procedure read the exported library's path and send these to the programm
// to run ever to solve the library sharing problem

  Var

    i: smallint;
    k: smallint;
    replaceflag: Treplaceflags;
    variabile: string;
  Begin

    env_file := path+'/env_variables.conf';

    If  sysutils.FileExists(env_file) Then
      Begin
        env_var := Tinifile.Create(env_file);
        num_of_var := env_var.ReadInteger('ENVIRONMENT','NumOfVar',0);
        If num_of_var > 0 Then
          Begin
            For i:=1 To num_of_var Do
              Begin
                variabile := env_var.ReadString('ENVIRONMENT','Variable'+
                             inttostr(i),' '
                             );
                env_variables[i] := variabile;
                writeln(variabile);
              End;
          End;
      End;
  End;





  Procedure Tfunctions.leggiparameters;


//this procedure read the parameter file (that include the name of
//program to execute)
  Begin
    Try
      parameters_file := path+'/parameters';
      assign(parameters,parameters_file);
      reset(parameters);
      readln(parameters,parametro1);
      closefile(parameters);
    Except
      funzioni.sendError(


           'I/O ERROR ! Unable to read the parameters file !    Please Retry!'
      );
      writeln('I/O ERROR ! Unable to read the parameters file !');
      writeln('Please Retry!');
    End;
  End;

  Procedure Tfunctions.leggidescriptionid;


//this procedure read line after line all the infos about the program contained
// into the SFS and set the architecture type
  Begin
    Try
      descriptionid_file := path+'/description.id';
      assign(descriptionid,descriptionid_file);
      reset(descriptionid);
      readln(descriptionid,nomeprogramma);
      readln(descriptionid,architettura);
      readln(descriptionid,versione);
      readln(descriptionid,autore);
      readln(descriptionid,info);
      If Not EOF(descriptionid) Then readln(descriptionid,mimeTypes);
      closefile(descriptionid);

    Except
      funzioni.sendError(

                        'I/O ERROR ! Unable to read the description.id file !'
      );
      writeln('I/O ERROR ! Unable to read the description.id file !');
    End;
    If  sysutils.AnsiLowerCase(architettura)<>'64' Then
      Begin
        writeln(

       '32 Bit architecture type found! Assuming that is i386 compatible...  '
        )
        ;
        architettura := 'x86';
      End
    Else writeln(


'64 Bit architecture type found! Assuming that is AMD64 or EM64T compatible...  '
      );
  End;

  ///THE MAIN FUNCTION

  Begin

    ProcessID := inttostr(System.GetThreadID);
    //setting the process ID
    opzioni := normale;
    writeln('SFS Stand-Alone Compressed Executable File Launcher');
    writeln(


 'By Vincenzo Dentamaro (c) 2007-2008-2009 for all Linux distros that support'
            +' the squashfs module'
    );
    ps1 := lowercase(paramstr(1));
    ps2 := lowercase(paramstr(2));
    ps3 := lowercase(paramstr(3));
    If ps1  = '-v' Then opzioni := version;
    If ps2  = '-v' Then opzioni := version;
    If ps1  = '-h' Then opzioni := help;
    If ps1  = '--help'Then opzioni := help;
    If ps2  = '-h' Then opzioni := help;
    If ps2  = '--help'Then opzioni := help;
    If ps1  = '--make-loop' Then opzioni := make_loop;
    //  If ps1  = '-d' Then opzioni := desk_path;

    Case opzioni Of

        version:
                 Begin
                   If arch='x86' Then
                     Begin
                       writeln(


              'SFS Launcher Version 1.1.0.0 beta for intel i386 or compatible'
                       );
                       writeln(


  'Special version for Tiger,Ubuntu Feisty,Gutsy,Hardy,Intrepid and newers...'
                       );
                     End
                   Else
                     Begin
                       writeln(


           'SFS Launcher Version 1.0 beta for 64-bit AMD64 or EM64T Platforms'
                       ) ;
                       writeln(

                          'Special version for Ubuntu Feisty-64 and newers...'
                       );
                     End;
                 End;
      help   :
               Begin
                 writeln('Usage: sfslauncher ''file.sfs'' [options]');
                 writeln('The options are:');
                 writeln('-h or --help          # It show this help!');
                 writeln(

                    '-v                    # It show the sfslauncher version!'
                 );
                 writeln(



'--make-loop           # It make loop-back devices if the operating system is'
                 );
                 writeln(

                        '                        not provided or are broken !'
                 ) ;

               End;



                make_loop:
                           Begin
                             If funzioni.is_sudo = true Then
                               Begin
                                 Writeln(

                                     'Flushing existing loop-back devices ...'
                                 );
                                 unix.Shell('rm /dev/loop*');
                                 Writeln('Making loop-back devices ...');
                                 unix.Shell('cp /usr/sbin/sfs/MAKEloop /dev');
                                 unix.Shell('cd /dev && ./MAKEloop loop');
                               End
                             Else writeln(

                                       ' You Must be root ! Please use sudo .'
                               );
                           End;

            normale:
                     Begin
                       nomefilesfs := paramstr(1);
                       If sysutils.FileExists(nomefilesfs) Then
                         Begin
                           If sysutils.ExtractFilePath(nomefilesfs) = '' Then
                             Begin
                               nomefilesfs := sysutils.GetCurrentDir+'/'+
                                              nomefilesfs;
                             End;

                           funzioni._do;
                         End
                       Else
                        if paramstr(1) > ' ' then
                          funzioni.sendError('The file '+nomefilesfs+
                                             ' does not exist!');
                     End;

      End;
End.
