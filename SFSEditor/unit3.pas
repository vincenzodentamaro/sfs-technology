unit Unit3; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, Menus, inifiles, unix;

type

  { TForm3 }

  TForm3 = class(TForm)
    BitBtn1: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    ListBox1: TListBox;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    PopupMenu1: TPopupMenu;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form3: TForm3; 
  path:String;
  config:Tinifile;

implementation

{ TForm3 }
uses unit1;

procedure TForm3.Button1Click(Sender: TObject);
begin
  listbox1.Items.Add(edit1.Text);
end;

procedure TForm3.Button2Click(Sender: TObject);
begin
  if listbox1.ItemIndex >=0 then
   begin
    listbox1.Items.Delete(listbox1.ItemIndex);
   end;
end;

procedure TForm3.Button3Click(Sender: TObject);
var
i:integer;
begin
   if listbox1.ItemIndex >=0 then
   begin
    i:= listbox1.ItemIndex;
    listbox1.Items.Delete(i);
    listbox1.Items.Insert(i,edit1.Text);
   end;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin

end;

procedure TForm3.MenuItem2Click(Sender: TObject);
begin
  listbox1.Items.Add('LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORKDIR/usr/lib:');
end;

procedure TForm3.MenuItem3Click(Sender: TObject);
begin
  button1.Click;
end;

procedure TForm3.MenuItem4Click(Sender: TObject);
begin
   listbox1.Items.Add('PATH=$PATH:$WORKDIR/usr/bin:');
end;

procedure TForm3.BitBtn1Click(Sender: TObject);
var
i:integer;

begin
config := Tinifile.Create('/tmp/sfs/env_variables.conf');
config.WriteInteger('ENVIRONMENT','NumOfVar',listbox1.Items.Count);
for i:=0 to listbox1.Items.Count-1 do
  begin
   config.WriteString('ENVIRONMENT','Variable'+inttostr(i+1),listbox1.Items.Strings[i]);
  
  end;
  SetCurrentDir(path);
  unix.Shell('cp /tmp/sfs/env_variables.conf '+path+'/env_variables.conf');
  sysutils.DeleteFile('/tmp/sfs/env_variables.conf');
  showmessage('Now you can make the SFS executable file. Select the directory to'+
  'make the SFS.');
  form1.SelectDirectoryDialog1.FileName:=path;
  form1.MenuItem11Click(nil);

 close;

end;

initialization
  {$I unit3.lrs}

end.

