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
package org.oscarehr.common.dao;

import java.util.List;

import javax.persistence.Query;

import org.oscarehr.common.model.IndicatorResultItem;
import org.springframework.stereotype.Repository;

@Repository
public class IndicatorResultItemDao  extends AbstractDao<IndicatorResultItem> {

	public IndicatorResultItemDao() {
		super(IndicatorResultItem.class);
	}
	 
	 public List<String> findLabels(Integer indicatorTemplateId) {
		 Query query = entityManager.createQuery("SELECT DISTINCT d.label FROM IndicatorResultItem d WHERE d.indicatorTemplateId = :indicatorTemplateId");
		 query.setParameter("indicatorTemplateId", indicatorTemplateId);
			
		 return query.getResultList();
	 }
	 
	 public List<IndicatorResultItem> findItemsByProviderNoAndLabelAndIndicatorTemplateId(String providerNo, String label, Integer indicatorTemplateId) {
		 Query query = entityManager.createQuery("FROM IndicatorResultItem d WHERE d.indicatorTemplateId = :indicatorTemplateId AND d.label = :label AND d.providerNo = :providerNo ORDER BY d.timeGenerated");
		 query.setParameter("indicatorTemplateId", indicatorTemplateId);
		 query.setParameter("label", label);
		 query.setParameter("providerNo", providerNo);
				
		 return query.getResultList();
	 }

}
