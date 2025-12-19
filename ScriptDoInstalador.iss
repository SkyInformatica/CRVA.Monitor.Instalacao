#define NomeDaAplicacao "SkyDigitalliza.Desktop"
#define NomeDaEmpresa "Sky Informática Ltda."
#define UrlDaAplicacao "https://github.com/SkyInformatica/CRVA.Monitor.Instalacao"
#define NomeDoExecutavelDaAplicacao "SkyInfo.Crva.Digitalliza.Desktop.Serviço.GerenciadorDeAplicações.exe"
#define NomeDoExecutavelDoGerenciadorDeMonitoracao "SkyInfo.Crva.Digitalliza.Desktop.Serviço.GerenciadorDeMonitoração.exe"
#define CaminhoDaFonteDaAplicacao "Binários\gerenciador"
#define CaminhoDoFonteDoGerenciadorDeMonitoracao "Binários\gerenciador-de-monitoração"
#define CaminhoDoAssistenteDeInstalacao "SkyInfo.Crva.Digitalliza.Desktop.Instalador.exe"
#define public Dependency_Path_NetCoreCheck "Dependências\NetCoreCheck\"
#define Versao "20251127"
#define ChaveDoRegistry "Software\Sky Informática Ltda.\SkyDigitalliza.Desktop"

#include "Dependências\CodeDependencies.iss"
#include "Dependências\UtilitáriosDeAdministraçãoWindows.iss"
#include "Dependências\Utilitários.iss"

[Setup]
AppId={{9907afbb-90dd-40c4-837b-d0110e845d5d}}
AppName={#NomeDaAplicacao}
AppVersion={#Versao}
AppPublisher={#NomeDaEmpresa}
AppPublisherURL={#UrlDaAplicacao}
AppSupportURL={#UrlDaAplicacao}
AppUpdatesURL={#UrlDaAplicacao}
DefaultDirName={autopf}\{#NomeDaAplicacao}
ArchitecturesInstallIn64BitMode=win64
DefaultGroupName={#NomeDaAplicacao}
DisableProgramGroupPage=no
PrivilegesRequired=admin
OutputBaseFilename={#NomeDaAplicacao}.Instalador
Compression=lzma
SolidCompression=yes
OutputDir=Instalador
WizardStyle=modern dynamic polar includetitlebar
CloseApplications=force
MergeDuplicateFiles=no
DisableDirPage=yes

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueName: "SkyDigitallizaGerenciadorMonitoracao"; Flags: deletevalue
Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "SkyDigitallizaGerenciadorMonitoracao"; ValueData: """{app}\GerenciadorDeMonitoracao\{#NomeDoExecutavelDoGerenciadorDeMonitoracao}"""; Flags: uninsdeletevalue
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control"; ValueType: dword; ValueName: "ServicesPipeTimeout"; ValueData: 120000; Flags: preservestringtype

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Files]
Source: "Binários\assistente-de-instalação\*"; DestDir: "{tmp}"; Flags: replacesameversion;

[Files]
Source: "{#CaminhoDaFonteDaAplicacao}\{#NomeDoExecutavelDaAplicacao}"; DestDir: "{app}"; Flags: replacesameversion;
Source: "{#CaminhoDaFonteDaAplicacao}\appsettings.json"; DestDir: "{app}"; Flags: replacesameversion;
Source: "{#CaminhoDaFonteDaAplicacao}\*"; DestDir: "{app}"; Excludes: "appsettings.Development.json,Armazenamento\*"; Flags: recursesubdirs createallsubdirs replacesameversion;
Source: "{#CaminhoDaFonteDaAplicacao}\Armazenamento\*"; DestDir: "{app}\Armazenamento"; Flags: recursesubdirs createallsubdirs uninsneveruninstall noencryption nocompression;
Source: "{#CaminhoDoFonteDoGerenciadorDeMonitoracao}\*"; DestDir: "{app}\GerenciadorDeMonitoracao"; Flags: recursesubdirs createallsubdirs replacesameversion;

[UninstallDelete]
Type: files; Name: "{app}\*";
Type: filesandordirs; Name: "{app}\Monitor";
Type: filesandordirs; Name: "{app}\GerenciadorDeMonitoracao";
Type: filesandordirs; Name: "{app}\.temp"
Type: filesandordirs; Name: "{app}\.old";

[InstallDelete]
Type: files; Name: "{app}\*";
Type: filesandordirs; Name: "{app}\Monitor";
Type: filesandordirs; Name: "{app}\GerenciadorDeMonitoracao";
Type: filesandordirs; Name: "{app}\.temp"
Type: filesandordirs; Name: "{app}\.old";

[Code]
const ComandoDeRegistroNormal = 'registrar "%s" "%s"';
const ComandoDeRegistroComCredenciais = 'registrar "%s" "%s" -u "%s" -s "%s"';
const ComandoDeRemocaoDoServico = 'remover "%s"';

// <CAMINHO_DO_APPSETTINGS> <DIRETORIO_DE_DOCUMENTOS> <EMAIL_DO_USUARIO> <SENHA_DO_USUARIO> <ORGANIZACAO_DO_USUARIO> <ARQUIVO_DE_ARMAZENAMENTO_DE_REGISTROS>
const ComandoDeAtualizacaoDoAppSettings = 'atualizar-appsettings "%s" "%s" "%s" "%s" "%s" "%s"';

const ValorDiretorioDocumentos = 'DiretorioDocumentos';
const ValorEmailUsuario = 'EmailUsuario';

function ObterChaveDoRegistry(): String;
begin
  Result := '{#ChaveDoRegistry}';
end;

function LerDiretorioDocumentosAnterior(out Diretorio: String): Boolean;
begin
  Result := RegQueryStringValue(HKCU, ObterChaveDoRegistry(), ValorDiretorioDocumentos, Diretorio);
  if Result and (Diretorio <> '') then
  begin
    Log('Diretório de documentos anterior encontrado: ' + Diretorio);
  end
  else
  begin
    Diretorio := '';
    Result := False;
  end;
end;

function LerEmailUsuarioAnterior(out Email: String): Boolean;
begin
  Result := RegQueryStringValue(HKCU, ObterChaveDoRegistry(), ValorEmailUsuario, Email);
  if Result and (Email <> '') then
  begin
    Log('Email de usuário anterior encontrado: ' + Email);
  end
  else
  begin
    Email := '';
    Result := False;
  end;
end;

procedure SalvarDiretorioDocumentos(Diretorio: String);
begin
  if Diretorio <> '' then
  begin
    RegWriteStringValue(HKCU, ObterChaveDoRegistry(), ValorDiretorioDocumentos, Diretorio);
    Log('Diretório de documentos salvo: ' + Diretorio);
  end;
end;

procedure SalvarEmailUsuario(Email: String);
begin
  if Email <> '' then
  begin
    RegWriteStringValue(HKCU, ObterChaveDoRegistry(), ValorEmailUsuario, Email);
    Log('Email de usuário salvo: ' + Email);
  end;
end;

function IniciarGerenciadorDeMonitoracao(): Boolean;
var
  CaminhoDoGerenciador: String;
  ResultCode: Integer;
begin
  Result := False;
  CaminhoDoGerenciador := ExpandConstant('{app}\GerenciadorDeMonitoracao\{#NomeDoExecutavelDoGerenciadorDeMonitoracao}');
  
  if FileExists(CaminhoDoGerenciador) then
  begin
    if ExecAsOriginalUser(CaminhoDoGerenciador, '', '', SW_HIDE, ewNoWait, ResultCode) then
    begin
      Log('Gerenciador de Monitoração iniciado com sucesso');
      Result := True;
    end
    else
    begin
      Log('Falha ao iniciar o Gerenciador de Monitoração. Código: ' + IntToStr(ResultCode));
    end;
  end
  else
  begin
    Log('Executável do Gerenciador de Monitoração não encontrado: ' + CaminhoDoGerenciador);
  end;
end;

function PararGerenciadorDeMonitoracao(): Boolean;
var
  ResultCode: Integer;
begin
  Result := False;
  if Exec('taskkill', '/F /IM "{#NomeDoExecutavelDoGerenciadorDeMonitoracao}"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    Log('Gerenciador de Monitoração parado com sucesso');
    Result := True;
  end
  else
  begin
    Log('Falha ao parar o Gerenciador de Monitoração ou processo não estava em execução. Código: ' + IntToStr(ResultCode));
    Result := True; // Considera sucesso mesmo se o processo não estava rodando
  end;
end;

var
  PaginaInicial: TOutputMsgWizardPage;
  PaginaDeSelecaoDoDiretorioDeDocumentos: TInputDirWizardPage;
  PaginaDeSelecaoDoTipoDeInicializacaoDoServico: TInputOptionWizardPage;
  PaginaDeCredenciaisDoUsuario: TInputQueryWizardPage;
  PaginaDeSelecaoDaOrganizacao: TInputOptionWizardPage;
  PaginaDeCredenciaisDoWindows: TInputQueryWizardPage;
  UtilizarCredenciaisDoWindows: Boolean;
  Organizacoes: TOrganizacoes;
  OrganizacaoId, DiretorioDeDocumentos, Email, Senha, DominioValido, NomeUsuarioWindows, SenhaWindows: String;

function DevePularPaginaDeOrganizacao(Page: TWizardPage): Boolean;
begin
  Result := Length(Organizacoes) = 1;
  if Result then
  begin
    OrganizacaoId := Organizacoes[0].Id;
  end;
end;

function NaoUtilizarCredenciaisDoWindows(Page: TWizardPage): Boolean;
begin
  Result := PaginaDeSelecaoDoTipoDeInicializacaoDoServico.Values[0] = False;
end;

function ObterParametrosDeRegistroDoServico(): String;
begin
  if not UtilizarCredenciaisDoWindows then
  begin
    Result := Utf8Encode(Format(ComandoDeRegistroNormal, ['{#NomeDaAplicacao}', ExpandConstant('{app}') + '\{#NomeDoExecutavelDaAplicacao}']));
  end
  else
  begin
    Result := Utf8Encode(Format(ComandoDeRegistroComCredenciais, ['{#NomeDaAplicacao}', ExpandConstant('{app}') + '\{#NomeDoExecutavelDaAplicacao}', DominioValido + '\' + NomeUsuarioWindows, SenhaWindows]));
  end;
end;

procedure RemoverGerenciadorDeAplicacoes();
var
  ResultCode: Integer;
begin
  ExecAndLogOutput(ExpandConstant('{tmp}') + '\{#CaminhoDoAssistenteDeInstalacao}', Utf8Encode(Format(ComandoDeRemocaoDoServico, ['{#NomeDaAplicacao}'])), '', SW_HIDE, ewWaitUntilTerminated, ResultCode, nil);
end;

procedure InitializeWizard();
var
  DiretorioAnterior, EmailAnterior: String;
  RespostaDialogo: Integer;
begin
  PaginaInicial := CreateOutputMsgPage(
    wpWelcome,
    'Bem-vindo ao instalador do Monitor de Documentos do Sky Digitaliza!',
    'Para que a instalação seja concluída com sucesso, certifique-se que a instalação está sendo executada com permissões administrativas e que o usuário logado na máquina esteja no mesmo domínio que o administrador.',
    ''
  );

  PaginaDeSelecaoDoDiretorioDeDocumentos := CreateInputDirPage(
    PaginaInicial.ID,
    'Diretório de Documentos do Scanner',
    'Por favor, selecione o diretório de monitoração, nele serão criadas as pastas "Processados" e "Escaneados", caso ainda não existam.',
    'Os documentos que forem enviados para o servidor do Sky Digitaliza serão armazenados na pasta "Processados", os que ainda não foram enviados devem ser armazenados na pasta "Escaneados". Assim que a instalação for concluída, aponte o diretório de saída do scanner para o diretório "Escaneados" para que os documentos sejam digitalizados.',
    True,
    ''
  );
  
  PaginaDeSelecaoDoTipoDeInicializacaoDoServico := CreateInputOptionPage(
    PaginaDeSelecaoDoDiretorioDeDocumentos.ID,
    'Tipo de Instalação', 
    'Utilizar usuário e senha administrativa para criar o serviço?',
    'Caso sua máquina tenha políticas de permissão rígorosas, assinale esta opção.',
    False, 
    False
  );

  PaginaDeCredenciaisDoWindows := CreateInputQueryPage(
    PaginaDeSelecaoDoTipoDeInicializacaoDoServico.ID,
    'Credenciais de Administrador do Windows',
    'Por favor, preencha os campos a seguir com as credenciais de administrador da sua máquina. Isso é necessário para que a aplicação funcione como esperado.',
    ''
  );

  PaginaDeCredenciaisDoUsuario := CreateInputQueryPage(
    PaginaDeCredenciaisDoWindows.ID,
    'Credenciais de Usuário Sky Sistemas',
    'Por favor, preencha as suas credenciais do Sky Sistemas:',
    ''
  );

  PaginaDeSelecaoDaOrganizacao := CreateInputOptionPage(
      PaginaDeCredenciaisDoUsuario.Id,
      'Organização do Usuário',
      'Por favor, escolha a organização que estará utilizando esta aplicação.',
      'Escolher a organização errada irá impedir a aplicação de funcionar corretamente.',
      False,
      False
  );

  PaginaDeSelecaoDoTipoDeInicializacaoDoServico.Add('Utilizar credenciais administrativas.');
  PaginaDeSelecaoDoTipoDeInicializacaoDoServico.Values[0] := False;
  
  PaginaDeSelecaoDaOrganizacao.OnShouldSkipPage := @DevePularPaginaDeOrganizacao;
  PaginaDeCredenciaisDoWindows.OnShouldSkipPage := @NaoUtilizarCredenciaisDoWindows;
  
  // Verificar se existe diretório anterior e perguntar ao usuário
  if LerDiretorioDocumentosAnterior(DiretorioAnterior) then
  begin
    RespostaDialogo := MsgBox('Foi definido anteriormente o diretório "' + DiretorioAnterior + '" como o diretório de documentos em uma instalação anterior.' + #13#10 + #13#10 + 'Gostaria de manter o mesmo?', mbConfirmation, MB_YESNO);
    if RespostaDialogo = IDYES then
    begin
      PaginaDeSelecaoDoDiretorioDeDocumentos.Add(DiretorioAnterior);
      PaginaDeSelecaoDoDiretorioDeDocumentos.Values[0] := DiretorioAnterior;
    end
    else
    begin
      PaginaDeSelecaoDoDiretorioDeDocumentos.Add('');
    end;
  end
  else
  begin
    PaginaDeSelecaoDoDiretorioDeDocumentos.Add('');
  end;

  // Preencher email anterior se existir
  if LerEmailUsuarioAnterior(EmailAnterior) then
  begin
    PaginaDeCredenciaisDoUsuario.Add('Email:', False);
    PaginaDeCredenciaisDoUsuario.Add('Senha:', True);
    PaginaDeCredenciaisDoUsuario.Values[0] := EmailAnterior;
  end
  else
  begin
    PaginaDeCredenciaisDoUsuario.Add('Email:', False);
    PaginaDeCredenciaisDoUsuario.Add('Senha:', True);
  end;

  PaginaDeCredenciaisDoWindows.Add('Usuário:', False);
  PaginaDeCredenciaisDoWindows.Add('Senha:', True);
end;

function InitializeSetup: Boolean;
begin
  Dependency_AddDotNet80;
  Result := True;
end;

procedure ObterDominioDoUsuario(out Resultado: String);
var 
  ResultCode: Integer;
  ListaDeStrings: TArrayOfString;
begin
  if ExecWithResult('whoami', '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode, Resultado) then
  begin
    if ResultCode = 0 then
    begin
      ListaDeStrings := DividirString(Resultado, '\');
      Resultado := ListaDeStrings[0];
    end;
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  JsonResponse: string;
  I, OrganizacoesSelecionadas: Integer;
begin
  Result := True;
  if CurPageID = PaginaDeCredenciaisDoUsuario.ID then
  begin
    Email := PaginaDeCredenciaisDoUsuario.Values[0];
    Senha := PaginaDeCredenciaisDoUsuario.Values[1];

    JsonResponse := ValidarCredenciais(Email, Senha);
    if JsonResponse = '' then
    begin
      Result := False;
    end
    else
    begin
      if Length(Organizacoes) < 1 then
      begin
        Organizacoes := ObterOrganizacoesDoUsuario(JsonResponse);
        if Length(Organizacoes) >= 1 then
        begin
          for I := 0 to Length(Organizacoes) - 1 do
          begin
              PaginaDeSelecaoDaOrganizacao.Add(Organizacoes[I].Nome);
              PaginaDeSelecaoDaOrganizacao.Values[I] := False;
          end;
        end;
      end;

      if Length(Organizacoes) < 1 then
        Result := False;
    end;
  end
  else if CurPageID = PaginaDeSelecaoDaOrganizacao.ID then
  begin
    OrganizacoesSelecionadas := 0;
    for I := 0 to Length(Organizacoes) - 1 do
    begin
      if PaginaDeSelecaoDaOrganizacao.Values[I] = True then
        OrganizacoesSelecionadas := OrganizacoesSelecionadas + 1;
    end;

    if OrganizacoesSelecionadas <> 1 then
    begin
      MsgBox('Escolha apenas UMA organização.', mbInformation, MB_OK);
      Result := False;
      Exit;
    end;
    
    OrganizacaoId := Organizacoes[PaginaDeSelecaoDaOrganizacao.SelectedValueIndex].Id;
  end
  else if CurPageID = PaginaDeCredenciaisDoWindows.ID then
  begin
    NomeUsuarioWindows := PaginaDeCredenciaisDoWindows.Values[0];
    SenhaWindows := PaginaDeCredenciaisDoWindows.Values[1];
    DominioValido := '';
    ObterDominioDoUsuario(DominioValido);
  end;
end;

procedure AtualizarAppSettings(diretorioDoAppSettings: String);
var
  CaminhoDoAppSettings: AnsiString;
  ResultCode: Integer;
  ArquivoDeArmazenamentoDeRegistros: AnsiString;
begin
  CaminhoDoAppSettings := diretorioDoAppSettings + '\appsettings.json';
  DiretorioDeDocumentos := SubstituirString(PaginaDeSelecaoDoDiretorioDeDocumentos.Values[0], '\', '/');
  ArquivoDeArmazenamentoDeRegistros := SubstituirString(ExpandConstant('{app}') + '\Armazenamento\Registros.db', '\', '/');
  
  ExecAndLogOutput(ExpandConstant('{tmp}') + '\{#CaminhoDoAssistenteDeInstalacao}', UTF8Encode(Format(ComandoDeAtualizacaoDoAppSettings, [CaminhoDoAppSettings, DiretorioDeDocumentos, Email, Senha, OrganizacaoId, ArquivoDeArmazenamentoDeRegistros])), '', SW_HIDE, ewWaitUntilTerminated, ResultCode, nil);
end;

procedure ExibirMensagemComResultCode(Mensagem: String; ResultCode: Integer);
var
  MensagemFormatada: String;
begin
  MensagemFormatada := Mensagem+'. [CODIGO: '+IntToStr(ResultCode)+']';
  Log(MensagemFormatada);
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    PararGerenciadorDeMonitoracao();
    RemoverGerenciadorDeAplicacoes();
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  if CurStep = ssInstall then
  begin
    PararGerenciadorDeMonitoracao();
    RemoverGerenciadorDeAplicacoes();
    
    Sleep(1000);
  end;

  if CurStep = ssPostInstall then
  begin
    AtualizarAppSettings(ExpandConstant('{app}'));
    
    // Salvar parâmetros da instalação para uso futuro
    SalvarDiretorioDocumentos(PaginaDeSelecaoDoDiretorioDeDocumentos.Values[0]);
    SalvarEmailUsuario(Email);
    
    // Registra e inicia o serviço principal
    ExecAndLogOutput(ExpandConstant('{tmp}') + '\{#CaminhoDoAssistenteDeInstalacao}', ObterParametrosDeRegistroDoServico(), '', SW_HIDE, ewWaitUntilTerminated, ResultCode, nil);
    ExecAndLogOutput(ExpandConstant('{tmp}') + '\{#CaminhoDoAssistenteDeInstalacao}', 'iniciar "{#NomeDaAplicacao}"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode, nil);
    
    // Inicia o gerenciador de monitoração como usuário normal
    IniciarGerenciadorDeMonitoracao();
  end;
end;
