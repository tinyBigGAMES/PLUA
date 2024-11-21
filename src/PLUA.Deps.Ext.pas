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

unit PLUA.Deps.Ext;

{$I PLUA.Defines.inc}

interface

uses
  PLUA.Deps;

// macros
function  lua_isfunction(aState: Pointer; n: Integer): Boolean; inline;
function  lua_isvariable(aState: Pointer; n: Integer): Boolean; inline;
procedure lua_newtable(aState: Pointer); inline;
procedure lua_pop(aState: Pointer; n: Integer); inline;
procedure lua_getglobal(aState: Pointer; aName: PAnsiChar); inline;
procedure lua_setglobal(aState: Pointer; aName: PAnsiChar); inline;
procedure lua_pushcfunction(aState: Pointer; aFunc: lua_CFunction); inline;
procedure lua_register(aState: Pointer; aName: PAnsiChar; aFunc: lua_CFunction); inline;
function  lua_isnil(aState: Pointer; n: Integer): Boolean; inline;
function  lua_tostring(aState: Pointer; idx: Integer): string; inline;
function  luaL_dofile(aState: Pointer; aFilename: PAnsiChar): Integer; inline;
function  luaL_dostring(aState: Pointer; aStr: PAnsiChar): Integer; inline;
function  luaL_dobuffer(aState: Pointer; aBuffer: Pointer; aSize: NativeUInt; aName: PAnsiChar): Integer; inline;
function  lua_upvalueindex(i: Integer): Integer; inline;
function  luaL_checkstring(L: Plua_State; n: Integer): PAnsiChar; inline;
procedure luaL_requiref(L: Plua_State; modname: PAnsiChar; openf: lua_CFunction; glb: Integer); inline;
function  lua_istable(L: Plua_State; N: Integer): Boolean;

implementation

function lua_isfunction(aState: Pointer; n: Integer): Boolean; inline;
begin
  Result := Boolean(lua_type(aState, n) = LUA_TFUNCTION);
end;

function lua_isvariable(aState: Pointer; n: Integer): Boolean; inline;
var
  aType: Integer;
begin
  aType := lua_type(aState, n);

  if (aType = LUA_TBOOLEAN) or (aType = LUA_TLIGHTUSERDATA) or (aType = LUA_TNUMBER) or (aType = LUA_TSTRING) then
    Result := True
  else
    Result := False;
end;

procedure lua_newtable(aState: Pointer); inline;
begin
  lua_createtable(aState, 0, 0);
end;

procedure lua_pop(aState: Pointer; n: Integer); inline;
begin
  lua_settop(aState, -n - 1);
end;

procedure lua_getglobal(aState: Pointer; aName: PAnsiChar); inline;
begin
  lua_getfield(aState, LUA_GLOBALSINDEX, aName);
end;

procedure lua_setglobal(aState: Pointer; aName: PAnsiChar); inline;
begin
  lua_setfield(aState, LUA_GLOBALSINDEX, aName);
end;

procedure lua_pushcfunction(aState: Pointer; aFunc: lua_CFunction); inline;
begin
  lua_pushcclosure(aState, aFunc, 0);
end;

procedure lua_register(aState: Pointer; aName: PAnsiChar; aFunc: lua_CFunction); inline;
begin
  lua_pushcfunction(aState, aFunc);
  lua_setglobal(aState, aName);
end;

function lua_isnil(aState: Pointer; n: Integer): Boolean; inline;
begin
  Result := Boolean(lua_type(aState, n) = LUA_TNIL);
end;

function lua_tostring(aState: Pointer; idx: Integer): string; inline;
begin
  Result := string(lua_tolstring(aState, idx, nil));
end;

function luaL_dofile(aState: Pointer; aFilename: PAnsiChar): Integer; inline;
Var
  Res: Integer;
begin
  Res := luaL_loadfile(aState, aFilename);
  if Res = 0 then
    Res := lua_pcall(aState, 0, 0, 0);
  Result := Res;
end;

function luaL_dostring(aState: Pointer; aStr: PAnsiChar): Integer; inline;
Var
  Res: Integer;
begin
  Res := luaL_loadstring(aState, aStr);
  if Res = 0 then
    Res := lua_pcall(aState, 0, 0, 0);
  Result := Res;
end;

function luaL_dobuffer(aState: Pointer; aBuffer: Pointer; aSize: NativeUInt;
  aName: PAnsiChar): Integer; inline;
var
  Res: Integer;
begin
  Res := luaL_loadbuffer(aState, aBuffer, aSize, aName);
  if Res = 0 then
    Res := lua_pcall(aState, 0, 0, 0);
  Result := Res;
end;

function lua_upvalueindex(i: Integer): Integer; inline;
begin
  Result := LUA_GLOBALSINDEX - i;
end;

function luaL_checkstring(L: Plua_State; n: Integer): PAnsiChar; inline;
begin
  Result := luaL_checklstring(L, n, nil);
end;

procedure luaL_requiref(L: Plua_State; modname: PAnsiChar; openf: lua_CFunction; glb: Integer); inline;
begin
  lua_pushcfunction(L, openf);
  lua_pushstring(L, modname);
  lua_call(L, 1, 1);
  lua_getfield(L, LUA_REGISTRYINDEX, '_LOADED');
  lua_pushvalue(L, -2);
  lua_setfield(L, -2, modname);
  lua_pop(L, 1);
  if glb <> 0 then
  begin
    lua_pushvalue(L, -1);
    lua_setglobal(L, modname);
  end;
end;

function lua_istable(L: Plua_State; N: Integer): Boolean;
begin
  Result := lua_type(L, N) = LUA_TTABLE;
end;





end.
