```markdown
# dotfiles Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill outlines the core development patterns and workflows for the `dotfiles` repository, a TypeScript-based project with no detected framework. It covers coding conventions, documentation and configuration workflows, and testing patterns to ensure consistency and maintainability across contributions.

## Coding Conventions

### File Naming
- Use **PascalCase** for file names.
  - Example: `MyConfig.ts`, `UserSettings.test.ts`

### Import Style
- Use **relative imports** for modules within the project.
  ```typescript
  import { getConfig } from './Config';
  ```

### Export Style
- Use **named exports** for all modules.
  ```typescript
  // In Config.ts
  export function getConfig() { ... }
  export const DEFAULTS = { ... };
  ```

### Commit Messages
- Follow **conventional commit** patterns.
- Common prefixes: `docs`, `feat`
  - Example: `feat: add user settings loader`
  - Example: `docs: update installation instructions`

## Workflows

### Document New Feature or Workflow
**Trigger:** When adding a significant new feature, workflow, or tool that requires documentation.  
**Command:** `/document-feature`

1. Implement or integrate the new feature, tool, or workflow.
2. Update or create documentation files (e.g., `README.md`, `CLAUDE.md`) to explain usage, setup, and operational notes.
3. Commit documentation changes with a message referencing the new feature or workflow.

**Example Commit:**
```
docs: document new shell integration workflow
```

### Update Configuration and Documentation in Tandem
**Trigger:** When changing or adding configuration and ensuring documentation stays in sync.  
**Command:** `/update-config-docs`

1. Edit or add configuration files (e.g., `.config/opencode/opencode.json`, `install.sh`).
2. Update documentation files (e.g., `CLAUDE.md`) to reflect the new configuration or installation steps.
3. Commit both configuration and documentation changes together.

**Example Commit:**
```
docs: update CLAUDE.md for new opencode.json options
```

## Testing Patterns

- Test files follow the `*.test.*` naming convention.
  - Example: `Config.test.ts`
- The testing framework is not specified; ensure tests are colocated with the code or in a dedicated test directory.

**Example Test File:**
```typescript
// Config.test.ts
import { getConfig } from './Config';

describe('getConfig', () => {
  it('returns default config', () => {
    expect(getConfig()).toEqual({ /* ... */ });
  });
});
```

## Commands

| Command             | Purpose                                                        |
|---------------------|----------------------------------------------------------------|
| /document-feature   | Document a new feature, workflow, or tool after implementation |
| /update-config-docs | Update configuration and documentation in tandem               |
```
