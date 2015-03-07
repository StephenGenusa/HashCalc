unit frmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.ExtCtrls, IdHashMessageDigest, idHash, FMX.Controls.Presentation, FMX.Edit,
  FMX.Layouts, FMX.Memo, FMX.TabControl, DCPtiger, DCPsha512, DCPsha256,
  DCPsha1, DCPripemd160, DCPripemd128, DCPmd5, DCPmd4, DCPcrypt2, DCPhaval,
  FMX.Menus, System.NetEncoding, System.IOUtils;

// https://bitbucket.org/wpostma/dcpcrypt2010

type
  TForm1 = class(TForm)
    tabBase64: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    memoPlainText: TMemo;
    DropTarget1: TDropTarget;
    edtMD5Hash: TEdit;
    lblMD5: TLabel;
    lblFilename: TLabel;
    edtSHA1Hash: TEdit;
    lblSHA1: TLabel;
    edtSHA256Hash: TEdit;
    lblSHA256: TLabel;
    lblSHA384: TLabel;
    btnEncode: TButton;
    memoBase64Text: TMemo;
    btnDecode: TButton;
    lblSHA512: TLabel;
    lblHaval: TLabel;
    edtHavalHash: TEdit;
    lblMD4: TLabel;
    edtMD4Hash: TEdit;
    memSHA512Hash: TMemo;
    memSHA384Hash: TMemo;
    lblRipeMD160: TLabel;
    edtRipeMD160Hash: TEdit;
    lblRipeMD128: TLabel;
    edtRipeMD128Hash: TEdit;
    lblTiger: TLabel;
    edtTigerHash: TEdit;
    pgbarFileRead: TProgressBar;
    cbMD4: TCheckBox;
    cbMD5: TCheckBox;
    cbRipeMD128: TCheckBox;
    cbRipeMD160: TCheckBox;
    cbSHA1: TCheckBox;
    cbSHA256: TCheckBox;
    cbSHA384: TCheckBox;
    cbSHA512: TCheckBox;
    cbHaval: TCheckBox;
    cbTiger: TCheckBox;
    cbLowercaseHashes: TCheckBox;
    cbCreateHashFiles: TCheckBox;
    procedure DropTarget1Dropped(Sender: TObject; const Data: TDragObject;
      const Point: TPointF);
    procedure DropTarget1DragOver(Sender: TObject; const Data: TDragObject;
      const Point: TPointF; var Operation: TDragOperation);
    procedure FormCreate(Sender: TObject);
    procedure mnuCopyValueClick(Sender: TObject);
    procedure btnEncodeClick(Sender: TObject);
    procedure btnDecodeClick(Sender: TObject);
    procedure cbLowercaseHashesChange(Sender: TObject);
  private
    { Private declarations }
    dcrypt_haval: TDCP_haval;
    dcrypt_md4: TDCP_md4;
    dcrypt_md5: TDCP_md5;
    dcrypt_ripemd128: TDCP_ripemd128;
    dcrypt_ripemd160: TDCP_ripemd160;
    dcrypt_sha1: TDCP_sha1;
    dcrypt_sha256: TDCP_sha256;
    dcrypt_sha384: TDCP_sha384;
    dcrypt_sha512: TDCP_sha512;
    dcrypt_tiger: TDCP_tiger;
    Hashes : array of TDCP_hash;
    HashCheckboxes : array of TCheckbox;
    procedure ClearFieldHashValues;
    procedure EnableHashCheckboxes;
    procedure DisableHashCheckboxes;
    procedure CheckHashCase;
    procedure CreateHashFiles(strFilename : String);
    procedure CalculateFileHash(strFilename : String);
 public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.DropTarget1DragOver(Sender: TObject; const Data: TDragObject;
  const Point: TPointF; var Operation: TDragOperation);
begin
  Operation := TDragOperation.Copy;
end;


procedure TForm1.EnableHashCheckboxes;
begin
  cbMD4.Enabled := True;
  cbMD5.Enabled := True;
  cbRipeMD128.Enabled := True;
  cbRipeMD160.Enabled := True;
  cbSHA1.Enabled := True;
  cbSHA256.Enabled := True;
  cbSHA384.Enabled := True;
  cbSHA512.Enabled := True;
  cbHaval.Enabled := True;
  cbTiger.Enabled := True;
end;


procedure TForm1.DisableHashCheckboxes;
begin
  cbMD4.Enabled := False;
  cbMD5.Enabled := False;
  cbRipeMD128.Enabled := False;
  cbRipeMD160.Enabled := False;
  cbSHA1.Enabled := False;
  cbSHA256.Enabled := False;
  cbSHA384.Enabled := False;
  cbSHA512.Enabled := False;
  cbHaval.Enabled := False;
  cbTiger.Enabled := False;
end;


procedure TForm1.btnDecodeClick(Sender: TObject);
var
  Base64_Decoder : TBase64Encoding;
begin
  memoPlainText.Lines.Clear;
  Base64_Decoder := TBase64Encoding.Create;
  try
    memoPlainText.Lines.Add(Base64_Decoder.Decode(memoBase64Text.Text));
  finally
    Base64_Decoder.Free;
  end;
end;


procedure TForm1.btnEncodeClick(Sender: TObject);
var
  Base64_Encoder : TBase64Encoding;
begin
  memoBase64Text.Lines.Clear;
  Base64_Encoder := TBase64Encoding.Create;
  try
    memoBase64Text.Lines.Add(Base64_Encoder.Encode(memoPlainText.Text));
  finally
    Base64_Encoder.Free;
  end;
end;


procedure TForm1.ClearFieldHashValues;
begin
  edtMD4Hash.Text := 'n/a';
  edtMD5Hash.Text := 'n/a';
  edtRipeMD128Hash.Text := 'n/a';
  edtRipeMD160Hash.Text := 'n/a';
  edtSHA1Hash.Text := 'n/a';
  edtSHA256Hash.Text := 'n/a';
  edtHavalHash.Text := 'n/a';
  edtTigerHash.Text := 'n/a';
  memSHA384Hash.Lines.Clear;
  memSHA384Hash.Lines.Add('n/a');
  memSHA512Hash.Lines.Clear;
  memSHA512Hash.Lines.Add('n/a');
end;


procedure TForm1.CheckHashCase;
var
  strTempHash : String;
begin
  if cbLowercaseHashes.IsChecked then begin
    edtMD4Hash.Text := LowerCase(edtMD4Hash.Text);
    edtMD5Hash.Text := LowerCase(edtMD5Hash.Text);
    edtRipeMD128Hash.Text := LowerCase(edtRipeMD128Hash.Text);
    edtRipeMD160Hash.Text := LowerCase(edtRipeMD160Hash.Text);
    edtSHA1Hash.Text := LowerCase(edtSHA1Hash.Text);
    edtSHA256Hash.Text := LowerCase(edtSHA256Hash.Text);
    edtHavalHash.Text := LowerCase(edtHavalHash.Text);
    edtTigerHash.Text := LowerCase(edtTigerHash.Text);
    strTempHash := LowerCase(memSHA384Hash.Text);
    memSHA384Hash.Lines.Clear;
    memSHA384Hash.Lines.Add(strTempHash);
    strTempHash := LowerCase(memSHA512Hash.Text);
    memSHA512Hash.Lines.Clear;
    memSHA512Hash.Lines.Add(strTempHash);
  end
  else begin
    edtMD4Hash.Text := UpperCase(edtMD4Hash.Text);
    edtMD5Hash.Text := UpperCase(edtMD5Hash.Text);
    edtRipeMD128Hash.Text := UpperCase(edtRipeMD128Hash.Text);
    edtRipeMD160Hash.Text := UpperCase(edtRipeMD160Hash.Text);
    edtSHA1Hash.Text := UpperCase(edtSHA1Hash.Text);
    edtSHA256Hash.Text := UpperCase(edtSHA256Hash.Text);
    edtHavalHash.Text := UpperCase(edtHavalHash.Text);
    edtTigerHash.Text := UpperCase(edtTigerHash.Text);
    strTempHash := UpperCase(memSHA384Hash.Text);
    memSHA384Hash.Lines.Clear;
    memSHA384Hash.Lines.Add(strTempHash);
    strTempHash := UpperCase(memSHA512Hash.Text);
    memSHA512Hash.Lines.Clear;
    memSHA512Hash.Lines.Add(strTempHash);
  end;
end;


procedure TForm1.CreateHashFiles(strFilename : String);

  procedure WriteHashFile(HashFilename, TextValue : String);
  var
    filHashFile : TextFile;
  begin
    AssignFile(filHashFile, HashFilename);
    Rewrite (filHashFile);
    Writeln (filHashFile, TextValue);
    CloseFile(filHashFile);
  end;

  procedure HandleFileExtension(HashCheckbox : TCheckBox; HashEditbox : TEdit; strFileExtension : String);
  var
    intLen : Integer;
    strCurExt : String;
    strHashFilename : String;
  begin
    intLen := Length(strFilename);
    strCurExt := LowerCase(TPath.GetExtension(strFilename));
    if HashCheckbox.IsChecked and (strCurExt <> strFileExtension) then begin
      strHashFilename := strFilename + strFileExtension;
      if not FileExists(strHashFilename) then
        WriteHashFile(strHashFilename, HashEditbox.Text + ' ' + strFilename);
    end;
  end;

begin
  HandleFileExtension(cbMD5, edtMD5Hash, '.md5');
  HandleFileExtension(cbSHA1, edtSHA1Hash, '.sha1');
 // HandleFileExtension(cbMD5, edtMD5Hash, '.md5');
end;


procedure TForm1.CalculateFileHash(strFilename : String);
var
  HashDigest: array of byte;
  i, j, read: integer;
  s: string;
  buffer: array[0..16383] of byte;
  strmInput: TFileStream;
  pcount : integer;

  procedure AddHashFunctionToList (hashFunction : TDCP_hash);
  begin
    SetLength(Hashes, Length(Hashes)+1);
    Hashes[Length(Hashes)-1] := hashFunction;
  end;

begin
  DisableHashCheckboxes;
  ClearFieldHashValues;
  lblFilename.Text := strFilename;

  Hashes := nil;
  if cbMD4.IsChecked then AddHashFunctionToList(dcrypt_md4);
  if cbMD5.IsChecked then AddHashFunctionToList(dcrypt_md5);
  if cbRipeMD128.IsChecked then AddHashFunctionToList(dcrypt_ripemd128);
  if cbRipeMD160.IsChecked then AddHashFunctionToList(dcrypt_ripemd160);
  if cbSHA1.IsChecked then AddHashFunctionToList(dcrypt_sha1);
  if cbSHA256.IsChecked then AddHashFunctionToList(dcrypt_sha256);
  if cbSHA384.IsChecked then AddHashFunctionToList(dcrypt_sha384);
  if cbSHA512.IsChecked then AddHashFunctionToList(dcrypt_sha512);
  if cbHaval.IsChecked then AddHashFunctionToList(dcrypt_haval);
  if cbTiger.IsChecked then AddHashFunctionToList(dcrypt_tiger);

  pgbarFileRead.Min := 0;
  pgbarFileRead.Value := 0;
  pgbarFileRead.Visible := True;

  // make a list of all the hash algorithms to use
  for i := 0 to Length(Hashes)-1 do
    TDCP_hash(Hashes[i]).Init;
  strmInput := nil;
  try
    strmInput := TFileStream.Create(strFilename, fmOpenRead or fmShareDenyWrite);
    pgbarFileRead.Max := strmInput.Size;
    pcount := 0;
    repeat
      // read into the buffer
      read := strmInput.Read(buffer,Sizeof(buffer));
      pgbarFileRead.Value := pgbarFileRead.Value + Sizeof(buffer);
      if pcount mod 40 = 0 then Application.ProcessMessages;
      // hash the buffer with each of the selected hashes
      for i := 0 to Length(Hashes) - 1 do begin
        Hashes[i].Update(buffer,read);
      end;
      inc(pcount);
    until read <> Sizeof(buffer);
    strmInput.Free;
    // iterate through the selected hashes
    memSHA384Hash.Lines.Clear;
    memSHA512Hash.Lines.Clear;
    for i := 0 to Length(Hashes) - 1 do
    begin
      SetLength(HashDigest,Hashes[i].HashSize div 8);
      Hashes[i].Final(HashDigest[0]);  // get the output
      s := '';
      for j := 0 to Length(HashDigest) - 1 do  // convert it into a hex string
        s := s + IntToHex(HashDigest[j],2);
      if Hashes[i].Algorithm = 'MD4' then edtMD4Hash.Text := s;
      if Hashes[i].Algorithm = 'MD5' then edtMD5Hash.Text := s;
      if Hashes[i].Algorithm = 'RipeMD-128' then edtRipeMD128Hash.Text := s;
      if Hashes[i].Algorithm = 'RipeMD-160' then edtRipeMD160Hash.Text := s;
      if Hashes[i].Algorithm = 'SHA1' then edtSHA1Hash.Text := s;
      if Hashes[i].Algorithm = 'SHA256' then edtSHA256Hash.Text := s;
      if Hashes[i].Algorithm = 'SHA384' then memSHA384Hash.Lines.Add(s);
      if Hashes[i].Algorithm = 'SHA512' then memSHA512Hash.Lines.Add(s);
      if Hashes[i].Algorithm = 'Haval (256bit, 5 passes)' then edtHavalHash.Text := s;
      if Hashes[i].Algorithm = 'Tiger' then edtTigerHash.Text := s;
      //txtOutput.Lines.Add(Hashes[i].Algorithm + ': ' + s);
    end;
    if cbCreateHashFiles.IsChecked then
      CreateHashFiles(strFilename);
  except
    strmInput.Free;
  end;
  CheckHashCase;
  pgbarFileRead.Visible := False;
  EnableHashCheckboxes;
end;

procedure TForm1.cbLowercaseHashesChange(Sender: TObject);
begin
  CheckHashCase;
end;

procedure TForm1.DropTarget1Dropped(Sender: TObject; const Data: TDragObject;
  const Point: TPointF);
begin
  CalculateFileHash(Data.Files[0]);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  dcrypt_haval:= TDCP_haval.Create(self);
  dcrypt_md4:= TDCP_md4.Create(self);
  dcrypt_md5:= TDCP_md5.Create(self);
  dcrypt_ripemd128:= TDCP_ripemd128.Create(self);
  dcrypt_ripemd160:= TDCP_ripemd160.Create(self);
  dcrypt_sha1:= TDCP_sha1.Create(self);
  dcrypt_sha256:= TDCP_sha256.Create(self);
  dcrypt_sha384:= TDCP_sha384.Create(self);
  dcrypt_sha512:= TDCP_sha512.Create(self);
  dcrypt_tiger:= TDCP_tiger.Create(self);

  lblMD4.TextAlign := TTextAlign.Trailing;
  lblMD5.TextAlign := TTextAlign.Trailing;
  lblRipeMD128.TextAlign := TTextAlign.Trailing;
  lblRipeMD160.TextAlign := TTextAlign.Trailing;
  lblSHA1.TextAlign := TTextAlign.Trailing;
  lblSHA256.TextAlign := TTextAlign.Trailing;
  lblSHA384.TextAlign := TTextAlign.Trailing;
  lblSHA512.TextAlign := TTextAlign.Trailing;
  lblHaval.TextAlign := TTextAlign.Trailing;
  lblTiger.TextAlign := TTextAlign.Trailing;
  ClearFieldHashValues;
  pgbarFileRead.Visible := False;

  if ParamCount = 1 then begin
    if FileExists(ParamStr(1)) then
      CalculateFileHash(ParamStr(1));
  end;
end;

procedure TForm1.mnuCopyValueClick(Sender: TObject);
begin
  //
end;

end.
