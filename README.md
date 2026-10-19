# Extensions Filter for Cotonti

A plugin for filtering and searching extensions (modules and plugins) in the Cotonti CMF administration panel.

**Author:** https://github.com/webitproff/

**Repository:** https://github.com/webitproff/extensionfilter-cotonti

**License:** BSD-3-Clause

**Version:** 1.0.3

**Compatibility:** Cotonti v1.0+, PHP 8.5+, MySQL 8.4

---

<img width="1920" height="1080" alt="extensionfilter_004" src="https://github.com/user-attachments/assets/8785dba6-85a5-4813-bf2f-fbf562b6219d" />
<img width="1920" height="1080" alt="extensionfilter_001" src="https://github.com/user-attachments/assets/3b71e503-3412-41b2-a039-7898f63747b9" />
<img width="1920" height="1080" alt="extensionfilter_002" src="https://github.com/user-attachments/assets/1d5b7785-6bda-42ce-9bc7-b27557c973e5" />
<img width="1920" height="1080" alt="extensionfilter_003" src="https://github.com/user-attachments/assets/5682a4bb-73a1-4497-8cef-7df56d016461" />


---

## Table of Contents

1. [Introduction](#introduction)
2. [Purpose and Problems Solved](#purpose)
3. [Features](#features)
4. [Requirements](#requirements)
5. [Installation](#installation)
6. [Uninstallation](#uninstall)
7. [Plugin Structure](#structure)
8. [Architecture and Operating Principle](#architecture)
9. [Entry Point: the tools hook](#hook-tools)
10. [URLs and Navigation](#urls)
11. [Filter Parameters](#filters)
12. [File Descriptions](#files)
13. [Setup File](#file-setup)
14. [Functions File (API)](#file-functions)
15. [Tools File (Admin Interface)](#file-tools)
16. [Template File](#file-tpl)
17. [Language Files](#file-lang)
18. [Template Tags: Complete Reference](#template-tags)
19. [Language Keys: Complete Reference](#lang-keys)
20. [Filtering Logic Step by Step](#filter-logic)
21. [Select Lists: How They Are Built](#select-lists)
22. [Installed and Missing Extensions](#installed-missing)
23. [Interaction with Cotonti Core](#core-interaction)
24. [Security](#security)
25. [Performance](#performance)
26. [Localization and Adding Languages](#localization)
27. [Extending Functionality](#extending)
28. [Debugging](#debugging)
29. [Compatibility and Limitations](#compatibility)
30 [Version History](#changelog)
31. [Support](#support)
32. [License](#license)

---

## <a name="introduction"></a>1. Introduction

**Extensions Filter** is a plugin for the Cotonti CMS that adds a dedicated filtering and searching tool for installed and available extensions to the administration panel. The plugin does not modify the core "Extensions" page; instead, it provides its own page accessible through the "Tools" section (`admin.php?m=other&p=extensionfilter`).

The plugin operates as a standalone handler of the `tools` hook that Cotonti invokes when the administrative "Tools" section is accessed. Unlike the `admin.php?m=extensions` page, which lists all extensions without search or filters, this page provides:

- switching between modules and plugins (two tabs);
- a dropdown list of codes to select a specific extension;
- a dropdown list of names to select by name;
- full-text search by code and name;
- a counter of found and total extensions;
- direct links to the details page of each extension in the standard core section `admin.php?m=extensions&a=details`.

The plugin does not create its own database tables, does not modify existing ones, does not register its own hooks other than `tools`, and requires no configuration after installation.

---

## <a name="purpose"></a>2. Purpose and Problems Solved

The Cotonti administration panel provides the standard `admin.php?m=extensions` page, which lists all modules and plugins split into sections. When many extensions are installed, this page has the following problems:

1. No search by code.
2. No search by name.
3. No search by keyword.
4. No dedicated view — only a general list with "Alphabetical" and "By category" tabs.
5. Navigating to a specific extension takes a long time when there are dozens or hundreds of extensions.

The plugin solves these problems by adding a separate page with filters. It does not duplicate core functionality; instead, it complements it by linking to standard details pages.

---

## <a name="features"></a>3. Features

As of version 1.0.3, the plugin provides:

### 3.1. Two Tabs

The page is divided into two tabs:

- **Modules** (`tab=module`, default).
- **Plugins** (`tab=plug`).

Tabs are switched via the `tab` GET parameter. If the parameter is absent or has an invalid value, `module` is used.

### 3.2. Dropdown List of Codes

The list is built from actual extension files in the directory (`modules/` or `plugins/`), merged with the list of extensions installed in the `cot_core` table. Values are extension codes (`page`, `market`, `extensionfilter`, etc.); displayed text is the same codes.

### 3.3. Dropdown List of Names

The list is built from the same data. Values are extension codes; displayed text is human-readable names (`Pages`, `Market PRO`, `Extensions Filter`). If the name in the setup file is empty, the code is displayed.

### 3.4. Keyword Search

A text field; search is case-insensitive over the combined string "code + space + name". It searches for a substring, not a prefix match.

### 3.5. Counter

Displays `found / total`. For example, `12 / 12` — all 12 extensions are found, `1 / 12` — 1 out of 12 is found.

### 3.6. Direct Links to Details

For each found extension, a link to the core details page: `admin.php?m=extensions&a=details&mod=<code>` for modules and `admin.php?m=extensions&a=details&pl=<code>` for plugins.

### 3.7. Installation Status

Each extension is marked with a status: "Installed" (green badge) or "Not installed" (grey badge). The status is determined by the presence of a record in the `cot_core` table.

---

## <a name="requirements"></a>4. Requirements

| Parameter | Value |
|---|---|
| CMS | Cotonti Siena v1.0.0 or higher |
| PHP | 8.5 or higher |
| MySQL | 8.4 or higher |
| Language | PHP 8.5: uses `?string`, `mixed` (implicitly), `mb_*` functions |
| Hooks | `tools` |
| DB tables | `cot_core` (to determine installed status) |
| Dependency plugins | none |
| Dependency modules | none |

The plugin requires no core modifications and does not use deprecated functions such as `$db->query` where unjustified. Standard Cotonti functions are used: `cot_import`, `cot_url`, `cot_selectbox`, `cot_extension_list_info`, `cot_auth`, `cot_display_messages`.

---

## <a name="installation"></a>5. Installation

### 5.1. Manual Installation

1. Download the archive or clone the repository:

```bash
git clone https://github.com/webitproff/extensionfilter-cotonti.git
```

2. Copy the `extensionfilter` folder into the Cotonti plugins directory:

```
<site root>/plugins/extensionfilter/
```

3. Open the administration panel:

```
https://<domain>/admin.php?m=extensions
```

4. Find "Extensions Filter" in the plugins list and click "Install".

5. After installation, the plugin appears in the "Tools" section (`admin.php?m=other`).

6. Open the plugin page:

```
https://<domain>/admin.php?m=other&p=extensionfilter
```

### 5.2. Installation via Cotonti Extension Manager

If your Cotonti version supports extension installation via the admin panel:

1. Open "Extensions" → "Plugins".
2. "Extensions Filter" appears in the list if files are already uploaded.
3. Click "Install".

### 5.3. What Happens During Installation

When "Install" is clicked, Cotonti performs the following sequence:

1. Reads the `[BEGIN_COT_EXT]` block from `extensionfilter.setup.php`.
2. Registers a record in the `cot_core` table (plugin code, name, version, type).
3. Registers a record in the `cot_plugins` table with the `tools` hook and the `extensionfilter/extensionfilter.tools.php` file.
4. Creates access-rights records in `cot_auth` for all groups (`Auth_guests=R`, `Auth_members=RW`, `Lock_guests=12345A`, `Lock_members=12345A`).
5. Registers rights at the plugin level (`plug` / `extensionfilter`).
6. Clears the cache.

After this, the `tools` hook pulls in `extensionfilter.tools.php` every time `admin.php?m=other` is opened, and if the current user is an administrator, includes it.

---

## <a name="uninstall"></a>6. Uninstallation

### 6.1. Via the Admin Panel

1. Open "Extensions" → "Plugins".
2. Click "Delete" next to "Extensions Filter".
3. Confirm the action.

During uninstallation, Cotonti:

1. Deletes the record from `cot_core`.
2. Deletes records from `cot_plugins` (unregisters the `tools` hook).
3. Deletes records from `cot_auth` (rights).
4. Deletes records from `cot_config` (plugin settings, if any).
5. Clears the cache.

The plugin **does not create its own tables**, so the "drop tables" step is skipped — nothing to drop.

### 6.2. Manual Uninstallation

If for some reason the plugin has been removed from the DB but files remain:

1. Delete the `plugins/extensionfilter/` folder entirely.
2. Open phpMyAdmin and run:

```sql
DELETE FROM cot_core WHERE ct_code = 'extensionfilter';
DELETE FROM cot_plugins WHERE pl_code = 'extensionfilter';
DELETE FROM cot_auth WHERE (auth_code = 'plug' AND auth_option = 'extensionfilter');
DELETE FROM cot_config WHERE config_owner = 'plug' AND config_cat = 'extensionfilter';
```

where `cot_` is the table prefix of your installation.

3. Clear the Cotonti cache (in the admin panel → "Cache" → "Clear all").

---

## <a name="structure"></a>7. Plugin Structure

```
plugins/extensionfilter/
├── extensionfilter.setup.php         — plugin registration (COT_EXT)
├── extensionfilter.tools.php         — tools hook handler, business logic
├── inc/
│   └── extensionfilter.functions.php — plugin API, dependency loading
├── lang/
│   ├── extensionfilter.ru.lang.php   — Russian localization
│   └── extensionfilter.en.lang.php   — English localization
└── tpl/
    └── extensionfilter.tools.tpl     — page template
```

Each file has a strictly defined role. Detailed descriptions below.

---

## <a name="architecture"></a>8. Architecture and Operating Principle

### 8.1. The Cotonti Hook Mechanism

Cotonti uses a hook system: extension files with a `[BEGIN_COT_EXT]` block and the `Hooks=<name>` parameter are registered in the `cot_plugins` table. At certain points, the core calls `cot_getextplugins(<hook name>)`, which returns a list of files registered for that hook. Each file is included via `include`.

The `tools` hook is invoked in `admin.php` (in the "Tools" section, `m=other`). The `other` module in the admin panel is specifically designed to display plugin tools that are not bound to a specific admin section.

### 8.2. How the tools Hook Works

Execution flow:

```
User opens /admin.php?m=other&p=extensionfilter
            │
            ▼
admin.php loads the admin/other controller
            │
            ▼
other.php looks for a plugin with code p=extensionfilter
            │
            ▼
Loads the list of files on the tools hook: cot_getextplugins('tools')
            │
            ▼
For each file on the tools hook, performs include
            │
            ▼
extensionfilter.tools.php executes in the scope of other.php
            │
            ▼
  - reads GET parameters (tab, fcode, fname, fkeyword)
  - builds data
  - renders the extensionfilter.tools.tpl template
  - assigns $pluginBody
            │
            ▼
other.php inserts $pluginBody into the main admin/other.tpl template
            │
            ▼
Returns the page HTML
```

### 8.3. Why the Variable Is Named $tuman

When `include $pl` is executed inside `admin.php`/`other.php`, the plugin lands in the scope where the `$t` variable is already defined — it is the main XTemplate instance of the admin panel. If you write `$t = new XTemplate(...)` inside the plugin, it will overwrite: the core will lose its reference to its template.

That is why a plugin handler must use a name other than `$t`. In `extensionfilter.tools.php`, `$t` is used for its own template, but since the include from the core happens in a different context (`include` inside a function), the plugin's `$t` **does not collide** with the core's `$t` — it is local within the scope of the included file. However, to avoid confusion and to align with the core style (see `contact.tools.php` in Cotonti), it is recommended to use a distinct name — for example, `$tuman`.

Version 1.0.3 uses `$t` inside the plugin, which is technically safe because `include $pl` executes in an isolated scope. If the core changes the inclusion method in the future, the variable will be overwritten. For robustness, it is recommended to rename `$t` to `$tuman` (or any other name not found in the core).

### 8.4. Data Flow

```
Filesystem (plugins/ or modules/)           cot_core table
            │                                       │
            ▼                                       ▼
   cot_extension_list_info($dir)         SELECT ct_code, ct_version
            │                                       │
            └──────────────┬────────────────────────┘
                           ▼
                   Array $extensions
                           │
                           ▼
                 Applying filters
                 (fcode → fname → fkeyword)
                           │
                           ▼
                   Array $filtered
                           │
                           ▼
                 Transferring to template via assign()
                           │
                           ▼
                     HTML rendering
```

---

## <a name="hook-tools"></a>9. Entry Point: the tools Hook

The `extensionfilter.tools.php` file is the only plugin hook. Header:

```php
<?php
/* ====================
[BEGIN_COT_EXT]
Hooks=tools
[END_COT_EXT]
==================== */
```

**Parameter meaning:**

- `Hooks=tools` — the only hook. No other hooks.
- On installation, Cotonti registers a record in `cot_plugins` with the fields:
  - `pl_hook = 'tools'`
  - `pl_code = 'extensionfilter'`
  - `pl_part = 'main'` (main part)
  - `pl_file = 'extensionfilter/extensionfilter.tools.php'`
  - `pl_active = 1`
  - `pl_module = 0` (plugin, not a module)

When `admin.php?m=other` is opened, the core finds all active plugins with the `tools` hook, sorts them by `pl_order` (default 10), and performs `include`.

---

## <a name="urls"></a>10. URLs and Navigation

### 10.1. Main URL

```
/admin.php?m=other&p=extensionfilter
```

With Cotonti's pretty URLs enabled, the actual URL is:

```
/<lang>/admin/other?p=extensionfilter
```

Example: `https://example.com/en/admin/other?p=extensionfilter`.

### 10.2. URLs with Tab Parameters

| Tab | URL |
|---|---|
| Modules (default) | `/admin.php?m=other&p=extensionfilter` |
| Plugins | `/admin.php?m=other&p=extensionfilter&tab=plug` |

### 10.3. URLs with Filters

Parameters are passed via GET. Example:

```
/admin.php?m=other&p=extensionfilter&tab=module&fcode=page&fname=&fkeyword=
```

All three parameters (`fcode`, `fname`, `fkeyword`) are always present in the form URL, even if empty. This simplifies parsing and makes the form predictable.

### 10.4. Links to Details Pages

The plugin provides direct links to Cotonti's standard details pages:

- for a module: `admin.php?m=extensions&a=details&mod=<code>`
- for a plugin: `admin.php?m=extensions&a=details&pl=<code>`

Example for the Pages module: `admin.php?m=extensions&a=details&mod=page`.

### 10.5. "Reset" Button

Leads to the current tab URL without filter parameters:

```
/admin.php?m=other&p=extensionfilter&tab=<current_tab>
```

---

## <a name="filters"></a>11. Filter Parameters

The plugin accepts three GET parameters. All three are optional and may be empty.

### 11.1. The `fcode` Parameter

| Property | Value |
|---|---|
| Source | `$_GET['fcode']` |
| Import | `cot_import('fcode', 'G', 'ALP')` |
| Type | string `[a-zA-Z0-9\-_]` |
| Default | empty string |
| Purpose | exact match with the extension code |

Using `ALP` (alphanumeric) ensures that only allowed characters can appear in the parameter. Cotonti codes comply with this pattern.

If `fcode` is not empty and matches one of the available codes, the array is filtered to a single element. If it does not match — the result is empty.

### 11.2. The `fname` Parameter

| Property | Value |
|---|---|
| Source | `$_GET['fname']` |
| Import | `cot_import('fname', 'G', 'TXT')` |
| Type | string, whitespace trimmed |
| Default | empty string |
| Purpose | exact match with the code (from the dropdown values) |

The names list stores the **code** as the `value` and the **name** as the displayed text. So the `fname` filter effectively filters by code, but the UI displays names. This is done for uniqueness — names can change, repeat, or contain special characters, whereas codes are unique and stable.

### 11.3. The `fkeyword` Parameter

| Property | Value |
|---|---|
| Source | `$_GET['fkeyword']` |
| Import | `cot_import('fkeyword', 'G', 'TXT')` |
| Type | string |
| Default | empty string |
| Purpose | substring search by code or name |

Search:

```php
$kw = mb_strtolower($fKeyword);
$hay = mb_strtolower($code . ' ' . (string)$info['Name']);
if (mb_strpos($hay, $kw) !== false) {
    // found
}
```

- Case-insensitive: `$kw` and `$hay` are lowercased.
- Multibyte: `mb_strtolower` and `mb_strpos` are used.
- Searches the combined string `code name`. Thus `market` will find both `market` (code) and `Market PRO` (name).

### 11.4. Application Order

Filters are applied in sequence, each narrowing the result:

1. `$filtered = $extensions` — initial array of all extensions.
2. If `fcode` is not empty → filter by code (leaves 0 or 1 element).
3. If `fname` is not empty → filter by code (from the names list).
4. If `fkeyword` is not empty → filter by substring.
5. `ksort` — sort by code.

Example:

- Initially: 12 extensions.
- `fcode=page` → 1 extension.
- `fname=page` → still the same 1 extension.
- `fkeyword=pag` → 1 extension.

If you apply `fcode=page&fname=market` — the result is empty, because after step 2 the array contains only `page`, and step 3 searches for `market`.

### 11.5. Result After Application

If the array is empty after all filters:

```php
if (count($filtered) === 0) {
    $t->parse('MAIN.NO_RESULTS');
}
```

The `NO_RESULTS` block is output with the text `{PHP.L.extensionfilter_no_results}` ("Nothing found").

---

## <a name="files"></a>12. File Descriptions

| File | Role | Approx. lines |
|---|---|---|
| `extensionfilter.setup.php` | registration | ~35 |
| `inc/extensionfilter.functions.php` | API, dependency loading | ~25 |
| `extensionfilter.tools.php` | business logic + rendering | ~130 |
| `tpl/extensionfilter.tools.tpl` | page template | ~80 |
| `lang/extensionfilter.ru.lang.php` | Russian localization | ~25 |
| `lang/extensionfilter.en.lang.php` | English localization | ~25 |

Each file is discussed in detail in the following sections.

---

## <a name="file-setup"></a>13. Setup File

**Path:** `plugins/extensionfilter/extensionfilter.setup.php`

**Purpose:** registers the plugin with the Cotonti system. On installation, Cotonti reads the `[BEGIN_COT_EXT]` block and transfers the data into the tables.

**Block structure:**

```
[BEGIN_COT_EXT]
Code=extensionfilter
Name=Extensions Filter
Category=administration
Description=Search and filter modules and plugins in admin panel
Version=1.0.3
Date=2026-10-19
Author=webitpoff
Copyright=(c) 2026 webitproff | https://github.com/webitproff/extensionfilter-cotonti
Notes=
Auth_guests=R
Lock_guests=12345A
Auth_members=RW
Lock_members=12345A
Requires_modules=
Requires_plugins=
Recommends_modules=
Recommends_plugins=
[END_COT_EXT]
```

**Parameters:**

| Parameter | Value | Destination |
|---|---|---|
| `Code` | `extensionfilter` | `cot_core.ct_code`, used as code in URL (`p=extensionfilter`) |
| `Name` | `Extensions Filter` | `cot_core.ct_title`, shown in the plugin list |
| `Category` | `administration` | used when sorting by category |
| `Description` | `Search and filter modules and plugins in admin panel` | plugin card description |
| `Version` | `1.0.3` | `cot_core.ct_version`, displayed and compared |
| `Date` | `2026-10-19` | release date |
| `Author` | `webitpoff` | author |
| `Copyright` | `(c) 2026 webitproff | ...` | copyright |
| `Auth_guests` | `R` | guest rights at install time |
| `Lock_guests` | `12345A` | locked guest rights |
| `Auth_members` | `RW` | member rights |
| `Lock_members` | `12345A` | locked member rights |
| `Requires_modules` | (empty) | dependency modules |
| `Requires_plugins` | (empty) | dependency plugins |
| `Recommends_modules` | (empty) | recommended modules |
| `Recommends_plugins` | (empty) | recommended plugins |

**Meaning of `Lock_guests=12345A` and `Lock_members=12345A`:**

Privilege levels 1–5 and administration (`A`) are locked for both groups. This means:

- Guests get Read (`R`), but administration is locked.
- Members get Read and Write (`RW`), but administration is also locked.
- Only the superadmin group (`COT_GROUP_SUPERADMINS`) has `A` and can open the page.

**Meaning of `Category=administration`:**

Used to display the plugin in the corresponding category on the "Extensions" page. In Cotonti's Russian localization it corresponds to "Administration".

**What Cotonti reads next from the setup file:**

- the `[BEGIN_COT_EXT_CONFIG]` section — if present. The plugin does not have it because the plugin has **no settings**.
- the `[BEGIN_COT_EXT_CONFIG_STRUCTURE]` section — also absent.
- `[BEGIN_COT_EXT]` — already covered.

After the `[BEGIN_COT_EXT]` block there is a standard PHPDoc comment identifying the file, version, author, and repository link.

---

## <a name="file-functions"></a>14. Functions File (API)

**Path:** `plugins/extensionfilter/inc/extensionfilter.functions.php`

**Purpose:** loads external plugin dependencies. In version 1.0.3 it contains no plugin-specific functions — only `require_once` for two Cotonti files.

**Contents:**

```php
defined('COT_CODE') or die('Wrong URL');

require_once cot_langfile('extensionfilter', 'plug');
require_once cot_incfile('extensions');
```

**Why `cot_incfile` and `cot_langfile`:**

- `cot_incfile('extensions')` — includes the `system/extensions.php` file, where `cot_extension_list_info`, `cot_extension_installed`, `cot_infoget`, and other helpers for working with extensions are defined. Without it, `cot_extension_list_info()` in `extensionfilter.tools.php` would fail.
- `cot_langfile('extensionfilter', 'plug')` — includes the plugin language file. Defines `$L['extensionfilter_title']`, `$L['extensionfilter_tab_module']`, etc.

**Where it is called:**

In `extensionfilter.tools.php` on the first line after `defined('COT_CODE')`:

```php
require_once cot_incfile('extensionfilter', 'plug');
```

Cotonti automatically resolves the path: `plugins/extensionfilter/inc/extensionfilter.functions.php`.

**Why a separate file is needed if it does nothing:**

A Cotonti convention: when a hook handler file needs functions, localization, or dependencies, they are extracted into `inc/<code>.functions.php`. This provides:

- consistency with other plugins;
- the ability in future versions to add functions without modifying the entry point;
- loading dependencies before the handler function is declared (although here the dependency is loaded via `require_once` in the entry point itself).

The plugin could have done without this file by placing `require_once` directly in `extensionfilter.tools.php`. It is kept for structural cleanliness and future expansion.

---

## <a name="file-tools"></a>15. Tools File (Admin Interface)

**Path:** `plugins/extensionfilter/extensionfilter.tools.php`

**Purpose:** the only `tools` hook handler. Contains all business logic.

**Structure (in execution order):**

### 15.1. COT_EXT Header

```php
<?php
/* ====================
[BEGIN_COT_EXT]
Hooks=tools
[END_COT_EXT]
==================== */
```

Sets the `tools` hook. Nothing else in the header — the plugin subscribes to no other hooks.

### 15.2. Protection Against Direct Access

```php
defined('COT_CODE') or die('Wrong URL.');
```

A standard Cotonti check. Without `COT_CODE` the file will not execute. This prevents direct URL access to the file.

### 15.3. Loading Dependencies

```php
require_once cot_incfile('extensionfilter', 'plug');
```

Includes `inc/extensionfilter.functions.php`, which in turn includes `system/extensions.php` and the language file.

### 15.4. Creating the Template

```php
$t = new XTemplate(cot_tplfile('extensionfilter.tools', 'plug', true));
```

- `cot_tplfile('extensionfilter.tools', 'plug', true)` — looks for the template file.
- First argument `'extensionfilter.tools'` — template name (without `.tpl`).
- Second argument `'plug'` — extension type. The search runs across several locations:
  - `themes/<admin_theme>/plugins/extensionfilter/extensionfilter.tools.tpl` (theme override)
  - `themes/<admin_theme>/plugins/extensionfilter.tools.tpl`
  - `plugins/extensionfilter/tpl/extensionfilter.tools.tpl` (plugin standard location)
- Third argument `true` — "admin mode": search in the admin theme. Without it, the template would be searched for in the user theme.

If the file is not found in any of those locations — `cot_tplfile` returns `false`, and `new XTemplate(false)` throws an error.

### 15.5. Title and Breadcrumbs

```php
$adminTitle = Cot::$L['extensionfilter_title'];
$adminPath[] = [cot_url('admin', ['m' => 'other', 'p' => 'extensionfilter']), Cot::$L['extensionfilter_title']];
```

- `$adminTitle` — sets the page title (`<title>` and `<h1>` in the admin header).
- `$adminPath[]` — adds a segment to the breadcrumbs. Format: `[url, title]`.

### 15.6. Tab Determination

```php
$tab = cot_import('tab', 'G', 'ALP');
if ($tab !== 'module' && $tab !== 'plug') {
    $tab = 'module';
}
```

- `cot_import('tab', 'G', 'ALP')` — reads the `tab` GET parameter, filtered as "letters only". If the parameter is missing — returns `null`.
- Validation: only `module` and `plug` are allowed.
- Default value — `module`.

### 15.7. Directory Determination

```php
$isModule = ($tab === 'module');
$dir = $isModule ? Cot::$cfg['modules_dir'] : Cot::$cfg['plugins_dir'];
```

- `$isModule` — boolean flag for subsequent branching.
- `$dir` — path to the modules or plugins folder. `Cot::$cfg['modules_dir']` and `Cot::$cfg['plugins_dir']` — absolute paths set by Cotonti during initialization.

### 15.8. Obtaining the Extension List

```php
$extensions = cot_extension_list_info($dir);
```

`cot_extension_list_info()` — a standard Cotonti function (in `system/extensions.php`) that:

1. Scans the given folder.
2. For each subfolder, looks for `<code>.setup.php`.
3. Reads the `[BEGIN_COT_EXT]` block via `cot_infoget`.
4. Returns an array `[code => info array]`.

Structure of each element:

```php
[
    'Code' => 'page',
    'Name' => 'Pages',
    'Description' => 'Static pages',
    'Version' => '1.0.0',
    'Date' => '2025-07-07',
    'Author' => 'Cotonti Team',
    'Copyright' => '...',
    'Notes' => '...',
    'Category' => 'content',
    'Auth_members' => 'RW',
    'Lock_members' => '',
    'Auth_guests' => 'R',
    'Lock_guests' => '12345A',
    'Requires_modules' => '',
    'Requires_plugins' => '',
    'Recommends_modules' => '',
    'Recommends_plugins' => ''
]
```

### 15.9. Obtaining Installed Extensions

```php
$installed = Cot::$db->query(
    'SELECT ct_code, ct_version FROM ' . Cot::$db->core . ' WHERE ct_plug = ?',
    [(int)!$isModule]
)->fetchAll(PDO::FETCH_KEY_PAIR);
```

- Query to the `cot_core` table.
- `ct_plug = 0` — module, `ct_plug = 1` — plugin.
- `(int)!$isModule` — cast: `0` for modules, `1` for plugins.
- `fetchAll(PDO::FETCH_KEY_PAIR)` — returns an associative array `[ct_code => ct_version]`.

Example result for modules:

```php
[
    'page' => '1.0.0',
    'users' => '1.0.0',
    'market' => '5.7.9',
]
```

### 15.10. Adding Installed Extensions Missing from the Folder

```php
foreach ($installed as $code => $version) {
    if (!isset($extensions[$code])) {
        $extensions[$code] = [
            'Code' => $code,
            'Name' => $code,
            'Description' => '',
            'Version' => $version,
            'Category' => 'misc-ext',
            'NotFound' => true,
        ];
    }
}
```

Situation: the extension is recorded in `cot_core`, but the folder with files is absent. This can happen when:

- the folder was deleted without removing the DB record;
- an error during update;
- manual intervention in the DB.

Such extensions are shown in the list marked `NotFound` with a name equal to the code (no setup file to read the name from). The `Category = 'misc-ext'` value is the standard one for "other".

### 15.11. Building the Select Lists

```php
$codes = [];
$names = [];
foreach ($extensions as $code => $info) {
    $codes[$code] = $code;
    $names[$code] = ($info['Name'] !== '') ? $info['Name'] : $code;
}
asort($codes, SORT_NATURAL | SORT_FLAG_CASE);
asort($names, SORT_NATURAL | SORT_FLAG_CASE);
```

- `$codes` — array `[code => code]`. Value equals the displayed text.
- `$names` — array `[code => name]`. Value is the code, display is the name.
- `asort` — sorts by value, preserving keys.
- `SORT_NATURAL | SORT_FLAG_CASE` — natural sort ignoring case. `page2` will come after `page10`? No, the opposite: `page2` before `page10` — that is exactly natural sort.

### 15.12. Reading Filter Parameters

```php
$fCode    = (string) cot_import('fcode', 'G', 'ALP');
$fName    = (string) cot_import('fname', 'G', 'TXT');
$fKeyword = (string) cot_import('fkeyword', 'G', 'TXT');
```

All parameters are taken via `cot_import`. The result is cast to string — `cot_import` returns `null` if the parameter is missing.

### 15.13. Applying Filters

Already discussed in section 11. Order:

```php
$filtered = $extensions;
if ($fCode !== '' && isset($filtered[$fCode])) { ... }
if ($fName !== '') { ... }
if ($fKeyword !== '') { ... }
ksort($filtered, SORT_NATURAL | SORT_FLAG_CASE);
```

### 15.14. Building Base URL Parameters

```php
$baseParams = ['m' => 'other', 'p' => 'extensionfilter', 'tab' => $tab];
```

Used for `cot_url()` when building `FORM_URL` and `RESET_URL`.

### 15.15. Assigning Global Tags

```php
$t->assign([
    'TAB_MODULE_URL'    => cot_url('admin', ['m' => 'other', 'p' => 'extensionfilter', 'tab' => 'module']),
    'TAB_PLUG_URL'      => cot_url('admin', ['m' => 'other', 'p' => 'extensionfilter', 'tab' => 'plug']),
    'TAB_MODULE_ACTIVE' => $isModule ? 'active' : '',
    'TAB_PLUG_ACTIVE'   => $isModule ? '' : 'active',
    'FORM_URL'          => cot_url('admin', $baseParams),
    'RESET_URL'         => cot_url('admin', $baseParams),
    'TAB'               => $tab,
    'SELECT_CODE'       => cot_selectbox($fCode, 'fcode', array_keys($codes), array_values($codes), true),
    'SELECT_NAME'       => cot_selectbox($fName, 'fname', array_keys($names), array_values($names), true),
    'KEYWORD'           => htmlspecialchars($fKeyword),
    'RESULTS_COUNT'     => count($filtered),
    'TOTAL_COUNT'       => count($extensions),
]);
```

Each field is detailed in section 18 "Template Tags".

### 15.16. Building Table Rows

```php
foreach ($filtered as $code => $info) {
    $isInstalled = isset($installed[$code]);
    $detailsUrl  = cot_url('admin', [
        'm' => 'extensions',
        'a' => 'details',
        ($isModule ? 'mod' : 'pl') => $code,
    ]);
    $t->assign([
        'ROW_CODE'         => htmlspecialchars($code),
        'ROW_NAME'         => htmlspecialchars((string)($info['Name'] !== '' ? $info['Name'] : $code)),
        'ROW_VERSION'      => htmlspecialchars((string)$info['Version']),
        'ROW_DESCRIPTION'  => htmlspecialchars((string)$info['Description']),
        'ROW_DETAILS_URL'  => $detailsUrl,
        'ROW_STATUS'       => $isInstalled ? Cot::$L['extensionfilter_status_installed'] : Cot::$L['extensionfilter_status_notinstalled'],
        'ROW_STATUS_CLASS' => $isInstalled ? 'success' : 'secondary',
    ]);
    $t->parse('MAIN.ROWS.ROW');
}
$t->parse('MAIN.ROWS');
```

Details:

- `ROW_STATUS` — text from the language file. Keys `extensionfilter_status_installed` and `extensionfilter_status_notinstalled`.
- `ROW_STATUS_CLASS` — Bootstrap CSS class. `success` — green badge, `secondary` — grey.
- `$t->parse('MAIN.ROWS.ROW')` — collects a row inside the `ROWS` block.
- `$t->parse('MAIN.ROWS')` **must** be present after the loop. Without this line the `ROWS` block will not be included in the final HTML and rows will not appear.

### 15.17. The "No Results" Block

```php
if (count($filtered) === 0) {
    $t->parse('MAIN.NO_RESULTS');
}
```

Parses the `NO_RESULTS` block if the array is empty after filtering. The template outputs the message.

### 15.18. Displaying Messages

```php
cot_display_messages($t);
```

A standard Cotonti function. Reads the message array (`cot_messages`) from the session, added via `cot_message` or `cot_error`, and passes them to the template (usually via `{FILE .../warnings.tpl}` at the top of the template).

### 15.19. Parsing the Main Block and Output

```php
$t->parse('MAIN');
$pluginBody = $t->text('MAIN');
```

- `$t->parse('MAIN')` — collects the root `MAIN` block.
- `$t->text('MAIN')` — returns the resulting HTML as a string.
- `$pluginBody` — the variable the core (`admin.php` / `other.php`) inserts into its main template at the `{PLUGIN_BODY}` tag.

**Mistake that must not be made:** writing `$adminTitle = $t->text('MAIN');`. `$adminTitle` is the page title (usually plain text), not the HTML body. Overwriting `$adminTitle` with the plugin HTML will put the entire markup into `<title>`. The correct way: `$pluginBody = ...`.

---

## <a name="file-tpl"></a>16. Template File

**Path:** `plugins/extensionfilter/tpl/extensionfilter.tools.tpl`

**Purpose:** XTemplate template for HTML rendering. Uses Cotonti XTemplate syntax.

### 16.1. Block Structure

```
MAIN
├── (nav-tabs)
├── (filter form)
├── (counter)
├── IF RESULTS_COUNT > 0
│   └── (list)
│       └── ROWS
│           └── ROW  ← loop
└── NO_RESULTS
```

`ROWS` — container into which `parse('MAIN.ROWS.ROW')` adds one row at a time. `parse('MAIN.ROWS')` inserts the container into MAIN.

### 16.2. Tabs

```html
<ul class="nav nav-tabs mb-3">
    <li class="nav-item">
        <a class="nav-link {TAB_MODULE_ACTIVE}" href="{TAB_MODULE_URL}">{PHP.L.extensionfilter_tab_module}</a>
    </li>
    <li class="nav-item">
        <a class="nav-link {TAB_PLUG_ACTIVE}" href="{TAB_PLUG_URL}">{PHP.L.extensionfilter_tab_plug}</a>
    </li>
</ul>
```

Bootstrap tabs. The active tab receives the `active` class; the inactive one — an empty class.

### 16.3. Form

```html
<form method="get" action="{FORM_URL}" class="card mb-3">
    <input type="hidden" name="m" value="other" />
    <input type="hidden" name="p" value="extensionfilter" />
    <input type="hidden" name="tab" value="{TAB}" />
    ...
</form>
```

- `method="get"` — parameters passed in the URL.
- Three hidden fields: `m`, `p`, `tab`. `m` and `p` are required by Cotonti (otherwise the URL won't point to the plugin). `tab` preserves the current tab.

### 16.4. Three Filter Fields

Three columns in `row g-2`:

```html
<div class="col-12 col-lg-4">
    <label class="form-label">{PHP.L.extensionfilter_filter_code}</label>
    {SELECT_CODE}
</div>
<div class="col-12 col-lg-4">
    <label class="form-label">{PHP.L.extensionfilter_filter_name}</label>
    {SELECT_NAME}
</div>
<div class="col-12 col-lg-4">
    <label class="form-label">{PHP.L.extensionfilter_filter_keyword}</label>
    <input type="text" name="fkeyword" value="{KEYWORD}" class="form-control" />
</div>
```

The first two fields are pre-rendered HTML (`cot_selectbox`). The third is a regular `<input>`, value inserted from `{KEYWORD}`.

### 16.5. Buttons

```html
<div class="mt-3">
    <button type="submit" class="btn btn-primary">{PHP.L.extensionfilter_btn_search}</button>
    <a href="{RESET_URL}" class="btn btn-outline-secondary">{PHP.L.extensionfilter_btn_reset}</a>
</div>
```

- "Search" — `submit`, submits the form.
- "Reset" — `<a>`, links to a URL without parameters.

### 16.6. Counter

```html
<div class="text-muted small mb-2">{RESULTS_COUNT} / {TOTAL_COUNT}</div>
```

Displays "found / total".

### 16.7. Results List

```html
<!-- IF {RESULTS_COUNT} > 0 -->
<div class="list-group list-group-flush border">
    <div class="list-group-item list-group-item-dark d-none d-lg-block">
        <div class="row fw-bold">
            <div class="col-lg-2">{PHP.L.extensionfilter_col_code}</div>
            <div class="col-lg-4">{PHP.L.extensionfilter_col_name}</div>
            <div class="col-lg-1">{PHP.L.extensionfilter_col_version}</div>
            <div class="col-lg-2">{PHP.L.extensionfilter_col_status}</div>
            <div class="col-lg-3">{PHP.L.extensionfilter_col_action}</div>
        </div>
    </div>
    <!-- BEGIN: ROWS -->
    <!-- BEGIN: ROW -->
    ...
    <!-- END: ROW -->
    <!-- END: ROWS -->
</div>
<!-- ENDIF -->
```

Header — `d-none d-lg-block` (hidden on mobile, visible on desktop). Rows — each in `list-group-item`.

### 16.8. Row

```html
<div class="list-group-item">
    <div class="row align-items-center">
        <div class="col-12 col-lg-2"><code>{ROW_CODE}</code></div>
        <div class="col-12 col-lg-4">
            <a href="{ROW_DETAILS_URL}" title="{PHP.L.extensionfilter_view}">
                <div>{ROW_NAME}</div>
                <div class="small">{ROW_DESCRIPTION}</div>
            </a>
        </div>
        <div class="col-12 col-lg-1">{ROW_VERSION}</div>
        <div class="col-12 col-lg-2">
            <span class="badge text-bg-{ROW_STATUS_CLASS}">{ROW_STATUS}</span>
        </div>
        <div class="col-12 col-lg-3">
            <!-- here you could add an "Open" button if needed -->
        </div>
    </div>
</div>
```

Note: the link covers the name and description, but not the code and not the version. Version — a separate column without a link. Code — `<code>` without a link (visually emphasizes "this is an identifier, not a link").

### 16.9. NO_RESULTS Block

```html
<!-- BEGIN: NO_RESULTS -->
<div class="alert alert-info">{PHP.L.extensionfilter_no_results}</div>
<!-- END: NO_RESULTS -->
```

Output if `count($filtered) === 0`. A Bootstrap alert for visibility.

---

## <a name="file-lang"></a>17. Language Files

**Path:** `plugins/extensionfilter/lang/extensionfilter.ru.lang.php` and `extensionfilter.en.lang.php`.

**Purpose:** defines UI strings. Cotonti loads the file matching the user language, with a fallback to English.

**Structure:**

```php
defined('COT_CODE') or die('Wrong URL.');

$L['extensionfilter_title'] = 'Extensions Filter';
$L['extensionfilter_tab_module'] = 'Modules';
// ...
```

All keys have the `extensionfilter_` prefix. This is a standard Cotonti requirement — to avoid collisions with other extensions.

**Loading:**

In `extensionfilter.functions.php`:

```php
require_once cot_langfile('extensionfilter', 'plug');
```

Cotonti looks for the file in this order:

1. `lang/<lang>/plugins/extensionfilter.<lang>.lang.php` (common language folder)
2. `plugins/extensionfilter/lang/extensionfilter.<lang>.lang.php` (plugin folder)
3. `plugins/extensionfilter/lang/extensionfilter.en.lang.php` (fallback)

For a Russian user, `extensionfilter.ru.lang.php` will be loaded. For French (no file) — `extensionfilter.en.lang.php`.

**List of keys** — see section 19.

---

## <a name="template-tags"></a>18. Template Tags: Complete Reference

### 18.1. Page Tags

| Tag | Type | Description |
|---|---|---|
| `{TAB_MODULE_URL}` | URL | Link to the "Modules" tab |
| `{TAB_PLUG_URL}` | URL | Link to the "Plugins" tab |
| `{TAB_MODULE_ACTIVE}` | string | CSS class of the active tab (`active` or empty) |
| `{TAB_PLUG_ACTIVE}` | string | Same for plugins |
| `{FORM_URL}` | URL | Form action URL (with current tab) |
| `{RESET_URL}` | URL | Reset URL (with current tab, no filters) |
| `{TAB}` | string | Current tab (`module` or `plug`) |

### 18.2. Filter Tags

| Tag | Type | Description |
|---|---|---|
| `{SELECT_CODE}` | HTML | Pre-rendered `<select name="fcode">` with code list |
| `{SELECT_NAME}` | HTML | Pre-rendered `<select name="fname">` with name list |
| `{KEYWORD}` | string | Value of `fkeyword` (escaped) |

### 18.3. Counter Tags

| Tag | Type | Description |
|---|---|---|
| `{RESULTS_COUNT}` | int | Number of found after filtering |
| `{TOTAL_COUNT}` | int | Total number of extensions on the tab |

### 18.4. Row Tags (inside `ROWS > ROW`)

| Tag | Type | Description |
|---|---|---|
| `{ROW_CODE}` | string | Extension code (e.g., `page`) |
| `{ROW_NAME}` | string | Name or code if name is absent |
| `{ROW_VERSION}` | string | Version from the setup file |
| `{ROW_DESCRIPTION}` | string | Description from the setup file |
| `{ROW_DETAILS_URL}` | URL | Link to `admin.php?m=extensions&a=details&...` |
| `{ROW_STATUS}` | string | "Installed" or "Not installed" |
| `{ROW_STATUS_CLASS}` | string | CSS class of the badge: `success` or `secondary` |

### 18.5. Language Tags `{PHP.L.*}`

All references to `$L[...]` in the template go through `{PHP.L.<key>}`. XTemplate automatically substitutes the value from the `$L` array or leaves it as-is if the key is missing.

Used in the template:

| Tag | Corresponds to `$L[...]` |
|---|---|
| `{PHP.L.extensionfilter_tab_module}` | `extensionfilter_tab_module` |
| `{PHP.L.extensionfilter_tab_plug}` | `extensionfilter_tab_plug` |
| `{PHP.L.extensionfilter_filter_code}` | `extensionfilter_filter_code` |
| `{PHP.L.extensionfilter_filter_name}` | `extensionfilter_filter_name` |
| `{PHP.L.extensionfilter_filter_keyword}` | `extensionfilter_filter_keyword` |
| `{PHP.L.extensionfilter_btn_search}` | `extensionfilter_btn_search` |
| `{PHP.L.extensionfilter_btn_reset}` | `extensionfilter_btn_reset` |
| `{PHP.L.extensionfilter_col_code}` | `extensionfilter_col_code` |
| `{PHP.L.extensionfilter_col_name}` | `extensionfilter_col_name` |
| `{PHP.L.extensionfilter_col_version}` | `extensionfilter_col_version` |
| `{PHP.L.extensionfilter_col_status}` | `extensionfilter_col_status` |
| `{PHP.L.extensionfilter_col_action}` | `extensionfilter_col_action` |
| `{PHP.L.extensionfilter_view}` | `extensionfilter_view` |
| `{PHP.L.extensionfilter_no_results}` | `extensionfilter_no_results` |

---

## <a name="lang-keys"></a>19. Language Keys: Complete Reference

### 19.1. Russian Localization (`extensionfilter.ru.lang.php`)

| Key | Value |
|---|---|
| `extensionfilter_title` | Фильтр расширений |
| `extensionfilter_tab_module` | Модули |
| `extensionfilter_tab_plug` | Плагины |
| `extensionfilter_filter_code` | Код |
| `extensionfilter_filter_name` | Название |
| `extensionfilter_filter_keyword` | Ключевое слово (код или название) |
| `extensionfilter_btn_search` | Поиск |
| `extensionfilter_btn_reset` | Сбросить |
| `extensionfilter_no_results` | Ничего не найдено |
| `extensionfilter_col_code` | Код |
| `extensionfilter_col_name` | Название |
| `extensionfilter_col_version` | Версия |
| `extensionfilter_col_status` | Статус |
| `extensionfilter_col_action` | Действие |
| `extensionfilter_status_installed` | Установлен |
| `extensionfilter_status_notinstalled` | Не установлен |
| `extensionfilter_view` | Открыть |

### 19.2. English Localization (`extensionfilter.en.lang.php`)

| Key | Value |
|---|---|
| `extensionfilter_title` | Extensions Filter |
| `extensionfilter_tab_module` | Modules |
| `extensionfilter_tab_plug` | Plugins |
| `extensionfilter_filter_code` | Code |
| `extensionfilter_filter_name` | Name |
| `extensionfilter_filter_keyword` | Keyword (code or name) |
| `extensionfilter_btn_search` | Search |
| `extensionfilter_btn_reset` | Reset |
| `extensionfilter_no_results` | Nothing found |
| `extensionfilter_col_code` | Code |
| `extensionfilter_col_name` | Name |
| `extensionfilter_col_version` | Version |
| `extensionfilter_col_status` | Status |
| `extensionfilter_col_action` | Action |
| `extensionfilter_status_installed` | Installed |
| `extensionfilter_status_notinstalled` | Not installed |
| `extensionfilter_view` | Open |

### 19.3. Naming Convention

All keys:

- start with `extensionfilter_`;
- are lowercase;
- use `_` between words;
- do not collide with core or other plugin keys.

When adding new keys, follow this pattern.

---

## <a name="filter-logic"></a>20. Filtering Logic Step by Step

A step-by-step breakdown with an example. Initial data: 12 modules.

### Step 1. Starting State

```php
$extensions = cot_extension_list_info($dir);
```

Result: an array of 12 modules. Order — as returned by `cot_extension_list_info` (alphabetical by code, typically).

### Step 2. The User Selected Nothing

`fcode=''`, `fname=''`, `fkeyword=''`.

```php
$filtered = $extensions;   // 12 elements
// all three ifs are skipped
ksort($filtered, ...);     // re-sort
// count($filtered) === 12
```

Result: 12 / 12, everything is displayed.

### Step 3. The User Selected `fcode=page`

```php
$filtered = $extensions;
if ($fCode !== '' && isset($filtered[$fCode])) {
    $filtered = [$fCode => $filtered[$fCode]];
}
// $filtered === ['page' => [...]]
// count === 1
```

Result: 1 / 12, only the `page` module is shown.

### Step 4. The User Selected `fname=page` (from the names list)

```php
$filtered = $extensions;
// step 3 is skipped (fcode empty)
if ($fName !== '') {
    $res = [];
    foreach ($filtered as $code => $info) {
        if ($code === $fName) {
            $res[$code] = $info;
        }
    }
    $filtered = $res;
}
// $filtered === ['page' => [...]]
```

Logic: `fname` contains the **code** (not the name). Comparison `$code === $fName` is exact.

### Step 5. The User Entered `fkeyword=market`

```php
$kw = 'market';
foreach ($filtered as $code => $info) {
    $hay = mb_strtolower($code . ' ' . $info['Name']);
    if (mb_strpos($hay, $kw) !== false) { ... }
}
```

- `market` (code) → `market market pro` → found.
- `Market PRO` (name) → `market market pro` → found (by code `market`).
- `marketing` (code) → `marketing something` → found.
- `promarket` (code) → `promarket something` → found (substring `market`).
- `pro` (name) → `market market pro` → found (`pro` inside `market pro`).

### Step 6. The User Entered `fcode=page&fkeyword=user`

After step 3, `$filtered` contains only `page`. At step 6 we check:

- Does `page` contain `user`? No.
- Does `Pages` contain `user`? No.

Result: 0 / 12, `NO_RESULTS` block is shown.

### Step 7. The User Entered `fkeyword=` (empty) — reset

```php
if ($fKeyword !== '') { ... }  // skipped
```

Result: back to 12 / 12.

### Step 8. General Principle

Each filter is a "refinement". If after any step the array becomes empty, the remaining steps simply change nothing except `fkeyword`, which can… No — if the array is empty, `foreach` does nothing, result remains empty.

---

## <a name="select-lists"></a>21. Select Lists: How They Are Built

### 21.1. `cot_selectbox` — a Standard Cotonti Function

```php
cot_selectbox($selected, $name, $values, $titles, $empty = false, $classes = '', $custom = '')
```

- `$selected` — currently selected value.
- `$name` — field name (`name="..."`).
- `$values` — array of `<option value="...">` values.
- `$titles` — array of displayed texts.
- `$empty` — if `true`, an empty `<option value="">` is added on top ("all" / "not selected").

### 21.2. Code List

```php
'SELECT_CODE' => cot_selectbox($fCode, 'fcode', array_keys($codes), array_values($codes), true)
```

- `$codes = ['page' => 'page', 'market' => 'market', 'users' => 'users']`.
- `array_keys($codes)` — `['page', 'market', 'users']`.
- `array_values($codes)` — `['page', 'market', 'users']`.
- `$empty = true` — adds `<option value="">` — "all" / "not selected".

**HTML output:**

```html
<select name="fcode" class="form-control">
    <option value=""></option>
    <option value="market">market</option>
    <option value="page">page</option>
    <option value="users">users</option>
</select>
```

Sorting by value — natural.

### 21.3. Name List

```php
'SELECT_NAME' => cot_selectbox($fName, 'fname', array_keys($names), array_values($names), true)
```

- `$names = ['page' => 'Pages', 'market' => 'Market PRO', 'users' => 'Users']`.
- `array_keys($names)` — `['page', 'market', 'users']` — codes in `value`.
- `array_values($names)` — `['Pages', 'Market PRO', 'Users']` — names as text.

**HTML output:**

```html
<select name="fname" class="form-control">
    <option value=""></option>
    <option value="market">Market PRO</option>
    <option value="page">Pages</option>
    <option value="users">Users</option>
</select>
```

**Important:** despite displaying names, the **code** is transmitted in the URL. This is done for reliability — the code is stable, the name can change, contain special characters or HTML.

### 21.4. Sorting

```php
asort($codes, SORT_NATURAL | SORT_FLAG_CASE);
asort($names, SORT_NATURAL | SORT_FLAG_CASE);
```

- `asort` — sorts by value, preserving keys.
- `SORT_NATURAL` — natural sort (numbers in strings compared as numbers).
- `SORT_FLAG_CASE` — case-insensitive.

Example: `page2`, `page10`, `Page1` are sorted as `Page1`, `page2`, `page10`.

---

## <a name="installed-missing"></a>22. Installed and Missing Extensions

### 22.1. Data Sources

Two independent sources:

1. **Filesystem** — `cot_extension_list_info($dir)` scans folders, finds `<code>.setup.php`, reads metadata.
2. **Database** — `cot_core` contains records for all installed extensions.

### 22.2. Possible States

| Files | `cot_core` record | What the plugin does |
|---|---|---|
| present | present | Shows, status "Installed" |
| present | absent | Shows, status "Not installed" |
| absent | present | Shows, status "Installed", name = code, `Category=misc-ext`, `NotFound=true` |
| absent | absent | Does not show (no data) |

Third row — exactly the case for which the following block was added in the loop:

```php
foreach ($installed as $code => $version) {
    if (!isset($extensions[$code])) {
        $extensions[$code] = [ ... 'NotFound' => true ];
    }
}
```

### 22.3. What "Not installed" Means

The extension is present on disk (folder, setup file) but not registered in `cot_core`. This is possible if:

- the administrator uploaded the files but did not click "Install";
- the plugin was removed from the DB, but files remain;
- this is a bundled module/plugin disabled by the administrator.

The plugin shows such extensions with a grey badge. The link to `admin.php?m=extensions&a=details&...` opens the page with the "Install" button.

### 22.4. What `NotFound = true` Means

Internal flag. Used only inside the plugin. Not directly output in the template. Affects the name (`Name = code`) and category. Used if in the future there is a need to filter by `NotFound`.

---

## <a name="core-interaction"></a>23. Interaction with Cotonti Core

### 23.1. Classes and Functions Used

| Function / class | Source | Purpose |
|---|---|---|
| `Cot::$db` | `system/Cot.php` | CotDB object |
| `Cot::$cfg` | `system/Cot.php` | Configuration (paths, version) |
| `Cot::$L` | `system/Cot.php` | Language strings |
| `Cot::$env` | `system/Cot.php` | Environment (`ext`, `location`, `type`) |
| `cot_import` | `system/functions.php` | Read GET/POST with filtering |
| `cot_url` | `system/functions.php` | URL generation |
| `cot_auth` | `system/functions.php` | Permission check |
| `cot_selectbox` | `system/forms.php` | `<select>` generation |
| `cot_display_messages` | `system/functions.php` | Message output |
| `cot_extension_list_info` | `system/extensions.php` | Extension list |
| `cot_langfile` | `system/functions.php` | Path to language file |
| `cot_incfile` | `system/functions.php` | Path to inc file |
| `cot_tplfile` | `system/functions.php` | Path to template |
| `XTemplate` | `system/xtemplate.php` | Templating engine |

### 23.2. What `cot_extension_list_info` Does

```php
function cot_extension_list_info($dir)
{
    $ext_list = [];
    clearstatcache();
    $dp = opendir($dir);
    while ($f = readdir($dp)) {
        $path = $dir . '/' . $f;
        if ($f[0] != '.' && is_dir($path) && file_exists("$path/$f.setup.php")) {
            $info = cot_infoget("$path/$f.setup.php", 'COT_EXT');
            if (!$info && cot_plugin_active('genoa')) {
                $info = cot_infoget("$path/$f.setup.php", 'SED_EXTPLUGIN');
            }
            if ($info == false) {
                $info = [ ... defaults ... ];
            }
            if (empty($info['Category'])) {
                $info['Category'] = 'misc-ext';
            }
            $ext_list[$f] = $info;
        }
    }
    closedir($dp);
    return $ext_list;
}
```

Returns `[code => field array]`. All fields the plugin reads (`Name`, `Version`, `Description`) come from here.

### 23.3. What `cot_tplfile` Does

```php
cot_tplfile('extensionfilter.tools', 'plug', true)
```

Searches the template file in this order:

1. `themes/admin/<admintheme>/plugins/extensionfilter/extensionfilter.tools.tpl`
2. `themes/admin/<admintheme>/plugins/extensionfilter.tools.tpl`
3. `plugins/extensionfilter/tpl/extensionfilter.tools.tpl`

Returns the path or `false`. `cot_tplfile` does not cache results — it scans the filesystem on every call (which is cheap due to the small number of variants).

### 23.4. What `cot_import` Does

```php
cot_import('tab', 'G', 'ALP')
```

1. Takes `$_GET['tab']`.
2. Applies the `ALP` filter (only `[a-zA-Z0-9\-_]`).
3. Returns the sanitized value or `null`.

If `$_GET['tab']` is not set — returns `null`.

### 23.5. What `cot_url` Does

```php
cot_url('admin', ['m' => 'extensions', 'a' => 'details', 'mod' => 'page'])
```

Builds a URL respecting Cotonti's pretty-URL settings. For `admin`, uses `admin.php`, adds parameters via `http_build_query`.

Result (without pretty URLs): `admin.php?m=extensions&a=details&mod=page`.
With pretty URLs and language: `/en/admin/extensions?m=extensions&a=details&mod=page` or shorter — depending on settings.

---

## <a name="security"></a>24. Security

### 24.1. Page Access

`admin.php?m=other` is an administrative section. Cotonti core already checks:

```php
list($usr['auth_read'], $usr['auth_write'], $usr['isadmin']) = cot_auth('admin', 'a');
cot_block($usr['isadmin']);
```

Thus only administrators can open the page. The plugin does not additionally check rights — this would be redundant.

In version 1.0.3 it is **correct that there is no** custom `cot_auth('plug', 'extensionfilter', 'A')` check. If it were added, the user would receive 403 because in the setup, `Lock_members=12345A` blocks `A` for members. Technically only the superadmin would gain access, which is excessive — a regular section admin should also see the tool.

### 24.2. SQL Injection

- `cot_extension_list_info` works with the filesystem, not SQL.
- The query `SELECT ct_code, ct_version FROM cot_core WHERE ct_plug = ?` uses a prepared statement via PDO. The `(int)` cast guarantees the type.
- Extension codes from GET (`fcode`) do not go into SQL — filtering is done in the PHP array.

### 24.3. XSS

- All user values (`$fCode`, `$fName`, `$fKeyword`) are escaped on HTML output:
  - `htmlspecialchars($fKeyword)` for `{KEYWORD}`;
  - `cot_selectbox` escapes values itself;
  - `ROW_CODE`, `ROW_NAME`, `ROW_VERSION`, `ROW_DESCRIPTION` — via `htmlspecialchars`.
- Names from setup files may potentially contain HTML. The plugin escapes them via `htmlspecialchars`, so tags will not execute — but also will not be displayed as HTML. If HTML in names needs to be allowed — separate logic is required.

### 24.4. CSRF

The form uses `method="get"`. GET forms do not need CSRF tokens because they do not change state. The plugin only reads data; no write operations are performed.

### 24.5. Path Traversal

The plugin does not accept paths from the user. `$dir` is fixed (`Cot::$cfg['modules_dir']` or `Cot::$cfg['plugins_dir']`). File reading via `cot_extension_list_info` is limited to this folder.

### 24.6. Information Disclosure

The page is visible only to administrators. No server information (paths, versions) is output on the page beyond what already exists in the standard "Extensions" section.

---

## <a name="performance"></a>25. Performance

### 25.1. Complexity

- Folder scan: O(N), where N is the number of subfolders (modules or plugins). Typically N < 100.
- Setup file reading: O(N) — each extension is read once.
- Filtering: O(N) for `fkeyword`, O(1) for `fcode` and `fname`.
- Sorting: O(N log N).

Total: O(N log N) at typical N < 100 — milliseconds.

### 25.2. Caching

The plugin **does not cache** results. Every page visit re-reads the filesystem and DB. This is:

- a plus — data is always fresh;
- a minus — with a large number of extensions (hundreds), the page may take longer.

In practice, Cotonti sites rarely have >100 extensions. If needed, caching can be added via `Cot::$cache`, but this is not in the current version.

### 25.3. XTemplate Cache

Cotonti caches compiled XTemplate templates. On the first request the template is parsed and compiled into a PHP file in `datas/cache/templates/`. On subsequent requests the cached version is used. If the template changes, the cache is invalidated automatically by file modification time.

---

## <a name="localization"></a>26. Localization and Adding Languages

### 26.1. How Loading Works

Cotonti looks for the language file in this order:

1. `lang/<current_lang>/plugins/extensionfilter.<current_lang>.lang.php`
2. `plugins/extensionfilter/lang/extensionfilter.<current_lang>.lang.php`
3. `plugins/extensionfilter/lang/extensionfilter.en.lang.php` (fallback)

### 26.2. Adding a New Language

1. Copy `extensionfilter.en.lang.php` to `extensionfilter.<code>.lang.php`, where `<code>` is the two-letter language code (`de`, `fr`, `uk`, etc.).
2. Translate the values.
3. Do not change key names.

**Example:**

`plugins/extensionfilter/lang/extensionfilter.de.lang.php`:

```php
<?php
defined('COT_CODE') or die('Wrong URL.');

$L['extensionfilter_title']                 = 'Erweiterungsfilter';
$L['extensionfilter_tab_module']            = 'Module';
$L['extensionfilter_tab_plug']              = 'Plugins';
$L['extensionfilter_filter_code']           = 'Code';
$L['extensionfilter_filter_name']           = 'Name';
$L['extensionfilter_filter_keyword']        = 'Schlüsselwort (Code oder Name)';
$L['extensionfilter_btn_search']            = 'Suchen';
$L['extensionfilter_btn_reset']             = 'Zurücksetzen';
$L['extensionfilter_no_results']            = 'Nichts gefunden';
$L['extensionfilter_col_code']              = 'Code';
$L['extensionfilter_col_name']              = 'Name';
$L['extensionfilter_col_version']           = 'Version';
$L['extensionfilter_col_status']            = 'Status';
$L['extensionfilter_col_action']            = 'Aktion';
$L['extensionfilter_status_installed']      = 'Installiert';
$L['extensionfilter_status_notinstalled']   = 'Nicht installiert';
$L['extensionfilter_view']                  = 'Öffnen';
```

### 26.3. Overriding in the Theme

If you need to change strings only for a specific admin theme, put the file in:

```
themes/admin/<theme>/lang/extensionfilter.<lang>.lang.php
```

Cotonti will pick it up before the standard one.

### 26.4. Pluralization

The current version does not use pluralization — all strings are singular. When extending (e.g., "Found N extensions"), you can use `cot_declension($n, $L['extensionfilter_found'])`.

---

## <a name="extending"></a>27. Extending Functionality

### 27.1. Adding a New Filter

Example: filter by category.

**Step 1.** In `extensionfilter.tools.php`:

```php
$fCategory = (string) cot_import('fcat', 'G', 'ALP');

$categories = [];
foreach ($extensions as $info) {
    if (!empty($info['Category'])) {
        $categories[$info['Category']] = $info['Category'];
    }
}

if ($fCategory !== '') {
    $res = [];
    foreach ($filtered as $code => $info) {
        if (($info['Category'] ?? '') === $fCategory) {
            $res[$code] = $info;
        }
    }
    $filtered = $res;
}

$t->assign('SELECT_CATEGORY', cot_selectbox($fCategory, 'fcat', array_keys($categories), array_values($categories), true));
```

**Step 2.** In the template:

```html
<div class="col-12 col-lg-3">
    <label class="form-label">{PHP.L.extensionfilter_filter_category}</label>
    {SELECT_CATEGORY}
</div>
```

**Step 3.** In the language files:

```php
$L['extensionfilter_filter_category'] = 'Category';
```

### 27.2. Adding Sorting

Example: sorting by version.

**Step 1.** In PHP:

```php
$sort = cot_import('sort', 'G', 'ALP');
if ($sort === 'version') {
    uasort($filtered, function ($a, $b) {
        return version_compare($a['Version'], $b['Version']);
    });
} else {
    ksort($filtered, SORT_NATURAL | SORT_FLAG_CASE);
}
$t->assign('SORT_VERSION_URL', cot_url('admin', $baseParams + ['sort' => 'version']));
```

**Step 2.** In the template — sort buttons.

### 27.3. Adding Pagination

With dozens of extensions pagination is not needed. With hundreds:

```php
list($pg, $d, $durl) = cot_import_pagenav('d', 25);
$total = count($filtered);
$pageItems = array_slice($filtered, $d, 25);

$pagenav = cot_pagenav('admin', $baseParams, $d, $total, 25);
$t->assign(cot_generatePaginationTags($pagenav));
```

In the template — `{PAGINATION}`, `{PREVIOUS_PAGE}`, `{NEXT_PAGE}`.

### 27.4. Adding an "Install" Action

Installation link: `admin.php?m=extensions&a=details&mod=<code>&b=install`. Cotonti core already handles this URL. The plugin only needs to build the link:

```php
$installUrl = cot_url('admin', ['m' => 'extensions', 'a' => 'details', $isModule ? 'mod' : 'pl' => $code, 'b' => 'install']);
```

### 27.5. Adding AJAX Filtering

**Step 1.** Add an `ajax` hook in a separate file `extensionfilter.ajax.php`:

```php
<?php
/* ====================
[BEGIN_COT_EXT]
Hooks=ajax
[END_COT_EXT]
==================== */
defined('COT_CODE') or die('Wrong URL.');

$a = cot_import('a', 'G', 'ALP');
if ($a === 'filter') {
    // filtering
    header('Content-Type: application/json');
    echo json_encode($result);
    exit;
}
```

**Step 2.** In the template — a JS handler that sends `fetch('/index.php?r=extensionfilter&a=filter&...')`.

**Step 3.** No change needed in `setup.php` — Cotonti will register the second hook automatically if you add a file with the appropriate `Hooks=ajax`.

### 27.6. What NOT to Do

- Do not add `cot_auth('plug', 'extensionfilter', 'A')` at the start of the file — this will block access for regular admins.
- Do not use `$t` — use `$tuman` or another name.
- Do not forget `$t->parse('MAIN.ROWS')` after the loop.
- Do not overwrite `$adminTitle` via `$t->text('MAIN')`.

---

## <a name="debugging"></a>28. Debugging

### 28.1. Template Not Loading

**Symptom:** page `admin.php?m=other&p=extensionfilter` opens but content is empty or "template not found".

**Check:**

1. File `plugins/extensionfilter/tpl/extensionfilter.tools.tpl` exists.
2. Filename is exactly `extensionfilter.tools.tpl`, not `extensionfilter.admin.tpl`, no case difference.
3. `cot_tplfile('extensionfilter.tools', 'plug', true)` returns the correct path.

Temporary check:

```php
var_dump(cot_tplfile('extensionfilter.tools', 'plug', true)); exit;
```

- If `false` — file absent or path wrong.
- If a path — file present but something with read permissions or contents.

### 28.2. "12 / 12, but no rows"

**Symptom:** counter shows 12, but the table is empty.

**Cause:** missing `$t->parse('MAIN.ROWS')` after the loop.

**Check:** in `extensionfilter.tools.php` after `foreach` the line `$t->parse('MAIN.ROWS')` must be present.

### 28.3. "404 on all other links"

**Symptom:** `admin.php?m=other&p=extensionfilter` opens, but clicking the "Plugins" tab goes to 404.

**Cause:** incorrect URL building. In version 1.0.3 all URLs are built via `cot_url('admin', ['m' => 'other', 'p' => 'extensionfilter', 'tab' => 'plug'])`, which gives `admin.php?m=other&p=extensionfilter&tab=plug`. This is correct.

Check that in `setup.php` the `[BEGIN_COT_EXT]` block has no `Order` or other parameters that break installation.

### 28.4. Filter Logic Does Not Trigger

**Symptom:** selected a code from the list, clicked "Search", but the result is unchanged.

**Check:**

1. The URL now contains `fcode=<code>`.
2. `cot_import('fcode', 'G', 'ALP')` returns the expected value.
3. The `$extensions` array contains this code (`isset($filtered[$fCode])`).

Debug:

```php
var_dump($fCode, isset($extensions[$fCode])); exit;
```

### 28.5. `$adminTitle` Contains HTML

**Symptom:** `<title>` displays `<div class="row">...`.

**Cause:** `$adminTitle = $t->text('MAIN');` instead of `$pluginBody = $t->text('MAIN');`.

**Fix:** replace with `$pluginBody`.

### 28.6. Cache

Always clear the Cotonti cache after editing PHP files or templates:

- admin panel → "Cache" → "Clear all";
- or delete the `datas/cache/templates/` folder (temporarily, until the next visit).

---

## <a name="compatibility"></a>29. Compatibility and Limitations

### 29.1. PHP Compatibility

| PHP | Compatibility |
|---|---|
| 8.5+ | Full |
| 8.4 | Full |
| 8.3 | Full |
| 8.2 | Full |
| 8.1 | Full |
| 8.0 | Full |
| 7.4 | Not guaranteed (uses `?string`, `mixed`, `match` in Cotonti core) |

The plugin code does not use PHP 8.5-specific constructs. The minimum version is determined by Cotonti (7.3+ for the core itself, but the repository declares 8.5+).

### 29.2. Cotonti Compatibility

| Cotonti version | Compatibility |
|---|---|
| 1.0.0+ | Full |
| 0.9.26 | Not guaranteed |

The plugin uses modern classes `Cot`, `Cot::$db`, `Cot::$cfg`, `Cot::$L`. Older Cotonti versions will require adaptation.

### 29.3. MySQL Compatibility

| MySQL | Compatibility |
|---|---|
| 8.4 | Full |
| 8.0 | Full |
| 5.7 | Full |

The plugin uses standard SQL via PDO. There are no MySQL 8.4-specific constructs.

### 29.4. Limitations

- **No caching** of results — with hundreds of extensions the page may take longer.
- **No pagination** — all extensions are displayed on one page.
- **No sort-by-column** — only by code (natural).
- **No AJAX** — filtering via page reload.
- **No separate search by description** — only by code and name.
- **One tab — one extension type** — the "modules" and "plugins" lists are separated, not mixed.

All these limitations are intentional: the plugin solves a specific task with minimal code.

---

## <a name="changelog"></a>30. Version History

### Version 1.0.3 (2026-10-19)

- Release in the repository `https://github.com/webitproff/extensionfilter-cotonti`.
- Stable version.
- Features: two tabs (modules/plugins), three filters (code, name, keyword), results table, details links.

### Version 1.0.2 (internal)

- Debug: fixed `$adminTitle = $t->text('MAIN')` → `$pluginBody = $t->text('MAIN')`.
- Debug: added `$t->parse('MAIN.ROWS')` after the loop.

### Version 1.0.1 (internal)

- Debug: removed the redundant `cot_auth('plug', 'extensionfilter', 'A')` check.

### Version 1.0.0 (2026-10-19)

- First release.
- Basic functionality.

---

## <a name="support"></a>31. Support

### 31.1. Repository

- **GitHub:** https://github.com/webitproff/extensionfilter-cotonti
- **Issues:** https://github.com/webitproff/extensionfilter-cotonti/issues
- **Pull Requests:** https://github.com/webitproff/extensionfilter-cotonti/pulls

### 31.2. Marketplace

- **Plugin page:** https://abuyfile.com/market/cotonti/plugs/extensionfilter
- **Forum:** https://abuyfile.com/forums/cotonti/custom/

### 31.3. How to Report a Bug

Create an Issue on GitHub specifying:

1. Plugin version (`1.0.3`).
2. Cotonti version (e.g., `1.0.0`).
3. PHP version (`8.5.0`).
4. MySQL version (`8.4.0`).
5. Reproduction steps.
6. Expected behavior.
7. Actual behavior.
8. Screenshot or error text.

---

## <a name="license"></a>32. License

The plugin is distributed under the **BSD-3-Clause** license.

Full text:

```
BSD 3-Clause License

Copyright (c) 2026, webitproff
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
```

**What is allowed:**

- Use in commercial and non-commercial projects.
- Modify.
- Distribute in source and binary form.
- Embed in other products.

**What is required:**

- Retain the copyright text in the sources.
- Reproduce the copyright in documentation (for binary builds).
- Do not use the author's name or product name without permission for promoting derivatives.

**What is not guaranteed:**

- Absence of bugs.
- Fitness for a particular purpose.
- Author's liability for any consequences.

---

## Appendix A. Full Project Structure

```
extensionfilter-cotonti/
├── README.md                           ← this file
├── LICENSE                             ← BSD-3-Clause
├── .gitignore
├── extensionfilter.setup.php
├── extensionfilter.tools.php
├── inc/
│   └── extensionfilter.functions.php
├── lang/
│   ├── extensionfilter.ru.lang.php
│   └── extensionfilter.en.lang.php
└── tpl/
    └── extensionfilter.tools.tpl
```

## Appendix B. Quick Start

```bash
# Clone
git clone https://github.com/webitproff/extensionfilter-cotonti.git

# Copy into Cotonti plugins
cp -r extensionfilter-cotonti /path/to/cotonti/plugins/extensionfilter

# Install via admin panel
# 1. Open https://yoursite.com/admin.php?m=extensions
# 2. Find "Extensions Filter"
# 3. Click "Install"

# Use
# Open https://yoursite.com/admin.php?m=other&p=extensionfilter
```

## Appendix C. Pre-Release Checklist

- [ ] All files are UTF-8 without BOM.
- [ ] All PHP files start with `<?php` with no space before it.
- [ ] All PHP files after `<?php` have `defined('COT_CODE') or die('Wrong URL.');`.
- [ ] Version in `setup.php` is updated.
- [ ] Version in PHPDoc blocks is updated.
- [ ] Language files contain all keys from `README.md`.
- [ ] Template uses all tags from `README.md`.
- [ ] `$pluginBody` at the end of the handler, not `$adminTitle`.
- [ ] `$t->parse('MAIN.ROWS')` after the row loop.
- [ ] Cotonti cache is cleared.
- [ ] Tested on all three states (modules, plugins, empty result).
- [ ] Tested with empty filters and with matching filters.
- [ ] Tested on installed and not-installed extension.
- [ ] URL encoding with Cyrillic characters in names is checked.
- [ ] Works on PHP 8.5.
- [ ] Works on MySQL 8.4.

---

**End of document.**
