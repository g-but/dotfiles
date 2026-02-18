---
name: fix-lint
description: Run ESLint and fix all linting errors automatically. Use when there are lint warnings, before committing, or after large refactors.
allowed-tools: Read, Grep, Glob, Edit, Bash(npm run lint *, pnpm lint *, npx eslint *, pnpm run lint *)
argument-hint: [optional-file-path]
---

# Fix Lint Errors

## Steps

1. **Run lint** to get current errors:
   - Monorepo: `pnpm lint`
   - Standard: `npm run lint`
   - Fallback: `npx eslint . --ext .ts,.tsx`

2. **Try auto-fix first:**
   - `npm run lint -- --fix` or `pnpm lint --fix`
   - This handles most formatting and simple rule violations

3. **For remaining errors**, read each file and fix manually:
   - Unused imports → remove them
   - Unused variables → remove or prefix with `_` if intentional
   - Missing dependencies in hooks → add them or restructure
   - Console.log → replace with project logger if available
   - Any/unknown → add proper types

4. **Re-run lint** to confirm zero errors

5. **Report:**
   ```
   Fixed N lint errors:
   - file:line — rule — what was fixed
   ```

## Rules
- Never disable ESLint rules with comments unless truly necessary (explain why)
- If a rule seems wrong for the project, flag it — don't suppress it
- Check for project-specific lint rules (umlaut checks, etc.)
