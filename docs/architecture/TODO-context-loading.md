# TODO: Context Loading System Implementation

## Status Overview

| Component | Status | File | Priority |
|-----------|--------|------|----------|
| Branch Cache | ✅ DONE | `lib/config-loader.sh` | - |
| resolve_agent() | ✅ DONE | `lib/config-loader.sh` | - |
| Haiku Classification | ❌ TODO | `lib/context-preloader.sh` | P0 |
| Profile Detection | ❌ TODO | `lib/profile-loader.sh` | P1 |
| Knowledge JIT Loading | ❌ TODO | `lib/knowledge-loader.sh` | P1 |
| Memory Injection | ❌ TODO | `lib/memory-injector.sh` | P2 |
| Guardian Integration | ❌ TODO | `agents/guardian.md` | P2 |

---

## P0: Context Preloader (CRITICAL)

### Task 1: `lib/context-preloader.sh`

**Functions to implement:**

```bash
# Main orchestrator
preload_context() {
    local user_input="$1"
    local current_agent="$2"

    # 1. Classify with Haiku
    # 2. Resolve branch
    # 3. Load profiles
    # 4. Load knowledge
    # 5. Inject to memory
}

# Haiku classification
classify_with_haiku() {
    local user_input="$1"
    # Call Haiku API with classification_prompt from routing-rules.yaml
    # Return JSON: {intent, flags, agent, triggered_agents, confidence}
}

# Parse Haiku response
parse_classification_result() {
    local json_response="$1"
    # Extract and validate fields
}

# Load triggered agents (summaries only)
load_triggered_agents() {
    local agents_array="$1"
    # For each agent, load first 50 lines only
}
```

**Estimated effort:** 4-6 hours

**Dependencies:**
- [ ] Haiku API access (via Claude Code or direct)
- [ ] jq for JSON parsing
- [ ] routing-rules.yaml loaded

**Tests to add:**
```bash
test_context_preloader() {
    # Mock Haiku response
    result=$(classify_with_haiku "créer auth" --mock)
    assert_contains "$result" "has_auth"

    # Integration test
    result=$(preload_context "créer jeu" "developer" --dry-run)
    assert_contains "$result" "gaming"
}
```

---

## P1: Profile Loader

### Task 2: `lib/profile-loader.sh`

**Functions to implement:**

```bash
# Detect profiles from project files
detect_profiles() {
    local project_dir="$1"

    # Check package.json
    if [[ -f "$project_dir/package.json" ]]; then
        detect_npm_profiles "$project_dir/package.json"
    fi

    # Check pubspec.yaml (Flutter)
    if [[ -f "$project_dir/pubspec.yaml" ]]; then
        detect_flutter_profiles "$project_dir/pubspec.yaml"
    fi

    # Check requirements.txt (Python)
    if [[ -f "$project_dir/requirements.txt" ]]; then
        detect_python_profiles "$project_dir/requirements.txt"
    fi
}

# Detect from package.json
detect_npm_profiles() {
    local package_json="$1"

    # React
    if jq -e '.dependencies.react' "$package_json" > /dev/null 2>&1; then
        echo "frontend/react"

        # Detect version
        version=$(jq -r '.dependencies.react' "$package_json")
        echo "react_version:$version"
    fi

    # React Native
    if jq -e '.dependencies["react-native"]' "$package_json" > /dev/null 2>&1; then
        echo "mobile/react-native"
    fi

    # NestJS
    if jq -e '.dependencies["@nestjs/core"]' "$package_json" > /dev/null 2>&1; then
        echo "backend/nestjs"
    fi

    # TypeScript
    if jq -e '.devDependencies.typescript' "$package_json" > /dev/null 2>&1; then
        echo "languages/typescript"
    fi
}

# Load profile manifest
load_profile_manifest() {
    local profile_id="$1"  # e.g., "frontend/react"
    local manifest_path="${HARMONY_DIR}/profiles/${profile_id}/manifest.yaml"

    if [[ -f "$manifest_path" ]]; then
        yq -o=json "$manifest_path"
    fi
}

# Get knowledge for intent
get_profile_knowledge_for_intent() {
    local profile_id="$1"
    local intent="$2"  # IMPLEMENT, TEST, SECURITY

    local manifest=$(load_profile_manifest "$profile_id")
    echo "$manifest" | jq -r ".knowledge.on_intent.$intent[]?" 2>/dev/null
}
```

**Estimated effort:** 3-4 hours

**Detection matrix:**

| File | Check | Profile |
|------|-------|---------|
| `package.json` | `dependencies.react` | frontend/react |
| `package.json` | `dependencies.react-native` | mobile/react-native |
| `package.json` | `dependencies.@nestjs/core` | backend/nestjs |
| `package.json` | `dependencies.next` | frontend/nextjs |
| `package.json` | `devDependencies.typescript` | languages/typescript |
| `pubspec.yaml` | `dependencies.flutter` | mobile/flutter |
| `requirements.txt` | `django` | backend/django |
| `requirements.txt` | `fastapi` | backend/fastapi |
| `go.mod` | exists | languages/go |
| `Cargo.toml` | exists | languages/rust |

---

## P1: Knowledge Loader

### Task 3: `lib/knowledge-loader.sh`

**Functions to implement:**

```bash
# Main loader
load_knowledge_for_context() {
    local branch_manifest="$1"
    local profiles="$2"        # newline-separated
    local context_flags="$3"   # newline-separated
    local intent="$4"          # IMPLEMENT, TEST, etc.

    local knowledge_files=()

    # 1. From branch manifest
    while IFS= read -r file; do
        knowledge_files+=("$file")
    done < <(get_branch_knowledge "$branch_manifest")

    # 2. From profiles (by intent)
    while IFS= read -r profile; do
        while IFS= read -r file; do
            knowledge_files+=("$file")
        done < <(get_profile_knowledge_for_intent "$profile" "$intent")
    done <<< "$profiles"

    # 3. From context flags
    while IFS= read -r flag; do
        while IFS= read -r file; do
            knowledge_files+=("$file")
        done < <(get_flag_knowledge "$flag")
    done <<< "$context_flags"

    # Deduplicate and return
    printf '%s\n' "${knowledge_files[@]}" | sort -u
}

# Get knowledge from routing-rules.yaml flags
get_flag_knowledge() {
    local flag="$1"
    # Read context_flag_triggers.$flag.knowledge from routing-rules.yaml
}

# Token budget check
check_token_budget() {
    local files="$1"
    local max_tokens="${2:-15000}"

    local total=0
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            local chars=$(wc -c < "$file")
            local tokens=$((chars / 4))
            total=$((total + tokens))
        fi
    done <<< "$files"

    if (( total > max_tokens )); then
        echo "WARNING: Token budget exceeded ($total > $max_tokens)" >&2
        return 1
    fi

    echo "$total"
}
```

**Estimated effort:** 2-3 hours

---

## P2: Memory Injector

### Task 4: `lib/memory-injector.sh`

**Functions to implement:**

```bash
# Inject context to working memory
inject_context_to_memory() {
    local agent="$1"
    local branch="$2"
    local profiles="$3"
    local knowledge="$4"
    local flags="$5"
    local triggered="$6"

    local memory_file="${HARMONY_DIR}/memory/working.json"

    # Build JSON
    cat > "$memory_file" << EOF
{
    "context_loaded": true,
    "timestamp": "$(date -Iseconds)",
    "active_agent": "$agent",
    "active_branch": "$branch",
    "loaded_profiles": $(echo "$profiles" | jq -R -s 'split("\n") | map(select(length > 0))'),
    "loaded_knowledge": $(echo "$knowledge" | jq -R -s 'split("\n") | map(select(length > 0))'),
    "context_flags": $(echo "$flags" | jq -R -s 'split("\n") | map(select(length > 0))'),
    "triggered_agents": $(echo "$triggered" | jq -R -s 'split("\n") | map(select(length > 0))')
}
EOF
}

# Display context summary
display_context_summary() {
    local memory_file="${HARMONY_DIR}/memory/working.json"

    if [[ -f "$memory_file" ]]; then
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                    CONTEXT LOADED                               ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Agent:    $(jq -r '.active_agent' "$memory_file")"
        echo "Branch:   $(jq -r '.active_branch' "$memory_file")"
        echo "Profiles: $(jq -r '.loaded_profiles | join(", ")' "$memory_file")"
        echo "Flags:    $(jq -r '.context_flags | join(", ")' "$memory_file")"
        echo ""
    fi
}
```

**Estimated effort:** 1-2 hours

---

## P2: Guardian Integration

### Task 5: Modify `agents/guardian.md`

**Add section after routing:**

```markdown
## Context Pre-Loading (Step 4)

AFTER routing to an agent, BEFORE execution:

1. **Call context preloader**
   ```
   source ${HARMONY_DIR}/lib/context-preloader.sh
   preload_context "$USER_REQUEST" "$SELECTED_AGENT"
   ```

2. **Verify context loaded**
   - Check .harmony/memory/working.json exists
   - Verify context_loaded == true

3. **Display summary**
   ```
   display_context_summary
   ```

4. **Proceed with enriched context**
   - Agent has knowledge pre-loaded
   - Triggered agents visible
   - Flags available for decisions
```

**Estimated effort:** 1 hour

---

## Implementation Order

```
Week 1:
├── Day 1-2: context-preloader.sh (P0)
│   ├── classify_with_haiku()
│   ├── parse_classification_result()
│   └── preload_context() orchestrator
│
├── Day 3: profile-loader.sh (P1)
│   ├── detect_profiles()
│   └── detect_npm_profiles()
│
├── Day 4: knowledge-loader.sh (P1)
│   ├── load_knowledge_for_context()
│   └── check_token_budget()
│
└── Day 5: Integration
    ├── memory-injector.sh (P2)
    ├── Guardian integration (P2)
    └── E2E tests

Week 2:
├── Additional profile detectors (Flutter, Python, Go)
├── Context7 integration
└── Performance optimization
```

---

## Test Plan

### Unit Tests

```bash
# tests/e2e/scripts/test.sh additions

test_context_preloader() {
    echo "=== Testing context-preloader ==="

    # Test 1: Mock classification
    result=$(classify_with_haiku "créer auth" --mock)
    assert_contains "$result" "has_auth"
    assert_contains "$result" "IMPLEMENT"

    # Test 2: Branch resolution with flags
    result=$(resolve_branch_for_flags "is_game" "developer")
    assert_equals "$result" "specialties/developer/branchs/gaming.md"

    # Test 3: Token budget
    result=$(check_token_budget "$(echo -e 'file1.md\nfile2.md')" 1000)
    assert_less_than "$result" 1000
}

test_profile_loader() {
    echo "=== Testing profile-loader ==="

    # Create mock package.json
    echo '{"dependencies":{"react":"^18.0.0","@nestjs/core":"^10.0.0"}}' > /tmp/package.json

    result=$(detect_npm_profiles /tmp/package.json)
    assert_contains "$result" "frontend/react"
    assert_contains "$result" "backend/nestjs"
}

test_knowledge_loader() {
    echo "=== Testing knowledge-loader ==="

    # Test loading for gaming context
    result=$(load_knowledge_for_context "developer/gaming" "" "is_game" "IMPLEMENT")
    assert_contains "$result" "gaming"
}
```

### E2E Tests

```bash
test_full_context_flow() {
    echo "=== Testing full context flow ==="

    # Setup: Create test project with package.json
    mkdir -p /tmp/test-project
    echo '{"dependencies":{"react-native":"^0.72.0"}}' > /tmp/test-project/package.json

    # Run preloader
    cd /tmp/test-project
    result=$(preload_context "créer écran login" "developer" --dry-run)

    # Verify
    assert_contains "$result" "mobile"
    assert_contains "$result" "has_auth"
    assert_file_exists ".harmony/memory/working.json"
}
```

---

## Dependencies

### Required Tools

| Tool | Purpose | Install |
|------|---------|---------|
| `jq` | JSON parsing | `apt install jq` |
| `yq` | YAML parsing | `snap install yq` |
| `curl` | API calls | Built-in |

### API Access

For Haiku classification, options:
1. **Claude Code built-in** - Use Task tool with haiku model
2. **Direct API** - Requires ANTHROPIC_API_KEY
3. **Mock mode** - For testing without API

---

## Acceptance Criteria

- [ ] `preload_context "créer auth"` returns has_auth flag
- [ ] Gaming context auto-detects from keywords
- [ ] Profiles detected from package.json
- [ ] Knowledge loaded within 15K token budget
- [ ] working.json updated with full context
- [ ] Guardian displays context summary before execution
- [ ] All tests pass in CI
