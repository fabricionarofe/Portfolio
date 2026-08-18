# 🏛️ Sistema Patrimônio — Asset Management System

[![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)](#)

> A corporate tool for controlling, auditing, and efficiently managing an organization's physical and digital assets — built for institutional environments where accurate patrimony records are a legal and operational requirement.

---

## 📖 Table of Contents
- [About the Project](#-about-the-project)
- [How It Works](#-how-it-works)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Installation & Setup](#-installation--setup)
- [How to Run](#-how-to-run)
- [Technical Highlights](#-technical-highlights)

---

## 📌 About the Project

In institutional environments — such as government offices, universities, or large companies — managing physical assets (computers, furniture, vehicles, equipment) requires a systematic approach. Without proper tooling, assets get lost, depreciation goes untracked, and audits become nightmares.

**This system solves that.** It provides a centralized platform to register, track, and audit every asset in an organization, from acquisition to disposal.

**Key capabilities:**
- Register new assets with full metadata (description, acquisition date, value, location, responsible party).
- Track asset location and custody over time.
- Generate asset inventory reports for internal audits.
- Flag assets approaching scheduled maintenance or end-of-life.

---

## ⚙️ How It Works

`
[Asset Registration] → [Database Storage] → [Lifecycle Tracking] → [Audit Reports]
`

1. Each asset is registered with its full metadata into the system.
2. Custody transfers and location changes are recorded as events.
3. The system tracks the lifecycle state of each asset automatically.
4. Management can generate comprehensive inventory and audit reports at any time.

---

## 📁 Project Structure

`
SistemaPatrimonio/
│
├── assets/            # UI resources: icons, images
├── docs/              # Additional documentation and system manuals
├── outros/            # Auxiliary scripts and launch utilities
│   ├── app.R          # R-based reporting module
│   ├── iniciar_sistema.bat  # Windows launcher script
│   └── lancar_sistema.vbs   # VBS launcher for desktop shortcut
│
├── main.py            # Application entry point
├── requirements.txt   # Python dependencies
├── __version__.py     # Semantic versioning
├── .gitignore         # Files excluded from version control
└── README.md          # This file
`

---

## ✅ Prerequisites

- **Python 3.8+** — [Download](https://www.python.org/downloads/)
- **pip**
- *(Optional)* **R** — Only needed for the pp.R reporting module

---

## 📦 Installation & Setup

**Step 1 — Clone the repository:**
`ash
git clone https://github.com/fabricionarofe/portfolio.git
cd portfolio/SistemaPatrimonio
`

**Step 2 — Create and activate a virtual environment:**
`ash
python -m venv venv
venv\Scripts\activate   # Windows
# source venv/bin/activate  # Linux/macOS
`

**Step 3 — Install dependencies:**
`ash
pip install -r requirements.txt
`

**Step 4 — Quick Windows Launch (optional):**

For Windows users, a launcher script is included. Double-click outros/iniciar_sistema.bat to start the application without opening a terminal.

---

## ▶️ How to Run

`ash
python main.py
`

---

## 🔬 Technical Highlights

- **Multi-format Reporting:** In addition to the Python application, an R script (pp.R) provides statistical reporting capabilities — demonstrating polyglot programming and data analysis depth.
- **Desktop Integration:** Windows .bat and .vbs launcher files make the system accessible to non-technical users without a terminal.
- **Clean Separation of Concerns:** UI, business logic, and data layers are separated into distinct modules.
- **Audit-Ready:** Every record change is tracked with timestamps, fulfilling traceability requirements common in public sector environments.
