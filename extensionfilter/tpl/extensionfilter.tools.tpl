<!-- 
	/**
	* extensionfilter plugin for Cotonti v1.+, PHP 8.5+, MySQL 8.4 
	* Добавляем плагину интерфейс и инструменты управления.
	* Админка плагина. Просмотр, фильтр и поиска расширений
	* 
	* Filename: plugins/extensionfilter/tpl/extensionfilter.tools.tpl
	* Recommended: themes/admin/{admintheme}/plugins/extensionfilter/extensionfilter.tools.tpl
	* Main business logic: plugins/extensionfilter/extensionfilter.tools.php
	* 
	* ReadMeMore:       https://abuyfile.com/market/cotonti/plugs/extensionfilter
	* Support:          https://abuyfile.com/forums/cotonti/custom/
	* Source:           https://github.com/webitproff/extensionfilter-cotonti
	* 
	* Date: Oct 30, 2026
	* @package extensionfilter
	* @version 1.0.5
	* @author webitproff
	* @copyright Copyright (c) webitproff 2026 | https://github.com/webitproff/extensionfilter-cotonti
	* @license BSD
	*
	* =====================================================================
	* НАЗНАЧЕНИЕ
	* =====================================================================
	*   Шаблон административной страницы плагина Extension Filter.
	*   Открывается по адресу admin.php?m=other&p=extensionfilter и
	*   показывает:
	*     • переключатель «Модули / Плагины» в виде вкладок;
	*     • форму фильтрации: точный код, точное имя, ключевое слово;
	*     • счётчик «найдено / всего»;
	*     • список расширений с иконкой, кодом, названием, описанием,
	*       версией и статусом (установлено / не установлено);
	*     • ссылку на карточку расширения (admin.extensions.a=details);
	*     • пустое состояние, когда ничего не найдено.
	*   Все данные собираются в plugins/extensionfilter/extensionfilter.tools.php
	*   через хук tools. Результат возвращается в $pluginBody; ядро
	*   (admin.other.php) конкатенирует его в $adminMain, а уже admin.tpl
	*   подставляет в тег <открывающая фигурная скобка>ADMIN_MAIN<закрывающая фигурная>.
	*
	*   ПРИМЕР admin.php?m=other&p=extensionfilter
	*   ПРИМЕР admin.php?m=other&p=extensionfilter&tab=plug
	*   ПРИМЕР admin.php?m=other&p=extensionfilter&tab=module&fkeyword=cache
	*
	* =====================================================================
	* ПАРАМЕТРЫ URL
	* =====================================================================
	*   m=other               — раздел «Прочее» админки;
	*   p=extensionfilter     — код плагина (обязательно совпадает
	*                           с именем каталога plugins/extensionfilter);
	*   tab=module|plug       — активная вкладка. Импортируется через
	*                           cot_import('tab', 'G', 'ALP'); если не
	*                           равно ни 'module', ни 'plug' — ставится
	*                           'module';
	*   fcode=<код>           — фильтр по точному коду расширения
	*                           (cot_import 'ALP');
	*   fname=<имя>           — фильтр по точному имени расширения
	*                           (cot_import 'TXT');
	*   fkeyword=<подстрока>  — поиск подстроки без учёта регистра
	*                           (mb_strtolower + mb_strpos) по строке
	*                           «код + пробел + название». Название
	*                           берётся из info['Name'] каталога, а не
	*                           из массива $names.
	*
	*   Фильтры можно комбинировать: сначала применяется fcode,
	*   затем fname, затем fkeyword. Результат сортируется через
	*   ksort($filtered, SORT_NATURAL | SORT_FLAG_CASE).
	*
	* =====================================================================
	* ИСТОЧНИКИ ДАННЫХ
	* =====================================================================
	*   • cot_extension_list_info($dir) — каталог $isModule ?
	*     Cot::$cfg['modules_dir'] : Cot::$cfg['plugins_dir'];
	*   • Cot::$db->core (SELECT ct_code, ct_version WHERE ct_plug = ?)
	*     — установленные расширения нужного типа. Если расширение
	*     есть в БД, но отсутствует на диске — в массив $extensions
	*     добавляется заглушка с полями Code, Name (= код), Version
	*     (= установленная версия), Category='misc-ext', NotFound=true.
	*     Description в заглушке пустой.
	*
	* =====================================================================
	* ТЕГИ ШАБЛОНА
	* =====================================================================
	*   ===== Текущая вкладка =====
	*     <открывающая фигурная скобка>TAB_CURRENT_TITLE<закрывающая фигурная>
	*       — локализованный заголовок активной вкладки:
	*         Cot::$L['extensionfilter_tab_module'] или
	*         Cot::$L['extensionfilter_tab_plug'];
	*     <открывающая фигурная скобка>TAB_CURRENT_ICON<закрывающая фигурная>
	*       — CSS-класс иконки для <i class="...">:
	*         'fa-solid fa-cube' для модулей,
	*         'fa-solid fa-plug' для плагинов.
	*
	*   ===== Навигация по вкладкам =====
	*     <открывающая фигурная скобка>TAB_MODULE_URL<закрывающая фигурная>
	*       — URL текущей страницы с tab=module;
	*     <открывающая фигурная скобка>TAB_PLUG_URL<закрывающая фигурная>
	*       — URL текущей страницы с tab=plug;
	*     <открывающая фигурная скобка>TAB_MODULE_ACTIVE<закрывающая фигурная>
	*       — 'active' или '' — для добавления к классу .nav-link;
	*     <открывающая фигурная скобка>TAB_PLUG_ACTIVE<закрывающая фигурная>
	*       — то же для второй вкладки.
	*
	*   ===== Форма фильтра =====
	*     <открывающая фигурная скобка>FORM_URL<закрывающая фигурная>
	*       — action формы; равен URL текущей вкладки без GET-фильтров;
	*     <открывающая фигурная скобка>RESET_URL<закрывающая фигурная>
	*       — то же значение; используется кнопкой «Сброс» как href;
	*     <открывающая фигурная скобка>TAB<закрывающая фигурная>
	*       — 'module' или 'plug' для скрытого input name="tab";
	*     <открывающая фигурная скобка>SELECT_CODE<закрывающая фигурная>
	*       — <select name="fcode"> через cot_selectbox с пустым
	*         вариантом (последний аргумент true); значения — коды
	*         расширений, подписи — те же коды; отсортированы
	*         через asort(SORT_NATURAL | SORT_FLAG_CASE);
	*     <открывающая фигурная скобка>SELECT_NAME<закрывающая фигурная>
	*       — <select name="fname"> через cot_selectbox с пустым
	*         вариантом; значения — коды расширений, подписи —
	*         info['Name'] (если пусто — сам код); отсортированы
	*         тем же способом;
	*     <открывающая фигурная скобка>KEYWORD<закрывающая фигурная>
	*       — htmlspecialchars(fkeyword) для значения <input>.
	*
	*   ===== Счётчик результатов =====
	*     <открывающая фигурная скобка>RESULTS_COUNT<закрывающая фигурная>
	*       — count($filtered) — число строк после фильтрации;
	*     <открывающая фигурная скобка>TOTAL_COUNT<закрывающая фигурная>
	*       — count($extensions) — всего расширений этого типа.
	*     Выражение <открывающая фигурная скобка>RESULTS_COUNT<закрывающая фигурная> > 0
	*     используется как IF-условие вокруг всего блока списка.
	*
	*   ===== Строка расширения (BEGIN: ROWS → BEGIN: ROW) =====
	*     <открывающая фигурная скобка>ROW_CODE<закрывающая фигурная>
	*       — код расширения (htmlspecialchars);
	*     <открывающая фигурная скобка>ROW_NAME<закрывающая фигурная>
	*       — название из info['Name'] или сам код, если пусто
	*         (htmlspecialchars);
	*     <открывающая фигурная скобка>ROW_ICON<закрывающая фигурная>
	*       — HTML-разметка иконки из cot_get_extensionparams()['icon']
	*         (обычно <img src="...">). Выводится как готовая разметка
	*         внутри <figure>, не как CSS-класс;
	*     <открывающая фигурная скобка>ROW_VERSION<закрывающая фигурная>
	*       — версия из info['Version'] (htmlspecialchars);
	*     <открывающая фигурная скобка>ROW_DESCRIPTION<закрывающая фигурная>
	*       — описание из info['Description'] (htmlspecialchars);
	*     <открывающая фигурная скобка>ROW_DETAILS_URL<закрывающая фигурная>
	*       — URL карточки расширения
	*         (admin.extensions&a=details&mod=<код> для модуля
	*          или &pl=<код> для плагина);
	*     <открывающая фигурная скобка>ROW_STATUS<закрывающая фигурная>
	*       — статус (установлено / не установлено):
	*         Cot::$L['extensionfilter_status_installed'] при наличии
	*         кода в выборке из Cot::$db->core, иначе
	*         Cot::$L['extensionfilter_status_notinstalled'];
	*     <открывающая фигурная скобка>ROW_STATUS_CLASS<закрывающая фигурная>
	*       — CSS-суффикс бейджа: 'success' для установленных,
	*         'secondary' для остальных. Подставляется в
	*         class="badge text-bg-<...>".
	*
	*   ===== Пустое состояние (BEGIN: NO_RESULTS) =====
	*     Парсится, если count($filtered) === 0.
	*     Содержит только <открывающая фигурная скобка>PHP.L.extensionfilter_no_results<закрывающая фигурная>.
	*
	*   ===== Отладка =====
	*     Блок с путём к текущему tpl:
	*       <открывающая фигурная скобка>PHP|function_exists('cot_debug_tpl_url')<закрывающая фигурная>
	*         — обёртка, сработает только если функция определена;
	*       <открывающая фигурная скобка>PHP.L.cotcp_path_current_tpl<закрывающая фигурная>
	*         — подпись «Путь текущего шаблона»
	*           (ключ темы cotcp, может отсутствовать в чужой теме);
	*       <открывающая фигурная скобка>PHP|cot_debug_tpl_url()<закрывающая фигурная>
	*         — абсолютный URL текущего tpl.
	*
	* =====================================================================
	* ПРАВИЛА И ОГРАНИЧЕНИЯ
	* =====================================================================
	*   • ROW_ICON — это готовая HTML-разметка (обычно img), а не
	*     CSS-класс. Выводится внутри <figure> без экранирования.
	*     Не путать с TAB_CURRENT_ICON — тот содержит только классы.
	*   • Фильтр fcode работает строго по точному совпадению кода.
	*     Если код не найден — итог пустой (не «поиск по подстроке»).
	*     Для поиска по подстроке используйте fkeyword.
	*   • Фильтр fname сравнивает строго $code === $fName, где $fName
	*     импортируется как 'TXT'. То есть в поле нужно ввести именно
	*     КОД расширения, а не отображаемое имя. Совпадение по
	*     info['Name'] не выполняется.
	*   • Фильтр fkeyword ищет по строке «код + пробел + info['Name']»
	*     без учёта регистра. Описание и версия в поиск не входят.
	*   • Заглушки для установленных, но отсутствующих на диске
	*     расширений получают:
	*       Name    = код,
	*       Version = версия из БД,
	*       Description = '',
	*       Category = 'misc-ext',
	*       NotFound = true.
	*     На этой странице флаг NotFound нигде не отображается —
	*     запись выглядит как обычная, только без описания.
	*   • Обе вкладки (module / plug) — это один и тот же шаблон,
	*     меняется только источник данных (modules_dir vs plugins_dir)
	*     и активный класс на вкладке.
	*   • Форма поиска отправляется методом GET, поэтому все
	*     фильтры остаются в URL и их можно сохранять в закладки.
	*   • Кнопка «Сброс» ведёт на тот же URL без параметров
	*     fcode / fname / fkeyword — сбрасывает все три фильтра,
	*     но сохраняет активную вкладку (tab).
	*   • Отдельного cot_display_messages() блока внутри нет —
	*     сообщения, как указано выше, выводятся в общий wrapper
	*     только если плагин задаст свой; сейчас их нет.
	*
	* =====================================================================
	* ХУКИ
	* =====================================================================
	*   tools — точка входа страницы (extensionfilter.tools.php).
	*   Других шаблонных хуков внутри этой страницы плагин не вызывает.
	*
	*   Для справки: этот же плагин через отдельный файл
	*   extensionfilter.admin.extensions.first.php (хук
	*   admin.extensions.first) добавляет в шаблон admin.extensions.tpl
	*   кнопки быстрого перехода:
	*     ADMIN_EXTENSIONFILTER_SEARCH_URL,   ADMIN_EXTENSIONFILTER_SEARCH_TITLE,
	*     ADMIN_EXTENSIONFILTER_MODULES_URL,  ADMIN_EXTENSIONFILTER_MODULES_TITLE,
	*     ADMIN_EXTENSIONFILTER_PLUGINS_URL,  ADMIN_EXTENSIONFILTER_PLUGINS_TITLE.
	*   К этому шаблону (extensionfilter.tools.tpl) они не относятся —
	*   упомянуты только как общий контекст плагина.
	*
	* =====================================================================
	* ЯЗЫКОВЫЕ КЛЮЧИ
	* =====================================================================
	*   Используются прямо в шаблоне через <открывающая фигурная скобка>PHP.L.*<закрывающая фигурная>:
	*
	*   Используются в PHP и передаются в шаблон как значения тегов:
	*     extensionfilter_title (в breadcrumbs / adminTitle, не в теле tpl),
	*     extensionfilter_tab_module / extensionfilter_tab_plug
	*       (как TAB_CURRENT_TITLE),
	*     extensionfilter_status_installed / extensionfilter_status_notinstalled
	*       (как ROW_STATUS).
	*/
-->

<!-- BEGIN: MAIN -->
{FILE "{PHP.cfg.system_dir}/admin/tpl/warnings.tpl"}

<div class="row">
    <div class="col-12">

        <h2 class="mb-3">
            <i class="{TAB_CURRENT_ICON} me-1"></i>{TAB_CURRENT_TITLE}
        </h2>

        <div class="d-flex align-items-center mb-3">
            <hr class="flex-grow-1 my-0">
            <div class="fw-semibold text-muted text-uppercase mx-3 text-nowrap">
                {PHP.L.extensionfilter_found}:
                <span class="badge text-bg-success border">{RESULTS_COUNT}</span>
                <span class="mx-1">/</span>
                <span class="badge text-bg-light border">{TOTAL_COUNT}</span>
            </div>
            <hr class="flex-grow-1 my-0">
        </div>

        <ul class="nav nav-tabs mb-3">
            <li class="nav-item">
                <a class="nav-link {TAB_MODULE_ACTIVE}" href="{TAB_MODULE_URL}">{PHP.L.extensionfilter_tab_module}</a>
            </li>
            <li class="nav-item">
                <a class="nav-link {TAB_PLUG_ACTIVE}" href="{TAB_PLUG_URL}">{PHP.L.extensionfilter_tab_plug}</a>
            </li>
        </ul>

        <form method="get" action="{FORM_URL}" class="card border-0 shadow mb-3">
            <input type="hidden" name="m" value="other" />
            <input type="hidden" name="p" value="extensionfilter" />
            <input type="hidden" name="tab" value="{TAB}" />
            <div class="card-body">
                <div class="row g-3 mb-4">
                    <div class="col-12 col-md-6 col-xl-3">
                        <label class="form-label">{PHP.L.extensionfilter_filter_keyword}</label>
                        <input type="text" name="fkeyword" value="{KEYWORD}" class="form-control" />
                    </div>
                    <div class="col-12 col-md-6 col-xl-3">
                        <label class="form-label">{PHP.L.extensionfilter_filter_code}</label>
                        {SELECT_CODE}
                    </div>
                    <div class="col-12 col-md-6 col-xl-3">
                        <label class="form-label">{PHP.L.extensionfilter_filter_name}</label>
                        {SELECT_NAME}
                    </div>
                    <div class="col-12 col-md-6 col-xl-3">
                        <label class="form-label">{PHP.L.extensionfilter_filter_status}</label>
                        {SELECT_STATUS}
                    </div>
                </div>
                <div class="row g-3">
                    <div class="col-12 col-lg-6">
                        <button type="submit" class="btn btn-success w-100">
                            <i class="fa-solid fa-filter me-1"></i>{PHP.L.extensionfilter_btn_search}
                        </button>
                    </div>
                    <div class="col-12 col-lg-6">
                        <a class="btn btn-outline-danger w-100" href="{RESET_URL}">
                            <i class="fa-solid fa-broom me-1"></i>{PHP.L.extensionfilter_btn_reset}
                        </a>
                    </div>
                </div>
            </div>
        </form>

        <!-- IF {RESULTS_COUNT} > 0 -->
        <div class="list-group list-group-flush">
            <div class="list-group-item d-none d-lg-block fw-semibold text-muted bg-body-tertiary">
                <div class="row g-2">
                    <div class="col-lg-1"></div>
                    <div class="col-lg">{PHP.L.extensionfilter_col_name}</div>
                    <div class="col-lg-2">{PHP.L.extensionfilter_col_code}</div>
                    <div class="col-lg-1">{PHP.L.extensionfilter_col_version}</div>
                    <div class="col-lg-2">{PHP.L.extensionfilter_col_status}</div>
                </div>
            </div>

            <!-- BEGIN: ROWS -->
            <!-- BEGIN: ROW -->
            <a href="{ROW_DETAILS_URL}" class="list-group-item list-group-item-action text-decoration-none text-reset" title="{PHP.L.extensionfilter_view}">
                <div class="row g-2 align-items-center">
                    <div class="col-auto col-lg-1">{ROW_ICON}</div>
                    <div class="col col-lg">
                        <div class="fw-semibold">{ROW_NAME}</div>
                        <!-- IF {ROW_DESCRIPTION} -->
                        <div class="small text-muted">{ROW_DESCRIPTION}</div>
                        <!-- ENDIF -->
                    </div>
                    <div class="col-12 col-lg-2">
                        <div class="d-lg-none small text-muted">{PHP.L.extensionfilter_col_code}</div>
                        <code>{ROW_CODE}</code>
                    </div>
                    <div class="col-6 col-lg-1 text-nowrap">
                        <div class="d-lg-none small text-muted">{PHP.L.extensionfilter_col_version}</div>
                        {ROW_VERSION}
                    </div>
                    <div class="col-6 col-lg-2 text-nowrap">
                        <div class="d-lg-none small text-muted">{PHP.L.extensionfilter_col_status}</div>
                        <span class="badge text-bg-{ROW_STATUS_CLASS} p-2 rounded-3">{ROW_STATUS}</span>
                    </div>
                </div>
            </a>
            <!-- END: ROW -->
            <!-- END: ROWS -->
        </div>
        <!-- ENDIF -->

        <!-- BEGIN: NO_RESULTS -->
        <div class="alert alert-info">{PHP.L.extensionfilter_no_results}</div>
        <!-- END: NO_RESULTS -->

    </div>
</div>

<!-- IF {PHP|function_exists('cot_debug_tpl_url')} -->
<div class="alert alert-secondary m-5" role="alert">
    <div class="fw-semibold mb-2">{PHP.L.cotcp_path_current_tpl}</div>
    <div class="text-danger fw-semibold">{PHP|cot_debug_tpl_url()}</div>
</div>
<!-- ENDIF -->

<!-- END: MAIN -->
