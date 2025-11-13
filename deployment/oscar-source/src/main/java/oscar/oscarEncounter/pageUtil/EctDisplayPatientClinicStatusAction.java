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

package oscar.oscarEncounter.pageUtil;

import org.apache.struts.util.MessageResources;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;
import javax.servlet.http.HttpServletRequest;

public class EctDisplayPatientClinicStatusAction extends EctDisplayAction {
    private static final String cmd = "patientClinicStatus";

    public boolean getInfo(EctSessionBean bean, HttpServletRequest request, NavBarDisplayDAO Dao, MessageResources messages) {
        LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
        String widget = request.getParameter("widget");

        DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
        Demographic demographic = demographicDao.getDemographic(bean.demographicNo);
        String displayName = "";
        switch (widget) {
            case "fDoc":
                displayName = demographic.getFamilyDoctorFullName();//demographic.getFamilyPhysicianFullName();
                break;
            case "rDoc":
                displayName = demographic.getFamilyDoctorFullName();
                break;
            default:
                // invalid value, do not display link
                return false;
        }
        
        String heading = messages.getMessage(request.getLocale(), "oscarEncounter.LeftNavBar." + widget);
        
        String winName = "patientClinicStatus" + bean.demographicNo;
        String url = "popupPage(700,1024,'" + winName + "', '" + request.getContextPath() + "/demographic/demographiccontrol.jsp?demographic_no=" + bean.demographicNo + "&displaymode=edit&dboperation=search_detail');return false;";
        Dao.setLeftHeading(heading);
        Dao.setLeftURL(url);
        
        NavBarDisplayDAO.Item item = NavBarDisplayDAO.Item();
        item.setLinkTitle(displayName);
        displayName = oscar.util.StringUtils.maxLenString(displayName, MAX_LEN_TITLE, CROP_LEN_TITLE, ELLIPSES);
        item.setTitle(displayName);
        item.setURL(url);
        Dao.addItem(item);

        //set righthand link to same as left so we have visual consistency with other modules
        Dao.setRightURL(url);
        Dao.setRightHeadingID(cmd);  //no menu so set div id to unique id for this action
        
        return true; 
    }

    public String getCmd() {
        return cmd;
    }
}
