<?php
/* ====================
[BEGIN_COT_EXT]
Hooks=tools
[END_COT_EXT]
==================== */

/**
 * extensionfilter plugin for Cotonti v1.+, PHP 8.5+, MySQL 8.4 
 * Хук tools. Добавляем плагину интерфейс и инструменты управления.
 * Админка плагина. Просмотр, фильтр и поиска расширений
 * 
 * Filename: plugins/extensionfilter/extensionfilter.tools.php 
 *
 * ReadMeMore:       https://abuyfile.com/market/cotonti/plugs/extensionfilter
 * Support:          https://abuyfile.com/forums/cotonti/custom/
 * Source:           https://github.com/webitproff/extensionfilter-cotonti
 * 
 * Date: Oct 19, 2026
 * @package extensionfilter
 * @version 1.0.3
 * @author webitproff
 * @copyright Copyright (c) webitproff 2026 | https://github.com/webitproff/extensionfilter-cotonti
 * @license BSD
 */



defined('COT_CODE') or die('Wrong URL.');

require_once cot_incfile('extensionfilter', 'plug');


$t = new XTemplate(cot_tplfile('extensionfilter.tools', 'plug', true));

$adminTitle = Cot::$L['extensionfilter_title'];
$adminPath[] = [cot_url('admin', ['m' => 'other', 'p' => 'extensionfilter']), Cot::$L['extensionfilter_title']];

$tab = cot_import('tab', 'G', 'ALP');
if ($tab !== 'module' && $tab !== 'plug') {
    $tab = 'module';
}

$isModule = ($tab === 'module');
$dir = $isModule ? Cot::$cfg['modules_dir'] : Cot::$cfg['plugins_dir'];

$extensions = cot_extension_list_info($dir);

$installed = Cot::$db->query(
    'SELECT ct_code, ct_version FROM ' . Cot::$db->core . ' WHERE ct_plug = ?',
    [(int)!$isModule]
)->fetchAll(PDO::FETCH_KEY_PAIR);

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

$codes = [];
$names = [];
foreach ($extensions as $code => $info) {
    $codes[$code] = $code;
    $names[$code] = ($info['Name'] !== '') ? $info['Name'] : $code;
}
asort($codes, SORT_NATURAL | SORT_FLAG_CASE);
asort($names, SORT_NATURAL | SORT_FLAG_CASE);

$fCode    = (string) cot_import('fcode', 'G', 'ALP');
$fName    = (string) cot_import('fname', 'G', 'TXT');
$fKeyword = (string) cot_import('fkeyword', 'G', 'TXT');

$filtered = $extensions;
if ($fCode !== '' && isset($filtered[$fCode])) {
    $filtered = [$fCode => $filtered[$fCode]];
} elseif ($fCode !== '') {
    $filtered = [];
}

if ($fName !== '') {
    $res = [];
    foreach ($filtered as $code => $info) {
        if ($code === $fName) {
            $res[$code] = $info;
        }
    }
    $filtered = $res;
}

if ($fKeyword !== '') {
    $kw = mb_strtolower($fKeyword);
    $res = [];
    foreach ($filtered as $code => $info) {
        $hay = mb_strtolower($code . ' ' . (string)$info['Name']);
        if (mb_strpos($hay, $kw) !== false) {
            $res[$code] = $info;
        }
    }
    $filtered = $res;
}
ksort($filtered, SORT_NATURAL | SORT_FLAG_CASE);

$baseParams = ['m' => 'other', 'p' => 'extensionfilter', 'tab' => $tab];

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
if (count($filtered) === 0) {
    $t->parse('MAIN.NO_RESULTS');
}

cot_display_messages($t);

$t->parse('MAIN');
$pluginBody = $t->text('MAIN');