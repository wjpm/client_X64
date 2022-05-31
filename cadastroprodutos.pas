unit cadastroProdutos;

{$mode objfpc}{$H+}

interface

uses
  {$ifdef MSWINDOWS}
  Windows,
  Messages,
  Graphics,
  {$endif}
  Classes, SysUtils, Forms, Controls, Dialogs, ExtCtrls, Buttons, ComCtrls,
  StdCtrls, SynCommons, SynTable, mORMot, DataModule, mORMotHttpClient ;

type
  TEstadoRegisro = (eUpdate, eInsert, eBrowser);
type
  { TfrmCadastroProdutos }
  TfrmCadastroProdutos = class(TForm)
    btnFechar: TBitBtn;
    btnCancelar: TBitBtn;
    btnIncluir: TBitBtn;
    btnGravar: TBitBtn;
    btnExcluir: TBitBtn;
    btnCadastrarEmLoop: TButton;
    btnQuantosRegistros: TButton;
    lblQuantosRegistros: TLabel;
    lblInicio: TLabel;
    lblFim: TLabel;
    lblMsgCadastrado: TLabel;
    ledQtdRegistros: TLabeledEdit;
    ledCodProduto: TLabeledEdit;
    ledCodigoBarras: TLabeledEdit;
    ledDescricao: TLabeledEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    stbStatus: TStatusBar;
    procedure btnCadastrarEmLoopClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnIncluirClick(Sender: TObject);
    procedure btnQuantosRegistrosClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ledCodProdutoExit(Sender: TObject);
    procedure ledCodProdutoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure limparCampos;
    procedure estadoRegistro(eTipoEstado : TEstadoRegisro);
  public
    Database : TSQLHttpClient ; //TSQLRest;
    Model : TSQLModel;
  end;

var
  frmCadastroProdutos: TfrmCadastroProdutos;
  statusRegistro : TEstadoRegisro;
  RecProduto : TSQLProdutos;

implementation

{$ifdef FPC}
{$R *.lfm}
{$else}
{$R *.dfm}
{$endif}

{ TfrmCadastroProdutos }

procedure TfrmCadastroProdutos.limparCampos;
begin
  ledCodProduto.Clear;
  ledCodigoBarras.Clear;
  ledDescricao.Clear;
end;


procedure TfrmCadastroProdutos.FormCreate(Sender: TObject);
begin
  Model := CreateDataModule;
  limparCampos;
  stbStatus.Panels[0].Text := '';
  stbStatus.Panels[1].Text := '';
  stbStatus.Panels[2].Text := '';
end;

procedure TfrmCadastroProdutos.FormDestroy(Sender: TObject);
begin
  Database.Free;
  Model.Free;
  RecProduto.Free;
end;

procedure TfrmCadastroProdutos.FormShow(Sender: TObject);
begin
  estadoRegistro(eBrowser);
end;

procedure TfrmCadastroProdutos.ledCodProdutoExit(Sender: TObject);
begin
  RecProduto := TSQLProdutos.Create(Database, 'ID=?', [StringToUTF8(ledCodProduto.Text)]);
  try
    if RecProduto.ID=0 then
       stbStatus.Panels[2].Text:='Código não encontrado.' else
    begin
       ledDescricao.Text:= UTF8ToString(RecProduto.Descricao);
       ledCodigoBarras.Text := UTF8ToString(RecProduto.CodigoBarras);
       estadoRegistro(eUpdate);
    end;
  finally
  end;
end;

procedure TfrmCadastroProdutos.ledCodProdutoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if key = VK_RETURN then
     ledCodProduto.OnExit(nil);

end;

procedure TfrmCadastroProdutos.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadastroProdutos.btnCancelarClick(Sender: TObject);
begin
  limparCampos;
  estadoRegistro(eBrowser);
end;

procedure TfrmCadastroProdutos.btnCadastrarEmLoopClick(Sender: TObject);
var
  Rec : TSQLProdutos;
  i : integer ;
  ID : integer ;
begin
   lblInicio.Caption:= FormatDateTime('dd/mm/yyyy hh:nn:ss', now);
   Application.ProcessMessages;
   For i := 0 to StrToInt(ledQtdRegistros.Text) do begin
      Rec := TSQLProdutos.Create;
      try
        Rec.Descricao := StringToUTF8(' REGISTRO ' + FormatFloat('0', i));
        Rec.CodigoBarras := StringToUTF8(IntToStr(i));
        ID := Database.Add(Rec,true);
        if  ID = 0  then
        begin
          Application.MessageBox('Ocorreu um erro ao inserir o registro.', 'Atenção', MB_OK + MB_ICONERROR);
        end
        else
        begin
           //if (i mod 10 = 0) then Application.ProcessMessages;
           lblMsgCadastrado.Caption := FormatFloat('000000', i);
        end;
      finally
        Rec.Free;
      end;
   end;
   lblFim.Caption:= FormatDateTime('dd/mm/yyyy hh:nn:ss', now);
   Application.ProcessMessages;
   Showmessage('Finalizado');
end;

procedure TfrmCadastroProdutos.btnGravarClick(Sender: TObject);
Var
  ID : Integer;
begin
  RecProduto.Descricao := StringToUTF8(ledDescricao.Text);
  RecProduto.CodigoBarras := StringToUTF8(ledCodigoBarras.Text);
  ID := Database.AddOrUpdate(RecProduto,false);
  if  ID = 0  then
  begin
    Application.MessageBox('Ocorreu um erro ao inserir o registro.', 'Atenção', MB_OK + MB_ICONERROR);
    ledDescricao.SetFocus;
  end
  else
  begin
    stbStatus.Panels[0].Text := 'Último registro';
    stbStatus.Panels[1].Text := FormatFloat('000000', ID);
    stbStatus.Panels[2].Text := RecProduto.Descricao;
    limparCampos;
    estadoRegistro(eBrowser);
  end;
end;

procedure TfrmCadastroProdutos.btnIncluirClick(Sender: TObject);
begin
  limparCampos;
  try
    RecProduto.Free;
    RecProduto := TSQLProdutos.Create;
  except
  end;
  estadoRegistro(eInsert);
end;

procedure TfrmCadastroProdutos.btnQuantosRegistrosClick(Sender: TObject);
var
  ResultJson : TSQLTableJSON;
begin
  ResultJson := Database.ExecuteList([TSQLProdutos],
  ' Select ID from Produtos WHERE ID > 1000 AND ID < 1050' );
  if ResultJson <> nil then
  try
    lblQuantosRegistros.Caption:= IntToStr(ResultJson.RowCount);
  finally
    ResultJson.Free;
  end;
end;

procedure TfrmCadastroProdutos.estadoRegistro(eTipoEstado : TEstadoRegisro);
begin
  statusRegistro := eTipoEstado;
  case eTipoEstado of
       eInsert: begin
                     ledCodProduto.Enabled:=False;
                     ledDescricao.Enabled:=True;
                     ledCodigoBarras.Enabled:=True;
                     ledDescricao.SetFocus;
                end;
       eUpdate: begin
                     ledCodProduto.Enabled:=False;
                     ledDescricao.Enabled:=True;
                     ledCodigoBarras.Enabled:=True;
                     ledDescricao.SetFocus;
                end;
       eBrowser:begin
                     ledCodProduto.Enabled:=True;
                     ledDescricao.Enabled:=False;
                     ledCodigoBarras.Enabled:=False;
                     ledCodProduto.SetFocus;
                end;
  end;
end;

end.

