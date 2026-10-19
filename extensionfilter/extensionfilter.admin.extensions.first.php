<?php
/* ====================
[BEGIN_COT_EXT]
Hooks=admin.extensions.first
[END_COT_EXT]
==================== */

defined('COT_CODE') or die('Wrong URL.');

require_once cot_langfile('extensionfilter', 'plug');

$t->assign([
    'ADMIN_EXTENSIONFILTER_SEARCH_URL'    => cot_url('admin', ['m' => 'other', 'p' => 'extensionfilter']),
    'ADMIN_EXTENSIONFILTER_SEARCH_TITLE'  => Cot::$L['extensionfilter_title'],
    'ADMIN_EXTENSIONFILTER_MODULES_URL'   => cot_url('admin', ['m' => 'other', 'p' => 'extensionfilter', 'tab' => 'module']),
    'ADMIN_EXTENSIONFILTER_MODULES_TITLE' => Cot::$L['extensionfilter_tab_module'],
    'ADMIN_EXTENSIONFILTER_PLUGINS_URL'   => cot_url('admin', ['m' => 'other', 'p' => 'extensionfilter', 'tab' => 'plug']),
    'ADMIN_EXTENSIONFILTER_PLUGINS_TITLE' => Cot::$L['extensionfilter_tab_plug'],
]);