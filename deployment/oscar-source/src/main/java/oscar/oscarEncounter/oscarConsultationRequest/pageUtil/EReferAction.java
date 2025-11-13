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
package oscar.oscarEncounter.oscarConsultationRequest.pageUtil;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.common.dao.EReferAttachmentDao;
import org.oscarehr.common.model.EReferAttachment;
import org.oscarehr.common.model.EReferAttachmentData;
import org.oscarehr.util.SpringUtils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.oscarehr.util.MiscUtils;
import org.apache.logging.log4j.Logger;

public class EReferAction extends Action {
	private static Logger log = MiscUtils.getLogger();
	public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
		Integer demographicNo = Integer.parseInt(request.getParameter("demographicNo"));
		String documents = StringUtils.trimToEmpty(request.getParameter("documents"));

		if (!documents.isEmpty()) {
			EReferAttachment eReferAttachment = new EReferAttachment(demographicNo);
			List<EReferAttachmentData> attachments = new ArrayList<>();
			String[] splitDocuments = documents.split("\\|");
			
			for (String document : splitDocuments) {
				String type = document.replaceAll("\\d", "");
				Integer id = Integer.parseInt(document.substring(type.length()));
				EReferAttachmentData attachmentData = new EReferAttachmentData(eReferAttachment, id, type);
				attachments.add(attachmentData);
			}

			eReferAttachment.setAttachments(attachments);

			EReferAttachmentDao eReferAttachmentDao = SpringUtils.getBean(EReferAttachmentDao.class);
			eReferAttachmentDao.persist(eReferAttachment);
			
			try {
				response.getWriter().write(eReferAttachment.getId().toString());
			} catch (IOException e) {
				//e.print Stack Trace();
				log.error("IO error",e);
			}
		}
		
		return null;
	}
}
