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
package oscar.form;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import org.oscarehr.common.dao.AllergyDao;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.model.Allergy;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

import oscar.OscarProperties;
import oscar.oscarDemographic.data.DemographicRelationship;
import oscar.oscarRx.data.RxPatientData;
import oscar.oscarRx.data.RxPatientData.Patient;

public class FrmAR2017Record extends FrmRecord {
    public Properties getFormRecord(LoggedInInfo loggedInInfo, int demographicNo, int existingID) throws SQLException {
        Properties props = new Properties();
        
        DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
//        RelationshipsDao relationshipsDao = SpringUtils.getBean(RelationshipsDao.class);
        DemographicRelationship demoRelation = new DemographicRelationship();
        
        String demoNoStr = Integer.toString(demographicNo);
        
        if (existingID <= 0) {
            Demographic demo = demographicDao.getDemographic(demoNoStr);
                
            if (demo != null) {
            	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                java.util.Date date = demo.getBirthDay() != null ? demo.getBirthDay().getTime() : null;
                props.setProperty("demographic_no", demoNoStr);
                props.setProperty("formCreated", sdf.format(new Date()));
                //props.setProperty("formEdited",
                // UtilDateUtilities.DateToString(new Date(),"yyyy/MM/dd"));
                props.setProperty("c_fn", demo.getFirstName()!=null?demo.getFirstName():"");
                props.setProperty("c_ln", demo.getLastName()!=null?demo.getLastName():"");
                String addressFromDemo = demo.getAddress()!=null?demo.getAddress():"";
                String apt = "";
                String address="";
                int aptIdx = addressFromDemo.toLowerCase().indexOf("apt");
                if(aptIdx > 0) {
                	address = addressFromDemo.substring(0, aptIdx-1); 
                	apt = addressFromDemo.substring(aptIdx+3, addressFromDemo.length());
                	if(apt.startsWith(".")) apt.substring(1);
                } else {
                	address = addressFromDemo;
                }
                props.setProperty("c_addr", address);
                props.setProperty("c_apt", apt);
                props.setProperty("c_city", demo.getCity());
                props.setProperty("c_prv", demo.getProvince());
                props.setProperty("c_pst", demo.getPostal());
                props.setProperty("c_chrt", demo.getDemographicNo().toString());
                props.setProperty("c_ohip", demo.getHin()!=null?demo.getHin()+(demo.getVer()!=null?demo.getVer():""):"");
                //no marital status in db?
                props.setProperty("c_cpr", demo.getPhone());
                props.setProperty("c_calt", demo.getEmail());
                props.setProperty("c_dob", demo.getYearOfBirth()+"/"+demo.getMonthOfBirth()+"/"+demo.getDateOfBirth());
                props.setProperty("c_lang", demo.getOfficialLanguage());
                props.setProperty("c_fph", demo.getProvider() != null ? demo.getProvider().getFirstName()+ " "+ demo.getProvider().getLastName() : "");
                
                //relatives
                List<Map<String, Object>> relations = demoRelation.getDemographicRelationshipsWithNamePhone(loggedInInfo, demoNoStr, loggedInInfo.getCurrentFacility().getId());
                if(relations != null && relations.size()>0) {
                    Iterator<Map<String, Object>> iter = relations.iterator();
                    while(iter.hasNext()) {
                    	Map<String, Object> relative = iter.next();
                    	String relation = (String)relative.get("relation");
                    	if(relation.equalsIgnoreCase("spouce") 
                    			|| relation.equalsIgnoreCase("husband")
                    			|| relation.equalsIgnoreCase("partner")
                    			|| relation.equalsIgnoreCase("wife")) {
                    		props.setProperty("c_pln", relative.get("lastName")!=null?(String)relative.get("lastName"):"");
                    		props.setProperty("c_pfn", relative.get("firstName")!=null?(String)relative.get("firstName"):"");
                    		props.setProperty("c_pAge", relative.get("age")!=null?(String)relative.get("age"):"");
//                    		String relativeDemoNo  = (String)relative.get("demographicNo") ;
                    		break;
                    	}
                    }
                }
                
                //drugs
                String drugsStr = "";
                Set<String> drugsSet = new HashSet<String>();
                
                String drugref_route = OscarProperties.getInstance().getProperty("drugref_route");
                if (drugref_route == null) {
                    drugref_route = "";
                }

                Patient patient = RxPatientData.getPatient(loggedInInfo, demographicNo);
                oscar.oscarRx.data.RxPrescriptionData.Prescription[] prescribedDrugs;
                prescribedDrugs = patient.getPrescribedDrugScripts(); //this function only returns drugs which have an entry in prescription and drugs table
                
                for (int i = 0; i < prescribedDrugs.length; i++) {
                    oscar.oscarRx.data.RxPrescriptionData.Prescription drug = prescribedDrugs[i];
                    drugsSet.add(drug.getDrugName().toLowerCase());
                }
                            
       			for(String drug : drugsSet) {
       				if(drugsStr.length()==0) drugsStr = drug;
       				else drugsStr += ", "+drug;
       			}
                props.setProperty("c_medc", drugsStr);
                
                //alergy
       			String allergiesStr = "";
        		AllergyDao allergyDao = SpringUtils.getBean(AllergyDao.class);
        		List<Allergy> allergies = allergyDao.findActiveAllergies(demographicNo);
       			for(Allergy allergy : allergies) {
       				if(allergiesStr.length()==0) allergiesStr = allergy.getDescription();
       				else allergiesStr += ", "+allergy;
       			}
                props.setProperty("c_alrg", allergiesStr);

            }
        } else {
            String sql = "SELECT * FROM formONAR2017 WHERE demographic_no = " + demographicNo
                    + " AND ID = " + existingID;
            props = (new FrmRecordHelp()).getFormRecord(sql);
        }

        return props;
    }

    public int saveFormRecord(Properties props) throws SQLException {
        String demographic_no = props.getProperty("demographic_no");
        String sql = "SELECT * FROM formONAR2017 WHERE demographic_no=" + demographic_no + " AND ID=0";

        return ((new FrmRecordHelp()).saveFormRecord(props, sql));
    }

    public Properties getPrintRecord(int demographicNo, int existingID) throws SQLException {
        String sql = "SELECT * FROM formONAR2017 WHERE demographic_no = " + demographicNo + " AND ID = "
                + existingID;
        return ((new FrmRecordHelp()).getPrintRecord(sql));
    }

    public String findActionValue(String submit) throws SQLException {
        return ((new FrmRecordHelp()).findActionValue(submit));
    }

    public String createActionURL(String where, String action, String demoId, String formId)
            throws SQLException {
        return ((new FrmRecordHelp()).createActionURL(where, action, demoId, formId));
    }

    public boolean isSendToPing(String demoNo) throws SQLException {
        boolean ret = false;
        if ("yes".equalsIgnoreCase(OscarProperties.getInstance().getProperty("PHR", ""))) {

            DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
            Demographic demo = demographicDao.getDemographic(demoNo);
            
            if(demo != null) {
                if (demo.getEmail() != null && demo.getEmail().length() > 5
                        && demo.getEmail().matches(".*@.*"))
                    ret = true;
            	
            }
        }
        return ret;
    }
}
