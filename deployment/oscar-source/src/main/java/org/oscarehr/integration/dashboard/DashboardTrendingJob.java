/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */
package org.oscarehr.integration.dashboard;

import java.util.Date;
import java.util.List;

import org.apache.logging.log4j.Logger;
import org.oscarehr.common.dao.IndicatorResultItemDao;
import org.oscarehr.common.jobs.OscarRunnable;
import org.oscarehr.common.model.IndicatorResultItem;
import org.oscarehr.common.model.IndicatorTemplate;
import org.oscarehr.common.model.Provider;
import org.oscarehr.common.model.Security;
import org.oscarehr.dashboard.display.beans.IndicatorBean;
import org.oscarehr.managers.DashboardManager;
import org.oscarehr.managers.ProviderManager2;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

public class DashboardTrendingJob implements OscarRunnable {

	private Logger logger = MiscUtils.getLogger();

	private Provider provider;
	private Security security;

	private DashboardManager dashboardManager = SpringUtils.getBean(DashboardManager.class);
	private ProviderManager2 providerManager = SpringUtils.getBean(ProviderManager2.class);
	private IndicatorResultItemDao indicatorResultItemDao = SpringUtils.getBean(IndicatorResultItemDao.class);
	
	@Override
	public void run() {
		LoggedInInfo x = new LoggedInInfo();
		x.setLoggedInProvider(provider);
		x.setLoggedInSecurity(security);

		logger.info("DashboardTrendingJob started and running as " + x.getLoggedInProvider().getFormattedName());

		List<Provider> providers = providerManager.getProviders(x, true);
		
		List<IndicatorTemplate> sharedIndicatorTemplates = dashboardManager.getIndicatorLibrary(x);

		for (IndicatorTemplate indicatorTemplate : sharedIndicatorTemplates) {


			for (Provider provider : providers) {
			//	IndicatorTemplateHandler ith = new IndicatorTemplateHandler(x, indicatorTemplate.getTemplate().getBytes());
				//run indicator
				Date d = new Date();
				IndicatorBean indicatorBean = dashboardManager.getIndicatorPanelForProvider(x, provider.getProviderNo(), indicatorTemplate.getId());
				
				//save it to DB
				
				JSONObject plots = JSONObject.fromObject(indicatorBean.getOriginalJsonPlots());

				JSONArray arr = plots.getJSONArray("results");

				for (int i = 0; i < arr.size(); i++) {
					JSONObject obj = (JSONObject) arr.get(i);
					String name = (String) obj.names().get(0);
					int value = obj.getInt(name);


					IndicatorResultItem item = new IndicatorResultItem();
					item.setLabel(name);
					item.setResult(value);
					
					item.setIndicatorTemplateId(indicatorTemplate.getId());
					item.setProviderNo(provider.getId());
					item.setTimeGenerated(d);
					
					
					indicatorResultItemDao.persist(item);
	
				}
				
			}
		}		

	}

	@Override
	public void setLoggedInProvider(Provider provider) {
		this.provider = provider;

	}

	@Override
	public void setLoggedInSecurity(Security security) {
		this.security = security;
	}
	
	@Override
	public void setConfig(String string) {
	}

}
