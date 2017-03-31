unit MultiCastEvent.TestCase;

interface

uses System.SysUtils, System.Classes, TestFramework;

type{$M+}
  TEvent0 = procedure of object;
  TEvent3 = procedure (Sender: TObject; p2, p3: Integer) of object;
  TEvent5 = procedure (Sender: TObject; p2, p3, p4, p5: Integer) of object;
  TEvent8 = procedure (Sender: TObject; p2, p3, p4, p5, p6, p7, p8: Integer) of object;

  TTestEvent = class
  strict private
    FID: string;
    FResponse: string;
  public
    constructor Create(aID: string);
    procedure NotifyEvent(Sender: TObject);
    procedure Event0;
    procedure Event3(Sender: TObject; p2, p3: Integer);
    procedure Event5(Sender: TObject; p2, p3, p4, p5: Integer);
    procedure Event8(Sender: TObject; p2, p3, p4, p5, p6, p7, p8: Integer);
    property Response: string read FResponse;
  end;

  TTestObject = class
  strict private
    FNotifyEvent: TNotifyEvent;
    FEvent0: TEvent0;
    FEvent3: TEvent3;
    FEvent5: TEvent5;
    FEvent8: TEvent8;
  public
    procedure DoEvent0;
    procedure DoEvent3;
    procedure DoEvent5;
    procedure DoEvent8;
    procedure DoNotifyEvent;
    property Event0: TEvent0 read FEvent0 write FEvent0;
    property Event3: TEvent3 read FEvent3 write FEvent3;
    property Event5: TEvent5 read FEvent5 write FEvent5;
    property Event8: TEvent8 read FEvent8 write FEvent8;
    property NotifyEvent: TNotifyEvent read FNotifyEvent write FNotifyEvent;
  end;

  TMultiCastEvent_TestCase = class(TTestCase)
  private
    FTestEvent: TTestEvent;
    FTestObject: TTestObject;
    function PrefixID(aIndex: Integer = -1): string;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  public
    class constructor Create;
  published
    procedure Test_Event0;
    procedure Test_Event3;
    procedure Test_Event5;
    procedure Test_Event8;
    procedure Test_TNotifyEvent;
  end;

implementation

uses MultiCastEvent;

constructor TTestEvent.Create(aID: string);
begin
  inherited Create;
  FID := aID;
end;

procedure TTestEvent.Event0;
begin
  FResponse := string.Join('.', [Self.ClassName, FID]);
end;

procedure TTestEvent.Event3(Sender: TObject; p2, p3: Integer);
begin
  FResponse := string.Join('.', [Self.ClassName, Sender.ClassName, FID, p2.ToString, p3.ToString]);
end;

procedure TTestEvent.Event5(Sender: TObject; p2, p3, p4, p5: Integer);
begin
  FResponse := string.Join('.', [Self.ClassName, Sender.ClassName, FID, p2.ToString, p3.ToString, p4.ToString, p5.ToString]);
end;

procedure TTestEvent.Event8(Sender: TObject; p2, p3, p4, p5, p6, p7,
  p8: Integer);
begin
  FResponse := string.Join('.', [Self.ClassName, Sender.ClassName, FID, p2.ToString, p3.ToString, p4.ToString, p5.ToString, p6.ToString, p7.ToString, p8.ToString]);
end;

procedure TTestEvent.NotifyEvent(Sender: TObject);
begin
  FResponse := string.Join('.', [Self.ClassName, Sender.ClassName, FID]);
end;

procedure TTestObject.DoEvent0;
begin
  FEvent0;
end;

procedure TTestObject.DoEvent3;
begin
  FEvent3(Self, 222, 333);
end;

procedure TTestObject.DoEvent5;
begin
  FEvent5(Self, 22222, 33333, 44444, 55555);
end;

procedure TTestObject.DoEvent8;
begin
  FEvent8(Self, 22222222, 33333333, 44444444, 55555555, 66666666, 77777777, 88888888);
end;

procedure TTestObject.DoNotifyEvent;
begin
  FNotifyEvent(Self);
end;

class constructor TMultiCastEvent_TestCase.Create;
begin
  RegisterTest(Suite);
end;

function TMultiCastEvent_TestCase.PrefixID(aIndex: Integer = -1): string;
var sID: string;
begin
  sID := Name;
  if aIndex >= 0 then sID := sID + aIndex.ToString;
  Result := string.Join('.', [TTestEvent.ClassName, TTestObject.ClassName, sID]);
end;

procedure TMultiCastEvent_TestCase.SetUp;
begin
  inherited;
  FTestEvent := TTestEvent.Create(Name);
  FTestObject := TTestObject.Create;
end;

procedure TMultiCastEvent_TestCase.TearDown;
begin
  inherited;
  FTestEvent.Free;
  FTestObject.Free;
end;

procedure TMultiCastEvent_TestCase.Test_Event0;
var o: TMultiCastEvent<TEvent0>;
begin
  o := TMultiCastEvent<TEvent0>.Create([nil, FTestEvent.Event0]);
  FTestObject.Event0 := o.Invoke;

  FTestObject.DoEvent0;
  CheckEquals(
    string.Join('.', [TTestEvent.ClassName, Name])
    , FTestEvent.Response
  );

  o.Free;
end;

procedure TMultiCastEvent_TestCase.Test_Event3;
var o: TMultiCastEvent<TEvent3>;
begin
  o := TMultiCastEvent<TEvent3>.Create([nil, FTestEvent.Event3]);
  FTestObject.Event3 := o.Invoke;

  FTestObject.DoEvent3;
  CheckEquals(
    string.Join('.', [PrefixID, 222.ToString, 333.ToString])
    , FTestEvent.Response
  );

  o.Free;
end;

procedure TMultiCastEvent_TestCase.Test_Event5;
var o: TMultiCastEvent<TEvent5>;
begin
  o := TMultiCastEvent<TEvent5>.Create([nil, FTestEvent.Event5]);
  FTestObject.Event5 := o.Invoke;

  FTestObject.DoEvent5;
  CheckEquals(
    string.Join('.', [PrefixID, 22222.ToString, 33333.ToString, 44444.ToString, 55555.ToString])
    , FTestEvent.Response
  );

  o.Free;
end;

procedure TMultiCastEvent_TestCase.Test_Event8;
var o: TMultiCastEvent<TEvent8>;
begin
  o := TMultiCastEvent<TEvent8>.Create([nil, FTestEvent.Event8]);
  FTestObject.Event8 := o.Invoke;

  FTestObject.DoEvent8;
  CheckEquals(
    string.Join('.', [PrefixID, 22222222.ToString, 33333333.ToString, 44444444.ToString, 55555555.ToString, 66666666.ToString, 77777777.ToString, 88888888.ToString])
    , FTestEvent.Response
  );

  o.Free;
end;

procedure TMultiCastEvent_TestCase.Test_TNotifyEvent;
var o: TMultiCastEvent<TNotifyEvent>;
    A: TArray<TTestEvent>;
    E: TTestEvent;
    i: Integer;
begin
  A := [];
  for i := 0 to 4 do A := A + [TTestEvent.Create(Name + i.ToString)];

  o := TMultiCastEvent<TNotifyEvent>.Create([nil, nil, FTestEvent.NotifyEvent]);
  for E in A do o.Add(E.NotifyEvent);
  o.Add(nil);
  o.Add(nil);

  FTestObject.NotifyEvent := o.Invoke;
  FTestObject.DoNotifyEvent;

  CheckEquals(PrefixID, FTestEvent.Response);
  for i := Low(A) to High(A) do begin
    CheckEquals(PrefixID(i), A[i].Response);
    A[i].Free;
  end;

  o.Free;
end;

end.
