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

unit PLUA.Deps;

{$I PLUA.Defines.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  WinApi.Windows,
  MemoryDLL;

const
  WINVER = $0501;
  LUA_LDIR = '!\lua\';
  LUA_CDIR = '!\';
  LUA_PATH_DEFAULT = '.\?.lua;' + LUA_LDIR + '?.lua;' + LUA_LDIR + '?\init.lua;';
  LUA_CPATH_DEFAULT = '.\?.dll;' + LUA_CDIR + '?.dll;' + LUA_CDIR + 'loadall.dll';
  LUA_PATH = 'LUA_PATH';
  LUA_CPATH = 'LUA_CPATH';
  LUA_INIT = 'LUA_INIT';
  LUA_DIRSEP = '\';
  LUA_PATHSEP = ';';
  LUA_PATH_MARK = '?';
  LUA_EXECDIR = '!';
  LUA_IGMARK = '-';
  LUA_PATH_CONFIG = LUA_DIRSEP + #10 + LUA_PATHSEP + #10 + LUA_PATH_MARK + #10 + LUA_EXECDIR + #10 + LUA_IGMARK + #10;
  LUAI_MAXSTACK = 65500;
  LUAI_MAXCSTACK = 8000;
  LUAI_GCPAUSE = 200;
  LUAI_GCMUL = 200;
  LUA_MAXCAPTURES = 32;
  LUA_IDSIZE = 60;
  BUFSIZ = 512;
  LUA_NUMBER_SCAN = '%lf';
  LUA_NUMBER_FMT = '%.14g';
  LUAI_MAXNUMBER2STR = 32;
  LUA_INTFRMLEN = 'l';
  LUA_VERSION_ = 'Lua 5.1';
  LUA_RELEASE = 'Lua 5.1.4';
  LUA_VERSION_NUM = 501;
  LUA_COPYRIGHT = 'Copyright (C) 1994-2008 Lua.org, PUC-Rio';
  LUA_AUTHORS = 'R. Ierusalimschy, L. H. de Figueiredo & W. Celes';
  LUA_SIGNATURE = #27'Lua';
  LUA_MULTRET = (-1);
  LUA_REGISTRYINDEX = (-10000);
  LUA_ENVIRONINDEX = (-10001);
  LUA_GLOBALSINDEX = (-10002);
  LUA_OK = 0;
  LUA_YIELD_ = 1;
  LUA_ERRRUN = 2;
  LUA_ERRSYNTAX = 3;
  LUA_ERRMEM = 4;
  LUA_ERRERR = 5;
  LUA_TNONE = (-1);
  LUA_TNIL = 0;
  LUA_TBOOLEAN = 1;
  LUA_TLIGHTUSERDATA = 2;
  LUA_TNUMBER = 3;
  LUA_TSTRING = 4;
  LUA_TTABLE = 5;
  LUA_TFUNCTION = 6;
  LUA_TUSERDATA = 7;
  LUA_TTHREAD = 8;
  LUA_MINSTACK = 20;
  LUA_GCSTOP = 0;
  LUA_GCRESTART = 1;
  LUA_GCCOLLECT = 2;
  LUA_GCCOUNT = 3;
  LUA_GCCOUNTB = 4;
  LUA_GCSTEP = 5;
  LUA_GCSETPAUSE = 6;
  LUA_GCSETSTEPMUL = 7;
  LUA_GCISRUNNING = 9;
  LUA_HOOKCALL = 0;
  LUA_HOOKRET = 1;
  LUA_HOOKLINE = 2;
  LUA_HOOKCOUNT = 3;
  LUA_HOOKTAILRET = 4;
  LUA_MASKCALL = (1 shl LUA_HOOKCALL);
  LUA_MASKRET = (1 shl LUA_HOOKRET);
  LUA_MASKLINE = (1 shl LUA_HOOKLINE);
  LUA_MASKCOUNT = (1 shl LUA_HOOKCOUNT);
  LUAJIT_VERSION = 'LuaJIT 2.1.1731601260';
  LUAJIT_VERSION_NUM = 20199;
  LUAJIT_COPYRIGHT = 'Copyright (C) 2005-2023 Mike Pall';
  LUAJIT_URL = 'https://luajit.org/';
  LUAJIT_MODE_MASK = $00ff;
  LUAJIT_MODE_OFF = $0000;
  LUAJIT_MODE_ON = $0100;
  LUAJIT_MODE_FLUSH = $0200;
  LUA_FILEHANDLE = 'FILE*';
  LUA_COLIBNAME = 'coroutine';
  LUA_MATHLIBNAME = 'math';
  LUA_STRLIBNAME = 'string';
  LUA_TABLIBNAME = 'table';
  LUA_IOLIBNAME = 'io';
  LUA_OSLIBNAME = 'os';
  LUA_LOADLIBNAME = 'package';
  LUA_DBLIBNAME = 'debug';
  LUA_BITLIBNAME = 'bit';
  LUA_JITLIBNAME = 'jit';
  LUA_FFILIBNAME = 'ffi';
  LUA_ERRFILE = (LUA_ERRERR+1);
  LUA_NOREF = (-2);
  LUA_REFNIL = (-1);

const
  LUAJIT_MODE_ENGINE = 0;
  LUAJIT_MODE_DEBUG = 1;
  LUAJIT_MODE_FUNC = 2;
  LUAJIT_MODE_ALLFUNC = 3;
  LUAJIT_MODE_ALLSUBFUNC = 4;
  LUAJIT_MODE_TRACE = 5;
  LUAJIT_MODE_WRAPCFUNC = 16;
  LUAJIT_MODE_MAX = 17;

type
  // Forward declarations
  PPUTF8Char = ^PUTF8Char;
  PNativeUInt = ^NativeUInt;
  Plua_Debug = ^lua_Debug;
  PluaL_Reg = ^luaL_Reg;
  PluaL_Buffer = ^luaL_Buffer;

  Plua_State = Pointer;
  PPlua_State = ^Plua_State;

  lua_CFunction = function(L: Plua_State): Integer; cdecl;

  lua_Reader = function(L: Plua_State; ud: Pointer; sz: PNativeUInt): PUTF8Char; cdecl;

  lua_Writer = function(L: Plua_State; const p: Pointer; sz: NativeUInt; ud: Pointer): Integer; cdecl;

  lua_Alloc = function(ud: Pointer; ptr: Pointer; osize: NativeUInt; nsize: NativeUInt): Pointer; cdecl;
  lua_Number = Double;
  Plua_Number = ^lua_Number;
  lua_Integer = NativeInt;

  lua_Hook = procedure(L: Plua_State; ar: Plua_Debug); cdecl;

  lua_Debug = record
    event: Integer;
    name: PUTF8Char;
    namewhat: PUTF8Char;
    what: PUTF8Char;
    source: PUTF8Char;
    currentline: Integer;
    nups: Integer;
    linedefined: Integer;
    lastlinedefined: Integer;
    short_src: array [0..59] of UTF8Char;
    i_ci: Integer;
  end;

  luaJIT_profile_callback = procedure(data: Pointer; L: Plua_State; samples: Integer; vmstate: Integer); cdecl;

  luaL_Reg = record
    name: PUTF8Char;
    func: lua_CFunction;
  end;

  luaL_Buffer = record
    p: PUTF8Char;
    lvl: Integer;
    L: Plua_State;
    buffer: array [0..511] of UTF8Char;
  end;

var
  lua_newstate: function(f: lua_Alloc; ud: Pointer): Plua_State; cdecl;
  lua_close: procedure(L: Plua_State); cdecl;
  lua_newthread: function(L: Plua_State): Plua_State; cdecl;
  lua_atpanic: function(L: Plua_State; panicf: lua_CFunction): lua_CFunction; cdecl;
  lua_gettop: function(L: Plua_State): Integer; cdecl;
  lua_settop: procedure(L: Plua_State; idx: Integer); cdecl;
  lua_pushvalue: procedure(L: Plua_State; idx: Integer); cdecl;
  lua_remove: procedure(L: Plua_State; idx: Integer); cdecl;
  lua_insert: procedure(L: Plua_State; idx: Integer); cdecl;
  lua_replace: procedure(L: Plua_State; idx: Integer); cdecl;
  lua_checkstack: function(L: Plua_State; sz: Integer): Integer; cdecl;
  lua_xmove: procedure(from: Plua_State; &to: Plua_State; n: Integer); cdecl;
  lua_isnumber: function(L: Plua_State; idx: Integer): Integer; cdecl;
  lua_isstring: function(L: Plua_State; idx: Integer): Integer; cdecl;
  lua_iscfunction: function(L: Plua_State; idx: Integer): Integer; cdecl;
  lua_isuserdata: function(L: Plua_State; idx: Integer): Integer; cdecl;
  lua_type: function(L: Plua_State; idx: Integer): Integer; cdecl;
  lua_typename: function(L: Plua_State; tp: Integer): PUTF8Char; cdecl;
  lua_equal: function(L: Plua_State; idx1: Integer; idx2: Integer): Integer; cdecl;
  lua_rawequal: function(L: Plua_State; idx1: Integer; idx2: Integer): Integer; cdecl;
  lua_lessthan: function(L: Plua_State; idx1: Integer; idx2: Integer): Integer; cdecl;
  lua_tonumber: function(L: Plua_State; idx: Integer): lua_Number; cdecl;
  lua_tointeger: function(L: Plua_State; idx: Integer): lua_Integer; cdecl;
  lua_toboolean: function(L: Plua_State; idx: Integer): Integer; cdecl;
  lua_tolstring: function(L: Plua_State; idx: Integer; len: PNativeUInt): PUTF8Char; cdecl;
  lua_objlen: function(L: Plua_State; idx: Integer): NativeUInt; cdecl;
  lua_tocfunction: function(L: Plua_State; idx: Integer): lua_CFunction; cdecl;
  lua_touserdata: function(L: Plua_State; idx: Integer): Pointer; cdecl;
  lua_tothread: function(L: Plua_State; idx: Integer): Plua_State; cdecl;
  lua_topointer: function(L: Plua_State; idx: Integer): Pointer; cdecl;
  lua_pushnil: procedure(L: Plua_State); cdecl;
  lua_pushnumber: procedure(L: Plua_State; n: lua_Number); cdecl;
  lua_pushinteger: procedure(L: Plua_State; n: lua_Integer); cdecl;
  lua_pushlstring: procedure(L: Plua_State; const s: PUTF8Char; l_: NativeUInt); cdecl;
  lua_pushstring: procedure(L: Plua_State; const s: PUTF8Char); cdecl;
  lua_pushvfstring: function(L: Plua_State; const fmt: PUTF8Char; argp: Pointer): PUTF8Char; cdecl;
  lua_pushfstring: function(L: Plua_State; const fmt: PUTF8Char): PUTF8Char varargs; cdecl;
  lua_pushcclosure: procedure(L: Plua_State; fn: lua_CFunction; n: Integer); cdecl;
  lua_pushboolean: procedure(L: Plua_State; b: Integer); cdecl;
  lua_pushlightuserdata: procedure(L: Plua_State; p: Pointer); cdecl;
  lua_pushthread: function(L: Plua_State): Integer; cdecl;
  lua_gettable: procedure(L: Plua_State; idx: Integer); cdecl;
  lua_getfield: procedure(L: Plua_State; idx: Integer; const k: PUTF8Char); cdecl;
  lua_rawget: procedure(L: Plua_State; idx: Integer); cdecl;
  lua_rawgeti: procedure(L: Plua_State; idx: Integer; n: Integer); cdecl;
  lua_createtable: procedure(L: Plua_State; narr: Integer; nrec: Integer); cdecl;
  lua_newuserdata: function(L: Plua_State; sz: NativeUInt): Pointer; cdecl;
  lua_getmetatable: function(L: Plua_State; objindex: Integer): Integer; cdecl;
  lua_getfenv: procedure(L: Plua_State; idx: Integer); cdecl;
  lua_settable: procedure(L: Plua_State; idx: Integer); cdecl;
  lua_setfield: procedure(L: Plua_State; idx: Integer; const k: PUTF8Char); cdecl;
  lua_rawset: procedure(L: Plua_State; idx: Integer); cdecl;
  lua_rawseti: procedure(L: Plua_State; idx: Integer; n: Integer); cdecl;
  lua_setmetatable: function(L: Plua_State; objindex: Integer): Integer; cdecl;
  lua_setfenv: function(L: Plua_State; idx: Integer): Integer; cdecl;
  lua_call: procedure(L: Plua_State; nargs: Integer; nresults: Integer); cdecl;
  lua_pcall: function(L: Plua_State; nargs: Integer; nresults: Integer; errfunc: Integer): Integer; cdecl;
  lua_cpcall: function(L: Plua_State; func: lua_CFunction; ud: Pointer): Integer; cdecl;
  lua_load: function(L: Plua_State; reader: lua_Reader; dt: Pointer; const chunkname: PUTF8Char): Integer; cdecl;
  lua_dump: function(L: Plua_State; writer: lua_Writer; data: Pointer): Integer; cdecl;
  lua_yield: function(L: Plua_State; nresults: Integer): Integer; cdecl;
  lua_resume: function(L: Plua_State; narg: Integer): Integer; cdecl;
  lua_status: function(L: Plua_State): Integer; cdecl;
  lua_gc: function(L: Plua_State; what: Integer; data: Integer): Integer; cdecl;
  lua_error: function(L: Plua_State): Integer; cdecl;
  lua_next: function(L: Plua_State; idx: Integer): Integer; cdecl;
  lua_concat: procedure(L: Plua_State; n: Integer); cdecl;
  lua_getallocf: function(L: Plua_State; ud: PPointer): lua_Alloc; cdecl;
  lua_setallocf: procedure(L: Plua_State; f: lua_Alloc; ud: Pointer); cdecl;
  lua_setlevel: procedure(from: Plua_State; &to: Plua_State); cdecl;
  lua_getstack: function(L: Plua_State; level: Integer; ar: Plua_Debug): Integer; cdecl;
  lua_getinfo: function(L: Plua_State; const what: PUTF8Char; ar: Plua_Debug): Integer; cdecl;
  lua_getlocal: function(L: Plua_State; const ar: Plua_Debug; n: Integer): PUTF8Char; cdecl;
  lua_setlocal: function(L: Plua_State; const ar: Plua_Debug; n: Integer): PUTF8Char; cdecl;
  lua_getupvalue: function(L: Plua_State; funcindex: Integer; n: Integer): PUTF8Char; cdecl;
  lua_setupvalue: function(L: Plua_State; funcindex: Integer; n: Integer): PUTF8Char; cdecl;
  lua_sethook: function(L: Plua_State; func: lua_Hook; mask: Integer; count: Integer): Integer; cdecl;
  lua_gethook: function(L: Plua_State): lua_Hook; cdecl;
  lua_gethookmask: function(L: Plua_State): Integer; cdecl;
  lua_gethookcount: function(L: Plua_State): Integer; cdecl;
  lua_upvalueid: function(L: Plua_State; idx: Integer; n: Integer): Pointer; cdecl;
  lua_upvaluejoin: procedure(L: Plua_State; idx1: Integer; n1: Integer; idx2: Integer; n2: Integer); cdecl;
  lua_loadx: function(L: Plua_State; reader: lua_Reader; dt: Pointer; const chunkname: PUTF8Char; const mode: PUTF8Char): Integer; cdecl;
  lua_version: function(L: Plua_State): Plua_Number; cdecl;
  lua_copy: procedure(L: Plua_State; fromidx: Integer; toidx: Integer); cdecl;
  lua_tonumberx: function(L: Plua_State; idx: Integer; isnum: PInteger): lua_Number; cdecl;
  lua_tointegerx: function(L: Plua_State; idx: Integer; isnum: PInteger): lua_Integer; cdecl;
  lua_isyieldable: function(L: Plua_State): Integer; cdecl;
  luaJIT_setmode: function(L: Plua_State; idx: Integer; mode: Integer): Integer; cdecl;
  luaJIT_profile_start: procedure(L: Plua_State; const mode: PUTF8Char; cb: luaJIT_profile_callback; data: Pointer); cdecl;
  luaJIT_profile_stop: procedure(L: Plua_State); cdecl;
  luaJIT_profile_dumpstack: function(L: Plua_State; const fmt: PUTF8Char; depth: Integer; len: PNativeUInt): PUTF8Char; cdecl;
  luaJIT_version_2_1_1731601260: procedure(); cdecl;
  luaopen_base: function(L: Plua_State): Integer; cdecl;
  luaopen_math: function(L: Plua_State): Integer; cdecl;
  luaopen_string: function(L: Plua_State): Integer; cdecl;
  luaopen_table: function(L: Plua_State): Integer; cdecl;
  luaopen_io: function(L: Plua_State): Integer; cdecl;
  luaopen_os: function(L: Plua_State): Integer; cdecl;
  luaopen_package: function(L: Plua_State): Integer; cdecl;
  luaopen_debug: function(L: Plua_State): Integer; cdecl;
  luaopen_bit: function(L: Plua_State): Integer; cdecl;
  luaopen_jit: function(L: Plua_State): Integer; cdecl;
  luaopen_ffi: function(L: Plua_State): Integer; cdecl;
  luaopen_string_buffer: function(L: Plua_State): Integer; cdecl;
  luaL_openlibs: procedure(L: Plua_State); cdecl;
  luaL_openlib: procedure(L: Plua_State; const libname: PUTF8Char; const l_: PluaL_Reg; nup: Integer); cdecl;
  luaL_register: procedure(L: Plua_State; const libname: PUTF8Char; const l_: PluaL_Reg); cdecl;
  luaL_getmetafield: function(L: Plua_State; obj: Integer; const e: PUTF8Char): Integer; cdecl;
  luaL_callmeta: function(L: Plua_State; obj: Integer; const e: PUTF8Char): Integer; cdecl;
  luaL_typerror: function(L: Plua_State; narg: Integer; const tname: PUTF8Char): Integer; cdecl;
  luaL_argerror: function(L: Plua_State; numarg: Integer; const extramsg: PUTF8Char): Integer; cdecl;
  luaL_checklstring: function(L: Plua_State; numArg: Integer; l_: PNativeUInt): PUTF8Char; cdecl;
  luaL_optlstring: function(L: Plua_State; numArg: Integer; const def: PUTF8Char; l_: PNativeUInt): PUTF8Char; cdecl;
  luaL_checknumber: function(L: Plua_State; numArg: Integer): lua_Number; cdecl;
  luaL_optnumber: function(L: Plua_State; nArg: Integer; def: lua_Number): lua_Number; cdecl;
  luaL_checkinteger: function(L: Plua_State; numArg: Integer): lua_Integer; cdecl;
  luaL_optinteger: function(L: Plua_State; nArg: Integer; def: lua_Integer): lua_Integer; cdecl;
  luaL_checkstack: procedure(L: Plua_State; sz: Integer; const msg: PUTF8Char); cdecl;
  luaL_checktype: procedure(L: Plua_State; narg: Integer; t: Integer); cdecl;
  luaL_checkany: procedure(L: Plua_State; narg: Integer); cdecl;
  luaL_newmetatable: function(L: Plua_State; const tname: PUTF8Char): Integer; cdecl;
  luaL_checkudata: function(L: Plua_State; ud: Integer; const tname: PUTF8Char): Pointer; cdecl;
  luaL_where: procedure(L: Plua_State; lvl: Integer); cdecl;
  luaL_error: function(L: Plua_State; const fmt: PUTF8Char): Integer varargs; cdecl;
  luaL_checkoption: function(L: Plua_State; narg: Integer; const def: PUTF8Char; lst: PPUTF8Char): Integer; cdecl;
  luaL_ref: function(L: Plua_State; t: Integer): Integer; cdecl;
  luaL_unref: procedure(L: Plua_State; t: Integer; ref: Integer); cdecl;
  luaL_loadfile: function(L: Plua_State; const filename: PUTF8Char): Integer; cdecl;
  luaL_loadbuffer: function(L: Plua_State; const buff: PUTF8Char; sz: NativeUInt; const name: PUTF8Char): Integer; cdecl;
  luaL_loadstring: function(L: Plua_State; const s: PUTF8Char): Integer; cdecl;
  luaL_newstate: function(): Plua_State; cdecl;
  luaL_gsub: function(L: Plua_State; const s: PUTF8Char; const p: PUTF8Char; const r: PUTF8Char): PUTF8Char; cdecl;
  luaL_findtable: function(L: Plua_State; idx: Integer; const fname: PUTF8Char; szhint: Integer): PUTF8Char; cdecl;
  luaL_fileresult: function(L: Plua_State; stat: Integer; const fname: PUTF8Char): Integer; cdecl;
  luaL_execresult: function(L: Plua_State; stat: Integer): Integer; cdecl;
  luaL_loadfilex: function(L: Plua_State; const filename: PUTF8Char; const mode: PUTF8Char): Integer; cdecl;
  luaL_loadbufferx: function(L: Plua_State; const buff: PUTF8Char; sz: NativeUInt; const name: PUTF8Char; const mode: PUTF8Char): Integer; cdecl;
  luaL_traceback: procedure(L: Plua_State; L1: Plua_State; const msg: PUTF8Char; level: Integer); cdecl;
  luaL_setfuncs: procedure(L: Plua_State; const l_: PluaL_Reg; nup: Integer); cdecl;
  luaL_pushmodule: procedure(L: Plua_State; const modname: PUTF8Char; sizehint: Integer); cdecl;
  luaL_testudata: function(L: Plua_State; ud: Integer; const tname: PUTF8Char): Pointer; cdecl;
  luaL_setmetatable: procedure(L: Plua_State; const tname: PUTF8Char); cdecl;
  luaL_buffinit: procedure(L: Plua_State; B: PluaL_Buffer); cdecl;
  luaL_prepbuffer: function(B: PluaL_Buffer): PUTF8Char; cdecl;
  luaL_addlstring: procedure(B: PluaL_Buffer; const s: PUTF8Char; l: NativeUInt); cdecl;
  luaL_addstring: procedure(B: PluaL_Buffer; const s: PUTF8Char); cdecl;
  luaL_addvalue: procedure(B: PluaL_Buffer); cdecl;
  luaL_pushresult: procedure(B: PluaL_Buffer); cdecl;

procedure GetExports(const aDLLHandle: THandle);

implementation

procedure GetExports(const aDLLHandle: THandle);
begin
  if aDllHandle = 0 then Exit;
  lua_atpanic := GetProcAddress(aDLLHandle, 'lua_atpanic');
  lua_call := GetProcAddress(aDLLHandle, 'lua_call');
  lua_checkstack := GetProcAddress(aDLLHandle, 'lua_checkstack');
  lua_close := GetProcAddress(aDLLHandle, 'lua_close');
  lua_concat := GetProcAddress(aDLLHandle, 'lua_concat');
  lua_copy := GetProcAddress(aDLLHandle, 'lua_copy');
  lua_cpcall := GetProcAddress(aDLLHandle, 'lua_cpcall');
  lua_createtable := GetProcAddress(aDLLHandle, 'lua_createtable');
  lua_dump := GetProcAddress(aDLLHandle, 'lua_dump');
  lua_equal := GetProcAddress(aDLLHandle, 'lua_equal');
  lua_error := GetProcAddress(aDLLHandle, 'lua_error');
  lua_gc := GetProcAddress(aDLLHandle, 'lua_gc');
  lua_getallocf := GetProcAddress(aDLLHandle, 'lua_getallocf');
  lua_getfenv := GetProcAddress(aDLLHandle, 'lua_getfenv');
  lua_getfield := GetProcAddress(aDLLHandle, 'lua_getfield');
  lua_gethook := GetProcAddress(aDLLHandle, 'lua_gethook');
  lua_gethookcount := GetProcAddress(aDLLHandle, 'lua_gethookcount');
  lua_gethookmask := GetProcAddress(aDLLHandle, 'lua_gethookmask');
  lua_getinfo := GetProcAddress(aDLLHandle, 'lua_getinfo');
  lua_getlocal := GetProcAddress(aDLLHandle, 'lua_getlocal');
  lua_getmetatable := GetProcAddress(aDLLHandle, 'lua_getmetatable');
  lua_getstack := GetProcAddress(aDLLHandle, 'lua_getstack');
  lua_gettable := GetProcAddress(aDLLHandle, 'lua_gettable');
  lua_gettop := GetProcAddress(aDLLHandle, 'lua_gettop');
  lua_getupvalue := GetProcAddress(aDLLHandle, 'lua_getupvalue');
  lua_insert := GetProcAddress(aDLLHandle, 'lua_insert');
  lua_iscfunction := GetProcAddress(aDLLHandle, 'lua_iscfunction');
  lua_isnumber := GetProcAddress(aDLLHandle, 'lua_isnumber');
  lua_isstring := GetProcAddress(aDLLHandle, 'lua_isstring');
  lua_isuserdata := GetProcAddress(aDLLHandle, 'lua_isuserdata');
  lua_isyieldable := GetProcAddress(aDLLHandle, 'lua_isyieldable');
  lua_lessthan := GetProcAddress(aDLLHandle, 'lua_lessthan');
  lua_load := GetProcAddress(aDLLHandle, 'lua_load');
  lua_loadx := GetProcAddress(aDLLHandle, 'lua_loadx');
  lua_newstate := GetProcAddress(aDLLHandle, 'lua_newstate');
  lua_newthread := GetProcAddress(aDLLHandle, 'lua_newthread');
  lua_newuserdata := GetProcAddress(aDLLHandle, 'lua_newuserdata');
  lua_next := GetProcAddress(aDLLHandle, 'lua_next');
  lua_objlen := GetProcAddress(aDLLHandle, 'lua_objlen');
  lua_pcall := GetProcAddress(aDLLHandle, 'lua_pcall');
  lua_pushboolean := GetProcAddress(aDLLHandle, 'lua_pushboolean');
  lua_pushcclosure := GetProcAddress(aDLLHandle, 'lua_pushcclosure');
  lua_pushfstring := GetProcAddress(aDLLHandle, 'lua_pushfstring');
  lua_pushinteger := GetProcAddress(aDLLHandle, 'lua_pushinteger');
  lua_pushlightuserdata := GetProcAddress(aDLLHandle, 'lua_pushlightuserdata');
  lua_pushlstring := GetProcAddress(aDLLHandle, 'lua_pushlstring');
  lua_pushnil := GetProcAddress(aDLLHandle, 'lua_pushnil');
  lua_pushnumber := GetProcAddress(aDLLHandle, 'lua_pushnumber');
  lua_pushstring := GetProcAddress(aDLLHandle, 'lua_pushstring');
  lua_pushthread := GetProcAddress(aDLLHandle, 'lua_pushthread');
  lua_pushvalue := GetProcAddress(aDLLHandle, 'lua_pushvalue');
  lua_pushvfstring := GetProcAddress(aDLLHandle, 'lua_pushvfstring');
  lua_rawequal := GetProcAddress(aDLLHandle, 'lua_rawequal');
  lua_rawget := GetProcAddress(aDLLHandle, 'lua_rawget');
  lua_rawgeti := GetProcAddress(aDLLHandle, 'lua_rawgeti');
  lua_rawset := GetProcAddress(aDLLHandle, 'lua_rawset');
  lua_rawseti := GetProcAddress(aDLLHandle, 'lua_rawseti');
  lua_remove := GetProcAddress(aDLLHandle, 'lua_remove');
  lua_replace := GetProcAddress(aDLLHandle, 'lua_replace');
  lua_resume := GetProcAddress(aDLLHandle, 'lua_resume');
  lua_setallocf := GetProcAddress(aDLLHandle, 'lua_setallocf');
  lua_setfenv := GetProcAddress(aDLLHandle, 'lua_setfenv');
  lua_setfield := GetProcAddress(aDLLHandle, 'lua_setfield');
  lua_sethook := GetProcAddress(aDLLHandle, 'lua_sethook');
  lua_setlevel := GetProcAddress(aDLLHandle, 'lua_setlevel');
  lua_setlocal := GetProcAddress(aDLLHandle, 'lua_setlocal');
  lua_setmetatable := GetProcAddress(aDLLHandle, 'lua_setmetatable');
  lua_settable := GetProcAddress(aDLLHandle, 'lua_settable');
  lua_settop := GetProcAddress(aDLLHandle, 'lua_settop');
  lua_setupvalue := GetProcAddress(aDLLHandle, 'lua_setupvalue');
  lua_status := GetProcAddress(aDLLHandle, 'lua_status');
  lua_toboolean := GetProcAddress(aDLLHandle, 'lua_toboolean');
  lua_tocfunction := GetProcAddress(aDLLHandle, 'lua_tocfunction');
  lua_tointeger := GetProcAddress(aDLLHandle, 'lua_tointeger');
  lua_tointegerx := GetProcAddress(aDLLHandle, 'lua_tointegerx');
  lua_tolstring := GetProcAddress(aDLLHandle, 'lua_tolstring');
  lua_tonumber := GetProcAddress(aDLLHandle, 'lua_tonumber');
  lua_tonumberx := GetProcAddress(aDLLHandle, 'lua_tonumberx');
  lua_topointer := GetProcAddress(aDLLHandle, 'lua_topointer');
  lua_tothread := GetProcAddress(aDLLHandle, 'lua_tothread');
  lua_touserdata := GetProcAddress(aDLLHandle, 'lua_touserdata');
  lua_type := GetProcAddress(aDLLHandle, 'lua_type');
  lua_typename := GetProcAddress(aDLLHandle, 'lua_typename');
  lua_upvalueid := GetProcAddress(aDLLHandle, 'lua_upvalueid');
  lua_upvaluejoin := GetProcAddress(aDLLHandle, 'lua_upvaluejoin');
  lua_version := GetProcAddress(aDLLHandle, 'lua_version');
  lua_xmove := GetProcAddress(aDLLHandle, 'lua_xmove');
  lua_yield := GetProcAddress(aDLLHandle, 'lua_yield');
  luaJIT_profile_dumpstack := GetProcAddress(aDLLHandle, 'luaJIT_profile_dumpstack');
  luaJIT_profile_start := GetProcAddress(aDLLHandle, 'luaJIT_profile_start');
  luaJIT_profile_stop := GetProcAddress(aDLLHandle, 'luaJIT_profile_stop');
  luaJIT_setmode := GetProcAddress(aDLLHandle, 'luaJIT_setmode');
  luaJIT_version_2_1_1731601260 := GetProcAddress(aDLLHandle, 'luaJIT_version_2_1_1731601260');
  luaL_addlstring := GetProcAddress(aDLLHandle, 'luaL_addlstring');
  luaL_addstring := GetProcAddress(aDLLHandle, 'luaL_addstring');
  luaL_addvalue := GetProcAddress(aDLLHandle, 'luaL_addvalue');
  luaL_argerror := GetProcAddress(aDLLHandle, 'luaL_argerror');
  luaL_buffinit := GetProcAddress(aDLLHandle, 'luaL_buffinit');
  luaL_callmeta := GetProcAddress(aDLLHandle, 'luaL_callmeta');
  luaL_checkany := GetProcAddress(aDLLHandle, 'luaL_checkany');
  luaL_checkinteger := GetProcAddress(aDLLHandle, 'luaL_checkinteger');
  luaL_checklstring := GetProcAddress(aDLLHandle, 'luaL_checklstring');
  luaL_checknumber := GetProcAddress(aDLLHandle, 'luaL_checknumber');
  luaL_checkoption := GetProcAddress(aDLLHandle, 'luaL_checkoption');
  luaL_checkstack := GetProcAddress(aDLLHandle, 'luaL_checkstack');
  luaL_checktype := GetProcAddress(aDLLHandle, 'luaL_checktype');
  luaL_checkudata := GetProcAddress(aDLLHandle, 'luaL_checkudata');
  luaL_error := GetProcAddress(aDLLHandle, 'luaL_error');
  luaL_execresult := GetProcAddress(aDLLHandle, 'luaL_execresult');
  luaL_fileresult := GetProcAddress(aDLLHandle, 'luaL_fileresult');
  luaL_findtable := GetProcAddress(aDLLHandle, 'luaL_findtable');
  luaL_getmetafield := GetProcAddress(aDLLHandle, 'luaL_getmetafield');
  luaL_gsub := GetProcAddress(aDLLHandle, 'luaL_gsub');
  luaL_loadbuffer := GetProcAddress(aDLLHandle, 'luaL_loadbuffer');
  luaL_loadbufferx := GetProcAddress(aDLLHandle, 'luaL_loadbufferx');
  luaL_loadfile := GetProcAddress(aDLLHandle, 'luaL_loadfile');
  luaL_loadfilex := GetProcAddress(aDLLHandle, 'luaL_loadfilex');
  luaL_loadstring := GetProcAddress(aDLLHandle, 'luaL_loadstring');
  luaL_newmetatable := GetProcAddress(aDLLHandle, 'luaL_newmetatable');
  luaL_newstate := GetProcAddress(aDLLHandle, 'luaL_newstate');
  luaL_openlib := GetProcAddress(aDLLHandle, 'luaL_openlib');
  luaL_openlibs := GetProcAddress(aDLLHandle, 'luaL_openlibs');
  luaL_optinteger := GetProcAddress(aDLLHandle, 'luaL_optinteger');
  luaL_optlstring := GetProcAddress(aDLLHandle, 'luaL_optlstring');
  luaL_optnumber := GetProcAddress(aDLLHandle, 'luaL_optnumber');
  luaL_prepbuffer := GetProcAddress(aDLLHandle, 'luaL_prepbuffer');
  luaL_pushmodule := GetProcAddress(aDLLHandle, 'luaL_pushmodule');
  luaL_pushresult := GetProcAddress(aDLLHandle, 'luaL_pushresult');
  luaL_ref := GetProcAddress(aDLLHandle, 'luaL_ref');
  luaL_register := GetProcAddress(aDLLHandle, 'luaL_register');
  luaL_setfuncs := GetProcAddress(aDLLHandle, 'luaL_setfuncs');
  luaL_setmetatable := GetProcAddress(aDLLHandle, 'luaL_setmetatable');
  luaL_testudata := GetProcAddress(aDLLHandle, 'luaL_testudata');
  luaL_traceback := GetProcAddress(aDLLHandle, 'luaL_traceback');
  luaL_typerror := GetProcAddress(aDLLHandle, 'luaL_typerror');
  luaL_unref := GetProcAddress(aDLLHandle, 'luaL_unref');
  luaL_where := GetProcAddress(aDLLHandle, 'luaL_where');
  luaopen_base := GetProcAddress(aDLLHandle, 'luaopen_base');
  luaopen_bit := GetProcAddress(aDLLHandle, 'luaopen_bit');
  luaopen_debug := GetProcAddress(aDLLHandle, 'luaopen_debug');
  luaopen_ffi := GetProcAddress(aDLLHandle, 'luaopen_ffi');
  luaopen_io := GetProcAddress(aDLLHandle, 'luaopen_io');
  luaopen_jit := GetProcAddress(aDLLHandle, 'luaopen_jit');
  luaopen_math := GetProcAddress(aDLLHandle, 'luaopen_math');
  luaopen_os := GetProcAddress(aDLLHandle, 'luaopen_os');
  luaopen_package := GetProcAddress(aDLLHandle, 'luaopen_package');
  luaopen_string := GetProcAddress(aDLLHandle, 'luaopen_string');
  luaopen_string_buffer := GetProcAddress(aDLLHandle, 'luaopen_string_buffer');
  luaopen_table := GetProcAddress(aDLLHandle, 'luaopen_table');
end;

{$REGION ' DLL LOADER '}
{$R PLUA.Deps.res}

var
  DepsDLLHandle: THandle = 0;

procedure LoadDLL();
var
  LResStream: TResourceStream;

  function f1698f73a70b4b1da0d46bbd7e4944c7(): string;
  const
    CValue = 'b87deef5bbfd43c3a07379e26f4dec9b';
  begin
    Result := CValue;
  end;

  procedure AbortDLL();
  begin
    Halt;
  end;

begin
  // load deps DLL
  if DepsDLLHandle <> 0 then Exit;
  if not Boolean((FindResource(HInstance, PChar(f1698f73a70b4b1da0d46bbd7e4944c7()), RT_RCDATA) <> 0)) then AbortDLL();
  LResStream := TResourceStream.Create(HInstance, f1698f73a70b4b1da0d46bbd7e4944c7(), RT_RCDATA);
  try
    DepsDLLHandle := MemoryDLL.MemoryLoadLibrary(LResStream.Memory);
    if DepsDLLHandle = 0 then AbortDLL();
    GetExports(DepsDLLHandle);    
  finally
    LResStream.Free();
  end;
end;

procedure UnloadDLL();
begin
  // unload deps DLL
  if DepsDLLHandle <> 0 then
  begin
    FreeLibrary(DepsDLLHandle);
    DepsDLLHandle := 0;
  end;
end;

initialization
begin
  // turn on memory leak detection
  ReportMemoryLeaksOnShutdown := True;

  // load allegro DLL
  LoadDLL();
end;

finalization
begin
  // shutdown allegro DLL
  UnloadDLL();
end;
{$ENDREGION}

end.
