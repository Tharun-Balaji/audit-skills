# audit-skills: AI Skill Security Auditor

A comprehensive security auditing skill for reviewing AI skills for vulnerabilities including prompt injection, hidden instructions, command injection, data exfiltration, and malicious payloads.

## 🎯 Overview

The `audit-skills` skill provides thorough security reviews of AI skills (SKILL.md plus bundled resources). It identifies security risks, produces detailed findings with evidence, and delivers actionable remediation guidance.

### What It Detects

- ✅ **Hidden Instructions** - HTML comments, zero-width characters, encoded payloads
- ✅ **Prompt Injection** - Instruction override, jailbreaks, role hijacking
- ✅ **Command Injection** - Unsafe shell execution, eval/exec vulnerabilities
- ✅ **Path Traversal** - Directory escape attempts, unauthorized file access
- ✅ **Data Exfiltration** - Network leaks, credential exposure, clipboard access
- ✅ **Dependency Risks** - Unpinned versions, typosquats, known CVEs
- ✅ **Supply Chain** - Remote code execution, untrusted sources
- ✅ **Tool Misuse** - Destructive operations, privilege escalation

## 📁 Installation

### Option 0: Codex Skill Installer (GitHub)

If you're using the Codex skill installer, point it at the repository `skills/` directory (the parent folder that contains one or more skill folders):

```bash
npx skills add Tharun-Balaji/audit-skills --path skills --yes --global
```

For CI/automation, you can optionally add `--yes --global` to avoid interactive prompts and target the global install path.

### Publishing notes for skills.sh

If you want this repo to be consumable by `skills.sh`/`npx skills add`:

- Keep each skill in `skills/<skill-name>/`
- Ensure each skill folder contains a valid `SKILL.md` with YAML frontmatter starting on line 1
- Keep bundled resources inside that same skill folder (for example `skills/audit-skills/references/...`)
- Push the branch to GitHub, then install from the GitHub repo with `--path skills`

### Option 1: User Skill (Recommended)

For personal use or custom security audits:

```bash
# Create the skill directory
mkdir -p /mnt/skills/user/audit-skills/references

# Copy the skill files
cp SKILL.md /mnt/skills/user/audit-skills/
cp vulnerability-checklist.md /mnt/skills/user/audit-skills/references/
cp report-template.md /mnt/skills/user/audit-skills/references/
cp README.md /mnt/skills/user/audit-skills/
```

### Option 2: Example Skill

For demonstration or testing:

```bash
# Create the skill directory
mkdir -p /mnt/skills/examples/audit-skills/references

# Copy the skill files
cp SKILL.md /mnt/skills/examples/audit-skills/
cp vulnerability-checklist.md /mnt/skills/examples/audit-skills/references/
cp report-template.md /mnt/skills/examples/audit-skills/references/
cp README.md /mnt/skills/examples/audit-skills/
```

### Option 3: Public Skill

For organization-wide deployment (requires appropriate permissions):

```bash
# Create the skill directory
mkdir -p /mnt/skills/public/audit-skills/references

# Copy the skill files
cp SKILL.md /mnt/skills/public/audit-skills/
cp vulnerability-checklist.md /mnt/skills/public/audit-skills/references/
cp report-template.md /mnt/skills/public/audit-skills/references/
cp README.md /mnt/skills/public/audit-skills/
```

## 📂 Directory Structure

After installation, your skill directory should look like this:

```
audit-skills/
├── SKILL.md                          # Main skill instructions
├── README.md                         # This file
└── references/
    ├── vulnerability-checklist.md    # Detailed detection patterns
    └── report-template.md            # Professional report format
```

### File Descriptions

| File | Purpose | Size |
|------|---------|------|
| `SKILL.md` | Core skill instructions with comprehensive audit workflow | ~15 KB |
| `vulnerability-checklist.md` | Detailed vulnerability patterns, search commands, code examples | ~45 KB |
| `report-template.md` | Professional security audit report template | ~20 KB |
| `README.md` | Documentation and installation guide | ~10 KB |

## ✅ CI Test Coverage

The GitHub Actions workflow (`.github/workflows/skills-installation-ci.yml`) currently covers:

1. **Skill layout validation** (`scripts/ci/validate-skills-install.sh`)
   - `skills/` directory exists and contains at least one skill folder
   - each skill contains `SKILL.md`
   - YAML frontmatter starts on line 1 and has a closing `---` delimiter
   - required `name:` field exists in frontmatter
   - local markdown links referenced by `SKILL.md` resolve to real files
   - skill folder can be copied into a simulated install root

2. **CLI installation flow validation** (`scripts/ci/test-npx-skills-add.sh`)
   - runs the documented install command non-interactively:
     `npx -y skills add <owner/repo> --ref <ref> --path skills --yes --global`
   - installs into an isolated temporary `HOME`/`CODEX_HOME`
   - detects installed skill across supported install roots
   - verifies installed `SKILL.md` and bundled reference files exist

This gives coverage for both **packaging correctness** and **real installer behavior** before merging to `main`.

## 🚀 Usage

### Basic Audit

Simply ask Claude to audit a skill:

```
Please audit the skill at /mnt/skills/user/my-skill for security vulnerabilities.
```

```
Review this skill for security issues and create a report.
```

```
Can you do a security audit on the docx skill?
```

### Comprehensive Audit

For a thorough review with detailed report:

```
Please perform a comprehensive security audit on /mnt/skills/user/data-processor including:
1. All vulnerability checks from the checklist
2. Full dependency analysis
3. Manual testing with malicious inputs
4. Professional report using the template
```

### Specific Vulnerability Check

To focus on specific security concerns:

```
Check /mnt/skills/user/web-scraper for:
- Prompt injection vulnerabilities
- Data exfiltration risks
- Network security issues
```

### Re-Audit After Changes

After implementing fixes:

```
I've updated the scripts in /mnt/skills/user/my-skill based on your recommendations. 
Please re-audit to verify all issues are resolved.
```

## 📖 How It Works

### Audit Workflow

1. **Discovery Phase** (5-10 min)
   - Lists all files in the skill directory
   - Identifies entry points and data flows
   - Maps file types and purposes

2. **Automated Scanning** (2-5 min)
   - Runs pattern matching for known vulnerabilities
   - Checks for hidden content and encoding
   - Scans for dangerous keywords and patterns

3. **Manual Code Review** (10-20 min)
   - Line-by-line analysis of all scripts
   - Traces user input handling
   - Verifies safety patterns and validation

4. **Dependency Analysis** (5-10 min)
   - Extracts package requirements
   - Checks versions and known CVEs
   - Validates external resources

5. **Testing** (5-10 min)
   - Executes scripts in sandbox environment
   - Tests with malicious inputs
   - Verifies error handling

6. **Reporting** (10-15 min)
   - Creates structured findings list
   - Develops specific remediations
   - Writes professional risk summary

**Total Time: 40-70 minutes per skill**

### Severity Levels

The skill uses a four-tier severity system:

| Severity | Description | Action Required |
|----------|-------------|-----------------|
| **CRITICAL** | Immediate security threat (RCE, data exfiltration) | ❌ Block deployment immediately |
| **HIGH** | Significant risk (unauthorized access, injection) | ⚠️ Must fix before approval |
| **MEDIUM** | Notable concern (weak validation, missing checks) | 📋 Should address before release |
| **LOW** | Minor issue (documentation, best practices) | ℹ️ Informational, optional fix |

## 💡 Examples

### Example 1: Basic Skill Audit

**User Request:**
```
Audit the skill at /mnt/skills/user/csv-analyzer
```

**Claude's Process:**
1. Reads `SKILL.md` to understand the audit workflow
2. Reads `references/vulnerability-checklist.md` for detection patterns
3. Navigates to `/mnt/skills/user/csv-analyzer`
4. Runs automated scans and manual review
5. Uses `references/report-template.md` to structure findings
6. Creates comprehensive report in `/mnt/user-data/outputs/`

**Output:**
```
SECURITY AUDIT REPORT: csv-analyzer
Overall Risk: MEDIUM
Findings: 0 Critical, 1 High, 2 Medium, 1 Low

HIGH-001: Command Injection in data processing script
File: scripts/process.py, Line 45
Evidence: subprocess.run(f"csvcut {user_file}", shell=True)
Recommendation: Use list arguments instead...

[Full report with remediations]
```

### Example 2: Targeted Vulnerability Check

**User Request:**
```
Check if /mnt/skills/user/web-scraper has any prompt injection vulnerabilities
```

**Claude's Process:**
1. Focuses on prompt injection section of checklist
2. Scans for override patterns, jailbreaks, role changes
3. Reviews how external content is handled
4. Reports specific findings

**Output:**
```
Prompt Injection Analysis for web-scraper:

CRITICAL-001: Indirect Prompt Injection Risk
The skill reads web content and includes it directly in prompts without sanitization.
This allows malicious websites to inject instructions.

Location: SKILL.md, lines 23-25
Evidence: "Read the scraped content and {scraped_text}"
Remediation: Add content sanitization, use clear boundaries...
```

### Example 3: Post-Fix Verification

**User Request:**
```
I fixed the issues in my skill. Can you verify all vulnerabilities are resolved?
```

**Claude's Process:**
1. Re-runs all previous checks
2. Verifies fixes are properly implemented
3. Tests with malicious inputs
4. Confirms no new issues introduced

**Output:**
```
Re-Audit Results:

✅ CRITICAL-001: RESOLVED
   - Command injection fixed with list arguments
   - Input validation added
   - Tested with malicious inputs - all blocked

✅ HIGH-001: RESOLVED
   - Path traversal protection implemented
   - Normalization and validation in place

Status: All previous issues resolved. No new issues found.
Recommendation: APPROVED for deployment
```

## 🛡️ Security Principles

The skill operates on these core security principles:

1. **Assume Adversarial Intent** - Skills may contain deliberately hidden threats
2. **Defense in Depth** - Multiple validation layers prevent single-point failures
3. **Least Privilege** - Skills should request minimal permissions
4. **Fail Secure** - When uncertain, flag for manual review
5. **Transparency** - All instructions must be visible and auditable

## 📋 Checklist Quick Reference

Common vulnerability patterns to detect:

### Hidden Instructions
```bash
grep -rn "<!--" .                    # HTML comments
grep -rn $'\u200B' .                 # Zero-width characters
grep -rE '[A-Za-z0-9+/]{40,}' .     # Base64 encoding
```

### Prompt Injection
```bash
grep -rni "ignore.*previous" .       # Override attempts
grep -rni "you are now" .            # Role changes
grep -rni "system prompt" .          # Prompt extraction
```

### Command Injection
```bash
grep -rn "os.system\|eval\|exec" .   # Dangerous functions
grep -rn "subprocess.*shell=True" .  # Shell injection
```

### Data Exfiltration
```bash
grep -rn "requests\.\|urllib" .      # Network calls
grep -rn "os.environ\|\.env" .       # Secrets access
grep -rn "\.post\(|POST" .           # Data uploads
```

### Path Traversal
```bash
grep -rn "\.\.\/\|\.\.\\\\" .        # Path escape attempts
grep -rn "open(\|os.path.join" .     # File operations
```

## 🎓 Best Practices for Skill Authors

### DO ✅

- **Validate all user inputs** - Whitelist allowed characters, lengths, formats
- **Use subprocess with list arguments** - Never `shell=True` with user data
- **Normalize file paths** - Check against allowed directories
- **Pin dependency versions** - Use exact versions, not ranges
- **Document security implications** - Be transparent about risks
- **Test with malicious inputs** - Try to break your own skill

### DON'T ❌

- **Never use eval() or exec()** on untrusted input
- **Never use os.system()** with user data
- **Never access /etc, /root, or credential files**
- **Never hardcode secrets** - Use secure environment management
- **Never hide instructions** - No HTML comments, encoding tricks
- **Never bypass Claude's safety** - No jailbreak patterns

## 🔧 Customization

### Adding Custom Checks

You can extend the skill by adding custom vulnerability patterns to `references/vulnerability-checklist.md`:

```markdown
### 8.X Custom Check for [Your Concern]

**What to Look For:**
[Description of the vulnerability]

**Search Patterns:**
```bash
grep -rn "your_pattern" .
```

**Examples:**
[Code examples]

**Validation:**
- [ ] Checklist items
```

### Customizing Report Format

Modify `references/report-template.md` to match your organization's requirements:

- Add custom sections
- Adjust severity definitions
- Include compliance frameworks
- Add approval workflows

### Integration with CI/CD

The skill can be integrated into automated pipelines:

```bash
# Example: Run audit as part of skill deployment
claude_cli "Please audit /path/to/skill and save report to /tmp/audit.md"

# Check exit status
if grep -q "CRITICAL\|HIGH" /tmp/audit.md; then
    echo "Security issues found - blocking deployment"
    exit 1
fi
```

## 📊 Metrics & Reporting

### Audit Coverage

A comprehensive audit should cover:

- [ ] 100% of files inventoried
- [ ] All scripts reviewed line-by-line
- [ ] All dependencies verified
- [ ] Manual testing performed
- [ ] Report generated with findings
- [ ] Remediations provided for all issues

### Quality Indicators

A high-quality audit includes:

- **Completeness** - All files and code paths examined
- **Specificity** - Exact file/line references for findings
- **Actionability** - Clear, implementable remediations
- **Testing** - Verification with malicious inputs
- **Documentation** - Professional report with risk assessment

## 🤝 Contributing

### Reporting New Vulnerability Patterns

Found a new attack vector? Help improve the skill:

1. Document the vulnerability pattern
2. Provide detection commands
3. Include safe/unsafe code examples
4. Submit via feedback mechanism

### Improving Detection

Suggestions for better detection:

- More efficient grep patterns
- Additional automated checks
- Better false positive filtering
- Improved remediation guidance

## 🆘 Troubleshooting

### Issue: Skill not triggering

**Problem:** Claude doesn't use the audit-skills automatically

**Solution:** 
- Explicitly mention "security audit" or "vulnerabilities"
- Reference the skill directly: "Use the audit-skills to audit..."
- Ensure the skill files are in the correct directory

### Issue: Incomplete audit

**Problem:** Audit skips files or sections

**Solution:**
- Verify all skill files are present and readable
- Check file permissions in the skill directory
- Manually request specific checks if needed

### Issue: False positives

**Problem:** Legitimate code flagged as vulnerable

**Solution:**
- Review the context - some patterns are safe in specific cases
- Document why the flagged code is actually safe
- Consider adding justification comments to the code

### Issue: Report too long

**Problem:** Generated report exceeds token limits

**Solution:**
- Request summary report first, then detailed findings
- Focus on high/critical issues only
- Audit smaller sections of the skill separately

## 📚 Additional Resources

### Related Documentation

- [OWASP Top 10](https://owasp.org/www-project-top-ten/) - Web application security risks
- [CWE Top 25](https://cwe.mitre.org/top25/) - Most dangerous software weaknesses
- [NIST Guidelines](https://www.nist.gov/cybersecurity) - Security best practices

### Learning Resources

- **Prompt Injection:** Understanding how LLMs can be manipulated
- **Command Injection:** Classic web security vulnerability
- **Supply Chain Security:** Dependency and third-party risks
- **Secure Coding:** OWASP Secure Coding Practices

## 📝 License

This skill is provided as-is for security auditing purposes. Use responsibly.

## 🔖 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-02 | Initial release with comprehensive audit capabilities |

## 📞 Support

For questions, issues, or suggestions about this skill:

1. Review this README thoroughly
2. Check the vulnerability checklist for specific patterns
3. Review example audits for guidance
4. Provide feedback through appropriate channels

## ⚠️ Disclaimer

This skill is designed to identify common security vulnerabilities in AI skills. While comprehensive, it should not be considered a complete security solution. Always:

- Review findings manually before taking action
- Consider context when evaluating security issues
- Supplement with human security expertise for critical skills
- Stay updated on new attack vectors and vulnerabilities

**Remember:** Security is an ongoing process, not a one-time check.

---

**audit-skills v1.0** - Comprehensive AI Skill Security Auditor  
*Protecting AI skills from vulnerabilities since 2024*
