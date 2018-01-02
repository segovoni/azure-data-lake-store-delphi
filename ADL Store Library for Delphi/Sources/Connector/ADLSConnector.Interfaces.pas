unit ADLSConnector.Interfaces;

interface

type
  IADLSView = interface
  ['{9BB081F9-887B-44B5-A352-49BE0261FB0A}']
    // Input
    function GetBaseURL: string;
    function GetClientID: string;
    function GetClientSecret: string;
    function GetAccessTokenEndpoint: string;
    function GetAuthorizationEndpoint: string;
    // Output
    procedure SetAccessToken(const AValue: string);
    procedure SetResponseData(const AValue: string);
    procedure AddResponseData(const AValue: string);
  end;

implementation

end.
