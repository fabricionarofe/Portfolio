# Sales & Services Platform

[![PHP](https://img.shields.io/badge/PHP-7.4+-777BB4?style=flat-square&logo=php&logoColor=white)](https://php.net)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white)](https://mysql.com)
[![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=flat-square&logo=html5&logoColor=white)](https://developer.mozilla.org/en-US/docs/Web/HTML)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)](#)

A transactional web platform for showcasing services, handling customer inquiries, and optimizing the digital purchasing experience for end users.

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

A full web platform built to serve as a digital storefront. It handles everything from displaying products and services to processing customer data — all from a custom-built backend without relying on a heavy CMS or e-commerce framework.

**Design philosophy:** Built lean and fast. Every page load is optimized, database queries are indexed, and the frontend delivers a clean user experience.

**Key features:**
- Responsive product/service showcase pages.
- Customer contact and inquiry forms with server-side validation.
- Backend administration for managing listed services.
- Database-driven dynamic content (no hard-coded product lists).
- Secure form submissions (protection against SQL Injection and XSS).

---

## How It Works

`	ext
[User (Browser)] -> [HTML/CSS/JS Frontend] -> [PHP Backend] -> [MySQL Database]
                                          ^
                                   [Server-Side Validation]
`

1. The user visits the platform in their browser.
2. PHP dynamically generates pages by fetching data from MySQL.
3. When a user submits a form, PHP validates and sanitizes all input before any database interaction.
4. The administration layer allows authorized users to manage the content.

---

## Project Structure

`	ext
sales-platform/
|
|-- assets/            # Images, fonts, and global CSS/JS files
|-- config/            # Environment configuration and database connection
|-- database/          # SQL schema and seed data
|-- docs/              # Additional documentation and diagrams
|-- public/            # Publicly accessible files (index.html, icons, static assets)
|-- outros/            # Project-specific auxiliary modules
|
|-- requirements.txt   # Dependency manifest (if any Python utilities exist)
|-- __version__.py     # Version tracking
|-- .gitignore         # Secrets and environment files excluded from VCS
|-- README.md          # This file
`

---

## Prerequisites

- **PHP 7.4+** - Recommended: XAMPP (includes PHP, Apache, MySQL)
- **MySQL 8.0+**
- **Apache** (or any PHP-compatible web server)
- A modern web browser

---

## Installation & Setup

1. **Clone the repository:**
   `ash
   git clone https://github.com/fabricionarofe/portfolio.git
   cd portfolio/sales-platform
   `

2. **Set up a local server:**
   The easiest way is using XAMPP:
   - Download and install XAMPP from apachefriends.org.
   - Start the **Apache** and **MySQL** modules from the XAMPP Control Panel.
   - Move or symlink the sales-platform folder into C:\xampp\htdocs\.

3. **Set up the database:**
   - Open http://localhost/phpmyadmin in your browser.
   - Create a new database named site_vendas.
   - Click **Import**, select the SQL file from the database/ folder, and click **Execute**.

4. **Configure the database connection:**
   Open config/database.php (or the .env file if used) and update your credentials:
   `php
   define('DB_HOST', '127.0.0.1');
   define('DB_NAME', 'site_vendas');
   define('DB_USER', 'root');
   define('DB_PASS', '');  // Your MySQL password
   `

---

## How to Run

1. Make sure XAMPP (Apache and MySQL) is running.
2. Open your web browser.
3. Navigate to the local URL:
   `	ext
   http://localhost/sales-platform/public/
   `
4. **Expected Output:** You should see the homepage of the sales platform fully rendered. Navigation links, product listings, and contact forms should be fully functional.

---

## Technical Highlights

- **SQL Injection Prevention:** All database interactions use prepared statements — no raw user input is ever passed directly to a SQL query.
- **XSS Protection:** All dynamic output is sanitized with htmlspecialchars() before being rendered in the browser.
- **Separation of Concerns:** Configuration, business logic, database access, and views are maintained in isolated layers.
- **Optimized Queries:** Frequently-queried columns are indexed in the database schema. SELECT * is avoided in favor of explicit column selection.
