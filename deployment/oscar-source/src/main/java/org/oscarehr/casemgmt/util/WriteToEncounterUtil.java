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

package org.oscarehr.casemgmt.util;

import org.oscarehr.PMmodule.service.ProgramManager;
import org.oscarehr.casemgmt.model.CaseManagementNote;
import org.oscarehr.casemgmt.service.CaseManagementManager;
import org.oscarehr.common.dao.CaseManagementTmpSaveDao;
import org.oscarehr.common.model.CaseManagementTmpSave;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;
import oscar.oscarEncounter.data.EctProgram;

import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.text.SimpleDateFormat;
import java.util.Locale;

public class WriteToEncounterUtil {


    public static void addToCurrentNote(LoggedInInfo loggedInInfo, HttpSession session, String  demographicNo, String body, String moduleName) {
        SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
        if (!securityInfoManager.hasPrivilege(loggedInInfo, "_demographic", "w", demographicNo)) {
            throw new RuntimeException("missing required security object (_demographic)");
        }
        String programNo = new EctProgram(session).getProgram(session.getAttribute("user").toString());
        
        CaseManagementManager caseManagementMgr = SpringUtils.getBean(CaseManagementManager.class);
        CaseManagementTmpSaveDao caseManagementTmpSaveDao = SpringUtils.getBean(CaseManagementTmpSaveDao.class);
        CaseManagementNote note = getLastSaved(session, demographicNo, loggedInInfo.getLoggedInProviderNo(), caseManagementMgr);
        CaseManagementTmpSave tmpSave = caseManagementMgr.getTmpSave(loggedInInfo.getLoggedInProviderNo(), demographicNo, programNo);
        Date today = new Date();
        if (tmpSave != null) {
            String noteBody = generateNote(body, moduleName, false);
            
            if (tmpSave.getNoteId() > 0) {
                note = caseManagementMgr.getNote(String.valueOf(tmpSave.getNoteId()));
                if (note.getUpdate_date().after(tmpSave.getUpdateDate())) {
                    note.setNote(tmpSave.getNote() + "\n" + noteBody);
                    note.setUpdate_date(today);
                    caseManagementMgr.saveNoteSimple(note);
                } else {
                    createAndSaveNewNote(loggedInInfo, demographicNo, programNo, caseManagementMgr, today, tmpSave.getNote() + "\n" + noteBody);
                }
            } else {
                createAndSaveNewNote(loggedInInfo, demographicNo, programNo, caseManagementMgr, today, tmpSave.getNote() + "\n" + noteBody);
            }
            caseManagementTmpSaveDao.remove(tmpSave.getProviderNo(), tmpSave.getDemographicNo(), tmpSave.getProgramId());
        } else if (note != null) {
            String noteBody = generateNote(body, moduleName, false);
            note.setNote(note.getNote() + "\n" + noteBody);
            note.setUpdate_date(today);
            caseManagementMgr.saveNoteSimple(note);
        } else {
            String noteBody = generateNote(body, moduleName, true);
            createAndSaveNewNote(loggedInInfo, demographicNo, programNo, caseManagementMgr, today, noteBody);
        }
    }
    
    private static String generateNote(String noteBody, String moduleName, boolean addDateAndTypeString) {

        SimpleDateFormat df =  new SimpleDateFormat("dd-MMM-yyyy", Locale.getDefault());
        String formattedDate = df.format(new Date());
        String dateAndTypeString = "["+formattedDate+" .: " + moduleName + "]\n";
        
        String note = addDateAndTypeString ? dateAndTypeString : "";
        note += noteBody;
        
        return note;
    }
    
    public static CaseManagementNote getLastSaved(HttpSession session, String demono, String providerNo, CaseManagementManager caseManagementMgr) {
        String programId = (String) session.getAttribute("case_program_id");
        Map unlockedNotesMap = getUnlockedNotesMap(session);
        return caseManagementMgr.getLastSaved(programId, demono, providerNo, unlockedNotesMap);
    }

    protected static Map getUnlockedNotesMap(HttpSession session) {
        Map<Long, Boolean> map = (Map<Long, Boolean>) session.getAttribute("unlockedNoteMap");
        if (map == null) {
            map = new HashMap<Long, Boolean>();
        }
        return map;
    }

    private static void createAndSaveNewNote(LoggedInInfo loggedInInfo, String demographicNo, String programNo, CaseManagementManager caseManagementMgr, Date today, String noteBody) {
        CaseManagementNote note = new CaseManagementNote();
        note.setObservation_date(today);
        note.setCreate_date(today);
        note.setDemographic_no(demographicNo);
        note.setProvider(loggedInInfo.getLoggedInProvider());
        note.setProviderNo(loggedInInfo.getLoggedInProviderNo());
        note.setSigned(false);
        note.setSigning_provider_no("");
        note.setProgram_no(programNo);
        note.setNote(noteBody);
        note.setIncludeissue(false);
        ProgramManager programManager = SpringUtils.getBean(ProgramManager.class);
        String role;
        try {
            role = String.valueOf((programManager.getProgramProvider(note.getProviderNo(), note.getProgram_no())).getRole().getId());
        } catch (Exception e) {
            role = "0";
        }
        note.setReporter_caisi_role(role);
        note.setReporter_program_team("0");
        note.setPassword(null);
        note.setLocked(false);
        note.setHistory(noteBody);
        note.setUpdate_date(today);
        caseManagementMgr.saveNoteSimple(note);
    }

}
