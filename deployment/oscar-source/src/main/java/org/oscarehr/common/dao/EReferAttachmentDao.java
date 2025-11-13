/**
 * Copyright (c) 2014-2015. KAI Innovations Inc. All Rights Reserved.
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

import org.hibernate.Hibernate;
import org.oscarehr.common.model.EReferAttachment;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.Calendar;
import java.util.List;

@Repository
public class EReferAttachmentDao extends AbstractDao<EReferAttachment> {
	public EReferAttachmentDao() {
		super(EReferAttachment.class);
	}
	
	public EReferAttachment getRecentByDemographic(Integer demographicNo) {
		EReferAttachment eReferAttachment = null;
		
		Calendar calendar = Calendar.getInstance();
		calendar.add(Calendar.HOUR_OF_DAY, -1);
		
		String sql = "SELECT e FROM " + modelClass.getSimpleName() + " e WHERE e.archived = FALSE AND e.demographicNo = :demographicNo AND e.created > :expiry";
		Query query = entityManager.createQuery(sql);
		query.setParameter("demographicNo", demographicNo);
		query.setParameter("expiry", calendar.getTime());
		
		List<EReferAttachment> eReferAttachments = query.getResultList();
		
		if (!eReferAttachments.isEmpty()) {
			eReferAttachment = eReferAttachments.get(0);
			Hibernate.initialize(eReferAttachment.getAttachments());
		}
		
		return eReferAttachment;
	}
}
