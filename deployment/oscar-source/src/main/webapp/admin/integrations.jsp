<%--
    NextScript OSCAR EMR Integration Management
    Copyright (c) 2025 NextScript. All Rights Reserved.

    This page provides UI to configure RingCentral, OceanMD, and Lab integrations
    Connects to NextScript integration microservice (port 8080)
--%>

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String)session.getAttribute("user");
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
    <title>NextScript Integrations - OSCAR EMR</title>
    <link rel="stylesheet" type="text/css" href="../share/css/OscarStandardLayout.css" />
    <script type="text/javascript" src="../share/javascript/Oscar.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath()%>/library/jquery/jquery-3.6.4.min.js"></script>
    <style>
        .integration-box {
            margin: 20px;
            padding: 15px;
            border: 1px solid #ccc;
            background-color: #f9f9f9;
        }
        .integration-box h3 {
            margin-top: 0;
            color: #18A689;
        }
        .status-active {
            color: green;
            font-weight: bold;
        }
        .status-inactive {
            color: red;
        }
        .config-btn {
            background-color: #18A689;
            color: white;
            padding: 8px 15px;
            border: none;
            cursor: pointer;
            border-radius: 4px;
        }
        .config-btn:hover {
            background-color: #15967d;
        }
    </style>
</head>
<body>
    <h2>NextScript Integration Management</h2>

    <div class="integration-box">
        <h3>RingCentral (Fax & SMS)</h3>
        <p><strong>Status:</strong> <span id="rc-status" class="status-inactive">Not Configured</span></p>
        <p>Send faxes and SMS messages directly from patient charts using RingCentral.</p>
        <button class="config-btn" onclick="openSetupWizard('ringcentral')">Configure RingCentral</button>
        <button class="config-btn" onclick="testIntegration('ringcentral')">Test Connection</button>
    </div>

    <div class="integration-box">
        <h3>OceanMD (eReferrals)</h3>
        <p><strong>Status:</strong> <span id="ocean-status" class="status-inactive">Not Configured</span></p>
        <p>Create and manage electronic referrals through Ocean eReferral platform.</p>
        <button class="config-btn" onclick="openSetupWizard('ocean')">Configure Ocean</button>
        <button class="config-btn" onclick="testIntegration('ocean')">Test Connection</button>
    </div>

    <div class="integration-box">
        <h3>BC Laboratory Auto-Download</h3>
        <p><strong>Status:</strong> <span id="lab-status" class="status-inactive">Not Configured</span></p>
        <p>Automatically download and import lab results from Excelleris/LifeLabs.</p>
        <button class="config-btn" onclick="openSetupWizard('labs')">Configure Labs</button>
        <button class="config-btn" onclick="testIntegration('labs')">Test Connection</button>
    </div>

    <div class="integration-box">
        <h3>Integration Service Status</h3>
        <p><strong>API Status:</strong> <span id="api-status" class="status-inactive">Checking...</span></p>
        <p><strong>Service URL:</strong> <code>http://integrations:8080</code></p>
        <button class="config-btn" onclick="checkServiceHealth()">Check Service Health</button>
    </div>

    <script>
        // Open setup wizard for specific integration
        function openSetupWizard(section) {
            var wizardUrl = 'http://' + window.location.hostname + ':8568/#/' + section;
            window.open(wizardUrl, 'SetupWizard', 'width=1000,height=800,scrollbars=yes');
        }

        // Test integration connection
        function testIntegration(type) {
            alert('Testing ' + type + ' connection...\nThis will verify credentials with the external service.');
            // In production, this would make AJAX call to integration service
            jQuery.ajax({
                url: 'http://' + window.location.hostname + ':8080/api/test/' + type,
                method: 'POST',
                success: function(data) {
                    if(data.success) {
                        alert('✅ ' + type + ' connection successful!');
                    } else {
                        alert('❌ ' + type + ' connection failed: ' + data.error);
                    }
                },
                error: function() {
                    alert('❌ Unable to reach integration service');
                }
            });
        }

        // Check integration service health
        function checkServiceHealth() {
            jQuery.ajax({
                url: 'http://' + window.location.hostname + ':8080/health',
                method: 'GET',
                success: function(data) {
                    document.getElementById('api-status').className = 'status-active';
                    document.getElementById('api-status').textContent = 'Online';

                    // Check individual service status
                    if(data.services && data.services.ringcentral) {
                        document.getElementById('rc-status').className = 'status-active';
                        document.getElementById('rc-status').textContent = 'Active';
                    }
                    if(data.services && data.services.ocean) {
                        document.getElementById('ocean-status').className = 'status-active';
                        document.getElementById('ocean-status').textContent = 'Active';
                    }
                    if(data.services && data.services.expedius) {
                        document.getElementById('lab-status').className = 'status-active';
                        document.getElementById('lab-status').textContent = 'Active';
                    }

                    alert('✅ Integration service is online!');
                },
                error: function() {
                    document.getElementById('api-status').className = 'status-inactive';
                    document.getElementById('api-status').textContent = 'Offline';
                    alert('❌ Integration service is offline\n\nPlease ensure the integrations container is running:\ndocker-compose ps integrations');
                }
            });
        }

        // Check health on page load
        jQuery(document).ready(function() {
            checkServiceHealth();
        });
    </script>
</body>
</html>
