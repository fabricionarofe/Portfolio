# ⚙️ PHP CRUD System — Modern PHP 7.2+ with Semantic UI & MySQL

[![PHP](https://img.shields.io/badge/PHP-7.2+-777BB4?style=flat-square&logo=php&logoColor=white)](https://php.net)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white)](https://mysql.com)
[![Semantic UI](https://img.shields.io/badge/Semantic%20UI-35BDB2?style=flat-square)](https://semantic-ui.com)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)](#)

> A complete CRUD (Create, Read, Update, Delete) web application built with modern PHP 7.2+ best practices: PDO database access, Singleton pattern, MVC-inspired architecture, CSRF protection, and a polished Semantic UI interface.

---

## 📖 Table of Contents
- [About the Project](#-about-the-project)
- [Architecture Overview](#-architecture-overview)
- [Project Structure](#-project-structure)
- [Security Features](#-security-features)
- [Prerequisites](#-prerequisites)
- [Installation & Setup](#-installation--setup)
- [How to Run](#-how-to-run)
- [Technical Highlights](#-technical-highlights)

---

## 📌 About the Project

This project demonstrates senior-level PHP development skills by implementing a Course Management System — simulating the kind of internal tool used at the City Hall of Belém (SEGEP) to manage employee training programs.

It goes well beyond a simple tutorial CRUD by applying real-world architectural patterns and security hardening found in professional PHP applications.

**What it does:**
- Lists all registered courses in a clean, sortable table.
- Creates new courses through a validated Semantic UI modal form.
- Deletes courses with user confirmation.
- Persists all data in a MySQL database with optimized indexing.

---

## 🏗️ Architecture Overview

This project follows a simplified **MVC (Model-View-Controller)** pattern:

`
index.php      (View)        ← Renders HTML with Semantic UI components
actions.php    (Controller)  ← Receives POST, validates CSRF, routes to Model
classes/Curso.php (Model)    ← Handles all database logic via PDO
config/Database.php          ← Singleton PDO connection manager
database.sql                 ← MySQL schema with optimized indexes
`

---

## 📁 Project Structure

`
php-crud-semantic-ui/
│
├── config/
│   └── Database.php       # Singleton PDO connection class
│
├── classes/
│   └── Curso.php          # Model: CRUD operations with prepared statements
│
├── index.php              # Main view: table listing + modal form (Semantic UI)
├── actions.php            # Controller: CSRF validation + action routing
├── database.sql           # MySQL schema with indexes
└── README.md              # This file
`

---

## 🔒 Security Features

| Threat | Protection Applied |
|---|---|
| **SQL Injection** | All queries use PDO Prepared Statements with named parameters |
| **CSRF Attack** | Every form submits a session-bound token verified with hash_equals() |
| **XSS** | All dynamic output escaped with htmlspecialchars() at render time |
| **Direct URL Access** | ctions.php rejects all non-POST requests with an immediate redirect |
| **Type Safety** | Integer fields use PDO::PARAM_INT binding |

---

## ✅ Prerequisites

- **PHP 7.2+** (PHP 8.x also works)
- **MySQL 5.7+** or **MariaDB**
- **Apache** web server
- Recommended: **XAMPP** — [Download here](https://www.apachefriends.org/)

---

## 📦 Installation & Setup

**Step 1 — Clone the repository:**
`ash
git clone https://github.com/fabricionarofe/portfolio.git
cd portfolio/php-crud-semantic-ui
`

**Step 2 — Start your local server:**
1. Open the XAMPP Control Panel.
2. Start **Apache** and **MySQL**.
3. Move the php-crud-semantic-ui folder to C:\xampp\htdocs\.

**Step 3 — Create the database:**
1. Open http://localhost/phpmyadmin in your browser.
2. Click **New** and create a database named portfolio_cursos.
3. Select the new database, click **Import**, choose database.sql, and click **Execute**.

**Step 4 — Configure the database connection:**

Open config/Database.php and update the credentials if needed:
`php
private static System.Management.Automation.Internal.Host.InternalHost     = '127.0.0.1';
private static   = 'portfolio_cursos';
private static  = 'root';
private static  = ''; // your MySQL password
`

---

## ▶️ How to Run

With XAMPP running, open your browser and go to:
`
http://localhost/php-crud-semantic-ui/
`

You should see the Course Management interface with 3 pre-loaded sample records. Use the **New Course** button to add entries and the 🗑️ button to delete them.

---

## 🔬 Technical Highlights

- **PDO Singleton Pattern:** A single, reusable database connection managed through a Singleton class — avoiding redundant connections and centralizing error handling.
- **Prepared Statements Only:** No raw SQL string concatenation anywhere in the codebase. The industry standard for preventing SQL Injection.
- **CSRF Token with hash_equals():** Timing-safe comparison prevents timing attack exploits.
- **Data Stored Raw, Escaped on Output:** Follows the correct "output escaping" principle — data is stored as-is in the database and only escaped when rendered to HTML.
- **Semantic UI Components:** Native Semantic UI Modal, Table, Dropdown, Labels, and Buttons loaded via CDN — no custom CSS clutter.
