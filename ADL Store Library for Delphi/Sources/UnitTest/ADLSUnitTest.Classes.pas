unit ADLSUnitTest.Classes;

interface

uses
  DUnitX.TestFramework, ADLSConnector.Interfaces, ADLSFileManager.Interfaces,
  ADLSConnector.Presenter, ADLSFileManager.Presenter,
  System.Generics.Collections, IPPeerCommon;

type

  TADLSFakeView = class(TInterfacedObject, IADLSConnectorView, IADLSFileManagerView)
  protected
    FBaseURL: string;
    FClientID: string;
    FClientSecret: string;
    FAccessTokenEndpoint: string;
    FAuthorizationEndpoint: string;
    FFMBaseURL: string;
    FFMDirectory: string;
    FFMFilePath: string;

    FFMDirectories: TList<string>;
    FADLSConnectorP: IADLSConnectorPresenter;
    FADLSFileManagerP: IADLSFileManagerPresenter;
  public
    constructor Create(const ABaseURL, AClientID, AClientSecret, AAccessTokenEndpoint,
      AAuthorizationEndpoint, AFMBaseURL: string);
    //destructor Destroy; override;
    // Input connector
    function GetBaseURL: string;
    function GetClientID: string;
    function GetClientSecret: string;
    function GetAccessTokenEndpoint: string;
    function GetAuthorizationEndpoint: string;
    // Input file manager
    function GetFMBaseURL: string;
    function GetFMDirectory: string;
    function GetFMFilePath: string;
    // Output connector
    procedure SetAccessToken(const AValue: string);
    procedure SetResponseData(const AValue: string);
    procedure AddResponseData(const AValue: string);
    // Output file manager
    procedure DisplayFMMessage(AValue: string);
    procedure SetFMDirectory(AValue: TList<string>);
    procedure SetFMResponseData(const AValue: string);
    procedure AddFMResponseData(const AValue: string);

    procedure GetAccessToken;
  end;

  [TestFixture]
  TADLSUnitTest = class(TObject)
  protected
    FBaseURL: string;
    FClientID: string;
    FClientSecret: string;
    FAccessTokenEndpoint: string;
    FAuthorizationEndpoint: string;
    FFMBaseURL: string;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    // Sample Methods
    // Simple single Test
    //[Test]
    //procedure Test1;
    // Test with TestCase Atribute to supply parameters.
    //[Test]
    //[TestCase('TestA','1,2')]
    //[TestCase('TestB','3,4')]
    //procedure Test2(const AValue1 : Integer;const AValue2 : Integer);

    [Test]
    procedure GetAccessToken;

    [Test]
    procedure ListFolders;
  end;

implementation

uses
  System.SysUtils;

procedure TADLSUnitTest.GetAccessToken;
var
  LADLSFakeView: TADLSFakeView;
begin
  LADLSFakeView := TADLSFakeView.Create(FBaseURL, FClientID, FClientSecret,
    FAccessTokenEndpoint, FAuthorizationEndpoint, FFMBaseURL);

  try
    LADLSFakeView.GetAccessToken;

    if (LADLSFakeView.FADLSConnectorP.AccessToken = '') then
      raise Exception.Create('Error retrieving the access token');
  finally
    //LADLSFakeView.Free;
  end;
end;

procedure TADLSUnitTest.ListFolders;
var
  LADLSFakeView: TADLSFakeView;
begin
  LADLSFakeView := TADLSFakeView.Create(FBaseURL, FClientID, FClientSecret,
    FAccessTokenEndpoint, FAuthorizationEndpoint, FFMBaseURL);
  try
    LADLSFakeView.FADLSConnectorP.GetAccessToken;

    if (LADLSFakeView.FADLSConnectorP.AccessToken = '') then
      raise Exception.Create('Error retrieving the access token');

    LADLSFakeView.FADLSFileManagerP.ListFolders;

    if (LADLSFakeView.FADLSFileManagerP.GetListFolders.Text = '') then
      raise Exception.Create('Error retrieving the list folders');
  finally
    //LADLSFakeView.Free;
  end;
end;

procedure TADLSUnitTest.Setup;
begin
  FBaseURL := '';
  FClientID := '';
  FClientSecret := '';
  FAccessTokenEndpoint := 'https://login.windows.net/<TENANTID or DIRECTORYID>/oauth2/token';
  FAuthorizationEndpoint := '';
  FFMBaseURL := 'https://<DATA LAKE STORE NAME>.azuredatalakestore.net';
end;

procedure TADLSUnitTest.TearDown;
begin
end;

//procedure TADLSUnitTest.Test1;
//begin
//end;

//procedure TADLSUnitTest.Test2(const AValue1 : Integer;const AValue2 : Integer);
//begin
//end;

{ TADLSFakeView }

procedure TADLSFakeView.AddFMResponseData(const AValue: string);
begin
  System.Write(AValue);
end;

procedure TADLSFakeView.AddResponseData(const AValue: string);
begin
  System.Write(AValue);
end;

constructor TADLSFakeView.Create(const ABaseURL, AClientID, AClientSecret,
  AAccessTokenEndpoint, AAuthorizationEndpoint, AFMBaseURL: string);
begin
  // Connector
  FBaseURL := ABaseURL;
  FClientID := AClientID;
  FClientSecret := AClientSecret;
  FAccessTokenEndpoint := AAccessTokenEndpoint;
  FAuthorizationEndpoint := AAuthorizationEndpoint;

  // File Manager
  FFMBaseURL := AFMBaseURL;
  FFMDirectories := TList<string>.Create;

  FADLSConnectorP := TADLSConnectorPresenter.Create(Self);
  FADLSFileManagerP := TADLSFileManagerPresenter.Create(FADLSConnectorP, Self);
end;

//destructor TADLSFakeView.Destroy;
//begin
//  // Interfaces are released automatically
//  //FADLSFileManagerP.Free;
//  //FADLSConnectorP.Free;
//
//  inherited;
//end;

procedure TADLSFakeView.DisplayFMMessage(AValue: string);
begin
  System.Write(AValue);
end;

procedure TADLSFakeView.GetAccessToken;
begin
  FADLSConnectorP.GetAccessToken;
end;

function TADLSFakeView.GetAccessTokenEndpoint: string;
begin
  Result := FAccessTokenEndpoint;
end;

function TADLSFakeView.GetAuthorizationEndpoint: string;
begin
  Result := FAuthorizationEndpoint;
end;

function TADLSFakeView.GetBaseURL: string;
begin
  Result := FBaseURL;
end;

function TADLSFakeView.GetClientID: string;
begin
  Result := FClientID;
end;

function TADLSFakeView.GetClientSecret: string;
begin
  Result := FClientSecret;
end;

function TADLSFakeView.GetFMBaseURL: string;
begin
  Result := FFMBaseURL;
end;

function TADLSFakeView.GetFMDirectory: string;
begin

end;

function TADLSFakeView.GetFMFilePath: string;
begin

end;

procedure TADLSFakeView.SetAccessToken(const AValue: string);
begin
  System.Write('');
  System.Write('Access token..');
  System.Write(AValue);
end;

procedure TADLSFakeView.SetFMDirectory(AValue: TList<string>);
var
  i: Integer;
begin
  FFMDirectories.Clear;

  for i := 0 to AValue.Count - 1 do
    FFMDirectories.Add(AValue.Items[i]);
end;

procedure TADLSFakeView.SetFMResponseData(const AValue: string);
begin

end;

procedure TADLSFakeView.SetResponseData(const AValue: string);
begin
  System.Write('');
  System.Write(GetBaseURL);
  System.Write(AValue);
end;

initialization
  TDUnitX.RegisterTestFixture(TADLSUnitTest);

end.
