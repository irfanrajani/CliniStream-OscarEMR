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

package org.oscarehr.managers;

import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.Logger;
import org.oscarehr.PMmodule.model.ProgramProvider;
import org.oscarehr.PMmodule.service.AdmissionManager;
import org.oscarehr.PMmodule.service.ProgramManager;
import org.oscarehr.casemgmt.dao.CaseManagementNoteDAO;
import org.oscarehr.casemgmt.dao.IssueDAO;
import org.oscarehr.casemgmt.model.CaseManagementCPP;
import org.oscarehr.casemgmt.model.CaseManagementIssue;
import org.oscarehr.casemgmt.model.CaseManagementNote;
import org.oscarehr.casemgmt.model.CaseManagementNoteExt;
import org.oscarehr.casemgmt.model.Issue;
import org.oscarehr.casemgmt.service.CaseManagementManager;
import org.oscarehr.common.dao.CaseManagementIssueNotesDao;
import org.oscarehr.common.model.Provider;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.oscarehr.ws.rest.conversion.CaseManagementIssueConverter;
import org.oscarehr.ws.rest.to.model.CaseManagementIssueTo1;
import org.oscarehr.ws.rest.to.model.IssueTo1;
import org.oscarehr.ws.rest.to.model.NoteExtTo1;
import org.oscarehr.ws.rest.to.model.NoteIssueTo1;
import org.oscarehr.ws.rest.to.model.NoteTo1;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;

@Service
public class NoteManager {

    public static String cppCodes[] = {"OMeds", "SocHistory", "MedHistory", "Concerns", "FamHistory", "Reminders", "RiskFactors","OcularMedication","TicklerNote"};

    private static Logger logger = MiscUtils.getLogger();

    @Autowired
    private CaseManagementManager caseManagementManager;

    @Autowired
    private ProgramManager2 programManager2;
    
    @Autowired
    private ProgramManager programManager;

    @Autowired
    private IssueDAO issueDao;
    
    @Autowired
    private CaseManagementNoteDAO caseManagementNoteDAO;

    //moved over from NotesService.Java:saveNote()
    public NoteTo1 saveNote(LoggedInInfo loggedInInfo, Integer demographicNo, NoteTo1 note){
        logger.debug("saveNote "+note);
        String providerNo=loggedInInfo.getLoggedInProviderNo();
        Provider provider = loggedInInfo.getLoggedInProvider();
        String userName = provider != null ? provider.getFullName() : "";

        AdmissionManager admissionManager = (AdmissionManager) SpringUtils.getBean("admissionManager");
        String programId = getProgram(loggedInInfo,providerNo);

        String demo = ""+demographicNo;

        CaseManagementNote caseManagementNote  = new CaseManagementNote();

        caseManagementNote.setDemographic_no(demo);
        caseManagementNote.setProvider(provider);
        caseManagementNote.setProviderNo(providerNo);

        if(note.getUuid() != null && !note.getUuid().trim().equals("")){
            CaseManagementNote mostRecent = caseManagementManager.getMostRecentNote(note.getUuid());
            
            if(mostRecent == null || mostRecent.getDemographic_no().equals(demo)) {
                caseManagementNote.setUuid(note.getUuid());
            }
        }

        String noteTxt = note.getNote();
        noteTxt = StringUtils.trimToNull(noteTxt);
        if (noteTxt == null || noteTxt.equals("")) return null;

        caseManagementNote.setNote(noteTxt);

        CaseManagementCPP cpp = this.caseManagementManager.getCPP(demo);
        if (cpp == null) {
            cpp = new CaseManagementCPP();
            cpp.setDemographic_no(demo);
        }
        if(note.isCpp() && note.getSummaryCode()!=null){
            StringBuilder summaryCode = new StringBuilder(note.getSummaryCode());
            for(CaseManagementIssueTo1 cmIssue : note.getAssignedIssues()){
                if(cmIssue.getIssue() != null){
                    summaryCode.append((summaryCode.toString().equals("") ? "" : ", "));
                    summaryCode.append(cmIssue.getIssue().getCode());
                }
            }
            cpp = copyNote2cpp(cpp, note.getNote(), summaryCode.toString());
        }
        
        logger.debug("enc TYPE " +note.getEncounterType());
        caseManagementNote.setEncounter_type(note.getEncounterType());

        logger.debug("this is what the encounter time was "+note.getEncounterTime());

        logger.debug("this is what the encounter time was "+note.getEncounterTransportationTime());
		
        //Need to check some how that if a note is signed that it must stay signed, currently this is done in the interface where the save button is not available.
        if(note.getIsSigned()){
            caseManagementNote.setSigning_provider_no(providerNo);
            caseManagementNote.setSigned(true);
        } else {
            caseManagementNote.setSigning_provider_no("");
            caseManagementNote.setSigned(false);
        }

        caseManagementNote.setProviderNo(providerNo);
        if (provider != null) caseManagementNote.setProvider(provider);

        String programIdString = getProgram(loggedInInfo,providerNo); //might not to convert it.
        caseManagementNote.setProgram_no(programIdString);

        List<CaseManagementIssue> issuelist = new ArrayList<CaseManagementIssue>();

        for(CaseManagementIssueTo1 i:note.getAssignedIssues()) {
            if(!i.isUnchecked()) {
                CaseManagementIssue cmi = i.getIssue() != null ? caseManagementManager.getIssueByIssueCode(demo, i.getIssue().getCode()) : caseManagementManager.getIssueById(demo, "" + i.getIssue_id());
                if(cmi != null) {
                    //update
                } else {
                    //new one
                    cmi = new CaseManagementIssue();
                    Issue is = i.getIssue() != null ? issueDao.findIssueByCode(i.getIssue().getCode()) : issueDao.getIssue(i.getIssue_id());
                    cmi.setIssue_id(is.getId());
                    cmi.setIssue(is);
                    cmi.setProgram_id(programManager2.getCurrentProgramInDomain(loggedInInfo, loggedInInfo.getLoggedInProviderNo()).getProgramId().intValue());
                    cmi.setType(is.getRole());
                    cmi.setDemographic_no(Integer.valueOf(demo));
                }

                cmi.setAcute(i.isAcute());
                cmi.setCertain(i.isCertain());
                cmi.setMajor(i.isMajor());
                cmi.setResolved(i.isResolved());
                cmi.setUpdate_date(new Date());

                issuelist.add(cmi);
                caseManagementManager.saveCaseIssue(cmi);
            }
        }

        caseManagementNote.setIssues(new HashSet<CaseManagementIssue>(issuelist));
        
        String noteString = note.getNote();
        caseManagementNote.setNote(noteString);
        
        // update password
        Date now = new Date();

        Date observationDate = note.getObservationDate();
        if (observationDate != null && !observationDate.equals("")) {
            if (observationDate.getTime() > now.getTime()) {
                caseManagementNote.setObservation_date(now);
            } else{
                caseManagementNote.setObservation_date(observationDate);
            }
        } else {
            caseManagementNote.setObservation_date(now);
        }

        caseManagementNote.setUpdate_date(now);

        if (note.getAppointmentNo() != null) {
            caseManagementNote.setAppointmentNo(note.getAppointmentNo());
        }

        String role;
        String team;

        try {
            role = String.valueOf((programManager.getProgramProvider(providerNo, programId)).getRole().getId());
        } catch (Exception e) {
            logger.error("Error", e);
            role = "0";
        }

        caseManagementNote.setReporter_caisi_role(role);

        try {
            team = String.valueOf((admissionManager.getAdmission(programId, demographicNo)).getTeamId());
        } catch (Exception e) {
            logger.error("Error", e);
            team = "0";
        }
        caseManagementNote.setReporter_program_team(team);
        
        caseManagementManager.saveNote(cpp, caseManagementNote, providerNo, userName, null, note.getRoleName());
        caseManagementManager.saveCPP(cpp, providerNo);

        caseManagementManager.getEditors(caseManagementNote);
        
        if(note.getNoteExt() != null) {
            /* save extra fields */
            NoteExtTo1 noteExt = note.getNoteExt();
            CaseManagementNoteExt cme = new CaseManagementNoteExt();
            Long newNoteId = caseManagementNote.getId();

            if (noteExt.getStartDate() != null) {
                cme.setNoteId(newNoteId);
                cme.setKeyVal(NoteExtTo1.STARTDATE);
                cme.setDateValue(noteExt.getStartDate());
                caseManagementManager.saveNoteExt(cme);
            }

            if (noteExt.getResolutionDate() != null) {
                cme.setNoteId(newNoteId);
                cme.setKeyVal(NoteExtTo1.RESOLUTIONDATE);
                cme.setDateValue(noteExt.getResolutionDate());
                caseManagementManager.saveNoteExt(cme);
            }

            if (noteExt.getProcedureDate() != null) {
                cme.setNoteId(newNoteId);
                cme.setKeyVal(NoteExtTo1.PROCEDUREDATE);
                cme.setDateValue(noteExt.getProcedureDate());
                caseManagementManager.saveNoteExt(cme);
            }

            if (noteExt.getAgeAtOnset() != null) {
                cme.setNoteId(newNoteId);
                cme.setKeyVal(NoteExtTo1.AGEATONSET);
                cme.setDateValue((Date) null);
                cme.setValue(noteExt.getAgeAtOnset());
                caseManagementManager.saveNoteExt(cme);
            }

            if (noteExt.getTreatment() != null) {
                cme.setNoteId(newNoteId);
                cme.setKeyVal(NoteExtTo1.TREATMENT);
                cme.setDateValue((Date) null);
                cme.setValue(noteExt.getTreatment());
                caseManagementManager.saveNoteExt(cme);
            }

            if (noteExt.getProblemStatus() != null) {
                cme.setNoteId(newNoteId);
                cme.setKeyVal(NoteExtTo1.PROBLEMSTATUS);
                cme.setDateValue((Date) null);
                cme.setValue(noteExt.getProblemStatus());
                caseManagementManager.saveNoteExt(cme);
            }

            if (noteExt.getExposureDetail() != null) {
                cme.setNoteId(newNoteId);
                cme.setKeyVal(NoteExtTo1.EXPOSUREDETAIL);
                cme.setDateValue((Date) null);
                cme.setValue(noteExt.getExposureDetail());
                caseManagementManager.saveNoteExt(cme);
            }

            if (noteExt.getRelationship() != null) {
                cme.setNoteId(newNoteId);
                cme.setKeyVal(NoteExtTo1.RELATIONSHIP);
                cme.setDateValue((Date) null);
                cme.setValue(noteExt.getRelationship());
                caseManagementManager.saveNoteExt(cme);
            }

            if (noteExt.getLifeStage() != null) {
                cme.setNoteId(newNoteId);
                cme.setKeyVal(NoteExtTo1.LIFESTAGE);
                cme.setDateValue((Date) null);
                cme.setValue(noteExt.getLifeStage());
                caseManagementManager.saveNoteExt(cme);
            }

            if (noteExt.getHideCpp() != null) {
                cme.setNoteId(newNoteId);
                cme.setKeyVal(NoteExtTo1.HIDECPP);
                cme.setDateValue((Date) null);
                cme.setValue(noteExt.getHideCpp());
                caseManagementManager.saveNoteExt(cme);
            }

            if (noteExt.getProblemDesc() != null) {
                cme.setNoteId(newNoteId);
                cme.setKeyVal(NoteExtTo1.PROBLEMDESC);
                cme.setDateValue((Date) null);
                cme.setValue(noteExt.getProblemDesc());
                caseManagementManager.saveNoteExt(cme);
            }

            /* save extra fields */
        }
        
        note.setNoteId(Integer.parseInt(""+caseManagementNote.getId()));
        note.setUuid(caseManagementNote.getUuid());
        note.setUpdateDate(caseManagementNote.getUpdate_date());
        note.setObservationDate(caseManagementNote.getObservation_date());
        logger.error("note should return like this " + note.getNote() );
        return note;
    }
    
    //moved over from NoteService.Java:saveIssueNote()
    public NoteIssueTo1 saveIssueNote(LoggedInInfo loggedInInfo, Integer demographicNo, NoteIssueTo1 noteIssue){
        NoteTo1 note = noteIssue.getEncounterNote();
        NoteExtTo1 noteExt = noteIssue.getGroupNoteExt();
        IssueTo1 issue = noteIssue.getIssue();
        List<CaseManagementIssueTo1> assignedCMIssues = noteIssue.getAssignedCMIssues();

        String providerNo=loggedInInfo.getLoggedInProviderNo();
        Provider provider = loggedInInfo.getLoggedInProvider();
        String userName = provider != null ? provider.getFullName() : "";

        String demo = ""+demographicNo;
        String noteId = String.valueOf(note.getNoteId());

        String programId = getProgram(loggedInInfo,providerNo);

        CaseManagementNote caseMangementNote  = new CaseManagementNote();
        boolean newNote = false;

        // we don't want to try to remove an issue from a new note so we test here
        if(note.getNoteId()==null || note.getNoteId()==0){
            newNote = true;
        }else{
            boolean extChanged = true; //false
            // if note has not changed don't save
            caseManagementManager.getNote(noteId);
            if ( note.getNote().equals(note.getNote()) && issue.isIssueChange() && !extChanged && note.isArchived() ) return null;
        }

        caseMangementNote.setDemographic_no(demo);

        if(!newNote) {
            if (note.isArchived() ){
                caseMangementNote.setArchived(true);
            }
            note.setRevision(Integer.parseInt(note.getRevision())+1 + "");
        }


        if(note.getUuid() != null && !note.getUuid().trim().equals("")){
            caseMangementNote.setUuid(note.getUuid());
        }

        String noteTxt = note.getNote();
        noteTxt = org.apache.commons.lang.StringUtils.trimToNull(noteTxt);
        if (noteTxt == null || noteTxt.equals("")) return null;

        caseMangementNote.setNote(noteTxt);

        CaseManagementCPP cpp = this.caseManagementManager.getCPP(demo);
        if (cpp == null) {
            cpp = new CaseManagementCPP();
            cpp.setDemographic_no(demo);
        }

        if(note.isCpp() && note.getSummaryCode()!=null){
            cpp = copyNote2cpp(cpp, note.getNote(), note.getSummaryCode());
        }

        ProgramManager programManager = (ProgramManager) SpringUtils.getBean("programManager");
        AdmissionManager admissionManager = (AdmissionManager) SpringUtils.getBean("admissionManager");

        String role = null;
        String team = null;

        try {
            role = String.valueOf((programManager.getProgramProvider(providerNo, programId)).getRole().getId());
        } catch (Exception e) {
            logger.error("Error", e);
            role = "0";
        }

        caseMangementNote.setReporter_caisi_role(role);

        try {
            team = String.valueOf((admissionManager.getAdmission(programId, demographicNo)).getTeamId());
        } catch (Exception e) {
            logger.error("Error", e);
            team = "0";
        }
        caseMangementNote.setReporter_program_team(team);

        //Need to check some how that if a note is signed that it must stay signed, currently this is done in the interface where the save button is not available.
        if(note.getIsSigned()){
            caseMangementNote.setSigning_provider_no(providerNo);
            caseMangementNote.setSigned(true);
        } else {
            caseMangementNote.setSigning_provider_no("");
            caseMangementNote.setSigned(false);
        }

        caseMangementNote.setProviderNo(providerNo);
        if (provider != null) caseMangementNote.setProvider(provider);


        caseMangementNote.setProgram_no(programId);

        //this code basically updates the CPP note with which issues were removed
        if(!newNote) {
            List<String> removedIssueNames = new ArrayList<String>();
            for(CaseManagementIssueTo1 cmit : assignedCMIssues) {
                if(cmit.isUnchecked() && cmit.getId() != null && cmit.getId().longValue()>0) {
                    //we want to remove this association, and append to the note
                    removedIssueNames.add(cmit.getIssue().getDescription());
                }
            }

            if(!removedIssueNames.isEmpty()) {
                String text =  new SimpleDateFormat("dd-MMM-yyyy").format(new Date()) + " " + "Removed following issue(s)" + ":\n" + StringUtils.join(removedIssueNames, ",");
                caseMangementNote.setNote(caseMangementNote.getNote() + "\n" + text);
            }
        }
        
        List<CaseManagementIssue> issuelist = new ArrayList<CaseManagementIssue>();

        for(CaseManagementIssueTo1 i:assignedCMIssues) {
            if(!i.isUnchecked()) {
                CaseManagementIssue cmi = caseManagementManager.getIssueByIssueCode(demo, i.getIssue().getCode());
                if (cmi==null) {
                    //new one
                    cmi = new CaseManagementIssue();
                    Issue is = issueDao.getIssue(i.getIssue().getId());
                    cmi.setIssue_id(is.getId());
                    cmi.setIssue(is);
                    cmi.setProgram_id(programManager2.getCurrentProgramInDomain(loggedInInfo, loggedInInfo.getLoggedInProviderNo()).getProgramId().intValue());
                    cmi.setType(is.getRole());
                    cmi.setDemographic_no(Integer.valueOf(demo));
                }
                cmi.setAcute(i.isAcute());
                cmi.setCertain(i.isCertain());
                cmi.setMajor(i.isMajor());
                cmi.setResolved(i.isResolved());

                issuelist.add(cmi);
                caseManagementManager.saveCaseIssue(cmi);
            }
        }

        //this is actually just the issue for the main note
        //translate summary codes
        String issueCode = note.getSummaryCode() != null ? note.getSummaryCode() : "";
        issueCode = issueCode.replaceAll("ongoingconcerns", "Concerns");
        issueCode = issueCode.replaceAll("medhx", "MedHistory");
        issueCode = issueCode.replaceAll("reminders", "Reminders");
        issueCode = issueCode.replaceAll("othermeds", "OMeds");
        issueCode = issueCode.replaceAll("sochx", "SocHistory");
        issueCode = issueCode.replaceAll("famhx", "FamHistory");
        issueCode = issueCode.replaceAll("riskfactors", "RiskFactors");

        List<String> issueCodes = new ArrayList<>();
        for(String code: issueCode.split(",")) {
            //cIssue2 will be loaded with existing CaseManagementIssue if there is one for this patient
            code = code.trim();
            Issue cppIssue = caseManagementManager.getIssueInfoByCode(code);
            
            CaseManagementIssue cIssue;
            if(cppIssue != null) {
                cIssue = caseManagementManager.getIssueByIssueCode(demo, code);

                //no issue existing for this type of CPP note..create and save it
                if (cIssue == null) {
                    Date creationDate = new Date();

                    cIssue = new CaseManagementIssue();
                    cIssue.setAcute(false);
                    cIssue.setCertain(false);
                    cIssue.setDemographic_no(Integer.valueOf(demo));
                    cIssue.setIssue_id(cppIssue.getId());
                    cIssue.setMajor(false);
                    cIssue.setProgram_id(Integer.parseInt(programId));
                    cIssue.setResolved(false);
                    cIssue.setType(cppIssue.getRole());
                    cIssue.setUpdate_date(creationDate);

                    caseManagementManager.saveCaseIssue(cIssue);
                }

                //save the associations
                issuelist.add(cIssue);
            }
        }
        note.setIssues(new HashSet<CaseManagementIssue>(issuelist));
        caseMangementNote.setIssues(new HashSet<CaseManagementIssue>(issuelist));


        Date now = new Date();

        Date observationDate = note.getObservationDate();
        if (observationDate != null && !observationDate.equals("")) {
            if (observationDate.getTime() > now.getTime()) {
                caseMangementNote.setObservation_date(now);
            } else {
                caseMangementNote.setObservation_date(observationDate);
            }
        } else if (note.getObservationDate() == null) {
            caseMangementNote.setObservation_date(now);
        }

        caseMangementNote.setUpdate_date(now);
        if(note.getAppointmentNo() != null) {
            caseMangementNote.setAppointmentNo(note.getAppointmentNo());
        }


        //update positions
        /*
         * There's a few cases to handle, but basically when user is adding, editing, or archiving,
         * we go and set the positions so it's always 1,2,..,n across the group note. Archived notes,
         * and older notes (not the latest based on uuid/id) have positions set to 0
         */
        List<CaseManagementNote> curCPPNotes = this.caseManagementManager.getActiveNotes(demo, issueCodes.toArray(new String[0]));
        Collections.sort(curCPPNotes,CaseManagementNote.getPositionComparator());


        if(note.isArchived()) {
            //this one will basically assign 1,2,3,..,n to the group and ignore the one to be archived..setting it's position to 0
            int positionToAssign=1;
            for(int x=0;x<curCPPNotes.size();x++) {
                if(curCPPNotes.get(x).getUuid().equals(note.getUuid())) {
                    curCPPNotes.get(x).setPosition(0);
                    caseManagementManager.updateNote(curCPPNotes.get(x));
                    continue;
                }
                curCPPNotes.get(x).setPosition(positionToAssign);
                caseManagementManager.updateNote(curCPPNotes.get(x));
                positionToAssign++;
            }

        } else {
            List<CaseManagementNote> curCPPNotes2 = new ArrayList<CaseManagementNote>();
            for(CaseManagementNote cn:curCPPNotes) {
                if(!cn.getUuid().equals(note.getUuid())) {
                    curCPPNotes2.add(cn);
                } else {
                    cn.setPosition(0);
                    caseManagementManager.updateNote(cn);
                }
            }
            //we make a fake CaseManagementNoteEntry into curCPPNotes, and insert it into desired location. 
            //we then just set the positions to 1,2,...,n ignoring the fake one, but still incrementing the positionToAssign variable
            //when the new note is saved.it will have the missing position.
            int positionToAssign=1;
            CaseManagementNote xn = new CaseManagementNote();
            xn.setId(-1L);
            if(note.getPosition() > 0 || note.getPosition() < curCPPNotes2.size()) {
                curCPPNotes2.add(note.getPosition() - 1, xn);
            }
            for(int x=0;x<curCPPNotes2.size();x++) {
                if(curCPPNotes2.get(x).getId() != -1L) {
                    //update the note
                    curCPPNotes2.get(x).setPosition(positionToAssign);
                    caseManagementManager.updateNote(curCPPNotes2.get(x));
                }
                if(curCPPNotes2.get(x).getId() != -1L && curCPPNotes2.get(x).getUuid().equals(note.getUuid())) {
                    curCPPNotes2.get(x).setPosition(0);
                    caseManagementManager.updateNote(curCPPNotes2.get(x));
                    positionToAssign--;
                }
                positionToAssign++;
            }
        }
        if(!note.isArchived()) {
            caseMangementNote.setPosition(note.getPosition());
        }
        
        String savedStr = caseManagementManager.saveNote(cpp, caseMangementNote, providerNo, userName, null, note.getRoleName());
        caseManagementManager.saveCPP(cpp, providerNo);

        caseManagementManager.getEditors(caseMangementNote);
        
        note.setNoteId(Integer.parseInt(""+caseMangementNote.getId()));
        note.setUuid(caseMangementNote.getUuid());
        note.setUpdateDate(caseMangementNote.getUpdate_date());
        note.setObservationDate(caseMangementNote.getObservation_date());
        logger.debug("note should return like this " + note.getNote() );
        
        long newNoteId =  Long.valueOf(note.getNoteId());

        logger.debug("ISSUES LIST START for note " + newNoteId);
        CaseManagementIssueNotesDao cmeIssueNotesDao = (CaseManagementIssueNotesDao) SpringUtils.getBean("caseManagementIssueNotesDao");
        List<CaseManagementIssue> issuesList = cmeIssueNotesDao.getNoteIssues(note.getNoteId());
        for (CaseManagementIssue issueItem : issuesList) {
            logger.debug("ISSUES LIST " + issueItem + " for note " + newNoteId);
        }

        if(note.getNoteId()!=0){
            caseManagementManager.addNewNoteLink(newNoteId);
        }

        /* save extra fields */
        CaseManagementNoteExt cme = new CaseManagementNoteExt();

        if(noteExt.getStartDate()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.STARTDATE);
            cme.setDateValue(noteExt.getStartDate());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getResolutionDate()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.RESOLUTIONDATE);
            cme.setDateValue(noteExt.getResolutionDate());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getProcedureDate()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.PROCEDUREDATE);
            cme.setDateValue(noteExt.getProcedureDate());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getAgeAtOnset()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.AGEATONSET);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getAgeAtOnset());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getTreatment()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.TREATMENT);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getTreatment());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getProblemStatus()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.PROBLEMSTATUS);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getProblemStatus());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getExposureDetail()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.EXPOSUREDETAIL);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getExposureDetail());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getRelationship()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.RELATIONSHIP);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getRelationship());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getLifeStage()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.LIFESTAGE);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getLifeStage());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getHideCpp()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.HIDECPP);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getHideCpp());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getProblemDesc()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.PROBLEMDESC);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getProblemDesc());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getProcedure()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.PROCEDURE);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getProcedure());
            caseManagementManager.saveNoteExt(cme);
        }

        /* save extra fields */
        noteIssue.setEncounterNote(note);
        noteIssue.setGroupNoteExt(noteExt);

        return noteIssue;

    }
    
    public List<NoteTo1> getCppNotes(LoggedInInfo loggedInInfo, Integer demographicNo){
        List<CaseManagementNote> notes = new ArrayList<>(caseManagementNoteDAO.findNotesByDemographicAndIssueCode(demographicNo, cppCodes));
        List<NoteTo1> noteTo1s = new ArrayList<>();
        for(CaseManagementNote note : notes){
            noteTo1s.add(convertNote(loggedInInfo, note));
        }
        return noteTo1s;
    }
    
    public NoteTo1 convertNote(LoggedInInfo loggedInInfo, CaseManagementNote caseManagementNote){
        NoteTo1 note = new NoteTo1();
        note.setNoteId(caseManagementNote.getId().intValue());
        note.setIsSigned(caseManagementNote.isSigned());
        note.setRevision(caseManagementNote.getRevision());
        note.setObservationDate(caseManagementNote.getObservation_date());
        note.setUpdateDate(caseManagementNote.getUpdate_date());
        note.setProviderName(caseManagementNote.getProviderName());
        note.setProviderNo(caseManagementNote.getProviderNo());
        note.setStatus(caseManagementNote.getStatus());
        note.setProgramName(caseManagementNote.getProgramName());
        note.setRoleName(caseManagementNote.getRoleName());
        note.setUuid(caseManagementNote.getUuid());
        note.setHasHistory(caseManagementNote.getHasHistory());
        note.setLocked(caseManagementNote.isLocked());
        note.setNote(caseManagementNote.getNote());
        note.setRxAnnotation(caseManagementNote.isRxAnnotation());
        note.setEncounterType(caseManagementNote.getEncounter_type());
        note.setPosition(caseManagementNote.getPosition());
        note.setAppointmentNo(caseManagementNote.getAppointmentNo());
        note.setCpp(false);
        
        //get all note extra values	
        List<CaseManagementNoteExt> lcme = new ArrayList<CaseManagementNoteExt>();
        lcme.addAll(caseManagementManager.getExtByNote( caseManagementNote.getId() ));

        NoteExtTo1 noteExt = new NoteExtTo1();
        noteExt.setNoteId( caseManagementNote.getId() );

        for(CaseManagementNoteExt l : lcme){
            logger.debug("NOTE EXT KEY:" +l.getKeyVal() + l.getValue());

            if(l.getKeyVal().equals(CaseManagementNoteExt.STARTDATE)){
                noteExt.setStartDate(l.getDateValueStr());
            }else if(l.getKeyVal().equals(CaseManagementNoteExt.RESOLUTIONDATE)){
                noteExt.setResolutionDate(l.getDateValueStr());
            }else if(l.getKeyVal().equals(CaseManagementNoteExt.PROCEDUREDATE)){
                noteExt.setProcedureDate(l.getDateValueStr());
            }else if(l.getKeyVal().equals(CaseManagementNoteExt.AGEATONSET)){
                noteExt.setAgeAtOnset(l.getValue());
            }else if(l.getKeyVal().equals(CaseManagementNoteExt.TREATMENT)){
                noteExt.setTreatment(l.getValue());
            }else if(l.getKeyVal().equals(CaseManagementNoteExt.PROBLEMSTATUS)){
                noteExt.setProblemStatus(l.getValue());
            }else if(l.getKeyVal().equals(CaseManagementNoteExt.EXPOSUREDETAIL)){
                noteExt.setExposureDetail(l.getValue());
            }else if(l.getKeyVal().equals(CaseManagementNoteExt.RELATIONSHIP)){
                noteExt.setRelationship(l.getValue());
            }else if(l.getKeyVal().equals(CaseManagementNoteExt.LIFESTAGE)){
                noteExt.setLifeStage(l.getValue());
            }else if(l.getKeyVal().equals(CaseManagementNoteExt.HIDECPP)){
                noteExt.setHideCpp(l.getValue());
            }else if(l.getKeyVal().equals(CaseManagementNoteExt.PROBLEMDESC)){
                noteExt.setProblemDesc(l.getValue());
            }

        }
        
        List<CaseManagementIssue> cmIssues = new ArrayList<CaseManagementIssue>(caseManagementNote.getIssues());
        
        StringBuilder summaryCodes = new StringBuilder();
        for(CaseManagementIssue issue : cmIssues) {
            if(isCppCode(issue)) {
                note.setCpp(true);
            }
            summaryCodes.append((summaryCodes.toString().isEmpty()? "" : ", ") + issue.getIssue().getCode());
        }
        
        note.setSummaryCode(summaryCodes.toString());
        note.setNoteExt(noteExt);
        note.setAssignedIssues(new CaseManagementIssueConverter().getAllAsTransferObjects(loggedInInfo, cmIssues));
        
        return note;
    }

    public boolean isCppCode(CaseManagementIssue cmeIssue) {
        return Arrays.asList(cppCodes).contains(cmeIssue.getIssue().getCode());
    }

    public String getProgram(LoggedInInfo loggedInInfo,String providerNo){
        ProgramProvider pp = programManager2.getCurrentProgramInDomain(loggedInInfo,providerNo);
        String programId = null;

        if(pp !=null && pp.getProgramId() != null){
            programId = ""+pp.getProgramId();
        }else{
            programId = String.valueOf(programManager.getProgramIdByProgramName("OSCAR")); //Default to the oscar program if provider hasn't been assigned to a program
        }
        return programId;
    }

    protected CaseManagementCPP copyNote2cpp(CaseManagementCPP cpp, String note, String code) {
        //TODO: change this back to a loop
        Date d = new Date();
        String separator = "\n-----[[" + d + "]]-----\n";

        if (code.contains("othermeds") || code.contains("OMeds")) {
            StringBuilder text = new StringBuilder();
            text.append(cpp.getFamilyHistory());
            text.append(separator);
            text.append(note);
            cpp.setFamilyHistory(text.toString());

        } if (code.contains("sochx") || code.contains("SocHistory")) {
            StringBuilder text = new StringBuilder();
            text.append(cpp.getSocialHistory());
            text.append(separator);
            text.append(note);
            cpp.setSocialHistory(text.toString());

        } if (code.equals("medhx") || code.contains("MedHistory")) {
            StringBuilder text = new StringBuilder();
            text.append(cpp.getMedicalHistory());
            text.append(separator);
            text.append(note);
            cpp.setMedicalHistory(text.toString());

        } if (code.equals("ongoingconcerns") || code.contains("Concerns")) {
            StringBuilder text = new StringBuilder();
            text.append(cpp.getOngoingConcerns());
            text.append(separator);
            text.append(note);
            cpp.setOngoingConcerns(text.toString());

        } if (code.equals("reminders") || code.contains("Reminders")) {
            StringBuilder text = new StringBuilder();
            text.append(cpp.getReminders());
            text.append(separator);
            text.append(note);
            cpp.setReminders(text.toString());

        } if (code.equals("famhx") || code.contains("FamHistory")) {
            StringBuilder text = new StringBuilder();
            text.append(cpp.getFamilyHistory());
            text.append(separator);
            text.append(note);
            cpp.setFamilyHistory(text.toString());

        } if (code.equals("riskfactors") || code.contains("RiskFactors")) {
            StringBuilder text = new StringBuilder();
            text.append(cpp.getRiskFactors());
            text.append(separator);
            text.append(note);
            cpp.setRiskFactors(text.toString());

        }

        return cpp;
    }

}
