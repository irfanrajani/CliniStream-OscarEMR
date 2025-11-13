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
package org.oscarehr.fax.util;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Locale;
import java.util.ResourceBundle;

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.BaseFont;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.Rectangle;

import org.oscarehr.common.dao.ClinicDAO;
import org.oscarehr.common.dao.ProfessionalSpecialistDao;
import org.oscarehr.common.model.Clinic;
import org.oscarehr.common.model.ProfessionalSpecialist;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

public class PdfCoverPageCreator {
	
	private String note;

	public PdfCoverPageCreator(String note) {
		this.note = note;		
	}
	
	public byte[] createCoverPage() {
		byte[] bte = createCoverPage(null);
		return bte;
	}

	public byte[] createCoverPage(String specialistId) {
        Document document = new Document();
        document.setPageSize(new Rectangle(PageSize.LETTER));
		ByteArrayOutputStream os = new ByteArrayOutputStream();
		ResourceBundle oscarRec = ResourceBundle.getBundle("oscarResources", Locale.getDefault());	
		
		String faxno = oscarRec.getString("global.fax.faxno");
		String to = oscarRec.getString("oscarMessenger.DisplayMessages.msgTo");
		String footer = oscarRec.getString("oscarEncounter.oscarConsultationRequest.consultationFormPrint.msgFaxFooterMessage");
		String phone = oscarRec.getString("oscarEncounter.oscarConsultationRequest.ConsultationFormRequest.formPhone");
		String fax = oscarRec.getString("oscarEncounter.oscarConsultationRequest.ConsultationFormRequest.formFax");	
		String labelnote = oscarRec.getString("caseload.msgNotes");
		
		try {
			
	        PdfWriter pdfWriter = PdfWriter.getInstance(document, os);
	        document.open();
	        
	        PdfPTable table = new PdfPTable(1);
	        table.setWidthPercentage(95);
	        
	        PdfPCell cell = new PdfPCell(table);
	        cell.setBorder(0);
	        cell.setPadding(3);
			cell.setColspan(1);
			table.addCell(cell);
			
			ClinicDAO clinicDao = SpringUtils.getBean(ClinicDAO.class);
			Clinic clinic = clinicDao.getClinic();
			BaseFont bf = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.CP1252,
					BaseFont.NOT_EMBEDDED);
			Font headerFont = new Font(bf, 28, Font.BOLD);
			Font headerMediumFont = new Font(bf, 16, Font.BOLD);
			Font infoFont = new Font(bf, 12, Font.NORMAL);
						
			if( clinic != null ) {							
				
				cell = new PdfPCell();
				cell.addElement(new Phrase(String.format("%s\n",
						   clinic.getClinicName()), headerFont));		
				cell.addElement(new Phrase(String.format("%s, %s, %s %s\n",
					 	   clinic.getClinicAddress(),  clinic.getClinicCity(),
						   clinic.getClinicProvince(), 
						   clinic.getClinicPostal()), headerMediumFont));
				cell.addElement(new Phrase(String.format("%s: %s, %s: %s\n", 
					 	   oscarRec.getString("oscarEncounter.oscarConsultationRequest.ConsultationFormRequest.formPhone"),
					 	   clinic.getClinicPhone(),
						   oscarRec.getString("oscarEncounter.oscarConsultationRequest.ConsultationFormRequest.formFax"),
					 	   clinic.getClinicFax()), headerMediumFont));	
			} else {
				
				cell = new PdfPCell(new Phrase("OSCAR", headerFont));
			
			}
			
			cell.setPaddingTop(40);
			cell.setPaddingLeft(25);
			cell.setPaddingBottom(25);
			cell.setBorderWidthBottom(1);
			table.addCell(cell);

			PdfPTable infoTable = new PdfPTable(1);
			
			cell = new PdfPCell();
			cell.addElement(new Phrase(fax,headerFont));
			
            if (specialistId != null && !specialistId.isEmpty()) {
                ProfessionalSpecialistDao professionalSpecialistDao = SpringUtils.getBean(ProfessionalSpecialistDao.class);
                ProfessionalSpecialist specialist = professionalSpecialistDao.find(Integer.parseInt(specialistId));
                if (specialist != null) {
                    String clinicInfo = "\n\n"+ to + ": " + specialist.getFormattedTitle() + "\n" +
                            phone + ": " + specialist.getPhoneNumber() + "\n" +
                            fax + ": " + specialist.getFaxNumber() + "\n\n\n";
                    cell.addElement(new Phrase(clinicInfo, infoFont));
                }
            }
			cell.addElement(new Phrase(labelnote,headerMediumFont));
			cell.addElement(new Phrase(note,infoFont));
			cell.setPaddingTop(25);
			cell.setPaddingBottom(25);
			cell.setPaddingLeft(25);
			cell.setBorder(0);
			cell.setMinimumHeight(400f); //about 5.5"
			infoTable.addCell(cell);
			table.addCell(infoTable);
			
			
			cell = new PdfPCell(new Phrase(footer,infoFont));
			cell.setPaddingTop(25);
			cell.setPaddingLeft(25);
			cell.setBorderWidth(1);
			table.addCell(cell);		
			
			document.add(table);
			
	        
        } catch (DocumentException e) {
	        
        	MiscUtils.getLogger().error("PDF COVER PAGE ERROR",e);
	        return new byte[] {};
	        
        }catch( IOException e ) {
        	
        	MiscUtils.getLogger().error("PDF COVER PAGE ERROR",e);
	        return new byte[] {};
	        
        }
		finally {
			document.close();
		}
		
		return os.toByteArray();
	}


}
