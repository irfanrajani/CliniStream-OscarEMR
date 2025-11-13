<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.List, org.apache.commons.lang.StringUtils" %>
<%@ page import="org.oscarehr.common.web.ContactAction" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.Provider" %>
<%@ page import="org.oscarehr.PMmodule.dao.ProviderDao" %>
<%@ page import="org.oscarehr.common.model.DemographicContact" %>
<%@ page import="org.oscarehr.common.model.Demographic" %>
<%@ page import="org.oscarehr.common.dao.DemographicDao" %>
<%@ page import="org.oscarehr.common.dao.ContactSpecialtyDao" %>
<%@ page import="org.oscarehr.common.model.ContactSpecialty" %>
<%@ page import="org.oscarehr.common.dao.DemographicContactDao" %>
<%@ page import="org.oscarehr.common.model.Contact" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.GregorianCalendar" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>

<security:oscarSec roleName="${ sessionScope.userrole }" objectName="_demographic" rights="r" reverse="${ false }">

    <%


        DemographicContactDao demographicContactDao = SpringUtils.getBean(DemographicContactDao.class);
        List<DemographicContact> demographicContacts = null;
        DemographicDao demographicDao = null;
        Demographic demographic = null;
        ContactSpecialtyDao specialtyDao = null;
        List<ContactSpecialty> specialty = null;
        String demographicNoString = request.getParameter("demographicNo");

        String curProviderNo = (String) session.getAttribute("user");
        String userFirstName = (String) session.getAttribute("userfirstname");
        String userLastName = (String) session.getAttribute("userlastname");
        GregorianCalendar now=new GregorianCalendar();
        int curYear = now.get(Calendar.YEAR);
        int curMonth = (now.get(Calendar.MONTH)+1);
        int curDay = now.get(Calendar.DAY_OF_MONTH);

        if (!StringUtils.isBlank(demographicNoString)) {
            demographicDao = SpringUtils.getBean(DemographicDao.class);
            demographic = demographicDao.getClientByDemographicNo( Integer.parseInt(demographicNoString) );
            demographicContacts = demographicContactDao.findActiveByDemographicNo(demographic.getDemographicNo());
            demographicContacts = ContactAction.fillContactInfo(demographicContacts);
        }

        pageContext.setAttribute("demographic", demographic);
        pageContext.setAttribute("demographicContacts", demographicContacts);
        pageContext.setAttribute("specialty", specialty);
    %>

    <%-- DETACHED VIEW ENABLED  --%>
    <c:if test="${ param.view eq 'detached' }">

        <%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
        <%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>

        <!DOCTYPE html>
        <html>
        <head>

       <script src="${ pageContext.request.contextPath }/library/jquery/jquery-3.6.4.min.js"></script>

    </c:if>
    <%-- END DETACHED VIEW ENABLED  --%>

    <c:if test="${ param.view ne 'detached' }" >
        <script type="text/javascript">
            jQuery(document).ready( function($) {
                //--> Popup effects
                $(".contactHover").on( "mouseover", function(){
                    $('#contactDetail_' + this.id).slideUp( 300 ).delay( 400 ).fadeIn( 400 );
                    $(this).css("fontWeight", "bold");
                });
                $(".contactHover").on( "mouseout", function(){
                    $('#contactDetail_' + this.id).delay(400).fadeOut(400);
                    $(this).css("fontWeight", "inherit");
                });
            })
        </script>
    </c:if>

    <%-- DETACHED VIEW ENABLED  --%>
    <c:if test="${ param.view eq 'detached' }" >

        <script type="text/javascript">
            jQuery(document).ready( function($) {
                //--> Popup effects
                $(".contactHover").on( "mouseover", function(){
                    $('#contactDetail_' + this.id).show();
                    $(this).css("fontWeight", "bold");
                });
                $(".contactHover").on( "mouseout", function(){
                    $('#contactDetail_' + this.id).hide();
                    $(this).css("fontWeight", "inherit");
                });
            })
        </script>

        </head>

        <body id="${ param.view }View">
        <table class="MainTable" >
        <tr class="MainTableTopRow">
            <td class="MainTableTopRowLeftColumn" style="width:20%">Other Contacts</td>
            <td class="MainTableTopRowRightColumn">
                <table class="TopStatusBar">
                    <tr>
                        <td>&nbsp;</td>
                        <td>
                            <c:out value="${ demographic.lastName }" />,&nbsp;
                            <c:out value="${ demographic.firstName }" />&nbsp;
                            <c:out value="${ demographic.age }" />&nbsp;years
                        </td>
                        <td style="text-align: right">
                            <oscar:help keywords="contact" key="app.top1"/> |
                            <a href="javascript:popupStart(300,400,'About.jsp')">
                                <bean:message key="global.about" /></a> | <a
                                href="javascript:popupStart(300,400,'License.jsp')">
                            <bean:message key="global.license" /></a></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr><td colspan="2">

    </c:if>
    <%-- END DETACHED VIEW ENABLED  --%>


    <%-- HEALTH CARE TEAM MODULE --%>
    <div class="demographicSection" id="otherContacts2" style="overflow: hidden;">

            <%-- DETACHED VIEW ENABLED  --%>

        <h4>&nbsp;<bean:message key="demographic.demographiceditdemographic.msgOtherContacts"/>
<i class="icon-edit" style="float: right;" title="<bean:message key="demographic.demographiceditdemographic.msgEdit"/>" onClick="popup(700,960,'Contact.do?method=manage&demographic_no=<%=demographic.getDemographicNo()%>','ManageContacts')"></i></h4>
        </h4>

            <%-- END DETACHED VIEW ENABLED  --%>

        <table style="border-spacing: 0px;">

            <%
                for(DemographicContact dContact : demographicContacts) {
                    String notSet = "Not Set";
                    Contact details = dContact.getDetails() != null ? dContact.getDetails() : new Contact();

                    String ecSdm = "";
                    if("true".equals(dContact.getEc())) {
                        ecSdm += "EC";
                    }

                    if ("true".equals(dContact.getSdm())) {
                        ecSdm += ecSdm.length() > 0 ? "/SDM" : "SDM";
                    }

                    String responsibility = "Internal";
                    if (!ecSdm.trim().isEmpty()) {
                        responsibility = ecSdm;
                    } else if (dContact.getType() == DemographicContact.TYPE_CONTACT) {
                        responsibility = "External";
                    } else if (dContact.getType() == DemographicContact.TYPE_PROFESSIONALSPECIALIST) {
                        responsibility = "Pro Specialist";
                    }

                    String preferredContact = notSet;
                    if (dContact.isConsentToContact()) {
                        if (DemographicContact.CONTACT_CELL.equals(dContact.getBestContact()) && StringUtils.trimToNull(details.getCellPhone()) != null) {
                            preferredContact = details.getCellPhone() + " (cell)";
                        } else if (DemographicContact.CONTACT_EMAIL.equals(dContact.getBestContact()) && StringUtils.trimToNull(details.getEmail()) != null) {
                            preferredContact = details.getEmail();
                        } else if (DemographicContact.CONTACT_PHONE.equals(dContact.getBestContact()) && StringUtils.trimToNull(details.getResidencePhone()) != null) {
                            preferredContact = details.getResidencePhone()  + " (main)";;
                        } else if (DemographicContact.CONTACT_WORK.equals(dContact.getBestContact()) && StringUtils.trimToNull(details.getWorkPhone()) != null) {
                            preferredContact = details.getWorkPhone()  + "  ext: "+ details.getWorkPhoneExtension() + " (work)";;
                        }
                    } else {
                        preferredContact = "<span class=\"text-danger\" style=\"font-weight: bold\">No Consent</span>";
                    }
            %>

            <tr >
                <td ><%=Encode.forHtmlContent(dContact.getRole())%>:&nbsp;<b><%=Encode.forHtmlContent(dContact.getContactName())%></b>
                    <% if (dContact.getType() == DemographicContact.TYPE_DEMOGRAPHIC) { %>
                    <a href='<%=request.getContextPath()%>/demographic/demographiccontrol.jsp?demographic_no=<%=dContact.getContactId()%>&displaymode=edit&dboperation=search_detail'>M</a>
                    <a href='<%=request.getContextPath()%>/oscarEncounter/IncomingEncounter.do?demographicNo=<%=dContact.getContactId()%>&providerNo=<%=curProviderNo%>&appointmentNo=&curProviderNo=&reason=&appointmentDate=&startTime=&status=&userName=<%=URLEncoder.encode(userFirstName + " " + userLastName)%>&curDate=<%=curYear%>-<%=curMonth%>-<%=curDay%>'>E</a>
                    <% } %> &nbsp;<%=preferredContact%></td>
                <td id="<%=dContact.getId()%>" class="contactHover text-warning" style="font-weight: bold;">&nbsp;<%=responsibility%></td>
                <td>&nbsp;<%=StringUtils.trimToNull(dContact.getNote()) != null ? Encode.forHtmlContent(dContact.getNote()) : ""%>
                </td>
            </tr>
            <tr id="contactDetail_<%=dContact.getId()%>" style="display:none;">
                <td colspan="3">
                <div class="contactName"><%=Encode.forHtmlContent(dContact.getContactName())%></div>
                <% if (StringUtils.trimToNull(ecSdm) != null) {%>
                    <div><%=ecSdm%></div>
                <%}%>
                <div class="smallText role">
                    Category:
                    <span class="alignRight"><%=dContact.getCategory()%></span>
                </div>

                <div class="smallText role">
                    Role:
                    <span class="alignRight"><%=Encode.forHtmlContent(dContact.getRole())%></span>
                </div>

                <div class="smallText role">
                    Preferred Contact:
                    <%if (dContact.isConsentToContact()) {%>
                    <span class="alignRight"><%=StringUtils.trimToNull(dContact.getBestContact()) != null ? dContact.getBestContact() : "Not Set"%></span>
                    <%} else {%>
                    <span class="alignRight">NO CONSENT</span>
                    <%}%>
                </div>

                <div class="smallText role">
                    Phone:
                    <span class="alignRight"><%=StringUtils.trimToNull(details.getResidencePhone()) != null ? details.getResidencePhone() : ""%></span>
                </div>

                <div class="smallText role">
                    Cell:
                    <span class="alignRight"><%=StringUtils.trimToNull(details.getCellPhone()) != null ? details.getCellPhone() : ""%></span>
                </div>

                <div class="smallText role">
                    Work:
                    <span class="alignRight"><%=StringUtils.trimToNull(details.getWorkPhone()) != null ? details.getWorkPhone() : ""%></span>
                </div>

                <div class="smallText role">
                    Email:
                    <span class="alignRight"><%=StringUtils.trimToNull(details.getEmail()) != null ? details.getEmail() : ""%></span>
                </div>
            </td>
            </tr>


            <%}%>
        </table>
    </div>
    <%-- END HEALTH CARE TEAM MODULE --%>

    <%-- DETACHED VIEW ENABLED  --%>
    <c:if test="${ param.view eq 'detached' }">
        </td></tr>
        </table>
        </body>
        </html>
    </c:if>
    <%-- END DETACHED VIEW ENABLED  --%>

</security:oscarSec>