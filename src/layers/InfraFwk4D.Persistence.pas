unit InfraFwk4D.Persistence;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  Data.DB,
  InfraFwk4D.DataSet.Iterator,
  SQLBuilder4D;

type

  EPersistenceException = class(Exception)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  IDB = interface(IInvokable)
    ['{4B8DE4DA-DE5F-4524-96D3-50D08F26B12A}']
    function GetOwner: IDB;
  end;

  IDBConnection<T: TCustomConnection> = interface(IDB)
    ['{A23B8BE9-E0BD-45B0-AD7B-B7F9C3769AA5}']
    function GetComponent: T;
  end;

  IDBStatement = interface(IDB)
    ['{27AA6423-5425-4472-AA9C-9777DC47AC1B}']
    function Build(const query: string): IDBStatement; overload;
    function Build(const query: ISQL): IDBStatement; overload;

    function AddOrSetParam(const name: string; const value: TValue): IDBStatement; overload;
    function AddOrSetParam(const name: string; const value: ISQLValue): IDBStatement; overload;
    function ClearParams: IDBStatement;
    function Prepare(const dataSet: TDataSet): IDBStatement;

    procedure Open(const dataSet: TDataSet); overload;
    procedure Open(const iterator: IDataSetIterator); overload;

    procedure Execute; overload;
    procedure Execute(const commit: Boolean); overload;

    function AsDataSet: TDataSet; overload;
    function AsDataSet(const fetchRows: Integer): TDataSet; overload;

    function AsIterator: IDataSetIterator; overload;
    function AsIterator(const fetchRows: Integer): IDataSetIterator; overload;

    function AsField: TField;
  end;

  IDBTransaction = interface(IDB)
    ['{AAFAF475-B600-4E1B-BE52-8490373EDDEB}']
    procedure Commit;
    procedure Rollback;
  end;

  IDBSession = interface(IDB)
    ['{CE7682D8-B2D6-4A05-A080-3E0634321152}']
    function BeginTransaction: IDBTransaction;
    procedure Transactional(const action: TProc);

    function NewStatement: IDBStatement;
  end;

  IDBQueryChanger = interface(IDB)
    ['{0AB16FB3-DA3C-4213-9F12-322D14652C6A}']
    function Initialize(const query: string): IDBQueryChanger; overload;
    function Initialize(const query: ISQL): IDBQueryChanger; overload;

    function Add(const condition: string): IDBQueryChanger; overload;
    function Add(const condition: ISQLClause): IDBQueryChanger; overload;

    function Restore: IDBQueryChanger;

    procedure Activate;
  end;

  IDBDelegate<T: TDataSet> = interface(IDB)
    ['{04DB309F-6132-4ED1-97C4-D7405F19D236}']
    function QueryChanger(const dataSet: T): IDBQueryChanger; overload;
    function QueryChanger(const dataSetName: string): IDBQueryChanger; overload;

    function NewIterator(const dataSet: T): IDataSetIterator; overload;
    function NewIterator(const dataSetName: string): IDataSetIterator; overload;
  end;

  IDBMetaDataInfo = interface(IDB)
    ['{A20C2754-F004-49B2-A2AF-54249EC921FE}']
    /// <summary>DataSet Structure</summary>
    /// <remarks>
    /// Column Name	    Data Type	      Description
    /// RECNO	          dtInt32         Index.
    /// CATALOG_NAME	  dtWideString	  Catalog name.
    /// SCHEMA_NAME	    dtWideString	  Schema name.
    /// TABLE_NAME	    dtWideString	  Table name.
    /// TABLE_TYPE	    dtInt32	        Table type.
    /// </remarks>
    function GetTables: IDataSetIterator;

    /// <summary>DataSet Structure</summary>
    /// <remarks>
    /// Column Name	      Data Type	    Description
    /// RECNO	            dtInt32       Index.
    /// CATALOG_NAME	    dtWideString	Catalog name.
    /// SCHEMA_NAME	      dtWideString	Schema name.
    /// TABLE_NAME	      dtWideString	Table name.
    /// COLUMN_NAME	      dtWideString	Column name.
    /// COLUMN_POSITION	  dtInt32	      Column position.
    /// COLUMN_DATATYPE	  dtInt32	      Column data type.
    /// COLUMN_TYPENAME	  dtWideString	DBMS native column type name.
    /// COLUMN_ATTRIBUTES	dtUInt32	    Column attributes.
    /// COLUMN_PRECISION	dtInt32	      Numeric and date/time column precision.
    /// COLUMN_SCALE	    dtInt32	      Numeric and date/time column scale.
    /// COLUMN_LENGTH	    dtInt32	      Character and byte string column length.
    /// </remarks>
    function GetFields(const tableName: string): IDataSetIterator;

    /// <summary>DataSet Structure</summary>
    /// <remarks>
    /// Column Name	        Data Type	      Description
    /// RECNO	              dtInt32         Index.
    /// CATALOG_NAME	      dtWideString	  Catalog name.
    /// SCHEMA_NAME	        dtWideString	  Schema name.
    /// TABLE_NAME	        dtWideString	  Table name.
    /// INDEX_NAME	        dtWideString	  Index name.
    /// PKEY_NAME	          dtWideString	  Primary key constraint name.
    /// INDEX_TYPE	        dtInt32	        Index type.
    /// </remarks>
    function GetPrimaryKeys(const tableName: string): IDataSetIterator;

    /// <summary>DataSet Structure</summary>
    /// <remarks>
    /// Column Name	        Data Type	      Description
    /// RECNO	              dtInt32         Index.
    /// CATALOG_NAME	      dtWideString	  Catalog name.
    /// SCHEMA_NAME	        dtWideString	  Schema name.
    /// TABLE_NAME	        dtWideString	  Table name.
    /// INDEX_NAME	        dtWideString	  Index name.
    /// PKEY_NAME	          dtWideString	  Primary key constraint name.
    /// INDEX_TYPE	        dtInt32	        Index type.
    /// </remarks>
    function GetIndexes(const tableName: string): IDataSetIterator;

    /// <summary>DataSet Structure</summary>
    /// <remarks>
    /// Column Name	      Data Type	      Description
    /// RECNO	            dtInt32         Index.
    /// CATALOG_NAME	    dtWideString	  Catalog name.
    /// SCHEMA_NAME	      dtWideString	  Schema name.
    /// TABLE_NAME	      dtWideString	  Table name.
    /// FKEY_NAME	        dtWideString	  Foreign key constraint name.
    /// PKEY_CATALOG_NAME	dtWideString	  Referenced table catalog name.
    /// PKEY_SCHEMA_NAME	dtWideString	  Referenced table schema name.
    /// PKEY_TABLE_NAME	  dtWideString	  Referenced table name.
    /// DELETE_RULE	      dtInt32	        Foreign key delete rule.
    /// UPDATE_RULE	      dtInt32	        Foreign key update rule.
    /// </remarks>
    function GetForeignKeys(const tableName: string): IDataSetIterator;

    /// <summary>DataSet Structure</summary>
    /// <remarks>
    /// Column Name	      Data Type	    Description
    /// RECNO	            dtInt32       Index.
    /// CATALOG_NAME	    dtWideString	Catalog name.
    /// SCHEMA_NAME	      dtWideString	Schema name.
    /// GENERATOR_NAME	  dtWideString	Generator / sequence name.
    /// GENERATOR_SCOPE	  dtInt32	      Generator / sequence scope.
    /// </remarks>
    function GetGenerators: IDataSetIterator;

    function TableExists(const tableName: string): Boolean;
    function FieldExists(const tableName, fieldName: string): Boolean;
    function PrimaryKeyExists(const tableName, primaryKeyName: string): Boolean;
    function IndexExists(const tableName, indexName: string): Boolean;
    function ForeignKeyExists(const tableName, foreignKeyName: string): Boolean;
    function GeneratorExists(const generatorName: string): Boolean;
  end;

implementation

end.
