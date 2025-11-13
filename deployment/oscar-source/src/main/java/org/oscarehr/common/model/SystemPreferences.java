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

package org.oscarehr.common.model;

import javax.persistence.*;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

@Entity
@Table(name="SystemPreferences")
public class SystemPreferences extends AbstractModel<Integer>
{

    public static final List<String> RX_PREFERENCE_KEYS = Arrays.asList("rx_paste_provider_to_echart", "rx_show_end_dates","rx_show_start_dates", "rx_show_refill_duration", "rx_show_refill_quantity", 
            "rx_methadone_end_date_calc", "save_rx_signature");
    public static final List<String> SCHEDULE_PREFERENCE_KEYS = Arrays.asList("schedule_display_type", 
            "schedule_display_custom_roster_status", "schedule_tp_link_enabled", "schedule_tp_link_type", "schedule_tp_link_display", 
            "schedule_eligibility_enabled", "schedule_display_enrollment_dr_enabled", "appt_show_full_name", "display_large_calendar", 
            "appt_intake_form", "show_appt_reason","receptionist_alt_view", "show_NonScheduledDays_In_WeekView", 
            "show_appt_type_with_reason", "appt_show_short_letters", "displayAlertsOnScheduleScreen", "displayNotesOnScheduleScreen", 
            "display_quick_date_multiplier", "display_quick_date_picker", "new_eyeform_enabled", "old_schedule_enabled","display_timeline");   
    public static final List<String> ECHART_PREFERENCE_KEYS = Arrays.asList("echart_show_timer", "displayChartNo",
        "echart_email_indicator","echart_show_OLIS", "echart_show_HIN", "echart_show_fam_doc_widget", "echart_show_ref_doc_widget",
        "echart_show_ocean", "echart_show_report_module", "echart_paste_fax_note", "echart_show_larger_font_size",
        "hideEformNotes", "hideDocumentNotes", "hideInvoiceNotes", "hideFormNotes", "hideCppNotes",
        "allergyAlertPopup", "hideEncounterLink", "echart_show_group_document_by_type", "echart_show_DOB", "echart_show_cell",
        "caisi_note_filter_enabled", "echartShowAppointmentTime", "echartShowRosterStatus",
        "sortMeasurementsInEChart","excludeMisc");    
    public static final List<String> MASTER_FILE_PREFERENCE_KEYS = Arrays.asList("display_former_name", "redirect_for_contact");
    public static final List<String> GENERAL_SETTINGS_KEYS = Arrays.asList("replace_demographic_name_with_preferred", "msg_use_create_date", "invoice_custom_clinic_info","force_logout_when_inactive", "force_logout_when_inactive_time");
    public static final List<String> LAB_DISPLAY_PREFERENCE_KEYS = Arrays.asList("code_show_hide_column", "lab_embed_pdf", "lab_pdf_max_size", "display_discipline_as_label_in_inbox", "discipline_character_limit_in_inbox");
    public static final List<String> EFORM_SETTINGS = Arrays.asList("rtl_template_document_type", "patient_intake_eform", "patient_intake_letter_eform", "perinatal_eforms");
    public static final List<String> REFERRAL_SOURCE_PREFERENCE_KEYS = Arrays.asList("enable_referral_source");
    public static final String KIOSK_DISPLAY_PREFERENCE_KEYS = "check_in_all_appointments";
    public static final String AUTO_FLAG_ALWAYS_TO_MRP_ON_DOCUMENTS = "auto_flag_always_to_mrp_on_documents";
    public static final List<String> DOCUMENT_SETTINGS_KEYS = Arrays.asList("document_description_typeahead", "inbox_use_fax_dropdown", "document_discipline_column_display", "split_new_window");
    public static final List<String> RTL_TEMPLATE_SETTINGS = Arrays.asList("rtl_template_document_type");
    public static final List<String> GST_SETTINGS_KEYS = Arrays.asList("clinic_gst_number");
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name="name")
    private String name;

    @Column(name="value")
    private String value;

    @Column(name="updateDate")
    @Temporal(TemporalType.TIMESTAMP)
    private Date updateDate;

    public SystemPreferences() {}
    public SystemPreferences(String name, String value) {
        this.name = name;
        this.value = value;
        this.updateDate = new Date();
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getValue() {
        return value != null ? value : "";
    }

    /**
     * Gets the system preference as a boolean
     * @return true if value is "true", false otherwise
     */
    public Boolean getValueAsBoolean() {
        return "true".equals(value);
    }

    public void setValue(String value) {
        this.value = value;
    }

    public Date getUpdateDate() {
        return updateDate;
    }

    public void setUpdateDate(Date updateDate) {
        this.updateDate = updateDate;
    }
}
