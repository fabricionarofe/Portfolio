# 📋 Sistema de Contratos — Contract Management System

[![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white)](https://mysql.com)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)](#)

> A corporate administrative platform for managing public contracts with built-in traceability, auditability, and transparency — developed to serve the operational demands of a public municipal institution.

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

Managing institutional contracts manually — through spreadsheets and physical files — creates serious risks: missing renewal deadlines, misplacing documents, and lacking a full audit trail. This system was built to eliminate those risks.

**Real-world context:** Developed to support public contract management at the City Hall of Belém (SEGEP), where hundreds of contracts with different expiration dates and suppliers needed to be tracked simultaneously.

**What it does:**
- Centralizes all contract records in a structured database.
- Tracks contract status, expiration dates, and associated parties.
- Sends alerts for contracts approaching their expiration.
- Provides a full audit log of all changes and interactions.
- Generates reports for management review.

---

## ⚙️ How It Works

`
[Data Input] → [Validation Layer] → [MySQL Database] → [Business Logic (Status, Alerts)] → [Reports]
`

1. Contract data is entered through the application interface.
2. The system validates the input and stores records in a normalized MySQL database.
3. Business rules automatically calculate contract status (active, expiring, expired).
4. Alerts are triggered for contracts nearing expiration.
5. Management can generate structured reports for internal review and external audits.

---

## 📁 Project Structure

`
sistema-de-contratos/
│
├── assets/            # Visual resources: icons, images, global stylesheets
├── database/          # SQL schemas, migration scripts, and seed data
├── outros/            # Auxiliary modules and project-specific components
│
├── main.py            # Application entry point
├── requirements.txt   # Python dependencies
├── __version__.py     # Semantic versioning
├── .gitignore         # Secrets and local files excluded from version control
└── README.md          # This file
`

---

## ✅ Prerequisites

- **Python 3.8+**
- **MySQL Server** (version 8.0 recommended) — [Download](https://dev.mysql.com/downloads/mysql/)
- **pip**

---

## 📦 Installation & Setup

**Step 1 — Clone the repository:**
`ash
git clone https://github.com/fabricionarofe/portfolio.git
cd portfolio/sistema-de-contratos
`

**Step 2 — Create and activate a virtual environment:**
`ash
python -m venv venv
venv\Scripts\activate   # Windows
# source venv/bin/activate  # Linux/macOS
`

**Step 3 — Install Python dependencies:**
`ash
pip install -r requirements.txt
`

**Step 4 — Set up the database:**

Make sure MySQL is running, then create the database and import the schema:
`ash
mysql -u root -p
`
Inside the MySQL shell:
`sql
CREATE DATABASE sistema_contratos;
USE sistema_contratos;
SOURCE database/schema.sql;
`
Or use **MySQL Workbench** or **phpMyAdmin** to import the .sql file from the database/ folder.

**Step 5 — Configure the database connection:**

Locate the configuration file (inside outros/ or the root) and update the database credentials to match your local MySQL setup.

---

## ▶️ How to Run

`ash
python main.py
`

---

## 🔬 Technical Highlights

- **Normalized Database Design:** Schema follows normalization principles to eliminate data redundancy and ensure referential integrity.
- **No Hardcoded Credentials:** Database passwords and sensitive configuration are excluded via .gitignore.
- **DRY Architecture:** Business rules defined once in the logic layer, reused across the interface and reporting modules.
- **Audit Logging:** Every write operation is accompanied by a timestamp and user reference — a critical requirement in public sector systems.
