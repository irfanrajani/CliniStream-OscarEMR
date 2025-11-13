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

import org.oscarehr.common.model.UAO;
import org.springframework.stereotype.Repository;

@Repository
public class UAODao extends AbstractDao<UAO> {

	public UAODao() {
		super(UAO.class);
	}
	
	
	
	public List<UAO> findByProvider(String provider) {
		
		Query q = entityManager.createQuery("select s from UAO s where s.providerNo = :providerNo and s.active = true order by s.defaultUAO desc");
		q.setParameter("providerNo", provider);
		
		@SuppressWarnings("unchecked")
		List<UAO> results = q.getResultList();
		return results;
	}
	
	public void setAsDefault(UAO uao,String provider) {
		List<UAO> list = findByProvider(provider);
		
		for(UAO u:list) {
			if(u.getId().equals(uao.getId()) && !u.getDefaultUAO()) { 
				u.setDefaultUAO(true);
				merge(u);
			}else {
				if(u.getDefaultUAO()) {
					u.setDefaultUAO(false);
					merge(u);
				}
			}
		}
		
		
	}
	
	
}
