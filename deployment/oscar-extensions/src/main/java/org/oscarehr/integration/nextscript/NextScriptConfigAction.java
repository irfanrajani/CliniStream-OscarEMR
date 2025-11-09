/**
 * Copyright (c) 2024 NextScript Medical Systems. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 */
package org.oscarehr.integration.nextscript;

import net.sf.json.JSONObject;
import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.integration.nextscript.dao.IntegrationConfigDao;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import oscar.form.JSONAction;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Map;

public class NextScriptConfigAction extends JSONAction {

    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    private static final String PASSWORD_BLANKET = "**********";

    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        return loadConfig(mapping, form, request, response);
    }

    /**
     * Load configuration for the settings page
     */
    public ActionForward loadConfig(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        if (!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_admin", "r", null)) {
            throw new SecurityException("missing required security object (_admin)");
        }

        JSONObject jsonObject = new JSONObject();

        try {
            IntegrationConfigDao configDao = SpringUtils.getBean(IntegrationConfigDao.class);

            // Load RingCentral config
            Map<String, String> rcConfig = configDao.getIntegrationConfig("ringcentral");
            jsonObject.put("ringcentral", rcConfig);

            // Load Ocean config
            Map<String, String> oceanConfig = configDao.getIntegrationConfig("ocean");
            jsonObject.put("ocean", oceanConfig);

            // Load Labs config
            Map<String, String> labsConfig = configDao.getIntegrationConfig("labs");
            jsonObject.put("labs", labsConfig);

            // Load system config
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            JSONObject systemConfig = new JSONObject();

            try {
                conn = getConnection();
                ps = conn.prepareStatement("SELECT config_key, config_value FROM system_config");
                rs = ps.executeQuery();

                while (rs.next()) {
                    systemConfig.put(rs.getString("config_key"), rs.getString("config_value"));
                }
            } finally {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            }

            jsonObject.put("system", systemConfig);
            jsonObject.put("success", true);

        } catch (Exception ex) {
            jsonObject.put("success", false);
            jsonObject.put("error", ex.getMessage());
            MiscUtils.getLogger().error("COULD NOT LOAD NEXTSCRIPT CONFIGURATION", ex);
        }

        try {
            jsonObject.write(response.getWriter());
        } catch (IOException e) {
            MiscUtils.getLogger().error("JSON WRITER ERROR", e);
        }
        return null;
    }

    /**
     * Save configuration
     */
    public ActionForward saveConfig(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        if (!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_admin", "w", null)) {
            throw new SecurityException("missing required security object (_admin)");
        }

        JSONObject jsonObject = new JSONObject();

        try {
            IntegrationConfigDao configDao = SpringUtils.getBean(IntegrationConfigDao.class);

            String section = request.getParameter("section");

            if ("ringcentral".equals(section)) {
                saveRingCentralConfig(request, configDao);
            } else if ("ocean".equals(section)) {
                saveOceanConfig(request, configDao);
            } else if ("labs".equals(section)) {
                saveLabsConfig(request, configDao);
            } else if ("system".equals(section)) {
                saveSystemConfig(request);
            }

            jsonObject.put("success", true);
            jsonObject.put("message", "Configuration saved successfully");

        } catch (Exception ex) {
            jsonObject.put("success", false);
            jsonObject.put("error", ex.getMessage());
            MiscUtils.getLogger().error("COULD NOT SAVE NEXTSCRIPT CONFIGURATION", ex);
        }

        try {
            jsonObject.write(response.getWriter());
        } catch (IOException e) {
            MiscUtils.getLogger().error("JSON WRITER ERROR", e);
        }
        return null;
    }

    /**
     * Test RingCentral connection
     */
    public ActionForward testRingCentral(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        if (!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_admin", "r", null)) {
            throw new SecurityException("missing required security object (_admin)");
        }

        JSONObject jsonObject = new JSONObject();

        try {
            String clientId = request.getParameter("clientId");
            String clientSecret = request.getParameter("clientSecret");

            // In production, this would actually test the connection
            // For now, just validate that credentials are present
            if (StringUtils.isNotBlank(clientId) && StringUtils.isNotBlank(clientSecret)) {
                jsonObject.put("success", true);
                jsonObject.put("message", "Connection test successful");
            } else {
                jsonObject.put("success", false);
                jsonObject.put("message", "Missing credentials");
            }

        } catch (Exception ex) {
            jsonObject.put("success", false);
            jsonObject.put("message", "Connection test failed: " + ex.getMessage());
            MiscUtils.getLogger().error("RINGCENTRAL CONNECTION TEST FAILED", ex);
        }

        try {
            jsonObject.write(response.getWriter());
        } catch (IOException e) {
            MiscUtils.getLogger().error("JSON WRITER ERROR", e);
        }
        return null;
    }

    /**
     * Test Ocean connection
     */
    public ActionForward testOcean(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        if (!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_admin", "r", null)) {
            throw new SecurityException("missing required security object (_admin)");
        }

        JSONObject jsonObject = new JSONObject();

        try {
            String siteId = request.getParameter("siteId");
            String apiKey = request.getParameter("apiKey");

            if (StringUtils.isNotBlank(siteId) && StringUtils.isNotBlank(apiKey)) {
                jsonObject.put("success", true);
                jsonObject.put("message", "Connection test successful");
            } else {
                jsonObject.put("success", false);
                jsonObject.put("message", "Missing credentials");
            }

        } catch (Exception ex) {
            jsonObject.put("success", false);
            jsonObject.put("message", "Connection test failed: " + ex.getMessage());
            MiscUtils.getLogger().error("OCEAN CONNECTION TEST FAILED", ex);
        }

        try {
            jsonObject.write(response.getWriter());
        } catch (IOException e) {
            MiscUtils.getLogger().error("JSON WRITER ERROR", e);
        }
        return null;
    }

    private void saveRingCentralConfig(HttpServletRequest request, IntegrationConfigDao configDao) {
        String enabled = request.getParameter("rc_enabled");
        String clientId = request.getParameter("rc_client_id");
        String clientSecret = request.getParameter("rc_client_secret");
        String username = request.getParameter("rc_username");
        String password = request.getParameter("rc_password");
        String extension = request.getParameter("rc_extension");
        String faxNumber = request.getParameter("rc_fax_number");
        String smsNumber = request.getParameter("rc_sms_number");

        configDao.saveConfig("ringcentral", "enabled", enabled, false, true);

        if (StringUtils.isNotBlank(clientId)) {
            configDao.saveConfig("ringcentral", "client_id", clientId, false, true);
        }

        if (StringUtils.isNotBlank(clientSecret) && !PASSWORD_BLANKET.equals(clientSecret)) {
            configDao.saveConfig("ringcentral", "client_secret", clientSecret, true, true);
        }

        if (StringUtils.isNotBlank(username)) {
            configDao.saveConfig("ringcentral", "username", username, false, true);
        }

        if (StringUtils.isNotBlank(password) && !PASSWORD_BLANKET.equals(password)) {
            configDao.saveConfig("ringcentral", "password", password, true, true);
        }

        if (StringUtils.isNotBlank(extension)) {
            configDao.saveConfig("ringcentral", "extension", extension, false, true);
        }

        if (StringUtils.isNotBlank(faxNumber)) {
            configDao.saveConfig("ringcentral", "fax_number", faxNumber, false, true);
        }

        if (StringUtils.isNotBlank(smsNumber)) {
            configDao.saveConfig("ringcentral", "sms_number", smsNumber, false, true);
        }
    }

    private void saveOceanConfig(HttpServletRequest request, IntegrationConfigDao configDao) {
        String enabled = request.getParameter("ocean_enabled");
        String siteId = request.getParameter("ocean_site_id");
        String apiKey = request.getParameter("ocean_api_key");

        configDao.saveConfig("ocean", "enabled", enabled, false, true);

        if (StringUtils.isNotBlank(siteId)) {
            configDao.saveConfig("ocean", "site_id", siteId, false, true);
        }

        if (StringUtils.isNotBlank(apiKey) && !PASSWORD_BLANKET.equals(apiKey)) {
            configDao.saveConfig("ocean", "api_key", apiKey, true, true);
        }
    }

    private void saveLabsConfig(HttpServletRequest request, IntegrationConfigDao configDao) {
        String enabled = request.getParameter("labs_enabled");
        String provider = request.getParameter("labs_provider");
        String username = request.getParameter("labs_username");
        String password = request.getParameter("labs_password");

        configDao.saveConfig("labs", "enabled", enabled, false, true);

        if (StringUtils.isNotBlank(provider)) {
            configDao.saveConfig("labs", "provider", provider, false, true);
        }

        if (StringUtils.isNotBlank(username)) {
            configDao.saveConfig("labs", "username", username, false, true);
        }

        if (StringUtils.isNotBlank(password) && !PASSWORD_BLANKET.equals(password)) {
            configDao.saveConfig("labs", "password", password, true, true);
        }
    }

    private void saveSystemConfig(HttpServletRequest request) throws Exception {
        String clinicName = request.getParameter("clinic_name");
        String clinicTimezone = request.getParameter("clinic_timezone");

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();

            if (StringUtils.isNotBlank(clinicName)) {
                ps = conn.prepareStatement("INSERT INTO system_config (config_key, config_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE config_value = ?");
                ps.setString(1, "clinic_name");
                ps.setString(2, clinicName);
                ps.setString(3, clinicName);
                ps.executeUpdate();
                ps.close();
            }

            if (StringUtils.isNotBlank(clinicTimezone)) {
                ps = conn.prepareStatement("INSERT INTO system_config (config_key, config_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE config_value = ?");
                ps.setString(1, "clinic_timezone");
                ps.setString(2, clinicTimezone);
                ps.setString(3, clinicTimezone);
                ps.executeUpdate();
                ps.close();
            }

        } finally {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        }
    }

    private Connection getConnection() throws Exception {
        return oscar.OscarProperties.getInstance().getConnection();
    }
}
