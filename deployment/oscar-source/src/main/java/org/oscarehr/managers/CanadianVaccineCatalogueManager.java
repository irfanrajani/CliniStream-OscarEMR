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
package org.oscarehr.managers;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.logging.log4j.Logger;
import org.oscarehr.common.dao.CVCImmunizationDao;
import org.oscarehr.common.dao.CVCMedicationDao;
import org.oscarehr.common.dao.CVCMedicationGTINDao;
import org.oscarehr.common.dao.CVCMedicationLotNumberDao;
import org.oscarehr.common.model.CVCImmunization;
import org.oscarehr.common.model.CVCMedication;
import org.oscarehr.common.model.CVCMedicationGTIN;
import org.oscarehr.common.model.CVCMedicationLotNumber;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import ca.uhn.fhir.context.FhirContext;
import oscar.log.LogAction;

@Service
public class CanadianVaccineCatalogueManager {

	
	protected static FhirContext ctx = null;
	protected static FhirContext ctxR4 = null;
	Logger logger = MiscUtils.getLogger();

	@Autowired
	CVCMedicationDao medicationDao;
	@Autowired
	CVCMedicationLotNumberDao lotNumberDao;
	@Autowired
	CVCMedicationGTINDao gtinDao;
	@Autowired
	CVCImmunizationDao immunizationDao;

	static {
		ctx = FhirContext.forDstu3();
		ctxR4 = FhirContext.forR4();
		/*
		SSLParameters sslParameters = new SSLParameters();
		List sniHostNames = new ArrayList(1);
		sniHostNames.add(new SNIHostName("api.cvc.canimmunize.ca"));
		sslParameters.setServerNames(sniHostNames);
		
		try {
		
			SSLContext sslcontext = SSLContexts.custom().build();
			
			
			SSLConnectionSocketFactory fac = new SSLConnectionSocketFactory(new SSLSocketFactoryWrapper(sslcontext.getSocketFactory(), sslParameters), SSLConnectionSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
			
			List<Header> defaultHeaders = new ArrayList<Header>();
			defaultHeaders.add(new BasicHeader("Accept-Encoding", "gzip;q=0,deflate,sdch"));
			CloseableHttpClient httpclient = HttpClients.custom().setSSLSocketFactory(fac).setDefaultHeaders(defaultHeaders).build();
			
			
		//	CloseableHttpClient httpclient = HttpClients.custom().setSslcontext(sslcontext).build();
			
			
			ctx.getRestfulClientFactory().setHttpClient(httpclient);
		}catch(Exception e) {
		}
		*/
			
	}
	public List<CVCImmunization> getImmunizationList() {
		List<CVCImmunization> results = immunizationDao.findAll(0, 1000);
		return results;
	}

	public List<CVCImmunization> getImmunizationsByParent(String conceptId) {
		List<CVCImmunization> results = immunizationDao.findByParent(conceptId);
		return results;
	}

	public CVCMedication getMedicationBySnomedConceptId(String conceptId) {
		CVCMedication result = medicationDao.findBySNOMED(conceptId);
		return result;
	}

	public List<CVCImmunization> getGenericImmunizationList() {
		List<CVCImmunization> results = immunizationDao.findAllGeneric();
		return results;
	}
	
	public List<CVCImmunization> getGenericMarketedImmunizationList() {
		List<CVCImmunization> results = immunizationDao.findAllGenericMarketed();
		return results;
	}

	public List<CVCMedication> getMedicationByDIN(LoggedInInfo loggedInInfo, String din) {
		List<CVCMedication> results = medicationDao.findByDIN(din);

		//--- log action ---
		LogAction.addLogSynchronous(loggedInInfo, "CanadianVaccineCatalogueManager.getMedicationByDIN", null);

		return results;
	}


	public String saveLot(CVCMedication medication, String lotNumber, Date expiryDate) {
		medication.getLotNumberList().add(new CVCMedicationLotNumber(medication, lotNumber, expiryDate));
		Set<CVCMedicationLotNumber> lotNumbers = medication.getLotNumberList();
		for (CVCMedicationLotNumber l : lotNumbers) {
			lotNumberDao.saveEntity(l);
		}
		return lotNumber;
	}

	public String deleteLot(String snomedConceptId, String lotNumber) {

		if(snomedConceptId != null) {
			lotNumberDao.removeLot(lotNumber);	
			return lotNumber;
		}
		return null;
	}


	public void saveMedication(LoggedInInfo loggedInInfo, CVCMedication medication) {
		Set<CVCMedicationGTIN> gtins = medication.getGtinList();
		Set<CVCMedicationLotNumber> lotNumbers = medication.getLotNumberList();

		medication.setGtinList(null);
		medication.setLotNumberList(null);
		medicationDao.saveEntity(medication);

		for (CVCMedicationGTIN g : gtins) {
			gtinDao.saveEntity(g);
		}

		for (CVCMedicationLotNumber l : lotNumbers) {
			lotNumberDao.saveEntity(l);
		}

		//--- log action ---
		LogAction.addLogSynchronous(loggedInInfo, "CanadianVaccineCatalogueManager.saveMedication", medication.getId().toString());

	}



	public CVCMedicationLotNumber findByLotNumber(LoggedInInfo loggedInInfo, String lotNumber) {
		CVCMedicationLotNumber result = lotNumberDao.findByLotNumber(lotNumber);

		LogAction.addLogSynchronous(loggedInInfo, "CanadianVaccineCatalogueManager.findByLotNumber", "lotNumber:" + lotNumber);

		return result;
	}

	public CVCImmunization getBrandNameImmunizationBySnomedCode(LoggedInInfo loggedInInfo, String snomedCode) {
		CVCImmunization result = immunizationDao.findBySnomedConceptId(snomedCode);

		LogAction.addLogSynchronous(loggedInInfo, "CanadianVaccineCatalogueManager.getBrandNameImmunizationBySnomedCode", "snomedCode:" + snomedCode);

		return result;
	}

	public List<CVCImmunization> query(String term, boolean includeGenerics, boolean includeBrands, boolean includeLotNumbers, boolean includeGTINs, StringBuilder matchedLotNumber) {
		List<CVCImmunization> results = new ArrayList<CVCImmunization>();
		
		if (includeGenerics || includeBrands) {
			results.addAll(immunizationDao.query(term, includeGenerics, includeBrands));
		}
		if (includeLotNumbers) {
			List<CVCMedicationLotNumber> res = lotNumberDao.query(term);
			if(res.size() == 1) {
				if(matchedLotNumber != null) {
					matchedLotNumber.append(res.get(0).getLotNumber());
				}
			}
			
			for (CVCMedicationLotNumber t : res) {
				String snomedId = t.getMedication().getSnomedCode();
				results.add(immunizationDao.findBySnomedConceptId(snomedId));		
			}
			

		}
		if (includeGTINs) {
			for (CVCMedicationGTIN t : gtinDao.query(term)) {
				String snomedId = t.getMedication().getSnomedCode();
				results.add(immunizationDao.findBySnomedConceptId(snomedId));
			}

		}

		//unique it
		Map<String, CVCImmunization> tmp = new HashMap<String, CVCImmunization>();
		for (CVCImmunization i : results) {
			tmp.put(i.getSnomedConceptId(), i);
		}
		List<CVCImmunization> uniqueResults = new ArrayList<CVCImmunization>(tmp.values());

		//sort it
		Collections.sort(uniqueResults, new PrevalenceComparator());
		
		
		return uniqueResults;
	}
}

class PrevalenceComparator implements Comparator<CVCImmunization> {
    public int compare( CVCImmunization i1, CVCImmunization i2 ) {
  
            Integer d1 = i1.getPrevalence();
            Integer d2 = i2.getPrevalence();
            
            if( d1 == null && d2 != null )
                    return 1;
            else if( d1 != null && d2 == null )
                    return -1;
            else if( d1 == null && d2 == null )
                    return 0;
            else
                    return d1.compareTo(d2) * -1;
    }
}
