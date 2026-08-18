# 🕷️ Web Scraping GDOC — Automated Data Extraction to Google Docs

[![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![Google APIs](https://img.shields.io/badge/Google%20Docs%20API-4285F4?style=flat-square&logo=google&logoColor=white)](https://developers.google.com/docs/api)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)](#)

> An automated data pipeline that scrapes structured information from web sources, processes it, and exports the clean output directly into Google Docs or Google Sheets — eliminating copy-paste workflows entirely.

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

This project automates the full data collection cycle: **scrape → process → export**. Instead of manually visiting websites, copying information, and pasting it into documents, this pipeline does everything programmatically — on demand or on a schedule.

**Real-world context:** Developed to automate the collection of public data for analysis and reporting, saving hours of manual data entry work per week.

**Key capabilities:**
- Scrapes target web pages using HTTP requests and HTML parsing.
- Cleans and normalizes raw scraped data.
- Authenticates with the Google Docs/Sheets API via service account.
- Writes the processed data into specified Google documents automatically.
- Configurable to target different URLs and document destinations.

---

## ⚙️ How It Works

`
[Target URL] → [HTTP Request] → [HTML Parser] → [Data Cleaner] → [Google API Client] → [Google Doc / Sheet]
`

1. The scraper fetches the HTML content of the target URL.
2. A parser (BeautifulSoup or similar) extracts the desired data elements.
3. The data is cleaned, normalized, and structured.
4. The Google API client authenticates using a service account.
5. The clean data is written directly to the target Google Doc or Sheet.

---

## 📁 Project Structure

`
web-scraping-gdoc/
│
├── src/               # Core scraping engine and Google API integration
├── config/            # API credentials configuration (NOT committed to Git)
├── docs/              # Technical documentation and reference material
├── public/            # Static assets or output samples
├── outros/            # Auxiliary scripts and one-off utilities
│
├── requirements.txt   # Python dependencies
├── __version__.py     # Semantic versioning
├── .gitignore         # Excludes credentials and .env files
└── README.md          # This file
`

---

## ✅ Prerequisites

- **Python 3.8+**
- **pip**
- A **Google Cloud Project** with the Docs API (or Sheets API) enabled
- A **Service Account** credentials JSON file from Google Cloud Console

---

## 📦 Installation & Setup

**Step 1 — Clone the repository:**
`ash
git clone https://github.com/fabricionarofe/portfolio.git
cd portfolio/web-scraping-gdoc
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

**Step 4 — Set up Google API credentials:**

> ⚠️ **This is the most critical step.** Without valid credentials, the pipeline cannot write to Google Docs.

1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create or select a project and enable the **Google Docs API** and/or **Google Sheets API**.
3. Create a **Service Account** and download the credentials JSON file.
4. Place the credentials file inside config/ and name it credentials.json.
5. Share your target Google Doc or Sheet with the service account email (Editor access).

> The config/ folder and all *.json credential files are listed in .gitignore and will **never** be committed.

---

## ▶️ How to Run

`ash
python src/__main__.py
`

---

## 🔬 Technical Highlights

- **Zero Manual Intervention:** Once configured, the entire pipeline runs unattended — from data collection to Google Doc population.
- **Credential Safety:** API keys and service account credentials are completely excluded from version control.
- **Modular Pipeline:** The scraping, cleaning, and export phases are implemented as separate, reusable modules.
- **Configurable Targets:** URLs and document IDs are managed via the config/ layer, keeping source code generic and reusable.
