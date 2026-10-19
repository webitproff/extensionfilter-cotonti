<!-- 
/**
 * extensionfilter plugin for Cotonti v1.+, PHP 8.5+, MySQL 8.4 
 * Добавляем плагину интерфейс и инструменты управления.
 * Админка плагина. Просмотр, фильтр и поиска расширений
 * 
 * Filename: plugins/extensionfilter/tpl/extensionfilter.tools.tpl
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
 -->

<!-- BEGIN: MAIN -->

<div class="row">
    <div class="col-12">
        <ul class="nav nav-tabs mb-3">
            <li class="nav-item">
                <a class="nav-link {TAB_MODULE_ACTIVE}" href="{TAB_MODULE_URL}">{PHP.L.extensionfilter_tab_module}</a>
            </li>
            <li class="nav-item">
                <a class="nav-link {TAB_PLUG_ACTIVE}" href="{TAB_PLUG_URL}">{PHP.L.extensionfilter_tab_plug}</a>
            </li>
        </ul>

        <form method="get" action="{FORM_URL}" class="card mb-3">
            <input type="hidden" name="m" value="other" />
            <input type="hidden" name="p" value="extensionfilter" />
            <input type="hidden" name="tab" value="{TAB}" />
            <div class="card-body">
                <div class="row g-2">
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
                </div>
                <div class="mt-3">
                    <button type="submit" class="btn btn-primary">{PHP.L.extensionfilter_btn_search}</button>
                    <a href="{RESET_URL}" class="btn btn-outline-secondary">{PHP.L.extensionfilter_btn_reset}</a>
                </div>
            </div>
        </form>

        <div class="text-muted small mb-2">{RESULTS_COUNT} / {TOTAL_COUNT}</div>

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
                        
                    </div>
                </div>
            </div>
            <!-- END: ROW -->
            <!-- END: ROWS -->
        </div>
        <!-- ENDIF -->

        <!-- BEGIN: NO_RESULTS -->
        <div class="alert alert-info">{PHP.L.extensionfilter_no_results}</div>
        <!-- END: NO_RESULTS -->
    </div>
</div>
<!-- END: MAIN -->