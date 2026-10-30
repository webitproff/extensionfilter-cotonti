<?php
/* ====================
[BEGIN_COT_EXT]
Hooks=tools
[END_COT_EXT]
==================== */

/**
 * extensionfilter plugin for Cotonti v1.+, PHP 8.5+, MySQL 8.4
 * Хук tools. Админка плагина: список расширений с фильтрацией.
 *
 * Filename: plugins/extensionfilter/extensionfilter.tools.php
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
 */

defined('COT_CODE') or die('Wrong URL.');

// Подключаем API плагина (lang + cot_incfile('extensions'), где объявлены
// cot_extension_list_info(), cot_get_extensionparams() и т.д.).
require_once cot_incfile('extensionfilter', 'plug');

// Основной шаблон страницы: ищется в теме (themes/admin/<theme>/plugins/...)
// и в plugins/extensionfilter/tpl/. Третий аргумент true — искать в админ-каталогах.
$t = new XTemplate(cot_tplfile('extensionfilter.tools', 'plug', true));

// Заголовок и хлебные крошки
$adminTitle = Cot::$L['extensionfilter_title'];
$adminPath[] = [cot_url('admin', ['m' => 'other', 'p' => 'extensionfilter']), Cot::$L['extensionfilter_title']];

/* =====================================================================
 * 1. Активная вкладка
 * =====================================================================
 * Допустимые значения: 'module' (по умолчанию) и 'plug'.
 * Любое иное значение из GET приравнивается к 'module'.
 * Параметр $tab определяет:
 *   - из какого каталога читать setup-файлы (modules_dir / plugins_dir);
 *   - какой флаг ct_plug использовать в SELECT к cot_core.
 */
$tab = cot_import('tab', 'G', 'ALP');
if ($tab !== 'module' && $tab !== 'plug') {
    $tab = 'module';
}

$isModule = ($tab === 'module');
$dir = $isModule ? Cot::$cfg['modules_dir'] : Cot::$cfg['plugins_dir'];

/* =====================================================================
 * 2. Список расширений: с диска + «призраки» из cot_core
 * =====================================================================
 * cot_extension_list_info($dir) обходит каталоги и возвращает
 *   [code => info_array]
 * для каждого каталога, где найден <code>.setup.php.
 *
 * $installed — карта [code => version] из cot_core для выбранного типа.
 *
 * Если код есть в cot_core, но на диске каталога нет — добавляем
 * заглушку с NotFound=true:
 *   - это нужно, чтобы «призрак» отобразился в списке;
 *   - чтобы $statusMap мог корректно вычислить для него 'missing'.
 */
$extensions = cot_extension_list_info($dir);

$installed = Cot::$db->query(
    'SELECT ct_code, ct_version FROM ' . Cot::$db->core . ' WHERE ct_plug = ?',
    [(int)!$isModule]
)->fetchAll(PDO::FETCH_KEY_PAIR);

foreach ($installed as $code => $version) {
    if (!isset($extensions[$code])) {
        $extensions[$code] = [
            'Code'        => $code,
            'Name'        => $code,
            'Description' => '',
            'Version'     => $version,
            'Category'    => 'misc-ext',
            'NotFound'    => true,   // маркер: на диске нет setup-файла
        ];
    }
}

/* =====================================================================
 * 3. Данные для <select name="fcode"> и <select name="fname">
 * =====================================================================
 * $codes — код => код (для «фильтр по коду»).
 * $names — код => название (для «фильтр по имени», значение — тоже код,
 *          чтобы фильтр $fName сравнивался с $code).
 * Сортируем оба списка natural case-insensitive.
 */
$codes = [];
$names = [];
foreach ($extensions as $code => $info) {
    $codes[$code] = $code;
    $names[$code] = ($info['Name'] !== '') ? $info['Name'] : $code;
}
asort($codes, SORT_NATURAL | SORT_FLAG_CASE);
asort($names, SORT_NATURAL | SORT_FLAG_CASE);

/* =====================================================================
 * 4. Приём параметров фильтра из GET
 * =====================================================================
 *   fcode    — точный код расширения (ALP — только буквы/цифры);
 *   fname    — точный код расширения (TXT — так исторически сложилось);
 *   fkeyword — подстрока без учёта регистра по строке «код + название»;
 *   fstatus  — один из 5 статусов (см. $statusKeys ниже).
 */
$fCode    = (string) cot_import('fcode', 'G', 'ALP');
$fName    = (string) cot_import('fname', 'G', 'TXT');
$fKeyword = (string) cot_import('fkeyword', 'G', 'TXT');
$fStatus  = (string) cot_import('fstatus', 'G', 'ALP');

/* Карта «код статуса => подпись» для <select>.
 * Здесь Cot::$L['adm_*'] — plain-text (без HTML), потому что
 * cot_selectbox() экранирует значения через htmlspecialchars.
 * Использовать $R['admin_code_*'] (там <span>) в опциях нельзя. */
$statusKeys = [
    'paused'       => Cot::$L['adm_paused'],
    'running'      => Cot::$L['adm_running'],
    'partrunning'  => Cot::$L['adm_partrunning'],
    'notinstalled' => Cot::$L['adm_notinstalled'],
    'missing'      => Cot::$L['adm_missing'],
];

// Защита от мусора в GET: если fstatus не из списка — сбрасываем фильтр.
if ($fStatus !== '' && !isset($statusKeys[$fStatus])) {
    $fStatus = '';
}

/* =====================================================================
 * 5. Статистика по частям расширений — один GROUP BY
 * =====================================================================
 *   $partStats[$code] = [SUM(pl_active), COUNT(*)]
 *
 *   SUM(pl_active) — сколько частей активно;
 *   COUNT(*)       — сколько всего частей зарегистрировано.
 *
 * Нужна для вычисления статусов running / paused / partrunning
 * для КАЖДОГО расширения без N+1 запросов в цикле.
 */
$partStats = [];
foreach (
    Cot::$db->query(
        'SELECT pl_code, SUM(pl_active) AS sum, COUNT(*) AS cnt '
        . 'FROM ' . Cot::$db->plugins . ' GROUP BY pl_code'
    )->fetchAll() as $row
) {
    $partStats[$row['pl_code']] = [(int) $row['sum'], (int) $row['cnt']];
}

/* =====================================================================
 * 6. Единая карта статусов $statusMap
 * =====================================================================
 * Вычисляется ОДИН раз для всех расширений — до фильтрации.
 *
 * Правила идентичны переменной $part_status в
 * system/admin/admin.extensions.php (ядро):
 *
 *   3 notinstalled — нет записи в cot_core;
 *   4 missing      — есть в cot_core, но каталога на диске нет
 *                    (наш маркер NotFound=true);
 *   2 partrunning  — активны не все части: 0 < active < total;
 *   0 paused       — все части выключены: active == 0, total > 0;
 *   1 running      — все части включены: active == total.
 *
 * $statusMap используется и в фильтре fstatus, и в render-цикле.
 * Это даёт гарантию: «что отфильтровали — то и покажем в строке».
 * Никаких расхождений между фильтром и отображением.
 */
$statusMap = [];
foreach ($extensions as $code => $info) {
    $inCore = isset($installed[$code]);
    $exists = empty($info['NotFound']);
    [$active, $total] = $partStats[$code] ?? [0, 0];

    if (!$inCore) {
        // В cot_core нет — значит, не установлено. Отсутствие setup-файла
        // здесь неважно: если оно и вовсе не установлено, статус один.
        $st = 'notinstalled';
    } elseif (!$exists) {
        // В cot_core есть, а на диске каталога нет — «призрак».
        $st = 'missing';
    } elseif ($total > $active && $active > 0) {
        // Часть частей активна, часть — нет.
        $st = 'partrunning';
    } elseif ($active === 0 && $total > 0) {
        // Все зарегистрированные части выключены.
        $st = 'paused';
    } else {
        // Все части активны (или частей вообще нет — трактуем как running,
        // как и ядро).
        $st = 'running';
    }
    $statusMap[$code] = $st;
}

/* =====================================================================
 * 7. Фильтрация
 * =====================================================================
 * Порядок применения: fcode → fname → fkeyword → fstatus.
 * Каждый следующий фильтр сужает уже отфильтрованный массив.
 */
$filtered = $extensions;

/* 7.1. fcode — точное совпадение по коду расширения.
 * Если код передан, но в массиве его нет — результат пустой. */
if ($fCode !== '' && isset($filtered[$fCode])) {
    $filtered = [$fCode => $filtered[$fCode]];
} elseif ($fCode !== '') {
    $filtered = [];
}

/* 7.2. fname — точное совпадение по коду расширения
 * (историческое поведение поля «Имя» в этой форме). */
if ($fName !== '') {
    $res = [];
    foreach ($filtered as $code => $info) {
        if ($code === $fName) {
            $res[$code] = $info;
        }
    }
    $filtered = $res;
}

/* 7.3. fkeyword — подстрока без учёта регистра по строке
 * «код + пробел + название». Описание и версия в поиск не входят. */
if ($fKeyword !== '') {
    $kw = mb_strtolower($fKeyword);
    $res = [];
    foreach ($filtered as $code => $info) {
        $hay = mb_strtolower($code . ' ' . (string) $info['Name']);
        if (mb_strpos($hay, $kw) !== false) {
            $res[$code] = $info;
        }
    }
    $filtered = $res;
}

/* 7.4. fstatus — точное совпадение с вычисленным статусом.
 * Сравниваем со $statusMap[$code] — тем же значением, что используется
 * для отображения в строке. Так «paused» в фильтре гарантированно
 * покажет в строках «paused», а не «installed». */
if ($fStatus !== '') {
    $res = [];
    foreach ($filtered as $code => $info) {
        if (($statusMap[$code] ?? '') === $fStatus) {
            $res[$code] = $info;
        }
    }
    $filtered = $res;
}

// Итоговая сортировка по коду, natural case-insensitive.
ksort($filtered, SORT_NATURAL | SORT_FLAG_CASE);

/* =====================================================================
 * 8. Теги шапки, вкладок и формы
 * ===================================================================== */
$baseParams = ['m' => 'other', 'p' => 'extensionfilter', 'tab' => $tab];

$t->assign([
    'TAB_MODULE_URL'    => cot_url('admin', ['m' => 'other', 'p' => 'extensionfilter', 'tab' => 'module']),
    'TAB_PLUG_URL'      => cot_url('admin', ['m' => 'other', 'p' => 'extensionfilter', 'tab' => 'plug']),
    'TAB_MODULE_ACTIVE' => $isModule ? 'active' : '',
    'TAB_PLUG_ACTIVE'   => $isModule ? '' : 'active',
    'TAB_CURRENT_TITLE' => $isModule ? Cot::$L['extensionfilter_tab_module'] : Cot::$L['extensionfilter_tab_plug'],
    'TAB_CURRENT_ICON'  => $isModule ? 'fa-solid fa-cube' : 'fa-solid fa-plug',

    // action формы и ссылка «Сброс» — одинаковы: оба ведут на URL
    // без фильтров, но с текущей вкладкой.
    'FORM_URL'          => cot_url('admin', $baseParams),
    'RESET_URL'         => cot_url('admin', $baseParams),

    'TAB'               => $tab,

    // Три <select> — значения plain-text, поэтому используем
    // $codes / $names / $statusKeys (код + подпись), а не $R['admin_code_*'].
    'SELECT_CODE'       => cot_selectbox($fCode, 'fcode', array_keys($codes), array_values($codes), true),
    'SELECT_NAME'       => cot_selectbox($fName, 'fname', array_keys($names), array_values($names), true),
    'SELECT_STATUS'     => cot_selectbox($fStatus, 'fstatus', array_keys($statusKeys), array_values($statusKeys), true),

    // Значение поля keyword — экранируем, чтобы не сломать атрибут value.
    'KEYWORD'           => htmlspecialchars($fKeyword),

    'RESULTS_COUNT'     => count($filtered),
    'TOTAL_COUNT'       => count($extensions),
]);

/* =====================================================================
 * 9. Строки списка
 * =====================================================================
 * Для каждого расширения:
 *   - $detailsUrl    — ссылка на карточку в admin.extensions;
 *   - $params['icon'] — готовая HTML-разметка иконки;
 *   - $st            — берём из $statusMap, чтобы статус в строке
 *                      совпадал с тем, по которому сработал фильтр;
 *   - ROW_STATUS     — готовый <span class="..."> из $R['admin_code_*'].
 *                      Отдельный ROW_STATUS_CLASS не нужен: классы
 *                      уже внутри ресурсной строки.
 * ===================================================================== */
foreach ($filtered as $code => $info) {
    $detailsUrl = cot_url('admin', [
        'm' => 'extensions',
        'a' => 'details',
        ($isModule ? 'mod' : 'pl') => $code,
    ]);
    $params = cot_get_extensionparams($code, $isModule);
    $st = $statusMap[$code] ?? 'notinstalled';

    $t->assign([
        'ROW_CODE'        => htmlspecialchars($code),
        'ROW_NAME'        => htmlspecialchars((string) ($info['Name'] !== '' ? $info['Name'] : $code)),
        'ROW_ICON'        => $params['icon'],
        'ROW_VERSION'     => htmlspecialchars((string) $info['Version']),
        'ROW_DESCRIPTION' => htmlspecialchars((string) $info['Description']),
        'ROW_DETAILS_URL' => $detailsUrl,
        'ROW_STATUS'      => $R['admin_code_' . $st],
    ]);
    $t->parse('MAIN.ROWS.ROW');
}
$t->parse('MAIN.ROWS');

// Пустое состояние: если после всех фильтров ничего не осталось.
if (count($filtered) === 0) {
    $t->parse('MAIN.NO_RESULTS');
}

// Системные сообщения (ошибки, предупреждения)
cot_display_messages($t);

$t->parse('MAIN');
$pluginBody = $t->text('MAIN');
