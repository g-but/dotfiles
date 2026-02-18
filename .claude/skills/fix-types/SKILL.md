---
name: fix-types
description: Run TypeScript type checker and fix all errors automatically. Use when there are type errors, after refactoring, or before committing.
allowed-tools: Read, Grep, Glob, Edit, Bash(pnpm type-check, pnpm typecheck, npm run type-check, npm run typecheck, npx tsc *)
argument-hint: [optional-file-path]
---

# Fix TypeScript Errors

## Steps

1. **Run typecheck** to get current errors:
   - Monorepo (pnpm-workspace.yaml exists): `pnpm type-check` or `pnpm typecheck`
   - Standard project: `npm run typecheck` or `npm run type-check`
   - Fallback: `npx tsc --noEmit`

2. **Parse the output** — group errors by file

3. **Fix each error** by reading the file, understanding context, and applying the minimal correct fix:
   - Missing types → add them (derive from schema if available, never define separately)
   - Wrong types → correct them
   - Missing imports → add them
   - Null/undefined → add proper checks (not `!` assertions unless truly safe)
   - Generic type args → infer from usage

4. **Re-run typecheck** to confirm zero errors

5. **Report** what was fixed:
   ```
   Fixed N type errors:
   - file:line — what was wrong → what was fixed
   ```

## Rules
- Never use `any` unless absolutely unavoidable (explain why)
- Never use `@ts-ignore` or `@ts-expect-error` to suppress errors
- Derive types from schemas (Zod, Drizzle, Prisma) — never define separately
- If a fix requires an architectural decision, stop and ask
