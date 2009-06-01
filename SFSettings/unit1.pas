
Unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, unix, inifiles,
  StdCtrls,Process, Buttons;

Type 

  { TForm1 }

  TForm1 = Class
             (TForm)
             Button1: TButton;
             Button2: TButton;
             Button3: TButton;
             CheckBox1: TCheckBox;
             CheckBox3: TCheckBox;
             CheckBox4: TCheckBox;
             Edit1: TEdit;
             Label1: TLabel;
             sd: TSelectDirectoryDialog;

             Procedure Button1Click(Sender: TObject);

             Procedure Button2Click(Sender: TObject);

             Procedure Button3Click(Sender: TObject);
             procedure Button4Click(Sender: TObject);

             Procedure CheckBox1Change(Sender: TObject);

             Procedure FormCreate(Sender: TObject);

             Procedure FormShow(Sender: TObject);

             Procedure Label1Click(Sender: TObject);
             private
    { private declarations }
             Public 
    { public declarations }
             End;

             Var 
               Form1: TForm1;
               inifile: Tinifile;
               implementation

{ TForm1 }

             Procedure TForm1.FormCreate(Sender: TObject);
             Begin

             End;

             Procedure TForm1.FormShow(Sender: TObject);
             Begin
             if sysutils.FileExists('/etc/sfs/log') then checkbox4.Checked:= true else checkbox4.Checked:=false;
               inifile := Tinifile.Create('/etc/sfs/config.conf');
               If inifile.ReadBool('GLOBAL','export_manifest',false)=true Then
                 Begin
                   checkbox1.Checked := true;
                   edit1.Text := inifile.ReadString('GLOBAL','manifest_dir','');
                 End
               Else checkbox1.checked := false;
               If inifile.ReadBool('GLOBAL','update_link',false)=true Then checkbox3.
                 Checked := true;
             End;

             Procedure TForm1.Label1Click(Sender: TObject);
             var
             proc : Tprocess;
             Begin
              proc := Tprocess.Create(Nil);
              //proc.Options := [poUsePipes];
              proc.CommandLine := 'gnome-open www.unixteam.net';
              proc.Execute;
             End;

             Procedure TForm1.Button1Click(Sender: TObject);
             Begin
               If sd.Execute Then edit1.Text := sd.FileName+'/';

             End;

             Procedure TForm1.Button2Click(Sender: TObject);
             Begin
               unix.Shell('chmod 777 -R ''/etc/sfs/''');
               If checkbox4.Checked then
                Begin
                   if not sysutils.FileExists('/etc/sfs/log')then unix.Shell('echo "For the log file see in /etc/sfs/sfs.log" > /etc/sfs/log');
                end else if sysutils.FileExists('/etc/sfs/log') then sysutils.DeleteFile('/etc/sfs/log');
               
               If checkbox1.Checked Then
                 Begin
                   inifile := Tinifile.Create('/etc/sfs/config.conf');
                   inifile.WriteBool('GLOBAL','export_manifest',true);
                   inifile.WriteString('GLOBAL','manifest_dir',edit1.Text);
                   If checkbox3.Checked Then inifile.WriteBool('GLOBAL','update_link',true
                     )
                   Else inifile.WriteBool('GLOBAL','update_link',false);
                 End
               Else inifile.WriteBool('GLOBAL','export_manifest',false);
                close;
             End;

             Procedure TForm1.Button3Click(Sender: TObject);
             Begin
               close;
             End;

             procedure TForm1.Button4Click(Sender: TObject);
             begin

             end;

             Procedure TForm1.CheckBox1Change(Sender: TObject);
             Begin
               If checkbox1.Checked Then
                 Begin
                   edit1.Enabled := true;
                   button1.Enabled := true;
                 End
               Else
                 Begin
                   edit1.Enabled := false;
                   button1.Enabled := false;
                 End;
             End;


             initialization
  {$I unit1.lrs}

End.
