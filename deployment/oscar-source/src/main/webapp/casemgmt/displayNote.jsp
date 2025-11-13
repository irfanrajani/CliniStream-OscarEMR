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
<%@page import="oscar.OscarProperties"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@page import="org.oscarehr.common.model.UserProperty"%>
<%@page import="org.oscarehr.common.dao.UserPropertyDAO"%>
<%@page import="org.commonmark.node.Node"%>
<%@page import="org.commonmark.parser.Parser"%>
<%@page import="org.commonmark.renderer.html.HtmlRenderer"%>
<%@page import="java.util.regex.Pattern"%>
<%@page import="java.util.ResourceBundle"%>

<%
    String noteStr = (String)request.getAttribute("noteStr");
    Boolean raw = (Boolean)request.getAttribute("raw");
    if( raw ) {
 %>
        <%=noteStr%>
    <% } else { 
        noteStr.replaceAll("\n","<br>");
        LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
		String curUser_no=loggedInInfo.getLoggedInProviderNo();
		UserPropertyDAO userPropertyDao = (UserPropertyDAO) SpringUtils.getBean("UserPropertyDAO");
		UserProperty markdownProp = userPropertyDao.getProp(curUser_no, UserProperty.MARKDOWN);
		boolean renderMarkdown = false;
		if ( markdownProp == null ) {
			renderMarkdown = oscar.OscarProperties.getInstance().getBooleanProperty("encounter.render_markdown", "true");
		} else {
			renderMarkdown = oscar.OscarProperties.getInstance().getBooleanProperty("encounter.render_markdown", "true") && Boolean.parseBoolean(markdownProp.getValue());
		}
        if ( renderMarkdown ){  //follow pattern from ChartNotesAjax.jsp
            noteStr = noteStr.replaceAll("<br>","  \n");  //force Markdown to introduce a <br> for a linebreak
            Parser parser = Parser.builder().build();
            Node document = parser.parse(noteStr);
            HtmlRenderer renderer = HtmlRenderer.builder().build();
            noteStr = renderer.render(document);
            //there are some formatting differences that this will produce, and we will let them be except for the signature line
            java.util.ResourceBundle oscarRec = ResourceBundle.getBundle("oscarResources", request.getLocale());
            String signedon = oscarRec.getString("oscarEncounter.class.EctSaveEncounterAction.msgSigned");
            noteStr = noteStr.replaceAll(Pattern.quote("["+signedon),"<br>["+signedon);
        }
%>
        <%=noteStr%>
    <%}%>