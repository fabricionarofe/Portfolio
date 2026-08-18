# WP Plugin: Financial Quotes - WordPress Financial Quotes Plugin

[![PHP](https://img.shields.io/badge/PHP-7.2+-777BB4?style=flat-square&logo=php&logoColor=white)](https://php.net)
[![WordPress](https://img.shields.io/badge/WordPress-Compatible-21759B?style=flat-square&logo=wordpress&logoColor=white)](https://wordpress.org)
[![OOP](https://img.shields.io/badge/Architecture-OOP-orange?style=flat-square)](#)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)](#)

A WordPress plugin built entirely with Object-Oriented PHP (OOP). It registers a custom Shortcode that renders a financial currency quote widget anywhere on the site — demonstrating mastery of WordPress Hooks (Actions & Filters), plugin architecture, and clean PHP class design.

---

## Table of Contents
- [About the Project](#about-the-project)
- [How It Works](#how-it-works)
- [Plugin Structure](#plugin-structure)
- [Using the Shortcode](#using-the-shortcode)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Technical Highlights](#technical-highlights)

---

## About the Project

This plugin was developed as a portfolio demonstration of professional-level WordPress plugin development. Rather than the common approach of writing procedural code directly in a plugin file, this plugin is fully encapsulated in a PHP class — following the same architectural patterns used by major commercial plugins.

**What it does:**
- Registers a [cotacao_moeda] shortcode that can be placed in any WordPress page, post, or widget area.
- Renders a clean, styled financial quote widget showing the current exchange rate for a given currency against the Brazilian Real (BRL).
- All logic is self-contained in a PHP class — no global variable pollution.

---

## How It Works

WordPress plugins communicate with the core system through a system called **Hooks**:

- **Actions** — Let you *execute code* at a specific point in the WordPress lifecycle.
- **Filters** — Let you *modify data* before it is saved or displayed.

This plugin uses both:
`php
add_shortcode('cotacao_moeda', [, 'render_shortcode']); // Registers the shortcode
add_action('wp_head', [, 'add_inline_styles']);          // Injects CSS into the <head>
`

**Full lifecycle:**
`	ext
[WordPress Init] -> [Plugin Loaded] -> [Class Instantiated] -> [Hooks Registered]
     |
     v
[User visits page with [cotacao_moeda]] -> [Shortcode renders widget HTML + CSS]
`

---

## Plugin Structure

`	ext
wp-currency-quote-plugin/
|
|-- includes/
|   |-- class-cotacao-widget.php   # Main plugin class (OOP logic, hooks, rendering)
|
|-- wp-plugin-cotacoes.php         # Plugin bootstrapper (WordPress metadata + class loader)
|-- README.md                      # This file
`

---

## Using the Shortcode

After installing and activating the plugin, use the shortcode in any page or post.

**Default (USD/BRL):**
`	ext
[cotacao_moeda]
`

**With specific currency:**
`	ext
[cotacao_moeda moeda="EUR"]
[cotacao_moeda moeda="GBP"]
`

Supported currencies in the mock data: USD, EUR, GBP.
> **Note:** The current version uses mock data. In production, this would be replaced with a real-time API call using wp_remote_get() and WordPress Transients for caching.

---

## Prerequisites

- **WordPress 5.0+**
- **PHP 7.2+**
- A local WordPress installation (XAMPP recommended)

---

## Installation

### Option A — Manual (Development)
1. Clone or download this repository.
2. Copy the wp-currency-quote-plugin folder to your WordPress plugins directory:
   `	ext
   C:\xampp\htdocs\your-wordpress-site\wp-content\plugins\wp-currency-quote-plugin\
   `
3. Open your WordPress admin panel at http://localhost/your-wordpress-site/wp-admin.
4. Navigate to **Plugins** -> Find **"Cotacoes Financeiras (Portfolio Senior)"** -> Click **Activate**.

### Option B — ZIP Upload
1. Compress the wp-currency-quote-plugin folder into a .zip file.
2. In WordPress admin, go to **Plugins -> Add New -> Upload Plugin**.
3. Select the .zip file and click **Install Now**, then **Activate**.

---

## How to Test

1. Ensure the plugin is active in your WordPress dashboard.
2. Go to **Pages** -> **Add New**.
3. Type [cotacao_moeda moeda="EUR"] in the editor.
4. Publish the page.
5. **Expected Output:** View the page on the front-end. You should see a formatted box displaying the current exchange rate for the Euro. Inspect the page source to see the dynamically injected CSS via wp_head.

---

## Technical Highlights

- **Full OOP Encapsulation:** The entire plugin logic lives inside the Cotacao_Widget class — no global functions, no global variables. Follows the WordPress Codex best practices for modern plugin development.
- **WordPress Hooks Mastery:** Demonstrates both dd_shortcode() (custom shortcode registration) and dd_action('wp_head', ...) (injecting assets into the page head) — the two most fundamental extension points in WordPress.
- **Output Buffering:** The shortcode render method uses ob_start() / ob_get_clean() for clean HTML output capture — a standard technique for complex shortcode rendering.
- **esc_html() on Output:** All dynamic values rendered in the widget are escaped with esc_html(), following WordPress security standards.
- **Extensible Design:** The etch_mock_cotacoes() method is clearly separated — showing exactly where a real API integration would go in production.
