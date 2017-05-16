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
  end;

  IDBConnection<T: TComponent> = interface(IDB)
    ['{A23B8BE9-E0BD-45B0-AD7B-B7F9C3769AA5}']
    function GetComponent: T;
  end;

  IDBStatement<T: TDataSet> = interface(IDB)
    ['{27AA6423-5425-4472-AA9C-9777DC47AC1B}']
    function Build(const query: string): IDBStatement<T>; overload;
    function Build(const query: ISQL): IDBStatement<T>; overload;

    function AddOrSetParam(const name: string; const value: TValue): IDBStatement<T>; overload;
    function AddOrSetParam(const name: string; const value: ISQLValue): IDBStatement<T>; overload;
    function ClearParams: IDBStatement<T>;
    function Prepare(const dataSet: T): IDBStatement<T>;

    procedure Open(const dataSet: T); overload;
    procedure Open(const iterator: IDataSetIterator<T>); overload;

    procedure Execute; overload;
    procedure Execute(const commit: Boolean); overload;

    function AsDataSet: T; overload;
    function AsDataSet(const fetchRows: Integer): T; overload;

    function AsIterator: IDataSetIterator<T>; overload;
    function AsIterator(const fetchRows: Integer): IDataSetIterator<T>; overload;

    function AsField: TField;
  end;

  IDBSession<C: TComponent; T: TDataSet> = interface(IDB)
    ['{CE7682D8-B2D6-4A05-A080-3E0634321152}']
    function GetConnection: IDBConnection<C>;
    function NewStatement: IDBStatement<T>;
  end;

  IDBQueryChanger<T: TDataSet> = interface(IDB)
    ['{0AB16FB3-DA3C-4213-9F12-322D14652C6A}']
    function Initialize(const query: string): IDBQueryChanger<T>; overload;
    function Initialize(const query: ISQL): IDBQueryChanger<T>; overload;

    function Add(const condition: string): IDBQueryChanger<T>; overload;
    function Add(const condition: ISQLClause): IDBQueryChanger<T>; overload;

    function Restore: IDBQueryChanger<T>;

    procedure Activate;
  end;

  IDBMetaDataInfo<T: TDataSet> = interface
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
    function GetTables: IDataSetIterator<T>;

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
    function GetFields(const tableName: string): IDataSetIterator<T>;

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
    function GetPrimaryKeys(const tableName: string): IDataSetIterator<T>;

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
    function GetIndexes(const tableName: string): IDataSetIterator<T>;

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
    function GetForeignKeys(const tableName: string): IDataSetIterator<T>;

    /// <summary>DataSet Structure</summary>
    /// <remarks>
    /// Column Name	      Data Type	    Description
    /// RECNO	            dtInt32       Index.
    /// CATALOG_NAME	    dtWideString	Catalog name.
    /// SCHEMA_NAME	      dtWideString	Schema name.
    /// GENERATOR_NAME	  dtWideString	Generator / sequence name.
    /// GENERATOR_SCOPE	  dtInt32	      Generator / sequence scope.
    /// </remarks>
    function GetGenerators: IDataSetIterator<T>;

    function TableExists(const tableName: string): Boolean;
    function FieldExists(const tableName, fieldName: string): Boolean;
    function PrimaryKeyExists(const tableName, primaryKeyName: string): Boolean;
    function IndexExists(const tableName, indexName: string): Boolean;
    function ForeignKeyExists(const tableName, foreignKeyName: string): Boolean;
    function GeneratorExists(const generatorName: string): Boolean;
  end;

implementation

end.
