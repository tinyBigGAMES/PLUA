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

{
  Description:
  This unit demonstrates the integration of Lua scripting into Delphi applications. It provides several
  examples to showcase Lua state management, variable interaction, script execution, debugging,
  and advanced features like module imports and memory buffer handling.

  Audience:
  Professional Delphi developers who are embedding Lua scripting into their projects and require
  comprehensive examples of different scenarios.

  Overview:
  - Example01: Basic Lua state lifecycle.
  - Example02: Managing Lua scripts with the TLua class.
  - Example03: Variable interaction between Lua and Delphi.
  - Example04: Registering and calling Delphi routines from Lua.
  - Example05: Using Lua modules with "require".
  - Example06: Using Lua modules with "import".
  - Example07: Debugging Lua scripts.
  - Example08: Compiling Lua scripts to memory buffers.
}
unit UTestbed;

interface

{
  RunTests:
  The main entry point for executing any of the provided examples. The example to be run is selected
  by modifying the `LNum` variable. This routine acts as a launcher for the examples in the unit.
}
procedure RunTests();

implementation

uses
  System.SysUtils,      // Provides exception handling and string utilities
  System.IOUtils,       // For file path and directory manipulation
  System.Classes,       // For stream handling (e.g., TMemoryStream)
  PLUA.Common,          // Common utilities for PLUA library
  PLUA.Deps,            // Dependency handling for PLUA
  PLUA.Deps.Ext,        // Extended dependencies for PLUA
  PLUA,                 // Main PLUA library for Lua integration
  UFunctions;           // Contains native Lua routines registered with Delphi

{ ---------------------------- Example Procedures ---------------------------- }

{
  Example01:
  Purpose:
  - Demonstrates creating a Lua state, loading Lua libraries, executing a simple script, and closing the state.
  - Introduces the basic lifecycle of a Lua state.

  Steps:
  1. Create a Lua state using `luaL_newstate`.
  2. Load Lua's standard libraries with `luaL_openlibs`.
  3. Execute a Lua script directly using `luaL_dostring`.
  4. Close the Lua state using `lua_close` to release resources.
}
procedure Example01();
var
  LLuaState: Plua_State; // Pointer to Lua state
begin
  LLuaState := luaL_newstate();          // Create a new Lua state
  luaL_openlibs(LLuaState);             // Load standard Lua libraries
  luaL_dostring(LLuaState, 'print(''Hello, World!'')'); // Execute Lua script
  lua_close(LLuaState);                 // Close the Lua state
end;

{
  Example02:
  Purpose:
  - Demonstrates the use of the `TLua` class for loading and executing Lua scripts from strings, files, and buffers.
  - Explores AutoRun behavior and script execution control.

  Steps:
  1. Create a `TLua` instance.
  2. Add search paths for Lua modules using `AddSearchPath`.
  3. Load Lua scripts from strings, files, and buffers.
  4. Execute scripts manually if AutoRun is disabled.
  5. Handle exceptions and release resources.
}
procedure Example02();
var
  LLua: TLua;             // Lua wrapper object
  LBuffer: TStringStream; // Memory buffer for Lua script
begin
  LLua := TLua.Create();
  try
    try
      LLua.AddSearchPath('.\res\scripts'); // Add search paths for Lua modules

      // Load and execute Lua script directly from a string with AutoRun enabled
      PrintLn('LoadString, AutoRun = True', []);
      PrintLn('---------------------------', []);
      LLua.LoadString('print("Hello World! (AutoRun)")');

      // Load a Lua script string without AutoRun and execute it manually
      PrintLn('LoadString, AutoRun = False', []);
      PrintLn('---------------------------', []);
      LLua.LoadString('print("Hello World! (No AutoRun)")', False);
      LLua.Run; // Execute the script manually

      // Load a Lua script from a file and execute it automatically
      PrintLn('LoadFile, AutoRun = True', []);
      PrintLn('---------------------------', []);
      LLua.LoadFile('Example01.lua');

      // Load a Lua script from a file without AutoRun and execute it manually
      PrintLn('LoadFile, AutoRun = False', []);
      PrintLn('---------------------------', []);
      LLua.LoadFile('.\res\scripts\Example01.lua', False);
      LLua.Run;

      // Load Lua script from a memory buffer
      LBuffer := TStringStream.Create('print("Lua running from a buffer!")');
      try
        // Load and execute Lua script from the buffer with AutoRun enabled
        PrintLn('LoadBuffer, AutoRun = True', []);
        PrintLn('---------------------------', []);
        LLua.LoadBuffer(LBuffer.Memory, LBuffer.Size);

        // Load Lua script from the buffer without AutoRun and execute it manually
        PrintLn('LoadBuffer, AutoRun = False', []);
        PrintLn('---------------------------', []);
        LLua.LoadBuffer(LBuffer.Memory, LBuffer.Size, False);
        LLua.Run;
      finally
        LBuffer.Free(); // Free the memory buffer
      end;
    except
      on E: Exception do
        PrintLn('Error: %s', [E.Message]); // Handle exceptions
    end;
  finally
    LLua.Free(); // Release Lua wrapper instance
  end;
end;

{
  Example03:
  Purpose:
  - Demonstrates variable interaction between Delphi and Lua.
  - Shows how to define variables in Lua from Delphi, retrieve values, and use them in Lua scripts.

  Steps:
  1. Define Lua variables using `SetVariable`.
  2. Load and execute Lua scripts that use the defined variables.
  3. Retrieve variables from Lua using `GetVariable`.
}
procedure Example03();
var
  LLua: TLua;      // Lua wrapper object
  LVal: TLuaValue; // Holder for Lua variables
begin
  LLua := TLua.Create();
  try
    try
      LLua.AddSearchPath('.\res\scripts'); // Add search paths for Lua modules

      // Define variables in Lua from Delphi
      LLua.SetVariable('var_string', '"My Name"');  // String variable
      LLua.SetVariable('var_integer', 4321);       // Integer variable
      LLua.SetVariable('var_number', 12.34);       // Number variable
      LLua.SetVariable('var_boolean', true);       // Boolean variable

      // Load and execute a Lua script file
      LLua.LoadFile('.\res\scripts\Example02.lua');

      // Retrieve and display variables defined in Lua
      LVal := LLua.GetVariable('var_string', vtString);
      PrintLn('var_string: %s, a string value', [LVal.AsString]);

      LVal := LLua.GetVariable('var_integer', vtInteger);
      PrintLn('var_integer: %d, an integer value', [LVal.AsInteger]);

      LVal := LLua.GetVariable('var_number', vtDouble);
      PrintLn('var_number: %3.2f, a number value', [LVal.AsNumber]);

      LVal := LLua.GetVariable('var_boolean', vtBoolean);
      PrintLn('var_boolean: %s, a boolean value', [BoolToStr(LVal.AsBoolean, True)]);
    except
      on E: Exception do
        PrintLn('Error: %s', [E.Message]); // Handle exceptions
    end;
  finally
    LLua.Free(); // Release Lua wrapper instance
  end;
end;

{
  Example04:
  Purpose:
  - Demonstrates the process of registering and calling Delphi routines and object methods from Lua.
  - Illustrates manual and automatic routine registration, global variable retrieval, and the use of object instances.

  Key Features:
  1. Manual registration of a routine and its direct invocation from Lua.
  2. Automatic registration of all class routines as global Lua functions.
  3. Registration of routines under a table named after the class.
  4. Registration of object instances as global Lua objects.
  5. Demonstrates retrieval of variables defined in Lua from Delphi.

  Steps:
  1. Create a `TLua` instance and set up the Lua environment.
  2. Manually register a routine and invoke it directly from Lua.
  3. Automatically register all methods of a Delphi class as global Lua functions.
  4. Automatically register all methods of a Delphi class under a Lua table named after the class.
  5. Register a specific object instance as a global Lua object.
  6. Retrieve and display Lua variables in Delphi to verify successful interaction.
}
procedure Example04();
var
  LLua: TLua;        // Lua wrapper object
  LVal: TLuaValue;   // Holder for Lua variables
  LObj: testbed2;    // Object instance to be registered with Lua
begin
  LLua := TLua.Create(); // Create a new Lua instance
  try
    try
      // Add a search path for resolving Lua modules via "require"
      LLua.AddSearchPath('.\res\scripts');

      // Step 1: Manually register a routine and call it directly from Lua
      LLua.RegisterRoutine('misc.test1', misc, @misc.test1); // Register the 'test1' routine in the 'misc' namespace
      LLua.Call('misc.test1', ['this works', 777]);          // Call the registered routine with parameters

      // Step 2: Automatically register all class routines as global Lua functions
      LLua.RegisterRoutines(testbed1);                      // Register all methods of 'testbed1' globally
      LVal := LLua.GetVariable('variable1', vtString);      // Retrieve a global variable set by Lua
      PrintLn('(host) variable1: %s', [LVal.AsString]);      // Display the retrieved variable
      LLua.Call('test1', ['this works!']);                  // Call the 'test1' method registered globally

      // Step 3: Automatically register all class routines under a Lua table named after the class
      LLua.RegisterRoutines('', testbed3);                  // Register all methods of 'testbed3' under its table
      LVal := LLua.GetVariable('variable3', vtString);      // Retrieve a variable set in the 'testbed3' table
      PrintLn('(host) variable3: %s', [LVal.AsString]);      // Display the retrieved variable
      LLua.Call('testbed3.test2', ['this works also!']);    // Call the 'test2' method from the 'testbed3' table

      // Step 4: Register an object instance as a global Lua object
      LObj := testbed2.Create;                              // Create an instance of 'testbed2'
      LLua.RegisterRoutines('', LObj, 'myObj');             // Register the object instance as 'myObj' in Lua
      LLua.Call('myObj.test1', [2020]);                     // Call the 'test1' method on the 'myObj' instance
      LObj.Free();                                          // Free the object instance to release resources

    except
      on E: Exception do
      begin
        // Handle and display any exceptions that occur during execution
        PrintLn('Error: %s', [E.Message]);
      end;
    end;
  finally
    // Ensure that the Lua instance is properly freed, even if an exception occurs
    LLua.Free();
  end;
end;

{
  Example05:
  Purpose:
  - Demonstrates loading and using Lua modules with the `require` command.
  - Highlights how to integrate external Lua scripts (modules) into the Lua runtime using Delphi.

  Key Features:
  1. Uses Lua's `require` function to load a module (`mymath`).
  2. Calls a function (`add`) from the loaded module with parameters.
  3. Illustrates adding a search path to resolve module locations.

  Steps:
  1. Create a `TLua` instance and set up the Lua environment.
  2. Add a search path for Lua modules using `AddSearchPath`.
  3. Load and execute Lua code as a string, which uses the `require` command to load a module.
  4. Handle exceptions that may occur during script execution.
  5. Free resources used by the `TLua` instance.
}
procedure Example05();
const
  LCode =
  '''
  print("load Lua modual using 'require' command...")
  local mm = require("mymath")  -- Load the 'mymath' module
  mm.add(5,5)                   -- Call the 'add' function from the module
  ''';
var
  LLua: TLua; // Lua wrapper object
begin
  LLua := TLua.Create(); // Create the Lua wrapper instance
  try
    try
      // Add a search path to locate Lua modules required by the script
      LLua.AddSearchPath('.\res\scripts');

      // Load the Lua code as a string and execute it
      LLua.LoadString(LCode);
    except
      on E: Exception do
      begin
        // Handle and display any exceptions that occur during execution
        PrintLn(E.Message, []);
      end;
    end;
  finally
    // Ensure that the Lua instance is properly freed, even if an exception occurs
    LLua.Free();
  end;
end;

{
  Example06:
  Purpose:
  - Demonstrates loading and using Lua scripts with the `import` command.
  - Highlights an alternative to `require` for loading specific Lua files directly into the runtime.

  Key Features:
  1. Uses Lua's `import` function to load a specific Lua script (`mymath.lua`).
  2. Calls a function (`add`) from the loaded script with parameters.
  3. Adds a search path for resolving Lua script locations.

  Steps:
  1. Create a `TLua` instance and configure the Lua environment.
  2. Add a search path to ensure the Lua script can be located.
  3. Load Lua code as a string, demonstrating the `import` command to include a Lua script.
  4. Execute the loaded script and handle exceptions that may occur.
  5. Free resources used by the `TLua` instance.
}
procedure Example06();
const
  LCode =
  '''
  print("load Lua modual using 'import' command...")
  local mm = import("./res/scripts/mymath.lua")  -- Import the 'mymath.lua' script
  mm.add(50,50)                                  -- Call the 'add' function from the script
  ''';
var
  LLua: TLua; // Lua wrapper object
begin
  LLua := TLua.Create(); // Create the Lua wrapper instance
  try
    try
      // Add a search path to locate Lua scripts used in the `import` command
      LLua.AddSearchPath('.\res\scripts');

      // Load the Lua code as a string and execute it
      LLua.LoadString(LCode);
    except
      on E: Exception do
      begin
        // Handle and display any exceptions that occur during execution
        PrintLn(E.Message, []);
      end;
    end;
  finally
    // Ensure that the Lua instance is properly freed, even if an exception occurs
    LLua.Free();
  end;
end;


{
  Example07:
  Purpose:
  - Demonstrates using a debugging function (`dbg`) in Lua scripts to assist with debugging Lua code execution.
  - Executes a loop that prints numbers from 1 to 10, providing an opportunity to inspect the script during debugging.

  Key Features:
  1. Integrates a `dbg` function for starting a debugging session within the Lua script.
  2. Executes a simple loop to demonstrate sequential Lua code execution.
  3. Adds a search path to resolve any potential dependencies.

  Steps:
  1. Create a `TLua` instance and configure the Lua environment.
  2. Add a search path for Lua modules and scripts using `AddSearchPath`.
  3. Load and execute Lua code containing the `dbg` function for debugging.
  4. Handle any exceptions that occur during script execution.
  5. Free the `TLua` instance to release resources.
}
procedure Example07();
const
  LCode =
  '''
  dbg() -- start debugging here
  for i = 1, 10 do
      print(i) -- Print numbers from 1 to 10
  end
  ''';
var
  LLua: TLua; // Lua wrapper object
begin
  LLua := TLua.Create(); // Create the Lua wrapper instance
  try
    try
      // Add a search path for Lua scripts
      LLua.AddSearchPath('.\res\scripts');

      // Load the Lua code as a string and execute it
      LLua.LoadString(LCode);
    except
      on E: Exception do
      begin
        // Handle and display any exceptions that occur during execution
        PrintLn(E.Message, []);
      end;
    end;
  finally
    // Ensure that the Lua instance is properly freed, even if an exception occurs
    LLua.Free();
  end;
end;


{
  Example08:
  Purpose:
  - Demonstrates compiling a Lua script file into a binary stream and then loading and executing the compiled script from memory.
  - Highlights the use of `TMemoryStream` to handle Lua script compilation and runtime execution.

  Key Features:
  1. Compiles a Lua script file (`Example03.lua`) into a memory stream using `CompileToStream`.
  2. Loads the compiled Lua bytecode from the memory stream into the Lua runtime using `LoadBuffer`.
  3. Executes the compiled script directly from memory without accessing the original script file.

  Steps:
  1. Create a `TLua` instance and configure the Lua environment.
  2. Add a search path for Lua scripts using `AddSearchPath`.
  3. Compile a Lua script file to a binary stream using `CompileToStream`.
  4. Load and execute the compiled bytecode directly from the memory stream using `LoadBuffer`.
  5. Handle exceptions that may occur during compilation or execution.
  6. Free the `TMemoryStream` and `TLua` instances to release resources.
}
procedure Example08();
var
  LLua: TLua;           // Lua wrapper object
  LStream: TMemoryStream; // Memory stream for storing compiled Lua bytecode
begin
  LLua := TLua.Create(); // Create the Lua wrapper instance
  try
    try
      // Add a search path to locate Lua scripts
      LLua.AddSearchPath('.\res\scripts');

      // Create a memory stream to store the compiled bytecode
      LStream := TMemoryStream.Create();
      try
        // Compile the Lua script file into the memory stream
        LLua.CompileToStream('.\res\scripts\Example03.lua', LStream, False);

        // Load the compiled Lua bytecode from the memory stream
        LLua.LoadBuffer(LStream.Memory, LStream.Size);

      finally
        // Free the memory stream after loading the bytecode
        LStream.Free();
      end;
    except
      on E: Exception do
      begin
        // Handle and display any exceptions that occur during compilation or execution
        PrintLn(E.Message, []);
      end;
    end;
  finally
    // Ensure that the Lua instance is properly freed, even if an exception occurs
    LLua.Free();
  end;
end;

{
  RunTests:
  Purpose:
  - Acts as the main entry point to execute any example from the unit.
  - The specific example is selected using the `LNum` variable.

  Steps:
  1. Modify `LNum` to choose the example to run.
  2. Call the corresponding example using a case statement.
  3. Pause the execution to review output.
}
procedure RunTests();
var
  LNum: Integer; // Index of the example to execute
begin
  LNum := 01; // Change this value to select a different example (01 to 08)

  case LNum of
    01: Example01(); // Demonstrates creating a Lua state, loading Lua libraries, executing a simple script, and closing the state.
    02: Example02(); // Demonstrates the use of the `TLua` class for loading and executing Lua scripts from strings, files, and buffers.
    03: Example03(); // Demonstrates variable interop between Delphi and Lua.
    04: Example04(); // Demonstrates routine registration
    05: Example05(); // Demonstrates Lua modules with "require"
    06: Example06(); // Demonstrates Lua modules with "import"
    07: Example07(); // Demonstrates debugging Lua scripts
    08: Example08(); // Demonstrates compiling Lua scripts to memory buffers
  end;

  Pause(); // Pause execution to review results
end;

end.
