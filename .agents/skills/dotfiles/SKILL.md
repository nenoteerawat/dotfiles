```markdown
# dotfiles Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill teaches you the core development patterns and conventions used in the `dotfiles` repository, which is written in TypeScript with no specific framework. You'll learn about file naming, import/export styles, commit message conventions, and how to write and run tests. This guide is ideal for contributors aiming for consistency and best practices in this codebase.

## Coding Conventions

### File Naming
- Use **PascalCase** for file names.
  - Example: `MyConfig.ts`, `UserSettings.ts`

### Import Style
- Use **relative imports** for referencing modules within the project.
  - Example:
    ```typescript
    import { UserSettings } from './UserSettings';
    ```

### Export Style
- Use **named exports**.
  - Example:
    ```typescript
    // In UserSettings.ts
    export const UserSettings = { /* ... */ };
    ```

### Commit Messages
- Use **Conventional Commits** with the `feat` prefix for new features.
  - Example:
    ```
    feat: add support for custom themes in UserSettings
    ```
- Keep commit messages concise (average length: ~80 characters).

## Workflows

### Adding a New Feature
**Trigger:** When you want to introduce a new feature.
**Command:** `/add-feature`

1. Create a new TypeScript file using PascalCase.
2. Implement the feature using relative imports and named exports.
3. Write corresponding tests in a `.test.ts` file.
4. Commit your changes using the `feat:` prefix.
5. Push your branch and open a pull request.

### Writing and Running Tests
**Trigger:** When you need to verify code correctness.
**Command:** `/run-tests`

1. Create a test file named `*.test.ts` alongside the module.
2. Write tests using your preferred testing framework (not specified).
3. Run the test suite using the project's test runner (see project docs or package.json).

## Testing Patterns

- Test files are named with the pattern `*.test.ts`.
- Place test files next to the modules they test.
- The testing framework is not specified; follow the project's existing patterns or consult the maintainer.
- Example:
  ```typescript
  // UserSettings.test.ts
  import { UserSettings } from './UserSettings';

  describe('UserSettings', () => {
    it('should initialize with default values', () => {
      // test implementation
    });
  });
  ```

## Commands
| Command        | Purpose                                  |
|----------------|------------------------------------------|
| /add-feature   | Guide for adding a new feature           |
| /run-tests     | Instructions for writing and running tests|
```
