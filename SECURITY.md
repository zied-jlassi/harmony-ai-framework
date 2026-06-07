# Security Policy

Harmony is an AI development framework that runs **on a developer workstation** and
intercepts shell/file/LLM activity through Claude Code hooks. Security is a core
part of the framework, not an add‑on. This document describes what Harmony actually
does, its limits, and how to report a vulnerability.

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.4.x   | ✅ |
| < 1.4   | ❌ (please upgrade) |

## Reporting a Vulnerability

**Please do not open a public issue for security vulnerabilities.**

- Open a private report via **GitHub Security Advisories**
  ("Security" tab → *Report a vulnerability*) on
  [zied-jlassi/harmony-ai-framework](https://github.com/zied-jlassi/harmony-ai-framework/security/advisories).

Please include: affected version, reproduction steps, impact, and any logs from
`.harmony/local/logs/security/`.

What to expect:
- Acknowledgement within **72 hours**.
- An initial assessment and severity within **7 days**.
- Coordinated disclosure: we agree on a fix + disclosure date before going public;
  credit is given to reporters who want it.

## What Harmony does (defense in depth)

These are **real, shipped** controls (see the referenced files). They are
auto-installed as Claude Code hooks and can be toggled with `HARMONY_GUARDS=off`
or `/hf:security:guards`.

| Control | File | Protects against |
|---------|------|------------------|
| **Rules enforcer** | `hooks/rules-enforcer.sh` | Destructive shell commands (`rm -rf /`, `DROP DATABASE`, fork bombs, `chmod 777 /`…) and shell **injection** combos (`base64 -d \| bash`, `eval $(curl …)`, `bash <(curl …)`, download‑pipe‑to‑interpreter). Blocks (exit 2) and logs. |
| **Supply‑chain guard** | `hooks/supply-chain-guard.sh` | Malicious/typosquatted packages, known‑vulnerable installs, unpinned MCP servers, unverified sources, recently‑published packages (quarantine). |
| **LLM output sanitizer** | `hooks/llm-output-sanitizer.sh` | Prompt‑injection / jailbreak artifacts, data exfiltration URLs, leaked secrets, and Unicode steganography in external/LLM output. |
| **Data sandbox** | `lib/data-sandbox.sh` | Untrusted input: injection‑pattern detection, trust levels, and quarantine of suspicious data. |
| **Security gates** | `lib/security-gates.sh` | Access to blocked/sensitive paths. |
| **Integrity verification** | `bin/install.sh` + `checksums.sha256` | Tampered/corrupted framework files — SHA‑256 verified at install (cross‑platform), with self‑repair (ADR‑007). |

### Security logging

Detections are persisted in the project's mutable zone, split by threat layer:

- `.harmony/local/logs/security/security.log` — application / workstation layer
  (dangerous commands, shell injection, supply‑chain).
- `.harmony/local/logs/security/llm-security.log` — LLM layer (prompt injection,
  exfiltration, steganography, untrusted input).

These logs stay **local** to the project and are never transmitted anywhere by the
framework.

## Scope & limitations

- Harmony provides **defense in depth**, not a security boundary or sandbox. It
  reduces risk from accidental and many malicious actions, but is **not** a
  substitute for OS‑level isolation (containers, VMs, gVisor/Firecracker), least
  privilege, and code review.
- Pattern‑based detection can have false negatives; determined attackers may craft
  payloads that evade specific patterns. We tune for a **low false‑positive rate**
  and welcome reports of bypasses.
- The optional performance tools (`jq`, `yq`, `bun`, `python`) and Node.js must be
  kept up to date by the user; Harmony does not manage their patch level.
- Guards can be disabled by the user (`HARMONY_GUARDS=off`). When disabled, the
  above protections do not apply.

## Hardening recommendations

- Run Claude Code / Harmony inside an isolated environment (container or VM) when
  working with untrusted code or data.
- Keep the security hooks **enabled** and the framework on a supported version.
- Review `.harmony/local/logs/security/` periodically.
- Never commit secrets; the sanitizer is a backstop, not a vault.
