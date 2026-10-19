# Extensions Filter для Cotonti

Плагин фильтрации и поиска расширений (модулей и плагинов) в административной панели Cotonti CMF.

**Репозиторий:** https://github.com/webitproff/extensionfilter-cotonti

**Лицензия:** BSD-3-Clause

**Версия:** 1.0.3

**Совместимость:** Cotonti v1.0+, PHP 8.5+, MySQL 8.4

---

## Содержание

1. [Введение](#introduction)
2. [Назначение и решаемые задачи](#purpose)
3. [Возможности](#features)
4. [Требования](#requirements)
5. [Установка](#installation)
6. [Удаление](#uninstall)
7. [Структура плагина](#structure)
8. [Архитектура и принцип работы](#architecture)
9. [Точка входа: хук tools](#hook-tools)
10. [URL-адреса и навигация](#urls)
11. [Параметры фильтрации](#filters)
12. [Описание файлов](#files)
13. [Файл setup](#file-setup)
14. [Файл functions (API)](#file-functions)
15. [Файл tools (админка)](#file-tools)
16. [Шаблон tpl](#file-tpl)
17. [Языковые файлы](#file-lang)
18. [Теги шаблона: полный справочник](#template-tags)
19. [Языковые ключи: полный справочник](#lang-keys)
20. [Логика фильтрации по шагам](#filter-logic)
21. [Списки select: как формируются](#select-lists)
22. [Работа с установленными и отсутствующими расширениями](#installed-missing)
23. [Взаимодействие с ядром Cotonti](#core-interaction)
24. [Безопасность](#security)
25. [Производительность](#performance)
26. [Локализация и добавление языков](#localization)
27. [Расширение функционала](#extending)
28. [Отладка](#debugging)
29. [Совместимость и ограничения](#compatibility)
30. [История версий](#changelog)
31. [Поддержка](#support)
32. [Лицензия](#license)

---

## <a name="introduction"></a>1. Введение

**Extensions Filter** — это плагин для CMS/Cotonti, который добавляет в административную панель отдельный инструмент фильтрации и поиска по установленным и доступным расширениям. Плагин не изменяет существующую страницу «Расширения» ядра, а предоставляет собственную страницу, доступную через раздел «Инструменты» (`admin.php?m=other&p=extensionfilter`).

Плагин работает как самостоятельный обработчик хука `tools`, который Cotonti вызывает при обращении к административному разделу «Инструменты». В отличие от страницы `admin.php?m=extensions`, где выводятся все расширения без поиска и фильтров, данная страница даёт:

- переключение между модулями и плагинами (две вкладки);
- выпадающий список кодов для выбора конкретного расширения;
- выпадающий список названий для выбора по имени;
- полнотекстовый поиск по коду и названию;
- счётчик найденных и общего числа расширений;
- прямые ссылки на страницу сведений о каждом расширении в стандартном разделе ядра `admin.php?m=extensions&a=details`.

Плагин не создаёт своих таблиц в базе данных, не изменяет существующие, не регистрирует собственных хуков, кроме `tools`, и не требует настройки после установки.

---

## <a name="purpose"></a>2. Назначение и решаемые задачи

Административная панель Cotonti штатно предоставляет страницу `admin.php?m=extensions`, где перечислены все модули и плагины, разделённые на секции. Проблема этой страницы при большом количестве установленных расширений:

1. Нет поиска по коду.
2. Нет поиска по названию.
3. Нет поиска по ключевому слову.
4. Нет отдельного представления — только общий список с вкладками «По алфавиту» и «По категориям».
5. Переход к конкретному расширению занимает много времени, если расширений десятки или сотни.

Плагин решает эти задачи, добавляя отдельную страницу с фильтрами. При этом он не дублирует функционал ядра, а дополняет его, ссылаясь на стандартные страницы сведений.

---

## <a name="features"></a>3. Возможности

По состоянию на версию 1.0.3 плагин предоставляет:

### 3.1. Две вкладки

Страница разделена на две вкладки:

- **Модули** (`tab=module`, по умолчанию).
- **Плагины** (`tab=plug`).

Вкладки переключаются через GET-параметр `tab`. При отсутствии параметра или недопустимом значении используется `module`.

### 3.2. Выпадающий список кодов

Список формируется из фактических файлов расширений в папке (`modules/` или `plugins/`), объединённых со списком установленных в таблице `cot_core`. Значения — коды расширений (`page`, `market`, `extensionfilter` и т. п.), отображаются — те же коды.

### 3.3. Выпадающий список названий

Список формируется из тех же данных. Значения — коды расширений, отображаются — человеко-читаемые названия (`Pages`, `Market PRO`, `Extensions Filter`). Если название в setup-файле пустое, отображается код.

### 3.4. Поиск по ключевому слову

Текстовое поле, поиск которого осуществляется без учёта регистра по объединённой строке «код + пробел + название». Ищет подстроку, не совпадение с начала строки.

### 3.5. Счётчик

Отображает `найдено / всего`. Например, `12 / 12` — найдены все 12 расширений, `1 / 12` — найден 1 из 12.

### 3.6. Прямые ссылки на сведения

Для каждого найденного расширения — ссылка на страницу сведений ядра: `admin.php?m=extensions&a=details&mod=<код>` для модулей и `admin.php?m=extensions&a=details&pl=<код>` для плагинов.

### 3.7. Индикация установки

Каждое расширение помечено статусом: «Установлен» (зелёный бейдж) или «Не установлен» (серый бейдж). Статус определяется по наличию записи в таблице `cot_core`.

---

## <a name="requirements"></a>4. Требования

| Параметр | Значение |
|---|---|
| CMS | Cotonti Siena v1.0.0 или выше |
| PHP | 8.5 или выше |
| MySQL | 8.4 или выше |
| Язык | PHP 8.5: используются `?string`, `mixed` (неявно), `mb_*` функции |
| Хуки | `tools` |
| Таблицы БД | `cot_core` (для определения установленных) |
| Плагины зависимостей | отсутствуют |
| Модули зависимостей | отсутствуют |

Плагин не требует правки ядра и не использует устаревшие функции вроде `$db->query` там, где это не оправдано. Используются стандартные функции Cotonti: `cot_import`, `cot_url`, `cot_selectbox`, `cot_extension_list_info`, `cot_auth`, `cot_display_messages`.

---

## <a name="installation"></a>5. Установка

### 5.1. Ручная установка

1. Скачать архив или склонировать репозиторий:

```bash
git clone https://github.com/webitproff/extensionfilter-cotonti.git
```

2. Скопировать папку `extensionfilter` в каталог плагинов Cotonti:

```
<корень сайта>/plugins/extensionfilter/
```

3. Зайти в административную панель:

```
https://<домен>/admin.php?m=extensions
```

4. Найти в списке плагинов «Extensions Filter» и нажать «Установить».

5. После установки плагин появится в разделе «Инструменты» (`admin.php?m=other`).

6. Открыть страницу плагина:

```
https://<домен>/admin.php?m=other&p=extensionfilter
```

### 5.2. Установка через менеджер расширений Cotonti

Если ваш сайт работает на версии Cotonti с поддержкой установки расширений через админ-панель:

1. Открыть «Расширения» → «Плагины».
2. Плагин «Extensions Filter» появится в списке, если файлы уже закачаны.
3. Нажать «Установить».

### 5.3. Что происходит при установке

При нажатии «Установить» Cotonti выполняет следующую последовательность:

1. Читает блок `[BEGIN_COT_EXT]` из `extensionfilter.setup.php`.
2. Регистрирует запись в таблице `cot_core` (код плагина, название, версия, тип).
3. Регистрирует запись в таблице `cot_plugins` с указанием хука `tools` и файла `extensionfilter/extensionfilter.tools.php`.
4. Создаёт записи прав доступа в `cot_auth` для всех групп (`Auth_guests=R`, `Auth_members=RW`, `Lock_guests=12345A`, `Lock_members=12345A`).
5. Регистрирует права на уровне плагина (`plug` / `extensionfilter`).
6. Очищает кеш.

После этого хук `tools` при каждом открытии `admin.php?m=other` подтягивает файл `extensionfilter.tools.php` и, если текущий пользователь — администратор, подключает его.

---

## <a name="uninstall"></a>6. Удаление

### 6.1. Через админ-панель

1. Открыть «Расширения» → «Плагины».
2. Нажать «Удалить» напротив «Extensions Filter».
3. Подтвердить действие.

При удалении Cotonti:

1. Удаляет запись из `cot_core`.
2. Удаляет записи из `cot_plugins` (снимает регистрацию хука `tools`).
3. Удаляет записи из `cot_auth` (права).
4. Удаляет записи из `cot_config` (настройки плагина, если есть).
5. Очищает кеш.

Плагин **не создаёт собственных таблиц**, поэтому шаг «удалить таблицы» не выполняется — нечего удалять.

### 6.2. Ручное удаление

Если по какой-то причине плагин удалён из БД, но файлы остались:

1. Удалить папку `plugins/extensionfilter/` полностью.
2. Открыть phpMyAdmin, выполнить:

```sql
DELETE FROM cot_core WHERE ct_code = 'extensionfilter';
DELETE FROM cot_plugins WHERE pl_code = 'extensionfilter';
DELETE FROM cot_auth WHERE (auth_code = 'plug' AND auth_option = 'extensionfilter');
DELETE FROM cot_config WHERE config_owner = 'plug' AND config_cat = 'extensionfilter';
```

где `cot_` — префикс таблиц вашей установки.

3. Очистить кеш Cotonti (в админ-панели → «Кеш» → «Очистить все»).

---

## <a name="structure"></a>7. Структура плагина

```
plugins/extensionfilter/
├── extensionfilter.setup.php         — регистрация плагина (COT_EXT)
├── extensionfilter.tools.php         — обработчик хука tools, бизнес-логика
├── inc/
│   └── extensionfilter.functions.php — API плагина, подключение зависимостей
├── lang/
│   ├── extensionfilter.ru.lang.php   — русская локализация
│   └── extensionfilter.en.lang.php   — английская локализация
└── tpl/
    └── extensionfilter.tools.tpl     — шаблон страницы
```

Каждый файл выполняет строго определённую роль. Ниже — подробное описание.

---

## <a name="architecture"></a>8. Архитектура и принцип работы

### 8.1. Механизм хуков Cotonti

Cotonti использует систему хуков: файлы расширений с блоком `[BEGIN_COT_EXT]` и параметром `Hooks=<имя>` регистрируются в таблице `cot_plugins`. При выполнении ядра в определённых точках вызывается `cot_getextplugins(<имя хука>)`, которая возвращает список файлов, зарегистрированных на этот хук. Каждый файл подключается через `include`.

Хук `tools` вызывается в `admin.php` (в разделе «Инструменты», `m=other`). Модуль `other` в админ-панели специально предназначен для отображения инструментов плагинов, не привязанных к конкретному разделу админки.

### 8.2. Как работает хук tools

Схема выполнения:

```
Пользователь открывает /admin.php?m=other&p=extensionfilter
            │
            ▼
admin.php загружает контроллер admin/other
            │
            ▼
other.php ищет плагин с кодом p=extensionfilter
            │
            ▼
Загружает список файлов на хуке tools: cot_getextplugins('tools')
            │
            ▼
Для каждого файла на хуке tools выполняет include
            │
            ▼
Файл extensionfilter.tools.php выполняется в области видимости other.php
            │
            ▼
  - читает GET-параметры (tab, fcode, fname, fkeyword)
  - формирует данные
  - рендерит шаблон extensionfilter.tools.tpl
  - присваивает $pluginBody
            │
            ▼
other.php вставляет $pluginBody в основной шаблон admin/other.tpl
            │
            ▼
Возвращает HTML страницы
```

### 8.3. Почему переменная называется $tuman

При выполнении `include $pl` внутри `admin.php`/`other.php` плагин попадает в область видимости, где уже определена переменная `$t` — это экземпляр главного XTemplate админ-панели. Если в плагине написать `$t = new XTemplate(...)`, то произойдёт перезапись: ядро потеряет ссылку на свой шаблон.

Именно поэтому обработчик плагина обязан использовать имя, отличное от `$t`. В файле `extensionfilter.tools.php` используется `$t` для своего шаблона, но так как при подключении из ядра это уже другой контекст (`include` внутри функции), переменная `$t` из плагина **не пересекается** с `$t` ядра — она локальна в области видимости подключаемого файла. Однако, чтобы избежать путаницы и совпасть со стилем ядра (см. `contact.tools.php` в Cotonti), рекомендуется использовать отдельное имя — например, `$tuman`.

В версии 1.0.3 используется `$t` в плагине, что технически безопасно, потому что `include $pl` выполняется в изолированной области видимости. Если в будущем ядро изменит способ подключения — переменная будет перезаписана. Для устойчивости рекомендуется переименовать `$t` в `$tuman` (или любое другое имя, не встречающееся в ядре).

### 8.4. Поток данных

```
Файловая система (plugins/ или modules/)     Таблица cot_core
            │                                       │
            ▼                                       ▼
   cot_extension_list_info($dir)         SELECT ct_code, ct_version
            │                                       │
            └──────────────┬────────────────────────┘
                           ▼
                   Массив $extensions
                           │
                           ▼
                 Применение фильтров
                 (fcode → fname → fkeyword)
                           │
                           ▼
                   Массив $filtered
                           │
                           ▼
                 Передача в шаблон через assign()
                           │
                           ▼
                     Рендеринг HTML
```

---

## <a name="hook-tools"></a>9. Точка входа: хук tools

Файл `extensionfilter.tools.php` — единственный хук плагина. Заголовок:

```php
<?php
/* ====================
[BEGIN_COT_EXT]
Hooks=tools
[END_COT_EXT]
==================== */
```

**Значение параметров:**

- `Hooks=tools` — единственный хук. Других хуков у плагина нет.
- При установке Cotonti регистрирует запись в `cot_plugins` с полями:
  - `pl_hook = 'tools'`
  - `pl_code = 'extensionfilter'`
  - `pl_part = 'main'` (основная часть)
  - `pl_file = 'extensionfilter/extensionfilter.tools.php'`
  - `pl_active = 1`
  - `pl_module = 0` (плагин, не модуль)

При заходе в `admin.php?m=other` ядро находит все активные плагины с хуком `tools`, сортирует их по `pl_order` (по умолчанию 10) и выполняет `include`.

---

## <a name="urls"></a>10. URL-адреса и навигация

### 10.1. Основной URL

```
/admin.php?m=other&p=extensionfilter
```

При включённых ЧПУ в Cotonti фактический URL:

```
/<lang>/admin/other?p=extensionfilter
```

Пример: `https://example.com/ru/admin/other?p=extensionfilter`.

### 10.2. URL с параметрами вкладки

| Вкладка | URL |
|---|---|
| Модули (по умолчанию) | `/admin.php?m=other&p=extensionfilter` |
| Плагины | `/admin.php?m=other&p=extensionfilter&tab=plug` |

### 10.3. URL с фильтрами

Параметры передаются методом GET. Пример:

```
/admin.php?m=other&p=extensionfilter&tab=module&fcode=page&fname=&fkeyword=
```

Все три параметра (`fcode`, `fname`, `fkeyword`) всегда присутствуют в URL формы, даже если пусты. Это упрощает парсинг и делает форму предсказуемой.

### 10.4. Ссылки на страницы сведений

Из плагина доступны прямые ссылки на стандартные страницы сведений Cotonti:

- для модуля: `admin.php?m=extensions&a=details&mod=<код>`
- для плагина: `admin.php?m=extensions&a=details&pl=<код>`

Пример для модуля Pages: `admin.php?m=extensions&a=details&mod=page`.

### 10.5. Кнопка «Сбросить»

Ведёт на URL текущей вкладки без параметров фильтра:

```
/admin.php?m=other&p=extensionfilter&tab=<текущая_вкладка>
```

---

## <a name="filters"></a>11. Параметры фильтрации

Плагин принимает три GET-параметра. Все три — необязательные, могут быть пустыми.

### 11.1. Параметр `fcode`

| Свойство | Значение |
|---|---|
| Источник | `$_GET['fcode']` |
| Импорт | `cot_import('fcode', 'G', 'ALP')` |
| Тип | строка `[a-zA-Z0-9\-_]` |
| По умолчанию | пустая строка |
| Назначение | точное совпадение с кодом расширения |

Использование `ALP` (alphanumeric) гарантирует, что в параметр не попадёт ничего, кроме разрешённых символов. Коды Cotonti соответствуют этому шаблону.

Если `fcode` не пуст и совпадает с одним из доступных кодов — массив фильтруется до одного элемента. Если не совпадает — результат пустой.

### 11.2. Параметр `fname`

| Свойство | Значение |
|---|---|
| Источник | `$_GET['fname']` |
| Импорт | `cot_import('fname', 'G', 'TXT')` |
| Тип | строка, обрезаются пробелы |
| По умолчанию | пустая строка |
| Назначение | точное совпадение с кодом (из выпадающего списка значений) |

Список названий хранит **код** в качестве значения `value` и **название** в качестве отображаемого текста. Поэтому фильтр `fname` фактически фильтрует по коду, но UI показывает названия. Это сделано для однозначности — названия могут меняться, повторяться или содержать специальные символы, а коды уникальны и стабильны.

### 11.3. Параметр `fkeyword`

| Свойство | Значение |
|---|---|
| Источник | `$_GET['fkeyword']` |
| Импорт | `cot_import('fkeyword', 'G', 'TXT')` |
| Тип | строка |
| По умолчанию | пустая строка |
| Назначение | поиск подстроки по коду или названию |

Поиск:

```php
$kw = mb_strtolower($fKeyword);
$hay = mb_strtolower($code . ' ' . (string)$info['Name']);
if (mb_strpos($hay, $kw) !== false) {
    // найдено
}
```

- Регистронезависимый: `$kw` и `$hay` приводятся к нижнему регистру.
- Мультибайтовый: используются `mb_strtolower` и `mb_strpos`.
- Ищет в объединённой строке `код название`. То есть `market` найдёт и `market` (код), и `Market PRO` (название).

### 11.4. Порядок применения

Фильтры применяются последовательно, каждый следующий сужает выборку:

1. `$filtered = $extensions` — исходный массив всех расширений.
2. Если `fcode` не пуст → фильтр по коду (оставляет 0 или 1 элемент).
3. Если `fname` не пуст → фильтр по коду (из списка названий).
4. Если `fkeyword` не пуст → фильтр по подстроке.
5. `ksort` — сортировка по коду.

Пример:

- Исходно: 12 расширений.
- `fcode=page` → 1 расширение.
- `fname=page` → всё то же 1 расширение.
- `fkeyword=pag` → 1 расширение.

Если применить `fcode=page&fname=market` — результат пуст, так как после шага 2 в массиве только `page`, а шаг 3 ищет `market`.

### 11.5. Результат применения

Если после всех фильтров массив пуст:

```php
if (count($filtered) === 0) {
    $t->parse('MAIN.NO_RESULTS');
}
```

Выводится блок `NO_RESULTS` с текстом `{PHP.L.extensionfilter_no_results}` («Ничего не найдено»).

---

## <a name="files"></a>12. Описание файлов

| Файл | Роль | Строк кода (прибл.) |
|---|---|---|
| `extensionfilter.setup.php` | регистрация | ~35 |
| `inc/extensionfilter.functions.php` | API, подключение зависимостей | ~25 |
| `extensionfilter.tools.php` | бизнес-логика + рендер | ~130 |
| `tpl/extensionfilter.tools.tpl` | шаблон страницы | ~80 |
| `lang/extensionfilter.ru.lang.php` | русская локализация | ~25 |
| `lang/extensionfilter.en.lang.php` | английская локализация | ~25 |

Каждый файл подробно разобран в следующих разделах.

---

## <a name="file-setup"></a>13. Файл setup

**Путь:** `plugins/extensionfilter/extensionfilter.setup.php`

**Назначение:** регистрация плагина в системе Cotonti. Cotonti при установке читает блок `[BEGIN_COT_EXT]` и переносит эти данные в таблицы.

**Структура блока:**

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

**Параметры:**

| Параметр | Значение | Куда попадает |
|---|---|---|
| `Code` | `extensionfilter` | `cot_core.ct_code`, используется как код в URL (`p=extensionfilter`) |
| `Name` | `Extensions Filter` | `cot_core.ct_title`, отображается в списке плагинов |
| `Category` | `administration` | используется при сортировке по категориям |
| `Description` | `Search and filter modules and plugins in admin panel` | описание в карточке плагина |
| `Version` | `1.0.3` | `cot_core.ct_version`, отображается и сравнивается |
| `Date` | `2026-10-19` | дата релиза |
| `Author` | `webitpoff` | автор |
| `Copyright` | `(c) 2026 webitproff | ...` | копирайт |
| `Auth_guests` | `R` | права гостей при установке |
| `Lock_guests` | `12345A` | заблокированные права гостей |
| `Auth_members` | `RW` | права участников |
| `Lock_members` | `12345A` | заблокированные права участников |
| `Requires_modules` | (пусто) | модули-зависимости |
| `Requires_plugins` | (пусто) | плагины-зависимости |
| `Recommends_modules` | (пусто) | рекомендуемые модули |
| `Recommends_plugins` | (пусто) | рекомендуемые плагины |

**Что означает `Lock_guests=12345A` и `Lock_members=12345A`:**

Права уровней 1–5 и администрирование (`A`) заморожены для обеих групп. Это значит:

- Гости получают чтение (`R`), но администрирование заблокировано.
- Участники получают чтение и запись (`RW`), но администрирование тоже заблокировано.
- Только суперадмин группы (`COT_GROUP_SUPERADMINS`) имеет `A` и может открыть страницу.

**Что означает `Category=administration`:**

Используется для отображения плагина в соответствующей категории на странице «Расширения». В русской локализации Cotonti соответствует «Администрирование».

**Что дальше читает Cotonti из setup-файла:**

- секцию `[BEGIN_COT_EXT_CONFIG]` — если она есть. В данном плагине её нет, потому что у плагина **нет настроек**.
- секцию `[BEGIN_COT_EXT_CONFIG_STRUCTURE]` — тоже отсутствует.
- `[BEGIN_COT_EXT]` — уже рассмотрено.

После блока `[BEGIN_COT_EXT]` идёт стандартный PHPDoc-комментарий, идентифицирующий файл, версию, автора, ссылку на репозиторий.

---

## <a name="file-functions"></a>14. Файл functions (API)

**Путь:** `plugins/extensionfilter/inc/extensionfilter.functions.php`

**Назначение:** подключение внешних зависимостей плагина. В версии 1.0.3 не содержит собственных функций — только `require_once` для двух файлов Cotonti.

**Содержимое:**

```php
defined('COT_CODE') or die('Wrong URL');

require_once cot_langfile('extensionfilter', 'plug');
require_once cot_incfile('extensions');
```

**Почему `cot_incfile` и `cot_langfile`:**

- `cot_incfile('extensions')` — подключает файл `system/extensions.php`, где определены `cot_extension_list_info`, `cot_extension_installed`, `cot_infoget` и другие вспомогательные функции для работы с расширениями. Без него вызов `cot_extension_list_info()` в `extensionfilter.tools.php` упадёт.
- `cot_langfile('extensionfilter', 'plug')` — подключает языковой файл плагина. Определяет переменные `$L['extensionfilter_title']`, `$L['extensionfilter_tab_module']` и т. д.

**Где вызывается:**

В `extensionfilter.tools.php` первой строкой после `defined('COT_CODE')`:

```php
require_once cot_incfile('extensionfilter', 'plug');
```

Cotonti автоматически разрешает путь: `plugins/extensionfilter/inc/extensionfilter.functions.php`.

**Зачем нужен отдельный файл, если он ничего не делает:**

Соглашение Cotonti: если файлу-обработчику хука нужны функции, локализация или зависимости, они выносятся в `inc/<code>.functions.php`. Это даёт:

- единообразие с другими плагинами;
- возможность в будущих версиях добавить функции, не меняя точку входа;
- подключение зависимостей до объявления функции обработчика (хотя в данном случае подключение идёт через `require_once` в самой точке входа).

Плагин мог бы обойтись без этого файла, разместив `require_once` напрямую в `extensionfilter.tools.php`. Оставлено ради структурной чистоты и будущего расширения.

---

## <a name="file-tools"></a>15. Файл tools (админка)

**Путь:** `plugins/extensionfilter/extensionfilter.tools.php`

**Назначение:** единственный обработчик хука `tools`. Содержит всю бизнес-логику.

**Структура (в порядке выполнения):**

### 15.1. Заголовок COT_EXT

```php
<?php
/* ====================
[BEGIN_COT_EXT]
Hooks=tools
[END_COT_EXT]
==================== */
```

Задаёт хук `tools`. Более ничего в заголовке нет — плагин не подписан на другие хуки.

### 15.2. Защита от прямого обращения

```php
defined('COT_CODE') or die('Wrong URL.');
```

Стандартная проверка Cotonti. Без `COT_CODE` файл не выполнится. Это защищает от прямого URL-доступа к файлу.

### 15.3. Подключение зависимостей

```php
require_once cot_incfile('extensionfilter', 'plug');
```

Подключает `inc/extensionfilter.functions.php`, который, в свою очередь, подключает `system/extensions.php` и языковой файл.

### 15.4. Создание шаблона

```php
$t = new XTemplate(cot_tplfile('extensionfilter.tools', 'plug', true));
```

- `cot_tplfile('extensionfilter.tools', 'plug', true)` — ищет файл шаблона.
- Первый аргумент `'extensionfilter.tools'` — имя шаблона (без `.tpl`).
- Второй аргумент `'plug'` — тип расширения. Поиск идёт в нескольких местах:
  - `themes/<admin_theme>/plugins/extensionfilter/extensionfilter.tools.tpl` (переопределение темы)
  - `themes/<admin_theme>/plugins/extensionfilter.tools.tpl`
  - `plugins/extensionfilter/tpl/extensionfilter.tools.tpl` (стандартное место плагина)
- Третий аргумент `true` — означает «admin-режим»: искать в админ-теме. Без него шаблон искался бы в пользовательской теме.

Если файл не найден ни в одном месте — `cot_tplfile` вернёт `false`, и `new XTemplate(false)` выбросит ошибку.

### 15.5. Заголовок и хлебные крошки

```php
$adminTitle = Cot::$L['extensionfilter_title'];
$adminPath[] = [cot_url('admin', ['m' => 'other', 'p' => 'extensionfilter']), Cot::$L['extensionfilter_title']];
```

- `$adminTitle` — устанавливает заголовок страницы (`<title>` и `<h1>` в шапке админки).
- `$adminPath[]` — добавляет сегмент в хлебные крошки. Формат: `[url, title]`.

### 15.6. Определение вкладки

```php
$tab = cot_import('tab', 'G', 'ALP');
if ($tab !== 'module' && $tab !== 'plug') {
    $tab = 'module';
}
```

- `cot_import('tab', 'G', 'ALP')` — читает GET-параметр `tab`, фильтрует как «только буквы». Если параметра нет — вернёт `null`.
- Валидация: допустимы только `module` и `plug`.
- Значение по умолчанию — `module`.

### 15.7. Определение директории

```php
$isModule = ($tab === 'module');
$dir = $isModule ? Cot::$cfg['modules_dir'] : Cot::$cfg['plugins_dir'];
```

- `$isModule` — булев флаг для последующего ветвления.
- `$dir` — путь к папке модулей или плагинов. `Cot::$cfg['modules_dir']` и `Cot::$cfg['plugins_dir']` — абсолютные пути, устанавливаемые Cotonti при инициализации.

### 15.8. Получение списка расширений

```php
$extensions = cot_extension_list_info($dir);
```

`cot_extension_list_info()` — стандартная функция Cotonti (в `system/extensions.php`), которая:

1. Сканирует указанную папку.
2. Для каждой подпапки ищет `<code>.setup.php`.
3. Читает блок `[BEGIN_COT_EXT]` через `cot_infoget`.
4. Возвращает массив `[код => массив сведений]`.

Структура каждого элемента:

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

### 15.9. Получение установленных расширений

```php
$installed = Cot::$db->query(
    'SELECT ct_code, ct_version FROM ' . Cot::$db->core . ' WHERE ct_plug = ?',
    [(int)!$isModule]
)->fetchAll(PDO::FETCH_KEY_PAIR);
```

- Запрос к таблице `cot_core`.
- `ct_plug = 0` — модуль, `ct_plug = 1` — плагин.
- `(int)!$isModule` — приведение: если модуль — `0`, если плагин — `1`.
- `fetchAll(PDO::FETCH_KEY_PAIR)` — возвращает ассоциативный массив `[ct_code => ct_version]`.

Пример результата для модулей:

```php
[
    'page' => '1.0.0',
    'users' => '1.0.0',
    'market' => '5.7.9',
]
```

### 15.10. Добавление установленных, но отсутствующих в папке

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

Ситуация: расширение записано в `cot_core`, но папка с файлами отсутствует. Это может произойти при:

- удалении папки без удаления из БД;
- ошибке при обновлении;
- ручном вмешательстве в БД.

Такие расширения показываются в списке с пометкой `NotFound` и названием, равным коду (нет setup-файла для чтения названия). Значение `Category = 'misc-ext'` — стандартное для «прочее».

### 15.11. Формирование списков select

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

- `$codes` — массив `[код => код]`. Значение совпадает с отображаемым текстом.
- `$names` — массив `[код => название]`. Значение — код, отображение — название.
- `asort` — сортировка по значению, с сохранением ключей.
- `SORT_NATURAL | SORT_FLAG_CASE` — естественная сортировка без учёта регистра. `page2` окажется после `page10`? Нет, наоборот: `page2` перед `page10` — это и есть natural sort.

### 15.12. Чтение параметров фильтра

```php
$fCode    = (string) cot_import('fcode', 'G', 'ALP');
$fName    = (string) cot_import('fname', 'G', 'TXT');
$fKeyword = (string) cot_import('fkeyword', 'G', 'TXT');
```

Все параметры берутся через `cot_import`. Результат приводится к строке — `cot_import` возвращает `null`, если параметра нет.

### 15.13. Применение фильтров

Уже разобрано в разделе 11. Порядок:

```php
$filtered = $extensions;
if ($fCode !== '' && isset($filtered[$fCode])) { ... }
if ($fName !== '') { ... }
if ($fKeyword !== '') { ... }
ksort($filtered, SORT_NATURAL | SORT_FLAG_CASE);
```

### 15.14. Формирование базовых параметров URL

```php
$baseParams = ['m' => 'other', 'p' => 'extensionfilter', 'tab' => $tab];
```

Используется для `cot_url()` при формировании `FORM_URL` и `RESET_URL`.

### 15.15. Присвоение общих тегов

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

Каждое поле подробно описано в разделе 18 «Теги шаблона».

### 15.16. Формирование строк таблицы

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

Особенности:

- `ROW_STATUS` — текст из языкового файла. Ключи `extensionfilter_status_installed` и `extensionfilter_status_notinstalled`.
- `ROW_STATUS_CLASS` — CSS-класс Bootstrap. `success` — зелёный бейдж, `secondary` — серый.
- `$t->parse('MAIN.ROWS.ROW')` — собирает строку внутри блока `ROWS`.
- `$t->parse('MAIN.ROWS')` **обязательно** после цикла. Без этой строки блок `ROWS` не попадёт в итоговый HTML, и строки не отобразятся.

### 15.17. Блок «нет результатов»

```php
if (count($filtered) === 0) {
    $t->parse('MAIN.NO_RESULTS');
}
```

Парсит блок `NO_RESULTS`, если после фильтрации массив пуст. В шаблоне блок выводит сообщение.

### 15.18. Отображение сообщений

```php
cot_display_messages($t);
```

Стандартная функция Cotonti. Читает из сессии массив сообщений (`cot_messages`), добавленных через `cot_message` или `cot_error`, и передаёт их в шаблон (обычно через `{FILE .../warnings.tpl}` в начале шаблона).

### 15.19. Парсинг главного блока и вывод

```php
$t->parse('MAIN');
$pluginBody = $t->text('MAIN');
```

- `$t->parse('MAIN')` — собирает корневой блок `MAIN`.
- `$t->text('MAIN')` — возвращает итоговый HTML как строку.
- `$pluginBody` — переменная, которую ядро (`admin.php` / `other.php`) вставляет в свой основной шаблон в тег `{PLUGIN_BODY}`.

**Ошибка, которую нельзя допускать:** писать `$adminTitle = $t->text('MAIN');`. `$adminTitle` — это заголовок страницы (обычно plain text), а не HTML-тело. При перезаписи `$adminTitle` HTML-ом плагина в `<title>` попадёт вся разметка. Правильно: `$pluginBody = ...`.

---

## <a name="file-tpl"></a>16. Шаблон tpl

**Путь:** `plugins/extensionfilter/tpl/extensionfilter.tools.tpl`

**Назначение:** XTemplate-шаблон для рендера HTML. Использует синтаксис XTemplate Cotonti.

### 16.1. Структура блоков

```
MAIN
├── (вкладки nav-tabs)
├── (форма фильтра)
├── (счётчик)
├── IF RESULTS_COUNT > 0
│   └── (список)
│       └── ROWS
│           └── ROW  ← цикл
└── NO_RESULTS
```

`ROWS` — контейнер, внутри которого `parse('MAIN.ROWS.ROW')` добавляет по одной строке. `parse('MAIN.ROWS')` — вставляет контейнер в MAIN.

### 16.2. Вкладки

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

Bootstrap-табы. Активная вкладка получает класс `active`, неактивная — пустой класс.

### 16.3. Форма

```html
<form method="get" action="{FORM_URL}" class="card mb-3">
    <input type="hidden" name="m" value="other" />
    <input type="hidden" name="p" value="extensionfilter" />
    <input type="hidden" name="tab" value="{TAB}" />
    ...
</form>
```

- `method="get"` — параметры передаются в URL.
- Три скрытых поля: `m`, `p`, `tab`. `m` и `p` — обязательные для Cotonti (без них URL не будет указывать на плагин). `tab` — сохраняет текущую вкладку.

### 16.4. Три поля фильтра

Три колонки в `row g-2`:

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

Первые два поля — уже сгенерированный HTML (`cot_selectbox`). Третье — обычный `<input>`, значение подставляется из `{KEYWORD}`.

### 16.5. Кнопки

```html
<div class="mt-3">
    <button type="submit" class="btn btn-primary">{PHP.L.extensionfilter_btn_search}</button>
    <a href="{RESET_URL}" class="btn btn-outline-secondary">{PHP.L.extensionfilter_btn_reset}</a>
</div>
```

- «Поиск» — `submit`, отправляет форму.
- «Сбросить» — `<a>`, ведёт на URL без параметров.

### 16.6. Счётчик

```html
<div class="text-muted small mb-2">{RESULTS_COUNT} / {TOTAL_COUNT}</div>
```

Отображает «найдено / всего».

### 16.7. Список результатов

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

Заголовок — `d-none d-lg-block` (скрыт на мобильных, виден на десктопе). Строки — каждая в `list-group-item`.

### 16.8. Строка

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
            <!-- здесь может быть кнопка "Открыть", если нужна -->
        </div>
    </div>
</div>
```

Обратите внимание: ссылка охватывает название и описание, но не код и не версию. Версия — отдельной колонкой без ссылки. Код — `<code>` без ссылки (визуально подчёркивает «это идентификатор, не ссылка»).

### 16.9. Блок NO_RESULTS

```html
<!-- BEGIN: NO_RESULTS -->
<div class="alert alert-info">{PHP.L.extensionfilter_no_results}</div>
<!-- END: NO_RESULTS -->
```

Выводится, если `count($filtered) === 0`. Bootstrap-alert для видимости.

---

## <a name="file-lang"></a>17. Языковые файлы

**Путь:** `plugins/extensionfilter/lang/extensionfilter.ru.lang.php` и `extensionfilter.en.lang.php`.

**Назначение:** определение строк интерфейса. Cotonti загружает файл, соответствующий языку пользователя, с фолбэком на английский.

**Структура:**

```php
defined('COT_CODE') or die('Wrong URL.');

$L['extensionfilter_title'] = 'Фильтр расширений';
$L['extensionfilter_tab_module'] = 'Модули';
// ...
```

Все ключи имеют префикс `extensionfilter_`. Это стандартное требование Cotonti — избегать коллизий с другими расширениями.

**Загрузка:**

В `extensionfilter.functions.php`:

```php
require_once cot_langfile('extensionfilter', 'plug');
```

Cotonti ищет файл в порядке:

1. `lang/<lang>/plugins/extensionfilter.<lang>.lang.php` (общая папка языков)
2. `plugins/extensionfilter/lang/extensionfilter.<lang>.lang.php` (папка плагина)
3. `plugins/extensionfilter/lang/extensionfilter.en.lang.php` (фолбэк)

Для русского пользователя загрузится `extensionfilter.ru.lang.php`. Для французского (файла нет) — `extensionfilter.en.lang.php`.

**Список ключей** — см. раздел 19.

---

## <a name="template-tags"></a>18. Теги шаблона: полный справочник

### 18.1. Теги страницы

| Тег | Тип | Описание |
|---|---|---|
| `{TAB_MODULE_URL}` | URL | Ссылка на вкладку «Модули» |
| `{TAB_PLUG_URL}` | URL | Ссылка на вкладку «Плагины» |
| `{TAB_MODULE_ACTIVE}` | строка | CSS-класс активной вкладки (`active` или пусто) |
| `{TAB_PLUG_ACTIVE}` | строка | То же для плагинов |
| `{FORM_URL}` | URL | Action-адрес формы (с текущей вкладкой) |
| `{RESET_URL}` | URL | Адрес для сброса (с текущей вкладкой, без фильтров) |
| `{TAB}` | строка | Текущая вкладка (`module` или `plug`) |

### 18.2. Теги фильтров

| Тег | Тип | Описание |
|---|---|---|
| `{SELECT_CODE}` | HTML | Готовый `<select name="fcode">` со списком кодов |
| `{SELECT_NAME}` | HTML | Готовый `<select name="fname">` со списком названий |
| `{KEYWORD}` | строка | Значение поля `fkeyword` (экранированное) |

### 18.3. Теги счётчиков

| Тег | Тип | Описание |
|---|---|---|
| `{RESULTS_COUNT}` | int | Число найденных после фильтрации |
| `{TOTAL_COUNT}` | int | Общее число расширений на вкладке |

### 18.4. Теги строки (внутри `ROWS > ROW`)

| Тег | Тип | Описание |
|---|---|---|
| `{ROW_CODE}` | строка | Код расширения (например, `page`) |
| `{ROW_NAME}` | строка | Название или код, если названия нет |
| `{ROW_VERSION}` | строка | Версия из setup-файла |
| `{ROW_DESCRIPTION}` | строка | Описание из setup-файла |
| `{ROW_DETAILS_URL}` | URL | Ссылка на `admin.php?m=extensions&a=details&...` |
| `{ROW_STATUS}` | строка | «Установлен» или «Не установлен» |
| `{ROW_STATUS_CLASS}` | строка | CSS-класс бейджа: `success` или `secondary` |

### 18.5. Языковые теги `{PHP.L.*}`

Все обращения к `$L[...]` в шаблоне идут через `{PHP.L.<ключ>}`. XTemplate автоматически подставляет значение из массива `$L` или оставляет как есть, если ключа нет.

Используемые в шаблоне:

| Тег | Соответствует `$L[...]` |
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

## <a name="lang-keys"></a>19. Языковые ключи: полный справочник

### 19.1. Русская локализация (`extensionfilter.ru.lang.php`)

| Ключ | Значение |
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

### 19.2. Английская локализация (`extensionfilter.en.lang.php`)

| Ключ | Значение |
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

### 19.3. Соглашение именования

Все ключи:

- начинаются с `extensionfilter_`;
- в нижнем регистре;
- используют `_` между словами;
- не совпадают с ключами ядра или других плагинов.

При добавлении новых ключей следуйте этому шаблону.

---

## <a name="filter-logic"></a>20. Логика фильтрации по шагам

Пошаговый разбор с примером. Исходные данные: 12 модулей.

### Шаг 1. Стартовое состояние

```php
$extensions = cot_extension_list_info($dir);
```

Результат: массив из 12 модулей. Порядок — как вернул `cot_extension_list_info` (алфавитный по коду, обычно).

### Шаг 2. Пользователь ничего не выбрал

`fcode=''`, `fname=''`, `fkeyword=''`.

```php
$filtered = $extensions;   // 12 элементов
// все три if пропущены
ksort($filtered, ...);     // пересортировка
// count($filtered) === 12
```

Результат: 12 / 12, всё отображается.

### Шаг 3. Пользователь выбрал `fcode=page`

```php
$filtered = $extensions;
if ($fCode !== '' && isset($filtered[$fCode])) {
    $filtered = [$fCode => $filtered[$fCode]];
}
// $filtered === ['page' => [...]]
// count === 1
```

Результат: 1 / 12, показан один модуль `page`.

### Шаг 4. Пользователь выбрал `fname=page` (из списка названий)

```php
$filtered = $extensions;
// шаг 3 пропущен (fcode пуст)
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

Логика: `fname` содержит **код** (не название). Сравнение `$code === $fName` точное.

### Шаг 5. Пользователь ввёл `fkeyword=market`

```php
$kw = 'market';
foreach ($filtered as $code => $info) {
    $hay = mb_strtolower($code . ' ' . $info['Name']);
    if (mb_strpos($hay, $kw) !== false) { ... }
}
```

- `market` (код) → `market market pro` → найдено.
- `Market PRO` (название) → `market market pro` → найдено (по коду `market`).
- `marketing` (код) → `marketing something` → найдено.
- `promarket` (код) → `promarket something` → найдено (подстрока `market`).
- `pro` (название) → `market market pro` → найдено (`pro` в `market pro`).

### Шаг 6. Пользователь ввёл `fcode=page&fkeyword=user`

После шага 3 в `$filtered` только `page`. На шаге 6 проверяется:

- `page` содержит `user`? Нет.
- Название `Pages` содержит `user`? Нет.

Результат: 0 / 12, показан блок `NO_RESULTS`.

### Шаг 7. Пользователь ввёл `fkeyword=` (пусто) — сброс

```php
if ($fKeyword !== '') { ... }  // пропущено
```

Результат: возврат к 12 / 12.

### Шаг 8. Общий принцип

Каждый фильтр — «уточнение». Если после любого шага массив стал пустым, остальные шаги просто ничего не меняют, кроме `fkeyword`, который может… Нет, если массив пуст, `foreach` ничего не сделает, результат останется пустым.

---

## <a name="select-lists"></a>21. Списки select: как формируются

### 21.1. `cot_selectbox` — стандартная функция Cotonti

```php
cot_selectbox($selected, $name, $values, $titles, $empty = false, $classes = '', $custom = '')
```

- `$selected` — текущее выбранное значение.
- `$name` — имя поля (`name="..."`).
- `$values` — массив значений `<option value="...">`.
- `$titles` — массив отображаемых текстов.
- `$empty` — если `true`, добавляется пустой `<option value="">` сверху (для «все» / «не выбрано»).

### 21.2. Список кодов

```php
'SELECT_CODE' => cot_selectbox($fCode, 'fcode', array_keys($codes), array_values($codes), true)
```

- `$codes = ['page' => 'page', 'market' => 'market', 'users' => 'users']`.
- `array_keys($codes)` — `['page', 'market', 'users']`.
- `array_values($codes)` — `['page', 'market', 'users']`.
- `$empty = true` — добавляет `<option value="">` — «все» / «не выбрано».

**HTML на выходе:**

```html
<select name="fcode" class="form-control">
    <option value=""></option>
    <option value="market">market</option>
    <option value="page">page</option>
    <option value="users">users</option>
</select>
```

Сортировка по значению — естественная.

### 21.3. Список названий

```php
'SELECT_NAME' => cot_selectbox($fName, 'fname', array_keys($names), array_values($names), true)
```

- `$names = ['page' => 'Pages', 'market' => 'Market PRO', 'users' => 'Users']`.
- `array_keys($names)` — `['page', 'market', 'users']` — коды в `value`.
- `array_values($names)` — `['Pages', 'Market PRO', 'Users']` — названия в тексте.

**HTML на выходе:**

```html
<select name="fname" class="form-control">
    <option value=""></option>
    <option value="market">Market PRO</option>
    <option value="page">Pages</option>
    <option value="users">Users</option>
</select>
```

**Важно:** несмотря на отображение названий, в URL передаётся **код**. Это сделано для надёжности — код стабилен, название может измениться, содержать спецсимволы и HTML.

### 21.4. Сортировка

```php
asort($codes, SORT_NATURAL | SORT_FLAG_CASE);
asort($names, SORT_NATURAL | SORT_FLAG_CASE);
```

- `asort` — сортирует по значению, сохраняет ключи.
- `SORT_NATURAL` — естественная сортировка (числа в строках сравниваются как числа).
- `SORT_FLAG_CASE` — без учёта регистра.

Пример: `page2`, `page10`, `Page1` сортируются как `Page1`, `page2`, `page10`.

---

## <a name="installed-missing"></a>22. Работа с установленными и отсутствующими расширениями

### 22.1. Источники данных

Два независимых источника:

1. **Файловая система** — `cot_extension_list_info($dir)` сканирует папки, находит `<code>.setup.php`, читает метаданные.
2. **База данных** — `cot_core` содержит записи обо всех установленных расширениях.

### 22.2. Возможные состояния

| Файлы | Запись в `cot_core` | Что делает плагин |
|---|---|---|
| есть | есть | Показывает, статус «Установлен» |
| есть | нет | Показывает, статус «Не установлен» |
| нет | есть | Показывает, статус «Установлен», название = код, `Category=misc-ext`, `NotFound=true` |
| нет | нет | Не показывает (нет данных) |

Третья строка — именно тот случай, для которого в цикле добавлен блок:

```php
foreach ($installed as $code => $version) {
    if (!isset($extensions[$code])) {
        $extensions[$code] = [ ... 'NotFound' => true ];
    }
}
```

### 22.3. Что означает «Не установлен»

Расширение присутствует на диске (папка, setup-файл), но не зарегистрировано в `cot_core`. Это возможно, если:

- администратор залил файлы, но не нажал «Установить»;
- плагин был удалён из БД, а файлы остались;
- это встроенный модуль/плагин, отключённый администратором.

Плагин показывает такие расширения с серым бейджем. Ссылка на `admin.php?m=extensions&a=details&...` открывает страницу с кнопкой «Установить».

### 22.4. Что означает «NotFound = true»

Внутренний флаг. Используется только внутри плагина. В шаблоне напрямую не выводится. Влияет на название (`Name = code`) и категорию. Используется, если в будущем потребуется фильтровать по `NotFound`.

---

## <a name="core-interaction"></a>23. Взаимодействие с ядром Cotonti

### 23.1. Используемые классы и функции

| Функция / класс | Откуда | Назначение |
|---|---|---|
| `Cot::$db` | `system/Cot.php` | Объект БД CotDB |
| `Cot::$cfg` | `system/Cot.php` | Конфигурация (пути, версия) |
| `Cot::$L` | `system/Cot.php` | Языковые строки |
| `Cot::$env` | `system/Cot.php` | Окружение (`ext`, `location`, `type`) |
| `cot_import` | `system/functions.php` | Чтение GET/POST с фильтрацией |
| `cot_url` | `system/functions.php` | Генерация URL |
| `cot_auth` | `system/functions.php` | Проверка прав |
| `cot_selectbox` | `system/forms.php` | Генерация `<select>` |
| `cot_display_messages` | `system/functions.php` | Вывод сообщений |
| `cot_extension_list_info` | `system/extensions.php` | Список расширений |
| `cot_langfile` | `system/functions.php` | Путь к языковому файлу |
| `cot_incfile` | `system/functions.php` | Путь к inc-файлу |
| `cot_tplfile` | `system/functions.php` | Путь к шаблону |
| `XTemplate` | `system/xtemplate.php` | Шаблонизатор |

### 23.2. Что делает `cot_extension_list_info`

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

Возвращает `[код => массив полей]`. Все поля, которые читает плагин (`Name`, `Version`, `Description`), берутся отсюда.

### 23.3. Что делает `cot_tplfile`

```php
cot_tplfile('extensionfilter.tools', 'plug', true)
```

Ищет файл шаблона в порядке:

1. `themes/admin/<admintheme>/plugins/extensionfilter/extensionfilter.tools.tpl`
2. `themes/admin/<admintheme>/plugins/extensionfilter.tools.tpl`
3. `plugins/extensionfilter/tpl/extensionfilter.tools.tpl`

Возвращает путь или `false`. Кеширование результатов `cot_tplfile` не делает — каждый вызов сканирует файлы (что недорого из-за малого числа вариантов).

### 23.4. Что делает `cot_import`

```php
cot_import('tab', 'G', 'ALP')
```

1. Берёт `$_GET['tab']`.
2. Применяет фильтр `ALP` (только `[a-zA-Z0-9\-_]`).
3. Возвращает очищенное значение или `null`.

Если `$_GET['tab']` не задан — возвращает `null`.

### 23.5. Что делает `cot_url`

```php
cot_url('admin', ['m' => 'extensions', 'a' => 'details', 'mod' => 'page'])
```

Собирает URL с учётом ЧПУ настроек Cotonti. Для `admin` использует `admin.php`, добавляет параметры через `http_build_query`.

Результат (без ЧПУ): `admin.php?m=extensions&a=details&mod=page`.
С ЧПУ и языком: `/ru/admin/extensions?m=extensions&a=details&mod=page` или короче — зависит от настроек.

---

## <a name="security"></a>24. Безопасность

### 24.1. Доступ к странице

`admin.php?m=other` — административный раздел. Ядро Cotonti уже проверяет:

```php
list($usr['auth_read'], $usr['auth_write'], $usr['isadmin']) = cot_auth('admin', 'a');
cot_block($usr['isadmin']);
```

То есть только администраторы могут открыть страницу. Плагин дополнительно **не** проверяет права — избыточно.

В версии 1.0.3 **правильно, что нет** собственной проверки `cot_auth('plug', 'extensionfilter', 'A')`. Если её добавить, пользователь получит 403, потому что в setup `Lock_members=12345A` блокирует `A` для участников. Технически только суперадмин получит доступ, что избыточно — обычный админ раздела тоже должен видеть инструмент.

### 24.2. SQL-инъекции

- `cot_extension_list_info` работает с файловой системой, не с SQL.
- Запрос `SELECT ct_code, ct_version FROM cot_core WHERE ct_plug = ?` использует подготовленное выражение через PDO. `(int)` приведение гарантирует тип.
- Кодов расширений из GET (`fcode`) не попадает в SQL — фильтрация по массиву в PHP.

### 24.3. XSS

- Все пользовательские значения (`$fCode`, `$fName`, `$fKeyword`) при выводе в HTML экранируются:
  - `htmlspecialchars($fKeyword)` для `{KEYWORD}`;
  - `cot_selectbox` сам экранирует значения;
  - `ROW_CODE`, `ROW_NAME`, `ROW_VERSION`, `ROW_DESCRIPTION` — через `htmlspecialchars`.
- Названия из setup-файлов потенциально могут содержать HTML. Плагин экранирует их через `htmlspecialchars`, поэтому теги не выполнятся — но и не отобразятся как HTML. Если нужно разрешить HTML в названии — потребуется отдельная логика.

### 24.4. CSRF

Форма использует `method="get"`. GET-формы не нуждаются в CSRF-токенах, потому что не изменяют состояние. Плагин только читает данные, никаких операций записи не выполняет.

### 24.5. Обход путей

Плагин не принимает от пользователя путей. `$dir` — фиксированный (`Cot::$cfg['modules_dir']` или `Cot::$cfg['plugins_dir']`). Чтение файлов через `cot_extension_list_info` ограничено этой папкой.

### 24.6. Раскрытие информации

Страница видна только администраторам. Никакой информации о сервере (пути, версии) на странице не выводится сверх того, что уже есть в стандартном разделе «Расширения».

---

## <a name="performance"></a>25. Производительность

### 25.1. Сложность

- Сканирование папки: O(N), где N — число подпапок (модулей или плагинов). Обычно N < 100.
- Чтение setup-файлов: O(N) — каждое расширение читается один раз.
- Фильтрация: O(N) для `fkeyword`, O(1) для `fcode` и `fname`.
- Сортировка: O(N log N).

Итого: O(N log N) при типичном N < 100 — миллисекунды.

### 25.2. Кеширование

Плагин **не кеширует** результаты. Каждый заход заново читает файловую систему и БД. Это:

- плюс — данные всегда актуальны;
- минус — при большом числе расширений (сотни) страница может работать дольше.

Практически Cotonti-сайты редко имеют >100 расширений. При необходимости можно добавить кеш через `Cot::$cache`, но в текущей версии этого нет.

### 25.3. Кеш XTemplate

Cotonti кеширует скомпилированные шаблоны XTemplate. При первом запросе шаблон парсится и компилируется в PHP-файл в `datas/cache/templates/`. При последующих — используется кешированный. Если шаблон изменился, кеш автоматически инвалидируется по времени модификации файла.

---

## <a name="localization"></a>26. Локализация и добавление языков

### 26.1. Как работает загрузка

Cotonti ищет языковой файл в порядке:

1. `lang/<current_lang>/plugins/extensionfilter.<current_lang>.lang.php`
2. `plugins/extensionfilter/lang/extensionfilter.<current_lang>.lang.php`
3. `plugins/extensionfilter/lang/extensionfilter.en.lang.php` (фолбэк)

### 26.2. Добавление нового языка

1. Скопируйте `extensionfilter.en.lang.php` в `extensionfilter.<код>.lang.php`, где `<код>` — двухбуквенный код языка (`de`, `fr`, `uk` и т. п.).
2. Переведите значения.
3. Не меняйте имена ключей.

**Пример:**

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

### 26.3. Переопределение в теме

Если нужно изменить строки только для конкретной админ-темы, положите файл в:

```
themes/admin/<theme>/lang/extensionfilter.<lang>.lang.php
```

Cotonti подхватит его раньше стандартного.

### 26.4. Плюрализация

В текущей версии плюрализация не используется — все строки в единственном числе. При расширении (например, «Найдено N расширений») можно использовать `cot_declension($n, $L['extensionfilter_found'])`.

---

## <a name="extending"></a>27. Расширение функционала

### 27.1. Добавление нового фильтра

Пример: фильтр по категории.

**Шаг 1.** В `extensionfilter.tools.php`:

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

**Шаг 2.** В шаблоне:

```html
<div class="col-12 col-lg-3">
    <label class="form-label">{PHP.L.extensionfilter_filter_category}</label>
    {SELECT_CATEGORY}
</div>
```

**Шаг 3.** В языковых файлах:

```php
$L['extensionfilter_filter_category'] = 'Категория';
```

### 27.2. Добавление сортировки

Пример: сортировка по версии.

**Шаг 1.** В PHP:

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

**Шаг 2.** В шаблоне — кнопки сортировки.

### 27.3. Добавление пагинации

При десятках расширений пагинация не нужна. При сотнях:

```php
list($pg, $d, $durl) = cot_import_pagenav('d', 25);
$total = count($filtered);
$pageItems = array_slice($filtered, $d, 25);

$pagenav = cot_pagenav('admin', $baseParams, $d, $total, 25);
$t->assign(cot_generatePaginationTags($pagenav));
```

В шаблоне — `{PAGINATION}`, `{PREVIOUS_PAGE}`, `{NEXT_PAGE}`.

### 27.4. Добавление действия «Установить»

Ссылка на установку: `admin.php?m=extensions&a=details&mod=<code>&b=install`. Ядро Cotonti уже обрабатывает этот URL. Плагину достаточно сформировать ссылку:

```php
$installUrl = cot_url('admin', ['m' => 'extensions', 'a' => 'details', $isModule ? 'mod' : 'pl' => $code, 'b' => 'install']);
```

### 27.5. Добавление AJAX-фильтрации

**Шаг 1.** Добавить хук `ajax` в отдельный файл `extensionfilter.ajax.php`:

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
    // фильтрация
    header('Content-Type: application/json');
    echo json_encode($result);
    exit;
}
```

**Шаг 2.** В шаблоне — JS-обработчик, отправляющий `fetch('/index.php?r=extensionfilter&a=filter&...')`.

**Шаг 3.** В `setup.php` ничего менять не нужно — Cotonti сам зарегистрирует второй хук, если добавить файл с соответствующим `Hooks=ajax`.

### 27.6. Что НЕ нужно делать

- Не добавлять `cot_auth('plug', 'extensionfilter', 'A')` в начале файла — это заблокирует доступ обычным админам.
- Не использовать `$t` — использовать `$tuman` или другое имя.
- Не забывать `$t->parse('MAIN.ROWS')` после цикла.
- Не перезаписывать `$adminTitle` через `$t->text('MAIN')`.

---

## <a name="debugging"></a>28. Отладка

### 28.1. Шаблон не подтягивается

**Симптом:** страница `admin.php?m=other&p=extensionfilter` открывается, но контент пустой или «шаблон не найден».

**Проверить:**

1. Файл `plugins/extensionfilter/tpl/extensionfilter.tools.tpl` существует.
2. Имя файла — точно `extensionfilter.tools.tpl`, не `extensionfilter.admin.tpl`, не с другим регистром.
3. `cot_tplfile('extensionfilter.tools', 'plug', true)` возвращает корректный путь.

Временная проверка:

```php
var_dump(cot_tplfile('extensionfilter.tools', 'plug', true)); exit;
```

- Если `false` — файла нет или путь неверный.
- Если путь — файл есть, но что-то с правами чтения или содержимым.

### 28.2. «12 / 12, но строк нет»

**Симптом:** счётчик показывает 12, но таблица пустая.

**Причина:** пропущен `$t->parse('MAIN.ROWS')` после цикла.

**Проверка:** в `extensionfilter.tools.php` после `foreach` должна быть строка `$t->parse('MAIN.ROWS')`.

### 28.3. «404 на остальных ссылках»

**Симптом:** открывается `admin.php?m=other&p=extensionfilter`, но переход на вкладку «Плагины» ведёт на 404.

**Причина:** неправильное формирование URL. В версии 1.0.3 все URL формируются через `cot_url('admin', ['m' => 'other', 'p' => 'extensionfilter', 'tab' => 'plug'])`, что даёт `admin.php?m=other&p=extensionfilter&tab=plug`. Это корректно.

Проверьте, что в `setup.php` в блоке `[BEGIN_COT_EXT]` нет параметра `Order` или других, ломающих установку.

### 28.4. Логика фильтров не срабатывает

**Симптом:** выбрал код из списка, нажал «Поиск», но результат прежний.

**Проверить:**

1. В URL появился параметр `fcode=<code>`.
2. `cot_import('fcode', 'G', 'ALP')` возвращает ожидаемое.
3. Массив `$extensions` содержит этот код (`isset($filtered[$fCode])`).

Отладка:

```php
var_dump($fCode, isset($extensions[$fCode])); exit;
```

### 28.5. `$adminTitle` содержит HTML

**Симптом:** в `<title>` отображается `<div class="row">...`.

**Причина:** `$adminTitle = $t->text('MAIN');` вместо `$pluginBody = $t->text('MAIN');`.

**Исправление:** заменить на `$pluginBody`.

### 28.6. Кеш

Всегда после правки PHP-файлов или шаблонов очищать кеш Cotonti:

- админка → «Кеш» → «Очистить все»;
- или удалить папку `datas/cache/templates/` (временно, до следующего захода).

---

## <a name="compatibility"></a>29. Совместимость и ограничения

### 29.1. Совместимость по PHP

| PHP | Совместимость |
|---|---|
| 8.5+ | Полная |
| 8.4 | Полная |
| 8.3 | Полная |
| 8.2 | Полная |
| 8.1 | Полная |
| 8.0 | Полная |
| 7.4 | Не гарантируется (используется `?string`, `mixed`, `match` в ядре Cotonti) |

Код плагина не использует конструкций, специфичных для PHP 8.5. Минимальная версия определяется Cotonti (7.3+ для самого ядра, но в репозитории заявлено 8.5+).

### 29.2. Совместимость по Cotonti

| Версия Cotonti | Совместимость |
|---|---|
| 1.0.0+ | Полная |
| 0.9.26 | Не гарантируется |

Плагин использует современные классы `Cot`, `Cot::$db`, `Cot::$cfg`, `Cot::$L`. Для старых версий Cotonti потребуется адаптация.

### 29.3. Совместимость по MySQL

| MySQL | Совместимость |
|---|---|
| 8.4 | Полная |
| 8.0 | Полная |
| 5.7 | Полная |

Плагин использует стандартный SQL через PDO. Специфичных для MySQL 8.4 конструкций нет.

### 29.4. Ограничения

- **Нет кеширования** результатов — при сотнях расширений страница может работать дольше.
- **Нет пагинации** — все расширения выводятся на одной странице.
- **Нет сортировки по столбцам** — только по коду (естественная).
- **Нет AJAX** — фильтрация через перезагрузку страницы.
- **Нет своего поиска по описанию** — только по коду и названию.
- **Одна вкладка — одно расширение** — список «модули» и «плагины» разделён, но не смешан.

Все эти ограничения сознательны: плагин решает конкретную задачу минимальным кодом.

---

## <a name="changelog"></a>30. История версий

### Версия 1.0.3 (2026-10-19)

- Релиз в репозитории `https://github.com/webitproff/extensionfilter-cotonti`.
- Стабильная версия.
- Функционал: две вкладки (модули/плагины), три фильтра (код, имя, ключевое слово), таблица результатов, ссылки на сведения.

### Версия 1.0.2 (внутренняя)

- Отладка: исправлен `$adminTitle = $t->text('MAIN')` → `$pluginBody = $t->text('MAIN')`.
- Отладка: добавлено `$t->parse('MAIN.ROWS')` после цикла.

### Версия 1.0.1 (внутренняя)

- Отладка: убрана лишняя проверка `cot_auth('plug', 'extensionfilter', 'A')`.

### Версия 1.0.0 (2026-10-19)

- Первый релиз.
- Базовая функциональность.

---

## <a name="support"></a>31. Поддержка

### 31.1. Репозиторий

- **GitHub:** https://github.com/webitproff/extensionfilter-cotonti
- **Issues:** https://github.com/webitproff/extensionfilter-cotonti/issues
- **Pull Requests:** https://github.com/webitproff/extensionfilter-cotonti/pulls

### 31.2. Маркетплейс

- **Страница плагина:** https://abuyfile.com/market/cotonti/plugs/extensionfilter
- **Форум:** https://abuyfile.com/forums/cotonti/custom/

### 31.3. Как сообщить об ошибке

Создайте Issue на GitHub с указанием:

1. Версия плагина (`1.0.3`).
2. Версия Cotonti (например, `1.0.0`).
3. Версия PHP (`8.5.0`).
4. Версия MySQL (`8.4.0`).
5. Шаги воспроизведения.
6. Ожидаемое поведение.
7. Фактическое поведение.
8. Скриншот или текст ошибки.

---

## <a name="license"></a>32. Лицензия

Плагин распространяется под лицензией **BSD-3-Clause**.

Полный текст:

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

**Что разрешено:**

- Использовать в коммерческих и некоммерческих проектах.
- Модифицировать.
- Распространять в исходном и бинарном виде.
- Встраивать в другие продукты.

**Что требуется:**

- Сохранять текст копирайта в исходниках.
- Воспроизводить копирайт в документации (для бинарных сборок).
- Не использовать имя автора или название продукта без разрешения для продвижения производных.

**Что не гарантируется:**

- Отсутствие ошибок.
- Пригодность для конкретной цели.
- Ответственность автора за любые последствия.

---

## Приложение A. Полная структура проекта

```
extensionfilter-cotonti/
├── README.md                           ← этот файл
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

## Приложение B. Быстрый старт

```bash
# Клонирование
git clone https://github.com/webitproff/extensionfilter-cotonti.git

# Копирование в плагины Cotonti
cp -r extensionfilter-cotonti /path/to/cotonti/plugins/extensionfilter

# Установка через админку
# 1. Открыть https://yoursite.com/admin.php?m=extensions
# 2. Найти "Extensions Filter"
# 3. Нажать "Установить"

# Использование
# Открыть https://yoursite.com/admin.php?m=other&p=extensionfilter
```

## Приложение C. Проверочный список перед публикацией изменений

- [ ] Все файлы соответствуют кодировке UTF-8 без BOM.
- [ ] Все PHP-файлы начинаются с `<?php` без пробела перед ним.
- [ ] Все PHP-файлы после `<?php` имеют проверку `defined('COT_CODE') or die('Wrong URL.');`.
- [ ] Версия в `setup.php` обновлена.
- [ ] Версия в PHPDoc-блоках обновлена.
- [ ] Языковые файлы содержат все ключи из `README.md`.
- [ ] Шаблон использует все теги из `README.md`.
- [ ] `$pluginBody` в конце обработчика, не `$adminTitle`.
- [ ] `$t->parse('MAIN.ROWS')` после цикла по строкам.
- [ ] Кеш Cotonti очищен.
- [ ] Протестировано на трёх вкладках (модули, плагины, пустой результат).
- [ ] Протестировано на пустых фильтрах и на совпадающих.
- [ ] Протестировано на установленном и неустановленном расширении.
- [ ] Проверена кодировка URL с русскими буквами в названии.
- [ ] Проверена работа на PHP 8.5.
- [ ] Проверена работа на MySQL 8.4.

---

**Конец документа.**
