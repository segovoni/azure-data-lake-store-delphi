unit ADLSConnector.Presenter;

interface

uses
  ADLSConnector.Interfaces, REST.Client, REST.Authenticator.OAuth;

type
  TADLSConnectorPresenter = class(TInterfacedObject)
  private
    FRESTClient: TRESTClient;
    FRESTRequest: TRESTRequest;
    FRESTResponse: TRESTResponse;
    FOAuth2_AzureDataLake: TOAuth2Authenticator;
    /// <summary>
    ///   Reset all of the rest-components for a new request
    /// </summary>
    procedure ResetRESTComponentsToDefaults;
    procedure InitComponents;
    procedure LocalRESTRequestAfterExecute(Sender: TCustomRESTRequest);
  protected
    FADLSConnector: IADLSView;
    FAccessToken: string;
  public
    constructor Create(AADLSConnectorView: IADLSView);
    destructor Destroy; override;
    procedure GetAccessToken;
    function GetBaseURL: string;
    function GetClientID: string;
    property AccessToken: string read FAccessToken;
    //property Authenticator: TOAuth2Authenticator read FOAuth2_AzureDataLake;
  end;

implementation

uses
  System.SysUtils, REST.Types, REST.Json;

{ TADLSPresenter }

constructor TADLSConnectorPresenter.Create(AADLSConnectorView: IADLSView);
begin
  FADLSConnector := AADLSConnectorView;
  FRESTClient := TRESTClient.Create(''{FADLSConnector.GetBaseURL});
  FRESTRequest := TRESTRequest.Create(nil);
  FRESTResponse := TRESTResponse.Create(nil);
  FOAuth2_AzureDataLake := TOAuth2Authenticator.Create(nil);

  FRESTRequest.OnAfterExecute := LocalRESTRequestAfterExecute;
end;

destructor TADLSConnectorPresenter.Destroy;
begin
  FOAuth2_AzureDataLake.Free;
  FRESTResponse.Free;
  FRESTRequest.Free;
  FRESTClient.Free;
end;

procedure TADLSConnectorPresenter.GetAccessToken;
begin
  ResetRESTComponentsToDefaults;
  InitComponents;

  FRESTClient.BaseURL := FADLSConnector.GetAccessTokenEndpoint;

  FRESTRequest.Method := TRESTRequestMethod.rmPOST;
  FRESTRequest.Params.AddItem('client_id', FADLSConnector.GetClientID, TRESTRequestParameterKind.pkGETorPOST);
  FRESTRequest.Params.AddItem('client_secret', FADLSConnector.GetClientSecret, TRESTRequestParameterKind.pkGETorPOST);
  FRESTRequest.Params.AddItem('grant_type', 'client_credentials', TRESTRequestParameterKind.pkGETorPOST);
  FRESTRequest.Params.AddItem('resource', 'https://management.core.windows.net/');

  FRESTRequest.Execute;

  if FRESTRequest.Response.GetSimpleValue('access_token', FAccessToken) then
  begin
    FOAuth2_AzureDataLake.AccessToken := FAccessToken;
    FADLSConnector.SetAccessToken(FAccessToken);
  end;
end;

function TADLSConnectorPresenter.GetBaseURL: string;
begin
  Result := FADLSConnector.GetBaseURL;
end;

function TADLSConnectorPresenter.GetClientID: string;
begin
  FADLSConnector.GetClientID;
end;

procedure TADLSConnectorPresenter.InitComponents;
begin
  FOAuth2_AzureDataLake.AccessTokenEndpoint := FADLSConnector.GetAccessTokenEndpoint;
  FOAuth2_AzureDataLake.AuthorizationEndpoint := FADLSConnector.GetAuthorizationEndpoint;
  FOAuth2_AzureDataLake.ResponseType := TOAuth2ResponseType(0);
  FOAuth2_AzureDataLake.TokenType := TOAuth2TokenType(0);

  FRESTClient.Accept := 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
  FRESTClient.Authenticator := FOAuth2_AzureDataLake;

  FRESTRequest.Client := FRESTClient;
  FRESTRequest.Response := FRESTResponse;
end;

procedure TADLSConnectorPresenter.LocalRESTRequestAfterExecute(
  Sender: TCustomRESTRequest);
begin
  FADLSConnector.SetResponseData('');
  //lbl_status.Caption := 'URI: ' + Sender.GetFullRequestURL + ' Execution time: ' +
  //  IntToStr(Sender.ExecutionPerformance.TotalExecutionTime) + 'ms';
  if Assigned(FRESTResponse.JSONValue) then
  begin
    FADLSConnector.SetResponseData(TJson.Format(FRESTResponse.JSONValue));
  end
  else
  begin
    FADLSConnector.AddResponseData(FRESTResponse.Content);
  end;
end;

procedure TADLSConnectorPresenter.ResetRESTComponentsToDefaults;
begin
  FRESTClient.ResetToDefaults;
  FRESTRequest.ResetToDefaults;
  FRESTResponse.ResetToDefaults;
end;

end.
