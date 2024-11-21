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

program Testbed;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  PLUA.Deps in '..\..\src\PLUA.Deps.pas',
  UTestbed in 'UTestbed.pas',
  PLUA.Deps.Ext in '..\..\src\PLUA.Deps.Ext.pas',
  PLUA in '..\..\src\PLUA.pas',
  PLUA.Debugger in '..\..\src\PLUA.Debugger.pas',
  PLUA.Common in '..\..\src\PLUA.Common.pas',
  UFunctions in 'UFunctions.pas';

begin
  try
    RunTests();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
