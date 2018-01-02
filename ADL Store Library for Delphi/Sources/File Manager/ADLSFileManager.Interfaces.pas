unit ADLSFileManager.Interfaces;

interface

uses
  System.Classes;

type

  IADLSFileManager = interface
  ['{AA452B82-AD29-463F-B93F-D1D51F517AC6}']
    // Input
    function GetFMBaseURL: string;
    function GetFMDirectory: string;
    function GetFMFilePath: string;

  end;

implementation

end.
