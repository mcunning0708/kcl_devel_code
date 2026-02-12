# Enterprise Code Repository

This repository contains curated components extracted from a broader working environment.  
Only the `python/`, `R/` and `sql/` directories are included based on compliance, security, and 
version‑control governance requirements.

---

## 📁 Repository Structure

| Directory | Purpose |
|----------|----------|
| **python/** | Python modules, ETL pipelines, notebooks, utilities, unit tests, and service wrappers. |
| **sql/** | Database objects including schema migrations, stored procedures, views, DDL/DML scripts. |
| **Powershell/** | tentative Windows scripts. |
| **R/** | R scripts .... for BioResource processes /DML scripts. |

All other top‑level directories from the original workspace (e.g., `PowerShell/`, `R/`, `data/`, 
`eclipse/`, `github/`) are **explicitly excluded** from version control.

---

## 🏛 Governance & Compliance

This repository follows enterprise engineering standards, including:

- Version control hygiene (no sensitive data, tokens, credentials, dumps, or logs)
- Mandatory code review (pull requests only; no direct commits to `main`)
- Automated linting, formatting, and testing (CI/CD recommended)
- Consistent directory structure across services and pipelines
- Traceability and auditability of changes

---

## 🚀 Getting Started

1. **Clone the repo:**
   \`\`\`bash
   git clone <REPO URL>
   cd <REPO NAME>
   \`\`\`

2. **Python Environment Setup (if applicable):**
   \`\`\`bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   \`\`\`

3. **SQL Workflow Guidance:**
   - Store schema migrations in timestamped folders
   - Keep environment‑specific configs **out** of version control
   - Validate scripts using static SQL linters (sqlfluff recommended)

---

## 🤝 Contributing

- Branch naming: \`feature/*\`, \`bugfix/*\`, \`hotfix/*\`
- Commit messages follow the **Conventional Commits** standard
- Pull requests require:
  - Reviewer approval
  - Lint + test checks passing

