#define NomeDaAplicacao "SkyDigitalliza.Desktop"
#define NomeDoMonitorNoSistema "SkyInfo.Crva.Digitalliza.Desktop.Serviço.Monitor"
#define NomeDaEmpresa "Sky Informática Ltda."
#define UrlDaAplicacao "https://github.com/SkyInformatica/CRVA.Monitor.Instalacao"
#define NomeDoExecutavelDaAplicacao "SkyInfo.Crva.Digitalliza.Desktop.Serviço.GerenciadorDeAplicações.exe"
#define CaminhoDaFonteDaAplicacao "gerenciador"
#define public Dependency_Path_NetCoreCheck "Dependências\NetCoreCheck\"

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
DisableProgramGroupPage=yes
PrivilegesRequired=admin
OutputBaseFilename={#NomeDaAplicacao}.Instalador
Compression=lzma
SolidCompression=yes
OutputDir=D:\a\{#NomeDaAplicacao}\{#NomeDaAplicacao}\Instalador
WizardStyle=modern
CloseApplications=force
MergeDuplicateFiles=no

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

; --> Arquivos x64
[Files]
Source: "{#CaminhoDaFonteDaAplicacao}\x64\{#NomeDoExecutavelDaAplicacao}"; DestDir: "{app}"; Flags: replacesameversion; Check: Is64BitInstallMode; Permissions: everyone-modify;
Source: "{#CaminhoDaFonteDaAplicacao}\x64\appsettings.json"; DestDir: "{app}"; Flags: replacesameversion; Check: Is64BitInstallMode; Permissions: everyone-modify;
Source: "{#CaminhoDaFonteDaAplicacao}\x64\*"; DestDir: "{app}"; Excludes: "appsettings.Development.json,Armazenamento\*"; Flags: recursesubdirs createallsubdirs replacesameversion; Check: Is64BitInstallMode; Permissions: everyone-modify;
Source: "{#CaminhoDaFonteDaAplicacao}\x64\Armazenamento\*"; DestDir: "{app}\Armazenamento"; Flags: recursesubdirs createallsubdirs uninsneveruninstall noencryption nocompression; Check: Is64BitInstallMode; Permissions: everyone-modify;

; --> Arquivos x86
[Files]
Source: "{#CaminhoDaFonteDaAplicacao}\x86\{#NomeDoExecutavelDaAplicacao}"; DestDir: "{app}"; Flags: replacesameversion; Check: InstalacaoEm32Bits; Permissions: everyone-modify;
Source: "{#CaminhoDaFonteDaAplicacao}\x86\appsettings.json"; DestDir: "{app}"; Flags: replacesameversion; Check: InstalacaoEm32Bits; Permissions: everyone-modify;
Source: "{#CaminhoDaFonteDaAplicacao}\x86\*"; DestDir: "{app}"; Excludes: "appsettings.Development.json,Armazenamento\*"; Flags: recursesubdirs createallsubdirs replacesameversion; Check: InstalacaoEm32Bits; Permissions: everyone-modify;
Source: "{#CaminhoDaFonteDaAplicacao}\x86\Armazenamento\*"; DestDir: "{app}\Armazenamento"; Flags: recursesubdirs createallsubdirs uninsneveruninstall noencryption nocompression; Check: InstalacaoEm32Bits; Permissions: everyone-modify;

[UninstallDelete]
Type: files; Name: "{app}\Chave.txt";
Type: filesandordirs; Name: "{app}\Monitor";

[InstallDelete]
Type: files; Name: "{app}\Chave.txt"; 
Type: files; Name: "{app}\appsettings.json";
Type: filesandordirs; Name: "{app}\Monitor";

[Code]
const Debug = False;

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

function InstalacaoEm32Bits: Boolean;
begin
  Result := Is64BitInstallMode() = False;
end;

procedure InitializeWizard();
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
  
  PaginaDeSelecaoDoDiretorioDeDocumentos.Add('');

  PaginaDeCredenciaisDoUsuario.Add('Email:', False);
  PaginaDeCredenciaisDoUsuario.Add('Senha:', True);

  PaginaDeCredenciaisDoWindows.Add('Usuário:', False);
  PaginaDeCredenciaisDoWindows.Add('Senha:', True);
end;

function InitializeSetup: Boolean;
begin
  Dependency_AddDotNet80;
  Result := True;
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
  end;
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

procedure AtualizarAppSettings();
var
  JSONString, CaminhoDoAppSettings: AnsiString;
begin
  CaminhoDoAppSettings := ExpandConstant('{app}\appsettings.json');
  DiretorioDeDocumentos := SubstituirString(PaginaDeSelecaoDoDiretorioDeDocumentos.Values[0], '\', '/');
  JSONString := ObterTextoDoArquivo(CaminhoDoAppSettings);
  if JSONString = '' then
  begin
    MsgBox('Falha ao ler o appsettings.json ou o arquivo está vazio.', mbError, MB_OK);
    Exit;
  end;
  
  JSONString := SubstituirString(JSONString, '"DIRETORIO_DE_DOCUMENTOS"', '"' + DiretorioDeDocumentos + '"');
  JSONString := SubstituirString(JSONString, '"EMAIL_DO_USUARIO"', '"' + Email + '"');
  JSONString := SubstituirString(JSONString, '"SENHA_DO_USUARIO"', '"' + Senha + '"');
  JSONString := SubstituirString(JSONString, '"ORGANIZACAO_DO_USUARIO"', '"' + OrganizacaoId + '"');
  JSONString := SubstituirString(JSONString, '"USUARIO_WINDOWS"', '"' + NomeUsuarioWindows + '"');
  JSONString := SubstituirString(JSONString, '"SENHA_WINDOWS"', '"' + SenhaWindows + '"');

  SalvarTextoEmArquivo(CaminhoDoAppSettings, JSONString);
end;

procedure ExibirMensagemComResultCode(Mensagem: String; ResultCode: Integer);
var
  MensagemFormatada: String;
begin
  if Debug = True then
  begin
    MensagemFormatada := Mensagem+'. [CODIGO: '+IntToStr(ResultCode)+']';
    MsgBox(MensagemFormatada, mbInformation, MB_OK);
  end;
end;

procedure CriarServicoDoWindows(NomeUsuario, SenhaUsuario, DominioUsuario: string);
var
  ResultCode: Integer;
begin
  UtilizarCredenciaisDoWindows := PaginaDeSelecaoDoTipoDeInicializacaoDoServico.Values[0];
  if not UtilizarCredenciaisDoWindows then
  begin
    Exec('sc', 'create {#NomeDaAplicacao} displayName="Sky Digitaliza - Desktop" binPath= "' + ExpandConstant('{app}\{#NomeDoExecutavelDaAplicacao}') + '" start= auto obj="LocalSystem"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end
  else
  begin
    Exec('sc', 'create {#NomeDaAplicacao} displayName="Sky Digitaliza - Desktop" binPath= "' + ExpandConstant('{app}\{#NomeDoExecutavelDaAplicacao}') +
      '" start= auto obj= "' + DominioUsuario + '\' + NomeUsuario + '" password= "' + SenhaUsuario + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  Dominio: string;
begin
  if CurStep = ssInstall then
  begin
    if Exec('sc', 'stop {#NomeDaAplicacao}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      ExibirMensagemComResultCode('Serviço do Windows foi parado', ResultCode);
    end;
    Sleep(1000);
  end;

  if CurStep = ssPostInstall then
  begin
    AtualizarAppSettings();
  end;
  
  if CurStep = ssDone then
  begin
    NomeUsuarioWindows := PaginaDeCredenciaisDoWindows.Values[0];
    SenhaWindows := PaginaDeCredenciaisDoWindows.Values[1];
    ObterDominioDoUsuario(Dominio);
    
    CriarServicoDoWindows(NomeUsuarioWindows, SenhaWindows, Dominio);
    ExibirMensagemComResultCode('Serviço criado', ResultCode);
    Sleep(1500);
    if Exec('sc', 'start {#NomeDaAplicacao}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      ExibirMensagemComResultCode('Serviço iniciado', ResultCode);
    end
    else
    begin
      ExibirMensagemComResultCode('Erro ao tentar iniciar o serviço no Windows', ResultCode);
    end;
  end;
end;

procedure CurUninstallStepChanged(CurStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  if CurStep = usUninstall then
  begin
    if Exec('sc', 'stop {#NomeDaAplicacao}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      ExibirMensagemComResultCode('Serviço do Gerenciador no Windows foi Parado', ResultCode);
      Sleep(1000);
    end;
    
    if Exec('sc', 'delete {#NomeDaAplicacao}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      ExibirMensagemComResultCode('Serviço do Gerenciador no Windows foi deletado', ResultCode);
    end;
	
	if Exec('sc', 'stop {#NomeDoMonitorNoSistema}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      ExibirMensagemComResultCode('Serviço do Monitor no Windows foi Parado', ResultCode);
      Sleep(1000);
    end;
    
    if Exec('sc', 'delete {#NomeDoMonitorNoSistema}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      ExibirMensagemComResultCode('Serviço do Monitor no Windows foi deletado', ResultCode);
    end;
    
    Sleep(1000);
  end;
end;
