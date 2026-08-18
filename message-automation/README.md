# Scheduled Messaging Automation

[![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)](#)

A Python-based automation system designed to schedule and dispatch messages programmatically, significantly reducing manual operational overhead in repetitive communication workflows.

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

This project was developed to solve a recurring operational problem: the need to send standardized, scheduled messages to multiple recipients without human intervention every time.

**Real-world context:** Built to support internal workflows at the City Hall of Belem (SEGEP), where periodic notifications to teams and departments were previously done manually.

**What it does:**
- Reads a recipient list from a structured source (file or database).
- Composes messages from a configurable template.
- Dispatches messages on a schedule or on-demand trigger.
- Logs all actions for auditability.

---

## How It Works

`	ext
[Config / Template] -> [Recipient Source] -> [Scheduler] -> [Dispatch Engine] -> [Log]
`

1. The system reads the message template and recipient list.
2. A scheduler (cron-like or time-based trigger) determines when to run.
3. The dispatch engine sends the messages using the configured channel.
4. All operations are logged with timestamps for traceability.

---

## Project Structure

`	ext
message-automation/
|
|-- src/               # Core application logic and dispatch engine
|-- docs/              # Additional documentation and reference material
|-- outros/            # Auxiliary scripts and one-off utilities
|
|-- requirements.txt   # Python dependencies
|-- __version__.py     # Semantic versioning
|-- .gitignore         # Files and secrets excluded from version control
|-- README.md          # This file
`

---

## Prerequisites

- **Python 3.8+** - Download from python.org
- **pip** (Python package manager)

---

## Installation & Setup

1. **Clone the repository:**
   Open your terminal and run:
   `ash
   git clone https://github.com/fabricionarofe/portfolio.git
   cd portfolio/message-automation
   `

2. **Create and activate a virtual environment:**
   This ensures dependencies don't conflict with your global Python installation.
   `ash
   # On Windows
   python -m venv venv
   venv\Scripts\activate

   # On Linux / macOS
   python3 -m venv venv
   source venv/bin/activate
   `

3. **Install dependencies:**
   `ash
   pip install -r requirements.txt
   `

4. **Configure environment variables:**
   This project relies on environment variables for sensitive data. Look for a .env.example file (if provided) and copy it to .env:
   `ash
   # On Windows
   copy .env.example .env

   # On Linux / macOS
   cp .env.example .env
   `
   Open the .env file in a text editor and fill in your API keys, credentials, and settings. Note that .env is ignored by Git to prevent leaking secrets.

---

## How to Run

1. Ensure your virtual environment is activated (you should see (venv) in your terminal prompt).
2. Navigate to the project directory: cd portfolio/message-automation
3. Execute the main application file:
   `ash
   python src/__main__.py
   `
4. **Expected Output:** The console will display initialization logs. If messages are scheduled, it will show a waiting prompt or immediately begin iterating through the recipient list and dispatching messages. Check the generated .log files in the project folder for a complete audit trail.

---

## Technical Highlights

- **Clean Architecture:** Business logic is fully isolated in src/, keeping the entry point thin and testable.
- **No Hardcoded Secrets:** All sensitive credentials are managed via environment variables — never committed to the repository.
- **DRY Principle:** Template-based message composition avoids code duplication.
- **Audit Trail:** Every dispatch action is logged with a timestamp, making the system fully traceable.
