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

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_rx" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_rx");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>


<%@ page import="oscar.oscarRx.data.*"%>
<%@ page import="oscar.oscarRx.pageUtil.*"%>

<%@ page import="javax.servlet.http.HttpServletRequest"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>

<%
RxSessionBean bean = (RxSessionBean) session.getAttribute("RxSessionBean");
if ( bean == null ){
    return;
}


     RxDrugData.Interaction[] interactions = (RxDrugData.Interaction[]) bean.getInteractions();
     if (interactions != null && interactions.length > 0){
        for (int i = 0 ; i < interactions.length; i++){  %>
<div
	style="width: 300px; font-size: 9pt; background-color:<%=sigColor(interactions[i].significance)%>;margin-right:3px;margin-top:2px;padding-left:3px;padding-top:3px;padding-bottom:3px;" title="SIGNIFICANCE = <%=significance(interactions[i].significance)%>">
<%=interactions[i].affectingdrug%> <%=effect(request, interactions[i].effect)%> <%=interactions[i].affecteddrug%>
<br><%=evidence(request,interactions[i].evidence)%><br />
<%=interactions[i].comment==null||interactions[i].comment.equals("")? "":interactions[i].comment+"<br>"%>
<a href="">Drugref2</a></div>
<%      }
    }else if(interactions == null && bean.getStashSize() > 1){ %>
<div>Drug to Drug Interaction Service not available</div>
<%  }   %>
<%!
    String effect(HttpServletRequest request, String s){
        java.util.ResourceBundle oscarRec = ResourceBundle.getBundle("oscarResources", request.getLocale());
        Hashtable h = new Hashtable();
        h.put("a",oscarRec.getString("oscarRx.MyDrugref.InteractingDrugs.effect.AugmentsNoClinicalEffect"));
        h.put("A",oscarRec.getString("oscarRx.MyDrugref.InteractingDrugs.effect.Augments"));
        h.put("i",oscarRec.getString("oscarRx.MyDrugref.InteractingDrugs.effect.InhibitsNoClinicalEffect"));
        h.put("I",oscarRec.getString("oscarRx.MyDrugref.InteractingDrugs.effect.Inhibits"));
        h.put("n",oscarRec.getString("oscarRx.MyDrugref.InteractingDrugs.effect.NoEffect"));
        h.put("N",oscarRec.getString("oscarRx.MyDrugref.InteractingDrugs.effect.NoEffect"));
        h.put(" ",oscarRec.getString("oscarRx.MyDrugref.InteractingDrugs.effect.Unknown"));

        String retval = (String) h.get(s);
        if (retval == null) {retval = oscarRec.getString("oscarRx.MyDrugref.InteractingDrugs.effect.Unknown");}
        return retval;
   }

	String significance(String s){
       Hashtable h = new Hashtable();
       h.put("1","minor");
       h.put("2","moderate");
       h.put("3","major");
       h.put(" ","unknown");

       String retval = (String) h.get(s);
        if (retval == null) {retval = "unknown";}
        return retval;
   }

   String evidence(HttpServletRequest request, String s){
       java.util.ResourceBundle oscarRec = ResourceBundle.getBundle("oscarResources", request.getLocale());
       Hashtable h = new Hashtable();
       h.put("P",oscarRec.getString("oscarRx.MyDrugref.InteractingDrugs.evidence.Poor"));
       h.put("F",oscarRec.getString("oscarRx.MyDrugref.InteractingDrugs.evidence.Fair"));
       h.put("G",oscarRec.getString("oscarRx.MyDrugref.InteractingDrugs.evidence.Good"));
       h.put(" ",oscarRec.getString("oscarRx.MyDrugref.InteractingDrugs.evidence.Unknown"));

       String retval = (String) h.get(s);
        if (retval == null) {retval = oscarRec.getString("oscarRx.MyDrugref.InteractingDrugs.evidence.Unknown");}
        return retval;
   }


   String sigColor(String s){
       Hashtable h = new Hashtable();
       h.put("1","yellow");
       h.put("2","orange");
       h.put("3","red");
       h.put(" ","greenyellow");

       String retval = (String) h.get(s);
        if (retval == null) {retval = "greenyellow";}
        return retval;
   }

   String severityOfReaction(String s){
       Hashtable h = new Hashtable();
       h.put("1","Mild");
       h.put("2","Moderate");
       h.put("3","Severe");

       String retval = (String) h.get(s);
       if (retval == null) {retval = "Unknown";}
       return retval;
   }

   String severityOfReactionColor(String s){
       Hashtable h = new Hashtable();
       h.put("1","yellow");
       h.put("2","orange");
       h.put("3","red");

       String retval = (String) h.get(s);
       if (retval == null) {retval = "red";}
       return retval;
   }

   String onSetOfReaction(String s){
       Hashtable h = new Hashtable();
       h.put("1","Immediate");
       h.put("2","Gradual");
       h.put("3","Slow");

       String retval = (String) h.get(s);
       if (retval == null) {retval = "Unknown";}
       return retval;
   }
%>