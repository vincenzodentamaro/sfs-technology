unit Unit2; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources,unix, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ComCtrls, Process, unit5, unit4, unit3;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ck: TCheckBox;
    cm: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    od: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ckChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ckClick(Sender: TObject);
    procedure cmChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form2: TForm2; 
  isDebian: boolean;
  isTarball: boolean;
  isRpm: boolean;
  path: String;
  tmpPath:String;
  processID:string;
implementation

{ TForm2 }
uses unit1;

procedure TForm2.FormCreate(Sender: TObject);
begin
processID:=inttostr(GetProcessID);
tmpPath:= '/tmp/sfs'+processID;
   isDebian:=true;
   isTarball:=false;
   isRpm:=false;

end;

procedure TForm2.ckClick(Sender: TObject);
begin
    if ck.Checked = true then
   begin
     button1.Enabled:=false;
     ck.Checked:=false;
     edit2.Enabled:=false;
   end;
  if ck.Checked = false then
   begin
     button1.Enabled:=true;
     ck.Checked:=true;
     edit2.Enabled:=true;
   end;
end;

procedure TForm2.cmChange(Sender: TObject);
begin
if cm.Items.Strings[cm.ItemIndex]= 'Debian package (*.deb)'then
  begin
   isDebian:=true;
   isTarball:=false;
   isRpm:=false;
  end;
if cm.Items.Strings[cm.ItemIndex]= 'RPM package (*.rpm)'then
  begin
  isDebian:=false;
  isRpm:=true;
  isTarball:=false;

  end;
if cm.Items.Strings[cm.ItemIndex]= 'Tarball package (*tar.gz/*tar.bz2)'then
  begin
  isDebian:=false;
  isRpm:=false;
  isTarball:=true;
  end;


end;

procedure TForm2.ckChange(Sender: TObject);
begin
  if ck.Checked = true then
   begin
     button1.Enabled:=true;

     edit2.Enabled:=false;
   end;
  if ck.Checked = false then
   begin
     button1.Enabled:=false;

     edit2.Enabled:=true;
   end;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
if isDebian then
 begin
   od.Filter:='Debian package (*.deb)|*.deb';
   od.Title:='Open debian package';
   od.DefaultExt:='deb';
   if od.Execute then
     begin
      label3.Caption:=od.FileName;
     end;
 
 end;
 if isRpm then
 begin
   od.Filter:='Red Hat package manager file format (*.rpm)|*.rpm';
   od.Title:='Open RPM package';
   od.DefaultExt:='rpm';
   if od.Execute then
     begin
      label3.Caption:=od.FileName;
     end;

 end;
 if isTarball then
 begin
   od.Filter:='Tarball package (*.tar.gz;*.tar.bz2)|*.tar.gz;*.tar.bz2';
   od.Title:='Open tarball package';
   od.DefaultExt:='tar.gz';
   if od.Execute then
     begin
      label3.Caption:=od.FileName;
     end;

 end;

end;

procedure TForm2.Button2Click(Sender: TObject);
var
f:textfile;
curr_dir: String;
proc:Tprocess;
searchResult : TSearchRec;
begin

  proc := Tprocess.Create(nil);
  curr_dir:= sysutils.ExtractFilePath(application.ExeName);
  sysutils.CreateDir('/tmp/SFSeditor');
  if path <= ' ' then
  begin
  if sysutils.DirectoryExists('/tmp/SFSeditor/'+edit1.Text) then
    begin
      sysutils.CreateDir('/tmp/SFSeditor/'+edit1.Text+inttostr(System.GetThreadID));
      path := '/tmp/SFSeditor/'+edit1.Text+inttostr(System.GetThreadID);
    end else
       begin
        sysutils.CreateDir('/tmp/SFSeditor/'+edit1.Text);
        path:='/tmp/SFSeditor/'+edit1.Text;
       end;
   end;
SetCurrentDir('/var/cache/apt/archives/');
  form5.show;
  proc.Options:=[poNewConsole];
  if ck.Checked then
   begin

   //estrai il file selezionato e scarica ed estrai le dipendenze
   if isDebian then
     begin
      proc.CommandLine := 'dpkg --extract '+od.FileName+' '+Path;
      proc.Execute;
      proc.CommandLine := curr_dir+'/tools/./getlibs '+Path+'/usr/bin/*';
      proc.Execute;
    end;
   end;
  if ck.Checked=false then
   begin
    if isDebian then
     begin
     Try
        system.Assign(f,'/tmp/toExecute');
        rewrite(f);
        writeln(f,'#! /bin/sh');
        writeln(f,'apt-get clean');
        writeln(f,'apt-get install -d -y '+sysutils.AnsiLowerCase(edit2.Text));
        closefile(f);
     Except
        showmessage('Unable to write the file parameters');
     End;

      proc.Options:=[poNewConsole,poWaitOnExit];
      proc.CommandLine := 'chmod 777 /tmp/toExecute';
      proc.Execute;
      proc.CommandLine :='gksu /tmp/toExecute';
      proc.Execute;
      sysutils.DeleteFile('/tmp/toExecute');
      proc.Options:=[poNewConsole];
    if FindFirst('*.deb', faAnyFile, searchResult) = 0 then
    begin
      repeat
        form5.Memo1.Lines.Add('Processing file '+searchResult.Name);
        form5.Memo1.Lines.Add('File size = '+IntToStr(searchResult.Size));
        proc.CommandLine := 'dpkg --extract '+searchResult.Name+' '+Path;
        proc.Execute;

      until FindNext(searchResult) <> 0;

      // Must free up resources used by these successful finds
      FindClose(searchResult);
    end;

  end;
  unit1.projectPath:=path;
  unit4.path:=path;
  form4.ShowModal;
    
 end;

end;

initialization
  {$I unit2.lrs}

end.

