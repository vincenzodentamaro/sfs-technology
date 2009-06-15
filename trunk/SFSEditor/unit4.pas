unit Unit4; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, ExtDlgs,unit3, unix;

type

  { TForm4 }

  TForm4 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    op: TOpenPictureDialog;
    OpenDialog1: TOpenDialog;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form4: TForm4; 
  Form3: Tform3;
  iconName:String;
  path:String;
  
implementation

{ TForm4 }

procedure TForm4.Image1Click(Sender: TObject);
begin

end;

procedure TForm4.Button1Click(Sender: TObject);
begin
op.InitialDir:=path;
op.FileName:=path;
 if op.Execute then
  begin
   iconName:=op.FileName;
   image1.Picture.LoadFromFile(iconName);
  end;

end;

procedure TForm4.Button2Click(Sender: TObject);
begin
  opendialog1.InitialDir:=path+'/usr/bin';
  if opendialog1.Execute then
   begin
      edit1.Text:='usr/bin/'+sysutils.ExtractFileName(opendialog1.FileName);
   end;
end;

procedure TForm4.BitBtn1Click(Sender: TObject);
var
f:TextFile;
begin
     Try
     system.Assign(f,path+'/description.id');
      rewrite(f);
      writeln(f,edit2.Text);
      writeln(f,combobox1.Text);
      writeln(f,edit4.Text);
      writeln(f,edit5.Text);
      writeln(f,edit6.Text);
      writeln(f,edit7.Text);
      closefile(f);
    Except
      showmessage('Unable to write the file description.id');
    End;
      Try
     system.Assign(f,path+'/parameters');
      rewrite(f);
      writeln(f,edit1.Text);
      closefile(f);
    Except
      showmessage('Unable to write the file parameters');
    End;
  if  iconName <= ' ' then
   begin
      form4.Button1.Click;
      unix.Shell('cp '+iconName+' '+path+'/icon.png');
   end else
   begin
      unix.Shell('cp '+iconName+' '+path+'/icon.png');
   end;
  unit3.path:=path;
  form3.MenuItem2.Click;
  form3.MenuItem4.Click;
  form3.ShowModal;

end;

procedure TForm4.FormCreate(Sender: TObject);
begin

end;

initialization
  {$I unit4.lrs}

end.

