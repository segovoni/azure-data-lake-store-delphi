unit ADLSFileManager.Interfaces;

interface

uses
  System.Classes;

type

  IADLSFileManager = interface ['{AA452B82-AD29-463F-B93F-D1D51F517AC6}']
    // Input
    function GetFMFilePath: string;
    function GetFMBaseURL: string;
  end;

implementation

end.
