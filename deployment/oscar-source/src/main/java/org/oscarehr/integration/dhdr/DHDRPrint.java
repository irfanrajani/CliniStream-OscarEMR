package org.oscarehr.integration.dhdr;
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
import java.awt.Color;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.logging.log4j.Logger;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.printing.FontSettings;
import org.oscarehr.common.printing.PdfWriterFactory;
import org.oscarehr.managers.DemographicManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import com.lowagie.text.Chunk;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.HeaderFooter;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

public class DHDRPrint {
	
	DemographicManager demographicManager = SpringUtils.getBean(DemographicManager.class);
    Logger logger = MiscUtils.getLogger();
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd  'at' HH:mm:ss z");
	
    public void printDetail(LoggedInInfo loggedInInfo,Integer demographicNo,OutputStream outputStream,JSONObject jsonOb) throws Exception{
    		Document document;
	    PdfContentByte cb;
	    
	    Demographic demo = demographicManager.getDemographic(loggedInInfo, demographicNo);
        
        if (demo == null) 
            throw new DocumentException();
		
		document = new Document(); 
        document.setPageSize(PageSize.LETTER);
        
        PdfWriter writer = PdfWriterFactory.newInstance(document, outputStream, FontSettings.HELVETICA_10PT);
        
        HeaderFooter header = getHeaderFooter( demo ,"DHDR Detailed");
        document.setHeader(header);  
        
        
        document.open();
        cb = writer.getDirectContent();

        Paragraph dhrDisclaimerParagraph = new Paragraph("Warning: Limited to Drug and Pharmacy Service Information available in the Digital Health Drug Repository (DHDR) EHR Service. To ensure a Best Possible Medication History (BPMH), please review this information with the patient/family and use other available sources of medication information in addition to the DHDR EHR Service.", FontFactory.getFont(FontFactory.HELVETICA, 9, Font.ITALIC , Color.BLACK));
        dhrDisclaimerParagraph.add(Chunk.NEWLINE);
        document.add(dhrDisclaimerParagraph);
        
        Paragraph emrHeaderParagraph = new Paragraph("DHDR Detailed", FontFactory.getFont(FontFactory.HELVETICA, 12, Font.BOLD | Font.UNDERLINE, Color.BLACK));
        emrHeaderParagraph.add(Chunk.NEWLINE);
        document.add(emrHeaderParagraph);
        
        document.add(Chunk.NEWLINE);
        
        ///////table
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100.0f);
        
        
        JSONObject med = jsonOb.getJSONObject("med");
        
        if(med != null){
        	
	        table.addCell(getHeaderCell("Dispense Date"));
	        table.addCell(getHeaderCell(med.optString("whenPrepared"))); //Dispense Date
	        
	        table.setHeaderRows(1);
	        
	        table.addCell(getHeaderCell("Generic"));	
            	table.addCell(getItemCell(med.optString("genericName")));  //Generic
            	
            	JSONObject brandObj = med.getJSONObject("brandName");
            	table.addCell(getHeaderCell("Brand"));
            	table.addCell(getItemCell( brandObj.optString("display"))); //Brand
            	
            	table.addCell(getHeaderCell("DIN/PIN"));
            	table.addCell(getItemCell( brandObj.optString("code"))); //Brand
            	
            	JSONObject ahfsClassObj = med.getJSONObject("ahfsClass");
            	table.addCell(getHeaderCell("Therapeutic Class"));
            	table.addCell(getItemCell( ahfsClassObj.optString("display"))); //Brand
            	
            	JSONObject ahfsSubClassObj = med.getJSONObject("ahfsSubClass");
            	table.addCell(getHeaderCell("Therapeutic Sub-Class"));
            	table.addCell(getItemCell( ahfsSubClassObj.optString("display"))); //Brand
	
            	table.addCell(getHeaderCell("Rx Number"));
            	table.addCell(getItemCell( med.optString("rxNumber"))); //Brand

            	table.addCell(getHeaderCell("Medical Condition/Reason for Use"));
            	
            	StringBuilder reasonCodesStr = new StringBuilder();
            	JSONArray reasonCodes = med.getJSONArray("reasonCode");
            	for(int i = 0; i < reasonCodes.size(); i++) {
            		JSONObject jsonObject = reasonCodes.getJSONObject(i);
            	
            		reasonCodesStr.append(jsonObject.opt("code")+" -- "+jsonObject.opt("display"));
            	}
            	table.addCell(getItemCell( reasonCodesStr.toString())); //Brand
          

            	table.addCell(getHeaderCell("Strength"));
            	table.addCell(getItemCell(med.optString("dispensedDrugStrength")));  //Strength
            	table.addCell(getHeaderCell("Dosage Form"));
            	table.addCell(getItemCell(med.optString("drugDosageForm")));  //Dosage Form
            	table.addCell(getHeaderCell("Quantity"));
            	table.addCell(getItemCell(med.optString("dispensedQuantity"))); //Quantity
            	table.addCell(getHeaderCell("Est Days Supply"));
            	table.addCell(getItemCell(med.optString("estimatedDaysSupply"))); //Est Days Supply
            	
            	table.addCell(getHeaderCell("Refills Remaining"));
            	table.addCell(getItemCell(med.optString("refillsRemaining"))); 
			table.addCell(getHeaderCell("Quantity Remaining"));
			table.addCell(getItemCell(med.optString("quantityRemaining"))); 
			
            	
            	JSONObject prescriberLicenceNumberObj = med.getJSONObject("prescriberLicenceNumber");
            	table.addCell(getHeaderCell("Prescriber"));
            	table.addCell(getItemCell(med.optString("prescriberLastname")+", "+med.optString("prescriberFirstname")+" ("+prescriberLicenceNumberObj.optString("value")+")"   ));//Prescriber
            	
            	table.addCell(getHeaderCell("Prescriber ID"));
            	table.addCell(getItemCell(prescriberLicenceNumberObj.optString("system")+" "+prescriberLicenceNumberObj.optString("value")));//Prescriber
            	
            	table.addCell(getHeaderCell("Prescriber #"));
            	table.addCell(getItemCell(med.optString("prescriberPhoneNumber"))); //Prescriber #
            	table.addCell(getHeaderCell("Pharmacy"));
            	table.addCell(getItemCell(med.optString("dispensingPharmacy"))); //Pharmacy
            	table.addCell(getHeaderCell("Pharmacy Fax"));
            	table.addCell(getItemCell(med.optString("dispensingPharmacyFaxNumber"))); // Pharmacy Fax
        
            	table.addCell(getHeaderCell("Pharmacy Phone"));
            	table.addCell(getItemCell(med.optString("dispensingPharmacyPhoneNumber"))); // Pharmacy Fax
        
            	table.addCell(getHeaderCell("Pharmacist"));
            	JSONObject pharmacistLicenceNumber = med.getJSONObject("pharmacistLicenceNumber");
            	table.addCell(getItemCell(med.optString("pharmacistLastname")+", "+med.optString("pharmacistFirstname")+" ("+pharmacistLicenceNumber.optString("value")+")"   )); // Pharmacy Fax
		
            	 document.add(table); 
        }else {
        	Paragraph noResults = new Paragraph("No Med Found.",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK));
        	noResults.add(Chunk.NEWLINE);
        	document.add(noResults);
        }
        //////end table
        
        Paragraph datePrinted = new Paragraph("Printed on " + formatter.format(new Date()) ,FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK));
        datePrinted.add(Chunk.NEWLINE);
        document.add(datePrinted);
        
        
        document.close();

    }
	
	public void printSummary(LoggedInInfo loggedInInfo,Integer demographicNo,OutputStream outputStream,JSONObject jsonOb) throws Exception{
		
		Document document;
	    PdfContentByte cb;
	    
	    Demographic demo = demographicManager.getDemographic(loggedInInfo, demographicNo);
        
        if (demo == null) 
            throw new DocumentException();
		
		document = new Document(); 
        document.setPageSize(PageSize.LETTER);
        
        PdfWriter writer = PdfWriterFactory.newInstance(document, outputStream, FontSettings.HELVETICA_10PT);
        
        HeaderFooter header = getHeaderFooter( demo,"DHDR Summary" );
        document.setHeader(header);  
        
        
        document.open();
        cb = writer.getDirectContent();

        Paragraph dhrDisclaimerParagraph = new Paragraph("Warning: Limited to Drug and Pharmacy Service Information available in the Digital Health Drug Repository (DHDR) EHR Service. To ensure a Best Possible Medication History (BPMH), please review this information with the patient/family and use other available sources of medication information in addition to the DHDR EHR Service.", FontFactory.getFont(FontFactory.HELVETICA, 9, Font.ITALIC , Color.BLACK));
        dhrDisclaimerParagraph.add(Chunk.NEWLINE);
        document.add(dhrDisclaimerParagraph);
        
        ///
        
        Paragraph emrHeaderParagraph = new Paragraph("DHDR Summary", FontFactory.getFont(FontFactory.HELVETICA, 12, Font.BOLD | Font.UNDERLINE, Color.BLACK));
        emrHeaderParagraph.add(Chunk.NEWLINE);
        document.add(emrHeaderParagraph);
        //formatter.format(
        Paragraph emrDateRangeParagraph = new Paragraph("Date Range: ", FontFactory.getFont(FontFactory.HELVETICA, 11, Font.BOLD, Color.BLACK));
        emrDateRangeParagraph.add(new Phrase (jsonOb.get("startDate") + " to " + jsonOb.get("endDate"),FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK)));
        emrDateRangeParagraph.add(Chunk.NEWLINE);
        
        document.add(emrDateRangeParagraph);
        
        document.add(Chunk.NEWLINE);
        
        JSONArray arr = jsonOb.getJSONArray("meds");
        Paragraph drugProductParagraph = new Paragraph("Drug Product", FontFactory.getFont(FontFactory.HELVETICA, 11, Font.BOLD, Color.BLACK));
        drugProductParagraph.add(new Phrase ("(Found " + arr.size() + " Events)",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK)));
        drugProductParagraph.add(Chunk.NEWLINE);
        drugProductParagraph.setSpacingAfter(5f);
        document.add(drugProductParagraph);
        
        ///////table
        PdfPTable table = new PdfPTable(13);
        table.setWidthPercentage(100.0f);
        
        
        
        
        if(arr.size() > 0) {
        	
	        table.addCell(getHeaderCell("Dispense Date"));
	        table.addCell(getHeaderCell("Generic"));
	        table.addCell(getHeaderCell("Brand"));
	        table.addCell(getHeaderCell("Strength"));
	        table.addCell(getHeaderCell("Dosage Form"));
	        table.addCell(getHeaderCell("Quantity"));
	        table.addCell(getHeaderCell("Est Days Supply"));
	    		table.addCell(getHeaderCell("Refills Remaining"));        	 
	    		table.addCell(getHeaderCell("Quantity Remaining"));
	        table.addCell(getHeaderCell("Prescriber"));
	        table.addCell(getHeaderCell("Prescriber #"));
	        table.addCell(getHeaderCell("Pharmacy"));
	        table.addCell(getHeaderCell("Pharmacy Fax"));
	        
	        table.setHeaderRows(1);
        
	        for(int i = 0; i < arr.size(); i++) {
	        		JSONObject med = arr.getJSONObject(i);
	        		
	        		table.addCell(getItemCell(med.optString("whenPrepared"))); //Dispense Date
	            	table.addCell(getItemCell(med.optString("genericName")));  //Generic
	            	JSONObject brandObj = med.getJSONObject("brandName");
	            	table.addCell(getItemCell( brandObj.optString("display"))); //Brand
	            	table.addCell(getItemCell(med.optString("dispensedDrugStrength")));  //Strength
	            	table.addCell(getItemCell(med.optString("drugDosageForm")));  //Dosage Form
	            	table.addCell(getItemCell(med.optString("dispensedQuantity"))); //Quantity
	            	table.addCell(getItemCell(med.optString("estimatedDaysSupply"))); //Est Days Supply
	            	table.addCell(getItemCell(med.optString("refillsRemaining")));
	        		table.addCell(getItemCell(med.optString("quantityRemaining")));
	            	JSONObject prescriberLicenceNumberObj = med.getJSONObject("prescriberLicenceNumber");
	            	table.addCell(getItemCell(med.optString("prescriberLastname")+", "+med.optString("prescriberFirstname")+" ("+prescriberLicenceNumberObj.optString("value")+")"   ));//Prescriber
	            	table.addCell(getItemCell(med.optString("prescriberPhoneNumber"))); //Prescriber #
	            	table.addCell(getItemCell(med.optString("dispensingPharmacy"))); //Pharmacy
	            	table.addCell(getItemCell(med.optString("dispensingPharmacyFaxNumber"))); // Pharmacy Fax
	        }
        
        
        document.add(table); 
        
       // Paragraph numResults = new Paragraph("Found " + arr.size() + " Events.",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK));
        //numResults.add(Chunk.NEWLINE);
        //document.add(numResults);
        }else {
        	Paragraph noResults = new Paragraph("No events found for the search time period.",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK));
        	noResults.add(Chunk.NEWLINE);
        	document.add(noResults);
        }
        //////end table
        
        ////service Table

        
        if(jsonOb.containsKey("services")) {
        		JSONArray serviceArr = jsonOb.getJSONArray("services");
        		
        		document.add(Chunk.NEWLINE);
        		
        		Paragraph servicesProductParagraph = new Paragraph("Pharma Services", FontFactory.getFont(FontFactory.HELVETICA, 11, Font.BOLD, Color.BLACK));
        		servicesProductParagraph.add(new Phrase ("(Found " + serviceArr.size() + " Events)",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK)));
        		servicesProductParagraph.add(Chunk.NEWLINE);
        		servicesProductParagraph.setSpacingAfter(5f);
            document.add(servicesProductParagraph);
            
            
        		
            PdfPTable serviceTable = new PdfPTable(7);
            serviceTable.setWidthPercentage(100.0f);

	        
	        
	        if(serviceArr.size() > 0) {
	        	        	
		        	serviceTable.addCell(getHeaderCell("Last Service Date"));
		        	serviceTable.addCell(getHeaderCell("Pickup Date"));
		        	serviceTable.addCell(getHeaderCell("Pharmacy Service Type"));
		        	serviceTable.addCell(getHeaderCell("Pharmacy Service Description"));
		        	serviceTable.addCell(getHeaderCell("Pharmacy Name"));
		        	serviceTable.addCell(getHeaderCell("Pharmacist"));
		        	serviceTable.addCell(getHeaderCell("Pharmacy Fax"));        
		        	serviceTable.setHeaderRows(1);
	        
		        for(int i = 0; i < serviceArr.size(); i++) {
		        		JSONObject med = serviceArr.getJSONObject(i);
		        		
		        		
		        		serviceTable.addCell(getItemCell(med.optString("whenPrepared"))); //Dispense Date
		        		serviceTable.addCell(getItemCell(med.optString("whenHandedOver")));  //Generic
		            	JSONObject brandObj = med.getJSONObject("brandName");
		            	serviceTable.addCell(getItemCell( brandObj.optString("display"))); //Brand
		            	serviceTable.addCell(getItemCell(med.optString("genericName")));  //Strength
		            	serviceTable.addCell(getItemCell(med.optString("dispensingPharmacy")));  //Dosage Form
		            	JSONObject pharmacistLicenceNumberObj = med.getJSONObject("pharmacistLicenceNumber");
		            	serviceTable.addCell(getItemCell(med.optString("pharmacistLastname")+", "+med.optString("pharmacistFirstname")+" ("+pharmacistLicenceNumberObj.optString("value")+")"   ));//Prescriber
		            	serviceTable.addCell(getItemCell(med.optString("dispensingPharmacyFaxNumber"))); //Prescriber #
		            	
		        }
	        
	        
	        document.add(serviceTable); 
	        
	        //Paragraph serviceNumResults = new Paragraph("Found " + serviceArr.size() + " Events.",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK));
	        //serviceNumResults.add(Chunk.NEWLINE);
	        //document.add(serviceNumResults);
	        }else {
	        	Paragraph noResults = new Paragraph("No events found for the search time period.",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK));
	        	noResults.add(Chunk.NEWLINE);
	        	document.add(noResults);
	        }
        }
       
        ////service Table end
        
        Paragraph datePrinted = new Paragraph("Printed on " + formatter.format(new Date()) ,FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK));
        datePrinted.add(Chunk.NEWLINE);
        document.add(datePrinted);
        
        
        document.close();
	}
	
	//Utils
	
	private PdfPCell getHeaderCell(String name) {
	    	Font font = FontFactory.getFont(FontFactory.HELVETICA, 9, Font.BOLD, Color.BLACK);     
	        
	    	PdfPCell cell = new PdfPCell(new Phrase(name,font));
	    	cell.setHorizontalAlignment(Element.ALIGN_CENTER);
	    	cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
	    	
	    	return cell;
    }
    
    private PdfPCell getItemCell(String name) {
	    	Font font = FontFactory.getFont(FontFactory.HELVETICA, 9, Font.NORMAL, Color.BLACK);     
	        
	    	PdfPCell cell = new PdfPCell(new Phrase(name,font));
	    	
	    	return cell;
    }
    
    private String getDemoInfo(Demographic demo) {
    	StringBuilder demoInfo = new StringBuilder(demo.getSexDesc()).append(" Age: ").append(demo.getAge()).append(" (").append(demo.getBirthDayAsString()).append(")")
                .append(" HIN: (").append(demo.getHcType()).append(") ").append(demo.getHin()).append(" ").append(demo.getVer());
    	return demoInfo.toString();
       
    }
    
    private Phrase getTitlePhrase(Demographic demo,String title) {
    	 Phrase titlePhrase = new Phrase(16, title, FontFactory.getFont(FontFactory.HELVETICA_BOLD, 20, Font.BOLD, Color.BLACK));
         titlePhrase.add(Chunk.NEWLINE);
         titlePhrase.add(new Chunk(demo.getFormattedName(),FontFactory.getFont(FontFactory.HELVETICA, 14, Font.NORMAL, Color.BLACK)));
         titlePhrase.add(Chunk.NEWLINE);         
         titlePhrase.add(new Chunk(getDemoInfo(demo), FontFactory.getFont(FontFactory.HELVETICA, 12, Font.NORMAL, Color.BLACK)));
         
         return titlePhrase;
    }
    
    private HeaderFooter getHeaderFooter(Demographic demo,String title) {
    	HeaderFooter header = new HeaderFooter(getTitlePhrase(demo,title),false);        
        header.setAlignment(HeaderFooter.ALIGN_RIGHT);
        header.setBorder(Rectangle.BOTTOM);
        
        return header;
    }

	public void printComparative(LoggedInInfo loggedInInfo,Integer demographicNo,OutputStream outputStream,JSONObject jsonOb) throws Exception{
		
		Document document;
	    PdfContentByte cb;
	    
	    Demographic demo = demographicManager.getDemographic(loggedInInfo, demographicNo);
        
        if (demo == null) 
            throw new DocumentException();
		
		document = new Document(); 
        document.setPageSize(PageSize.LETTER);
        
        PdfWriter writer = PdfWriterFactory.newInstance(document, outputStream, FontSettings.HELVETICA_10PT);
        
        HeaderFooter header = getHeaderFooter( demo ,"DHDR Comparative");
        document.setHeader(header);  
        
        
        document.open();
        cb = writer.getDirectContent();

        Paragraph dhrDisclaimerParagraph = new Paragraph("Warning: Limited to Drug and Pharmacy Service Information available in the Digital Health Drug Repository (DHDR) EHR Service. To ensure a Best Possible Medication History (BPMH), please review this information with the patient/family and use other available sources of medication information in addition to the DHDR EHR Service.", FontFactory.getFont(FontFactory.HELVETICA, 9, Font.ITALIC , Color.BLACK));
        dhrDisclaimerParagraph.add(Chunk.NEWLINE);
        document.add(dhrDisclaimerParagraph);
        
        ///
        
        Paragraph emrHeaderParagraph = new Paragraph("DHDR Comparative", FontFactory.getFont(FontFactory.HELVETICA, 12, Font.BOLD | Font.UNDERLINE, Color.BLACK));
        emrHeaderParagraph.add(Chunk.NEWLINE);
        document.add(emrHeaderParagraph);
        //formatter.format(
        Paragraph emrDateRangeParagraph = new Paragraph("Date Range: ", FontFactory.getFont(FontFactory.HELVETICA, 11, Font.BOLD, Color.BLACK));
        emrDateRangeParagraph.add(new Phrase (jsonOb.get("startDate") + " to " + jsonOb.get("endDate"),FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK)));
        emrDateRangeParagraph.add(Chunk.NEWLINE);
        
        document.add(emrDateRangeParagraph);
        
        document.add(Chunk.NEWLINE);
        
        JSONArray arr = jsonOb.getJSONArray("meds");
        Paragraph drugProductParagraph = new Paragraph("DHDR Drugs", FontFactory.getFont(FontFactory.HELVETICA, 11, Font.BOLD, Color.BLACK));
        drugProductParagraph.add(new Phrase ("(Found " + arr.size() + " Events)",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK)));
        drugProductParagraph.add(Chunk.NEWLINE);
        drugProductParagraph.setSpacingAfter(5f);
        document.add(drugProductParagraph);
        
        ///////table
        PdfPTable table = new PdfPTable(13);
        table.setWidthPercentage(100.0f);
        
        
        
        
        if(arr.size() > 0) {
        	
	        table.addCell(getHeaderCell("Dispense Date"));
	        table.addCell(getHeaderCell("Generic"));
	        table.addCell(getHeaderCell("Brand"));
	        table.addCell(getHeaderCell("Strength"));
	        table.addCell(getHeaderCell("Dosage Form"));
	        table.addCell(getHeaderCell("Quantity"));
	        table.addCell(getHeaderCell("Est Days Supply"));
	    		table.addCell(getHeaderCell("Refills Remaining"));        	 
	    		table.addCell(getHeaderCell("Quantity Remaining"));
	        table.addCell(getHeaderCell("Prescriber"));
	        table.addCell(getHeaderCell("Prescriber #"));
	        table.addCell(getHeaderCell("Pharmacy"));
	        table.addCell(getHeaderCell("Pharmacy Fax"));
	        
	        table.setHeaderRows(1);
        
	        for(int i = 0; i < arr.size(); i++) {
	        		JSONObject med = arr.getJSONObject(i);
	        		
	        		table.addCell(getItemCell(med.optString("whenPrepared"))); //Dispense Date
	            	table.addCell(getItemCell(med.optString("genericName")));  //Generic
	            	JSONObject brandObj = med.getJSONObject("brandName");
	            	table.addCell(getItemCell( brandObj.optString("display"))); //Brand
	            	table.addCell(getItemCell(med.optString("dispensedDrugStrength")));  //Strength
	            	table.addCell(getItemCell(med.optString("drugDosageForm")));  //Dosage Form
	            	table.addCell(getItemCell(med.optString("dispensedQuantity"))); //Quantity
	            	table.addCell(getItemCell(med.optString("estimatedDaysSupply"))); //Est Days Supply
	            	table.addCell(getItemCell(med.optString("refillsRemaining")));
	        		table.addCell(getItemCell(med.optString("quantityRemaining")));
	            	JSONObject prescriberLicenceNumberObj = med.getJSONObject("prescriberLicenceNumber");
	            	table.addCell(getItemCell(med.optString("prescriberLastname")+", "+med.optString("prescriberFirstname")+" ("+prescriberLicenceNumberObj.optString("value")+")"   ));//Prescriber
	            	table.addCell(getItemCell(med.optString("prescriberPhoneNumber"))); //Prescriber #
	            	table.addCell(getItemCell(med.optString("dispensingPharmacy"))); //Pharmacy
	            	table.addCell(getItemCell(med.optString("dispensingPharmacyFaxNumber"))); // Pharmacy Fax
	        }
        
        
        document.add(table); 
        
       // Paragraph numResults = new Paragraph("Found " + arr.size() + " Events.",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK));
        //numResults.add(Chunk.NEWLINE);
        //document.add(numResults);
        }else {
        	Paragraph noResults = new Paragraph("No events found for the search time period.",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK));
        	noResults.add(Chunk.NEWLINE);
        	document.add(noResults);
        }
        //////end table
        
        ////service Table

        
        if(jsonOb.containsKey("services")) {
        		JSONArray serviceArr = jsonOb.getJSONArray("services");
        		
        		document.add(Chunk.NEWLINE);
        		
        		Paragraph servicesProductParagraph = new Paragraph("DHDR PharmaServices", FontFactory.getFont(FontFactory.HELVETICA, 11, Font.BOLD, Color.BLACK));
        		servicesProductParagraph.add(new Phrase ("(Found " + serviceArr.size() + " Events)",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK)));
        		servicesProductParagraph.add(Chunk.NEWLINE);
        		servicesProductParagraph.setSpacingAfter(5f);
            document.add(servicesProductParagraph);
            
            
        		
            PdfPTable serviceTable = new PdfPTable(7);
            serviceTable.setWidthPercentage(100.0f);

	        
	        
	        if(serviceArr.size() > 0) {
	        	        	
		        	serviceTable.addCell(getHeaderCell("Last Service Date"));
		        	serviceTable.addCell(getHeaderCell("Pickup Date"));
		        	serviceTable.addCell(getHeaderCell("Pharmacy Service Type"));
		        	serviceTable.addCell(getHeaderCell("Pharmacy Service Description"));
		        	serviceTable.addCell(getHeaderCell("Pharmacy Name"));
		        	serviceTable.addCell(getHeaderCell("Pharmacist"));
		        	serviceTable.addCell(getHeaderCell("Pharmacy #"));        
		        	serviceTable.setHeaderRows(1);
	        
		        for(int i = 0; i < serviceArr.size(); i++) {
		        		JSONObject med = serviceArr.getJSONObject(i);
		        		
		        		
		        		serviceTable.addCell(getItemCell(med.optString("whenPrepared"))); //Dispense Date
		        		serviceTable.addCell(getItemCell(med.optString("whenHandedOver")));  //Generic
		            	JSONObject brandObj = med.getJSONObject("brandName");
		            	serviceTable.addCell(getItemCell( brandObj.optString("display"))); //Brand
		            	serviceTable.addCell(getItemCell(med.optString("genericName")));  //Strength
		            	serviceTable.addCell(getItemCell(med.optString("dispensingPharmacy")));  //Dosage Form
		            	JSONObject pharmacistLicenceNumberObj = med.getJSONObject("pharmacistLicenceNumber");
		            	serviceTable.addCell(getItemCell(med.optString("pharmacistLastname")+", "+med.optString("pharmacistFirstname")+" ("+pharmacistLicenceNumberObj.optString("value")+")"   ));//Prescriber
		            	serviceTable.addCell(getItemCell(med.optString("dispensingPharmacyPhoneNumber"))); //Prescriber #
		            	
		        }
	        
	        
	        document.add(serviceTable); 
	        
	        //Paragraph serviceNumResults = new Paragraph("Found " + serviceArr.size() + " Events.",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK));
	        //serviceNumResults.add(Chunk.NEWLINE);
	        //document.add(serviceNumResults);
	        }else {
	        	Paragraph noResults = new Paragraph("No events found for the search time period.",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK));
	        	noResults.add(Chunk.NEWLINE);
	        	document.add(noResults);
	        }
        }
       
        ////service Table end
        
        
        ////local Table

        
        if(jsonOb.containsKey("localData")) {
        		JSONArray localArr = jsonOb.getJSONArray("localData");
        		
        		document.add(Chunk.NEWLINE);
        		
        		Paragraph servicesProductParagraph = new Paragraph("EMR Prescriptions", FontFactory.getFont(FontFactory.HELVETICA, 11, Font.BOLD, Color.BLACK));
        		servicesProductParagraph.add(new Phrase ("(Found " + localArr.size() + " Events)",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK)));
        		servicesProductParagraph.add(Chunk.NEWLINE);
        		servicesProductParagraph.setSpacingAfter(5f);
            document.add(servicesProductParagraph);
            
            
        		
            PdfPTable localTable = new PdfPTable(4);
            localTable.setWidthPercentage(100.0f);

	        
	        
	        if(localArr.size() > 0) {
	   
		        	localTable.addCell(getHeaderCell("Start Date"));
		        	localTable.addCell(getHeaderCell("Medication"));
		        	localTable.addCell(getHeaderCell("Prescriber"));
		        	localTable.addCell(getHeaderCell("DIN"));     
		        	localTable.setHeaderRows(1);
	        
		        for(int i = 0; i < localArr.size(); i++) {
		        		JSONObject med = localArr.getJSONObject(i);
		        		localTable.addCell(getItemCell(med.optString("rxDate"))); //Dispense Date
		        		localTable.addCell(getItemCell(med.optString("instructions")));  //Generic
		        		localTable.addCell(getItemCell(med.optString("providerName")));  //Strength
		        		localTable.addCell(getItemCell(med.optString("regionalIdentifier")));  //Dosage Form
		        }
	        
	        
	        document.add(localTable); 
	        
	        }else {
	        	Paragraph noResults = new Paragraph("No events found for the search time period.",FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK));
	        	noResults.add(Chunk.NEWLINE);
	        	document.add(noResults);
	        }
        }
       
        ////local Table end
        
        
        
        Paragraph datePrinted = new Paragraph("Printed on " + formatter.format(new Date()) ,FontFactory.getFont(FontFactory.HELVETICA, 11, Font.NORMAL, Color.BLACK));
        datePrinted.add(Chunk.NEWLINE);
        document.add(datePrinted);
        
        
        document.close();
	}

}
