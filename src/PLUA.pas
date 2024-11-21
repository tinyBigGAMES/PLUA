{===============================================================================

                   ______  _____    _______  _______ ™
                  |   __ \|     |_ |   |   ||   _   |
                  |    __/|       ||   |   ||       |
                  |___|   |_______||_______||___|___|
                            Lua for Pascal

                 Copyright © 2024-present tinyBigGAMES™ LLC
                          All Rights Reserved.

                   https://github.com/tinyBigGAMES/PLUA

                 See LICENSE file for license information
===============================================================================}

unit PLUA;

{$I PLUA.defines.inc}

interface

uses
  System.TypInfo,
  System.Types,
  System.SysUtils,
  System.IOUtils,
  System.Rtti,
  System.Classes,
  WinApi.Windows,
  PLUA.Common,
  PLUA.Deps,
  PLUA.Deps.Ext,
  PLUA.Debugger;

const
  PLUA_VERSION = '0.1.0';

type
  { TLuaType }
  TLuaType = (ltNone = -1, ltNil = 0, ltBoolean = 1, ltLightUserData = 2,
    ltNumber = 3, ltString = 4, ltTable = 5, ltFunction = 6, ltUserData = 7,
    ltThread = 8);

  { TLuaTable }
  TLuaTable = (LuaTable);

  { TLuaValueType }
  TLuaValueType = (vtInteger, vtDouble, vtString, vtTable, vtPointer,
    vtBoolean);

  { TLuaValue }
  TLuaValue = record
    AsType: TLuaValueType;
    class operator Implicit(const AValue: Integer): TLuaValue;
    class operator Implicit(const AValue: Double): TLuaValue;
    class operator Implicit(const AValue: System.PChar): TLuaValue;
    class operator Implicit(const AValue: TLuaTable): TLuaValue;
    class operator Implicit(const AValue: Pointer): TLuaValue;
    class operator Implicit(const AValue: Boolean): TLuaValue;

    class operator Implicit(const AValue: TLuaValue): Integer;
    class operator Implicit(const AValue: TLuaValue): Double;
    class operator Implicit(const AValue: TLuaValue): System.PChar;
    class operator Implicit(const AValue: TLuaValue): Pointer;
    class operator Implicit(const AValue: TLuaValue): Boolean;

    case Integer of
      0: (AsInteger: Integer);
      1: (AsNumber: Double);
      2: (AsString: System.PChar);
      3: (AsTable: TLuaTable);
      4: (AsPointer: Pointer);
      5: (AsBoolean: Boolean);
  end;

  { ILuaContext }
  ILuaContext = interface
    ['{6AEC306C-45BC-4C65-A0E1-044739DED1EB}']
    function  ArgCount(): Integer;
    function  PushCount(): Integer;
    procedure ClearStack();
    procedure PopStack(const ACount: Integer);
    function  GetStackType(const AIndex: Integer): TLuaType;
    function  GetValue(const AType: TLuaValueType; const AIndex: Integer): TLuaValue;
    procedure PushValue(const AValue: TLuaValue);
    procedure SetTableFieldValue(const AName: string; const AValue: TLuaValue; const AIndex: Integer); overload;
    function  GetTableFieldValue(const AName: string; const AType: TLuaValueType; const AIndex: Integer): TLuaValue; overload;
    procedure SetTableIndexValue(const AName: string; const AValue: TLuaValue; const AIndex: Integer; const AKey: Integer);
    function  GetTableIndexValue(const aName: string; const AType: TLuaValueType; const AIndex: Integer; const AKey: Integer): TLuaValue;
  end;

  { TLuaFunction }
  TLuaFunction = procedure(ALua: ILuaContext) of object;

  { ILua }
  ILua = interface
    ['{671FAB20-00F2-4C81-96A6-6F675A37D00B}']
    procedure Reset();
    procedure LoadStream(const AStream: TStream; const ASize: NativeUInt = 0; const AAutoRun: Boolean = True);
    function  LoadFile(const AFilename: string; const AAutoRun: Boolean = True): Boolean;
    procedure LoadString(const AData: string; const AAutoRun: Boolean = True);
    procedure LoadBuffer(const AData: Pointer; const ASize: NativeUInt; const AAutoRun: Boolean = True);
    procedure Run();
    function  RoutineExist(const AName: string): Boolean;
    function  Call(const AName: string; const AParams: array of TLuaValue): TLuaValue; overload;
    function  PrepCall(const AName: string): Boolean;
    function  Call(const aParamCount: Integer): TLuaValue; overload;
    function  VariableExist(const AName: string): Boolean;
    procedure SetVariable(const AName: string; const AValue: TLuaValue);
    function  GetVariable(const AName: string; const AType: TLuaValueType): TLuaValue;
    procedure RegisterRoutine(const AName: string; const AData: Pointer; const aCode: Pointer); overload;
    procedure RegisterRoutine(const AName: string; const aRoutine: TLuaFunction); overload;
    procedure RegisterRoutines(const AClass: TClass); overload;
    procedure RegisterRoutines(const AObject: TObject); overload;
    procedure RegisterRoutines(const ATables: string; const AClass: TClass; const ATableName: string = ''); overload;
    procedure RegisterRoutines(const ATables: string; const AObject: TObject; const ATableName: string = ''); overload;
  end;

  { Forwards }
  TLua = class;
  TLuaContext = class;

  { ELuaException }
  ELuaException = class(Exception);

  { ELuaRuntimeException }
  ELuaRuntimeException = class(Exception);

  { ELuaSyntaxError }
  ELuaSyntaxError = class(Exception);

  { TLuaContext }
  TLuaContext = class(TNoRefCountObject, ILuaContext)
  protected
    FLua: TLua;
    FPushCount: Integer;
    FPushFlag: Boolean;
    procedure Setup();
    procedure Check();
    procedure IncStackPushCount();
    procedure Cleanup();
    function PushTableForSet(const AName: array of string; const AIndex: Integer; var AStackIndex: Integer; var AFieldNameIndex: Integer): Boolean;
    function PushTableForGet(const AName: array of string; const AIndex: Integer; var AStackIndex: Integer; var AFieldNameIndex: Integer): Boolean;
  public
    constructor Create(const ALua: TLua);
    destructor Destroy(); override;
    function ArgCount(): Integer;
    function PushCount(): Integer;
    procedure ClearStack();
    procedure PopStack(const ACount: Integer);
    function  GetStackType(const AIndex: Integer): TLuaType;
    function  GetValue(const AType: TLuaValueType; const AIndex: Integer): TLuaValue; overload;
    procedure PushValue(const AValue: TLuaValue); overload;
    procedure SetTableFieldValue(const AName: string; const AValue: TLuaValue; const AIndex: Integer); overload;
    function  GetTableFieldValue(const AName: string; const AType: TLuaValueType; const AIndex: Integer): TLuaValue; overload;
    procedure SetTableIndexValue(const AName: string; const AValue: TLuaValue; const AIndex: Integer; const AKey: Integer);
    function  GetTableIndexValue(const AName: string; const AType: TLuaValueType; const AIndex: Integer; const AKey: Integer): TLuaValue;
  end;

  { TLua }
  TLua = class(TNoRefCountObject, ILua)
  protected
    FState: Pointer;
    FContext: TLuaContext;
    FGCStep: Integer;
    procedure Open();
    procedure Close();
    procedure CheckLuaError(const AError: Integer);
    function  PushGlobalTableForSet(const AName: array of string; var AIndex: Integer): Boolean;
    function  PushGlobalTableForGet(const AName: array of string; var AIndex: Integer): Boolean;
    procedure PushTValue(const AValue: System.RTTI.TValue);
    function  CallFunction(const AParams: array of System.RTTI.TValue): System.RTTI.TValue;
    procedure SaveByteCode(const AStream: TStream);
    procedure LoadByteCode(const AStream: TStream; const AName: string; const AAutoRun: Boolean = True);
    procedure Bundle(const AInFilename: string; const AOutFilename: string);
    procedure PushLuaValue(const AValue: TLuaValue);
    function  GetLuaValue(const AIndex: Integer): TLuaValue;
    function  DoCall(const AParams: array of TLuaValue): TLuaValue; overload;
    function  DoCall(const AParamCount: Integer): TLuaValue; overload;
    procedure CleanStack();
    property  State: Pointer read FState;
    property  Context: TLuaContext read FContext;
  public
    constructor Create(); virtual;
    destructor Destroy(); override;

    // Misc
    procedure Reset();
    procedure AddSearchPath(const APath: string);

    // Loading
    procedure LoadStream(const AStream: TStream; const ASize: NativeUInt = 0; const AAutoRun: Boolean = True);
    function  LoadFile(const AFilename: string; const AAutoRun: Boolean = True): Boolean;
    procedure LoadString(const AData: string; const AAutoRun: Boolean = True);
    procedure LoadBuffer(const AData: Pointer; const ASize: NativeUInt; const AAutoRun: Boolean = True);

    // Execution
    function  Call(const AName: string; const AParams: array of TLuaValue): TLuaValue; overload;
    function  PrepCall(const AName: string): Boolean;
    function  Call(const AParamCount: Integer): TLuaValue; overload;
    procedure Run();

    // Routine/Variable exists
    function  RoutineExist(const AName: string): Boolean;
    function  VariableExist(const AName: string): Boolean;

    // Global variables
    procedure SetVariable(const AName: string; const AValue: TLuaValue);
    function  GetVariable(const AName: string; const AType: TLuaValueType): TLuaValue;

    // Register routines
    procedure RegisterRoutine(const AName: string; const AData: Pointer; const ACode: Pointer); overload;
    procedure RegisterRoutine(const AName: string; const ARoutine: TLuaFunction); overload;

    // Auto-register routines
    procedure RegisterRoutines(const AClass: TClass); overload;
    procedure RegisterRoutines(const AObject: TObject); overload;
    procedure RegisterRoutines(const ATables: string; const AClass: TClass; const ATableName: string = ''); overload;
    procedure RegisterRoutines(const ATables: string; const AObject: TObject; const ATableName: string = ''); overload;

    // Garbage collection
    procedure SetGCStepSize(const AStep: Integer);
    function  GetGCStepSize(): Integer;
    function  GetGCMemoryUsed(): Integer;
    procedure CollectGarbage();

    // Compilation
    procedure CompileToStream(const AFilename: string; const AStream: TStream; const ACleanOutput: Boolean);
  end;

implementation

const
  cLuaAutoSetup = 'AutoSetup';

{$REGION ' LUA CODE '}
const cLOADER_LUA : array[1..436] of Byte = (
$2D, $2D, $20, $55, $74, $69, $6C, $69, $74, $79, $20, $66, $75, $6E, $63, $74,
$69, $6F, $6E, $20, $66, $6F, $72, $20, $68, $61, $76, $69, $6E, $67, $20, $61,
$20, $77, $6F, $72, $6B, $69, $6E, $67, $20, $69, $6D, $70, $6F, $72, $74, $20,
$66, $75, $6E, $63, $74, $69, $6F, $6E, $0A, $2D, $2D, $20, $46, $65, $65, $6C,
$20, $66, $72, $65, $65, $20, $74, $6F, $20, $75, $73, $65, $20, $69, $74, $20,
$69, $6E, $20, $79, $6F, $75, $72, $20, $6F, $77, $6E, $20, $70, $72, $6F, $6A,
$65, $63, $74, $73, $0A, $28, $66, $75, $6E, $63, $74, $69, $6F, $6E, $28, $29,
$0A, $20, $20, $20, $20, $6C, $6F, $63, $61, $6C, $20, $73, $63, $72, $69, $70,
$74, $5F, $63, $61, $63, $68, $65, $20, $3D, $20, $7B, $7D, $3B, $0A, $20, $20,
$20, $20, $66, $75, $6E, $63, $74, $69, $6F, $6E, $20, $69, $6D, $70, $6F, $72,
$74, $28, $6E, $61, $6D, $65, $29, $0A, $20, $20, $20, $20, $20, $20, $20, $20,
$69, $66, $20, $73, $63, $72, $69, $70, $74, $5F, $63, $61, $63, $68, $65, $5B,
$6E, $61, $6D, $65, $5D, $20, $3D, $3D, $20, $6E, $69, $6C, $20, $74, $68, $65,
$6E, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $73, $63,
$72, $69, $70, $74, $5F, $63, $61, $63, $68, $65, $5B, $6E, $61, $6D, $65, $5D,
$20, $3D, $20, $6C, $6F, $61, $64, $66, $69, $6C, $65, $28, $6E, $61, $6D, $65,
$29, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $65, $6E, $64, $0A, $20, $20,
$20, $20, $20, $20, $20, $20, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $69,
$66, $20, $73, $63, $72, $69, $70, $74, $5F, $63, $61, $63, $68, $65, $5B, $6E,
$61, $6D, $65, $5D, $20, $7E, $3D, $20, $6E, $69, $6C, $20, $74, $68, $65, $6E,
$0A, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $72, $65, $74,
$75, $72, $6E, $20, $73, $63, $72, $69, $70, $74, $5F, $63, $61, $63, $68, $65,
$5B, $6E, $61, $6D, $65, $5D, $28, $29, $0A, $20, $20, $20, $20, $20, $20, $20,
$20, $65, $6E, $64, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $65, $72, $72,
$6F, $72, $28, $22, $46, $61, $69, $6C, $65, $64, $20, $74, $6F, $20, $6C, $6F,
$61, $64, $20, $73, $63, $72, $69, $70, $74, $20, $22, $20, $2E, $2E, $20, $6E,
$61, $6D, $65, $29, $0A, $20, $20, $20, $20, $65, $6E, $64, $0A, $65, $6E, $64,
$29, $28, $29, $0A
);

const cLUABUNDLE_LUA : array[1..3478] of Byte = (
$28, $66, $75, $6E, $63, $74, $69, $6F, $6E, $28, $61, $72, $67, $73, $29, $0D,
$0A, $6C, $6F, $63, $61, $6C, $20, $6D, $6F, $64, $75, $6C, $65, $73, $20, $3D,
$20, $7B, $7D, $0D, $0A, $6D, $6F, $64, $75, $6C, $65, $73, $5B, $27, $61, $70,
$70, $2F, $62, $75, $6E, $64, $6C, $65, $5F, $6D, $61, $6E, $61, $67, $65, $72,
$2E, $6C, $75, $61, $27, $5D, $20, $3D, $20, $66, $75, $6E, $63, $74, $69, $6F,
$6E, $28, $2E, $2E, $2E, $29, $0D, $0A, $2D, $2D, $20, $43, $6C, $61, $73, $73,
$20, $66, $6F, $72, $20, $63, $6F, $6C, $6C, $65, $63, $74, $69, $6E, $67, $20,
$74, $68, $65, $20, $66, $69, $6C, $65, $27, $73, $20, $63, $6F, $6E, $74, $65,
$6E, $74, $20, $61, $6E, $64, $20, $62, $75, $69, $6C, $64, $69, $6E, $67, $20,
$61, $20, $62, $75, $6E, $64, $6C, $65, $20, $66, $69, $6C, $65, $0D, $0A, $6C,
$6F, $63, $61, $6C, $20, $73, $6F, $75, $72, $63, $65, $5F, $70, $61, $72, $73,
$65, $72, $20, $3D, $20, $69, $6D, $70, $6F, $72, $74, $28, $22, $61, $70, $70,
$2F, $73, $6F, $75, $72, $63, $65, $5F, $70, $61, $72, $73, $65, $72, $2E, $6C,
$75, $61, $22, $29, $0D, $0A, $0D, $0A, $72, $65, $74, $75, $72, $6E, $20, $66,
$75, $6E, $63, $74, $69, $6F, $6E, $28, $65, $6E, $74, $72, $79, $5F, $70, $6F,
$69, $6E, $74, $29, $0D, $0A, $20, $20, $20, $20, $6C, $6F, $63, $61, $6C, $20,
$73, $65, $6C, $66, $20, $3D, $20, $7B, $7D, $0D, $0A, $20, $20, $20, $20, $6C,
$6F, $63, $61, $6C, $20, $66, $69, $6C, $65, $73, $20, $3D, $20, $7B, $7D, $0D,
$0A, $20, $20, $20, $20, $0D, $0A, $20, $20, $20, $20, $2D, $2D, $20, $53, $65,
$61, $72, $63, $68, $65, $73, $20, $74, $68, $65, $20, $67, $69, $76, $65, $6E,
$20, $66, $69, $6C, $65, $20, $72, $65, $63, $75, $72, $73, $69, $76, $65, $6C,
$79, $20, $66, $6F, $72, $20, $69, $6D, $70, $6F, $72, $74, $20, $66, $75, $6E,
$63, $74, $69, $6F, $6E, $20, $63, $61, $6C, $6C, $73, $0D, $0A, $20, $20, $20,
$20, $73, $65, $6C, $66, $2E, $70, $72, $6F, $63, $65, $73, $73, $5F, $66, $69,
$6C, $65, $20, $3D, $20, $66, $75, $6E, $63, $74, $69, $6F, $6E, $28, $66, $69,
$6C, $65, $6E, $61, $6D, $65, $29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20,
$20, $6C, $6F, $63, $61, $6C, $20, $70, $61, $72, $73, $65, $72, $20, $3D, $20,
$73, $6F, $75, $72, $63, $65, $5F, $70, $61, $72, $73, $65, $72, $28, $66, $69,
$6C, $65, $6E, $61, $6D, $65, $29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20,
$20, $66, $69, $6C, $65, $73, $5B, $66, $69, $6C, $65, $6E, $61, $6D, $65, $5D,
$20, $3D, $20, $70, $61, $72, $73, $65, $72, $2E, $63, $6F, $6E, $74, $65, $6E,
$74, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $0D, $0A, $20, $20, $20,
$20, $20, $20, $20, $20, $66, $6F, $72, $20, $5F, $2C, $20, $66, $20, $69, $6E,
$20, $70, $61, $69, $72, $73, $28, $70, $61, $72, $73, $65, $72, $2E, $69, $6E,
$63, $6C, $75, $64, $65, $73, $29, $20, $64, $6F, $0D, $0A, $20, $20, $20, $20,
$20, $20, $20, $20, $20, $20, $20, $20, $73, $65, $6C, $66, $2E, $70, $72, $6F,
$63, $65, $73, $73, $5F, $66, $69, $6C, $65, $28, $66, $29, $0D, $0A, $20, $20,
$20, $20, $20, $20, $20, $20, $65, $6E, $64, $0D, $0A, $20, $20, $20, $20, $65,
$6E, $64, $0D, $0A, $20, $20, $20, $20, $0D, $0A, $20, $20, $20, $20, $2D, $2D,
$20, $43, $72, $65, $61, $74, $65, $20, $61, $20, $62, $75, $6E, $64, $6C, $65,
$20, $66, $69, $6C, $65, $20, $77, $68, $69, $63, $68, $20, $63, $6F, $6E, $74,
$61, $69, $6E, $73, $20, $74, $68, $65, $20, $64, $65, $74, $65, $63, $74, $65,
$64, $20, $66, $69, $6C, $65, $73, $0D, $0A, $20, $20, $20, $20, $73, $65, $6C,
$66, $2E, $62, $75, $69, $6C, $64, $5F, $62, $75, $6E, $64, $6C, $65, $20, $3D,
$20, $66, $75, $6E, $63, $74, $69, $6F, $6E, $28, $64, $65, $73, $74, $5F, $66,
$69, $6C, $65, $29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $6C, $6F,
$63, $61, $6C, $20, $66, $69, $6C, $65, $20, $3D, $20, $69, $6F, $2E, $6F, $70,
$65, $6E, $28, $64, $65, $73, $74, $5F, $66, $69, $6C, $65, $2C, $20, $22, $77,
$22, $29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $0D, $0A, $20, $20,
$20, $20, $20, $20, $20, $20, $66, $69, $6C, $65, $3A, $77, $72, $69, $74, $65,
$28, $22, $28, $66, $75, $6E, $63, $74, $69, $6F, $6E, $28, $61, $72, $67, $73,
$29, $5C, $6E, $22, $29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $66,
$69, $6C, $65, $3A, $77, $72, $69, $74, $65, $28, $22, $6C, $6F, $63, $61, $6C,
$20, $6D, $6F, $64, $75, $6C, $65, $73, $20, $3D, $20, $7B, $7D, $5C, $6E, $22,
$29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $0D, $0A, $20, $20, $20,
$20, $20, $20, $20, $20, $2D, $2D, $20, $43, $72, $65, $61, $74, $65, $20, $61,
$20, $73, $6F, $72, $74, $65, $64, $20, $6C, $69, $73, $74, $20, $6F, $66, $20,
$6B, $65, $79, $73, $20, $73, $6F, $20, $74, $68, $65, $20, $6F, $75, $74, $70,
$75, $74, $20, $77, $69, $6C, $6C, $20, $62, $65, $20, $74, $68, $65, $20, $73,
$61, $6D, $65, $20, $77, $68, $65, $6E, $20, $74, $68, $65, $20, $69, $6E, $70,
$75, $74, $20, $64, $6F, $65, $73, $20, $6E, $6F, $74, $20, $63, $68, $61, $6E,
$67, $65, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $6C, $6F, $63, $61,
$6C, $20, $66, $69, $6C, $65, $6E, $61, $6D, $65, $73, $20, $3D, $20, $7B, $7D,
$0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $66, $6F, $72, $20, $66, $69,
$6C, $65, $6E, $61, $6D, $65, $2C, $20, $5F, $20, $69, $6E, $20, $70, $61, $69,
$72, $73, $28, $66, $69, $6C, $65, $73, $29, $20, $64, $6F, $0D, $0A, $20, $20,
$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $74, $61, $62, $6C, $65, $2E,
$69, $6E, $73, $65, $72, $74, $28, $66, $69, $6C, $65, $6E, $61, $6D, $65, $73,
$2C, $20, $66, $69, $6C, $65, $6E, $61, $6D, $65, $29, $0D, $0A, $20, $20, $20,
$20, $20, $20, $20, $20, $65, $6E, $64, $0D, $0A, $20, $20, $20, $20, $20, $20,
$20, $20, $74, $61, $62, $6C, $65, $2E, $73, $6F, $72, $74, $28, $66, $69, $6C,
$65, $6E, $61, $6D, $65, $73, $29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20,
$20, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $2D, $2D, $20, $41, $64,
$64, $20, $66, $69, $6C, $65, $73, $20, $61, $73, $20, $6D, $6F, $64, $75, $6C,
$65, $73, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $66, $6F, $72, $20,
$5F, $2C, $20, $66, $69, $6C, $65, $6E, $61, $6D, $65, $20, $69, $6E, $20, $70,
$61, $69, $72, $73, $28, $66, $69, $6C, $65, $6E, $61, $6D, $65, $73, $29, $20,
$64, $6F, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20,
$66, $69, $6C, $65, $3A, $77, $72, $69, $74, $65, $28, $22, $6D, $6F, $64, $75,
$6C, $65, $73, $5B, $27, $22, $29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20,
$20, $20, $20, $20, $20, $66, $69, $6C, $65, $3A, $77, $72, $69, $74, $65, $28,
$66, $69, $6C, $65, $6E, $61, $6D, $65, $29, $0D, $0A, $20, $20, $20, $20, $20,
$20, $20, $20, $20, $20, $20, $20, $66, $69, $6C, $65, $3A, $77, $72, $69, $74,
$65, $28, $22, $27, $5D, $20, $3D, $20, $66, $75, $6E, $63, $74, $69, $6F, $6E,
$28, $2E, $2E, $2E, $29, $5C, $6E, $22, $29, $0D, $0A, $20, $20, $20, $20, $20,
$20, $20, $20, $20, $20, $20, $20, $66, $69, $6C, $65, $3A, $77, $72, $69, $74,
$65, $28, $66, $69, $6C, $65, $73, $5B, $66, $69, $6C, $65, $6E, $61, $6D, $65,
$5D, $29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20,
$66, $69, $6C, $65, $3A, $77, $72, $69, $74, $65, $28, $22, $5C, $6E, $22, $29,
$0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $66, $69,
$6C, $65, $3A, $77, $72, $69, $74, $65, $28, $22, $65, $6E, $64, $5C, $6E, $22,
$29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $65, $6E, $64, $0D, $0A,
$20, $20, $20, $20, $20, $20, $20, $20, $66, $69, $6C, $65, $3A, $77, $72, $69,
$74, $65, $28, $22, $66, $75, $6E, $63, $74, $69, $6F, $6E, $20, $69, $6D, $70,
$6F, $72, $74, $28, $6E, $29, $5C, $6E, $22, $29, $0D, $0A, $20, $20, $20, $20,
$20, $20, $20, $20, $66, $69, $6C, $65, $3A, $77, $72, $69, $74, $65, $28, $22,
$72, $65, $74, $75, $72, $6E, $20, $6D, $6F, $64, $75, $6C, $65, $73, $5B, $6E,
$5D, $28, $74, $61, $62, $6C, $65, $2E, $75, $6E, $70, $61, $63, $6B, $28, $61,
$72, $67, $73, $29, $29, $5C, $6E, $22, $29, $0D, $0A, $20, $20, $20, $20, $20,
$20, $20, $20, $66, $69, $6C, $65, $3A, $77, $72, $69, $74, $65, $28, $22, $65,
$6E, $64, $5C, $6E, $22, $29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20,
$0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $66, $69, $6C, $65, $3A, $77,
$72, $69, $74, $65, $28, $22, $6C, $6F, $63, $61, $6C, $20, $65, $6E, $74, $72,
$79, $20, $3D, $20, $69, $6D, $70, $6F, $72, $74, $28, $27, $22, $20, $2E, $2E,
$20, $65, $6E, $74, $72, $79, $5F, $70, $6F, $69, $6E, $74, $20, $2E, $2E, $20,
$22, $27, $29, $5C, $6E, $22, $29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20,
$20, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $66, $69, $6C, $65, $3A,
$77, $72, $69, $74, $65, $28, $22, $65, $6E, $64, $29, $28, $7B, $2E, $2E, $2E,
$7D, $29, $22, $29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $66, $69,
$6C, $65, $3A, $66, $6C, $75, $73, $68, $28, $29, $0D, $0A, $20, $20, $20, $20,
$20, $20, $20, $20, $66, $69, $6C, $65, $3A, $63, $6C, $6F, $73, $65, $28, $29,
$0D, $0A, $20, $20, $20, $20, $65, $6E, $64, $0D, $0A, $20, $20, $20, $20, $0D,
$0A, $20, $20, $20, $20, $72, $65, $74, $75, $72, $6E, $20, $73, $65, $6C, $66,
$0D, $0A, $65, $6E, $64, $0D, $0A, $65, $6E, $64, $0D, $0A, $6D, $6F, $64, $75,
$6C, $65, $73, $5B, $27, $61, $70, $70, $2F, $6D, $61, $69, $6E, $2E, $6C, $75,
$61, $27, $5D, $20, $3D, $20, $66, $75, $6E, $63, $74, $69, $6F, $6E, $28, $2E,
$2E, $2E, $29, $0D, $0A, $2D, $2D, $20, $4D, $61, $69, $6E, $20, $66, $75, $6E,
$63, $74, $69, $6F, $6E, $20, $6F, $66, $20, $74, $68, $65, $20, $70, $72, $6F,
$67, $72, $61, $6D, $0D, $0A, $6C, $6F, $63, $61, $6C, $20, $62, $75, $6E, $64,
$6C, $65, $5F, $6D, $61, $6E, $61, $67, $65, $72, $20, $3D, $20, $69, $6D, $70,
$6F, $72, $74, $28, $22, $61, $70, $70, $2F, $62, $75, $6E, $64, $6C, $65, $5F,
$6D, $61, $6E, $61, $67, $65, $72, $2E, $6C, $75, $61, $22, $29, $0D, $0A, $0D,
$0A, $72, $65, $74, $75, $72, $6E, $20, $66, $75, $6E, $63, $74, $69, $6F, $6E,
$28, $61, $72, $67, $73, $29, $0D, $0A, $20, $20, $20, $20, $69, $66, $20, $23,
$61, $72, $67, $73, $20, $3D, $3D, $20, $31, $20, $61, $6E, $64, $20, $61, $72,
$67, $73, $5B, $31, $5D, $20, $3D, $3D, $20, $22, $2D, $76, $22, $20, $74, $68,
$65, $6E, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $70, $72, $69, $6E,
$74, $28, $22, $6C, $75, $61, $62, $75, $6E, $64, $6C, $65, $20, $76, $30, $2E,
$30, $31, $22, $29, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $6F, $73,
$2E, $65, $78, $69, $74, $28, $29, $0D, $0A, $20, $20, $20, $20, $65, $6C, $73,
$65, $69, $66, $20, $23, $61, $72, $67, $73, $20, $7E, $3D, $20, $32, $20, $74,
$68, $65, $6E, $0D, $0A, $20, $20, $20, $20, $20, $20, $20, $20, $70, $72, $69,
$6E, $74, $28, $22, $75, $73, $61, $67, $65, $3A, $20, $6C, $75, $61, $62, $75,
$6E, $64, $6C, $65, $20, $69, $6E, $20, $6F, $75, $74, $22, $29, $0D, $0A, $20,
$20, $20, $20, $20, $20, $20, $20, $6F, $73, $2E, $65, $78, $69, $74, $28, $29,
$0D, $0A, $20, $20, $20, $20, $65, $6E, $64, $0D, $0A, $20, $20, $20, $20, $0D,
$0A, $20, $20, $20, $20, $6C, $6F, $63, $61, $6C, $20, $69, $6E, $66, $69, $6C,
$65, $20, $3D, $20, $61, $72, $67, $73, $5B, $31, $5D, $0D, $0A, $20, $20, $20,
$20, $6C, $6F, $63, $61, $6C, $20, $6F, $75, $74, $66, $69, $6C, $65, $20, $3D,
$20, $61, $72, $67, $73, $5B, $32, $5D, $0D, $0A, $20, $20, $20, $20, $6C, $6F,
$63, $61, $6C, $20, $62, $75, $6E, $64, $6C, $65, $20, $3D, $20, $62, $75, $6E,
$64, $6C, $65, $5F, $6D, $61, $6E, $61, $67, $65, $72, $28, $69, $6E, $66, $69,
$6C, $65, $29, $0D, $0A, $20, $20, $20, $20, $62, $75, $6E, $64, $6C, $65, $2E,
$70, $72, $6F, $63, $65, $73, $73, $5F, $66, $69, $6C, $65, $28, $69, $6E, $66,
$69, $6C, $65, $2C, $20, $62, $75, $6E, $64, $6C, $65, $29, $0D, $0A, $20, $20,
$20, $20, $0D, $0A, $20, $20, $20, $20, $62, $75, $6E, $64, $6C, $65, $2E, $62,
$75, $69, $6C, $64, $5F, $62, $75, $6E, $64, $6C, $65, $28, $6F, $75, $74, $66,
$69, $6C, $65, $29, $0D, $0A, $65, $6E, $64, $0D, $0A, $65, $6E, $64, $0D, $0A,
$6D, $6F, $64, $75, $6C, $65, $73, $5B, $27, $61, $70, $70, $2F, $73, $6F, $75,
$72, $63, $65, $5F, $70, $61, $72, $73, $65, $72, $2E, $6C, $75, $61, $27, $5D,
$20, $3D, $20, $66, $75, $6E, $63, $74, $69, $6F, $6E, $28, $2E, $2E, $2E, $29,
$0D, $0A, $2D, $2D, $20, $43, $6C, $61, $73, $73, $20, $66, $6F, $72, $20, $65,
$78, $74, $72, $61, $63, $74, $69, $6E, $67, $20, $69, $6D, $70, $6F, $72, $74,
$20, $66, $75, $6E, $63, $74, $69, $6F, $6E, $20, $63, $61, $6C, $6C, $73, $20,
$66, $72, $6F, $6D, $20, $73, $6F, $75, $72, $63, $65, $20, $66, $69, $6C, $65,
$73, $0D, $0A, $72, $65, $74, $75, $72, $6E, $20, $66, $75, $6E, $63, $74, $69,
$6F, $6E, $28, $66, $69, $6C, $65, $6E, $61, $6D, $65, $29, $0D, $0A, $20, $20,
$20, $20, $6C, $6F, $63, $61, $6C, $20, $66, $69, $6C, $65, $20, $3D, $20, $69,
$6F, $2E, $6F, $70, $65, $6E, $28, $66, $69, $6C, $65, $6E, $61, $6D, $65, $2C,
$20, $22, $72, $22, $29, $0D, $0A, $20, $20, $20, $20, $69, $66, $20, $66, $69,
$6C, $65, $20, $3D, $3D, $20, $6E, $69, $6C, $20, $74, $68, $65, $6E, $0D, $0A,
$20, $20, $20, $20, $20, $20, $20, $20, $65, $72, $72, $6F, $72, $28, $22, $46,
$69, $6C, $65, $20, $6E, $6F, $74, $20, $66, $6F, $75, $6E, $64, $3A, $20, $22,
$20, $2E, $2E, $20, $66, $69, $6C, $65, $6E, $61, $6D, $65, $29, $0D, $0A, $20,
$20, $20, $20, $65, $6E, $64, $0D, $0A, $20, $20, $20, $20, $6C, $6F, $63, $61,
$6C, $20, $66, $69, $6C, $65, $5F, $63, $6F, $6E, $74, $65, $6E, $74, $20, $3D,
$20, $66, $69, $6C, $65, $3A, $72, $65, $61, $64, $28, $22, $2A, $61, $22, $29,
$0D, $0A, $20, $20, $20, $20, $66, $69, $6C, $65, $3A, $63, $6C, $6F, $73, $65,
$28, $29, $0D, $0A, $20, $20, $20, $20, $6C, $6F, $63, $61, $6C, $20, $69, $6E,
$63, $6C, $75, $64, $65, $64, $5F, $66, $69, $6C, $65, $73, $20, $3D, $20, $7B,
$7D, $0D, $0A, $20, $20, $20, $20, $0D, $0A, $20, $20, $20, $20, $2D, $2D, $20,
$53, $65, $61, $72, $63, $68, $20, $66, $6F, $72, $20, $69, $6D, $70, $6F, $72,
$74, $28, $29, $20, $63, $61, $6C, $6C, $73, $20, $77, $69, $74, $68, $20, $64,
$6F, $62, $75, $6C, $65, $20, $71, $75, $6F, $74, $65, $73, $20, $28, $21, $29,
$0D, $0A, $20, $20, $20, $20, $66, $6F, $72, $20, $66, $20, $69, $6E, $20, $73,
$74, $72, $69, $6E, $67, $2E, $67, $6D, $61, $74, $63, $68, $28, $66, $69, $6C,
$65, $5F, $63, $6F, $6E, $74, $65, $6E, $74, $2C, $20, $27, $69, $6D, $70, $6F,
$72, $74, $25, $28, $5B, $22, $5C, $27, $5D, $28, $5B, $5E, $5C, $27, $22, $5D,
$2D, $29, $5B, $22, $5C, $27, $5D, $25, $29, $27, $29, $20, $64, $6F, $0D, $0A,
$20, $20, $20, $20, $20, $20, $20, $20, $74, $61, $62, $6C, $65, $2E, $69, $6E,
$73, $65, $72, $74, $28, $69, $6E, $63, $6C, $75, $64, $65, $64, $5F, $66, $69,
$6C, $65, $73, $2C, $20, $66, $29, $0D, $0A, $20, $20, $20, $20, $65, $6E, $64,
$0D, $0A, $20, $20, $20, $20, $0D, $0A, $20, $20, $20, $20, $73, $65, $6C, $66,
$20, $3D, $20, $7B, $7D, $0D, $0A, $20, $20, $20, $20, $73, $65, $6C, $66, $2E,
$66, $69, $6C, $65, $6E, $61, $6D, $65, $20, $3D, $20, $66, $69, $6C, $65, $6E,
$61, $6D, $65, $0D, $0A, $20, $20, $20, $20, $73, $65, $6C, $66, $2E, $63, $6F,
$6E, $74, $65, $6E, $74, $20, $3D, $20, $66, $69, $6C, $65, $5F, $63, $6F, $6E,
$74, $65, $6E, $74, $0D, $0A, $20, $20, $20, $20, $73, $65, $6C, $66, $2E, $69,
$6E, $63, $6C, $75, $64, $65, $73, $20, $3D, $20, $69, $6E, $63, $6C, $75, $64,
$65, $64, $5F, $66, $69, $6C, $65, $73, $0D, $0A, $20, $20, $20, $20, $72, $65,
$74, $75, $72, $6E, $20, $73, $65, $6C, $66, $0D, $0A, $65, $6E, $64, $0D, $0A,
$65, $6E, $64, $0D, $0A, $6D, $6F, $64, $75, $6C, $65, $73, $5B, $27, $6C, $75,
$61, $62, $75, $6E, $64, $6C, $65, $2E, $6C, $75, $61, $27, $5D, $20, $3D, $20,
$66, $75, $6E, $63, $74, $69, $6F, $6E, $28, $2E, $2E, $2E, $29, $0D, $0A, $2D,
$2D, $20, $45, $6E, $74, $72, $79, $20, $70, $6F, $69, $6E, $74, $20, $6F, $66,
$20, $74, $68, $65, $20, $70, $72, $6F, $67, $72, $61, $6D, $2E, $0D, $0A, $2D,
$2D, $20, $4F, $6E, $6C, $79, $20, $62, $61, $73, $69, $63, $20, $73, $74, $75,
$66, $66, $20, $69, $73, $20, $73, $65, $74, $20, $75, $70, $20, $68, $65, $72,
$65, $2C, $20, $74, $68, $65, $20, $61, $63, $74, $75, $61, $6C, $20, $70, $72,
$6F, $67, $72, $61, $6D, $20, $69, $73, $20, $69, $6E, $20, $61, $70, $70, $2F,
$6D, $61, $69, $6E, $2E, $6C, $75, $61, $0D, $0A, $6C, $6F, $63, $61, $6C, $20,
$61, $72, $67, $73, $20, $3D, $20, $7B, $2E, $2E, $2E, $7D, $0D, $0A, $0D, $0A,
$2D, $2D, $20, $43, $68, $65, $63, $6B, $20, $69, $66, $20, $77, $65, $20, $61,
$72, $65, $20, $61, $6C, $72, $65, $61, $64, $79, $20, $62, $75, $6E, $64, $6C,
$65, $64, $0D, $0A, $69, $66, $20, $69, $6D, $70, $6F, $72, $74, $20, $3D, $3D,
$20, $6E, $69, $6C, $20, $74, $68, $65, $6E, $0D, $0A, $20, $20, $20, $20, $64,
$6F, $66, $69, $6C, $65, $28, $22, $75, $74, $69, $6C, $2F, $6C, $6F, $61, $64,
$65, $72, $2E, $6C, $75, $61, $22, $29, $0D, $0A, $65, $6E, $64, $0D, $0A, $0D,
$0A, $69, $6D, $70, $6F, $72, $74, $28, $22, $61, $70, $70, $2F, $6D, $61, $69,
$6E, $2E, $6C, $75, $61, $22, $29, $28, $61, $72, $67, $73, $29, $0D, $0A, $65,
$6E, $64, $0D, $0A, $66, $75, $6E, $63, $74, $69, $6F, $6E, $20, $69, $6D, $70,
$6F, $72, $74, $28, $6E, $29, $0D, $0A, $72, $65, $74, $75, $72, $6E, $20, $6D,
$6F, $64, $75, $6C, $65, $73, $5B, $6E, $5D, $28, $74, $61, $62, $6C, $65, $2E,
$75, $6E, $70, $61, $63, $6B, $28, $61, $72, $67, $73, $29, $29, $0D, $0A, $65,
$6E, $64, $0D, $0A, $6C, $6F, $63, $61, $6C, $20, $65, $6E, $74, $72, $79, $20,
$3D, $20, $69, $6D, $70, $6F, $72, $74, $28, $27, $6C, $75, $61, $62, $75, $6E,
$64, $6C, $65, $2E, $6C, $75, $61, $27, $29, $0D, $0A, $65, $6E, $64, $29, $28,
$7B, $2E, $2E, $2E, $7D, $29
);
{$ENDREGION}

function LuaWrapperClosure(const aState: Pointer): Integer; cdecl;
var
  LMethod: TMethod;
  LClosure: TLuaFunction absolute LMethod;
  LLua: TLua;
begin
  // get lua object
  LLua := lua_touserdata(aState, lua_upvalueindex(1));

  // get lua class routine
  LMethod.Code := lua_touserdata(aState, lua_upvalueindex(2));
  LMethod.Data := lua_touserdata(aState, lua_upvalueindex(3));

  // init the context
  LLua.Context.Setup;

  // call class routines
  LClosure(LLua.Context);

  // return result count
  Result := LLua.Context.PushCount;

  // clean up stack
  LLua.Context.Cleanup;
end;

function LuaWrapperWriter(aState: Plua_State; const aBuffer: Pointer; aSize: NativeUInt; aData: Pointer): Integer; cdecl;
var
  LStream: TStream;
begin
  LStream := TStream(aData);
  try
    LStream.WriteBuffer(aBuffer^, aSize);
    Result := 0;
  except
    on E: EStreamError do
      Result := 1;
  end;
end;

{ TLuaValue }
class operator TLuaValue.Implicit(const AValue: Integer): TLuaValue;
begin
  Result.AsType := vtInteger;
  Result.AsInteger := AValue;
end;

class operator TLuaValue.Implicit(const AValue: Double): TLuaValue;
begin
  Result.AsType := vtDouble;
  Result.AsNumber := AValue;
end;

class operator TLuaValue.Implicit(const AValue: System.PChar): TLuaValue;
begin
  Result.AsType := vtString;
  Result.AsString := AValue;
end;

class operator TLuaValue.Implicit(const AValue: TLuaTable): TLuaValue;
begin
  Result.AsType := vtTable;
  Result.AsTable := AValue;
end;

class operator TLuaValue.Implicit(const AValue: Pointer): TLuaValue;
begin
  Result.AsType := vtPointer;
  Result.AsPointer := AValue;
end;

class operator TLuaValue.Implicit(const AValue: Boolean): TLuaValue;
begin
  Result.AsType := vtBoolean;
  Result.AsBoolean := AValue;
end;

class operator TLuaValue.Implicit(const AValue: TLuaValue): Integer;
begin
  Result := AValue.AsInteger;
end;

class operator TLuaValue.Implicit(const AValue: TLuaValue): Double;
begin
  Result := AValue.AsNumber;
end;

var TLuaValue_Implicit_LValue: string = '';
class operator TLuaValue.Implicit(const AValue: TLuaValue): System.PChar;
begin
  TLuaValue_Implicit_LValue := AValue.AsString;
  Result := PChar(TLuaValue_Implicit_LValue);
end;

class operator TLuaValue.Implicit(const AValue: TLuaValue): Pointer;
begin
  Result := AValue.AsPointer
end;

class operator TLuaValue.Implicit(const AValue: TLuaValue): Boolean;
begin
  Result := AValue.AsBoolean;
end;

{ Routines }
function ParseTableNames(const aNames: string): TStringDynArray;
var
  LItems: TArray<string>;
  LI: Integer;
begin
  LItems := aNames.Split(['.']);
  SetLength(Result, Length(LItems));
  for LI := 0 to High(LItems) do
  begin
    Result[LI] := LItems[LI];
  end;
end;

{ TLuaContext }
procedure TLuaContext.Setup();
begin
  FPushCount := 0;
  FPushFlag := True;
end;

procedure TLuaContext.Check();
begin
  if FPushFlag then
  begin
    FPushFlag := False;
    ClearStack;
  end;
end;

procedure TLuaContext.IncStackPushCount();
begin
  Inc(FPushCount);
end;

procedure TLuaContext.Cleanup();
begin
  if FPushFlag then
  begin
    ClearStack;
  end;
end;

function TLuaContext.PushTableForSet(const AName: array of string; const AIndex: Integer; var AStackIndex: Integer; var AFieldNameIndex: Integer): Boolean;
var
  LMarshall: TMarshaller;
  LI: Integer;
begin
  Result := False;

  // validate name array size
  AStackIndex := Length(AName);
  if AStackIndex < 1 then  Exit;

  // validate return aStackIndex and aFieldNameIndex
  if Length(AName) = 1 then
    AFieldNameIndex := 0
  else
    AFieldNameIndex := Length(AName) - 1;

  // table does not exist, exit
  if lua_type(FLua.State, AIndex) <> LUA_TTABLE then Exit;

  // process sub tables
  for LI := 0 to AStackIndex - 1 do
  begin
    // check if table at field aIndex[i] exits
    lua_getfield(FLua.State, LI + AIndex, LMarshall.AsAnsi(AName[LI]).ToPointer);

    // table field does not exists, create a new one
    if lua_type(FLua.State, -1) <> LUA_TTABLE then
    begin
      // clean up stack
      lua_pop(FLua.State, 1);

      // push new table
      lua_newtable(FLua.State);

      // set new table a field
      lua_setfield(FLua.State, LI + AIndex, LMarshall.AsAnsi(AName[LI]).ToPointer);

      // push field table back on stack
      lua_getfield(FLua.State, LI + AIndex, LMarshall.AsAnsi(AName[LI]).ToPointer);
    end;
  end;

  Result := True;
end;

function TLuaContext.PushTableForGet(const AName: array of string; const AIndex: Integer; var AStackIndex: Integer; var AFieldNameIndex: Integer): Boolean;
var
  LMarshall: TMarshaller;
  LI: Integer;
begin
  Result := False;

  // validate name array size
  AStackIndex := Length(AName);
  if AStackIndex < 1 then  Exit;

  // validate return aStackIndex and aFieldNameIndex
  if AStackIndex = 1 then
    AFieldNameIndex := 0
  else
    AFieldNameIndex := AStackIndex - 1;

  // table does not exist, exit
  if lua_type(FLua.State, AIndex) <> LUA_TTABLE then  Exit;

  // process sub tables
  for LI := 0 to AStackIndex - 2 do
  begin
    // check if table at field aIndex[i] exits
    lua_getfield(FLua.State, LI + AIndex, LMarshall.AsAnsi(AName[LI]).ToPointer);

    // table field does not exists, create a new one
    if lua_type(FLua.State, -1) <> LUA_TTABLE then Exit;
  end;

  Result := True;
end;

constructor TLuaContext.Create(const ALua: TLua);
begin
  FLua := ALua;
  FPushCount := 0;
  FPushFlag := False;
end;

destructor TLuaContext.Destroy();
begin
  FLua := nil;
  FPushCount := 0;
  FPushFlag := False;
  inherited;
end;

function TLuaContext.ArgCount(): Integer;
begin
  Result := lua_gettop(FLua.State);
end;

function TLuaContext.PushCount: Integer;
begin
  Result := FPushCount;
end;

procedure TLuaContext.ClearStack();
begin
  lua_pop(FLua.State, lua_gettop(FLua.State));
  FPushCount := 0;
  FPushFlag := False;
end;

procedure TLuaContext.PopStack(const ACount: Integer);
begin
  lua_pop(FLua.State, ACount);
end;

function TLuaContext.GetStackType(const AIndex: Integer): TLuaType;
begin
  Result := TLuaType(lua_type(FLua.State, AIndex));
end;

var TLuaContext_GetValue_LStr: string = '';
function TLuaContext.GetValue(const AType: TLuaValueType; const AIndex: Integer): TLuaValue;
begin
  Result := Default(TLuaValue);
  case AType of
    vtInteger:
      begin
        Result.AsInteger := lua_tointeger(FLua.State, AIndex);
      end;
    vtDouble:
      begin
        Result.AsNumber := lua_tonumber(FLua.State, AIndex);
      end;
    vtString:
      begin
        TLuaContext_GetValue_LStr := lua_tostring(FLua.State, AIndex);
        Result := PChar(TLuaContext_GetValue_LStr);
      end;
    vtPointer:
      begin
        Result.AsPointer := lua_touserdata(FLua.State, AIndex);
      end;
    vtBoolean:
      begin
        Result.AsBoolean := Boolean(lua_toboolean(FLua.State, AIndex));
      end;
  else
    begin

    end;
  end;
end;

procedure TLuaContext.PushValue(const AValue: TLuaValue);
var
  LMarshall: TMarshaller;
begin
  Check;

  case AValue.AsType of
    vtInteger:
      begin
        lua_pushinteger(FLua.State, AValue);
      end;
    vtDouble:
      begin
        lua_pushnumber(FLua.State, AValue);
      end;
    vtString:
      begin
        lua_pushstring(FLua.State, LMarshall.AsAnsi(AValue.AsString).ToPointer);
      end;
    vtTable:
      begin
        lua_newtable(FLua.State);
      end;
    vtPointer:
      begin
        lua_pushlightuserdata(FLua.State, AValue);
      end;
    vtBoolean:
      begin
        lua_pushboolean(FLua.State, AValue.AsBoolean.ToInteger);
      end;
  end;

  IncStackPushCount();
end;

procedure TLuaContext.SetTableFieldValue(const AName: string; const AValue: TLuaValue; const AIndex: Integer);
var
  LMarshall: TMarshaller;
  LStackIndex: Integer;
  LFieldNameIndex: Integer;
  LItems: TStringDynArray;
  LOk: Boolean;
begin
  LItems := ParseTableNames(AName);
  if not PushTableForSet(LItems, AIndex, LStackIndex, LFieldNameIndex) then Exit;
  LOk := True;

  case AValue.AsType of
    vtInteger:
      begin
        lua_pushinteger(FLua.State, AValue);
      end;
    vtDouble:
      begin
        lua_pushnumber(FLua.State, AValue);
      end;
    vtString:
      begin
        lua_pushstring(FLua.State, LMarshall.AsAnsi(AValue.AsString).ToPointer);
      end;
    vtPointer:
      begin
        lua_pushlightuserdata(FLua.State, AValue);
      end;
    vtBoolean:
      begin
        lua_pushboolean(FLua.State, AValue.AsBoolean.ToInteger);
      end;
  else
    begin
      LOk := False;
    end;
  end;

  if LOk then
  begin
    lua_setfield(FLua.State, LStackIndex + (AIndex - 1),
      LMarshall.AsAnsi(LItems[LFieldNameIndex]).ToPointer);
  end;

  PopStack(LStackIndex);
end;

var TLuaContext_GetTableFieldValue_LStr: string = '';
function TLuaContext.GetTableFieldValue(const AName: string; const AType: TLuaValueType; const AIndex: Integer): TLuaValue;
var
  LMarshall: TMarshaller;
  LStackIndex: Integer;
  LFieldNameIndex: Integer;
  LItems: TStringDynArray;
begin
  LItems := ParseTableNames(AName);
  if not PushTableForGet(LItems, AIndex, LStackIndex, LFieldNameIndex) then
    Exit;
  lua_getfield(FLua.State, LStackIndex + (AIndex - 1),
    LMarshall.AsAnsi(LItems[LFieldNameIndex]).ToPointer);

  case AType of
    vtInteger:
      begin
        Result := lua_tointeger(FLua.State, -1);
      end;
    vtDouble:
      begin
        Result := lua_tonumber(FLua.State, -1);
      end;
    vtString:
      begin
        TLuaContext_GetTableFieldValue_LStr := lua_tostring(FLua.State, -1);
        Result := PChar(TLuaContext_GetTableFieldValue_LStr);
      end;
    vtPointer:
      begin
        Result := lua_touserdata(FLua.State, -1);
      end;
    vtBoolean:
      begin
        Result := Boolean(lua_toboolean(FLua.State, -1));
      end;
  end;

  PopStack(LStackIndex);
end;

procedure TLuaContext.SetTableIndexValue(const AName: string; const AValue: TLuaValue; const AIndex: Integer; const AKey: Integer);
var
  LMarshall: TMarshaller;
  LStackIndex: Integer;
  LFieldNameIndex: Integer;
  LItems: TStringDynArray;
  LOk: Boolean;

  procedure LPushValue;
  begin
    LOk := True;

    case AValue.AsType of
      vtInteger:
        begin
          lua_pushinteger(FLua.State, AValue);
        end;
      vtDouble:
        begin
          lua_pushnumber(FLua.State, AValue);
        end;
      vtString:
        begin
          lua_pushstring(FLua.State, LMarshall.AsAnsi(AValue.AsString).ToPointer);
        end;
      vtPointer:
        begin
          lua_pushlightuserdata(FLua.State, AValue);
        end;
      vtBoolean:
        begin
          lua_pushboolean(FLua.State, AValue.AsBoolean.ToInteger);
        end;
    else
      begin
        LOk := False;
      end;
    end;
  end;

begin
  LItems := ParseTableNames(AName);
  if Length(LItems) > 0 then
    begin
      if not PushTableForGet(LItems, AIndex, LStackIndex, LFieldNameIndex) then  Exit;
      LPushValue;
      if LOk then
        lua_rawseti (FLua.State, LStackIndex + (AIndex - 1), AKey);
    end
  else
    begin
      LPushValue;
      if LOk then
      begin
        lua_rawseti (FLua.State, AIndex, AKey);
      end;
      LStackIndex := 0;
    end;

    PopStack(LStackIndex);
end;

var TLuaContext_GetTableIndexValue_LStr: string = '';
function TLuaContext.GetTableIndexValue(const AName: string; const AType: TLuaValueType; const AIndex: Integer; const AKey: Integer): TLuaValue;
var
  LStackIndex: Integer;
  LFieldNameIndex: Integer;
  LItems: TStringDynArray;
begin
  LItems := ParseTableNames(AName);
  if Length(LItems) > 0 then
    begin
      if not PushTableForGet(LItems, AIndex, LStackIndex, LFieldNameIndex) then Exit;
      lua_rawgeti (FLua.State, LStackIndex + (AIndex - 1), AKey);
    end
  else
    begin
      lua_rawgeti (FLua.State, AIndex, AKey);
      LStackIndex := 0;
    end;

  case AType of
    vtInteger:
      begin
        Result := lua_tointeger(FLua.State, -1);
      end;
    vtDouble:
      begin
        Result := lua_tonumber(FLua.State, -1);
      end;
    vtString:
      begin
        TLuaContext_GetTableIndexValue_LStr := lua_tostring(FLua.State, -1);
        Result := PChar(TLuaContext_GetTableIndexValue_LStr);
      end;
    vtPointer:
      begin
        Result := lua_touserdata(FLua.State, -1);
      end;
    vtBoolean:
      begin
        Result := Boolean(lua_toboolean(FLua.State, -1));
      end;
  end;

  PopStack(LStackIndex);
end;


{ TLua }
procedure TLua.Open();
begin
  if FState <> nil then Exit;
  FState := luaL_newstate;
  SetGCStepSize(200);
  luaL_openlibs(FState);
  LoadBuffer(@cLOADER_LUA, Length(cLOADER_LUA));
  FContext := TLuaContext.Create(Self);

  SetVariable('PLUA.luaVersion', GetVariable('jit.version', vtString));
  SetVariable('PLUA.version', PLUA_VERSION);

  dbg_setup_default(FState);
end;

procedure TLua.Close();
begin
  if FState = nil then Exit;
  FreeAndNil(FContext);
  lua_close(FState);
  FState := nil;
end;

procedure TLua.CheckLuaError(const AError: Integer);
var
  LErr: string;
begin
  if FState = nil then Exit;

  case AError of
    // success
    0:
      begin

      end;
    // a runtime error.
    LUA_ERRRUN:
      begin
        LErr := lua_tostring(FState, -1);
        lua_pop(FState, 1);
        raise ELuaRuntimeException.CreateFmt('Runtime error [%s]', [LErr]);
      end;
    // memory allocation error. For such errors, Lua does not call the error handler function.
    LUA_ERRMEM:
      begin
        LErr := lua_tostring(FState, -1);
        lua_pop(FState, 1);
        raise ELuaException.CreateFmt('Memory allocation error [%s]', [LErr]);
      end;
    // error while running the error handler function.
    LUA_ERRERR:
      begin
        LErr := lua_tostring(FState, -1);
        lua_pop(FState, 1);
        raise ELuaException.CreateFmt
          ('Error while running the error handler function [%s]', [LErr]);
      end;
    LUA_ERRSYNTAX:
      begin
        LErr := lua_tostring(FState, -1);
        lua_pop(FState, 1);
        raise ELuaSyntaxError.CreateFmt('Syntax Error [%s]', [LErr]);
      end
  else
    begin
      LErr := lua_tostring(FState, -1);
      lua_pop(FState, 1);
      raise ELuaException.CreateFmt('Unknown Error [%s]', [LErr]);
    end;
  end;
end;

function TLua.PushGlobalTableForSet(const AName: array of string; var AIndex: Integer): Boolean;
var
  LMarshall: TMarshaller;
  LI: Integer;
begin
  Result := False;

  if FState = nil then Exit;

  if Length(AName) < 2 then Exit;

  AIndex := Length(AName) - 1;

  // check if global table exists
  lua_getglobal(FState, LMarshall.AsAnsi(AName[0]).ToPointer);

  // table does not exist, create new one
  if lua_type(FState, lua_gettop(FState)) <> LUA_TTABLE then
  begin
    // clean up stack
    lua_pop(FState, 1);

    // create new table
    lua_newtable(FState);

    // make it global
    lua_setglobal(FState, LMarshall.AsAnsi(AName[0]).ToPointer);

    // push global table back on stack
    lua_getglobal(FState, LMarshall.AsAnsi(AName[0]).ToPointer);
  end;

  // process tables in global table at index 1+
  // global table on stack, process remaining tables
  for LI := 1 to AIndex - 1 do
  begin
    // check if table at field aIndex[i] exits
    lua_getfield(FState, LI, LMarshall.AsAnsi(AName[LI]).ToPointer);

    // table field does not exists, create a new one
    if lua_type(FState, -1) <> LUA_TTABLE then
    begin
      // clean up stack
      lua_pop(FState, 1);

      // push new table
      lua_newtable(FState);

      // set new table a field
      lua_setfield(FState, LI, LMarshall.AsAnsi(AName[LI]).ToPointer);

      // push field table back on stack
      lua_getfield(FState, LI, LMarshall.AsAnsi(AName[LI]).ToPointer);
    end;
  end;

  Result := True;
end;

function TLua.PushGlobalTableForGet(const AName: array of string; var AIndex: Integer): Boolean;
var
  LMarshall: TMarshaller;
  LI: Integer;
begin
  // assume false
  Result := False;

  if FState = nil then Exit;

  // check for valid table name count
  if Length(AName) < 2 then Exit;

  // init stack index
  AIndex := Length(AName) - 1;

  // lookup global table
  lua_getglobal(FState, LMarshall.AsAnsi(AName[0]).ToPointer);

  // check of global table exits
  if lua_type(FState, lua_gettop(FState)) = LUA_TTABLE then
  begin
    // process tables in global table at index 1+
    // global table on stack, process remaining tables
    for LI := 1 to AIndex - 1 do
    begin
      // get table at field aIndex[i]
      lua_getfield(FState, LI, LMarshall.AsAnsi(AName[LI]).ToPointer);

      // table field does not exists, exit
      if lua_type(FState, -1) <> LUA_TTABLE then
      begin
        // table name does not exit so we are out of here with an error
        Exit;
      end;
    end;
  end;

  // all table names exits we are good
  Result := True;
end;

procedure TLua.PushTValue(const AValue: System.RTTI.TValue);
var
  LUtf8s: RawByteString;
begin
  if FState = nil then Exit;

  case AValue.Kind of
    tkUnknown, tkChar, tkSet, tkMethod, tkVariant, tkArray, tkProcedure, tkRecord, tkInterface, tkDynArray, tkClassRef:
      begin
        lua_pushnil(FState);
      end;
    tkInteger:
      lua_pushinteger(FState, AValue.AsInteger);
    tkEnumeration:
      begin
        if AValue.IsType<Boolean> then
        begin
          if AValue.AsBoolean then
            lua_pushboolean(FState, Ord(True))
          else
            lua_pushboolean(FState, Ord(False));
        end
        else
          lua_pushinteger(FState, AValue.AsInteger);
      end;
    tkFloat:
      lua_pushnumber(FState, AValue.AsExtended);
    tkString, tkWChar, tkLString, tkWString, tkUString:
      begin
        LUtf8s := UTF8Encode(AValue.AsString);
        lua_pushstring(FState, PAnsiChar(LUtf8s));
      end;
    //tkClass:
    //  lua_pushlightuserdata(FState, Pointer(aValue.AsObject));
    tkInt64:
      lua_pushnumber(FState, AValue.AsInt64);
    //tkPointer:
    //  lua_pushlightuserdata(FState, Pointer(aValue.AsObject));
  end;
end;

function TLua.CallFunction(const AParams: array of System.RTTI.TValue): System.RTTI.TValue;
var
  LP: System.RTTI.TValue;
  LR: Integer;
begin
  if FState = nil then Exit;

  for LP in AParams do
    PushTValue(LP);
  LR := lua_pcall(FState, Length(AParams), 1, 0);
  CheckLuaError(LR);
  lua_pop(FState, 1);
  case lua_type(FState, -1) of
    LUA_TNIL:
      begin
        Result := nil;
      end;

    LUA_TBOOLEAN:
      begin
        Result := Boolean(lua_toboolean(FState, -1));
      end;

    LUA_TNUMBER:
      begin
        Result := lua_tonumber(FState, -1);
      end;

    LUA_TSTRING:
      begin
        Result := lua_tostring(FState, -1);
      end;
  else
    Result := nil;
  end;
end;

procedure TLua.Bundle(const AInFilename: string; const AOutFilename: string);
var
  LInFilename: string;
  LOutFilename: string;
begin
  if FState = nil then Exit;

  if AInFilename.IsEmpty then  Exit;
  if AOutFilename.IsEmpty then Exit;
  LInFilename := AInFilename.Replace('\', '/');
  LOutFilename := AOutFilename.Replace('\', '/');
  LoadBuffer(@cLUABUNDLE_LUA, Length(cLUABUNDLE_LUA), False);
  DoCall([PChar(LInFilename), PChar(LOutFilename)]);
end;

constructor TLua.Create();
begin
  inherited;

  FState := nil;
  Open;
end;

destructor TLua.Destroy();
begin
  Close();
  inherited;
end;

procedure TLua.Reset();
begin
  if FState = nil then Exit;

  //TODO: Add OnPreLuaReset callback
  Close;
  Open;
  //TODO: add OnPostLuaReset callback
end;

procedure TLua.AddSearchPath(const APath: string);
var
  LPathToAdd: string;
  LCurrentPath: string;
begin
  if not Assigned(FState) then Exit;

  // Check if APath already ends with "?.lua"
  if APath.EndsWith('?.lua') then
    LPathToAdd := APath
  else
    LPathToAdd := IncludeTrailingPathDelimiter(APath) + '?.lua';

  // Retrieve the current package.path
  lua_getglobal(FState, 'package'); // Get the "package" table
  if not lua_istable(FState, -1) then
    raise Exception.Create('"package" is not a table in the Lua state');

  lua_getfield(FState, -1, 'path'); // Get the "package.path" field
  if LongBool(lua_isstring(FState, -1)) then
    LCurrentPath := string(lua_tostring(FState, -1))
  else
    LCurrentPath := ''; // Default to empty if "path" is not set

  lua_pop(FState, 1); // Pop the "package.path" field

  // Check if the path is already included
  if Pos(LPathToAdd, LCurrentPath) = 0 then
  begin
    // Append the new path if not already included
    LCurrentPath := LPathToAdd + ';' + LCurrentPath;

    // Update package.path
    lua_pushstring(FState, AsUTF8(LCurrentPath)); // Push the updated path
    lua_setfield(FState, -2, 'path'); // Update "package.path"
  end;

  lua_pop(FState, 1); // Pop the "package" table
end;

function TLua.LoadFile(const AFilename: string; const AAutoRun: Boolean): Boolean;
var
  LMarshall: TMarshaller;
  LErr: string;
  LRes: Integer;
begin
  Result := False;
  if not Assigned(FState) then Exit;

  if AFilename.IsEmpty then Exit;

  if not TFile.Exists(AFilename) then Exit;
  if AAutoRun then
    LRes := luaL_dofile(FState, LMarshall.AsUtf8(AFilename).ToPointer)
  else
    LRes := luaL_loadfile(FState, LMarshall.AsUtf8(AFilename).ToPointer);
  if LRes <> 0 then
  begin
    LErr := lua_tostring(FState, -1);
    lua_pop(FState, 1);
    raise ELuaException.Create(LErr);
  end;

  Result := True;
end;

procedure TLua.LoadString(const AData: string; const AAutoRun: Boolean);
var
  LMarshall: TMarshaller;
  LErr: string;
  LRes: Integer;
  LData: string;
begin
  if not Assigned(FState) then Exit;

  LData := AData;
  if LData.IsEmpty then Exit;

  if AAutoRun then
    LRes := luaL_dostring(FState, LMarshall.AsAnsi(LData).ToPointer)
  else
    LRes := luaL_loadstring(FState, LMarshall.AsAnsi(LData).ToPointer);

  if LRes <> 0 then
  begin
    LErr := lua_tostring(FState, -1);
    lua_pop(FState, 1);
    raise ELuaException.Create(LErr);
  end;
end;

procedure TLua.LoadStream(const AStream: TStream; const ASize: NativeUInt; const AAutoRun: Boolean);
var
  LMemStream: TMemoryStream;
  LSize: NativeUInt;
begin
  if not Assigned(FState) then Exit;

  LMemStream := TMemoryStream.Create;
  try
    if ASize = 0 then
      LSize := AStream.Size
    else
      LSize := ASize;
    LMemStream.Position := 0;
    LMemStream.CopyFrom(AStream, LSize);
    LoadBuffer(LMemStream.Memory, LMemStream.size, AAutoRun);
  finally
    FreeAndNil(LMemStream);
  end;
end;

procedure TLua.LoadBuffer(const AData: Pointer; const ASize: NativeUInt; const AAutoRun: Boolean);
var
  LMemStream: TMemoryStream;
  LRes: Integer;
  LErr: string;
  LSize: NativeUInt;
begin
  if not Assigned(FState) then Exit;

  LMemStream := TMemoryStream.Create;
  try
    LMemStream.Write(AData^, ASize);
    LMemStream.Position := 0;
    LSize := LMemStream.Size;
    if AAutoRun then
      LRes := luaL_dobuffer(FState, LMemStream.Memory, LSize, 'LoadBuffer')
    else
      LRes := luaL_loadbuffer(FState, LMemStream.Memory, LSize, 'LoadBuffer');
  finally
    FreeAndNil(LMemStream);
  end;

  if LRes <> 0 then
  begin
    LErr := lua_tostring(FState, -1);
    lua_pop(FState, 1);
    raise ELuaException.Create(LErr);
  end;
end;

procedure TLua.SaveByteCode(const AStream: TStream);
var
  LRet: Integer;
begin
  if not Assigned(FState) then Exit;

  if lua_type(FState, lua_gettop(FState)) <> LUA_TFUNCTION then Exit;

  try
    LRet := lua_dump(FState, LuaWrapperWriter, AStream);
    if LRet <> 0 then
      raise ELuaException.CreateFmt('lua_dump returned code %d', [LRet]);
  finally
    lua_pop(FState, 1);
  end;
end;

procedure TLua.LoadByteCode(const AStream: TStream; const AName: string; const AAutoRun: Boolean);
var
  LRes: NativeUInt;
  LErr: string;
  LMemStream: TMemoryStream;
  LMarshall: TMarshaller;
begin
  if not Assigned(FState) then Exit;
  if not Assigned(AStream) then Exit;
  if AStream.size <= 0 then Exit;

  LMemStream := TMemoryStream.Create;

  try
    LMemStream.CopyFrom(AStream, AStream.size);

    if AAutoRun then
    begin
      LRes := luaL_dobuffer(FState, LMemStream.Memory, LMemStream.size,
        LMarshall.AsAnsi(AName).ToPointer)
    end
    else
      LRes := luaL_loadbuffer(FState, LMemStream.Memory, LMemStream.size,
        LMarshall.AsAnsi(AName).ToPointer);
  finally
    LMemStream.Free;
  end;

  if LRes <> 0 then
  begin
    LErr := lua_tostring(FState, -1);
    lua_pop(FState, 1);
    raise ELuaException.Create(LErr);
  end;
end;

procedure TLua.PushLuaValue(const AValue: TLuaValue);
begin
  if not Assigned(FState) then Exit;

  case AValue.AsType of
    vtInteger:
      begin
        lua_pushinteger(FState, AValue.AsInteger);
      end;
    vtDouble:
      begin
        lua_pushnumber(FState, AValue.AsNumber);
      end;
    vtString:
      begin
        lua_pushstring(FState, PAnsiChar(UTF8Encode(AValue.AsString)));
      end;
    vtPointer:
      begin
        lua_pushlightuserdata(FState, AValue.AsPointer);
      end;
    vtBoolean:
      begin
        lua_pushboolean(FState, AValue.AsBoolean.ToInteger);
      end;
  else
    begin
      lua_pushnil(FState);
    end;
  end;
end;

var TLua_GetLuaValue_LStr: string = '';
function TLua.GetLuaValue(const AIndex: Integer): TLuaValue;
begin
  Result := Default(TLuaValue);

  if not Assigned(FState) then Exit;

  case lua_type(FState, AIndex) of
    LUA_TNIL:
      begin
        Result := nil;
      end;

    LUA_TBOOLEAN:
      begin
        Result.AsBoolean := Boolean(lua_toboolean(FState, AIndex));
      end;

    LUA_TNUMBER:
      begin
        Result.AsNumber := lua_tonumber(FState, AIndex);
      end;

    LUA_TSTRING:
      begin
        TLua_GetLuaValue_LStr := lua_tostring(FState, AIndex);
        Result := PChar(TLua_GetLuaValue_LStr);
      end;
  else
    begin
      Result := Default(TLuaValue);
    end;
  end;
end;

function TLua.DoCall(const AParams: array of TLuaValue): TLuaValue;
var
  LValue: TLuaValue;
  LRes: Integer;
begin
  if not Assigned(FState) then Exit;

  for LValue in AParams do
  begin
    PushLuaValue(LValue);
  end;

  LRes := lua_pcall(FState, Length(AParams), 1, 0);
  CheckLuaError(LRes);
  Result := GetLuaValue(-1);
end;

function TLua.DoCall(const AParamCount: Integer): TLuaValue;
var
  LRes: Integer;
begin
  Result := nil;
  if not Assigned(FState) then Exit;

  LRes := lua_pcall(FState, AParamCount, 1, 0);
  CheckLuaError(LRes);
  Result := GetLuaValue(-1);
  CleanStack();
end;

procedure TLua.CleanStack();
begin
  if FState = nil then Exit;

  lua_pop(FState, lua_gettop(FState));
end;

function TLua.Call(const AName: string; const AParams: array of TLuaValue): TLuaValue;
var
  LMarshall: TMarshaller;
  LIndex: Integer;
  LItems: TStringDynArray;
begin
  Result := nil;
  if not Assigned(FState) then Exit;

  if AName.IsEmpty then Exit;

  CleanStack();

  LItems := ParseTableNames(AName);

  if Length(LItems) > 1 then
    begin
      if not PushGlobalTableForGet(LItems, LIndex) then
      begin
        CleanStack;
        Exit;
      end;

      lua_getfield(FState,  LIndex, LMarshall.AsAnsi(LItems[LIndex]).ToPointer);
    end
  else
    begin
      lua_getglobal(FState, LMarshall.AsAnsi(LItems[0]).ToPointer);
    end;

  if not lua_isnil(FState, lua_gettop(FState)) then
  begin
    if lua_isfunction(FState, -1) then
    begin
      Result := DoCall(AParams);
    end;
  end;

  CleanStack();
end;

function TLua.PrepCall(const AName: string): Boolean;
var
  LMarshall: TMarshaller;
  LIndex: Integer;
  LItems: TStringDynArray;
begin
  Result := False;
  if not Assigned(FState) then Exit;

  if AName.IsEmpty then Exit;

  CleanStack;

  LItems := ParseTableNames(AName);

  if Length(LItems) > 1 then
    begin
      if not PushGlobalTableForGet(LItems, LIndex) then
      begin
        CleanStack;
        Exit;
      end;

      lua_getfield(FState,  LIndex, LMarshall.AsAnsi(LItems[LIndex]).ToPointer);
    end
  else
    begin
      lua_getglobal(FState, LMarshall.AsAnsi(LItems[0]).ToPointer);
    end;

  Result := True;
end;

function TLua.Call(const AParamCount: Integer): TLuaValue;
begin
  Result := nil;
  if not Assigned(FState) then Exit;

  if not lua_isnil(FState, lua_gettop(FState)) then
  begin
    if lua_isfunction(FState, -1) then
    begin
      Result := DoCall(AParamCount);
    end;
  end;
end;

function TLua.RoutineExist(const AName: string): Boolean;
var
  LMarshall: TMarshaller;
  LIndex: Integer;
  LItems: TStringDynArray;
  LCount: Integer;
  LName: string;
begin
  Result := False;
  if not Assigned(FState) then Exit;

  LName := AName;
  if LName.IsEmpty then  Exit;

  LItems := ParseTableNames(LName);

  LCount := Length(LItems);

  if LCount > 1 then
    begin
      if not PushGlobalTableForGet(LItems, LIndex) then
      begin
        CleanStack;
        Exit;
      end;
      lua_getfield(FState, LIndex, LMarshall.AsAnsi(LItems[LIndex]).ToPointer);
    end
  else
    begin
      lua_getglobal(FState, LMarshall.AsAnsi(LName).ToPointer);
    end;

  if not lua_isnil(FState, lua_gettop(FState)) then
  begin
    if lua_isfunction(FState, -1) then
    begin
      Result := True;
    end;
  end;

  CleanStack();
end;

procedure TLua.Run;
var
  LErr: string;
  LRes: Integer;
begin
  if not Assigned(FState) then Exit;

  // Check if the stack has any values
  if lua_gettop(FState) = 0 then
    raise ELuaException.Create('Lua stack is empty. Nothing to run.');

  // Check if the top of the stack is a function
  if lua_type(FState, lua_gettop(FState)) <> LUA_TFUNCTION then
    raise ELuaException.Create('Top of the stack is not a callable function.');

  // Call the function on the stack
  LRes := lua_pcall(FState, 0, LUA_MULTRET, 0);

  // Handle errors from pcall
  if LRes <> LUA_OK then
  begin
    LErr := lua_tostring(FState, -1);
    lua_pop(FState, 1);
    raise ELuaException.Create(LErr);
  end;
end;


function TLua.VariableExist(const AName: string): Boolean;
var
  LMarshall: TMarshaller;
  LIndex: Integer;
  LItems: TStringDynArray;
  LCount: Integer;
  LName: string;
begin
  Result := False;
  if not Assigned(FState) then Exit;

  LName := AName;
  if LName.IsEmpty then Exit;

  LItems := ParseTableNames(LName);
  LCount := Length(LItems);

  if LCount > 1 then
    begin
      if not PushGlobalTableForGet(LItems, LIndex) then
      begin
        CleanStack;
        Exit;
      end;
      lua_getfield(FState, LIndex, LMarshall.AsAnsi(LItems[LIndex]).ToPointer);
    end
  else if LCount = 1 then
    begin
      lua_getglobal(FState, LMarshall.AsAnsi(LName).ToPointer);
    end
  else
    begin
      Exit;
    end;

  if not lua_isnil(FState, lua_gettop(FState)) then
  begin
    Result := lua_isvariable(FState, -1);
  end;

  CleanStack();
end;

var TLua_GetVariable_LStr: string = '';
function TLua.GetVariable(const AName: string; const AType: TLuaValueType): TLuaValue;
var
  LMarshall: TMarshaller;
  LIndex: Integer;
  LItems: TStringDynArray;
  LCount: Integer;
  LName: string;
begin
  Result := Default(TLuaValue);
  if not Assigned(FState) then Exit;

  LName := AName;
  if LName.IsEmpty then Exit;

  LItems := ParseTableNames(LName);
  LCount := Length(LItems);

  if LCount > 1 then
    begin
      if not PushGlobalTableForGet(LItems, LIndex) then
      begin
        CleanStack;
        Exit;
      end;
      lua_getfield(FState, LIndex, LMarshall.AsAnsi(LItems[LIndex]).ToPointer);
    end
  else if LCount = 1 then
    begin
      lua_getglobal(FState, LMarshall.AsAnsi(LName).ToPointer);
    end
  else
    begin
      Exit;
    end;

  case AType of
    vtInteger:
      begin
        Result.AsInteger := lua_tointeger(FState, -1);
      end;
    vtDouble:
      begin
        Result.AsNumber := lua_tonumber(FState, -1);
      end;
    vtString:
      begin
        TLua_GetVariable_LStr := lua_tostring(FState, -1);
        Result := PChar(TLua_GetVariable_LStr);
      end;
    vtPointer:
      begin
        Result.AsPointer := lua_touserdata(FState, -1);
      end;
    vtBoolean:
      begin
        Result.AsBoolean := Boolean(lua_toboolean(FState, -1));
      end;
  end;

  CleanStack();
end;

procedure TLua.SetVariable(const AName: string; const AValue: TLuaValue);
var
  LMarshall: TMarshaller;
  LIndex: Integer;
  LItems: TStringDynArray;
  LOk: Boolean;
  LCount: Integer;
  LName: string;
begin
  if not Assigned(FState) then Exit;

  LName := AName;
  if LName.IsEmpty then Exit;

  LItems := ParseTableNames(AName);
  LCount := Length(LItems);

  if LCount > 1 then
    begin
      if not PushGlobalTableForSet(LItems, LIndex) then
      begin
        CleanStack;
        Exit;
      end;
    end
  else if LCount < 1 then
    begin
      Exit;
    end;

  LOk := True;

  case AValue.AsType of
    vtInteger:
      begin
        lua_pushinteger(FState, AValue);
      end;
    vtDouble:
      begin
        lua_pushnumber(FState, AValue);
      end;
    vtString:
      begin
        lua_pushstring(FState, LMarshall.AsUtf8(AValue).ToPointer);
      end;
    vtPointer:
      begin
        lua_pushlightuserdata(FState, AValue);
      end;
    vtBoolean:
      begin
        lua_pushboolean(FState, AValue.AsBoolean.ToInteger);
      end;
  else
    begin
      LOk := False;
    end;
  end;

  if LOk then
  begin
    if LCount > 1 then
      begin
        lua_setfield(FState, LIndex, LMarshall.AsAnsi(LItems[LIndex]).ToPointer)
      end
    else
      begin
        lua_setglobal(FState, LMarshall.AsAnsi(LName).ToPointer);
      end;
  end;

  CleanStack();
end;

procedure TLua.RegisterRoutine(const AName: string; const ARoutine: TLuaFunction);
var
  LMethod: TMethod;
  LMarshall: TMarshaller;
  LIndex: Integer;
  LNames: array of string;
  LI: Integer;
  LItems: TStringDynArray;
  LCount: Integer;
begin
  if not Assigned(FState) then Exit;
  if AName.IsEmpty then Exit;

  // parse table LNames in table.table.xxx format
  LItems := ParseTableNames(AName);

  LCount := Length(LItems);

  SetLength(LNames, Length(LItems));

  for LI := 0 to High(LItems) do
  begin
    LNames[LI] := LItems[LI];
  end;

  // init sub table LNames
  if LCount > 1 then
    begin
      // push global table to stack
      if not PushGlobalTableForSet(LNames, LIndex) then
      begin
        CleanStack;
        Exit;
      end;

      // push closure
      LMethod.Code := TMethod(ARoutine).Code;
      LMethod.Data := TMethod(ARoutine).Data;
      lua_pushlightuserdata(FState, Self);
      lua_pushlightuserdata(FState, LMethod.Code);
      lua_pushlightuserdata(FState, LMethod.Data);
      lua_pushcclosure(FState, @LuaWrapperClosure, 3);

      // add field to table
      lua_setfield(FState, -2, LMarshall.AsAnsi(LNames[LIndex]).ToPointer);

      CleanStack();
    end
  else if (LCount = 1) then
    begin
      // push closure
      LMethod.Code := TMethod(ARoutine).Code;
      LMethod.Data := TMethod(ARoutine).Data;
      lua_pushlightuserdata(FState, Self);
      lua_pushlightuserdata(FState, LMethod.Code);
      lua_pushlightuserdata(FState, LMethod.Data);
      lua_pushcclosure(FState, @LuaWrapperClosure, 3);

      // set as global
      lua_setglobal(FState, LMarshall.AsAnsi(LNames[0]).ToPointer);
    end;
end;

procedure TLua.RegisterRoutine(const AName: string; const AData: Pointer; const ACode: Pointer);
var
  LMarshall: TMarshaller;
  LIndex: Integer;
  LNames: array of string;
  LI: Integer;
  LItems: TStringDynArray;
  LCount: Integer;
begin
  if not Assigned(FState) then Exit;
  if AName.IsEmpty then Exit;

  // parse table LNames in table.table.xxx format
  LItems := ParseTableNames(AName);

  LCount := Length(LItems);

  SetLength(LNames, Length(LItems));

  for LI := 0 to High(LItems) do
  begin
    LNames[LI] := LItems[LI];
  end;

  // init sub table LNames
  if LCount > 1 then
    begin
      // push global table to stack
      if not PushGlobalTableForSet(LNames, LIndex) then
      begin
        CleanStack;
        Exit;
      end;

      // push closure
      lua_pushlightuserdata(FState, Self);
      lua_pushlightuserdata(FState, ACode);
      lua_pushlightuserdata(FState, AData);
      lua_pushcclosure(FState, @LuaWrapperClosure, 3);

      // add field to table
      lua_setfield(FState, -2, LMarshall.AsAnsi(LNames[LIndex]).ToPointer);

      CleanStack();
    end
  else if (LCount = 1) then
    begin
      // push closure
      lua_pushlightuserdata(FState, Self);
      lua_pushlightuserdata(FState, ACode);
      lua_pushlightuserdata(FState, AData);
      lua_pushcclosure(FState, @LuaWrapperClosure, 3);

      // set as global
      lua_setglobal(FState, LMarshall.AsAnsi(LNames[0]).ToPointer);
    end;
end;

procedure TLua.RegisterRoutines(const AClass: TClass);
var
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiMethod: TRttiMethod;
  LMethodAutoSetup: TRttiMethod;

  LRttiParameters: TArray<System.Rtti.TRttiParameter>;
  LMethod: TMethod;
  LMarshall: TMarshaller;
begin
  if not Assigned(FState) then Exit;

  LRttiType := LRttiContext.GetType(AClass);
  LMethodAutoSetup := nil;

  for LRttiMethod in LRttiType.GetMethods do
  begin
    if (LRttiMethod.MethodKind <> mkClassProcedure) then continue;
    if (LRttiMethod.Visibility <> mvPublic) then continue;

    LRttiParameters := LRttiMethod.GetParameters;

    // check for public AutoSetup class function
    if SameText(LRttiMethod.Name, cLuaAutoSetup) then
    begin
      if (Length(LRttiParameters) = 1) and (Assigned(LRttiParameters[0].ParamType)) and (LRttiParameters[0].ParamType.TypeKind = tkInterface) and (TRttiInterfaceType(LRttiParameters[0].ParamType).GUID = ILua) then
      begin
        // call auto setup for this class
        // LRttiMethod.Invoke(aClass, [Self]);
        LMethodAutoSetup := LRttiMethod;
      end;
      continue;
    end;

    { Check if one parameter of type ILuaContext is present }
    if (Length(LRttiParameters) = 1) and (Assigned(LRttiParameters[0].ParamType)) and (LRttiParameters[0].ParamType.TypeKind = tkInterface) and (TRttiInterfaceType(LRttiParameters[0].ParamType).GUID = ILuaContext) then
    begin
      // push closure
      LMethod.Code := LRttiMethod.CodeAddress;
      LMethod.Data := AClass;
      lua_pushlightuserdata(FState, Self);
      lua_pushlightuserdata(FState, LMethod.Code);
      lua_pushlightuserdata(FState, LMethod.Data);
      lua_pushcclosure(FState, @LuaWrapperClosure, 3);

      // add field to table
      lua_setglobal(FState, LMarshall.AsAnsi(LRttiMethod.Name).ToPointer);
    end;
  end;

  // clean up stack
  CleanStack();

  // invoke autosetup?
  if Assigned(LMethodAutoSetup) then
  begin
    // call auto setup LMethod
    LMethodAutoSetup.Invoke(AClass, [Self]);

    // clean up stack
    CleanStack();
  end;
end;

procedure TLua.RegisterRoutines(const AObject: TObject);
var
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiMethod: TRttiMethod;
  LMethodAutoSetup: TRttiMethod;
  LRttiParameters: TArray<System.Rtti.TRttiParameter>;
  LMethod: TMethod;
  LMarshall: TMarshaller;
begin
  if not Assigned(FState) then Exit;

  LRttiType := LRttiContext.GetType(AObject.ClassType);
  LMethodAutoSetup := nil;
  for LRttiMethod in LRttiType.GetMethods do
  begin
    if (LRttiMethod.MethodKind <> mkProcedure) then  continue;
    if (LRttiMethod.Visibility <> mvPublic) then continue;

    LRttiParameters := LRttiMethod.GetParameters;

    // check for public AutoSetup class function
    if SameText(LRttiMethod.Name, cLuaAutoSetup) then
    begin
      if (Length(LRttiParameters) = 1) and (Assigned(LRttiParameters[0].ParamType)) and (LRttiParameters[0].ParamType.TypeKind = tkInterface) and (TRttiInterfaceType(LRttiParameters[0].ParamType).GUID = ILua) then
      begin
        // call auto setup for this class
        LMethodAutoSetup := LRttiMethod;
      end;
      continue;
    end;

    { Check if one parameter of type ILuaContext is present }
    if (Length(LRttiParameters) = 1) and (Assigned(LRttiParameters[0].ParamType)) and (LRttiParameters[0].ParamType.TypeKind = tkInterface) and (TRttiInterfaceType(LRttiParameters[0].ParamType).GUID = ILuaContext) then
    begin
      // push closure
      LMethod.Code := LRttiMethod.CodeAddress;
      LMethod.Data := AObject;
      lua_pushlightuserdata(FState, Self);
      lua_pushlightuserdata(FState, LMethod.Code);
      lua_pushlightuserdata(FState, LMethod.Data);
      lua_pushcclosure(FState, @LuaWrapperClosure, 3);

      // add field to table
      lua_setglobal(FState, LMarshall.AsAnsi(LRttiMethod.Name).ToPointer);
    end;
  end;

  // clean up stack
  CleanStack();

  // invoke autosetup?
  if Assigned(LMethodAutoSetup) then
  begin
    // call auto setup LMethod
    LMethodAutoSetup.Invoke(AObject, [Self]);

    // clean up stack
    CleanStack();
  end;
end;

procedure TLua.RegisterRoutines(const ATables: string; const AClass: TClass; const ATableName: string);
var
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiMethod: TRttiMethod;
  LMethodAutoSetup: TRttiMethod;

  LRttiParameters: TArray<System.Rtti.TRttiParameter>;
  LMethod: TMethod;
  LMarshall: TMarshaller;
  LIndex: Integer;
  LNames: array of string;
  TblName: string;
  LI: Integer;
  LItems: TStringDynArray;
  LLastIndex: Integer;
begin
  if not Assigned(FState) then Exit;

  // init the routines table name
  if ATableName.IsEmpty then
    TblName := AClass.ClassName
  else
    TblName := ATableName;

  // parse table LNames in table.table.xxx format
  LItems := ParseTableNames(ATables);

  // init sub table LNames
  if Length(LItems) > 0 then
  begin
    SetLength(LNames, Length(LItems) + 2);

    for LI := 0 to High(LItems) do
    begin
      LNames[LI] := LItems[LI];
    end;

    LLastIndex := Length(LItems);

    // set last as table name for functions
    LNames[LLastIndex] := TblName;
    LNames[LLastIndex + 1] := TblName;
  end
  else
  begin
    SetLength(LNames, 2);
    LNames[0] := TblName;
    LNames[1] := TblName;
  end;

  // push global table to stack
  if not PushGlobalTableForSet(LNames, LIndex) then
  begin
    CleanStack();
    Exit;
  end;

  LRttiType := LRttiContext.GetType(AClass);
  LMethodAutoSetup := nil;
  for LRttiMethod in LRttiType.GetMethods do
  begin
    if (LRttiMethod.MethodKind <> mkClassProcedure) then
      continue;
    if (LRttiMethod.Visibility <> mvPublic) then
      continue;

    LRttiParameters := LRttiMethod.GetParameters;

    // check for public AutoSetup class function
    if SameText(LRttiMethod.Name, cLuaAutoSetup) then
    begin
      if (Length(LRttiParameters) = 1) and (Assigned(LRttiParameters[0].ParamType)) and (LRttiParameters[0].ParamType.TypeKind = tkInterface) and (TRttiInterfaceType(LRttiParameters[0].ParamType).GUID = ILua) then
      begin
        // call auto setup for this class
        // LRttiMethod.Invoke(aClass, [Self]);
        LMethodAutoSetup := LRttiMethod;
      end;
      continue;
    end;

    { Check if one parameter of type ILuaContext is present }
    if (Length(LRttiParameters) = 1) and (Assigned(LRttiParameters[0].ParamType)) and (LRttiParameters[0].ParamType.TypeKind = tkInterface) and (TRttiInterfaceType(LRttiParameters[0].ParamType).GUID = ILuaContext) then
    begin
      // push closure
      LMethod.Code := LRttiMethod.CodeAddress;
      LMethod.Data := AClass;
      lua_pushlightuserdata(FState, Self);
      lua_pushlightuserdata(FState, LMethod.Code);
      lua_pushlightuserdata(FState, LMethod.Data);
      lua_pushcclosure(FState, @LuaWrapperClosure, 3);

      // add field to table
      lua_setfield(FState, -2, LMarshall.AsAnsi(LRttiMethod.Name).ToPointer);
    end;
  end;

  // clean up stack
  CleanStack();

  // invoke autosetup?
  if Assigned(LMethodAutoSetup) then
  begin
    // call auto setup LMethod
    LMethodAutoSetup.Invoke(AClass, [Self]);

    // clean up stack
    CleanStack();
  end;
end;

procedure TLua.RegisterRoutines(const ATables: string; const AObject: TObject; const ATableName: string);
var
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiMethod: TRttiMethod;
  LMethodAutoSetup: TRttiMethod;
  LRttiParameters: TArray<System.Rtti.TRttiParameter>;
  LMethod: TMethod;
  LMarshall: TMarshaller;
  LIndex: Integer;
  LNames: array of string;
  TblName: string;
  LI: Integer;
  LItems: TStringDynArray;
  LLastIndex: Integer;
begin
  if not Assigned(FState) then Exit;

  // init the routines table name
  if ATableName.IsEmpty then
    TblName := AObject.ClassName
  else
    TblName := ATableName;

  // parse table LNames in table.table.xxx format
  LItems := ParseTableNames(ATables);

  // init sub table LNames
  if Length(LItems) > 0 then
    begin
      SetLength(LNames, Length(LItems) + 2);

      LLastIndex := 0;
      for LI := 0 to High(LItems) do
      begin
        LNames[LI] := LItems[LI];
        LLastIndex := LI;
      end;

      // set last as table name for functions
      LNames[LLastIndex] := TblName;
      LNames[LLastIndex + 1] := TblName;
    end
  else
    begin
      SetLength(LNames, 2);
      LNames[0] := TblName;
      LNames[1] := TblName;
    end;

  // push global table to stack
  if not PushGlobalTableForSet(LNames, LIndex) then
  begin
    CleanStack();
    Exit;
  end;

  LRttiType := LRttiContext.GetType(AObject.ClassType);
  LMethodAutoSetup := nil;
  for LRttiMethod in LRttiType.GetMethods do
  begin
    if (LRttiMethod.MethodKind <> mkProcedure) then continue;
    if (LRttiMethod.Visibility <> mvPublic) then continue;

    LRttiParameters := LRttiMethod.GetParameters;

    // check for public AutoSetup class function
    if SameText(LRttiMethod.Name, cLuaAutoSetup) then
    begin
      if (Length(LRttiParameters) = 1) and (Assigned(LRttiParameters[0].ParamType)) and (LRttiParameters[0].ParamType.TypeKind = tkInterface) and (TRttiInterfaceType(LRttiParameters[0].ParamType).GUID = ILua) then
      begin
        // call auto setup for this class
        // LRttiMethod.Invoke(aObject.ClassType, [Self]);
        LMethodAutoSetup := LRttiMethod;
      end;
      continue;
    end;

    { Check if one parameter of type ILuaContext is present }
    if (Length(LRttiParameters) = 1) and (Assigned(LRttiParameters[0].ParamType)) and (LRttiParameters[0].ParamType.TypeKind = tkInterface) and (TRttiInterfaceType(LRttiParameters[0].ParamType).GUID = ILuaContext) then
    begin
      // push closure
      LMethod.Code := LRttiMethod.CodeAddress;
      LMethod.Data := AObject;
      lua_pushlightuserdata(FState, Self);
      lua_pushlightuserdata(FState, LMethod.Code);
      lua_pushlightuserdata(FState, LMethod.Data);
      lua_pushcclosure(FState, @LuaWrapperClosure, 3);

      // add field to table
      lua_setfield(FState, -2, LMarshall.AsAnsi(LRttiMethod.Name).ToPointer);
    end;
  end;

  // clean up stack
  CleanStack();

  // invoke autosetup?
  if Assigned(LMethodAutoSetup) then
  begin
    // call auto setup LMethod
    LMethodAutoSetup.Invoke(AObject, [Self]);

    // clean up stack
    CleanStack();
  end;
end;

procedure TLua.CompileToStream(const AFilename: string; const AStream: TStream; const ACleanOutput: Boolean);
var
  LInFilename: string;
  LBundleFilename: string;
begin
  if not Assigned(FState) then Exit;

  LInFilename := AFilename;
  LBundleFilename := TPath.GetFileNameWithoutExtension(LInFilename) + '_bundle.lua';
  LBundleFilename := TPath.Combine(TPath.GetDirectoryName(LInFilename), LBundleFilename);
  Bundle(LInFilename, LBundleFilename);
  LoadFile(PChar(LBundleFilename), False);
  SaveByteCode(AStream);
  CleanStack;

  if ACleanOutput then
  begin
    if TFile.Exists(LBundleFilename) then
    begin
      TFile.Delete(LBundleFilename);
    end;
  end;
end;

procedure TLua.SetGCStepSize(const AStep: Integer);
begin
  FGCStep := AStep;
end;

function TLua.GetGCStepSize(): Integer;
begin
  Result := FGCStep;
end;

function TLua.GetGCMemoryUsed(): Integer;
begin
  Result := 0;
  if not Assigned(FState) then Exit;

  Result := lua_gc(FState, LUA_GCCOUNT, FGCStep);
end;

procedure TLua.CollectGarbage();
begin
  if not Assigned(FState) then Exit;

  lua_gc(FState, LUA_GCSTEP, FGCStep);
end;

initialization
begin
  ReportMemoryLeaksOnShutdown := True;
  SetConsoleCP(CP_UTF8);
  SetConsoleOutputCP(CP_UTF8);
  EnableVirtualTerminalProcessing();
end;

finalization
begin

end;

end.
