{============================================================================
  __  __                              ___   _     _ ™
 |  \/  | ___  _ __   ___  _ _  _  _ |   \ | |   | |
 | |\/| |/ -_)| '  \ / _ \| '_|| || || |) || |__ | |__
 |_|  |_|\___||_|_|_|\___/|_|   \_, ||___/ |____||____|
                                |__/
 In-Memory Win64 DLL Loading & Execution for Pascal

 Copyright © 2024-present tinyBigGAMES™ LLC
 All Rights Reserved.

 https://github.com/tinyBigGAMES/MemoryDLL

 BSD 3-Clause License

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

 3. Neither the name of the copyright holder nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 -----------------------------------------------------------------------------

 Summary:
   The MemoryDLL unit provides advanced functionality for loading dynamic-link
   libraries (win64 DLLs) directly from memory. This unit facilitates the
   loading of DLLs from byte arrays or memory streams, retrieval of function
   addresses within the loaded DLL, and proper unloading of the DLL module.
   Unlike traditional methods that rely on filesystem operations, MemoryDLL
   operates entirely in memory, offering a secure and efficient alternative
   for DLL management.

 Remarks:
   The MemoryDLL unit is meticulously crafted to cater to expert Pascal
   developers who require low-level control over DLL operations. By
   eliminating the dependency on the filesystem, this unit enhances security
   by preventing unauthorized access to DLL files and reduces I/O overhead,
   thereby improving application performance.

 Key Features:
   - MemoryLoadLibrary: Loads a DLL from a memory buffer, such as a byte
     array or memory stream, without writing to the disk.
   - You can then use standard win32 GetProcAddress and FreeLibrary as normal

 Implementation Details:
   1. Hook-Based Loading: Redirects calls to load a specific DLL by
      monitoring attempts to load a placeholder DLL
      (e.g., advapi32res.dll). This DLL acts as a trigger for the hook to
      intercept and handle redirection to an in-memory DLL.
   2. Placeholder DLL: The placeholder DLL, which can be any specified
      DLL file, is not embedded within the application. It is only used to
      initiate the hook process, allowing seamless redirection to the
      in-memory DLL.
   3. In-Memory Execution: The redirected DLL operates fully in memory,
      making all its functions accessible as if loaded conventionally.
      This approach avoids dependence on the filesystem, enhancing both
      performance and security.

 Usage Scenarios:
   - Embedding DLLs within the main executable for distribution, eliminating
     the need to manage separate DLL files.
   - Loading encrypted or obfuscated DLLs to enhance application security.
   - Facilitating dynamic plugin systems where plugins are provided as
     in-memory modules.

 Comprehensive documentation is provided for all public routines, types,
 variables, and internal logic within the MemoryDLL unit. This ensures that
 expert Pascal developers can effortlessly maintain, extend, and optimize
 the unit for future requirements. Additionally, inline comments elucidate
 complex operations and decision-making processes, promoting code
 readability and maintainability.

 Acknowledgment:
   This unit is based on the original MemoryDll-DllRedirect project by
   A-Normal-User, available at:
     https://github.com/A-Normal-User/MemoryDll-DllRedirect
   Credit goes to the original developer for their foundational work, which
   this unit builds upon.

-----------------------------------------------------------------------------
>>> CHANGELOG <<<

Version 0.2.0 - 2024-11-01
---------------------------
Added:
  - MemoryLoadLibrary for accessing DLL functions directly from memory.

Fixed:
  - N/A

Changed:
  - The fundamental way memory DLLs are processed. Should work better for
    now for most DLLs now. You can now use standard win32 FreeLibrary and
    GetProcAddress.

Version 0.1.0 - 2024-10-31
---------------------------
Added:
  - Initial release of MemoryDLL, featuring support for loading, freeing,
    and accessing DLL functions directly from memory.

Fixed:
  - N/A

Changed:
  - N/A

=============================================================================}

unit MemoryDLL;

{$IFDEF FPC}
  // Sets the Free Pascal Compiler (FPC) to use Delphi Unicode compatibility mode
  {$MODE DELPHIUNICODE}
{$ENDIF}

{$IFNDEF WIN64}
  // Generates a compile-time error if the target platform is not Win64
  {$MESSAGE Error 'Unsupported platform'}
{$ENDIF}

{$Z4}  // Sets the enumeration size to 4 bytes
{$A8}  // Sets the alignment for record fields to 8 bytes

interface

uses
  Windows;

const
  /// <summary>
  /// Major version of the MemoryDLL.
  /// </summary>
  /// <remarks>
  /// This represents the main version number, typically updated for significant changes or milestones.
  /// </remarks>
  MEMORYDLL_MAJOR_VERSION = '0';

  /// <summary>
  /// Minor version of the MemoryDLL.
  /// </summary>
  /// <remarks>
  /// This is incremented for smaller, incremental improvements or updates.
  /// </remarks>
  MEMORYDLL_MINOR_VERSION = '2';

  /// <summary>
  /// Patch version of the MemoryDLL.
  /// </summary>
  /// <remarks>
  /// This number increases for bug fixes or minor improvements that do not affect major or minor versions.
  /// </remarks>
  MEMORYDLL_PATCH_VERSION = '0';

  /// <summary>
  /// Full version of the MemoryDLL, formatted as Major.Minor.Patch.
  /// </summary>
  /// <remarks>
  /// This combines the major, minor, and patch versions into a single version string.
  /// </remarks>
  MEMORYDLL_VERSION = MEMORYDLL_MAJOR_VERSION + '.' + MEMORYDLL_MINOR_VERSION + '.' + MEMORYDLL_PATCH_VERSION;

/// <summary>
/// Loads a module from a memory image, emulating the behavior of the Windows API LoadLibrary function.
/// This function parses the Portable Executable (PE) format of the provided memory image, performs necessary
/// relocations, resolves imports, executes Thread Local Storage (TLS) callbacks, and initializes the module
/// by invoking its entry point.
/// </summary>
/// <param name="Data">
/// A pointer to the memory image of the module to be loaded. This memory image must conform to the PE format,
/// including valid DOS and NT headers, section headers, and correctly formatted import and export tables.
/// </param>
/// <returns>
/// Returns a handle of type THandle to the loaded module. This handle can be used with GetProcAddress to
/// retrieve function addresses exported by the module, and with FreeLibrary to unload the module from memory.
/// If the loading process fails due to invalid format, memory allocation issues, or unresolved imports,
/// the function returns 0 and sets the appropriate error code using SetLastError.
/// </returns>
/// <remarks>
/// <para>
/// This function does not rely on the filesystem and instead operates entirely in memory. It is particularly
/// useful in scenarios where loading a module from a non-standard source is required, such as loading from
/// encrypted or obfuscated data streams. However, care must be taken to ensure that the memory image is
/// correctly formatted and that all dependencies are available.
/// </para>
/// <para>
/// The caller is responsible for managing the lifecycle of the loaded module. Failure to call FreeLibrary
/// will result in memory leaks and potential resource exhaustion.
/// </para>
/// </remarks>
function MemoryLoadLibrary(const AData: Pointer): THandle; stdcall;

implementation

uses
  SysUtils,
  SyncObjs,
  Math;

const
  /// <summary>
  /// Specifies the name of the placeholder DLL resource used to initiate the hooking process.
  /// </summary>
  /// <remarks>
  /// This constant, <c>HOOK_REFERENCE_DLL</c>, represents the filename of a placeholder DLL resource, <c>advapi32res.dll</c>,
  /// embedded within the application. It serves as a trigger for the hook mechanism, allowing the application to intercept
  /// and redirect attempts to load this DLL to an actual in-memory DLL stored within the application. This approach bypasses
  /// the traditional file-based DLL loading, offering enhanced security and reducing the reliance on physical disk files.
  ///
  /// When the operating system attempts to load <c>advapi32res.dll</c>, the hook intercepts the call, redirecting it to a
  /// DLL loaded directly from memory. This facilitates dynamic DLL management in a controlled, secure memory-based context.
  /// </remarks>
  HOOK_REFERENCE_DLL = 'advapi32res.dll';

type
  // Alias for native unsigned integer type, matching the platform's pointer size
  TSizeT = NativeUInt;
  PSizeT = ^TSizeT;

  /// <summary>
  /// Structure representing a UNICODE string.
  /// </summary>
  /// <remarks>
  /// Used in Windows API calls that require UNICODE_STRING structures.
  /// </remarks>
  UNICODE_STRING = record
    Length: Word;           // Length of the string in bytes, not including the null terminator
    MaximumLength: Word;    // Total allocated length of the string buffer in bytes
    Buffer: PWideChar;      // Pointer to the wide-character string buffer
  end;
  PUNICODE_STRING = ^UNICODE_STRING;

  /// <summary>
  /// Structure representing object attributes in Windows API calls.
  /// </summary>
  OBJECT_ATTRIBUTES = record
    Length: ULONG;                     // Size of the structure in bytes
    RootDirectory: THandle;           // Handle to the root directory
    ObjectName: PUNICODE_STRING;      // Pointer to the UNICODE_STRING structure containing the object name
    Attributes: ULONG;                 // Attributes flags for the object
    SecurityDescriptor: Pointer;       // Pointer to a SECURITY_DESCRIPTOR structure
    SecurityQualityOfService: Pointer; // Pointer to a SECURITY_QUALITY_OF_SERVICE structure
  end;
  POBJECT_ATTRIBUTES = ^OBJECT_ATTRIBUTES;

  /// <summary>
  /// Structure representing I/O status block in Windows API calls.
  /// </summary>
  IO_STATUS_BLOCK = record
    case Integer of
      0: (
        Status: NTSTATUS;         // Status code indicating the result of an I/O operation
        Information: ULONG_PTR;   // Additional information about the I/O operation
      );
      1: (
        Pointer: Pointer;         // Alternate representation as a pointer
        Information2: ULONG_PTR;  // Additional information as a second pointer
      );
  end;
  PIO_STATUS_BLOCK = ^IO_STATUS_BLOCK;

  /// <summary>
  /// Function prototype for NtMapViewOfSection in ntdll.dll.
  /// </summary>
  TNtMapViewOfSection = function(
    SectionHandle: THandle;
    ProcessHandle: THandle;
    var BaseAddress: Pointer;
    ZeroBits: ULONG;
    CommitSize: ULONG;
    SectionOffset: PLARGEINTEGER;
    var ViewSize: SIZE_T;
    InheritDisposition: ULONG;
    AllocationType: ULONG;
    Win32Protect: ULONG
  ): NTSTATUS; stdcall;

  /// <summary>
  /// Function prototype for NtOpenFile in ntdll.dll.
  /// </summary>
  TNtOpenFile = function(
    FileHandle: PHANDLE;
    DesiredAccess: ACCESS_MASK;
    ObjectAttributes: POBJECT_ATTRIBUTES;
    IoStatusBlock: PIO_STATUS_BLOCK;
    ShareAccess: ULONG;
    OpenOptions: ULONG
  ): NTSTATUS; stdcall;

  /// <summary>
  /// Manages hooking of target functions by modifying their opcodes.
  /// </summary>
  THookManager = class
  private
    FOldProtect: DWORD;                  // Original memory protection flags before hooking
    FIsStart: Boolean;                   // Indicates whether the hook is active
    FOldOPCode: array[0..11] of Byte;    // Stores the original opcodes of the target function
    FNewOPCode: array[0..11] of Byte;    // Stores the new opcodes to replace the original
    FTargetFunction: FARPROC;            // Pointer to the target function being hooked
  public
    /// <summary>
    /// Initializes a new instance of the THookManager class.
    /// </summary>
    constructor Create();
    /// <summary>
    /// Cleans up the THookManager instance by stopping any active hooks.
    /// </summary>
    destructor Destroy(); override;
    /// <summary>
    /// Starts hooking a target function by replacing its opcodes with a jump to the replacement function.
    /// </summary>
    /// <param name="ALibFileName">
    /// Name of the library (DLL) containing the target function.
    /// </param>
    /// <param name="AProcName">
    /// Name of the procedure to hook.
    /// </param>
    /// <param name="ADealFunction">
    /// Pointer to the replacement function.
    /// </param>
    /// <returns>
    /// Returns True if the hook was successfully applied; otherwise, False.
    /// </returns>
    function Start(const ALibFileName, AProcName: LPCSTR; ADealFunction: FARPROC): Boolean;
    /// <summary>
    /// Stops hooking the target function by restoring its original opcodes.
    /// </summary>
    /// <returns>
    /// Returns True if the hook was successfully removed; otherwise, False.
    /// </returns>
    function Stop(): Boolean;
    /// <summary>
    /// Temporarily suspends the hook by restoring the original opcodes.
    /// </summary>
    procedure Suspended();
    /// <summary>
    /// Restores the hook by reapplying the new opcodes.
    /// </summary>
    procedure Restore();
    /// <summary>
    /// Retrieves the original function pointer before hooking.
    /// </summary>
    /// <returns>
    /// Returns the original FARPROC pointer of the target function.
    /// </returns>
    function GetOldFunction: FARPROC;
  end;

var
  NtOpenFileHook: THookManager = nil;          // Hook manager for NtOpenFile function
  NtMapViewOfSectionHook: THookManager = nil;  // Hook manager for NtMapViewOfSection function
  DllData: PByte = nil;                        // Pointer to the DLL data loaded in memory
  CriticalSection: TCriticalSection = nil;     // Critical section for thread-safe operations

/// <summary>
/// Searches for a substring within a wide-character string.
/// </summary>
/// <param name="Haystack">
/// The wide-character string to search within.
/// </param>
/// <param name="Needle">
/// The wide-character substring to search for.
/// </param>
/// <returns>
/// Returns a pointer to the first occurrence of Needle in Haystack; otherwise, returns nil.
/// </returns>
function wcsstr(const Haystack, Needle: PWideChar): PWideChar; cdecl; external 'ucrtbase.dll' name 'wcsstr';

/// <summary>
/// Copies a block of memory from Source to Destination.
/// </summary>
/// <param name="Destination">
/// Pointer to the destination buffer where the content is to be copied.
/// </param>
/// <param name="Source">
/// Pointer to the source buffer from which data is copied.
/// </param>
/// <param name="Length">
/// Number of bytes to copy.
/// </param>
procedure RtlMoveMemory(Destination: Pointer; const Source: Pointer; Length: SIZE_T); stdcall; external 'kernel32.dll';

{ THookManager }

/// <summary>
/// Constructor for THookManager.
/// Initializes the hook manager by setting up the new opcode sequence.
/// </summary>
constructor THookManager.Create();
begin
  inherited;

  FIsStart := False;

  // Initialize the new opcode sequence with a JMP instruction to the replacement function
  FNewOPCode[00] := $48;  // REX.W prefix for 64-bit operand size
  FNewOPCode[01] := $B8;  // MOV RAX, immediate
  FNewOPCode[02] := $00;  // Placeholder for immediate 64-bit address (first byte)
  FNewOPCode[03] := $00;  // Placeholder for immediate 64-bit address (second byte)
  FNewOPCode[04] := $00;  // Placeholder for immediate 64-bit address (third byte)
  FNewOPCode[05] := $00;  // Placeholder for immediate 64-bit address (fourth byte)
  FNewOPCode[06] := $00;  // Placeholder for immediate 64-bit address (fifth byte)
  FNewOPCode[07] := $00;  // Placeholder for immediate 64-bit address (sixth byte)
  FNewOPCode[08] := $00;  // Placeholder for immediate 64-bit address (seventh byte)
  FNewOPCode[09] := $00;  // Placeholder for immediate 64-bit address (eighth byte)
  FNewOPCode[10] := $FF;  // JMP [RAX]
  FNewOPCode[11] := $E0;
end;

/// <summary>
/// Destructor for THookManager.
/// Ensures that any active hooks are stopped before the hook manager is destroyed.
/// </summary>
destructor THookManager.Destroy();
begin
  if FIsStart then
    Stop(); // Restore original opcodes if hook is active

  inherited;
end;

/// <summary>
/// Starts hooking a specified procedure by replacing its opcodes with a jump to the replacement function.
/// </summary>
/// <param name="ALibFileName">
/// The name of the library (DLL) containing the target procedure.
/// </param>
/// <param name="AProcName">
/// The name of the procedure to hook.
/// </param>
/// <param name="ADealFunction">
/// Pointer to the replacement function.
/// </param>
/// <returns>
/// Returns True if the hook was successfully applied; otherwise, False.
/// </returns>
function THookManager.Start(const ALibFileName, AProcName: LPCSTR; ADealFunction: FARPROC): Boolean;
var
  LCache: Int64;
begin
  if FIsStart then
    Exit(False); // Hook already active

  // Retrieve the address of the target function from the specified library
  FTargetFunction := GetProcAddress(GetModuleHandleA(ALibFileName), AProcName);
  if FTargetFunction = nil then
    Exit(False); // Failed to find the target function

  // Change memory protection to allow writing to the target function's memory
  VirtualProtect(FTargetFunction, 12, PAGE_EXECUTE_READWRITE, FOldProtect);

  // Save the original opcodes for later restoration
  Move(Pointer(FTargetFunction)^, FOldOPCode, 12);

  // Insert the address of the replacement function into the new opcode sequence
  LCache := Int64(ADealFunction);
  Move(LCache, FNewOPCode[2], 8);

  // Overwrite the target function's opcodes with the new JMP instruction
  Move(FNewOPCode, Pointer(FTargetFunction)^, 12);

  FIsStart := True; // Indicate that the hook is active
  Result := True;
end;

/// <summary>
/// Stops the hook by restoring the original opcodes of the target function.
/// </summary>
/// <returns>
/// Returns True if the hook was successfully removed; otherwise, False.
/// </returns>
function THookManager.Stop(): Boolean;
begin
  if not FIsStart then
    Exit(False); // Hook is not active

  // Restore the original opcodes to the target function
  Move(FOldOPCode, Pointer(FTargetFunction)^, 12);
  ZeroMemory(@FOldOPCode, 12); // Clear the saved opcodes
  FIsStart := False;

  // Restore the original memory protection
  Result := VirtualProtect(FTargetFunction, 12, FOldProtect, FOldProtect);
end;

/// <summary>
/// Temporarily suspends the hook by restoring the original opcodes.
/// </summary>
procedure THookManager.Suspended();
begin
  if FIsStart then
    Move(FOldOPCode, Pointer(FTargetFunction)^, 12);
end;

/// <summary>
/// Restores the hook by reapplying the new opcodes to the target function.
/// </summary>
procedure THookManager.Restore();
begin
  if FIsStart then
    Move(FNewOPCode, Pointer(FTargetFunction)^, 12);
end;

/// <summary>
/// Retrieves the original function pointer before hooking.
/// </summary>
/// <returns>
/// Returns the original FARPROC pointer of the target function.
/// </returns>
function THookManager.GetOldFunction(): FARPROC;
begin
  Result := FTargetFunction;
end;

/// <summary>
/// Determines the appropriate memory protection flags based on section characteristics.
/// </summary>
/// <param name="Characteristics">
/// Flags describing the memory section's properties (execute, read, write).
/// </param>
/// <returns>
/// Returns the corresponding PAGE_* protection constant.
/// </returns>
function GetProtect(Characteristics: DWORD): DWORD;
begin
  if (Characteristics and IMAGE_SCN_MEM_EXECUTE) <> 0 then
  begin
    if (Characteristics and IMAGE_SCN_MEM_READ) <> 0 then
    begin
      if (Characteristics and IMAGE_SCN_MEM_WRITE) <> 0 then
        Exit(PAGE_EXECUTE_READWRITE)
      else
        Exit(PAGE_EXECUTE_READ);
    end
    else if (Characteristics and IMAGE_SCN_MEM_WRITE) <> 0 then
      Exit(PAGE_EXECUTE_WRITECOPY)
    else
      Exit(PAGE_EXECUTE);
  end
  else if (Characteristics and IMAGE_SCN_MEM_READ) <> 0 then
  begin
    if (Characteristics and IMAGE_SCN_MEM_WRITE) <> 0 then
      Exit(PAGE_READWRITE)
    else
      Exit(PAGE_READONLY);
  end
  else if (Characteristics and IMAGE_SCN_MEM_WRITE) <> 0 then
    Exit(PAGE_WRITECOPY)
  else
    Exit(PAGE_NOACCESS);
end;

/// <summary>
/// Maps a DLL into memory by allocating space and copying sections.
/// </summary>
/// <param name="ADllData">
/// Pointer to the DLL data in memory.
/// </param>
/// <param name="ABaseAddress">
/// Reference to the base address where the DLL will be loaded.
/// </param>
/// <param name="AViewSize">
/// Reference to the size of the mapped view.
/// </param>
procedure HookMapDll(const ADllData: PByte; var ABaseAddress: Pointer; var AViewSize: TSizeT);
var
  LDllMemoryBase: Int64;                  // Base address of the DLL data
  LDOSHeader: PIMAGEDOSHEADER;             // Pointer to the DOS header
  LNTHeader: PIMAGENTHEADERS64;            // Pointer to the NT headers
  LSectionHeaders: PIMAGESECTIONHEADER;    // Pointer to the section headers
  LSectionOffset: Int64;                   // Offset to the current section
  LLocation, LLpBaseAddress: Pointer;      // Temporary pointers for data copying
  LCount, I: Integer;                      // Counters
begin
  // Convert the DLL data pointer to an integer for arithmetic operations
  LDllMemoryBase := Int64(ADllData);
  LDOSHeader := PIMAGEDOSHEADER(LDllMemoryBase);

  // Verify the DOS header signature ("MZ")
  if LDOSHeader^.e_magic = IMAGE_DOS_SIGNATURE then
  begin
    // Retrieve the NT headers based on the DOS header's e_lfanew field
    LNTHeader := PIMAGENTHEADERS64(LDllMemoryBase + LDOSHeader^._lfanew);

    // Verify the NT headers signature ("PE\0\0")
    if LNTHeader^.Signature = IMAGE_NT_SIGNATURE then
    begin
      // Calculate the offset to the first section header
      LSectionOffset := LDOSHeader^._lfanew + SizeOf(IMAGE_NT_HEADERS64);

      // Allocate memory for the entire DLL image with execute-read-write permissions
      ABaseAddress := VirtualAlloc(nil, LNTHeader^.OptionalHeader.SizeOfImage, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
      AViewSize := LNTHeader^.OptionalHeader.SizeOfImage;

      // Copy the DOS header and section headers into the allocated memory
      LCount := LNTHeader^.FileHeader.NumberOfSections;
      RtlMoveMemory(ABaseAddress, ADllData, LSectionOffset + SizeOf(IMAGE_SECTION_HEADER) * LCount);

      // Protect the first 4KB of the allocated memory as read-only to prevent accidental modifications
      VirtualProtect(ADllData, $1000, PAGE_READONLY, nil);

      // Iterate through each section and map it into the allocated memory
      for I := 0 to LCount - 1 do
      begin
        LSectionHeaders := PIMAGESECTIONHEADER(LDllMemoryBase + LSectionOffset);

        if LSectionHeaders^.PointerToRawData <> 0 then
        begin
          // Only copy sections that contain actual data
          LLocation := Pointer(LDllMemoryBase + LSectionHeaders^.PointerToRawData);
          LLpBaseAddress := Pointer(Int64(ABaseAddress) + LSectionHeaders^.VirtualAddress);

          // Copy the section data into the allocated memory at the appropriate virtual address
          RtlMoveMemory(LLpBaseAddress, LLocation, LSectionHeaders^.SizeOfRawData);

          // Set the memory protection for the section based on its characteristics
          VirtualProtect(LLpBaseAddress, LSectionHeaders^.Misc.VirtualSize,
            GetProtect(LSectionHeaders^.Characteristics), nil);
        end;

        // Move to the next section header
        Inc(LSectionOffset, SizeOf(IMAGE_SECTION_HEADER));
      end;
    end;
  end;
end;

/// <summary>
/// Hooked version of NtMapViewOfSection function.
/// </summary>
/// <param name="ASectionHandle">
/// Handle to the section to map.
/// </param>
/// <param name="AProcessHandle">
/// Handle to the process in which to map the section.
/// </param>
/// <param name="ABaseAddress">
/// Reference to the base address where the section will be mapped.
/// </param>
/// <param name="AZeroBits">
/// Number of high-order address bits that must be zero.
/// </param>
/// <param name="ACommitSize">
/// Size of the committed region.
/// </param>
/// <param name="ASectionOffset">
/// Pointer to the section offset.
/// </param>
/// <param name="AViewSize">
/// Reference to the size of the view.
/// </param>
/// <param name="AInheritDisposition">
/// Inheritance options for the mapped view.
/// </param>
/// <param name="AAllocationType">
/// Type of allocation.
/// </param>
/// <param name="AWin32Protect">
/// Protection for the mapped view.
/// </param>
/// <returns>
/// Returns an NTSTATUS code indicating the result of the operation.
/// </returns>
function HookNtMapViewOfSection(
  ASectionHandle: THandle;
  AProcessHandle: THandle;
  ABaseAddress: PPVOID;
  AZeroBits: ULONG_PTR;
  ACommitSize: SIZE_T;
  ASectionOffset: PLARGEINTEGER;
  AViewSize: PSIZE_T;
  AInheritDisposition: ULONG;
  AAllocationType: ULONG;
  AWin32Protect: ULONG
): NTSTATUS; stdcall;
var
  LOldNtMapViewOfSection: TNtMapViewOfSection; // Original NtMapViewOfSection function
begin
  // Stop the current hook to prevent recursion
  NtMapViewOfSectionHook.Stop();

  if DllData = nil then
  begin
    // Retrieve the original NtMapViewOfSection function pointer
    LOldNtMapViewOfSection := TNtMapViewOfSection(NtMapViewOfSectionHook.GetOldFunction());
    // Call the original NtMapViewOfSection function with provided parameters
    Result := LOldNtMapViewOfSection(
      ASectionHandle,
      AProcessHandle,
      ABaseAddress^,
      AZeroBits,
      ACommitSize,
      ASectionOffset,
      AViewSize^,
      AInheritDisposition,
      AAllocationType,
      AWin32Protect
    );
    Exit;
  end;

  // Map the DLL into memory
  HookMapDll(DllData, ABaseAddress^, AViewSize^);
  DllData := nil; // Clear DLL data after mapping

  // Return a custom NTSTATUS code indicating successful mapping
  Result := $40000003;
end;

/// <summary>
/// Hooked version of NtOpenFile function.
/// </summary>
/// <param name="AFileHandle">
/// Pointer to the handle that receives the file handle.
/// </param>
/// <param name="ADesiredAccess">
/// Desired access for the file.
/// </param>
/// <param name="AObjectAttributes">
/// Pointer to the OBJECT_ATTRIBUTES structure.
/// </param>
/// <param name="AIoStatusBlock">
/// Pointer to the IO_STATUS_BLOCK structure.
/// </param>
/// <param name="AShareAccess">
/// Share access flags.
/// </param>
/// <param name="AOpenOptions">
/// Open options flags.
/// </param>
/// <returns>
/// Returns an NTSTATUS code indicating the result of the operation.
/// </returns>
function HookNtOpenFile(
  AFileHandle: PHANDLE;
  ADesiredAccess: ACCESS_MASK;
  AObjectAttributes: POBJECT_ATTRIBUTES;
  AIoStatusBlock: PIO_STATUS_BLOCK;
  AShareAccess: ULONG;
  AOpenOptions: ULONG
): NTSTATUS; stdcall;
var
  LResultStatus: NTSTATUS;            // Result status from the original NtOpenFile
  LOldNtOpenFile: TNtOpenFile;        // Original NtOpenFile function
begin
  // Temporarily suspend the NtOpenFile hook to avoid recursion
  NtOpenFileHook.Suspended();

  // Retrieve the original NtOpenFile function pointer
  LOldNtOpenFile := TNtOpenFile(NtOpenFileHook.GetOldFunction());

  // Call the original NtOpenFile function with provided parameters
  LResultStatus := LOldNtOpenFile(
    AFileHandle,
    ADesiredAccess,
    AObjectAttributes,
    AIoStatusBlock,
    AShareAccess,
    AOpenOptions
  );

  // Check if the ObjectName contains the hook reference DLL name
  if wcsstr(AObjectAttributes^.ObjectName^.Buffer, HOOK_REFERENCE_DLL) <> nil then
  begin
    // Stop the NtOpenFile hook and start the NtMapViewOfSection hook
    NtOpenFileHook.Stop();
    NtMapViewOfSectionHook.Start('ntdll.dll', 'NtMapViewOfSection', FARPROC(@HookNtMapViewOfSection));
    Exit(LResultStatus); // Return the original result status
  end;

  // Restore the NtOpenFile hook before returning
  NtOpenFileHook.Restore;
  Result := LResultStatus;
end;

function MemoryLoadLibrary(const AData: Pointer): THandle;
begin
  // Enter critical section to ensure thread-safe operations
  CriticalSection.Enter();
  try
    // Start hooking the NtOpenFile function in ntdll.dll with HookNtOpenFile as the replacement
    NtOpenFileHook.Start('ntdll.dll', 'NtOpenFile', @HookNtOpenFile);
    DllData := AData; // Store the DLL data pointer
    Result := LoadLibraryW(HOOK_REFERENCE_DLL); // Load the reference DLL using wide-character API
  finally
    // Leave the critical section after operations are complete
    CriticalSection.Leave();
  end;
end;

{ Initialization Section }

initialization
begin
  {$IFNDEF FPC}
    // Enable memory leak reporting on application shutdown in Delphi.
    // This helps identify any memory leaks that might occur while using this unit.
    // This directive has no effect in Free Pascal Compiler (FPC) as it is Delphi-specific.
    ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  // Configure floating-point exception handling.
  // Sets the exception mask to include floating-point overflow and invalid operation exceptions.
  // This prevents runtime errors for certain floating-point operations that would normally trigger exceptions.
  SetExceptionMask(GetExceptionMask + [exOverflow, exInvalidOp]);

  // Initialize critical section for thread-safe operations
  CriticalSection := TCriticalSection.Create();

  // Initialize hook managers for NtOpenFile and NtMapViewOfSection functions
  NtOpenFileHook := THookManager.Create();
  NtMapViewOfSectionHook := THookManager.Create();
end;

{ Finalization Section }

finalization
begin
  // Free hook managers to ensure hooks are removed and resources are released
  NtMapViewOfSectionHook.Free();
  NtOpenFileHook.Free();

  // Free the critical section object
  CriticalSection.Free();
end;

end.
