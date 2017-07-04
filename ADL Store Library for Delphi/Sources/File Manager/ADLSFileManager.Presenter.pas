unit ADLSFileManager.Presenter;

interface

uses
  System.Classes, REST.Client, ADLSFileManager.Interfaces, ADLSConnector.Presenter;

type

  TADLSFileManagerPresenter = class(TInterfacedObject)
  private
    FRESTClient: TRESTClient;
    FRESTRequest: TRESTRequest;
    FRESTResponse: TRESTResponse;
    FADLSConnector: TADLSConnectorPresenter;
    procedure ResetRESTComponentsToDefaults;
    procedure InitComponents;
  protected
    FADLSFileManager: IADLSFileManager;
  public
    constructor Create(AADLSConnector: TADLSConnectorPresenter; AADLSFileManager: IADLSFileManager);
    destructor Destroy; reintroduce;
    function GetListFolders: TStringList;
    procedure UploadFile;
  end;

implementation

uses
  System.SysUtils, REST.Utils, REST.Types, REST.Json, VCL.Dialogs;

{ TADLSFileManagerPresenter }

constructor TADLSFileManagerPresenter.Create(AADLSConnector: TADLSConnectorPresenter;
  AADLSFileManager: IADLSFileManager);
begin
  FADLSConnector := AADLSConnector;
  FADLSFileManager := AADLSFileManager;

  FRESTClient := TRESTClient.Create(FADLSConnector.GetBaseURL);
  FRESTRequest := TRESTRequest.Create(nil);
  FRESTResponse := TRESTResponse.Create(nil);
end;

destructor TADLSFileManagerPresenter.Destroy;
begin
  FreeAndNil(FRESTClient);
  FreeAndNil(FRESTRequest);
  FreeAndNil(FRESTResponse);
  inherited;
end;

function TADLSFileManagerPresenter.GetListFolders: TStringList;
begin
  // ToDo: work in progress..
  Result := TStringList.Create;
end;

procedure TADLSFileManagerPresenter.InitComponents;
begin
  // Authenticator must be set to nil
  //FRESTClient.Authenticator := FADLSConnector.Authenticator;
  FRESTClient.Authenticator := nil;

  // ToDo:
  //FRESTClient.Accept := 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';

  FRESTRequest.Client := FRESTClient;
  FRESTRequest.Response := FRESTResponse;
end;

procedure TADLSFileManagerPresenter.ResetRESTComponentsToDefaults;
begin
  FRESTClient.ResetToDefaults;
  FRESTRequest.ResetToDefaults;
  FRESTResponse.ResetToDefaults;
end;

procedure TADLSFileManagerPresenter.UploadFile;
var
  LFilePath: string;

  LUploadStream: TFileStream;
  LSize: Integer;
  LBuffer: TArray<byte>;
  LEncoding: TEncoding;
  LFileContent: string;
begin
  ResetRESTComponentsToDefaults;

  // Initialize connections among the REST components
  InitComponents;

  // Get file path from the view
  LFilePath := FADLSFileManager.GetFMFilePath;

  // Get BaseURL from the view
  FRESTClient.BaseURL := FADLSFileManager.GetFMBaseURL;

  FRESTRequest.Params.Clear;
  FRESTRequest.ClearBody;
  FRESTRequest.Method := TRestRequestMethod.rmPUT;
  FRESTRequest.Resource := '/webhdfs/v1/data_new/' + URIEncode(ExtractFileName(LFilePath))+ '?op=CREATE';

  LUploadStream := TFileStream.Create(LFilePath, fmOpenRead);

  try
    LUploadStream.Position := 0;

    // Set Content-Type to text/plain
    FRESTRequest.Params.AddHeader('Content-Type', 'text/plain');

    // Add token
    //FRESTRequest.AddAuthParameter('Authorization', 'Bearer ' + FADLSConnector.AccessToken + '',
    //  TRESTRequestParameterKind.pkHTTPHEADER,
    //  [TRESTRequestParameterOption.poDoNotEncode]);
    FRESTRequest.Params.AddItem('Authorization', 'Bearer ' + FADLSConnector.AccessToken,
      TRESTRequestParameterKind.pkHTTPHEADER,
      [TRESTRequestParameterOption.poDoNotEncode]);

    LSize := (LUploadStream.Size - LUploadStream.Position);
    SetLength(LBuffer, LSize);
    LUploadStream.ReadBuffer(Pointer(LBuffer)^, LSize);
    LEncoding := nil;
    LSize := TEncoding.GetBufferEncoding(LBuffer, LEncoding);
    LFileContent := LEncoding.GetString(LBuffer, LSize, Length(LBuffer) - LSize);

    FRESTRequest.AddBody(LFileContent, TRESTContentType.ctTEXT_PLAIN);
    FRESTRequest.Execute;

  finally
    LUploadStream.Free;
  end;

  //FRESTResponse.Content;
  //FRESTResponse.ErrorMessage;
end;

end.
