unit ADLSFileManager.Interfaces;

interface

uses
  System.Classes, System.Generics.Collections;

type

  IADLSFileManagerView = interface
  ['{AA452B82-AD29-463F-B93F-D1D51F517AC6}']
    // Input
    function GetFMBaseURL: string;
    function GetFMDirectory: string;
    function GetFMFilePath: string;
    // Output
    procedure DisplayFMMessage(AValue: string);
    procedure SetFMDirectory(AValue: TList<string>);
    procedure SetFMResponseData(const AValue: string);
    procedure AddFMResponseData(const AValue: string);
  end;

  IADLSFileManagerPresenter = interface
  ['{389E2588-BD83-4F56-A66F-4103F205A787}']
    function GetListFolders: TStringList;
    procedure UploadFile;
    procedure ListFolders;
  end;

implementation

end.
