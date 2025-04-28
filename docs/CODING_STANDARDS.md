# Coding Standards for Ultima VII: Revisited

This document outlines the coding standards to follow when contributing to this project. 
These standards are based on the existing codebase while incorporating some modern C++ best practices.

## File Organization

### Header Files
- Use header guards with the format `_FILENAME_H_`
- Include files in this order:
  1. Related header file (for .cpp files)
  2. Project headers (starting with core "Geist" headers)
  3. Third-party library headers
  4. Standard library headers
- Forward declare classes when possible instead of including headers

### Source Files
- Each file should have a header comment block describing:
  - File name
  - Author
  - Date
  - Purpose

Example:
```cpp
///////////////////////////////////////////////////////////////////////////
//
// Name:     FILENAME.H
// Author:   Your Name
// Date:     YYYY/MM/DD
// Purpose:  Brief description of the file's purpose
//
///////////////////////////////////////////////////////////////////////////
```

## Naming Conventions

### Classes and Structs
- Use PascalCase for class and struct names
- Prefix Ultima VII-specific classes with "U7" (e.g., `U7Object`, `U7Player`)
- Non-Ultima VII engine classes generally don't have a prefix (e.g., `Engine`, `ResourceManager`)

### Variables
- Use camelCase for local variables and function parameters
- Use `m_` prefix for class member variables (e.g., `m_Position`, `m_Speed`)
- Use `g_` prefix for global variables (e.g., `g_Engine`, `g_ResourceManager`)

### Functions
- Use PascalCase for method names (e.g., `Init()`, `Update()`, `Draw()`)
- Use verb phrases that describe the action being performed

### Constants and Enums
- Use PascalCase for enum types and enum values
- Use ALL_CAPS for preprocessor defines and constants

## Code Style

### Indentation and Braces
- Use 3-space indentation (maintain existing style)
- Opening braces on the same line for functions and control structures
- Closing braces on their own line

Example:
```cpp
if (condition) {
   doSomething();
}
```

### Spacing
- Space after keywords like `if`, `for`, `while`
- Space between operators
- No space between function name and opening parenthesis

### Line Length
- Keep lines to a reasonable length (recommend 80-100 characters)
- Break long lines at logical points

## C++ Usage

### Language Features
- The project uses C++17 features
- Use `std::unique_ptr` and `make_unique` for memory management (already in use in the codebase)
- Use `const` where appropriate, especially for methods that don't modify object state
- Use references for passing complex objects

### Memory Management
- Prefer smart pointers over raw pointers
- Follow RAII principles (Resource Acquisition Is Initialization)
- Ensure resources are properly released in destructors
- Use standard containers (like `std::vector`, `std::unordered_map`) when possible

### Error Handling
- Use try/catch blocks for error handling
- Add appropriate error messages
- Avoid silent failures

## Comments

- Use `//` for single-line comments
- Use `/* */` for multi-line comments
- Every class should have a comment explaining its purpose
- Complex functions should have explanatory comments
- Comment non-obvious code sections

## Project-Specific Patterns

### Game Object Pattern
- Derive game objects from existing base classes (e.g., `Unit3D`, `Object`)
- Implement the standard methods: `Init()`, `Shutdown()`, `Update()`, and `Draw()`
- Follow the established state machine pattern for game states

### Resource Management
- Use the `ResourceManager` for loading and managing assets
- Properly clean up resources when they're no longer needed

## Modern Improvements (While Maintaining Compatibility)

### Consider Using:
- `enum class` instead of plain `enum` for type safety
- `nullptr` instead of `NULL`
- Ranged-based for loops where appropriate
- `auto` for complex iterator types
- `constexpr` for compile-time computations
- `override` keyword for virtual function overrides

### Avoid:
- C-style casts (use C++ cast operators instead)
- Magic numbers (use named constants)
- Global state when possible (though this is used extensively in the codebase)
- Platform-specific code without proper abstraction

## Version Control

- Write clear commit messages explaining the changes
- Keep commits focused on single logical changes
- Update the CHANGELOG.md for significant changes

## Testing

- Test your changes thoroughly before submitting
- Ensure the game runs on the supported platforms

By following these standards, we'll maintain consistency with the existing codebase while gradually improving the code quality with modern C++ practices.
