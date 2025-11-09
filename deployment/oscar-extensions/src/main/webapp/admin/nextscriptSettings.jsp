<%--
    Copyright (c) 2024 NextScript Medical Systems. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
--%>

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin" rights="r" reverse="<%=true%>">
    <%authed=false; %>
    <%response.sendRedirect("../securityError.jsp?type=_admin");%>
</security:oscarSec>
<%
if(!authed) {
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<title>NextScript Integration Settings</title>

<meta name="viewport" content="width=device-width,initial-scale=1.0">

<link rel="stylesheet" href="<%=request.getContextPath() %>/css/bootstrap.css" type="text/css">
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css" type="text/css">
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/bootstrap-responsive.css" type="text/css">

<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.9.1.js"></script>

<style>
    .section-header {
        background-color: #f5f5f5;
        padding: 10px;
        margin-top: 20px;
        margin-bottom: 15px;
        border-left: 4px solid #1976d2;
    }
    .test-result {
        margin-top: 10px;
        padding: 10px;
        display: none;
    }
    .integration-toggle {
        margin-bottom: 15px;
    }
</style>

<script type="text/javascript">
    var config = {};

    $(document).ready(function() {
        loadConfig();

        // Save button handlers
        $("#saveRingCentral").click(function(e) {
            e.preventDefault();
            saveConfig('ringcentral');
        });

        $("#saveOcean").click(function(e) {
            e.preventDefault();
            saveConfig('ocean');
        });

        $("#saveLabs").click(function(e) {
            e.preventDefault();
            saveConfig('labs');
        });

        $("#saveSystem").click(function(e) {
            e.preventDefault();
            saveConfig('system');
        });

        // Test connection buttons
        $("#testRingCentral").click(function(e) {
            e.preventDefault();
            testRingCentral();
        });

        $("#testOcean").click(function(e) {
            e.preventDefault();
            testOcean();
        });
    });

    function loadConfig() {
        $.ajax({
            url: "<%=request.getContextPath() %>/admin/NextScriptConfig.do",
            method: 'GET',
            dataType: "json",
            success: function(data) {
                if (data.success) {
                    config = data;
                    populateForm();
                } else {
                    showMessage("Error loading configuration", "error");
                }
            },
            error: function() {
                showMessage("Error loading configuration", "error");
            }
        });
    }

    function populateForm() {
        // RingCentral
        if (config.ringcentral) {
            $("#rc_enabled").prop("checked", config.ringcentral.enabled === "true");
            $("#rc_client_id").val(config.ringcentral.client_id || "");
            $("#rc_client_secret").val(config.ringcentral.client_secret ? "**********" : "");
            $("#rc_username").val(config.ringcentral.username || "");
            $("#rc_password").val(config.ringcentral.password ? "**********" : "");
            $("#rc_extension").val(config.ringcentral.extension || "");
            $("#rc_fax_number").val(config.ringcentral.fax_number || "");
            $("#rc_sms_number").val(config.ringcentral.sms_number || "");
        }

        // Ocean
        if (config.ocean) {
            $("#ocean_enabled").prop("checked", config.ocean.enabled === "true");
            $("#ocean_site_id").val(config.ocean.site_id || "");
            $("#ocean_api_key").val(config.ocean.api_key ? "**********" : "");
        }

        // Labs
        if (config.labs) {
            $("#labs_enabled").prop("checked", config.labs.enabled === "true");
            $("#labs_provider").val(config.labs.provider || "");
            $("#labs_username").val(config.labs.username || "");
            $("#labs_password").val(config.labs.password ? "**********" : "");
        }

        // System
        if (config.system) {
            $("#clinic_name").val(config.system.clinic_name || "");
            $("#clinic_timezone").val(config.system.clinic_timezone || "America/Vancouver");
        }
    }

    function saveConfig(section) {
        var data = { section: section };

        if (section === 'ringcentral') {
            data.rc_enabled = $("#rc_enabled").is(":checked") ? "true" : "false";
            data.rc_client_id = $("#rc_client_id").val();
            data.rc_client_secret = $("#rc_client_secret").val();
            data.rc_username = $("#rc_username").val();
            data.rc_password = $("#rc_password").val();
            data.rc_extension = $("#rc_extension").val();
            data.rc_fax_number = $("#rc_fax_number").val();
            data.rc_sms_number = $("#rc_sms_number").val();
        } else if (section === 'ocean') {
            data.ocean_enabled = $("#ocean_enabled").is(":checked") ? "true" : "false";
            data.ocean_site_id = $("#ocean_site_id").val();
            data.ocean_api_key = $("#ocean_api_key").val();
        } else if (section === 'labs') {
            data.labs_enabled = $("#labs_enabled").is(":checked") ? "true" : "false";
            data.labs_provider = $("#labs_provider").val();
            data.labs_username = $("#labs_username").val();
            data.labs_password = $("#labs_password").val();
        } else if (section === 'system') {
            data.clinic_name = $("#clinic_name").val();
            data.clinic_timezone = $("#clinic_timezone").val();
        }

        $.ajax({
            url: "<%=request.getContextPath() %>/admin/NextScriptConfig.do?method=saveConfig",
            method: 'POST',
            data: data,
            dataType: "json",
            success: function(response) {
                if (response.success) {
                    showMessage(response.message || "Configuration saved successfully!", "success");
                } else {
                    showMessage(response.error || "Error saving configuration", "error");
                }
            },
            error: function() {
                showMessage("Error saving configuration", "error");
            }
        });
    }

    function testRingCentral() {
        var data = {
            clientId: $("#rc_client_id").val(),
            clientSecret: $("#rc_client_secret").val()
        };

        $("#rc_test_result").html("Testing connection...").removeClass("alert-success alert-error").addClass("alert-info").show();

        $.ajax({
            url: "<%=request.getContextPath() %>/admin/NextScriptConfig.do?method=testRingCentral",
            method: 'POST',
            data: data,
            dataType: "json",
            success: function(response) {
                if (response.success) {
                    $("#rc_test_result").html(response.message).removeClass("alert-info alert-error").addClass("alert-success");
                } else {
                    $("#rc_test_result").html(response.message).removeClass("alert-info alert-success").addClass("alert-error");
                }
            },
            error: function() {
                $("#rc_test_result").html("Connection test failed").removeClass("alert-info alert-success").addClass("alert-error");
            }
        });
    }

    function testOcean() {
        var data = {
            siteId: $("#ocean_site_id").val(),
            apiKey: $("#ocean_api_key").val()
        };

        $("#ocean_test_result").html("Testing connection...").removeClass("alert-success alert-error").addClass("alert-info").show();

        $.ajax({
            url: "<%=request.getContextPath() %>/admin/NextScriptConfig.do?method=testOcean",
            method: 'POST',
            data: data,
            dataType: "json",
            success: function(response) {
                if (response.success) {
                    $("#ocean_test_result").html(response.message).removeClass("alert-info alert-error").addClass("alert-success");
                } else {
                    $("#ocean_test_result").html(response.message).removeClass("alert-info alert-success").addClass("alert-error");
                }
            },
            error: function() {
                $("#ocean_test_result").html("Connection test failed").removeClass("alert-info alert-success").addClass("alert-error");
            }
        });
    }

    function showMessage(message, type) {
        var alertClass = type === "success" ? "alert-success" : "alert-error";
        $("#globalMessage").html(message).removeClass("alert-success alert-error").addClass(alertClass).show();
        setTimeout(function() {
            $("#globalMessage").fadeOut();
        }, 5000);
    }

</script>

</head>

<body>
    <div class="container-fluid">
        <h2>NextScript Integration Settings</h2>

        <div id="globalMessage" class="alert" style="display:none; margin-top: 20px;"></div>

        <!-- RingCentral Section -->
        <div class="section-header">
            <h3><i class="fa fa-fax"></i> RingCentral (Fax & SMS)</h3>
        </div>

        <form id="rcForm">
            <div class="row integration-toggle">
                <div class="span12">
                    <label class="checkbox">
                        <input type="checkbox" id="rc_enabled" />
                        Enable RingCentral Integration
                    </label>
                </div>
            </div>

            <div class="row">
                <div class="span6">
                    <label for="rc_client_id">Client ID</label>
                    <input class="span6" type="text" id="rc_client_id" name="rc_client_id" />
                </div>
                <div class="span6">
                    <label for="rc_client_secret">Client Secret</label>
                    <input class="span6" type="password" id="rc_client_secret" name="rc_client_secret" />
                </div>
            </div>

            <div class="row">
                <div class="span4">
                    <label for="rc_username">Username</label>
                    <input class="span4" type="text" id="rc_username" name="rc_username" />
                </div>
                <div class="span4">
                    <label for="rc_password">Password</label>
                    <input class="span4" type="password" id="rc_password" name="rc_password" />
                </div>
                <div class="span4">
                    <label for="rc_extension">Extension</label>
                    <input class="span4" type="text" id="rc_extension" name="rc_extension" />
                </div>
            </div>

            <div class="row">
                <div class="span6">
                    <label for="rc_fax_number">Fax Number</label>
                    <input class="span6" type="text" id="rc_fax_number" name="rc_fax_number" placeholder="+1234567890" />
                </div>
                <div class="span6">
                    <label for="rc_sms_number">SMS Number</label>
                    <input class="span6" type="text" id="rc_sms_number" name="rc_sms_number" placeholder="+1234567890" />
                </div>
            </div>

            <div class="row">
                <div class="span12">
                    <button type="button" id="testRingCentral" class="btn">Test Connection</button>
                    <button type="submit" id="saveRingCentral" class="btn btn-primary">Save RingCentral Settings</button>
                </div>
            </div>

            <div class="row">
                <div class="span12">
                    <div id="rc_test_result" class="alert test-result"></div>
                </div>
            </div>
        </form>

        <!-- OceanMD Section -->
        <div class="section-header">
            <h3><i class="fa fa-hospital-o"></i> OceanMD (eReferrals)</h3>
        </div>

        <form id="oceanForm">
            <div class="row integration-toggle">
                <div class="span12">
                    <label class="checkbox">
                        <input type="checkbox" id="ocean_enabled" />
                        Enable OceanMD Integration
                    </label>
                </div>
            </div>

            <div class="row">
                <div class="span6">
                    <label for="ocean_site_id">Site ID</label>
                    <input class="span6" type="text" id="ocean_site_id" name="ocean_site_id" />
                </div>
                <div class="span6">
                    <label for="ocean_api_key">API Key</label>
                    <input class="span6" type="password" id="ocean_api_key" name="ocean_api_key" />
                </div>
            </div>

            <div class="row">
                <div class="span12">
                    <button type="button" id="testOcean" class="btn">Test Connection</button>
                    <button type="submit" id="saveOcean" class="btn btn-primary">Save Ocean Settings</button>
                </div>
            </div>

            <div class="row">
                <div class="span12">
                    <div id="ocean_test_result" class="alert test-result"></div>
                </div>
            </div>
        </form>

        <!-- Lab Integration Section -->
        <div class="section-header">
            <h3><i class="fa fa-flask"></i> Laboratory Integration</h3>
        </div>

        <form id="labsForm">
            <div class="row integration-toggle">
                <div class="span12">
                    <label class="checkbox">
                        <input type="checkbox" id="labs_enabled" />
                        Enable Lab Integration
                    </label>
                </div>
            </div>

            <div class="row">
                <div class="span12">
                    <label for="labs_provider">Lab Provider</label>
                    <select class="span12" id="labs_provider" name="labs_provider">
                        <option value="">-- Select Provider --</option>
                        <option value="excelleris">Excelleris</option>
                        <option value="lifelabs">LifeLabs</option>
                        <option value="pathnet">PathNet</option>
                        <option value="meditech">MEDITECH</option>
                    </select>
                </div>
            </div>

            <div class="row">
                <div class="span6">
                    <label for="labs_username">Username</label>
                    <input class="span6" type="text" id="labs_username" name="labs_username" />
                </div>
                <div class="span6">
                    <label for="labs_password">Password</label>
                    <input class="span6" type="password" id="labs_password" name="labs_password" />
                </div>
            </div>

            <div class="row">
                <div class="span12">
                    <button type="submit" id="saveLabs" class="btn btn-primary">Save Lab Settings</button>
                </div>
            </div>
        </form>

        <!-- System Configuration Section -->
        <div class="section-header">
            <h3><i class="fa fa-cog"></i> System Configuration</h3>
        </div>

        <form id="systemForm">
            <div class="row">
                <div class="span6">
                    <label for="clinic_name">Clinic Name</label>
                    <input class="span6" type="text" id="clinic_name" name="clinic_name" />
                </div>
                <div class="span6">
                    <label for="clinic_timezone">Timezone</label>
                    <select class="span6" id="clinic_timezone" name="clinic_timezone">
                        <option value="America/Vancouver">Pacific Time (Vancouver)</option>
                        <option value="America/Edmonton">Mountain Time (Edmonton)</option>
                        <option value="America/Regina">Central Time (Regina)</option>
                        <option value="America/Winnipeg">Central Time (Winnipeg)</option>
                        <option value="America/Toronto">Eastern Time (Toronto)</option>
                        <option value="America/Halifax">Atlantic Time (Halifax)</option>
                        <option value="America/St_Johns">Newfoundland Time</option>
                    </select>
                </div>
            </div>

            <div class="row">
                <div class="span12">
                    <button type="submit" id="saveSystem" class="btn btn-primary">Save System Settings</button>
                </div>
            </div>
        </form>

        <div style="margin-top: 40px; margin-bottom: 20px;">
            <a href="admin.jsp" class="btn">Back to Admin</a>
        </div>
    </div>
</body>
</html>
