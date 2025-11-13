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

<%@ page import="java.util.*,java.sql.*, java.net.*"%>
<%@ page import="org.oscarehr.common.web.ContactAction"%>
<%@ page import="org.oscarehr.common.model.Contact"%>
<%@ page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ page import="org.apache.commons.lang.WordUtils"%>
<%@ page import="net.sf.json.JSONObject" %>
<%@ page import="javax.servlet.jsp.jstl.core.LoopTagStatus" %>
<%@ page import="oscar.SxmlMisc" %>
<%@ page import="oscar.OscarProperties" %>

<%@ include file="/taglibs.jsp"%>

<%
  String strLimit1="0";
  String strLimit2="10";
  if(request.getParameter("limit1")!=null) strLimit1 = request.getParameter("limit1");
  if(request.getParameter("limit2")!=null) strLimit2 = request.getParameter("limit2");

  int nItems = 0;
  Properties prop = null;
  String form = request.getParameter("form")==null?"":request.getParameter("form") ;
  String elementName = request.getParameter("elementName")==null?"":request.getParameter("elementName") ;
  String elementId = request.getParameter("elementId")==null?"":request.getParameter("elementId") ;
  String keyword = request.getParameter("keyword") == null ? "" : request.getParameter("keyword");
	
%>

<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title>Search Contacts</title>
<script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" media="all" href="../share/css/extractedFromPages.css"  />
<script type="text/javascript" >

<!--
var contactResults = [];
		function setfocus() {
		  this.focus();
		  document.forms[0].keyword.focus();
		  document.forms[0].keyword.select();
		}
		function check() {
		  document.forms[0].submit.value="Search";
		  return true;
		}


function selectContactJson(index) {
    var contact = contactResults[index];

    if (contact) {
        opener.document.contactForm.elements['contact_contactName'].value = contact.name;
        opener.document.contactForm.elements['contact_contactId'].value = contact.contactId;
        opener.document.contactForm.elements['contact_phone'].value = contact.phone ? contact.phone : '';
        opener.document.contactForm.elements['contact_cell'].value = contact.cell ? contact.cell : '';
        opener.document.contactForm.elements['contact_work'].value = contact.work ? contact.work : '';
        opener.document.contactForm.elements['contact_email'].value = contact.email ? contact.email : '';

        opener.document.contactForm.elements['contact_contactName'].onchange();
        self.close();
    }
}

		function selectResult(data1,data2) {
			
			try {
				serializePopupData(data1, data2);
			} catch(error) {
				opener.document.<%=form%>.elements['<%=elementId%>'].value = data1;
				opener.document.<%=form%>.elements['<%=elementName%>'].value = data2;
				self.close();
			}

		}
		
		function serializePopupData(data1, data2) {
			var id1 = '<%=elementId%>';
			var id2 = '<%=elementName%>';
			var data = '{"' + id1 + '":"' + data1 + '","' + id2 + '":"' + data2 + '"}';		
			opener.popUpData(data);
			self.close();
		}
		                
-->

</script>
</head>
<body onload="setfocus()">
	
<form method="post" name="titlesearch" action="contactSearch.jsp" onSubmit="return check();">
<table bgcolor="#CCCCFF" width="100%">
	<tr>
		<td class="searchTitle" colspan="4">Search Contacts</td>
	</tr>
	<tr>
		<td class="blueText" width="10%" nowrap>
			<input type="radio" name="search_mode" value="search_name" checked="checked"> Name
		</td>
		<td valign="middle" rowspan="2" align="left">
			<input type="text" name="elementName" value="" size="17" maxlength="100"> 
			<input type="hidden" name="orderby" value="c.lastName, c.firstName"> 
			<input type="hidden" name="limit1" value="0"> 
			<input type="hidden" name="limit2" value="10"> 
			<input type="hidden" name="submit" value='Search'> 
			<input type="submit" value='Search'>
		</td>
	</tr>	
</table>
<table>
	<tr>
		<td align="left">Results based on keyword(s): <%=keyword%></td>
	</tr>
</table>
<input type='hidden' name='form' value="<%=StringEscapeUtils.escapeHtml(form)%>"/>
<input type='hidden' name='elementName' value="<%=StringEscapeUtils.escapeHtml(elementName)%>"/>
<input type='hidden' name='elementId' value="<%=StringEscapeUtils.escapeHtml(elementId)%>"/>
</form>

<%
	String list = request.getParameter("list");
	List<Contact> contacts;

	if( "all".equalsIgnoreCase(list) ) {
		contacts = ContactAction.searchAllContacts("search_name", "c.lastName, c.firstName", keyword);
	} else if("personal".equalsIgnoreCase(list)) {
		contacts = ContactAction.searchPersonalContacts("search_name", "c.lastName, c.firstName", keyword);
	} else {
		contacts = ContactAction.searchContacts("search_name", "c.lastName, c.firstName", keyword);
	}

	nItems = contacts.size();
	pageContext.setAttribute("contacts",contacts);
%>

<table bgcolor="#C0C0C0" width="100%">
	<tr class="title" >
		<th>Specialty</th>
		<th>Last Name</th>
		<th>First Name</th>		
		<th>Phone</th>
	</tr>
	
	<c:forEach var="contact" items="${ contacts }" varStatus="i">
		<%
			Contact contact = (Contact)pageContext.getAttribute("contact");
			JSONObject contactJson = new JSONObject();
			contactJson = new JSONObject();
			contactJson.put("name", contact.getFormattedName());
			contactJson.put("contactId", contact.getId());
			contactJson.put("cell", contact.getCellPhone());
			contactJson.put("phone", contact.getResidencePhone());
			contactJson.put("work", contact.getWorkPhone());
			contactJson.put("email", contact.getEmail());
		%>
		<script type="text/javascript">
			contactResults.push(<%=contactJson.toString()%>);
		</script>
		<%
			LoopTagStatus i = (LoopTagStatus) pageContext.getAttribute("i");
			String bgColor = i.getIndex()%2==0?"#EEEEFF":"ivory";	
			
			String strOnClick;
			if (OscarProperties.getInstance().isPropertyActive("NEW_CONTACTS_UI") && "contactForm".equals(form)) {
			    strOnClick = "selectContactJson('" + i.getIndex() + "')";
			} else {
				strOnClick = "selectResult('" + contact.getId() + "','"+StringEscapeUtils.escapeJavaScript(contact.getLastName()+ "," + contact.getFirstName()) + "')";
			}

                        
		%>
		<tr bgcolor="<%=bgColor%>"
		onMouseOver="this.style.cursor='hand';this.style.backgroundColor='pink';"
		onMouseout="this.style.backgroundColor='<%=bgColor%>';" onClick="<%=strOnClick%>">
			<td><c:catch var="err"><c:out value="${contact.specialty }" /><</c:catch></td>
			<td><c:out value="${contact.lastName}"/></td>
			<td><c:out value="${contact.firstName}"/></td>
			<td><c:out value="${contact.residencePhone}"/></td>
		</tr>
	</c:forEach>
	
	
</table>

<%
  int nLastPage=0,nNextPage=0;
  nNextPage=Integer.parseInt(strLimit2)+Integer.parseInt(strLimit1);
  nLastPage=Integer.parseInt(strLimit1)-Integer.parseInt(strLimit2);
%> <%
  if(nItems==0 && nLastPage<=0) {
%> <bean:message key="demographic.search.noResultsWereFound" /> <%
  }
%> 
<script type="text/javascript" >

function last() {
  document.nextform.action="contactSearch.jsp?form=<%=URLEncoder.encode(form,"UTF-8")%>&elementName=<%=URLEncoder.encode(elementName,"UTF-8")%>&elementId=<%=URLEncoder.encode(elementId,"UTF-8")%>&keyword=<%=request.getParameter("keyword")%>&search_mode=<%=request.getParameter("search_mode")%>&orderby=<%=request.getParameter("orderby")%>&limit1=<%=nLastPage%>&limit2=<%=strLimit2%>" ; 
  document.nextform.submit();
}
function next() {
  document.nextform.action="contactSearch.jsp?form=<%=URLEncoder.encode(form,"UTF-8")%>&elementName=<%=URLEncoder.encode(elementName,"UTF-8")%>&elementId=<%=URLEncoder.encode(elementId,"UTF-8")%>&keyword=<%=request.getParameter("keyword")%>&search_mode=<%=request.getParameter("search_mode")%>&orderby=<%=request.getParameter("orderby")%>&limit1=<%=nNextPage%>&limit2=<%=strLimit2%>" ; 
  document.nextform.submit();
}

</script>

<form method="post" name="nextform" action="contactSearch.jsp">
<%
  if(nLastPage>=0) {
%> <input type="submit" class="mbttn" name="submit"
	value="<bean:message key="demographic.demographicsearch2apptresults.btnPrevPage"/>"
	onClick="last()"> <%
  }
  if(nItems==Integer.parseInt(strLimit2)) {
%> <input type="submit" class="mbttn" name="submit"
	value="<bean:message key="demographic.demographicsearch2apptresults.btnNextPage"/>"
	onClick="next()"> <%
}
%>
</form>
<br>
<a href="addEditContact.jsp">Add/Edit Contact</a>
</body>
</html:html>
