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

{$I PLUA.Defines.inc}

unit PLUA.Common;

interface

uses
  WinApi.Windows,
  System.SysUtils;

procedure Pause();
function  AsUTF8(const AText: string): Pointer;
function  EnableVirtualTerminalProcessing(): DWORD;
function  ResourceExists(aInstance: THandle; const aResName: string): Boolean;
function  HasConsoleOutput: Boolean;
function  GetPhysicalProcessorCount(): DWORD;
procedure GetConsoleSize(AWidth: PInteger; AHeight: PInteger);
function  TextToDelphiArray(const AInputText: string): string;
procedure Print(const AText: string; const AArgs: array of const);
procedure PrintLn(const AText: string; const AArgs: array of const);

implementation

var
  Marshaller: TMarshaller;

procedure Pause();
begin
  PrintLn('', []);
  Print('Press ENTER to continue...', []);
  ReadLn;
  PrintLn('', []);
end;

function AsUTF8(const AText: string): Pointer;
begin
  Result := Marshaller.AsUtf8(AText).ToPointer;
end;

function EnableVirtualTerminalProcessing(): DWORD;
var
  HOut: THandle;
  LMode: DWORD;
begin
  HOut := GetStdHandle(STD_OUTPUT_HANDLE);
  if HOut = INVALID_HANDLE_VALUE then
  begin
    Result := GetLastError;
    Exit;
  end;

  if not GetConsoleMode(HOut, LMode) then
  begin
    Result := GetLastError;
    Exit;
  end;

  LMode := LMode or ENABLE_VIRTUAL_TERMINAL_PROCESSING;
  if not SetConsoleMode(HOut, LMode) then
  begin
    Result := GetLastError;
    Exit;
  end;

  Result := 0;  // Success
end;

function ResourceExists(aInstance: THandle; const aResName: string): Boolean;
begin
  Result := Boolean((FindResource(aInstance, PChar(aResName), RT_RCDATA) <> 0));
end;

function HasConsoleOutput: Boolean;
var
  Stdout: THandle;
begin
  Stdout := GetStdHandle(Std_Output_Handle);
  Win32Check(Stdout <> Invalid_Handle_Value);
  Result := Stdout <> 0;
end;

function GetPhysicalProcessorCount(): DWORD;
var
  BufferSize: DWORD;
  Buffer: PSYSTEM_LOGICAL_PROCESSOR_INFORMATION;
  ProcessorInfo: PSYSTEM_LOGICAL_PROCESSOR_INFORMATION;
  Offset: DWORD;
begin
  Result := 0;
  BufferSize := 0;

  // Call GetLogicalProcessorInformation with buffer size set to 0 to get required buffer size
  if not GetLogicalProcessorInformation(nil, BufferSize) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
  begin
    // Allocate buffer
    GetMem(Buffer, BufferSize);
    try
      // Call GetLogicalProcessorInformation again with allocated buffer
      if GetLogicalProcessorInformation(Buffer, BufferSize) then
      begin
        ProcessorInfo := Buffer;
        Offset := 0;

        // Loop through processor information to count physical processors
        while Offset + SizeOf(SYSTEM_LOGICAL_PROCESSOR_INFORMATION) <= BufferSize do
        begin
          if ProcessorInfo.Relationship = RelationProcessorCore then
            Inc(Result);

          Inc(ProcessorInfo);
          Inc(Offset, SizeOf(SYSTEM_LOGICAL_PROCESSOR_INFORMATION));
        end;
      end;
    finally
      FreeMem(Buffer);
    end;
  end;
end;

procedure  GetConsoleSize(AWidth: PInteger; AHeight: PInteger);
var
  LConsoleInfo: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), LConsoleInfo);
  if Assigned(AWidth) then
    AWidth^ := LConsoleInfo.dwSize.X;

  if Assigned(AHeight) then
  AHeight^ := LConsoleInfo.dwSize.Y;
end;

function TextToDelphiArray(const AInputText: string): string;
var
  I: Integer;
  LLineLength: Integer;
  LOutput: string;
begin
  LOutput := 'const cTEXT : array[1..' + IntToStr(Length(AInputText)) + '] of Byte = (' + sLineBreak;
  LLineLength := 0;

  // Loop through each character in the input text
  for I := 1 to Length(AInputText) do
  begin
    // Add the byte in hexadecimal format, but add the comma only if it's not the first element
    if I > 1 then
      if LLineLength > 0 then
        LOutput := LOutput + ', ';  // Add a comma only after the first byte

    LOutput := LOutput + '$' + IntToHex(Ord(AInputText[I]), 2);

    // Add a line break after 80 characters (including the comma and space)
    LLineLength := LLineLength + 5; // Each entry is 5 characters long ($xx, including comma)
    if LLineLength > 80-5 then
    begin
      LOutput := LOutput + ',' + sLineBreak;
      LLineLength := 0;
    end;
  end;

  // Add closing parenthesis and semicolon after the array
  LOutput := LOutput + sLineBreak + ');';
  Result := LOutput;
end;

procedure Print(const AText: string; const AArgs: array of const);
begin
  if not HasConsoleOutput() then Exit;
  Write(Format(AText, AArgs));
end;

procedure PrintLn(const AText: string; const AArgs: array of const);
begin
  if not HasConsoleOutput() then Exit;
  WriteLn(Format(AText, AArgs));
end;

initialization
begin
end;

finalization
begin
end;

end.
