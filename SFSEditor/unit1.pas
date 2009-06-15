unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, unit2, unit3, process, unix;

type

  { TForm1 }

  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
  private
    { private declarations }
    function is_sudo:boolean;
  public
    { public declarations }
    
  end; 

var
  Form1: TForm1; 
  sudoers:TextFile;
  projectPath:String;


implementation

{ TForm1 }
Function Tform1.is_sudo: boolean; //this simple boolean function is intended to be used for determinate if we are working in super user mode or not.
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


procedure TForm1.FormCreate(Sender: TObject);
begin


end;

procedure TForm1.FormShow(Sender: TObject);
begin
 { if not form1.is_sudo then
  begin
   showmessage('You must be root to use this software');
   form1.Close;
  end;           }
end;

procedure TForm1.Memo1Change(Sender: TObject);
begin


end;

procedure TForm1.MenuItem11Click(Sender: TObject);
var
dir:String;
proc:Tprocess;
curDir:String;
begin
 selectdirectorydialog1.InitialDir:='/tmp/SFSeditor/';
 curDir:= sysutils.ExtractFilePath(application.ExeName);
 proc := Tprocess.Create(nil);
 proc.Options:=[poNewConsole];
 if selectdirectorydialog1.Execute then
  begin
   dir:=selectdirectorydialog1.FileName;
   if sysutils.DirectoryExists(dir) then
    begin
      if savedialog1.Execute then
      begin
        proc.CommandLine := curDir+'/tools/./mksquashfs '+dir+' '+savedialog1.FileName;
        proc.Execute;
      end;
    end;
  end;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
 form2.showmodal;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
var
proc:Tprocess;
f:textfile;
begin
 proc := Tprocess.Create(nil);
 proc.Options:=[poNewConsole];
   if opendialog1.Execute then
    begin
    try
      proc.CommandLine:= 'tar -v -xf '+opendialog1.FileName+' > /tmp/sfsproj';
      proc.Execute;

        system.Assign(f,'/tmp/sfsproj');
        reset(f);
        readln(f,path);
        closefile(f);
           Except
        showmessage('Unable to read the file /tmp/sfsproj');
         end;
        form2.ShowModal;
    end;
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
var
proc:Tprocess;
begin
if projectpath > ' ' then
begin
 proc:= Tprocess.Create(nil);
 proc.Options:=[poNewConsole];
   if savedialog2.Execute then
    begin
      proc.CommandLine:= 'tar -cf '+savedialog2.FileName+' '+projectpath;
      proc.Execute;

    end;
end else showmessage('Create a project first!');
end;

procedure TForm1.MenuItem7Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.MenuItem8Click(Sender: TObject);
begin
  showmessage('V0.01 Beta 1. Created by Vincenzo Dentamaro vincenzodentamaro@hotmail.com');
end;

procedure TForm1.MenuItem9Click(Sender: TObject);
begin
 showmessage('V0.01 Beta 1. Created by Vincenzo Dentamaro vincenzodentamaro@hotmail.com');

end;

initialization
  {$I unit1.lrs}

end.

