---
name: git-advanced-workflows
displayName: "Git Advanced Workflows"
category: developer-essentials
tier: 2
model: inherit
triggers:
  - "git rebase"
  - "git cherry-pick"
  - "git bisect"
  - "merge conflict"
  - "branch strategy"
---

# Git Advanced Workflows

> Master advanced Git operations for complex development scenarios.

## Capabilities

### Interactive Rebase
```bash
# Squash last 3 commits
git rebase -i HEAD~3

# Rebase onto main with autosquash
git rebase -i --autosquash main
```

### Cherry-Pick Strategies
```bash
# Cherry-pick without committing
git cherry-pick -n <commit>

# Cherry-pick range of commits
git cherry-pick <start>..<end>

# Cherry-pick with message edit
git cherry-pick -e <commit>
```

### Git Bisect for Bug Hunting
```bash
# Start bisect
git bisect start
git bisect bad HEAD
git bisect good v1.0.0

# Automate with test script
git bisect run npm test
```

### Merge Conflict Resolution
```bash
# Use ours/theirs strategy
git checkout --ours <file>
git checkout --theirs <file>

# Three-way merge tool
git mergetool
```

### Branch Strategies

| Strategy | Use Case |
|----------|----------|
| **Git Flow** | Release-based, scheduled deployments |
| **GitHub Flow** | Continuous deployment, simple |
| **Trunk-Based** | CI/CD, feature flags |

### Stash Operations
```bash
# Stash with message
git stash push -m "WIP: feature X"

# Stash specific files
git stash push -m "message" -- file1 file2

# Apply and drop
git stash pop

# Create branch from stash
git stash branch new-branch stash@{0}
```

### Reflog Recovery
```bash
# View reflog
git reflog

# Recover deleted branch
git checkout -b recovered-branch HEAD@{5}

# Undo hard reset
git reset --hard HEAD@{1}
```

## Best Practices

1. **Always** create backup branch before rebase
2. **Never** rebase public/shared branches
3. **Use** `--force-with-lease` instead of `--force`
4. **Commit** often, squash before merge
5. **Write** meaningful commit messages
