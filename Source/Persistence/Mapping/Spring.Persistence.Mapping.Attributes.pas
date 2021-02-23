{***************************************************************************}
{                                                                           }
{           Spring Framework for Delphi                                     }
{                                                                           }
{           Copyright (c) 2009-2021 Spring4D Team                           }
{                                                                           }
{           http://www.spring4d.org                                         }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

{$I Spring.inc}

unit Spring.Persistence.Mapping.Attributes;

{$IFDEF DELPHIXE4_UP}
  {$ZEROBASEDSTRINGS OFF}
{$ENDIF}

interface

uses
  Rtti,
  TypInfo;

type
  TFetchKind = (
    fkEager,
    fkLazy
  );

  TCascadeKind = (
    ckCascadeAll,
    ckCascadeMerge,
    ckCascadeRefresh,
    ckCascadeRemove
  );
  TCascadeKinds = set of TCascadeKind;

  TForeignStrategy = (
    fsOnDeleteSetNull,
    fsOnDeleteSetDefault,
    fsOnDeleteCascade,
    fsOnDeleteNoAction,
    fsOnUpdateSetNull,
    fsOnUpdateSetDefault,
    fsOnUpdateCascade,
    fsOnUpdateNoAction
  );
  TForeignStrategies = set of TForeignStrategy;

  TColumnProperty = (
    cpRequired,
    cpUnique,
    cpDontInsert,
    cpDontUpdate,
    cpPrimaryKey,
    cpNotNull,
    cpHidden
  );
  TColumnProperties = set of TColumnProperty;

  TDiscriminatorType = (
    dtString,
    dtInteger
  );

  TInheritenceStrategy = (
    isJoined,
    isSingleTable,
    isTablePerClass
  );

  TMemberKind = (
    mkField,
    mkProperty,
    mkClass
  );

  /// <summary>
  ///   Represents query which should be used for given repository method.
  /// </summary>
  QueryAttribute = class(TCustomAttribute)
  private
    fQueryText: string;
  public
    constructor Create(const queryText: string);

    property QueryText: string read fQueryText;
  end;

  TransientAttribute = class(TCustomAttribute);

  TORMAttribute = class(TCustomAttribute)
  private
    fEntityClass: TClass;
    fMember: TRttiMember;
    fMemberKind: TMemberKind;
    procedure SetEntityClass(const value: TClass); virtual;
  public
    property EntityClass: TClass read fEntityClass write SetEntityClass;
    property Member: TRttiMember read fMember write fMember;
    property MemberKind: TMemberKind read fMemberKind write fMemberKind;
  end;

  /// <summary>
  ///   Specifies that the class is an entity.
  /// </summary>
  EntityAttribute = class(TORMAttribute);

  /// <summary>
  ///   Specifies the primary key property or field of an entity.
  /// </summary>
  IdAttribute = class(TORMAttribute);

  /// <summary>
  ///   This annotation specifies the primary table for the annotated entity.
  /// </summary>
  TableAttribute = class(TORMAttribute)
  private
    fTableName: string;
    fSchema: string;
    function GetTableName: string;
    function GetNamespace: string;
  public
    constructor Create; overload;
    constructor Create(const tableName: string; const schema: string = ''); overload;

    property TableName: string read GetTableName;
    property Schema: string read fSchema;
    property Namespace: string read GetNamespace;
  end;

  /// <summary>
  ///   Specifies that field or property value should be autoincremented.
  /// </summary>
  AutoGeneratedAttribute = class(TORMAttribute);

  /// <summary>
  ///   This annotation is used to specify that a unique constraint is to be
  ///   included in the generated DDL for a primary or secondary table.
  /// </summary>
  UniqueConstraintAttribute = class(TORMAttribute);

  /// <summary>
  ///   Specifies properties for databases which uses sequences instead of
  ///   identities.
  /// </summary>
  /// <remarks>
  ///   If sequenceSQL is defined then framework will execute this SQL
  ///   statement when performing an insert. Returned value will be written
  ///   into the entity's primary key column.
  /// </remarks>
  SequenceAttribute = class(TORMAttribute)
  private
    fSequenceName: string;
    fSchema: string;
    fInitialValue: NativeInt;
    fIncrement: Integer;
    fSequenceSQL: string;
    function GetSequenceName: string;
  public
    constructor Create(const sequenceName: string; initialValue: NativeInt;
      increment: Integer); overload;
    constructor Create(const sequenceName, schema: string;
      initialValue: NativeInt; increment: Integer); overload;
    constructor Create(const sequenceSQL: string); overload;

    property SequenceName: string read GetSequenceName;
    property Schema: string read fSchema;
    property InitialValue: NativeInt read fInitialValue;
    property Increment: Integer read fIncrement;
    property SequenceSQL: string read fSequenceSQL;
  end;

  AssociationAttribute = class(TORMAttribute)
  private
    fRequired: Boolean;
    fCascade: TCascadeKinds;
  public
    constructor Create(required: Boolean; cascade: TCascadeKinds);

    property Required: Boolean read fRequired;
    property Cascade: TCascadeKinds read fCascade;
  end;

  ColumnAttribute = class;

  ManyValuedAssociationAttribute = class(AssociationAttribute)
  private
    fMappedBy: string;
    fMappedByMember: TRttiMember;
    function GetMappedByColumn: ColumnAttribute;
    procedure SetEntityClass(const value: TClass); override;
  public
    constructor Create(required: Boolean; cascade: TCascadeKinds;
      const mappedBy: string); overload;

    property MappedBy: string read fMappedBy;
    property MappedByColumn: ColumnAttribute read GetMappedByColumn;
    property MappedByMember: TRttiMember read fMappedByMember write fMappedByMember;
  end;

  /// <summary>
  ///   Defines a many-valued association with one-to-many multiplicity.
  /// </summary>
  OneToManyAttribute = class(AssociationAttribute)
  public
    constructor Create(required: Boolean = False;
      cascade: TCascadeKinds = [ckCascadeAll]);
  end;

  /// <summary>
  ///   This annotation defines a single-valued association to another entity
  ///   class that has many-to-one multiplicity.
  /// </summary>
  ManyToOneAttribute = class(ManyValuedAssociationAttribute);

  /// <summary>
  ///   Is used to specify a mapped column for joining an entity association.
  /// </summary>
  JoinColumnAttribute = class(TORMAttribute)
  private
    fName: string;
    fReferencedColumnName: string;
    fReferencedTableName: string;
  public
    constructor Create(const name, referencedTableName, referencedColumnName: string);

    property Name: string read fName;
    property ReferencedColumnName: string read fReferencedColumnName;
    property ReferencedTableName: string read fReferencedTableName;
  end;

  ForeignJoinColumnAttribute = class(JoinColumnAttribute)
  private
    fForeignStrategies: TForeignStrategies;
  public
    constructor Create(const name, referencedTableName, referencedColumnName: string;
      foreignStrategies: TForeignStrategies); overload;

    property ForeignStrategies: TForeignStrategies read fForeignStrategies write fForeignStrategies;
  end;

  /// <summary>
  ///   Is used to specify a mapped column for a persistent property or field.
  /// </summary>
  ColumnAttribute = class(TORMAttribute)
  private
    fColumnName: string;
    fProperties: TColumnProperties;
    fLength: Integer;
    fPrecision: Integer;
    fScale: Integer;
    fDescription: string;
    function GetName: string;
    function GetIsIdentity: Boolean;
  protected
    function GetIsDiscriminator: Boolean; virtual;
    function GetIsPrimaryKey: Boolean; virtual;
    function GetIsVersionColumn: Boolean; virtual;
  public
    constructor Create; overload;
    constructor Create(properties: TColumnProperties); overload;
    constructor Create(properties: TColumnProperties;
      length, precision, scale: Integer; const description: string = ''); overload;
    constructor Create(const columnName: string; properties: TColumnProperties = []); overload;
    constructor Create(const columnName: string; properties: TColumnProperties;
      length, precision, scale: Integer; const description: string = ''); overload;
    constructor Create(const columnName: string; properties: TColumnProperties;
      length: Integer; const description: string = ''); overload;
    constructor Create(const columnName: string; properties: TColumnProperties;
      precision, scale: Integer; const description: string = ''); overload;

    function CanInsert: Boolean; virtual;
    function CanUpdate: Boolean; virtual;
    function GetValue(const instance: TObject): TValue;

    property IsDiscriminator: Boolean read GetIsDiscriminator;
    property IsIdentity: Boolean read GetIsIdentity;
    property IsPrimaryKey: Boolean read GetIsPrimaryKey;
    property IsVersionColumn: Boolean read GetIsVersionColumn;
    property ColumnName: string read GetName;
    property Properties: TColumnProperties read fProperties;
    property Length: Integer read fLength;
    property Precision: Integer read fPrecision;
    property Scale: Integer read fScale;
    property Description: string read fDescription;
  end;

  /// <summary>
  ///   Is used to implement optimistic locking
  /// </summary>
  VersionAttribute = class(ColumnAttribute)
  private
    fInitialValue: Integer;
  protected
    function GetIsVersionColumn: Boolean; override;
  public
    constructor Create(initialValue: Integer = 0); overload;
    constructor Create(const columnName: string; initialValue: Integer = 0); overload;

    procedure IncrementValue(const instance: TObject);

    property InitialValue: Integer read FInitialValue;
  end;

  TColumnData = record
  public
    ColumnName: string;
    Properties: TColumnProperties;
    Member: TRttiMember;
    IsLazy: Boolean;
    function IsPrimaryKey: Boolean; inline;
  end;

  /// <summary>
  ///   Is used to specify the value of the discriminator column for entities
  ///   of the given type.
  /// </summary>
  DiscriminatorValueAttribute = class(TORMAttribute)
  private
    fValue: TValue;
  public
    constructor Create(const value: TValue);

    property Value: TValue read fValue;
  end;

  /// <summary>
  ///   Is used to define the discriminator column for the SINGLE_TABLE and
  ///   JOINED inheritance mapping strategies.
  /// </summary>
  DiscriminatorColumnAttribute = class(ColumnAttribute)
  private
    fName: string;
    fDiscriminatorType: TDiscriminatorType;
    fLength: Integer;
  protected
    function GetIsDiscriminator: Boolean; override;
  public
    constructor Create(const name: string; discriminatorType: TDiscriminatorType; length: Integer);

    property Name: string read fName;
    property DiscriminatorType: TDiscriminatorType read fDiscriminatorType;
    property Length: Integer read fLength;
  end;

  /// <summary>
  ///   Defines the inheritance strategy to be used for an entity class
  ///   hierarchy.
  /// </summary>
  InheritenceAttribute = class(TORMAttribute)
  private
    fStrategy: TInheritenceStrategy;
  public
    constructor Create(strategy: TInheritenceStrategy);

    property Strategy: TInheritenceStrategy read fStrategy;
  end;

  {TODO -oLinas -cGeneral : OrderBy attribute. see: http://docs.oracle.com/javaee/5/api/javax/persistence/OrderBy.html}
  {TODO -oLinas -cGeneral : ManyToMany attribute. see: http://docs.oracle.com/javaee/5/api/javax/persistence/ManyToMany.html}

implementation

uses
  Spring,
  Spring.Persistence.Core.Exceptions,
  Spring.Reflection;


{$REGION 'TableAttribute'}

constructor TableAttribute.Create;
begin
  inherited Create;
  fTableName := '';
  fSchema := '';
end;

constructor TableAttribute.Create(const tableName: string; const schema: string);
begin
  Create;
  fTableName := tableName;
  fSchema := schema;
end;

function TableAttribute.GetNamespace: string;
begin
  Result := TableName;
  if fSchema <> '' then
    Result := fSchema + '.' + Result;
end;

function TableAttribute.GetTableName: string;
begin
  Result := fTableName;
  if Result = '' then
  begin
    Result := fEntityClass.ClassName;
    if (Result[1] = 'T') and (Length(Result) > 1) then
      Result := Copy(Result, 2, Length(Result));
  end;
end;

{$ENDREGION}


{$REGION 'SequenceAttribute'}

constructor SequenceAttribute.Create(const sequenceName: string;
  initialValue: NativeInt; increment: Integer);
begin
  inherited Create;
  fSequenceName := sequenceName;
  fInitialValue := initialValue;
  fIncrement := increment;
  fSequenceSQL := '';
end;

constructor SequenceAttribute.Create(const sequenceName, schema: string;
  initialValue: NativeInt; increment: Integer);
begin
  inherited Create;
  fSequenceName := sequenceName;
  fSchema := schema;
  fInitialValue := initialValue;
  fIncrement := increment;
  fSequenceSQL := '';
end;

constructor SequenceAttribute.Create(const sequenceSQL: string);
begin
  inherited Create;
  fSequenceSQL := sequenceSQL;
end;

function SequenceAttribute.GetSequenceName: string;
begin
  Result := fSequenceName;
  if fSchema <> '' then
    Result := Result + '.' + fSchema;
end;

{$ENDREGION}


{$REGION 'AssociationAttribute'}

constructor AssociationAttribute.Create(required: Boolean; cascade: TCascadeKinds);
begin
  inherited Create;
  fRequired := required;
  fCascade := cascade;
end;

{$ENDREGION}


{$REGION 'ManyValuedAssociationAttribute'}

constructor ManyValuedAssociationAttribute.Create(
  required: Boolean; cascade: TCascadeKinds; const mappedBy: string);
begin
  Create(required, cascade);
  fMappedBy := mappedBy;
end;

function ManyValuedAssociationAttribute.GetMappedByColumn: ColumnAttribute;
begin
  // TODO raise exception in SetEntityClass already ?
  Result := fMappedByMember.GetCustomAttribute<ColumnAttribute>;
  if Result = nil then
    raise EORMManyToOneMappedByColumnNotFound.CreateFmt(
      'Mapped by column ("%s") not found in the base class "%s".',
      [fMappedBy, fEntityClass.ClassName]);
end;

procedure ManyValuedAssociationAttribute.SetEntityClass(const value: TClass);
var
  rttiType: TRttiType;
begin
  inherited SetEntityClass(value);
  rttiType := TType.GetType(fEntityClass);
  fMappedByMember := rttiType.GetField(fMappedBy);
  if not Assigned(fMappedByMember) then
    fMappedByMember := rttiType.GetProperty(fMappedBy);
end;

{$ENDREGION}


{$REGION 'OneToManyAttribute'}

constructor OneToManyAttribute.Create(required: Boolean;
  cascade: TCascadeKinds);
begin
  inherited Create(required, cascade);
end;

{$ENDREGION}


{$REGION 'JoinColumnAttribute'}

constructor JoinColumnAttribute.Create(
  const name, referencedTableName, referencedColumnName: string);
begin
  inherited Create;
  fName := name;
  fReferencedColumnName := referencedColumnName;
  fReferencedTableName := referencedTableName;
end;

{$ENDREGION}


{$REGION 'ColumnAttribute'}

constructor ColumnAttribute.Create;
begin
  inherited Create;
  fLength := 50;
  fPrecision := 0;
  fScale := 0;
end;

constructor ColumnAttribute.Create(properties: TColumnProperties);
begin
  Create;
  fProperties := properties;
end;

constructor ColumnAttribute.Create(properties: TColumnProperties;
  length, precision, scale: Integer; const description: string);
begin
  Create(properties);
  fLength := length;
  fPrecision := precision;
  fScale := scale;
  fDescription := description;
end;

constructor ColumnAttribute.Create(const columnName: string;
  properties: TColumnProperties);
begin
  Create(properties);
  fColumnName := columnName;
end;

constructor ColumnAttribute.Create(const columnName: string;
  properties: TColumnProperties; length, precision, scale: Integer;
  const description: string);
begin
  Create(columnName, properties);
  fLength := length;
  fPrecision := precision;
  fScale := scale;
  fDescription := description;
end;

constructor ColumnAttribute.Create(const columnName: string;
  properties: TColumnProperties; length: Integer; const description: string);
begin
  Create(columnName, properties, length, 0, 0, description);
end;

constructor ColumnAttribute.Create(const columnName: string;
  properties: TColumnProperties; precision, scale: Integer;
  const description: string);
begin
  Create(columnName, properties, 0, precision, scale, description);
end;

function ColumnAttribute.CanInsert: Boolean;
begin
  Result := not (cpDontInsert in Properties) and not IsIdentity;
end;

function ColumnAttribute.CanUpdate: Boolean;
begin
  Result := not (cpDontUpdate in Properties) and not IsPrimaryKey;
end;

function ColumnAttribute.GetIsDiscriminator: Boolean;
begin
  Result := False;
end;

function ColumnAttribute.GetIsIdentity: Boolean;
begin
  Result := fMember.HasCustomAttribute<AutoGeneratedAttribute>;
end;

function ColumnAttribute.GetIsPrimaryKey: Boolean;
begin
  Result := cpPrimaryKey in Properties;
end;

function ColumnAttribute.GetIsVersionColumn: Boolean;
begin
  Result := False;
end;

function ColumnAttribute.GetName: string;
begin
  Result := fColumnName;
  if Result = '' then
    Result := fMember.Name;
end;

function ColumnAttribute.GetValue(const instance: TObject): TValue;
begin
  Result := fMember.GetValue(instance);
end;

{$ENDREGION}


{$REGION 'DiscriminatorValueAttribute'}

constructor DiscriminatorValueAttribute.Create(const value: TValue);
begin
  inherited Create;
  fValue := value;
end;

{$ENDREGION}


{$REGION 'DiscriminatorColumnAttribute'}

constructor DiscriminatorColumnAttribute.Create(const name: string;
  discriminatorType: TDiscriminatorType; length: Integer);
begin
  inherited Create(name, [], length, 0, 0, '');
  fName := name;
  fDiscriminatorType := discriminatorType;
  fLength := length;
end;

function DiscriminatorColumnAttribute.GetIsDiscriminator: Boolean;
begin
  Result := True;
end;

{$ENDREGION}


{$REGION 'InheritenceAttribute'}

constructor InheritenceAttribute.Create(strategy: TInheritenceStrategy);
begin
  inherited Create;
  fStrategy := strategy;
end;

{$ENDREGION}


{$REGION 'TORMAttribute'}

procedure TORMAttribute.SetEntityClass(const Value: TClass);
begin
  fEntityClass := Value;
end;

{$ENDREGION}


{$REGION 'ForeignJoinColumnAttribute'}

constructor ForeignJoinColumnAttribute.Create(
  const name, referencedTableName, referencedColumnName: string;
  foreignStrategies: TForeignStrategies);
begin
  inherited Create(name, referencedTableName, referencedColumnName);
  fForeignStrategies := foreignStrategies;
end;

{$ENDREGION}


{$REGION 'TColumnData'}

function TColumnData.IsPrimaryKey: Boolean;
begin
  Result := cpPrimaryKey in Properties;
end;

{$ENDREGION}


{$REGION 'VersionAttribute'}

constructor VersionAttribute.Create(initialValue: Integer);
begin
  Create('_version', initialValue);
end;

constructor VersionAttribute.Create(const columnName: string;
  initialValue: Integer);
begin
  fInitialValue := initialValue;
  inherited Create(columnName);
end;

function VersionAttribute.GetIsVersionColumn: Boolean;
begin
  Result := True;
end;

procedure VersionAttribute.IncrementValue(const instance: TObject);
var
  value: Int64;
begin
  value := fMember.GetValue(instance).AsOrdinal;
  Inc(value);
  fMember.SetValue(instance, value);
end;

{$ENDREGION}


{$REGION 'QueryAttribute'}

constructor QueryAttribute.Create(const queryText: string);
begin
  inherited Create;
  fQueryText := queryText;
end;

{$ENDREGION}


end.
