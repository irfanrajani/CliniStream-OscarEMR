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

package oscar.form;

import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.Enumeration;
import java.util.List;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.JsonObject;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

import oscar.form.util.JasperReportPdfPrint;
import oscar.log.LogAction;
import oscar.log.LogConst;

public final class FrmAction extends Action {
    
	Logger log = org.oscarehr.util.MiscUtils.getLogger();
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {
    	
    	if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_form", "w", null)) {
			throw new SecurityException("missing required security object (_form)");
		}
    	
    	
    	LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        int newID = 0;
        FrmRecord rec = null;
        String where = "";                

        try {
            FrmRecordFactory recorder = new FrmRecordFactory();
            rec = recorder.factory(request.getParameter("form_class"));
            Properties props = new Properties();
               
            log.info("SUBMIT " + String.valueOf(request.getParameter("submit") == null));
            //if we are graphing, we need to grab info from db and add it to request object
            if( request.getParameter("submit").equals("graph") )
            {
            	//Rourke needs to know what type of graph is being plotted
            	String graphType = request.getParameter("__graphType");
            	if( graphType != null ) {
            		rec.setGraphType(graphType);
            	}
            	
               props = rec.getGraph(Integer.parseInt(request.getParameter("demographic_no")), 
                       Integer.parseInt(request.getParameter("formId")));
               
               for( Enumeration e = props.propertyNames(); e.hasMoreElements(); ) {
                   String name = (String)e.nextElement();                   
                   request.setAttribute(name,props.getProperty(name));                   
               }
            }
            //if we are printing all pages of form, grab info from db and merge with current page info
            else if( request.getParameter("submit").equals("printAll") || request.getParameter("submit").equals("printAllJasperReport")) {
                Integer demographicNo = Integer.parseInt(request.getParameter("demographic_no"));
                Integer formId = Integer.parseInt(request.getParameter("formId"));
                if (rec instanceof JasperReportPdfPrint) {
                    
                    List<Integer> pagesToPrint = new ArrayList<Integer>();
                    List<String> cfgPages = Arrays.asList(request.getParameterValues("__cfgfile"));
                    for (int i = 1; i <= 4; i++) {
                        if (cfgPages.contains("rourke2017printCfgPg" + i)) {
                            pagesToPrint.add(i);
                        }
                    }

                    response.setContentType("application/pdf");
                    response.setHeader("Content-Disposition", "attachment; filename=\"Rourke2017_" + formId + ".pdf\"");
                    ((JasperReportPdfPrint) rec).PrintJasperPdf(response.getOutputStream(), loggedInInfo, demographicNo, formId, pagesToPrint);
                    return null;
                } else {
                    props = rec.getFormRecord(loggedInInfo, Integer.parseInt(request.getParameter("demographic_no")), Integer.parseInt(request.getParameter("formId")));

                    String name;
                    for (Enumeration e = props.propertyNames(); e.hasMoreElements(); ) {
                        name = (String) e.nextElement();
                        if (request.getParameter(name) == null) {
                            request.setAttribute(name, props.getProperty(name));
                        }
                    }
                }
            } else if( request.getParameter("update")!=null && request.getParameter("update").equals("true") ) {
                boolean bMulPage = request.getParameter("c_lastVisited") != null ? true : false;
                String name;

                if (bMulPage) {
                    String curPageNum = request.getParameter("c_lastVisited");
                    String commonField = request.getParameter("commonField") != null ? request
                            .getParameter("commonField") : "&'";
                    curPageNum = curPageNum.length() > 3 ? ("" + curPageNum.charAt(0)) : curPageNum;
                    Properties currentParam = new Properties();
                    for (Enumeration varEnum = request.getParameterNames(); varEnum.hasMoreElements();) {
                        name = (String) varEnum.nextElement();
                        currentParam.setProperty(name, "");
                    }
                    for (Enumeration varEnum = props.propertyNames(); varEnum.hasMoreElements();) {
                        name = (String) varEnum.nextElement();
                        // kick off the current page elements, commonField on the current page
                        if (name.startsWith(curPageNum + "_") || (name.startsWith(commonField) && currentParam.containsKey(name))) {
                            props.remove(name);
                        }
                    }
                    props = currentParam;

                }
                //update the current record
                for (Enumeration varEnum = request.getParameterNames(); varEnum.hasMoreElements();) {
                    name = (String) varEnum.nextElement();
                    props.setProperty(name, request.getParameter(name));
                }

                props.setProperty("provider_no", (String) request.getSession().getAttribute("user"));
                newID = rec.saveFormRecord(props);
                String ip = request.getRemoteAddr();
                LogAction.addLog((String) request.getSession().getAttribute("user"), LogConst.UPDATE, request
                        .getParameter("form_class"), "" + newID, ip,request.getParameter("demographic_no"));
            } else if (request.getParameter("submit").equals("autosaveAjax")) {
                quickSaveForm(rec, request, response);
                return null;
            } else {
                boolean bMulPage = request.getParameter("c_lastVisited") != null ? true : false;
                String name;

                if (bMulPage) {
                    String curPageNum = request.getParameter("c_lastVisited");
                    String commonField = request.getParameter("commonField") != null ? request
                            .getParameter("commonField") : "&'";
                    curPageNum = curPageNum.length() > 3 ? ("" + curPageNum.charAt(0)) : curPageNum;

                    //copy an old record
                    props = rec.getFormRecord(loggedInInfo, Integer.parseInt(request.getParameter("demographic_no")), Integer
                            .parseInt(request.getParameter("formId")));

                    //empty the current page
                    Properties currentParam = new Properties();
                    for (Enumeration varEnum = request.getParameterNames(); varEnum.hasMoreElements();) {
                        name = (String) varEnum.nextElement();
                        currentParam.setProperty(name, "");
                    }
                    for (Enumeration varEnum = props.propertyNames(); varEnum.hasMoreElements();) {
                        name = (String) varEnum.nextElement();
                        // kick off the current page elements, commonField on the current page
                        if (name.startsWith(curPageNum + "_")
                                || (name.startsWith(commonField) && currentParam.containsKey(name))) {
                            props.remove(name);
                        }
                    }
                }

                //update the current record
                for (Enumeration varEnum = request.getParameterNames(); varEnum.hasMoreElements();) {
                    name = (String) varEnum.nextElement();                    
                    props.setProperty(name, request.getParameter(name));                    
                }

                props.setProperty("provider_no", (String) request.getSession().getAttribute("user"));
                newID = rec.saveFormRecord(props);
                String ip = request.getRemoteAddr();
                LogAction.addLog((String) request.getSession().getAttribute("user"), LogConst.ADD, request
                        .getParameter("form_class"), "" + newID, ip,request.getParameter("demographic_no"));

            }
            String strAction = rec.findActionValue(request.getParameter("submit"));
            ActionForward af = mapping.findForward(strAction);
            where = af.getPath();
            where = rec.createActionURL(where, strAction, request.getParameter("demographic_no"), "" + newID);

        } catch (Exception ex) {
            throw new ServletException(ex);
        }

        return new ActionForward(where); 
    }
    
    private void quickSaveForm(FrmRecord formRecord, HttpServletRequest request, HttpServletResponse response) {
        Properties props = new Properties();
        for (Enumeration<String> varEnum = request.getParameterNames(); varEnum.hasMoreElements();) {
            String name = varEnum.nextElement();
            props.setProperty(name, request.getParameter(name));
        }
        props.setProperty("provider_no", (String) request.getSession().getAttribute("user"));
        try {
            try {
                int newFormId = formRecord.saveFormRecord(props);
                LogAction.addLog((String) request.getSession().getAttribute("user"),
                        LogConst.ADD, request.getParameter("form_class"), String.valueOf(newFormId),
                        request.getRemoteAddr(), request.getParameter("demographic_no"));

                
                String newUrl = "?formname="+ props.getProperty("form_class") +
                        "&demographic_no=" + props.getProperty("demographic_no") + 
                        (StringUtils.isNotEmpty(props.getProperty("remoteFacilityId")) ? "&remoteFacilityId=" + props.getProperty("remoteFacilityId") : "") +
                        (StringUtils.isNotEmpty(props.getProperty("appointmentNo")) ? "&appointmentNo=" + props.getProperty("appointmentNo") : "") + 
                        "&formId=" + newFormId;

                response.setContentType("application/json");
                JsonObject json = new JsonObject();
                json.addProperty("success", true);
                json.addProperty("newFormId", newFormId);
                json.addProperty("newNewUrl", newUrl);
                json.addProperty("formAutosaveDate", new SimpleDateFormat("h:mm a").format(new Date()));
                response.getWriter().write(json.toString());

            } catch (SQLException e) {
                log.error("Failed to autosave form: " + request.getParameter("form_class"), e);
                response.setContentType("application/json");
                JsonObject json = new JsonObject();
                json.addProperty("success", false);
                response.getWriter().write(json.toString());
            }
        } catch (IOException e) { /* do nothing */ }
    }
}
