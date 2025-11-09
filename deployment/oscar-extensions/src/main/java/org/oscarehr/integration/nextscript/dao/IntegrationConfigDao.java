/**
 * Copyright (c) 2024 NextScript Medical Systems. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 */
package org.oscarehr.integration.nextscript.dao;

import org.oscarehr.common.dao.AbstractDao;
import org.oscarehr.integration.nextscript.model.IntegrationConfig;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class IntegrationConfigDao extends AbstractDao<IntegrationConfig> {

    public IntegrationConfigDao() {
        super(IntegrationConfig.class);
    }

    /**
     * Get all configuration for a specific integration
     */
    public Map<String, String> getIntegrationConfig(String integrationName) {
        String sql = "SELECT c FROM IntegrationConfig c WHERE c.integrationName = :integrationName";
        Query query = entityManager.createQuery(sql);
        query.setParameter("integrationName", integrationName);

        @SuppressWarnings("unchecked")
        List<IntegrationConfig> results = query.getResultList();

        Map<String, String> config = new HashMap<>();
        for (IntegrationConfig ic : results) {
            config.put(ic.getConfigKey(), ic.getConfigValue());
        }
        return config;
    }

    /**
     * Save or update a configuration value
     */
    public void saveConfig(String integrationName, String configKey, String configValue, boolean encrypted, boolean enabled) {
        String sql = "SELECT c FROM IntegrationConfig c WHERE c.integrationName = :integrationName AND c.configKey = :configKey";
        Query query = entityManager.createQuery(sql);
        query.setParameter("integrationName", integrationName);
        query.setParameter("configKey", configKey);

        @SuppressWarnings("unchecked")
        List<IntegrationConfig> results = query.getResultList();

        IntegrationConfig config;
        if (results.isEmpty()) {
            config = new IntegrationConfig();
            config.setIntegrationName(integrationName);
            config.setConfigKey(configKey);
        } else {
            config = results.get(0);
        }

        config.setConfigValue(configValue);
        config.setEncrypted(encrypted);
        config.setEnabled(enabled);

        merge(config);
    }

    /**
     * Check if an integration is enabled
     */
    public boolean isIntegrationEnabled(String integrationName) {
        String sql = "SELECT c FROM IntegrationConfig c WHERE c.integrationName = :integrationName AND c.configKey = 'enabled'";
        Query query = entityManager.createQuery(sql);
        query.setParameter("integrationName", integrationName);

        @SuppressWarnings("unchecked")
        List<IntegrationConfig> results = query.getResultList();

        if (!results.isEmpty()) {
            return "true".equals(results.get(0).getConfigValue());
        }
        return false;
    }

    /**
     * Delete all config for an integration
     */
    public void deleteIntegrationConfig(String integrationName) {
        String sql = "DELETE FROM IntegrationConfig c WHERE c.integrationName = :integrationName";
        Query query = entityManager.createQuery(sql);
        query.setParameter("integrationName", integrationName);
        query.executeUpdate();
    }
}
