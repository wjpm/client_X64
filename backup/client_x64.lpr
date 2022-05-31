program client_x64;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  SysUtils,
  mORMot,
  mORMotHttpClient,
  cadastroProdutos, DataModule
  { you can add units after this };

{$R *.res}

var
  Server: AnsiString;
begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmCadastroProdutos, frmCadastroProdutos);
  if ParamCount = 0 then
     Server := 'localhost' else
     Server := AnsiString(ParamStr(1));
  frmCadastroProdutos.Database := TSQLHttpClient.Create(Server, '8080', frmCadastroProdutos.Model);
  //TSQLHttpClient(frmCadastroProdutos.Database).SetUser('User', 'synopse');
  Application.Run;
end.

