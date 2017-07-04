program ADLStoreLibrary4D;

uses
  Vcl.Forms,
  ADLSConnector.Interfaces in 'Connector\ADLSConnector.Interfaces.pas',
  ADLSConnector.Presenter in 'Connector\ADLSConnector.Presenter.pas',
  ADLSFileManager.Interfaces in 'File Manager\ADLSFileManager.Interfaces.pas',
  ADLSFileManager.Presenter in 'File Manager\ADLSFileManager.Presenter.pas',
  ADLSMain in 'View\ADLSMain.pas' {frmADLSMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmADLSMain, frmADLSMain);
  Application.Run;
end.
