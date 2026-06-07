# P-025: Regression-First Bug Resolution

> Language-agnostic. Applies to any codebase Harmony assists (JS/TS, Python, Go, Rust, bash, …).
> Complements Sentinel error memory ([P-016](P-016-error-journal.md)) and the shell-TDD rule in CLAUDE.md.

## Problem

When a bug is reported, the tempting path is to jump straight to a code change.
This causes two recurring failures:

1. **No proof of the cause** — the "fix" may not address the actual reported case.
2. **Silent regressions** — the same bug (or a sibling of it) comes back later because
   nothing guards against it.

## Solution — the Regression-First loop

**On any captured error, BEFORE touching the implementation:**

```
1. REPRODUCE   Write a test that fails because of the reported bug (RED).
               Do NOT modify the implementation yet.
2. CONFIRM RED Run it. It must fail for the *expected* reason (proves the cause).
3. FIX         Change the code minimally until the test passes (GREEN).
4. REINFORCE   Add adjacent tests for the bug *class*, not just the instance
               (boundaries, null/empty, the symmetric case, the cross-platform case).
5. LEARN       Record it in Sentinel error-journal (link the test) so the pattern
               is remembered across sessions and prevented next time.
```

The order is the point: **a fix without a prior failing test is not accepted.**

## Why it works

- The failing test **proves** you reproduced the real defect (not a guess).
- The passing test **proves** the fix actually resolves the reported case.
- The reinforced tests turn one bug into **permanent coverage** of its whole class.
- Sentinel makes it **cumulative**: the same mistake is not repeated.

## Generic shape (any language)

```
# RED — reproduce the reported case
test("reported: <short description of the bug>", () => {
    expect(subject(reportedInput)).toBe(expectedCorrect)   // fails today
})

# → run, see RED for the right reason
# → fix implementation
# → run, see GREEN

# REINFORCE — the class, not just the instance
test("boundary: empty / null / max", ...)
test("symmetric / cross-platform case", ...)
```

For shell/bash specifically, see the CLAUDE.md rule "TDD pour tout fichier shell"
and capture recurring shell mistakes in `error-library/` (e.g. BASH-006).

## Anti-patterns

- ❌ Editing the implementation before a reproducing test exists.
- ❌ A test that passes immediately (it never proved the bug).
- ❌ Asserting only the exact reported input (no reinforcement → class re-breaks).
- ❌ Fixing without recording the lesson (no Sentinel entry → repeats).

## Integration

- **Sentinel** (`error-journal.json`): each entry should reference the regression test that guards it.
- **error-library/** (`*-XXX.json`): for reusable, cross-project mistakes (the bug *class*).
- **Workflow**: triggered whenever an error is caught — manual report, failing CI, or a Sentinel-logged failure.
