---
name: write-tests
description: Generate tests for recent changes or a specific file. Analyzes code and writes meaningful unit/integration tests.
allowed-tools: Read, Grep, Glob, Write, Edit, Bash(git diff *, git log *, npm test *, npm run test *, pnpm test *, pnpm run test *, npx jest *, npx playwright *)
argument-hint: [file-path-or-recent]
---

# Write Tests

## Steps

1. **Identify what to test:**
   - If `$ARGUMENTS` is a file path → test that file
   - If `$ARGUMENTS` is "recent" or empty → check `git diff HEAD~3 --name-only` for recently changed files

2. **Read the source code** and identify testable behavior:
   - Business logic functions (HIGH priority)
   - API endpoints / server actions (HIGH priority)
   - Utility functions (MEDIUM priority)
   - Component interactions (MEDIUM priority)
   - Pure rendering (LOW — skip unless asked)

3. **Check existing test patterns** in the project:
   - Find existing test files: `*.test.ts`, `*.spec.ts`, `__tests__/`
   - Match the project's test framework (Jest, Vitest, Playwright)
   - Follow existing naming and file placement conventions

4. **Write tests that verify behavior, not implementation:**
   - Test inputs → outputs, not internal details
   - Test edge cases: null, empty, boundary values
   - Test error paths (invalid input, missing data)
   - For financial code: use EXACT expected values, never approximate

5. **Run the tests** to confirm they pass

6. **Report:**
   ```
   Wrote N tests in M files:
   - path/to/test.ts — what's tested
   ```

## Rules
- Match the project's existing test style exactly
- Never mock what you can use directly
- Test behavior, not implementation details
- Financial assertions must use exact values (no toBeCloseTo)
