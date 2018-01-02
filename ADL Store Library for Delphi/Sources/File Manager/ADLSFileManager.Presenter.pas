unit ADLSFileManager.Presenter;

interface

uses
  System.Classes, System.Generics.Collections, System.JSON.Readers,
  System.JSON.Types, REST.Client, ADLSFileManager.Interfaces,
  ADLSConnector.Presenter;

type
  TADLSResponseReader = class
  private const
    PATH_SUFFIX = 'pathSuffix';
    PATH_TYPE_PROPERTY = 'type';
    PATH_TYPE_VALUE = 'Directory';
  public
    class function ListFoldersExtractor(AJsonTextReader: TJsonTextReader): TList<string>;
  end;


  TADLSFileManagerPresenter = class(TInterfacedObject)
  private const
    RESPONSE_DATA_SEPARATOR = '----------------------------';
    WEB_HDFS_RESOURCE_PATH = '/webhdfs/v1/';
    OP_LIST_STATUS = 'LISTSTATUS';
    OP_CREATE = 'CREATE';
  private var
    FRESTClient: TRESTClient;
    FRESTRequest: TRESTRequest;
    FRESTResponse: TRESTResponse;
    FADLSConnector: TADLSConnectorPresenter;
    FOperations: TDictionary<string, string>;
  private
    procedure ResetRESTComponentsToDefaults;
    procedure InitComponents;
    procedure LoadOperations;
  protected
    FADLSFileManager: IADLSFileManager;
  public
    constructor Create(AADLSConnector: TADLSConnectorPresenter; AADLSFileManager: IADLSFileManager);
    destructor Destroy; override;
    function GetListFolders: TStringList;
    procedure UploadFile;
    procedure ListFolders;
  end;


implementation

uses
  System.SysUtils, REST.Utils, REST.Types, REST.Json, REST.HttpClient,
  VCL.Dialogs;

{ TADLSFileManagerPresenter }

constructor TADLSFileManagerPresenter.Create(AADLSConnector: TADLSConnectorPresenter;
  AADLSFileManager: IADLSFileManager);
begin
  FADLSConnector := AADLSConnector;
  FADLSFileManager := AADLSFileManager;

  FRESTClient := TRESTClient.Create(FADLSConnector.GetBaseURL);
  FRESTRequest := TRESTRequest.Create(nil);
  FRESTResponse := TRESTResponse.Create(nil);

  LoadOperations;
end;

destructor TADLSFileManagerPresenter.Destroy;
begin
  FRESTResponse.Free;
  FRESTRequest.Free;
  FRESTClient.Free;
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

procedure TADLSFileManagerPresenter.ListFolders;
begin
  ResetRESTComponentsToDefaults;

  // Initialize connections among the REST components
  InitComponents;

  // Get BaseURL from the view
  FRESTClient.BaseURL := FADLSFileManager.GetFMBaseURL;

  FRESTRequest.Params.Clear;
  FRESTRequest.ClearBody;
  FRESTRequest.Method := TRestRequestMethod.rmGET;
  //FRESTRequest.Resource := '/webhdfs/v1/' + '?op=LISTSTATUS';
  FRESTRequest.Resource := WEB_HDFS_RESOURCE_PATH + FOperations.Items[OP_LIST_STATUS];

  // Set Content-Type to text/plain
  FRESTRequest.Params.AddHeader('Content-Type', 'text/plain');

  // Add token
  FRESTRequest.Params.AddItem('Authorization', 'Bearer ' + FADLSConnector.AccessToken,
    TRESTRequestParameterKind.pkHTTPHEADER,
    [TRESTRequestParameterOption.poDoNotEncode]);

  try
    FRESTRequest.Execute;
    FADLSFileManager.DisplayFMMessage('List folders retrieved successfully');
    FADLSFileManager.SetFMDirectory(TADLSResponseReader.ListFoldersExtractor(FRESTResponse.JSONReader));
    FADLSFileManager.AddFMResponseData(RESPONSE_DATA_SEPARATOR);
    FADLSFileManager.AddFMResponseData(FRESTResponse.Content);
  except on E: Exception do
    begin
      FADLSFileManager.DisplayFMMessage('List folders retrieved with errors: ' + E.Message);
      FADLSFileManager.SetFMDirectory(TList<string>.Create);
    end;
  end;

end;

procedure TADLSFileManagerPresenter.LoadOperations;
begin
  if Assigned(FOperations) then
    FOperations.Free;

  FOperations := TDictionary<string, string>.Create;
  FOperations.Add(OP_CREATE, '?op=CREATE');
  FOperations.Add(OP_LIST_STATUS, '?op=LISTSTATUS');
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

  //FRESTRequest.Resource := '/webhdfs/v1/.../' + URIEncode(ExtractFileName(LFilePath))+ '?op=CREATE';
  FRESTRequest.Resource := WEB_HDFS_RESOURCE_PATH +
                           FADLSFileManager.GetFMDirectory + '/' +
                           URIEncode(ExtractFileName(LFilePath)) +
                           FOperations.Items[OP_CREATE];

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

    try
      FRESTRequest.Execute;
      FADLSFileManager.DisplayFMMessage('Upload completed successfully');
    except
      on E: EHTTPProtocolException do
      begin
        FADLSFileManager.DisplayFMMessage('Upload completed with an HTTP protocol exception: ' + E.Message);
        FADLSFileManager.AddFMResponseData('Error: ' + RESPONSE_DATA_SEPARATOR);
        FADLSFileManager.AddFMResponseData(E.Message);
      end;

      on E: Exception do
      begin
        FADLSFileManager.AddFMResponseData('Error: ' + RESPONSE_DATA_SEPARATOR);
        FADLSFileManager.AddFMResponseData(E.Message);
      end;
    end;

  finally
    LUploadStream.Free;
  end;
end;

{ TADLSResponseReader }

class function TADLSResponseReader.ListFoldersExtractor(AJsonTextReader: TJsonTextReader): TList<string>;
var
  LValuePathSuffix: string;
begin
  if not Assigned(AJsonTextReader) then
    Result := nil
  else
  begin
    Result := TList<string>.Create;

    while AJsonTextReader.Read do
    begin
      case AJsonTextReader.TokenType of
        TJsonToken.PropertyName:
          begin
            if CompareText(AJsonTextReader.Value.ToString, PATH_SUFFIX) = 0 then
            begin
              AJsonTextReader.Read;
              case AJsonTextReader.TokenType of
                TJsonToken.String:
                  begin
                    LValuePathSuffix := AJsonTextReader.Value.ToString;
                    AJsonTextReader.Read;
                    case AJsonTextReader.TokenType of
                      TJsonToken.PropertyName:
                        begin
                          if CompareText(AJsonTextReader.Value.ToString, PATH_TYPE_PROPERTY) = 0 then
                          begin
                            AJsonTextReader.Read;
                            case AJsonTextReader.TokenType of
                              TJsonToken.String:
                                if CompareText(AJsonTextReader.Value.ToString, PATH_TYPE_VALUE) = 0 then
                                begin
                                  Result.Add(LValuePathSuffix);
                                  LValuePathSuffix := '';
                                end;
                            end;
                          end;
                        end;
                    end;
                  end;
              end;
            end
          end;
      end;
    end;
  end;
end;

end.
