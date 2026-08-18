# Asset Management System

[![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)](#)

A corporate tool for controlling, auditing, and efficiently managing an organization's physical and digital assets — built for institutional environments where accurate patrimony records are a legal and operational requirement.

---

## Table of Contents
- [About the Project](#about-the-project)
- [How It Works](#how-it-works)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [How to Run](#how-to-run)
- [Technical Highlights](#technical-highlights)

---

## About the Project

In institutional environments — such as government offices, universities, or large companies — managing physical assets (computers, furniture, vehicles, equipment) requires a systematic approach. Without proper tooling, assets get lost, depreciation goes untracked, and audits become nightmares.

**This system solves that.** It provides a centralized platform to register, track, and audit every asset in an organization, from acquisition to disposal.

**Key capabilities:**
- Register new assets with full metadata (description, acquisition date, value, location, responsible party).
- Track asset location and custody over time.
- Generate asset inventory reports for internal audits.
- Flag assets approaching scheduled maintenance or end-of-life.

---

## How It Works

`	ext
[Asset Registration] -> [Database Storage] -> [Lifecycle Tracking] -> [Audit Reports]
`

1. Each asset is registered with its full metadata into the system.
2. Custody transfers and location changes are recorded as events.
3. The system tracks the lifecycle state of each asset automatically.
4. Management can generate comprehensive inventory and audit reports at any time.

---

## Project Structure

`	ext
asset-management-system/
|
|-- assets/            # UI resources: icons, images
|-- docs/              # Additional documentation and system manuals
|-- outros/            # Auxiliary scripts and launch utilities
|   |-- app.R          # R-based reporting module
|   |-- iniciar_sistema.bat  # Windows launcher script
|   |-- lancar_sistema.vbs   # VBS launcher for desktop shortcut
|
|-- main.py            # Application entry point
|-- requirements.txt   # Python dependencies
|-- __version__.py     # Semantic versioning
|-- .gitignore         # Files excluded from version control
|-- README.md          # This file
`

---

## Prerequisites

- **Python 3.8+** - Download from python.org
- **pip**
- *(Optional)* **R** - Only needed for the pp.R reporting module

---

## Installation & Setup

1. **Clone the repository:**
   `ash
   git clone https://github.com/fabricionarofe/portfolio.git
   cd portfolio/asset-management-system
   `

2. **Create and activate a virtual environment:**
   `ash
   # Windows
   python -m venv venv
   venv\Scripts\activate

   # Linux / macOS
   python3 -m venv venv
   source venv/bin/activate
   `

3. **Install dependencies:**
   `ash
   pip install -r requirements.txt
   `

4. **Configuration:**
   If the system connects to a database, ensure you check the config or outros folder for a .env template or configuration file. Set your local database credentials there.

---

## How to Run

**Option A (Terminal):**
1. Activate the virtual environment.
2. Run the application:
   `ash
   python main.py
   `
3. **Expected Output:** The main application interface will load. You can navigate through the modules to register new assets or query existing ones.

**Option B (Windows Launcher):**
For end-users on Windows, you can simply double-click the outros/iniciar_sistema.bat file. This script automatically handles activating the environment and launching the Python process in the background.

---

## Technical Highlights

- **Multi-format Reporting:** In addition to the Python application, an R script (pp.R) provides statistical reporting capabilities — demonstrating polyglot programming and data analysis depth.
- **Desktop Integration:** Windows .bat and .vbs launcher files make the system accessible to non-technical users without a terminal.
- **Clean Separation of Concerns:** UI, business logic, and data layers are separated into distinct modules.
- **Audit-Ready:** Every record change is tracked with timestamps, fulfilling traceability requirements common in public sector environments.
