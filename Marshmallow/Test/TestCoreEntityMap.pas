unit TestCoreEntityMap;

interface

uses
  TestFramework, Spring.TestUtils, Spring.Collections, Rtti,
  Spring.Persistence.Core.EntityMap, TestEntities;

type
  TMockEntityMap = class(TEntityMap);

  {$HINTS OFF}
  TEntityMapTest = class(TTestCase)
  private
    FEntityMap: TMockEntityMap;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestIsMapped;
    procedure TestAdd;
    procedure TestAddOrReplace;
    {$IFDEF PERFORMANCE_TESTS}
    procedure TestAddOrReplace_Clone_Speed;
    {$ENDIF}
    procedure TestRemove;
    procedure TestClear;
    procedure TestHash;
    procedure When_Changed_One_Property_GetChangedMembers_Returns_It;
    procedure When_Replaced_Entity_No_MemoryLeaks;
  end;

implementation

uses
  SysUtils
  ,Spring.Persistence.Mapping.Attributes
  ,Spring.Persistence.Mapping.RttiExplorer
  ,Spring.Persistence.Core.EntityCache
  ,Spring.Persistence.Core.EntityWrapper
  ,Spring.Persistence.Core.Interfaces
  ,Diagnostics
  ,Generics.Collections
  ;

type
  TTest1 = class
  public
    [Column('TESTID', [cpRequired, cpPrimaryKey, cpNotNull], 0, 0, 0, 'Primary Key')]
    [AutoGenerated]
    FId: Integer;
  end;

  TTest2 = class
  public
    [Column('TESTID', [cpRequired, cpPrimaryKey, cpNotNull], 0, 0, 0, 'Primary Key')]
    [AutoGenerated]
    FId: Integer;
  end;

function CreateCustomer: TCustomer;
begin
  Result := TCustomer.Create;
  Result.Name := 'Test Case';
  Result.Age := 15;
  Result.Height := 1.11;
  Result.LastEdited := EncodeDate(2011,1,1);
  Result.EMail := 'test@gmail.com';
end;

function CreateCompany: TCompany;
begin
  Result := TCompany.Create;
  Result.Name := 'Test Company';
end;

procedure TEntityMapTest.SetUp;
begin
  FEntityMap := TMockEntityMap.Create;
end;

procedure TEntityMapTest.TearDown;
begin
  FEntityMap.Free;
end;

procedure TEntityMapTest.TestIsMapped;
var
  ReturnValue: Boolean;
  AObject, LClone: TCustomer;
  LCompany, LClonedCompany: TCompany;
  entityWrapper: IEntityWrapper;
begin
  AObject := CreateCustomer;
  LCompany := CreateCompany;
  LClone := CreateCustomer;
  LClonedCompany := CreateCompany;
  try
    ReturnValue := FEntityMap.IsMapped(AObject);
    CheckFalse(ReturnValue);
    entityWrapper := TEntityWrapper.Create(LClone);
    FEntityMap.AddOrReplace(entityWrapper);
    ReturnValue := FEntityMap.IsMapped(AObject);
    CheckTrue(ReturnValue);

    ReturnValue := FEntityMap.IsMapped(LCompany);
    CheckFalse(ReturnValue);
    entityWrapper := TEntityWrapper.Create(LClonedCompany);
    FEntityMap.AddOrReplace(entityWrapper);

    ReturnValue := FEntityMap.IsMapped(LCompany);
    CheckTrue(ReturnValue);
  finally
    AObject.Free;
    LCompany.Free;
    LClone.Free;
    LClonedCompany.Free;
  end;
end;

procedure TEntityMapTest.TestAdd;
var
  LCustomer: TCustomer;
  entityWrapper: IEntityWrapper;
begin
  LCustomer := CreateCustomer;
  try
    CheckFalse(FEntityMap.IsMapped(LCustomer));
    entityWrapper := TEntityWrapper.Create(LCustomer);
    FEntityMap.AddOrReplace(entityWrapper);
    CheckTrue(FEntityMap.IsMapped(LCustomer));
  finally
    LCustomer.Free;
  end;
end;

procedure TEntityMapTest.TestAddOrReplace;
var
  LCustomer: TCustomer;
  entityWrapper: IEntityWrapper;
begin
  LCustomer := CreateCustomer;
  try
    CheckFalse(FEntityMap.IsMapped(LCustomer));
    entityWrapper := TEntityWrapper.Create(LCustomer);
    FEntityMap.AddOrReplace(entityWrapper);
    CheckTrue(FEntityMap.IsMapped(LCustomer));
    FEntityMap.AddOrReplace(entityWrapper);
    CheckTrue(FEntityMap.IsMapped(LCustomer));
  finally
    LCustomer.Free;
  end;
end;

{$IFDEF PERFORMANCE_TESTS}
procedure TestTEntityMap.TestAddOrReplace_Clone_Speed;
var
  iCount: Integer;
  sw: TStopwatch;
  i: Integer;
  LCustomers: IList<TCustomer>;
  LSpringDict: IDictionary<string,TValue>;
  LObjectDict: IDictionary<string,TObject>;
  LNativeDict: TDictionary<string,TValue>;
  LValue: TValue;
  entityWrapper: IEntityWrapper;
begin
  iCount := 50000;
  LCustomers := TCollections.CreateObjectList<TCustomer>(True);
  for i := 1 to iCount do
  begin
    LCustomers.Add(CreateCustomer);
  end;

  sw := TStopwatch.StartNew;
  for i := 0 to iCount - 1 do
  begin
    entityWrapper := TEntityWrapper.Create(LCustomers[i]);
    FEntityMap.AddOrReplace(entityWrapper);
  end;
  sw.Stop;

  Status(Format('%D items in %D ms', [iCount, sw.ElapsedMilliseconds]));

  //previous implementation
  LObjectDict := TCollections.CreateDictionary<string, TObject>([doOwnsValues]);
  sw := TStopwatch.StartNew;
  for i := 0 to iCount - 1 do
  begin
    LObjectDict.AddOrSetValue('some random key', TRttiExplorer.Clone(LCustomers[i]));
  end;
  sw.Stop;

  Status(Format('Previous implementation: %D items in %D ms', [iCount, sw.ElapsedMilliseconds]));

  iCount := iCount * 10;
  sw := TStopwatch.StartNew;
  LSpringDict := TCollections.CreateDictionary<string, TValue>;
  for i := 0 to iCount - 1 do
  begin
    LValue := i;
    LSpringDict.AddOrSetValue('some random key', LValue);
  end;
  sw.Stop;
  Status(Format('Spring dictionary %D items in %D ms', [iCount, sw.ElapsedMilliseconds]));
  sw := TStopwatch.StartNew;
  LNativeDict := TDictionary<string,TValue>.Create;
  for i := 0 to iCount - 1 do
  begin
    LValue := i;
    LNativeDict.AddOrSetValue('some random key', LValue);
  end;
  sw.Stop;
  Status(Format('Native dictionary %D items in %D ms', [iCount, sw.ElapsedMilliseconds]));
  LNativeDict.Free;
end;
{$ENDIF}

procedure TEntityMapTest.TestHash;
var
  LTest1: TTest1;
  LTest2: TTest2;
  entityWrapper: IEntityWrapper;
begin
  LTest1 := TTest1.Create;
  LTest2 := TTest2.Create;
  TRttiExplorer.RttiCache.RebuildCache;
  try
    LTest2.FId := 220;

    CheckFalse(FEntityMap.IsMapped(LTest1));
    CheckFalse(FEntityMap.IsMapped(LTest2));
    //220 offset
    entityWrapper := TEntityWrapper.Create(LTest1);
    FEntityMap.AddOrReplace(entityWrapper);
    CheckFalse(FEntityMap.IsMapped(LTest2));

  finally
    LTest1.Free;
    LTest2.Free;
  end;
end;

procedure TEntityMapTest.TestRemove;
var
  LCustomer: TCustomer;
  entityWrapper: IEntityWrapper;
begin
  LCustomer := CreateCustomer;
  try
    entityWrapper := TEntityWrapper.Create(LCustomer);
    FEntityMap.AddOrReplace(entityWrapper);
    CheckTrue(FEntityMap.IsMapped(LCustomer));
    FEntityMap.Remove(LCustomer);
    CheckFalse(FEntityMap.IsMapped(LCustomer));
  finally
    LCustomer.Free;
  end;
end;

procedure TEntityMapTest.When_Changed_One_Property_GetChangedMembers_Returns_It;
var
  LCustomer: TCustomer;
  LChangedColumns: IList<ColumnAttribute>;
  entityWrapper: IEntityWrapper;
begin
  LCustomer := CreateCustomer;
  entityWrapper := TEntityWrapper.Create(LCustomer);
  FEntityMap.AddOrReplace(entityWrapper);
  LCustomer.Name := 'Changed';
  LChangedColumns := FEntityMap.GetChangedMembers(LCustomer, TEntityCache.Get(LCustomer.ClassType));
  CheckEquals(1, LChangedColumns.Count);
  CheckEquals('Name', LChangedColumns.First.MemberName);
  LCustomer.Free;
end;

procedure TEntityMapTest.When_Replaced_Entity_No_MemoryLeaks;
var
  company: TCompany;
  entityWrapper: IEntityWrapper;
begin
  company := TCompany.Create;
  try
    entityWrapper := TEntityWrapper.Create(company);
    FEntityMap.AddOrReplace(entityWrapper);
    company.Logo.LoadFromFile(PictureFilename);
    FEntityMap.AddOrReplace(entityWrapper);
  finally
    company.Free;
  end;
  Pass;
  SetFailsOnMemoryLeak(True);
end;

procedure TEntityMapTest.TestClear;
var
  LCustomer: TCustomer;
  entityWrapper: IEntityWrapper;
begin
  LCustomer := CreateCustomer;
  try
    entityWrapper := TEntityWrapper.Create(LCustomer);
    FEntityMap.AddOrReplace(entityWrapper);
    CheckTrue(FEntityMap.IsMapped(LCustomer));
    FEntityMap.Clear;
    CheckFalse(FEntityMap.IsMapped(LCustomer));
  finally
    LCustomer.Free;
  end;
end;

{$HINTS ON}

initialization
  // Register any test cases with the test runner
  RegisterTest(TEntityMapTest.Suite);
end.

