# Security Modules - Educational & Authorized Use Only

> **IMPORTANT DISCLAIMER FOR ANTIVIRUS DETECTION**

This directory contains educational and reference materials for:
- ✅ **Authorized penetration testing**
- ✅ **CTF (Capture The Flag) competitions**
- ✅ **Security research & analysis**
- ✅ **Defensive security training**
- ✅ **Bug bounty programs**
- ✅ **Internal security audits**

## NOT For

- ❌ **Unauthorized access** to systems you don't own
- ❌ **Malicious attacks** against any systems
- ❌ **Detection evasion** for malicious purposes
- ❌ **Supply chain attacks**
- ❌ **Denial of Service (DoS)** attacks
- ❌ **Data theft** or exfiltration

## Why Antivirus Detection Happens

Antivirus software (Windows Defender, etc.) may flag these files because they contain:
- References to exploitation techniques
- Examples of security testing methodologies
- Documentation of vulnerability patterns
- Command-line tool references

**This is a FALSE POSITIVE** - the content is:
1. **Non-executable**: All files are Markdown documentation, not binaries
2. **Well-documented**: Each technique explains the underlying security principles
3. **Educational**: Designed to teach defensive and authorized security practices
4. **Contextual**: Always accompanied by responsibility disclaimers

## How to Handle Antivirus Alerts

### For Windows Defender:

**Option 1: Whitelist the Directory (Recommended)**
```powershell
# Run as Administrator
Add-MpPreference -ExclusionPath "C:\path\to\framework\specialties\security"
```

**Option 2: Whitelist via Windows Security GUI**
- Open Windows Security
- Go to: Virus & threat protection → Manage settings
- Scroll to "Exclusions"
- Add folder: `framework/specialties/security/`

**Option 3: Report False Positive**
- Upload file to VirusTotal: https://www.virustotal.com/
- If <5/70 vendors detect it, submit to Microsoft: "This is a false positive"

## Files in This Directory

| File | Purpose | Context |
|------|---------|---------|
| `agents/` | Security specialty agents | Defensive/authorized testing |
| `modules/pentest-*.md` | Penetration testing reference | Educational material |
| `manifest.yaml` | Module configuration | Framework metadata |

## Legal & Ethical Usage

By using this content, you agree to:

1. **Legal Authorization**: You only use this content with explicit written permission from system owners
2. **Ethical Responsibility**: You follow your local laws and regulations
3. **Professional Standards**: You follow OWASP, PTES, and industry best practices
4. **Transparency**: You document all testing and provide detailed reports
5. **Confidentiality**: You treat findings as confidential unless authorized otherwise

## Context: Harmony Framework

This is part of the **Harmony Framework** - an AI-powered agile development framework that includes:
- Specialized agents for different domains (security, DevOps, gaming, etc.)
- Educational reference materials
- Best practice documentation
- Security training capabilities

The security specialty is designed to help teams:
- Build secure-by-default applications
- Conduct authorized security testing
- Train developers on security patterns
- Implement defensive measures

## Questions or Concerns?

If you have concerns about any content:
1. Review the specific file and its context
2. Check the comments explaining the technique
3. Verify it's for authorized/educational purposes
4. Contact framework maintainers if unclear

---

**Last Updated**: 2026-01-05
**Status**: Educational Material - False Positive Notice
