unit TestAnsiSQLGenerator;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, Spring.Persistence.SQL.AbstractSQLGenerator
  , Spring.Persistence.SQL.Generator.Ansi, Spring.Persistence.SQL.Commands
  , Spring.Persistence.SQL.Types, Spring.Collections;

type
  // Test methods for class TAnsiSQLGenerator

  TestTAnsiSQLGenerator = class(TTestCase)
  private
    FAnsiSQLGenerator: TAnsiSQLGenerator;
  protected
    procedure CheckEqualsSQL(const AExpected, ASQL: string);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestGenerateSelect;
    procedure TestGenerateInsert;
    procedure TestGenerateUpdate;
    procedure TestGenerateDelete;
    procedure TestGenerateCreateTable;
    procedure TestGenerateCreateFK;
    procedure TestGenerateCreateSequence;
    procedure TestGenerateGetNextSequenceValue;
    procedure TestGenerateGetLastInsertId;
    procedure TestGeneratePagedQuery;
    procedure TestGenerateGetQueryCount;
  end;

implementation

uses
  SysUtils,
  StrUtils
  ,uModels
  ,Spring.Persistence.Mapping.RttiExplorer
  ,Spring.Persistence.Mapping.Attributes
  ,Generics.Collections
  ;

function CreateTestTable(): TSQLTable;
begin
  Result := TSQLTable.Create;
  Result.Schema := 'TEST';
  Result.Name := 'CUSTOMERS';
  Result.Description := 'Customers table';
//  Result.Alias := 'C';
end;

function CreateTestJoinTable(): TSQLTable;
begin
  Result := TSQLTable.Create;
  Result.Schema := 'TEST';
  Result.Name := 'PRODUCTS';
  Result.Description := 'Products table';
 // Result.Alias := 'P';
end;

function CreateTestCOUNTRYTable(): TSQLTable;
begin
  Result := TSQLTable.Create;
  Result.Schema := 'TEST';
  Result.Name := 'COUNTRIES';
  Result.Description := 'Countries table';
 // Result.Alias := 'P';
end;

procedure TestTAnsiSQLGenerator.CheckEqualsSQL(const AExpected, ASQL: string);
var
  LExpected, LSQL: string;
begin
  LExpected := ReplaceStr(AExpected, ' ', '');
  LExpected := ReplaceStr(LExpected, #13#10, '');

  LSQL := ReplaceStr(ASQL, ' ', '');
  LSQL := ReplaceStr(LSQL, #13#10, '');
  CheckEqualsString(LExpected, LSQL, 'SQL not equals');
end;

procedure TestTAnsiSQLGenerator.SetUp;
begin
  FAnsiSQLGenerator := TAnsiSQLGenerator.Create();
end;

procedure TestTAnsiSQLGenerator.TearDown;
begin
  FAnsiSQLGenerator.Free;
  FAnsiSQLGenerator := nil;
end;


const
  SQL_SELECT_TEST_SIMPLE = 'SELECT A."NAME",A."AGE",A."HEIGHT"'+ #13#10 +
    ' FROM TEST.CUSTOMERS A;';

  SQL_SELECT_TEST_JOIN = 'SELECT A."NAME",A."AGE",A."HEIGHT"'+ #13#10 +
    ' FROM TEST.CUSTOMERS A' + #13#10 +
    '  INNER JOIN TEST.PRODUCTS B ON B."ID"=A."PRODID"'+
    ';';

  SQL_SELECT_TEST_JOIN_2 = 'SELECT A."NAME",A."AGE",A."HEIGHT",C."COUNTRYNAME"'+ #13#10 +
    ' FROM TEST.CUSTOMERS A' + #13#10 +
    '  INNER JOIN TEST.PRODUCTS B ON B."ID"=A."PRODID"'+#13#10+
    '  LEFT OUTER JOIN TEST.COUNTRIES C ON C."ID"=A."COUNTRYID"'+
    ';';

  SQL_SELECT_TEST_JOIN_2_ORDER = 'SELECT A."NAME",A."AGE",A."HEIGHT",C."COUNTRYNAME"'+ #13#10 +
    ' FROM TEST.CUSTOMERS A' + #13#10 +
    '  INNER JOIN TEST.PRODUCTS B ON B."ID"=A."PRODID"'+#13#10+
    '  LEFT OUTER JOIN TEST.COUNTRIES C ON C."ID"=A."COUNTRYID"'+#13#10+
    '  ORDER BY A."AGE" DESC'+
    ';';

  SQL_SELECT_TEST_JOIN_2_ORDER_MULTIPLE = 'SELECT A."NAME",A."AGE",A."HEIGHT",C."COUNTRYNAME"'+ #13#10 +
    ' FROM TEST.CUSTOMERS A' + #13#10 +
    '  INNER JOIN TEST.PRODUCTS B ON B."ID"=A."PRODID"'+#13#10+
    '  LEFT OUTER JOIN TEST.COUNTRIES C ON C."ID"=A."COUNTRYID"'+#13#10+
    '  ORDER BY A."AGE" DESC,C."COUNTRYNAME" ASC'+
    ';';

  SQL_SELECT_TEST_JOIN_2_ORDER_GROUP = 'SELECT A."NAME",A."AGE",A."HEIGHT",C."COUNTRYNAME"'+ #13#10 +
    ' FROM TEST.CUSTOMERS A' + #13#10 +
    '  INNER JOIN TEST.PRODUCTS B ON B."ID"=A."PRODID"'+#13#10+
    '  LEFT OUTER JOIN TEST.COUNTRIES C ON C."ID"=A."COUNTRYID"'+#13#10+
    '  GROUP BY A."HEIGHT",A."NAME",A."AGE",C."COUNTRYNAME"'+#13#10+
    '  ORDER BY A."AGE" DESC,C."COUNTRYNAME" ASC'+
    ';';

  SQL_SELECT_TEST_JOIN_2_ORDER_GROUP_WHERE = 'SELECT A."NAME",A."AGE",A."HEIGHT",C."COUNTRYNAME"'+ #13#10 +
    ' FROM TEST.CUSTOMERS A' + #13#10 +
    '  INNER JOIN TEST.PRODUCTS B ON B."ID"=A."PRODID"'+#13#10+
    '  LEFT OUTER JOIN TEST.COUNTRIES C ON C."ID"=A."COUNTRYID"'+#13#10+
    '  WHERE A."NAME" = :NAME'+#13#10+
    '  GROUP BY A."HEIGHT",A."NAME",A."AGE",C."COUNTRYNAME"'+#13#10+
    '  ORDER BY A."AGE" DESC,C."COUNTRYNAME" ASC'+
    ';';

procedure TestTAnsiSQLGenerator.TestGenerateSelect;
var
  sSql: string;
  LCommand: TSelectCommand;
  LTable, LJoinTable, LCountriesTable: TSQLTable;
  LJoin: TSQLJoin;
begin
  LTable := CreateTestTable;
  LTable.Alias := 'A';
  LJoinTable := CreateTestJoinTable();
  LJoinTable.Alias := 'B';
  LCountriesTable := CreateTestCOUNTRYTable;
  LCountriesTable.Alias := 'C';
  LCommand := TSelectCommand.Create(LTable);
  try
    LCommand.SelectFields.Add(TSQLSelectField.Create('NAME', LTable));
    LCommand.SelectFields.Add(TSQLSelectField.Create('AGE', LTable));
    LCommand.SelectFields.Add(TSQLSelectField.Create('HEIGHT', LTable));

    sSql := FAnsiSQLGenerator.GenerateSelect(LCommand);
    CheckEqualsString(SQL_SELECT_TEST_SIMPLE, sSql);

    LJoin := TSQLJoin.Create(jtInner);
    LJoin.Segments.Add
    (
      TSQLJoinSegment.Create
      (
        TSQLField.Create('ID', LJoinTable)
        ,TSQLField.Create('PRODID', LTable)
      )
    );
    LCommand.Joins.Add(LJoin);

    sSql := FAnsiSQLGenerator.GenerateSelect(LCommand);
    CheckEqualsSQL(SQL_SELECT_TEST_JOIN, sSql);

    LCommand.SelectFields.Add(TSQLSelectField.Create('COUNTRYNAME', LCountriesTable));
    LJoin := TSQLJoin.Create(jtLeft);
    LJoin.Segments.Add
    (
      TSQLJoinSegment.Create
      (
        TSQLField.Create('ID', LCountriesTable)
        ,TSQLField.Create('COUNTRYID', LTable)
      )
    );
    LCommand.Joins.Add(LJoin);

    sSql := FAnsiSQLGenerator.GenerateSelect(LCommand);
    CheckEqualsSQL(SQL_SELECT_TEST_JOIN_2, sSql);

    LCommand.OrderByFields.Add(TSQLOrderField.Create('AGE', LTable));
    LCommand.OrderByFields[0].OrderType := otDescending;

    sSql := FAnsiSQLGenerator.GenerateSelect(LCommand);
    CheckEqualsString(SQL_SELECT_TEST_JOIN_2_ORDER, sSql);

    LCommand.OrderByFields.Add(TSQLOrderField.Create('COUNTRYNAME', LCountriesTable));
    sSql := FAnsiSQLGenerator.GenerateSelect(LCommand);
    CheckEqualsString(SQL_SELECT_TEST_JOIN_2_ORDER_MULTIPLE, sSql);

    LCommand.GroupByFields.Add(TSQLGroupByField.Create('HEIGHT', LTable));
    LCommand.GroupByFields.Add(TSQLGroupByField.Create('NAME', LTable));
    LCommand.GroupByFields.Add(TSQLGroupByField.Create('AGE', LTable));
    LCommand.GroupByFields.Add(TSQLGroupByField.Create('COUNTRYNAME', LCountriesTable));

    sSql := FAnsiSQLGenerator.GenerateSelect(LCommand);
    CheckEqualsString(SQL_SELECT_TEST_JOIN_2_ORDER_GROUP, sSql);

    LCommand.WhereFields.Add(TSQLWhereField.Create('NAME', LTable));

    sSql := FAnsiSQLGenerator.GenerateSelect(LCommand);
    CheckEqualsSQL(SQL_SELECT_TEST_JOIN_2_ORDER_GROUP_WHERE, sSql);

  finally
    LTable.Free;
    LJoinTable.Free;
    LCountriesTable.Free;
    LCommand.Free;
  end;
end;

const
  SQL_INSERT_TEST = 'INSERT INTO TEST.CUSTOMERS ('+ #13#10 +
    '  "NAME","AGE","HEIGHT")'+ #13#10 +
    '  VALUES ('+ #13#10 +
    ':NAME1,:AGE1,:HEIGHT1);';

  SQL_INSERT_TEST_WITHOUT_SCHEMA = 'INSERT INTO CUSTOMERS ('+ #13#10 +
    '  "NAME","AGE","HEIGHT")'+ #13#10 +
    '  VALUES ('+ #13#10 +
    ':NAME2,:AGE2,:HEIGHT2);';

procedure TestTAnsiSQLGenerator.TestGenerateInsert;
var
  ReturnValue: string;
  LCommand: TInsertCommand;
  LTable: TSQLTable;
begin
  LTable := CreateTestTable;
  LCommand := TInsertCommand.Create(LTable);
  try
    LCommand.InsertFields.Add(TSQLField.Create('NAME', LTable));
    LCommand.InsertFields.Add(TSQLField.Create('AGE', LTable));
    LCommand.InsertFields.Add(TSQLField.Create('HEIGHT', LTable));

    ReturnValue := FAnsiSQLGenerator.GenerateInsert(LCommand);
    CheckEqualsString(SQL_INSERT_TEST, ReturnValue);

    LTable.Schema := '';
    ReturnValue := FAnsiSQLGenerator.GenerateInsert(LCommand);
    CheckEqualsString(SQL_INSERT_TEST_WITHOUT_SCHEMA, ReturnValue);

  finally
    LCommand.Free;
    LTable.Free;
  end;
end;

const
  SQL_PAGED_TEST = 'SELECT * FROM TEST.CUSTOMERS WHERE CUSTID = 1;';
  SQL_PAGED = 'SELECT * FROM TEST.CUSTOMERS WHERE CUSTID = 1 LIMIT 1,10 ;';

procedure TestTAnsiSQLGenerator.TestGeneratePagedQuery;
var
  LSQL: string;
begin
  LSQL := FAnsiSQLGenerator.GeneratePagedQuery(SQL_PAGED_TEST, 10, 1);
  CheckEqualsString(SQL_PAGED, LSQL);
end;

const
  SQL_UPDATE_TEST = 'UPDATE TEST.CUSTOMERS SET ' + #13#10
  + '"NAME"=:NAME1,"AGE"=:AGE1,"HEIGHT"=:HEIGHT1' + #13#10 + ' WHERE "ID"=:ID1;';

procedure TestTAnsiSQLGenerator.TestGenerateUpdate;
var
  ReturnValue: string;
  LCommand: TUpdateCommand;
  LTable: TSQLTable;
begin
  LTable := CreateTestTable;
  LCommand := TUpdateCommand.Create(LTable);
  try
    LCommand.UpdateFields.Add(TSQLField.Create('NAME', LTable));
    LCommand.UpdateFields.Add(TSQLField.Create('AGE', LTable));
    LCommand.UpdateFields.Add(TSQLField.Create('HEIGHT', LTable));
    LCommand.WhereFields.Add(TSQLWhereField.Create('ID', LTable));

    ReturnValue := FAnsiSQLGenerator.GenerateUpdate(LCommand);
    CheckEqualsString(SQL_UPDATE_TEST, ReturnValue);
  finally
    LCommand.Free;
    LTable.Free;
  end;
end;

const
  SQL_DELETE_TEST = 'DELETE FROM TEST.CUSTOMERS' + #13#10
  + ' WHERE "ID"=:ID1;';

procedure TestTAnsiSQLGenerator.TestGenerateDelete;
var
  ReturnValue: string;
  LCommand: TDeleteCommand;
  LTable: TSQLTable;
begin
  LTable := CreateTestTable;
  LCommand := TDeleteCommand.Create(LTable);
  try
    LCommand.WhereFields.Add(TSQLWhereField.Create('ID', LTable));

    ReturnValue := FAnsiSQLGenerator.GenerateDelete(LCommand);
    CheckEqualsString(SQL_DELETE_TEST, ReturnValue);
  finally
    LCommand.Free;
    LTable.Free;
  end;
end;

procedure TestTAnsiSQLGenerator.TestGenerateCreateTable;
var
  ReturnValue: IList<string>;
  LCommand: TCreateTableCommand;
  LTable: TSQLTable;
  LCols: IList<ColumnAttribute>;
begin
  LTable := CreateTestTable;
  LCommand := TCreateTableCommand.Create(LTable);
  try
    LCols := TRttiExplorer.GetColumns(TCustomer);
    LCommand.SetTable(LCols);

    ReturnValue := FAnsiSQLGenerator.GenerateCreateTable(LCommand);
    CheckTrue(ReturnValue.Count > 0);
  finally
    LTable.Free;
    LCommand.Free;
  end;
end;

procedure TestTAnsiSQLGenerator.TestGenerateCreateFK;
var
  LSQL: IList<string>;
  LCommand: TCreateFKCommand;
  LTable: TSQLTable;
  LCols: IList<ColumnAttribute>;
begin
  LTable := CreateTestTable;
  LCommand := TCreateFKCommand.Create(LTable);
  try
    LCols := TRttiExplorer.GetColumns(TCustomer);
    LCommand.SetTable(LCols);
    LCommand.ForeignKeys.Add(
      TSQLForeignKeyField.Create('FKColumn', LTable, 'RefColumn', 'RefTable', [fsOnDeleteCascade, fsOnUpdateCascade]
      )
    );

    LSQL := FAnsiSQLGenerator.GenerateCreateFK(LCommand);
    CheckTrue(LSQL.Count > 0);
  finally
    LTable.Free;
    LCommand.Free;
  end;
end;

procedure TestTAnsiSQLGenerator.TestGenerateCreateSequence;
var
  ReturnValue: string;
begin
  ReturnValue := FAnsiSQLGenerator.GenerateCreateSequence(nil);
  CheckEqualsString('', ReturnValue);
end;

procedure TestTAnsiSQLGenerator.TestGenerateGetNextSequenceValue;
var
  ReturnValue: string;
begin
  ReturnValue := FAnsiSQLGenerator.GenerateGetNextSequenceValue(nil);
  CheckEqualsString('', ReturnValue);
end;

const
  SQL_COUNT_TEST = 'SELECT * FROM TEST.CUSTOMERS WHERE CUSTID = 1;';
  SQL_COUNT = 'SELECT COUNT(*) FROM (' + #13#10 +
    'SELECT * FROM TEST.CUSTOMERS WHERE CUSTID = 1' + #13#10 +
    ') AS ORM_GET_QUERY_COUNT;';

procedure TestTAnsiSQLGenerator.TestGenerateGetQueryCount;
var
  LSQL: string;
begin
  LSQL := FAnsiSQLGenerator.GenerateGetQueryCount(SQL_COUNT_TEST);
  CheckEqualsString(SQL_COUNT, LSQL);
end;

procedure TestTAnsiSQLGenerator.TestGenerateGetLastInsertId;
var
  ReturnValue: string;
begin
  ReturnValue := FAnsiSQLGenerator.GenerateGetLastInsertId(nil);
  CheckEquals('', ReturnValue);
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTAnsiSQLGenerator.Suite);
end.

