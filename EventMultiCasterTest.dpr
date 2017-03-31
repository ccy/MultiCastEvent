program EventMultiCasterTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  FastMM4,
  System.SysUtils,
  TextTestRunner,
  MultiCastEvent in 'MultiCastEvent.pas',
  MultiCastEvent.TestCase in 'MultiCastEvent.TestCase.pas';

begin
  // Dummy code to trigger class TMultiCastEvent_TestCase initialization
  TMultiCastEvent_TestCase.ClassName;

  TextTestRunner.RunRegisteredTests(rxbPause).DisposeOf;
end.
