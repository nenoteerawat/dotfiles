```markdown
# dotfiles Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill teaches the core development patterns and conventions used in the `dotfiles` repository, which is written in TypeScript without a detected framework. You'll learn how to structure files, write and organize code, follow commit conventions, and understand the testing approach. This guide is ideal for contributors aiming for consistency and maintainability in this codebase.

## Coding Conventions

### File Naming
- Use **camelCase** for file names.
  - Example: `myConfigFile.ts`

### Import Style
- Use **relative imports** for modules within the project.
  - Example:
    ```typescript
    import { myFunction } from './utils/myFunction';
    ```

### Export Style
- Prefer **named exports**.
  - Example:
    ```typescript
    // utils/myFunction.ts
    export function myFunction() { /* ... */ }
    ```

### Commit Messages
- Use **conventional commit** format.
- Supported prefixes: `chore`, `refactor`
- Example:
  ```
  chore: update dependencies for security patches
  refactor: simplify config loader logic
  ```

## Workflows

### Code Refactoring
**Trigger:** When improving code structure or readability without changing external behavior.
**Command:** `/refactor`

1. Identify code that can be improved (e.g., simplify logic, rename variables).
2. Make changes following the coding conventions.
3. Commit with a message starting with `refactor:`.
4. Push your changes and open a pull request if necessary.

### Dependency Maintenance
**Trigger:** When updating, adding, or removing dependencies.
**Command:** `/chore`

1. Update dependency files as needed.
2. Ensure all imports and usages are updated.
3. Commit with a message starting with `chore:`.
4. Push your changes and open a pull request if necessary.

## Testing Patterns

- Test files use the pattern `*.test.*` (e.g., `configLoader.test.ts`).
- The specific testing framework is **unknown**, but tests are likely colocated with the code or in a dedicated test directory.
- Example test file:
  ```typescript
  // configLoader.test.ts
  import { configLoader } from './configLoader';

  describe('configLoader', () => {
    it('should load configuration correctly', () => {
      // test implementation
    });
  });
  ```

## Commands
| Command    | Purpose                                      |
|------------|----------------------------------------------|
| /refactor  | Initiate a code refactoring workflow         |
| /chore     | Start a dependency or maintenance workflow   |
```
