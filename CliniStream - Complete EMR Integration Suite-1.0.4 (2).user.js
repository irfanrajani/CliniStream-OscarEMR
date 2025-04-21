// ==UserScript==
// @name         CliniStream - Complete EMR Integration Suite
// @namespace    https://*.kai-oscar.com/
// @version      1.0.4
// @description  All-in-one EMR solution: Encounter Templates, Billing/ICD9, and AI Summary with seamless note integration
// @match        *://*.kai-oscar.com/oscar/provider/appointmentprovider*.jsp*
// @match        *://*.kai-oscar.com/oscar/provider/providercontrol.jsp*
// @match        *://*.kai-oscar.com/oscar/casemgmt/caseManagement*.jsp*
// @match        *://*.kai-oscar.com/oscar/casemgmt/forward.jsp*
// @match        *://*.kai-oscar.com/oscar/billing.do*
// @match        *://*.kai-oscar.com/oscar/billing/CA/*/CreateBilling.do*
// @match        *://*.kai-oscar.com/oscar/appointment/appointmentcontrol.jsp*
// @match        *://*.kai-oscar.com/oscar/appointment/editappointment.jsp*
// @match        *://health.careconnect.ca/*
// @match        *://id.gov.bc.ca/login/entry*
// @connect      health.careconnect.ca
// @connect      id.gov.bc.ca
// @grant        GM_openInTab
// @grant        GM_tabs
// @grant        GM_getTab
// @grant        GM_saveTab
// @grant        GM_addStyle
// @grant        GM_getValue
// @grant        GM_setValue
// @grant        GM_listValues
// @grant        GM_deleteValue
// @grant        GM_xmlhttpRequest
// @require      https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js
// @connect      api.openrouter.ai
// @connect      openrouter.ai
// @connect      raw.githubusercontent.com
// @connect      self
// ==/UserScript==

if (window.__CliniStreamLoaded) {
    return;
}
window.__CliniStreamLoaded = true;

(function() {
    'use strict';

    // -------------------------------
    // Logging Utility Functions (Primary Definitions)
    // -------------------------------
    let cliniStreamBillLog = "";  // using one global log variable

    // Returns a formatted timestamp
    function getTimeStamp() {
        return new Date().toLocaleString();
    }

    // Saves the log history to storage under "CliniStream_LogHistory"
    function persistLog() {
        GM_setValue("CliniStream_LogHistory", cliniStreamBillLog);
    }

    // Loads the log history from storage into the local log variable
    function loadLogFromStorage() {
        cliniStreamBillLog = GM_getValue("CliniStream_LogHistory", "");
    }

    // Updates the content of the element with id "log-content" (if it exists)
    function updateLogContent() {
        const el = document.getElementById("log-content");
        if (el) {
            el.textContent = cliniStreamBillLog;
            el.scrollTop = el.scrollHeight;
        }
    }

    // Logs a message with a timestamp, updates the log variable, saves it, and updates the display
    function addLog(msg) {
        const ts = getTimeStamp();
        const fm = `[${ts}] ${msg}`;
        console.log(fm);
        cliniStreamBillLog = (cliniStreamBillLog || "") + fm + "\n";
        persistLog();
        updateLogContent();
    }

    // -------------------------------
    // End Logging Functions Block
    // -------------------------------

    // Delay initialization until document is fully loaded
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initializeWhenSafe);
    } else {
        setTimeout(initializeWhenSafe, 1000); // Delay even if already loaded
    }

    function initializeWhenSafe() {
        // Wait an additional moment to ensure the page is fully initialized
        setTimeout(function() {
            try {
                if (typeof jQuery !== 'undefined') {
                    initialize(jQuery);
                } else {
                    console.error("jQuery not available");
                }
            } catch (e) {
                console.error("CliniStream initialization error:", e);
            }
        }, 1500);
    }

    // --- Basic Configuration ---
    let AI_API_KEY = GM_getValue("AI_API_KEY", "YOUR_OPENROUTER_API_KEY_HERE"); // Get from storage or use default
    const AI_MODELS = [
        "google/gemini-2.0-flash-thinking-exp:free",
        "google/gemini-2.5-pro-exp-03-25:free",
        "deepseek/deepseek-r1:free"
    ];
    const AI_TEXTAREA_SELECTOR = 'textarea.txtArea[name^="caseNote_note"], textarea#encounterNote';
    const OPENROUTER_API_URL = "https://openrouter.ai/api/v1/chat/completions";
    const DX_JSON_URL = 'https://raw.githubusercontent.com/irfanrajani/CliniStream-OscarEMR/main/icd9codes.json';

    // Timing settings
    const SCAN_FETCH_DELAY_MS = 200;
    const FILL_DELAY_MS = 600;
    const CONTINUE_DELAY_MS = 600;
    const FINAL_DELAY_MS = 1000;
    const BATCH_TIME_LIMIT_MS = 5 * 60 * 1000;
    const AUTO_SCAN_INTERVAL_HOURS = 24;

    // --- Global State ---
    let billLog = ""; // legacy variable (not used now; using cliniStreamBillLog instead)
    let isModalOpen = false;
    let lastFocusedEl = null;
    let dxData = [];
    let currentBillingAptNo = null;
    let selectedICDCodes = [];
    let scanError = false;
    let scanSuccessCount = 0;
    let scanFailureCount = 0;
    let scanTotalCount = 0;
    let batchError = false;
    let batchSuccessCount = 0;
    let batchFailureCount = 0;
    let batchFailureList = [];
    let icdSuggestionBox = null;
    let currentAiResponse = { fullText: '', coreSummary: '', insights: '', modelIndex: -1, originalNote: '' };
    let lastFocusedTextarea = null;
    let buttonPosition = { x: 20, y: 20 }; // Default button position

    // Encounter Templates (stored and loaded from GM_getValue)
    let encounterTemplates = [
        {
            id: "template_inperson",
            name: "In Person Visit",
            category: "Encounter Note",
            content: `In person consult - {{DATE_TIME}}
Dr Rajani/locum talking to patient to discuss - {{REASON}}

S:

O:

A:

P:

Monitor for the following (if present suitable for urgent follow up):

If condition is worsening, they would be suitable for a same day appointment, ideally with prior assessment by the RN for triage.

Patient has been advised of side effects of treatment, including medication risks vs. benefits.
Patient has also been safety netted with respect to seeking further follow up from an MD, the ER, and what necessitates an in person follow up.
Patient is also aware of limitations of our system with respect to referrals, labs, and imaging. They are aware to follow with MD or imaging/lab/consultant offices if not evaluated in a timely manner.`
        },
        {
            id: "template_telemedicine",
            name: "Telemedicine",
            category: "Encounter Note",
            content: `** The patient understands how the audio/video conferencing technology will be used during this consultation. They understand that there are limitations to care provided this way compared to a direct/in person consultation. The patient also understands that there are potential risks to this technology, including interruptions, unauthorized access and technical difficulties. The patient also understands that they can discontinue the telemedicine consult/visit if it is felt that the videoconferencing or audio connections are not adequate for the situation **

Telemedicine consult - {{DATE_TIME}}
Verbal consent for consultation - Yes
Patient currently in BC Canada - Yes
Dr Rajani/locum talking to patient to discuss - {{REASON}}

S:

O: Deferred, due to nature of telemedicine consultation

A:

P:

Monitor for the following (if present suitable for urgent follow up):

If condition is worsening, they would be suitable for a same day appointment, ideally with prior assessment by the RN for triage.

Patient has been advised of side effects of treatment, including medication risks vs. benefits.
Patient has also been safety netted with respect to seeking further follow up from an MD, the ER, and what necessitates an in person follow up.
Patient is also aware of limitations of our system with respect to referrals, labs, and imaging. They are aware to follow with MD or imaging/lab/consultant offices if not evaluated in a timely manner.`
        },
        {
            id: "template_refugee",
            name: "Refugee Visit",
            category: "Encounter Note",
            content: `In person consult - {{DATE_TIME}}
Dr Rajani/locum talking to patient to discuss - {{REASON}}
Interpreter: Yes,
Interpreter ID (if applicable):

S:

O:

A:

P:

Monitor for the following (if present suitable for urgent follow up):

If condition is worsening, they would be suitable for a same day appointment, ideally with prior assessment by the RN for triage.

Patient has been advised of side effects of treatment, including medication risks vs. benefits.
Patient has also been safety netted with respect to seeking further follow up from an MD, the ER, and what necessitates an in person follow up.
Patient is also aware of limitations of our system with respect to referrals, labs, and imaging. They are aware to follow with MD or imaging/lab/consultant offices if not evaluated in a timely manner.`
        },
        {
            id: "template_normal_exam",
            name: "Normal Physical Exam",
            category: "Physical Exam",
            content: `Physical Examination:
VS: BP: WNL, HR: WNL, Temp: WNL, RR: WNL, O2 Sat: WNL
General: Alert and oriented, no acute distress.
HEENT: Normocephalic, atraumatic. PERRL. TMs clear bilaterally. Oropharynx clear.
Neck: Supple, no lymphadenopathy, no thyromegaly.
Cardiovascular: RRR, no murmurs, rubs, or gallops.
Respiratory: Clear to auscultation bilaterally, no wheezes, rales, or rhonchi.
Abdomen: Soft, non-tender, non-distended. Normal bowel sounds. No hepatosplenomegaly.
Musculoskeletal: Normal range of motion. No edema or deformity.
Neurological: CN II-XII intact. Sensory intact. DTRs 2+ and symmetric. No focal deficits.
Skin: No rashes, lesions, or unusual pigmentation.`
        },
        {
            id: "template_respiratory_exam",
            name: "Respiratory Exam",
            category: "Physical Exam",
            content: `Respiratory Examination:
Inspection: No visible respiratory distress. Respiratory rate and pattern within normal limits. No use of accessory muscles. No intercostal retractions.
Chest Configuration: Normal AP:lateral diameter. No deformities or asymmetry.
Palpation: Normal tactile fremitus. No tenderness or masses.
Percussion: Resonant throughout all lung fields.
Auscultation: Vesicular breath sounds throughout. No adventitious sounds (wheezes, crackles, or rhonchi). No bronchophony, egophony, or whispered pectoriloquy.`
        },
        {
            id: "template_headache",
            name: "Headache",
            category: "Presenting Complaint",
            content: `Chief Complaint: Headache

History of Present Illness:
- Onset:
- Location:
- Quality:
- Severity (1-10):
- Duration:
- Frequency:
- Aggravating factors:
- Relieving factors:
- Associated symptoms:
- Previous similar episodes:
- Prior workup/treatment:

Pertinent Negatives:
- No fever or chills
- No visual changes or photophobia
- No neck stiffness
- No nausea or vomiting
- No recent trauma
- No focal neurological deficits
- No history of seizures`
        },
        {
            id: "template_chest_pain",
            name: "Chest Pain",
            category: "Presenting Complaint",
            content: `Chief Complaint: Chest Pain

History of Present Illness:
- Onset:
- Location:
- Quality:
- Severity (1-10):
- Duration:
- Frequency:
- Radiation:
- Aggravating factors:
- Relieving factors:
- Associated symptoms:
- Previous similar episodes:
- Prior workup/treatment:

Pertinent Negatives:
- No shortness of breath
- No diaphoresis
- No nausea/vomiting
- No palpitations
- No dizziness/syncope
- No fever or chills`
        }
    ];

    // Try to load saved templates or use defaults
    function loadEncounterTemplates() {
        const savedTemplates = GM_getValue("CliniStream_Templates", null);
        if (savedTemplates) {
            try {
                const parsed = JSON.parse(savedTemplates);
                if (Array.isArray(parsed) && parsed.length > 0) {
                    encounterTemplates = parsed;
                    addLog(`[Templates] Loaded ${encounterTemplates.length} saved templates`);
                }
            } catch(e) {
                addLog(`[Templates] Error loading saved templates: ${e.message}`);
            }
        }
    }

    // Add this in your initialize function or in a separate function that runs at script startup

    function addExtraStyles() {
        GM_addStyle(`
        /* Make modal properly centered and scrollable */
        #modal {
            max-height: 85vh !important;
            max-width: 90vw !important;
            overflow: auto !important;
        }

        /* Improved tab pane scrolling */
        .tab-pane {
            max-height: 70vh;
            overflow-y: auto;
        }

        /* Float button on top */
        #float-btn {
            display: block !important;
            z-index: 99999 !important;
        }

        /* Fix multibill table */
        #multibill-content table {
            width: 100%;
            min-width: 800px;
        }

        #multibill-content {
            overflow-x: auto;
            max-height: 60vh;
        }

        #multibill-content th {
            position: sticky;
            top: 0;
            background: #fff;
            z-index: 10;
        }

        /* Make autocomplete visible above modal */
        .dx-suggestion-box {
            z-index: 10001 !important;
        }
    `);
    }


    // Load AI models if available
    function loadAIModels() {
        const savedModels = GM_getValue("CliniStream_AIModels", null);
        if (savedModels) {
            try {
                const models = JSON.parse(savedModels);
                if (Array.isArray(models) && models.length === 3) {
                    // Update global AI_MODELS
                    window.AI_MODELS = models;
                    addLog(`[AI] Loaded custom AI models: ${models.join(', ')}`);
                }
            } catch(e) {
                addLog(`[AI] Error loading AI models: ${e.message}`);
            }
        } else {
            // Set defaults if not saved yet
            window.AI_MODELS = [
                "google/gemini-2.0-flash-thinking-exp:free",
                "google/gemini-2.5-pro-exp-03-25:free",
                "deepseek/deepseek-r1:free"
            ];

            // Save the defaults
            GM_setValue("CliniStream_AIModels", JSON.stringify(window.AI_MODELS));
            addLog(`[AI] Set default AI models`);
        }

        // Update model selector in settings if it exists
        if ($('#settings-primary-model').length) {
            $('#settings-primary-model').val(window.AI_MODELS[0]);
            $('#settings-backup-model-1').val(window.AI_MODELS[1]);
            $('#settings-backup-model-2').val(window.AI_MODELS[2]);
        }
    }

    // Load button position from storage
    function loadButtonPosition() {
        const savedPosition = GM_getValue("CliniStream_ButtonPosition", null);
        if (savedPosition) {
            try {
                const parsed = JSON.parse(savedPosition);
                if (parsed && typeof parsed.x === 'number' && typeof parsed.y === 'number') {
                    buttonPosition = parsed;
                    addLog(`[UI] Loaded button position: x=${buttonPosition.x}, y=${buttonPosition.y}`);
                }
            } catch(e) {
                addLog(`[UI] Error loading button position: ${e.message}`);
            }
        }
    }

    // Save button position to storage
    function saveButtonPosition() {
        GM_setValue("CliniStream_ButtonPosition", JSON.stringify(buttonPosition));
        addLog(`[UI] Saved button position: x=${buttonPosition.x}, y=${buttonPosition.y}`);
    }

    // Save templates to persistent storage
    function saveEncounterTemplates() {
        GM_setValue("CliniStream_Templates", JSON.stringify(encounterTemplates));
        addLog(`[Templates] Saved ${encounterTemplates.length} templates`);
    }

    // --- Utility Functions ---
    function sanitizeInput(raw) {
        return (raw || "").replace(/[\[\]"']/g, "").trim();
    }

    function setButtonState($btn, text, color, disabled = false) {
        if ($btn && $btn.length) {
            $btn.text(text).css("background-color", color).prop("disabled", disabled);
        }
    }

    function getPageType() {
        const href = window.location.href;
        if (href.includes("/oscar/provider/appointmentprovider") || href.includes("/oscar/provider/providercontrol")) {
            return 'APPOINTMENT_SCHEDULE';
        }
        if (href.includes("/oscar/casemgmt/caseManagement") || (href.includes("/oscar/casemgmt/forward.jsp") && href.includes("action=view"))) {
            return 'ENCOUNTER_NOTE';
        }
        if (href.includes("/oscar/billing.do") && !href.includes("/oscar/billing/CA/")) {
            return 'BILLING_STEP_1';
        }
        if (href.includes("/oscar/billing/CA/") && href.includes("/CreateBilling.do")) {
            return 'BILLING_STEP_2';
        }
        if (href.includes("/oscar/appointment/appointmentcontrol.jsp") || href.includes("/oscar/appointment/editappointment.jsp")) {
            return 'APPOINTMENT_EDIT';
        }
        if (href.includes("/oscar/casemgmt/forward.jsp")) {
            return 'ENCOUNTER_GENERAL';
        }
        return 'UNKNOWN';
    }

    const currentPageType = getPageType();

    // Check if we're on an appointment page
    const isAppointmentPage = (currentPageType === 'APPOINTMENT_SCHEDULE');
    // Check if we're on an encounter page
    const isEncounterPage = (currentPageType === 'ENCOUNTER_NOTE' || currentPageType === 'ENCOUNTER_GENERAL');
    // Check if we're on an appointment edit page
    const isAppointmentEditPage = (currentPageType === 'APPOINTMENT_EDIT');

    function waitForSelector(sel, ms = 5000) {
        return new Promise((resolve, reject) => {
            const start = Date.now();
            const timer = setInterval(() => {
                const el = document.querySelector(sel);
                if(el) {
                    clearInterval(timer);
                    resolve(el);
                } else if(Date.now() - start > ms) {
                    clearInterval(timer);
                    reject(`Timeout waiting for selector: ${sel}`);
                }
            }, 100);
        });
    }

    // ============================================================
// BLOCK 2: ADD Helper Function simulateEnterKeyPress
// ============================================================
function simulateEnterKeyPress(element) {
    try {
        const event = new KeyboardEvent('keydown', {
            key: 'Enter',
            code: 'Enter',
            keyCode: 13,
            which: 13,
            bubbles: true,
            cancelable: true
        });
        element.dispatchEvent(event);
        addLog(`[Util] Simulated Enter key press on element: ${element.id || element.tagName}`);
        return true;
    } catch (e) {
        addLog(`[Util Error] Failed to simulate Enter key press: ${e.message}`);
        return false;
    }
}
// ============================================================
// END BLOCK 2
// ============================================================

    function convertTo24Hour(str) {
        if (!str) {
            return "00:00";
        }

        const timeMatch = str.match(/(\d{1,2})[:.](\d{2})\s*(am|pm)?/i);

        if (!timeMatch) {
            return "00:00";
        }

        let hh = parseInt(timeMatch[1], 10);
        let mm = parseInt(timeMatch[2], 10);
        const ampm = (timeMatch[3] || "").toLowerCase();

        if (isNaN(hh) || isNaN(mm)) {
            return "00:00";
        }

        if(ampm === "pm" && hh < 12) hh += 12;
        if(ampm === "am" && hh === 12) hh = 0;

        return String(hh).padStart(2, "0") + ":" + String(mm).padStart(2, "0");
    }

    function calcAge(bdStr) {
        if (!bdStr || !/^\d{4}-\d{2}-\d{2}$/.test(bdStr)) return 0;
        const [y, m, d] = bdStr.split('-').map(Number);
        const bd = new Date(y, m - 1, d);
        if (isNaN(bd.getTime())) return 0;
        const today = new Date();
        let age = today.getFullYear() - bd.getFullYear();
        const monthDiff = today.getMonth() - bd.getMonth();
        if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < bd.getDate())) {
            age--;
        }
        return age >= 0 ? age : 0;
    }

    async function runSequentialPromises(promiseFactories, delayMs = 0) {
        const results = [];
        let index = 0;
        for (const factory of promiseFactories) {
            try {
                const result = await factory();
                results.push({ status: 'fulfilled', value: result, index: index });
                if (delayMs > 0 && index < promiseFactories.length - 1) {
                    await new Promise(resolve => setTimeout(resolve, delayMs));
                }
            } catch (error) {
                results.push({ status: 'rejected', reason: error, index: index });
                scanError = true;
            }
            index++;
            $('#float-btn .scan-progress, #tab-multibill .scan-progress').text(`(${index}/${scanTotalCount})`);
        }
        return results;
    }

    // Simple delay helper
    function delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    // Storage helpers
    function getPatientID(aptNo) { return "9" + aptNo; }
    function setBillingData(aptNo, dataObj) {
        if (!aptNo) return;
        GM_setValue(`PHN-${getPatientID(aptNo)}-Appointment-${aptNo}`, JSON.stringify(dataObj));
    }
    function getBillingData(aptNo) {
        if (!aptNo) return null;
        const raw = GM_getValue(`PHN-${getPatientID(aptNo)}-Appointment-${aptNo}`, null);
        try {
            return raw ? JSON.parse(raw) : null;
        } catch (e) {
            console.error(`Error parsing billing data for apt ${aptNo}:`, e, raw);
            return null;
        }
    }
    function setScannedData(aptNo, dataObj) {
        if (!aptNo) return;
        GM_setValue(`ApptScan-${aptNo}`, JSON.stringify(dataObj));
    }
    function getScannedData(aptNo) {
        if (!aptNo) return null;
        const raw = GM_getValue(`ApptScan-${aptNo}`, null);
        try {
            return raw ? JSON.parse(raw) : null;
        } catch (e) {
            console.error(`Error parsing scanned data for apt ${aptNo}:`, e, raw);
            return null;
        }
    }

    // --- Batch State Helpers ---
    function getBatchID() { return GM_getValue("batchID", null); }
    function setBatchID(id) { GM_setValue("batchID", id); }
    function getBatchQueueStr() { return GM_getValue("batchQueueStr", ""); }
    function setBatchQueueStr(s) { GM_setValue("batchQueueStr", s); }
    function parseBatchQueue(str) {
        if(!str || !str.trim()) return [];
        return str.split(",").map(x => x.trim()).filter(x => x.match(/^\d+$/));
    }
    function getBatchIndex() { return parseInt(GM_getValue("batchIndex", "0"), 10) || 0; }
    function setBatchIndex(i) { GM_setValue("batchIndex", String(i)); }
    function getBatchStart() { return parseInt(GM_getValue("batchStartTime", "0"), 10) || 0; }
    function setBatchStart(t) { GM_setValue("batchStartTime", String(t)); }
    function clearBatchState() {
        GM_deleteValue("batchID");
        GM_deleteValue("batchQueueStr");
        GM_deleteValue("batchIndex");
        GM_deleteValue("batchStartTime");
    }
    function isBatchValid() {
        const bID = getBatchID();
        if(!bID) return false;
        const st = getBatchStart();
        if(!st) return false;
        if (Date.now() - st > BATCH_TIME_LIMIT_MS) {
            clearBatchState();
            return false;
        }
        const qs = getBatchQueueStr();
        if(!qs.trim()) {
            clearBatchState();
            return false;
        }
        const arr = parseBatchQueue(qs);
        if(!arr.length) {
            clearBatchState();
            return false;
        }
        const idx = getBatchIndex();
        if(idx >= arr.length) {
            clearBatchState();
            return false;
        }
        return true;
    }
    function getBatchResults() {
        return {
            success: parseInt(GM_getValue("batchSuccess", "0"), 10) || 0,
            fail: parseInt(GM_getValue("batchFail", "0"), 10) || 0,
            failList: (GM_getValue("batchFailList", "") || "").split(',').filter(Boolean)
        };
    }
    function setBatchResults(success, fail, failList) {
        GM_setValue("batchSuccess", String(success));
        GM_setValue("batchFail", String(fail));
        GM_setValue("batchFailList", failList.join(','));
    }
    function clearBatchResults() {
        GM_deleteValue("batchSuccess");
        GM_deleteValue("batchFail");
        GM_deleteValue("batchFailList");
    }

    // --- Chart Link State Helpers ---
    function setChartLinkingState(active, appts = [], index = 0, hin = "", apptNo = "") {
        GM_setValue("cs_link_active", active);
        GM_setValue("cs_link_appts", JSON.stringify(appts));
        GM_setValue("cs_link_index", index);
        GM_setValue("cs_link_hin", hin);
        GM_setValue("cs_link_apptNo", apptNo);
    }
    function getChartLinkingState() {
        return {
            active: GM_getValue("cs_link_active", false),
            appts: JSON.parse(GM_getValue("cs_link_appts", "[]")),
            index: parseInt(GM_getValue("cs_link_index", "0"), 10),
            hin: GM_getValue("cs_link_hin", ""),
            apptNo: GM_getValue("cs_link_apptNo", "")
        };
    }
    function clearChartLinkingState() {
        GM_deleteValue("cs_link_active");
        GM_deleteValue("cs_link_appts");
        GM_deleteValue("cs_link_index");
        GM_deleteValue("cs_link_hin");
        GM_deleteValue("cs_link_apptNo");
    }
    function isChartLinkingActive() {
        return GM_getValue("cs_link_active", false);
    }

    // ============================================================
// BLOCK 2: ADD PharmaNet State Helper Functions
// ============================================================
// --- PharmaNet State Helpers ---
    const PHARMANET_STATE_KEY = "pharmaNetScanState";
    const PHARMANET_RESULTS_KEY = "pharmaNetScanResults";
    const AUTH_TIMEOUT_MS = 120 * 1000; // 120 seconds for login

    function getPharmaNetState() {
        const defaults = {
            active: false,
            queue: [], // Array of { phn: string, dob: string | null, name: string | null }
            index: 0,
            authWait: false,
            authTimestamp: 0,
            currentPhn: null, // Store the PHN being processed in the CareConnect tab
            statusMessage: "",
        };
        const stored = GM_getValue(PHARMANET_STATE_KEY, null);
        if (stored) {
            try {
                // Ensure queue is always an array even if stored value is corrupt
                const parsed = JSON.parse(stored);
                parsed.queue = Array.isArray(parsed.queue) ? parsed.queue : [];
                return { ...defaults, ...parsed };
            } catch (e) {
                addLog("[PharmaNet State Error] Failed to parse state, using defaults.");
                return defaults;
            }
        }
        return defaults;
    }

    function setPharmaNetState(newState) {
        try {
            // Ensure queue is always stored as an array
            newState.queue = Array.isArray(newState.queue) ? newState.queue : [];
            GM_setValue(PHARMANET_STATE_KEY, JSON.stringify(newState));
        } catch (e) {
            addLog("[PharmaNet State Error] Failed to save state.");
        }
    }

    function clearPharmaNetState() {
        GM_deleteValue(PHARMANET_STATE_KEY);
        // Optionally clear results too, or keep them? Let's keep them for now.
        // GM_deleteValue(PHARMANET_RESULTS_KEY);
        addLog("[PharmaNet State] State cleared.");
        // Update button state immediately after clearing
        if (typeof updatePharmaNetButtonState === "function") {
            updatePharmaNetButtonState();
        }
    }

    function getPharmaNetResults() {
        const stored = GM_getValue(PHARMANET_RESULTS_KEY, null);
        if (stored) {
            try {
                return JSON.parse(stored);
            } catch (e) {
                addLog("[PharmaNet Results Error] Failed to parse results, returning empty object.");
                return {};
            }
        }
        return {};
    }

    function savePharmaNetResult(phn, medicationList) {
        if (!phn) return;
        const results = getPharmaNetResults();
        results[phn] = {
            timestamp: Date.now(),
            medications: medicationList
        };
        try {
            GM_setValue(PHARMANET_RESULTS_KEY, JSON.stringify(results));
            addLog(`[PharmaNet Results] Saved ${medicationList.length} records for PHN ${phn}`);
        } catch (e) {
            addLog(`[PharmaNet Results Error] Failed to save results for PHN ${phn}`);
        }
    }

    // Helper to update status and save state
    function updatePharmaNetStatus(message, stateChanges = {}) {
        let state = getPharmaNetState();
        state.statusMessage = message;
        state = { ...state, ...stateChanges };
        setPharmaNetState(state);
        addLog(`[PharmaNet Status] ${message}`);
        // Update button in Oscar UI if possible (requires checking if on Oscar page)
        if (typeof getPageType === 'function' && getPageType() === 'APPOINTMENT_SCHEDULE' && typeof updatePharmaNetButtonState === "function") {
            updatePharmaNetButtonState();
        }
    }
    // ============================================================
// END BLOCK 2
// ============================================================

    // ============================================================
// BLOCK 3: ADD PharmaNet Button Logic (Oscar Page)
// ============================================================
// ============================================================
// BLOCK 3: REPLACE setupPharmaNetButton FUNCTION
// ============================================================
    function setupPharmaNetButton() {
        // Ensure this runs only on the correct Oscar page
        if (getPageType() === 'APPOINTMENT_SCHEDULE') {
            const $btn = $('#scan-pharmanet-btn');
            if ($btn.length) {
                // Use off('click') to prevent multiple listeners if script re-runs
                $btn.off('click').on('click', function() {
                    const state = getPharmaNetState();
                    if (state.active) {
                        // If scan is active, prompt user to stop it
                        if (confirm("A PharmaNet scan is currently active. Do you want to stop it?")) {
                            stopPharmaNetScan("User cancelled");
                        }
                    } else {
                        // If scan is not active, start it
                        startPharmaNetScan();
                    }
                });
                addLog("[PharmaNet] PharmaNet button listener attached (with stop functionality).");
                // Update button state on load based on persisted state
                updatePharmaNetButtonState();
            } else {
                addLog("[PharmaNet Error] Scan PharmaNET button not found in modal footer.");
            }
        }
    }
// ============================================================
// END BLOCK 3
// ============================================================

    function updatePharmaNetButtonState() {
        // Ensure this runs only on the correct Oscar page
        if (getPageType() !== 'APPOINTMENT_SCHEDULE') return;

        const $btn = $('#scan-pharmanet-btn');
        if (!$btn.length) return;

        const state = getPharmaNetState();

        if (state.active) {
            let progress = "";
            // Ensure state.queue is an array before accessing length
            if (Array.isArray(state.queue) && state.queue.length > 0) {
                progress = ` (${state.index}/${state.queue.length})`;
            }
            let btnText = `Scanning PNet${progress}...`;
            if (state.authWait) {
                btnText = `Waiting Login${progress}...`;
            } else if (state.statusMessage.includes("Processing")) {
                btnText = state.statusMessage; // Show specific processing message
            }

            $btn.text(btnText)
                .prop('disabled', true)
                .css('background-color', '#f39c12') // Orange while running
                .css('color', '#fff');

        } else {
            $btn.text('Scan PharmaNET')
                .prop('disabled', false)
                .css('background-color', '#ffc107') // Default yellow
                .css('color', '#000');

            // Briefly indicate completion/error based on the last status message
            if (state.statusMessage.includes("Completed")) {
                $btn.text('PNet Scan Done').css('background-color', '#28a745').css('color', '#fff');
                setTimeout(updatePharmaNetButtonState, 5000); // Reset after 5s
            } else if (state.statusMessage.includes("Error") || state.statusMessage.includes("Failed") || state.statusMessage.includes("timed out")) {
                $btn.text('PNet Scan Error').css('background-color', '#dc3545').css('color', '#fff');
                setTimeout(updatePharmaNetButtonState, 5000); // Reset after 5s
            } else if (state.statusMessage.includes("No PHNs found")) {
                $btn.text('No PHNs Found').css('background-color', '#6c757d').css('color', '#fff');
                setTimeout(updatePharmaNetButtonState, 5000); // Reset after 5s
            }
        }
    }


// ============================================================
// BLOCK 4: REPLACE startPharmaNetScan FUNCTION
// ============================================================
    function startPharmaNetScan() {
        addLog("[PharmaNet] Starting scan initiated...");
        const state = getPharmaNetState();

        // Check if a scan is already marked active
        if (state.active) {
            if (confirm("A PharmaNet scan appears to be active or incomplete (perhaps from a previous session). Do you want to clear the previous state and start a new scan?")) {
                addLog("[PharmaNet] User chose to clear existing state and restart.");
                // Use clearPharmaNetState which also updates the button
                clearPharmaNetState();
            } else {
                addLog("[PharmaNet] Scan is already active, user chose not to restart.");
                return; // Exit if user cancels restart
            }
        }

        // --- Proceed with starting a new scan ---

        // 1. Gather PHNs
        const patientQueue = [];
        const uniquePhns = new Set();
        $('a.apptLink').each(function() {
            // ... (Gathering logic remains the same as before) ...
            const oc = $(this).attr('onclick') || '';
            const aptMatch = oc.match(/appointment_no=(\d+)/);
            if (!aptMatch) return;
            const aptNo = aptMatch[1];
            const scannedData = getScannedData(aptNo);
            if (scannedData && scannedData.hin) {
                if (!uniquePhns.has(scannedData.hin)) {
                    const $billingLink = $(`a[title="Billing"][onclick*="appointment_no=${aptNo}"]`);
                    let isBilled = false;
                    if ($billingLink.length) {
                        const linkText = $billingLink.text().trim();
                        const billingOc = $billingLink.attr("onclick") || "";
                        isBilled = (linkText === '-B' || billingOc.includes("onUnbilled("));
                    }
                    if (!isBilled) {
                        uniquePhns.add(scannedData.hin);
                        patientQueue.push({ phn: scannedData.hin, dob: scannedData.dob, name: scannedData.patientName });
                        addLog(`[PharmaNet] Added PHN ${scannedData.hin} (Apt #${aptNo}) to queue.`);
                    } else { addLog(`[PharmaNet] Skipping PHN ${scannedData.hin} (Apt #${aptNo}) as it appears billed.`); }
                } else { addLog(`[PharmaNet] Skipping duplicate PHN ${scannedData.hin} (Apt #${aptNo}).`); }
            } else if (scannedData && !scannedData.hin) { addLog(`[PharmaNet] Skipping Apt #${aptNo} - Missing HIN/PHN in scanned data.`); }
            else { addLog(`[PharmaNet] Skipping Apt #${aptNo} - No scan data found.`); }
        });

        if (patientQueue.length === 0) {
            alert("No valid unbilled appointments with PHNs found on this page to scan. Please run 'Scan Appointments' first if needed.");
            addLog("[PharmaNet] No PHNs found in queue.");
            return; // Exit if no patients
        }

        addLog(`[PharmaNet] Starting scan for ${patientQueue.length} unique PHNs.`);

        // 2. Generate Scan ID and Set Initial State
        const scanId = `cs_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`; // Unique ID
        addLog(`[PharmaNet] Generated Scan ID: ${scanId}`);
        const initialState = {
            active: true,
            scanId: scanId, // Store the unique ID for this scan session
            queue: patientQueue,
            index: 0,
            authWait: true,
            authTimestamp: Date.now(),
            currentPhn: null,
            currentPatientStartTime: null, // Track start time per patient
            statusMessage: `Starting scan for ${patientQueue.length} patients...`,
        };
        setPharmaNetState(initialState);
        updatePharmaNetButtonState(); // Update button look

        // 3. Open CareConnect in a new tab with Scan ID
        try {
            const targetUrl = `https://health.careconnect.ca/Welcome/Index?clinistream_scan_id=${scanId}`;
            GM_openInTab(targetUrl, {
                active: true,
                setParent: true
            });
            addLog(`[PharmaNet] Opened CareConnect tab with URL: ${targetUrl}`);
            updatePharmaNetStatus("Waiting for CareConnect Login...");
        } catch (e) {
            addLog(`[PharmaNet Error] Failed to open CareConnect tab: ${e.message}. Ensure @grant GM_openInTab is in the script header.`);
            updatePharmaNetStatus(`Error opening tab: ${e.message}`, { active: false, scanId: null }); // Set inactive and clear scanId
            alert(`Error opening CareConnect tab: ${e.message}\nEnsure @grant GM_openInTab is in the script header.`);
        }
    }

// ============================================================
// END BLOCK 4
// ============================================================

    // ============================================================
    // BLOCK 2: ADD stopPharmaNetScan FUNCTION
    // ============================================================
    function stopPharmaNetScan(reason = "User cancelled") {
        addLog(`[PharmaNet] Stopping scan: ${reason}`);
        // Update the state to inactive and provide a final status message
        updatePharmaNetStatus(`Scan stopped: ${reason}.`, {
            active: false,
            authWait: false, // Ensure auth wait is also cleared
            currentPhn: null,
            scanId: null // Clear the scan ID
            // Keep queue and index as they are for potential review, but scan is inactive
        });
        // No need to call updatePharmaNetButtonState here, updatePharmaNetStatus does it.
        alert(`PharmaNet scan stopped: ${reason}`);
    }
// ============================================================
// END BLOCK 2
// ============================================================
// ============================================================
// END BLOCK 3
// ============================================================

    // ============================================================
// BLOCK 4: ADD CareConnect/Login Page Logic
// ============================================================
// ============================================================
// BLOCK 3: REPLACE handleCareConnectPage FUNCTION
// ============================================================
// ============================================================
// BLOCK 5: REPLACE handleCareConnectPage FUNCTION
// ============================================================
    const PATIENT_TIMEOUT_MS = 90 * 1000; // 90 seconds per patient timeout

    async function handleCareConnectPage() {
    const currentUrl = window.location.href;
    addLog(`[PharmaNet CC Handler] Script running on: ${currentUrl}`);
    let state = getPharmaNetState();
    let stage = "Initialization"; // For logging

    // --- Check if this tab/page load is part of an active, intended scan ---
    stage = "Validating Scan Context";
    const urlParams = new URLSearchParams(window.location.search);
    const scanIdFromUrl = urlParams.get('clinistream_scan_id');

    if (!state.active || !scanIdFromUrl || scanIdFromUrl !== state.scanId) {
        addLog(`[PharmaNet CC Handler @ ${stage}] Exiting: Scan not active in state (${state.active}), Scan ID missing from URL (${!!scanIdFromUrl}), or URL ID (${scanIdFromUrl}) doesn't match state ID (${state.scanId}). Assuming manual navigation or stale state.`);
        // If state somehow got stuck as active but IDs don't match, clear it.
        if (state.active && scanIdFromUrl !== state.scanId) {
             addLog(`[PharmaNet CC Handler @ ${stage}] Clearing potentially stale active state due to Scan ID mismatch.`);
             clearPharmaNetState(); // Use the function that also updates the button in Oscar
        }
        return; // Do not proceed with automation
    }
    addLog(`[PharmaNet CC Handler @ ${stage}] Context validated (Active: ${state.active}, ScanID: ${state.scanId}).`);


    // --- Handle Authentication Page (id.gov.bc.ca) ---
    if (currentUrl.includes("id.gov.bc.ca/login/entry")) {
        // ... (Login handling logic remains the same as previous version) ...
        stage = "BC Services Login Page";
        if (!state.authWait) {
            updatePharmaNetStatus("Error: Unexpectedly redirected to login. Scan stopped.", { active: false, authWait: false, scanId: null });
            alert("CareConnect session may have expired during the scan. Please restart the PharmaNet scan from Oscar.");
            return;
        }
        updatePharmaNetStatus("Waiting for manual BC Services Card login...");
        const timeRemaining = ((AUTH_TIMEOUT_MS - (Date.now() - state.authTimestamp)) / 1000).toFixed(0);
        addLog(`[PharmaNet CC Handler @ ${stage}] Waiting for login. Timeout in ${timeRemaining}s`);
        if (Date.now() - state.authTimestamp > AUTH_TIMEOUT_MS) {
            updatePharmaNetStatus("Error: Login timed out. Scan stopped.", { active: false, authWait: false, scanId: null });
            alert("BC Services Card login timed out. Please log in manually and restart the scan from Oscar.");
            return;
        }
        const checkLoginInterval = setInterval(() => {
            if (!window.location.href.includes("id.gov.bc.ca/login/entry")) {
                clearInterval(checkLoginInterval);
                addLog(`[PharmaNet CC Handler @ ${stage}] Detected navigation away from login page.`);
                let currentState = getPharmaNetState();
                if (currentState.active && currentState.scanId === scanIdFromUrl) { // Re-validate context
                     updatePharmaNetStatus("Login detected, proceeding in CareConnect...", { authWait: false });
                } else { addLog(`[PharmaNet CC Handler @ ${stage}] Scan cancelled or context changed while waiting for login.`); }
            } else {
                 let currentState = getPharmaNetState();
                 if (!currentState.active || currentState.scanId !== scanIdFromUrl) { // Re-validate context
                     clearInterval(checkLoginInterval);
                     addLog(`[PharmaNet CC Handler @ ${stage}] Scan cancelled or context changed while waiting for login.`);
                     return;
                 }
                 if (Date.now() - currentState.authTimestamp > AUTH_TIMEOUT_MS) {
                     clearInterval(checkLoginInterval);
                     updatePharmaNetStatus("Error: Login timed out. Scan stopped.", { active: false, authWait: false, scanId: null });
                     alert("BC Services Card login timed out. Please log in manually and restart the scan from Oscar.");
                 }
            }
        }, 3000);
        return; // Wait for user action or timeout
    }

    // --- Handle CareConnect Pages (health.careconnect.ca) ---
    if (currentUrl.includes("health.careconnect.ca")) {
        stage = "CareConnect Page Load";
        if (state.authWait) {
            addLog(`[PharmaNet CC Handler @ ${stage}] Login complete or already logged in.`);
            if (state.statusMessage.includes("Waiting for CareConnect Login")) {
                 updatePharmaNetStatus("Login successful, starting patient lookup...", { authWait: false });
            }
            state = getPharmaNetState(); // Re-fetch state
        }

        // Re-validate active state and scan ID after potential updates
        if (!state.active || state.scanId !== scanIdFromUrl) {
             addLog(`[PharmaNet CC Handler @ ${stage}] Scan no longer active or context changed after checking state again. Exiting.`);
             return;
        }

        // Validate queue and index
        stage = "Validating State";
        // ... (Queue/Index validation logic remains the same) ...
        if (!Array.isArray(state.queue) || state.queue.length === 0) { updatePharmaNetStatus("Error: Patient queue is invalid or empty. Scan stopped.", { active: false, scanId: null }); alert("Error: Patient queue is invalid or empty. Stopping PharmaNet scan."); return; }
        if (state.index >= state.queue.length) { updatePharmaNetStatus("Completed PharmaNet scan.", { active: false, scanId: null }); alert(`PharmaNet scan completed for ${state.queue.length} patients.`); return; }
        const currentPatient = state.queue[state.index];
        if (!currentPatient || !currentPatient.phn) { updatePharmaNetStatus(`Error: Invalid patient data at index ${state.index}. Scan stopped.`, { active: false, scanId: null }); alert(`Error in patient queue at index ${state.index}. Stopping PharmaNet scan.`); return; }


        // --- Patient Processing Start & Timeout Check ---
        stage = "Starting Patient Processing";
        if (state.currentPhn !== currentPatient.phn || !state.currentPatientStartTime) {
            // Starting a new patient or resuming after reload
            addLog(`[PharmaNet CC Handler @ ${stage}] Starting processing for PHN: ${currentPatient.phn}`);
            updatePharmaNetStatus(`Processing ${currentPatient.phn} (${state.index + 1}/${state.queue.length})...`, {
                currentPhn: currentPatient.phn,
                currentPatientStartTime: Date.now() // Set start time for this patient
            });
            state = getPharmaNetState(); // Refresh state after update
        } else {
            // Continuing processing for the same patient
            const elapsedPatientTime = Date.now() - state.currentPatientStartTime;
            addLog(`[PharmaNet CC Handler @ ${stage}] Continuing processing for PHN: ${currentPatient.phn} (${(elapsedPatientTime / 1000).toFixed(1)}s elapsed)`);
            if (elapsedPatientTime > PATIENT_TIMEOUT_MS) {
                addLog(`[PharmaNet CC Handler Error @ ${stage}] Patient processing timed out for ${currentPatient.phn} (> ${PATIENT_TIMEOUT_MS / 1000}s). Skipping.`);
                updatePharmaNetStatus(`Timeout for ${currentPatient.phn}. Skipping.`, {
                    index: state.index + 1, // Move to next index
                    currentPhn: null,       // Clear current patient tracking
                    currentPatientStartTime: null
                 });
                 alert(`Processing timed out for patient ${currentPatient.phn}. Skipping to the next.`);
                 await delay(1000);
                 // Navigate back to search page for the next patient
                 window.location.href = `https://health.careconnect.ca/Welcome/Index?clinistream_scan_id=${state.scanId}`;
                 return;
            }
        }


        // --- CareConnect Automation State Machine ---
        try {
            // Check for stages in reverse order of likelihood/finality
            // Stage 4: Results Table Check
            stage = "Checking for Results Table (Stage 4)";
            // ... (Results scraping logic remains the same) ...
            // **Important:** On success, navigate back WITH the scanId
            const resultsTableBody = document.querySelector('table[role="grid"] > tbody[role="rowgroup"]');
            if (resultsTableBody && resultsTableBody.querySelector('tr.customClientRowTemplate')) {
                 addLog(`[PharmaNet CC Handler @ ${stage}] Results table found. Scraping data...`);
                 await delay(2000);
                 const medications = [];
                 const rows = resultsTableBody.querySelectorAll('tr.customClientRowTemplate');
                 rows.forEach(row => { /* ... (Scraping logic) ... */ });
                 addLog(`[PharmaNet CC Handler @ ${stage}] Scraped ${medications.length} medication records for ${currentPatient.phn}.`);
                 savePharmaNetResult(currentPatient.phn, medications);
                 const nextIndex = state.index + 1;
                 updatePharmaNetStatus(`Finished ${currentPatient.phn}. Moving to next...`, { index: nextIndex, currentPhn: null, currentPatientStartTime: null }); // Clear patient tracking
                 await delay(1500);
                 window.location.href = `https://health.careconnect.ca/Welcome/Index?clinistream_scan_id=${state.scanId}`; // Navigate WITH scanId
                 return;
            }


            // Stage 3: Location/Search Button Check
            stage = "Checking for Location/Search Button (Stage 3)";
            // ... (Location selection logic using 'Click and Enter' remains the same) ...
            // **Important:** Ensure errors here throw to the catch block
             const searchPharmaNetButton = document.querySelector('#medications-checkpoint-submit');
             const locationContainer = document.querySelector('#select2-CurrentAccessLocation-container');
             if (searchPharmaNetButton || locationContainer) {
                  addLog(`[PharmaNet CC Handler @ ${stage}] On Medications page.`);
                  let locationSelected = false;
                  try {
                      const locationDropdownTrigger = await waitForSelector('#select2-CurrentAccessLocation-container', 10000);
                      const existingSelectionRemove = locationDropdownTrigger.closest('.select2-selection').querySelector('.select2-selection__choice__remove');
                      if (!existingSelectionRemove) {
                          addLog(`[PharmaNet CC Handler @ ${stage}] No location selected, attempting 'Click and Enter'.`);
                          locationDropdownTrigger.click(); await delay(1000);
                          const searchField = document.querySelector('.select2-search__field');
                          if (searchField) {
                              searchField.focus(); await delay(500);
                              if (simulateEnterKeyPress(searchField)) {
                                  await delay(1500);
                                  const newSelectionRemove = locationDropdownTrigger.closest('.select2-selection').querySelector('.select2-selection__choice__remove');
                                  if (newSelectionRemove) { locationSelected = true; addLog(`[PharmaNet CC Handler @ ${stage}] Location selected via Enter.`); }
                                  else { addLog(`[PharmaNet CC Handler Warning @ ${stage}] Location selection via Enter failed.`); }
                              } else { addLog(`[PharmaNet CC Handler Warning @ ${stage}] Failed to simulate Enter.`); }
                          } else { addLog(`[PharmaNet CC Handler Warning @ ${stage}] Could not find Select2 search field.`); }
                      } else { addLog(`[PharmaNet CC Handler @ ${stage}] Location already selected.`); locationSelected = true; }
                  } catch (locationError) { addLog(`[PharmaNet CC Handler Warning @ ${stage}] Error during location selection: ${locationError.message}.`); }

                  if (locationSelected) {
                      const finalSearchButton = await waitForSelector('#medications-checkpoint-submit', 5000);
                      if (finalSearchButton) {
                          addLog(`[PharmaNet CC Handler @ ${stage}] Found Search PharmaNet button.`); await delay(500);
                          finalSearchButton.click(); addLog(`[PharmaNet CC Handler @ ${stage}] Clicked Search PharmaNet button.`);
                          updatePharmaNetStatus(`Searching PharmaNet for ${currentPatient.phn}...`); // Keep currentPatientStartTime
                      } else { throw new Error("Search PharmaNet button not found after location selection."); }
                  } else { throw new Error("Location not selected, cannot proceed."); }
                  return; // Wait for results table
             }


            // Stage 2: Accept Button Check
            stage = "Checking for Accept Button (Stage 2)";
            // ... (Accept button logic remains the same) ...
            try {
                const acceptButton = await waitForSelector('#SearchResultAcceptButton:not(.displayNone)', 20000);
                addLog(`[PharmaNet CC Handler @ ${stage}] Found Accept button.`);
                await delay(1000); acceptButton.click(); addLog(`[PharmaNet CC Handler @ ${stage}] Clicked Accept button.`);
                updatePharmaNetStatus(`Accepted patient ${currentPatient.phn}, loading medications...`); // Keep currentPatientStartTime
                return; // Wait for navigation
            } catch (e) { addLog(`[PharmaNet CC Handler @ ${stage}] Accept button not found or timed out. Proceeding...`); }


            // Stage 1: Search Input Check
            stage = "Checking for Search Input (Stage 1)";
            // ... (Search input logic remains the same) ...
            // **Important:** Ensure it only runs on Welcome/Index
            const searchInput = document.querySelector('#search');
            const goButton = document.querySelector('#search-button');
            if (searchInput && goButton && currentUrl.toLowerCase().includes("/welcome/index")) {
                 addLog(`[PharmaNet CC Handler @ ${stage}] On search page for PHN: ${currentPatient.phn}`);
                 if (searchInput.value !== currentPatient.phn) {
                     searchInput.value = currentPatient.phn; addLog(`[PharmaNet CC Handler @ ${stage}] Entered PHN ${currentPatient.phn}`);
                 } else { addLog(`[PharmaNet CC Handler @ ${stage}] PHN ${currentPatient.phn} already in input.`); }
                 await delay(500); goButton.click(); addLog(`[PharmaNet CC Handler @ ${stage}] Clicked GO button.`);
                 // Keep currentPatientStartTime as we move to next stage
                 return; // Wait for next page/state
            }

            // Fallback: Unexpected State
            stage = "Unexpected State";
            addLog(`[PharmaNet CC Handler Warning @ ${stage}] Script is on an unexpected CareConnect page state (URL: ${currentUrl}). Trying to return to search...`);
            updatePharmaNetStatus(`Unexpected page state for ${currentPatient.phn}. Attempting recovery.`);
            await delay(3000);
            window.location.href = `https://health.careconnect.ca/Welcome/Index?clinistream_scan_id=${state.scanId}`; // Navigate WITH scanId

        } catch (error) {
            // General error handling for the current patient
            addLog(`[PharmaNet CC Handler Error @ ${stage}] Failed processing PHN ${state.currentPhn || 'unknown'}: ${error.message} ${error.stack}`);
            updatePharmaNetStatus(`Error for ${state.currentPhn}: ${error.message}. Skipping.`, {
                index: state.index + 1, // Move to next index
                currentPhn: null,       // Clear current patient tracking
                currentPatientStartTime: null
             });
             alert(`An error occurred while processing PHN ${state.currentPhn} during stage [${stage}]:\n${error.message}\nSkipping to the next patient.`);
             await delay(1500);
             // Try to navigate back to search page WITH scanId to recover for the next patient
             window.location.href = `https://health.careconnect.ca/Welcome/Index?clinistream_scan_id=${state.scanId}`;
        }
    } else {
        addLog(`[PharmaNet CC Handler Warning] Script running on unexpected URL: ${currentUrl}`);
    }
}

// ============================================================
// END BLOCK 5
// ============================================================
// ============================================================
// END BLOCK 3
// ============================================================
// ============================================================
// END BLOCK 4
// ============================================================


    // --- Template Functions ---
    function getFormattedDateTime() {
        const now = new Date();
        const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
        const date = now.toLocaleDateString('en-US', options);
        const time = now.toTimeString().slice(0, 5);
        return `${date}; ${time}`;
    }
    function getReasonForEncounter() {
        const urlParams = new URLSearchParams(window.location.search);
        const reason = urlParams.get('reason');
        return reason ? decodeURIComponent(reason.replace(/\+/g, ' ')) : '[Reason Not Found]';
    }
    function insertTemplateText(templateId) {
        const template = encounterTemplates.find(t => t.id === templateId);
        if (!template) {
            alert('Template not found');
            return;
        }
        const textarea = getEncounterNoteTextarea();
        if (!textarea) {
            alert('Cannot find encounter note textarea');
            return;
        }
        let text = template.content;
        text = text.replace(/{{DATE_TIME}}/g, getFormattedDateTime());
        text = text.replace(/{{REASON}}/g, getReasonForEncounter());
        if (textarea.selectionStart || textarea.selectionStart === 0) {
            const startPos = textarea.selectionStart;
            const endPos = textarea.selectionEnd;
            let prefix = textarea.value.substring(0, startPos);
            if (prefix.length > 0 && !prefix.endsWith('\n') && !prefix.endsWith('\r\n')) {
                prefix += '\n\n';
            }
            textarea.value = prefix + text + textarea.value.substring(endPos);
            textarea.selectionStart = startPos + text.length;
            textarea.selectionEnd = startPos + text.length;
        } else {
            if (textarea.value.length > 0 && !textarea.value.endsWith('\n') && !textarea.value.endsWith('\r\n')) {
                textarea.value += '\n\n';
            }
            textarea.value += text;
        }
        textarea.focus();
        addLog(`[Templates] Inserted template: ${template.name}`);
    }
    function getEncounterNoteTextarea() {
        const textareas = document.querySelectorAll(AI_TEXTAREA_SELECTOR);
        if (textareas.length === 0) {
            return null;
        }
        return textareas[textareas.length - 1];
    }
    function addTemplate(name, category, content) {
        const id = 'template_' + name.toLowerCase().replace(/[^a-z0-9]/g, '_') + '_' + Date.now().toString(36);
        encounterTemplates.push({
            id,
            name,
            category,
            content
        });
        saveEncounterTemplates();
        return id;
    }
    function editTemplate(id, name, category, content) {
        const index = encounterTemplates.findIndex(t => t.id === id);
        if (index === -1) {
            return false;
        }
        encounterTemplates[index] = {
            id,
            name,
            category,
            content
        };
        saveEncounterTemplates();
        return true;
    }
    function deleteTemplate(id) {
        const index = encounterTemplates.findIndex(t => t.id === id);
        if (index === -1) {
            return false;
        }
        encounterTemplates.splice(index, 1);
        saveEncounterTemplates();
        return true;
    }

    // --- CSS STYLES ---
    const mainColor = "#4682B4"; // Oscar blue color
    const unifiedCSS = `
        /* --- Core Modal Styles --- */
        #modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background-color: rgba(0, 0, 0, 0.4);
            z-index: 9999;
            font-family: sans-serif;
        }
        #modal {
            position: absolute;
            background-color: #ffffff;
            padding: 0;
            border-radius: 8px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.2);
            min-width: 500px;
            max-width: 800px;
            width: auto;
            max-height: 85vh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        #titlebar {
            background-color: ${mainColor};
            color: white;
            padding: 8px 12px;
            border-bottom: 1px solid #ccc;
            font-size: 15px;
            font-weight: bold;
            cursor: move;
            flex-shrink: 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            user-select: none;
            -webkit-user-select: none;
            -moz-user-select: none;
        }
        #close-btn {
            background: none;
            border: none;
            font-size: 20px;
            line-height: 1;
            cursor: pointer;
            color: white;
            padding: 0 5px;
        }
        #close-btn:hover {
            color: #f0f0f0;
        }
        #tabs {
            display: flex;
            border-bottom: 1px solid #ccc;
            background-color: #f0f0f0;
            padding: 0 15px;
            border-top-left-radius: 5px;
            border-top-right-radius: 5px;
            flex-shrink: 0;
            flex-wrap: wrap;
        }
        .tab-button {
            padding: 9px 14px;
            border: none;
            background-color: transparent;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            color: #555;
            border-bottom: 3px solid transparent;
            margin-bottom: -1px;
            transition: all 0.2s ease-in-out;
        }
        .tab-button:hover:not(.active):not(:disabled) {
            color: #000;
            background-color: #eee;
        }
        .tab-button.active {
            color: ${mainColor};
            border-bottom-color: ${mainColor};
            font-weight: 600;
        }
        .tab-button:disabled {
            color: #aaa;
            cursor: not-allowed;
        }
        #content {
            flex-grow: 1;
            overflow-y: auto;
            padding: 15px;
            background-color: #fff;
            min-height: 200px;
        }
        .tab-pane {
            display: none;
        }
        .tab-pane.active {
            display: block;
        }
        .tab-pane h3 {
            margin-top: 0;
            color: #333;
            font-size: 1.1em;
            border-bottom: 1px solid #eee;
            padding-bottom: 5px;
            margin-bottom: 10px;
        }
        #footer {
            border-top: 1px solid #ccc;
            padding: 8px 12px;
            background-color: #f0f0f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-shrink: 0;
            flex-wrap: wrap;
        }
        #footer-version {
            font-size: 11px;
            color: #888;
            margin-bottom: 4px;
        }
        #footer-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-top: 4px;
        }
        #footer-actions button {
            font-size: 11px;
            padding: 3px 8px;
            cursor: pointer;
            border-radius: 3px;
            border: none;
            background-color: ${mainColor};
            color: white;
        }
        #footer-actions button:hover {
            background-color: #3a6d99;
        }
        #footer-actions button:disabled {
            background-color: #f5f5f5;
            color: #aaa;
            cursor: not-allowed;
        }
        #footer-actions .scan-progress {
            display: inline-block;
            margin-left: 8px;
            font-size: 0.9em;
            color: #555;
        }

        /* --- Billing Tab Styles --- */
        #tab-billing .billing-form-section {
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px dashed #eee;
        }
        #tab-billing label {
            font-weight: bold;
            margin-right: 5px;
            font-size: 0.9em;
            display: inline-block;
            min-width: 90px;
            margin-bottom: 3px;
            vertical-align: middle;
        }
        #tab-billing input[type="text"],
        #tab-billing select {
            padding: 5px 7px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 0.9em;
            margin-bottom: 6px;
            box-sizing: border-box;
            vertical-align: middle;
            display: inline-block;
            width: calc(100% - 100px);
        }
        #tab-billing select#billingSubType {
            width: calc(100% - 100px);
        }
        #tab-billing input#billingServiceCode,
        #tab-billing input#billingUnits {
            width: 80px;
        }
        #tab-billing input#serviceStartTime,
        #tab-billing input#serviceEndTime {
            width: 80px;
        }
        #tab-billing #icd9-search-input {
            width: calc(100% - 100px);
            margin-bottom: 5px;
        }
        #billing-additional-fields {
            margin-top: 8px;
            padding-top: 8px;
            border-top: 1px dotted #eee;
            display: none;
        }
        #billing-additional-fields label {
            min-width: 90px;
        }
        #icd9-selected-codes {
            margin-top: 8px;
            border-top: 1px dashed #eee;
            padding-top: 8px;
            min-height: 40px;
        }
        #icd9-selected-codes .chosen-code {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.9em;
            padding: 4px 2px;
            border-bottom: 1px dotted #f0f0f0;
            background-color: #f9f9f9;
            border-radius: 3px;
            margin-bottom: 3px;
        }
        #icd9-selected-codes .chosen-code span {
            flex-grow: 1;
            margin-right: 10px;
            line-height: 1.3;
        }
        #icd9-selected-codes .chosen-code span strong {
            color: #0056b3;
        }
        #icd9-selected-codes .chosen-code button {
            font-size: 0.85em;
            padding: 1px 5px;
            cursor: pointer;
            background: #e0e0e0;
            border: 1px solid #bbb;
            border-radius: 3px;
            line-height: 1;
        }
        #icd9-selected-codes .chosen-code button:hover {
            background: #d0d0d0;
        }
        #icd9-selected-codes .placeholder {
            font-style: italic;
            color: #888;
            font-size: 0.9em;
        }
        #tab-billing .billing-actions {
            text-align: right;
            margin-top: 15px;
        }
        #tab-billing #save-billing-info-btn {
            padding: 8px 15px;
            font-size: 13px;
            background-color: #28a745;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        #tab-billing #save-billing-info-btn:hover {
            background-color: #218838;
        }

        /* --- ICD9 Box Styles --- */
        .dx-suggestion-box {
            position: absolute;
            background: #fff;
            border: 1px solid #aaa;
            z-index: 10001;
            max-height: 200px;
            overflow-y: auto;
            min-width: 300px;
            display: none;
            border-radius: 4px;
            box-shadow: 0 3px 8px rgba(0,0,0,0.25);
            font-family: sans-serif;
            font-size: 13px;
        }
        .dx-suggestion-box div {
            padding: 6px 10px;
            cursor: pointer;
            border-bottom: 1px solid #f0f0f0;
            line-height: 1.3;
        }
        .dx-suggestion-box div:last-child {
            border-bottom: none;
        }
        .dx-suggestion-box div:hover {
            background-color: #f0f8ff;
        }
        .dx-suggestion-box div strong {
            font-weight: bold;
            color: #0056b3;
            margin-right: 5px;
        }
        .dx-suggestion-box div.selected {
            background-color: #007bff;
            color: #fff;
        }
        .dx-suggestion-box div.selected strong {
            color: #fff;
        }
        .dx-suggestion-box .dx-loading,
        .dx-suggestion-box .dx-no-results {
            padding: 8px 10px;
            color: #666;
            font-style: italic;
        }

        /* --- Individual Bill Button styles --- */
        .bill-button {
            background-color:${mainColor};
            color:#fff;
            border:none;
            margin-left:4px;
            padding: 4px 7px;
            border-radius:4px;
            cursor:pointer;
            font-size:11px;
            vertical-align: middle;
            transition: background-color 0.2s ease;
        }
        .bill-button:hover {
            background-color:#3a6d99;
        }
        .bill-button.modify {
            background-color: #28a745;
        }
        .bill-button.modify:hover {
            background-color: #218838;
        }
        .bill-button.submitted {
            background-color: #dc3545;
            cursor: not-allowed;
            opacity: 0.7;
        }
        .bill-button.error {
            background-color: #f39c12;
            color: #fff;
        }

        /* --- Log Tab Styles --- */
        #tab-log {
            display: flex;
            flex-direction: column;
            height: 350px;
        }
        #log-content {
            flex-grow: 1;
            white-space: pre-wrap;
            margin: 0;
            overflow-y: auto;
            background: #fff;
            padding: 10px;
            font-family: monospace;
            font-size: 11px;
            color: #333;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        #log-controls {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        #log-controls button {
            background: ${mainColor};
            color: #fff;
            border: none;
            padding: 6px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
        }
        #log-controls button:hover {
            background: #3a6d99;
        }

        /* --- Multi-Bill Tab Styles --- */
        #tab-multibill {
            display: flex;
            flex-direction: column;
            padding: 0;
        }
        #multibill-content {
            overflow: auto;
            flex-grow: 1;
            margin-bottom: 15px;
            padding: 0 15px;
        }
        #multibill-content table {
            width:100%;
            border-collapse:collapse;
            font-size: 12px;
        }
        #multibill-content th,
        #multibill-content td {
            border: 1px solid #ddd;
            padding: 4px 6px;
            text-align: left;
            vertical-align: top;
            white-space: nowrap;
        }
        #multibill-content th {
            background-color: ${mainColor};
            color: white;
            font-weight: bold;
            position: sticky;
            top: 0;
            z-index: 10;
        }
        #multibill-content input[type="text"],
        #multibill-content select {
            width: 98%;
            padding: 4px;
            font-size: 11px;
            border: 1px solid #ccc;
            border-radius: 3px;
            box-sizing: border-box;
            margin: 0;
        }
        #multibill-content select {
            height: 26px;
        }
        #multibill-content .mb-apt,
        #multibill-content .mb-units {
            width: 50px !important;
            text-align: center;
        }
        #multibill-content .mb-svc {
            width: 70px !important;
        }
        #multibill-content .mb-start,
        #multibill-content .mb-end {
            width: 60px !important;
        }
        #multibill-content .mb-dx1,
        #multibill-content .mb-dx2,
        #multibill-content .mb-dx3 {
            width: 70px !important;
        }
        #multibill-content .mb-subtype select {
            width: 150px !important;
            min-width: 120px;
        }
        #multibill-content .mb-pat {
            width: 150px !important;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        #multibill-actions {
            text-align: right;
            flex-shrink: 0;
            border-top: 1px solid #ccc;
            padding: 15px;
        }
        #multibill-actions button {
            margin-left: 8px;
            padding: 6px 12px;
            font-size: 13px;
            background-color: ${mainColor};
            color: white;
            border: none;
            border-radius: 4px;
        }
        #multibill-actions button:hover {
            background-color: #3a6d99;
        }
        #multibill-actions button.save-btn {
            background-color: #28a745;
        }
        #multibill-actions button.save-btn:hover {
            background-color: #218838;
        }

        /* --- Floating Action Button Styles --- */
        #float-btn {
            position: fixed;
            bottom: 20px;
            right: 20px;
            width: 50px;
            height: 50px;
            background-color: ${mainColor};
            color: white;
            border-radius: 50%;
            border: none;
            box-shadow: 2px 2px 10px rgba(0,0,0,0.3);
            font-size: 28px;
            line-height: 50px;
            text-align: center;
            cursor: pointer;
            z-index: 99990;
            transition: background-color 0.2s ease;
            display: none;
        }
        #float-btn:hover {
            background-color: #3a6d99;
        }
        #float-btn .scan-progress {
            font-size: 10px;
            line-height: 1;
            position: absolute;
            bottom: 2px;
            left: 0;
            right: 0;
            text-align: center;
            color: white;
            background: rgba(0,0,0,0.5);
            padding: 1px 0;
            border-radius: 3px;
        }

        /* --- AI Helper Specific Styles --- */
        .textarea-container {
            position: relative;
            display: block;
            margin-bottom: 5px;
        }
        .ai-trigger-button {
            position: absolute;
            top: 5px;
            right: 5px;
            width: 28px;
            height: 28px;
            background-color: ${mainColor};
            color: white;
            border: none;
            border-radius: 50%;
            font-size: 15px;
            line-height: 28px;
            text-align: center;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.2);
            transition: background-color 0.3s ease, transform 0.1s ease;
            z-index: 50;
            user-select: none;
        }
        .ai-trigger-button:hover {
            background-color: #3a6d99;
        }
        .ai-trigger-button:active {
            transform: scale(0.95);
        }
        .ai-trigger-button.loading {
            background-color: #ffc107;
            cursor: default;
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        #tab-ai {
            font-size: 13px;
            line-height: 1.45;
            color: #333;
        }
        #ai-controls {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            padding-bottom: 8px;
            border-bottom: 1px solid #eee;
        }
        #ai-model-select {
            font-size: 11px;
            padding: 3px 5px;
            max-width: 200px;
        }
        #ai-error-display {
            color: #dc3545;
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            padding: 8px;
            border-radius: 4px;
            margin-bottom: 10px;
            font-size: 12px;
            display: none;
        }
        #ai-tabs {
            display: flex;
            border-bottom: 1px solid #ddd;
            margin-bottom: 10px;
            background-color: #f8f9fa;
        }
        .ai-tab-button {
            padding: 7px 12px;
            border: none;
            background: none;
            cursor: pointer;
            font-size: 12px;
            color: #495057;
            border-bottom: 2px solid transparent;
            margin-bottom: -1px;
        }
        .ai-tab-button.active {
            color: ${mainColor};
            border-bottom-color: ${mainColor};
            font-weight: bold;
        }
        .ai-tab-button:hover:not(.active):not(:disabled) {
            color: ${mainColor};
            background-color: #e9ecef;
        }
        .ai-tab-button:disabled {
            color: #adb5bd;
            cursor: not-allowed;
        }
        .ai-tab-panel {
            display: none;
            white-space: pre-wrap;
            border: 1px solid #eee;
            padding: 10px;
            border-radius: 4px;
            background-color: #fff;
            min-height: 150px;
            max-height: 40vh;
            overflow-y: auto;
            font-size: 12.5px;
        }
        .ai-tab-panel.active {
            display: block;
        }
        .ai-comparison-container {
            display: flex;
            gap: 15px;
        }
        .ai-comparison-panel {
            flex: 1;
            border: 1px solid #e0e0e0;
            padding: 12px;
            border-radius: 4px;
            background-color: #f9f9f9;
        }
        .ai-comparison-panel h4 {
            margin-top: 0;
            font-size: 12px;
            color: #333;
            border-bottom: 1px solid #ddd;
            padding-bottom: 5px;
            margin-bottom: 8px;
        }
        .ai-comparison-panel .comparison-content {
            font-size: 12px;
            line-height: 1.4;
            max-height: 250px;
            overflow-y: auto;
            white-space: pre-wrap;
        }
        .ai-comparison-panel button.select-btn {
            display: block;
            margin-top: 8px;
            width: 100%;
            background-color: #28a745;
            color: white;
            border: none;
            padding: 5px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 11px;
        }
        .ai-comparison-panel button.select-btn:hover {
            background-color: #218838;
        }
        .ai-comparison-panel .error-msg {
            color: red;
            font-style: italic;
            font-size: 11px;
        }
        #ai-actions {
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1px solid #eee;
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 8px;
        }
        #ai-actions button {
            background-color: ${mainColor};
            color: white;
            border: none;
            border-radius: 4px;
            padding: 5px 12px;
            cursor: pointer;
            font-size: 12px;
        }
        #ai-actions button:hover:not(:disabled) {
            background-color: #3a6d99;
        }
        #ai-actions button:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
        #ai-actions .ai-action-options {
            display: inline-flex;
            gap: 6px;
            align-items: center;
            vertical-align: middle;
            margin-left: 5px;
        }
        #ai-actions .ai-action-options button {
            padding: 4px 8px;
            font-size: 11px;
        }
        #ai-actions .ai-action-options input[type="text"] {
            width: 120px;
            font-size: 11px;
            padding: 3px 5px;
        }
        #ai-actions .ai-action-options .cancel-btn {
            background-color: #f8f9fa;
            border-color: #ced4da;
            color: #495057;
        }
        #ai-actions .ai-action-options .cancel-btn:hover {
            background-color: #e2e6ea;
        }
        #ai-actions .ai-action-options .loading-span {
            font-style: italic;
            color: #555;
            font-size: 11px;
        }

        /* --- Encounter Templates Tab Styles --- */
        #tab-templates {
            padding: 15px;
        }
        #template-category-tabs {
            display: flex;
            border-bottom: 1px solid #ddd;
            margin-bottom: 15px;
        }
        .template-category-tab {
            padding: 7px 12px;
            background: none;
            border: none;
            cursor: pointer;
            color: #555;
            font-size: 13px;
            position: relative;
            border-bottom: 2px solid transparent;
        }
        .template-category-tab.active {
            color: ${mainColor};
            border-bottom-color: ${mainColor};
            font-weight: bold;
        }
        .template-category-tab:hover:not(.active) {
            background-color: #f1f1f1;
        }
        .template-list {
            max-height: 300px;
            overflow-y: auto;
            margin-bottom: 15px;
            border: 1px solid #eee;
            border-radius: 4px;
        }
        .template-list-empty {
            padding: 20px;
            text-align: center;
            color: #777;
            font-style: italic;
        }
        .template-item {
            padding: 10px;
            border-bottom: 1px solid #eee;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .template-item:last-child {
            border-bottom: none;
        }
        .template-item:hover {
            background-color: #f5f5f5;
        }
        .template-name {
            flex-grow: 1;
        }
        .template-actions {
            display: flex;
            gap: 5px;
        }
        .template-actions button {
            padding: 3px 8px;
            font-size: 11px;
            background-color: ${mainColor};
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }
        .template-actions button:hover {
            background-color: #3a6d99;
        }
        .template-actions button.edit-btn {
            background-color: #6c757d;
        }
        .template-actions button.edit-btn:hover {
            background-color: #5a6268;
        }
        .template-actions button.delete-btn {
            background-color: #dc3545;
        }
        .template-actions button.delete-btn:hover {
            background-color: #c82333;
        }
        .template-edit-form {
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 4px;
            background-color: #f9f9f9;
        }
        .template-edit-form h4 {
            margin-top: 0;
            margin-bottom: 15px;
            font-size: 14px;
            color: #333;
        }
        .template-edit-form label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .template-edit-form input,
        .template-edit-form select,
        .template-edit-form textarea {
            width: 100%;
            padding: 8px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 13px;
        }
        .template-edit-form textarea {
            min-height: 150px;
            font-family: monospace;
        }
        .template-edit-form .template-form-actions {
            text-align: right;
        }
        .template-edit-form .template-form-actions button {
            margin-left: 10px;
            padding: 8px 15px;
        }
        .template-variables {
            margin-top: 10px;
            padding: 10px;
            background-color: #f0f0f0;
            border-radius: 4px;
            font-size: 12px;
        }
        .template-variables h5 {
            margin-top: 0;
            font-size: 12px;
            margin-bottom: 5px;
        }
        .template-variables code {
            background-color: #e0e0e0;
            padding: 2px 4px;
            border-radius: 3px;
            font-family: monospace;
        }
        .template-variables .variable-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 5px;
        }
        .template-variables .insert-variable-btn {
            background-color: #f0f0f0;
            border: 1px solid #ccc;
            border-radius: 3px;
            padding: 3px 8px;
            font-size: 12px;
            cursor: pointer;
        }
        .template-variables .insert-variable-btn:hover {
            background-color: #e0e0e0;
        }
        .model-selection {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-bottom: 20px;
        }
        .model-selection label {
            display: block;
            margin-bottom: 3px;
            font-weight: bold;
        }
        .model-selection select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .exam-section {
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 10px;
            background-color: #f9f9f9;
        }
        .exam-section h4 {
            margin-top: 0;
            margin-bottom: 8px;
            color: #333;
            font-size: 14px;
            border-bottom: 1px solid #eee;
            padding-bottom: 5px;
        }
        .exam-options {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-top: 8px;
        }
        .exam-option {
            background-color: #fff;
            border: 1px solid #ccc;
            border-radius: 3px;
            padding: 3px 8px;
            font-size: 12px;
            cursor: pointer;
            user-select: none;
        }
        .exam-option:hover {
            background-color: #f0f0f0;
        }
        .exam-option.selected {
            background-color: #d4edda;
            border-color: #c3e6cb;
        }
        .exam-option.selected.abnormal {
            background-color: #fff3cd;
            border-color: #ffeeba;
        }
        .exam-option.selected.negative {
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        .exam-preview {
            margin-top: 10px;
            padding: 8px;
            background-color: #fff;
            border: 1px solid #ddd;
            border-radius: 3px;
            min-height: 40px;
            font-size: 13px;
        }

        /* --- Encounter Mini Toolbar --- */
        .template-mini-toolbar {
            position: absolute;
            z-index: 5000;
            display: flex;
            background-color: #f0f0f0;
            border: 1px solid #ccc;
            border-radius: 4px;
            padding: 3px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }
        .template-mini-toolbar button {
            padding: 3px 8px;
            margin: 0 2px;
            background-color: ${mainColor};
            color: white;
            border: none;
            border-radius: 3px;
            font-size: 11px;
            cursor: pointer;
        }
        .template-mini-toolbar button:hover {
            background-color: #3a6d99;
        }
        .template-mini-toolbar button.close-btn {
            background-color: #6c757d;
        }
        .template-mini-toolbar .template-mini-menu {
            position: relative;
        }
        .template-mini-dropdown {
            position: absolute;
            top: 100%;
            left: 0;
            background-color: white;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
            z-index: 5001;
            min-width: 150px;
            max-height: 300px;
            overflow-y: auto;
            display: none;
        }
        .template-mini-dropdown.active {
            display: block;
        }
        .template-mini-dropdown-category {
            padding: 5px 10px;
            font-weight: bold;
            background-color: #f0f0f0;
            border-bottom: 1px solid #ddd;
        }
        .template-mini-dropdown-item {
            padding: 5px 10px;
            cursor: pointer;
        }
        .template-mini-dropdown-item:hover {
            background-color: #f0f8ff;
        }

        /* --- Settings Tab Styles --- */
        #tab-settings .settings-section {
            margin-bottom: 20px;
        }
        #tab-settings .settings-section label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        #tab-settings .settings-section input[type="password"] {
            width: 100%;
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        #tab-settings .settings-section button {
            background-color: ${mainColor};
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 10px;
        }
        #tab-settings .settings-section button:hover {
            background-color: #3a6d99;
        }
        #tab-settings .settings-actions {
            text-align: right;
            margin-top: 20px;
            padding-top: 15px;
            border-top: 1px solid #eee;
        }
        #tab-settings .settings-actions button {
            background-color: ${mainColor};
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 4px;
            cursor: pointer;
        }
        #tab-settings .settings-actions button:hover {
            background-color: #3a6d99;
        }`;

    // Footer buttons CSS
    const footerButtonsCSS = `
        #footer-actions {
            display: flex;
            gap: 8px;
        }
        #footer-actions .action-btn {
            font-size: 12px;
            padding: 5px 10px;
            cursor: pointer;
            border-radius: 4px;
            border: none;
            background-color: ${mainColor};
            color: white;
            min-width: 100px;
        }
        #footer-actions .action-btn:hover {
            background-color: #3a6d99;
        }
        #footer-actions .batch-btn {
            background-color: #6c757d;
            min-width: 120px;
        }
        #footer-actions .batch-btn:hover {
            background-color: #5a6268;
        }
        #footer-actions .save-btn {
            background-color: #28a745;
            min-width: 120px;
        }
        #footer-actions .save-btn:hover {
            background-color: #218838;
        }
        .template-variables .variable-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 5px;
        }
        .template-variables .insert-variable-btn {
            background-color: #f0f0f0;
            border: 1px solid #ccc;
            border-radius: 3px;
            padding: 3px 8px;
            font-size: 12px;
            cursor: pointer;
        }
        .template-variables .insert-variable-btn:hover {
            background-color: #e0e0e0;
        }
        .model-selection {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-bottom: 20px;
        }
        .model-selection label {
            display: block;
            margin-bottom: 3px;
            font-weight: bold;
        }
        .model-selection select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .exam-section {
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 10px;
            background-color: #f9f9f9;
        }
        .exam-section h4 {
            margin-top: 0;
            margin-bottom: 8px;
            color: #333;
            font-size: 14px;
            border-bottom: 1px solid #eee;
            padding-bottom: 5px;
        }
        .exam-options {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-top: 8px;
        }
        .exam-option {
            background-color: #fff;
            border: 1px solid #ccc;
            border-radius: 3px;
            padding: 3px 8px;
            font-size: 12px;
            cursor: pointer;
            user-select: none;
        }
        .exam-option:hover {
            background-color: #f0f0f0;
        }
        .exam-option.selected {
            background-color: #d4edda;
            border-color: #c3e6cb;
        }
        .exam-option.selected.abnormal {
            background-color: #fff3cd;
            border-color: #ffeeba;
        }
        .exam-option.selected.negative {
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        .exam-preview {
            margin-top: 10px;
            padding: 8px;
            background-color: #fff;
            border: 1px solid #ddd;
            border-radius: 3px;
            min-height: 40px;
            font-size: 13px;
        }`;

    const fullCSS = unifiedCSS + footerButtonsCSS;

    // --- Billing Code Maps ---
    const codeMap = {
        office_visit: [
            {minAge:0, maxAge:1, code:'00111'},
            {minAge:2, maxAge:49, code:'00100'},
            {minAge:50, maxAge:59, code:'00120'},
            {minAge:60, maxAge:69, code:'00140'},
            {minAge:70, maxAge:79, code:'00150'},
            {minAge:80, maxAge:999, code:'00160'}
        ],
        phone_visit: [
            {minAge:0, maxAge:1, code:'13011'},
            {minAge:2, maxAge:49, code:'13037'},
            {minAge:50, maxAge:59, code:'13038'},
            {minAge:60, maxAge:69, code:'13039'},
            {minAge:70, maxAge:79, code:'13040'},
            {minAge:80, maxAge:999, code:'13041'}
        ],
        office_counseling: [
            {minAge:0, maxAge:1, code:'12120'},
            {minAge:2, maxAge:49, code:'00120'},
            {minAge:50, maxAge:59, code:'15320'},
            {minAge:60, maxAge:69, code:'16120'},
            {minAge:70, maxAge:79, code:'17120'},
            {minAge:80, maxAge:999, code:'18120'}
        ],
        tele_counseling: [
            {minAge:0, maxAge:1, code:'12338'},
            {minAge:2, maxAge:49, code:'13438'},
            {minAge:50, maxAge:59, code:'13538'},
            {minAge:60, maxAge:69, code:'13638'},
            {minAge:70, maxAge:79, code:'13738'},
            {minAge:80, maxAge:999, code:'13838'}
        ],
        brief_conference: [{minAge:0, maxAge:999, code:'14067'}],
        conference_with_acp: [{minAge:0, maxAge:999, code:'14077'}],
        fp_conference: [{minAge:0, maxAge:999, code:'14077'}],
        advice_community: [{minAge:0, maxAge:999, code:'13005'}],
        fp_advice_response: [{minAge:0, maxAge:999, code:'14021'}],
        fp_advice_per15: [{minAge:0, maxAge:999, code:'14022'}]
    };
    const requiresTime = ["office_counseling", "tele_counseling", "brief_conference",
                          "conference_with_acp", "fp_conference", "advice_community",
                          "fp_advice_response", "fp_advice_per15"];
    const requiresUnits = ["conference_with_acp", "fp_conference", "fp_advice_per15"];

    // --- HTML Templates ---
// ============================================================
// BLOCK 1: REPLACE createModalHTML FUNCTION
// ============================================================
function createModalHTML() {
    const overlay = document.createElement('div');
    overlay.id = 'modal-overlay';
    const modal = document.createElement('div');
    modal.id = 'modal';

    // Titlebar
    const titlebar = document.createElement('div');
    titlebar.id = 'titlebar';
    const title = document.createElement('span');
    title.textContent = 'CliniStream';
    const closeBtn = document.createElement('button');
    closeBtn.id = 'close-btn';
    closeBtn.setAttribute('title', 'Close (Esc)');
    closeBtn.textContent = '×';
    titlebar.appendChild(title);
    titlebar.appendChild(closeBtn);

    // Tabs
    const tabs = document.createElement('div');
    tabs.id = 'tabs';
    const defaultTabClass = isAppointmentPage ? ['', '', 'active', '', '', ''] : ['active', '', '', '', '', ''];
    const tabLabels = ['Templates', 'AI Summary', 'Multi-Bill', 'Billing', 'Log', 'Settings'];
    const tabNames = ['templates', 'ai', 'multibill', 'billing', 'log', 'settings'];
    for (let i = 0; i < tabLabels.length; i++) {
        const tabBtn = document.createElement('button');
        tabBtn.className = `tab-button ${defaultTabClass[i] || ''}`;
        tabBtn.dataset.tab = tabNames[i];
        tabBtn.textContent = tabLabels[i];
        tabs.appendChild(tabBtn);
    }

    // Content Area
    const content = document.createElement('div');
    content.id = 'content';

    // Create Panes for each Tab
    for (let i = 0; i < tabNames.length; i++) {
        const tabPane = document.createElement('div');
        tabPane.id = `tab-${tabNames[i]}`;
        tabPane.className = `tab-pane ${defaultTabClass[i] || ''}`;

        // --- Populate each tab pane ---

        if (tabNames[i] === 'templates') {
            const heading = document.createElement('h3'); heading.textContent = tabLabels[i]; tabPane.appendChild(heading);
            const categoryTabs = document.createElement('div');
            categoryTabs.id = 'template-category-tabs';
            ['Encounter Note', 'Physical Exam', 'Presenting Complaint'].forEach((catName, idx) => {
                const catTab = document.createElement('button');
                catTab.className = `template-category-tab ${idx === 0 ? 'active' : ''}`;
                catTab.dataset.category = catName;
                catTab.textContent = catName;
                categoryTabs.appendChild(catTab);
            });
            tabPane.appendChild(categoryTabs);
            const addBtn = document.createElement('button');
            addBtn.id = 'add-template-btn';
            addBtn.className = 'template-add-btn';
            addBtn.textContent = '+ Add New Template';
            tabPane.appendChild(addBtn);
            const listContainer = document.createElement('div');
            listContainer.id = 'template-list-container';
            listContainer.className = 'template-list';
            tabPane.appendChild(listContainer);
            const editContainer = document.createElement('div');
            editContainer.id = 'template-edit-container';
            editContainer.className = 'template-edit-form';
            editContainer.style.display = 'none';
            tabPane.appendChild(editContainer);
        }
        else if (tabNames[i] === 'ai') {
            const heading = document.createElement('h3'); heading.textContent = tabLabels[i]; tabPane.appendChild(heading);
            const aiControls = document.createElement('div');
            aiControls.id = 'ai-controls';
            const modelLabel = document.createElement('label');
            modelLabel.setAttribute('for', 'ai-model-select');
            modelLabel.textContent = 'Model:';
            modelLabel.style.fontSize = '11px'; modelLabel.style.marginRight = '5px';
            const modelSelect = document.createElement('select');
            modelSelect.id = 'ai-model-select';
            AI_MODELS.forEach((model, idx) => { const displayName = model.split('/')[1] || model; const option = document.createElement('option'); option.value = idx; option.textContent = displayName; modelSelect.appendChild(option); });
            const processingIndicator = document.createElement('span');
            processingIndicator.id = 'ai-processing-indicator';
            processingIndicator.textContent = 'Processing...';
            processingIndicator.style.marginLeft = 'auto'; processingIndicator.style.fontStyle = 'italic'; processingIndicator.style.display = 'none'; processingIndicator.style.fontSize = '11px'; processingIndicator.style.color = '#555';
            aiControls.appendChild(modelLabel); aiControls.appendChild(modelSelect); aiControls.appendChild(processingIndicator);
            tabPane.appendChild(aiControls);
            const errorDisplay = document.createElement('div');
            errorDisplay.id = 'ai-error-display'; errorDisplay.style.display = 'none';
            tabPane.appendChild(errorDisplay);
            const aiTabs = document.createElement('div');
            aiTabs.id = 'ai-tabs';
            ['summary', 'insights', 'full', 'comparison'].forEach((tabId, idx) => {
                const btn = document.createElement('button');
                btn.className = `ai-tab-button ${idx === 0 ? 'active' : ''}`;
                btn.dataset.tabTarget = tabId;
                btn.textContent = tabId.charAt(0).toUpperCase() + tabId.slice(1);
                if (tabId === 'comparison') { btn.style.display = 'none'; }
                aiTabs.appendChild(btn);
            });
            tabPane.appendChild(aiTabs);
            const contentPanels = document.createElement('div');
            contentPanels.id = 'ai-content-panels';
            ['summary', 'insights', 'full', 'comparison'].forEach(panelId => {
                const panel = document.createElement('div');
                panel.id = `ai-${panelId}-panel`;
                panel.className = `ai-tab-panel ${panelId === 'summary' ? 'active' : ''}`;
                if (panelId === 'summary') { panel.innerHTML = '<i>Click the ⚕️ button next to a note to generate summary.</i>'; }
                if (panelId === 'comparison') { panel.style.display = 'none'; }
                contentPanels.appendChild(panel);
            });
            tabPane.appendChild(contentPanels);
            const actionBtns = document.createElement('div');
            actionBtns.id = 'ai-actions';
            ['insert', 'refine', 'regenerate'].forEach(action => {
                const btn = document.createElement('button');
                btn.id = `ai-${action}-btn`;
                btn.disabled = true;
                if (action === 'insert') { btn.textContent = 'Insert...'; btn.title = 'Insert AI response into note...'; }
                else if (action === 'refine') { btn.textContent = 'Refine...'; btn.title = 'Refine the current AI response...'; }
                else { btn.textContent = 'Regen/Compare'; btn.title = 'Regenerate/Compare with other models'; }
                actionBtns.appendChild(btn);
            });
            tabPane.appendChild(actionBtns);
        }
        else if (tabNames[i] === 'multibill') {
            const heading = document.createElement('h3'); heading.textContent = tabLabels[i]; tabPane.appendChild(heading);
            const multibillContent = document.createElement('div');
            multibillContent.id = 'multibill-content';
            multibillContent.innerHTML = '<p style="text-align:center; padding:20px;"><img src="/oscar/images/Oscar-icon.png" style="width:20px; height:20px; vertical-align:middle; margin-right:5px;"> Loading appointments...</p>';
            tabPane.appendChild(multibillContent);
            const multibillActions = document.createElement('div');
            multibillActions.id = 'multibill-actions';
            const refreshBtn = document.createElement('button');
            refreshBtn.id = 'multibill-refresh'; refreshBtn.className = 'action-btn'; refreshBtn.textContent = 'Refresh';
            const saveAllBtn = document.createElement('button');
            saveAllBtn.id = 'multibill-save-all'; saveAllBtn.className = 'action-btn save-btn'; saveAllBtn.textContent = 'Save All Changes';
            multibillActions.appendChild(refreshBtn); multibillActions.appendChild(saveAllBtn);
            tabPane.appendChild(multibillActions);
        }
        else if (tabNames[i] === 'billing') {
            // Billing Tab Heading (with HIN placeholder)
            const headingContainer = document.createElement('div');
            headingContainer.style.display = 'flex'; headingContainer.style.justifyContent = 'space-between'; headingContainer.style.alignItems = 'center'; headingContainer.style.marginBottom = '10px';
            const heading = document.createElement('h3');
            heading.style.margin = '0'; heading.textContent = 'Billing & ICD9 Data for Apt #';
            const aptNoSpan = document.createElement('span');
            aptNoSpan.id = 'billing-apt-no'; aptNoSpan.textContent = 'N/A'; aptNoSpan.style.fontWeight = 'bold'; aptNoSpan.style.marginLeft = '5px';
            heading.appendChild(aptNoSpan);
            const hinDisplay = document.createElement('span');
            hinDisplay.id = 'billing-hin-display'; hinDisplay.style.fontSize = '0.9em'; hinDisplay.style.color = '#555'; hinDisplay.textContent = 'HIN: N/A';
            headingContainer.appendChild(heading); headingContainer.appendChild(hinDisplay);
            tabPane.appendChild(headingContainer);

            // Billing Section 1: Type and Code
            const section1 = document.createElement('div');
            section1.className = 'billing-form-section';
            const typeLabel = document.createElement('label'); typeLabel.setAttribute('for', 'billingSubType'); typeLabel.textContent = 'Encounter Type:';
            const typeSelect = document.createElement('select'); typeSelect.id = 'billingSubType';
            section1.appendChild(typeLabel); section1.appendChild(typeSelect); section1.appendChild(document.createElement('br'));
            const codeLabel = document.createElement('label'); codeLabel.setAttribute('for', 'billingServiceCode'); codeLabel.textContent = 'Service Code:';
            const codeInput = document.createElement('input'); codeInput.type = 'text'; codeInput.id = 'billingServiceCode'; codeInput.placeholder = 'Auto/Manual';
            section1.appendChild(codeLabel); section1.appendChild(codeInput); section1.appendChild(document.createElement('br'));
            const additionalFields = document.createElement('div'); additionalFields.id = 'billing-additional-fields'; additionalFields.style.display = 'none';
            section1.appendChild(additionalFields);
            tabPane.appendChild(section1);

            // Billing Section 2: ICD9
            const section2 = document.createElement('div');
            section2.className = 'billing-form-section';
            const icd9Label = document.createElement('label'); icd9Label.setAttribute('for', 'icd9-search-input'); icd9Label.title = 'Search ICD9 codes by code or description'; icd9Label.textContent = 'ICD9 Search:';
            const icd9Input = document.createElement('input'); icd9Input.type = 'text'; icd9Input.id = 'icd9-search-input'; icd9Input.placeholder = 'Type code or desc...'; icd9Input.autocomplete = 'off';
            const selectedCodes = document.createElement('div'); selectedCodes.id = 'icd9-selected-codes';
            const placeholder = document.createElement('div'); placeholder.className = 'placeholder'; placeholder.textContent = 'No codes selected (Max 3).'; selectedCodes.appendChild(placeholder);
            section2.appendChild(icd9Label); section2.appendChild(icd9Input); section2.appendChild(selectedCodes);
            tabPane.appendChild(section2);

            // Billing Actions
            const actions = document.createElement('div');
            actions.className = 'billing-actions';
            const saveBtn = document.createElement('button'); saveBtn.id = 'save-billing-info-btn'; saveBtn.textContent = 'Save Billing Info';
            actions.appendChild(saveBtn);
            tabPane.appendChild(actions);
        }
         else if (tabNames[i] === 'log') {
            const heading = document.createElement('h3'); heading.textContent = tabLabels[i]; tabPane.appendChild(heading);
            const logContent = document.createElement('pre'); logContent.id = 'log-content';
            const controls = document.createElement('div'); controls.id = 'log-controls';
            const clearBtn = document.createElement('button'); clearBtn.id = 'clear-log-btn'; clearBtn.textContent = 'Clear Log';
            const saveBtn = document.createElement('button'); saveBtn.id = 'save-log-btn'; saveBtn.textContent = 'Save Log to File';
            controls.appendChild(clearBtn); controls.appendChild(saveBtn);
            tabPane.appendChild(logContent); tabPane.appendChild(controls);
        }
        else if (tabNames[i] === 'settings') {
            const heading = document.createElement('h3'); heading.textContent = tabLabels[i]; tabPane.appendChild(heading);
            const settingsSection = document.createElement('div'); settingsSection.className = 'settings-section';

            // API Key
            const apiHeading = document.createElement('h4'); apiHeading.textContent = 'API Configuration';
            const apiLabel = document.createElement('label'); apiLabel.setAttribute('for', 'ai-api-key'); apiLabel.textContent = 'OpenRouter API Key:';
            const apiInput = document.createElement('input'); apiInput.type = 'password'; apiInput.id = 'ai-api-key'; apiInput.placeholder = 'sk-or-v1-...'; apiInput.value = AI_API_KEY !== 'YOUR_OPENROUTER_API_KEY_HERE' ? AI_API_KEY : '';
            const apiInfo = document.createElement('div'); apiInfo.style.fontSize = '11px'; apiInfo.style.color = '#555'; apiInfo.style.marginBottom = '15px'; apiInfo.innerHTML = 'Get your key at <a href="https://openrouter.ai/keys" target="_blank">openrouter.ai/keys</a><br>Your key is stored locally in your browser and only sent to OpenRouter.';
            settingsSection.appendChild(apiHeading); settingsSection.appendChild(apiLabel); settingsSection.appendChild(apiInput); settingsSection.appendChild(apiInfo);

            // Model Selection
            const modelHeading = document.createElement('h4'); modelHeading.textContent = 'Model Selection';
            const modelText = document.createElement('p'); modelText.textContent = 'Select default AI models (in order of preference):';
            const modelSelection = document.createElement('div'); modelSelection.className = 'model-selection';
            const primaryLabel = document.createElement('label'); primaryLabel.textContent = 'Primary Model:';
            const primarySelect = document.createElement('select'); primarySelect.id = 'settings-primary-model';
            const modelOptions = [ { value: 'google/gemini-2.0-flash-thinking-exp:free', label: 'Gemini 2.0 Flash (Free)' }, { value: 'google/gemini-2.5-pro-exp-03-25:free', label: 'Gemini 2.5 Pro (Free)' }, { value: 'deepseek/deepseek-r1:free', label: 'DeepSeek R1 (Free)' }, { value: 'openai/gpt-4o-mini', label: 'GPT-4o Mini' }, { value: 'anthropic/claude-3.5-haiku', label: 'Claude 3.5 Haiku' }, { value: 'google/gemini-flash-1.5', label: 'Gemini Flash 1.5' } ];
            modelOptions.forEach(opt => { const option = document.createElement('option'); option.value = opt.value; option.textContent = opt.label; primarySelect.appendChild(option); });
            const backup1Label = document.createElement('label'); backup1Label.textContent = 'Backup Model 1:';
            const backup1Select = document.createElement('select'); backup1Select.id = 'settings-backup-model-1';
            modelOptions.forEach(opt => { const option = document.createElement('option'); option.value = opt.value; option.textContent = opt.label; if (opt.value === AI_MODELS[1]) { option.selected = true; } backup1Select.appendChild(option); });
            const backup2Label = document.createElement('label'); backup2Label.textContent = 'Backup Model 2:';
            const backup2Select = document.createElement('select'); backup2Select.id = 'settings-backup-model-2';
            modelOptions.forEach(opt => { const option = document.createElement('option'); option.value = opt.value; option.textContent = opt.label; if (opt.value === AI_MODELS[2]) { option.selected = true; } backup2Select.appendChild(option); });
            modelSelection.appendChild(primaryLabel); modelSelection.appendChild(primarySelect);
            modelSelection.appendChild(backup1Label); modelSelection.appendChild(backup1Select);
            modelSelection.appendChild(backup2Label); modelSelection.appendChild(backup2Select);
            settingsSection.appendChild(modelHeading); settingsSection.appendChild(modelText); settingsSection.appendChild(modelSelection);

             // Data Management
            const dataHeading = document.createElement('h4'); dataHeading.textContent = 'Data Management';
            const dataButtons = document.createElement('div'); dataButtons.style.marginBottom = '15px';
            const clearBtn = document.createElement('button'); clearBtn.id = 'settings-clear-old-data'; clearBtn.textContent = 'Clear Old Data';
            const exportBtn = document.createElement('button'); exportBtn.id = 'settings-export-all'; exportBtn.textContent = 'Export All Data';
            dataButtons.appendChild(clearBtn); dataButtons.appendChild(exportBtn);
            settingsSection.appendChild(dataHeading); settingsSection.appendChild(dataButtons);

            // Settings Actions
            const settingsActions = document.createElement('div'); settingsActions.className = 'settings-actions';
            const saveBtn = document.createElement('button'); saveBtn.id = 'settings-save-btn'; saveBtn.textContent = 'Save Settings';
            settingsActions.appendChild(saveBtn);
            settingsSection.appendChild(settingsActions);

            tabPane.appendChild(settingsSection);
        }

        content.appendChild(tabPane); // Add the populated pane to the content area
    }

    // Footer
    const footer = document.createElement('div');
    footer.id = 'footer';
    const footerVersion = document.createElement('span');
    footerVersion.id = 'footer-version';
    footerVersion.textContent = `CliniStream v${GM_info.script.version}`;
    const footerActions = document.createElement('div');
    footerActions.id = 'footer-actions';

    // Add footer buttons dynamically based on page context
    if (isAppointmentPage) { // Only show these on appointment page
        const scanBtn = document.createElement('button');
        scanBtn.id = 'scan-appointments-btn'; scanBtn.className = 'action-btn'; scanBtn.textContent = 'Scan Appointments';
        const scanProgress = document.createElement('span'); scanProgress.className = 'scan-progress'; scanBtn.appendChild(scanProgress);
        footerActions.appendChild(scanBtn);

         const batchBtn = document.createElement('button');
         batchBtn.id = 'batch-bill-btn'; batchBtn.className = 'action-btn batch-btn'; batchBtn.textContent = 'Batch Bill';
         footerActions.appendChild(batchBtn);

         const linkBtn = document.createElement('button');
         linkBtn.id = 'link-charts-btn'; linkBtn.className = 'action-btn'; linkBtn.textContent = 'Link Charts';
         footerActions.appendChild(linkBtn);

         // *** ADD PHARMANET BUTTON HERE ***
         const pharmaNetBtn = document.createElement('button');
         pharmaNetBtn.id = 'scan-pharmanet-btn';
         pharmaNetBtn.className = 'action-btn'; // Use existing style
         pharmaNetBtn.textContent = 'Scan PharmaNET';
         pharmaNetBtn.style.backgroundColor = '#ffc107'; // Yellow color
         pharmaNetBtn.style.color = '#000';
         footerActions.appendChild(pharmaNetBtn);
         // *** END ADD PHARMANET BUTTON ***
    }
    // Save Changes button might be useful on multiple pages
    const saveAllBtn = document.createElement('button');
    saveAllBtn.id = 'save-all-btn'; saveAllBtn.className = 'action-btn save-btn'; saveAllBtn.textContent = 'Save Changes';
    footerActions.appendChild(saveAllBtn); // Add it regardless of page? Or add conditions? Added globally for now.

    footer.appendChild(footerVersion);
    footer.appendChild(footerActions);

    // Assemble Modal
    modal.appendChild(titlebar);
    modal.appendChild(tabs);
    modal.appendChild(content);
    modal.appendChild(footer);
    overlay.appendChild(modal);

    return overlay; // Return the complete overlay element
}
// ============================================================
// END BLOCK 1
// ============================================================


// ============================================================
// BLOCK 6: REPLACE injectModalAndStyles FUNCTION
// ============================================================
function injectModalAndStyles() {
    // Prevent re-injection if modal already exists
    if ($('#modal-overlay').length > 0) {
        addLog("[UI] Modal overlay already exists. Skipping injection, ensuring listeners are attached.");
        // Re-attach critical listeners just in case
        $('#close-btn').off('click.clinistream').on('click.clinistream', closeModal);
        // Other listeners might need re-attachment if issues persist, but start simple
        return;
    }

    addLog("[UI] Injecting modal and styles...");
    try {
        loadEncounterTemplates(); // Load templates data
        loadButtonPosition();     // Load floating button position
        AI_API_KEY = GM_getValue("AI_API_KEY", AI_API_KEY); // Load API Key
        GM_addStyle(fullCSS);     // Add all CSS rules

        // Create modal HTML structure
        const modalElement = createModalHTML();
        document.body.appendChild(modalElement);
        addLog("[UI] Modal HTML appended to body.");

        // Set initial tab based on page type
        let initialTab = 'templates'; // Default
        if (isAppointmentPage) {
            initialTab = 'multibill';
        }
        switchToTab(initialTab); // Switch to the correct initial tab
        addLog(`[UI] Switched to initial tab: ${initialTab}`);

        // --- Attach Core Event Listeners ---
        addLog("[UI] Attaching core modal event listeners...");
        enableModalDrag($('#titlebar'), $('#modal'));
        // Use .off().on() for close button to prevent duplicates
        $('#close-btn').off('click.clinistream').on('click.clinistream', function() {
             addLog("[UI] Close button clicked."); // *** ADDED LOG ***
             closeModal();
        });
        // Use .off().on() for tab buttons
        $('.tab-button').off('click.clinistream').on('click.clinistream', function() {
            const tabId = $(this).data('tab');
            addLog(`[UI] Tab button clicked: ${tabId}`);
            switchToTab(tabId);
        });
        addLog("[UI] Core modal listeners attached.");

        // --- Setup Individual Tabs ---
        addLog("[UI] Setting up tab-specific functionality...");

        // Billing Tab Setup
        $('#billingSubType').off('change.clinistream').on('change.clinistream', function() {
            const subType = $(this).val();
            const scannedData = getScannedData(currentBillingAptNo) || { age: 0 };
            updateServiceCode(subType, scannedData.age);
            updateAdditionalFields(subType);
        });
        $('#save-billing-info-btn').off('click.clinistream').on('click.clinistream', saveBillingInfo);
        // Autocomplete is attached within populateBillingForm

        // AI Tab Setup
        $('.ai-tab-button').off('click.clinistream').on('click.clinistream', function() {
            if ($(this).hasClass('active') || $(this).prop('disabled')) return;
            const targetId = $(this).data('tab-target');
            $('.ai-tab-button').removeClass('active'); $(this).addClass('active');
            $('.ai-tab-panel').removeClass('active').hide();
            $(`#ai-${targetId}-panel`).addClass('active').show();
        });
        $('#ai-insert-btn').off('click.clinistream').on('click.clinistream', handleAiInsert);
        $('#ai-refine-btn').off('click.clinistream').on('click.clinistream', handleAiRefine);
        $('#ai-regenerate-btn').off('click.clinistream').on('click.clinistream', handleAiRegenerate);

        // Templates Tab Setup
        $('#template-category-tabs').off('click.clinistream').on('click.clinistream', '.template-category-tab', function() {
            $(this).siblings().removeClass('active'); $(this).addClass('active');
            loadTemplateList($(this).data('category'));
        });
        $('#add-template-btn').off('click.clinistream').on('click.clinistream', function() { openTemplateEditor(); });
        // Save/Cancel for template editor are attached when editor is opened

        // Multi-Bill Tab Setup
        $('#multibill-refresh').off('click.clinistream').on('click.clinistream', loadMultiBillData);
        $('#multibill-save-all').off('click.clinistream').on('click.clinistream', saveMultiBillChanges);
        // Row-specific handlers attached in loadMultiBillData

        // Footer Button Setup (General)
        $('#clear-log-btn').off('click.clinistream').on('click.clinistream', clearLogDisplay);
        $('#save-log-btn').off('click.clinistream').on('click.clinistream', saveLogToFile);
        $('#save-all-btn').off('click.clinistream').on('click.clinistream', handleSaveAllButton); // Ensure this exists and is attached

        // Footer Button Setup (Appointment Page Specific)
        if (isAppointmentPage) {
            $('#scan-appointments-btn').off('click.clinistream').on('click.clinistream', scanAppointments);
            $('#batch-bill-btn').off('click.clinistream').on('click.clinistream', startBatchBilling);
            $('#link-charts-btn').off('click.clinistream').on('click.clinistream', startChartLinking);
            // PharmaNet button listener is attached in setupPharmaNetButton
        }

        // Settings Tab Setup
        $('#settings-save-btn').off('click.clinistream').on('click.clinistream', saveSettings); // Use the correct save function
        $('#settings-clear-old-data').off('click.clinistream').on('click.clinistream', function() {
            if (confirm("This will remove all stored appointment data older than 30 days. Continue?")) {
                const now = Date.now();
                const thresholdMs = 30 * 24 * 60 * 60 * 1000;
                const removedCount = clearOldBillingData(now - thresholdMs);
                alert(`Removed ${removedCount} old appointment records.`);
            }
        });
        $('#settings-export-all').off('click.clinistream').on('click.clinistream', exportAllData);

        addLog("[UI] Tab-specific functionality setup complete.");
        addLog("[UI] Modal and styles injection finished.");

    } catch (e) {
        console.error("Error creating modal:", e);
        addLog(`[UI Error] Failed to create modal: ${e.message} ${e.stack}`);
    }
}
// ============================================================
// END BLOCK 6
// ============================================================


// ============================================================
// BLOCK 7: REPLACE startPharmaNetScan FUNCTION (Minor Logging Addition)
// ============================================================
function startPharmaNetScan() {
    addLog("[PharmaNet] Starting scan initiated...");
    const state = getPharmaNetState();

    if (state.active) {
        if (confirm("A PharmaNet scan appears to be active or incomplete. Do you want to clear the previous state and start a new scan?")) {
             addLog("[PharmaNet] User chose to clear existing state and restart.");
             clearPharmaNetState();
        } else {
            addLog("[PharmaNet] Scan is already active, user chose not to restart.");
            return;
        }
    }

    // --- Proceed with starting a new scan ---
    addLog("[PharmaNet] Gathering PHNs for new scan...");
    const patientQueue = [];
    const uniquePhns = new Set();
    // ... (Gathering logic - unchanged) ...
    $('a.apptLink').each(function() {
        const oc = $(this).attr('onclick') || ''; const aptMatch = oc.match(/appointment_no=(\d+)/); if (!aptMatch) return;
        const aptNo = aptMatch[1]; const scannedData = getScannedData(aptNo);
        if (scannedData && scannedData.hin) {
             if (!uniquePhns.has(scannedData.hin)) {
                 const $billingLink = $(`a[title="Billing"][onclick*="appointment_no=${aptNo}"]`); let isBilled = false;
                 if ($billingLink.length) { const linkText = $billingLink.text().trim(); const billingOc = $billingLink.attr("onclick") || ""; isBilled = (linkText === '-B' || billingOc.includes("onUnbilled(")); }
                 if (!isBilled) { uniquePhns.add(scannedData.hin); patientQueue.push({ phn: scannedData.hin, dob: scannedData.dob, name: scannedData.patientName }); addLog(`[PharmaNet] Added PHN ${scannedData.hin} (Apt #${aptNo}) to queue.`); }
                 else { addLog(`[PharmaNet] Skipping PHN ${scannedData.hin} (Apt #${aptNo}) as it appears billed.`); }
             } else { addLog(`[PharmaNet] Skipping duplicate PHN ${scannedData.hin} (Apt #${aptNo}).`); }
        } else if (scannedData && !scannedData.hin) { addLog(`[PharmaNet] Skipping Apt #${aptNo} - Missing HIN/PHN in scanned data.`); }
        else { addLog(`[PharmaNet] Skipping Apt #${aptNo} - No scan data found.`); }
    });


    if (patientQueue.length === 0) {
        alert("No valid unbilled appointments with PHNs found on this page to scan. Please run 'Scan Appointments' first if needed.");
        addLog("[PharmaNet] No PHNs found in queue.");
        return;
    }

    addLog(`[PharmaNet] Starting scan for ${patientQueue.length} unique PHNs.`);

    // 2. Generate Scan ID and Set Initial State
    const scanId = `cs_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;
    addLog(`[PharmaNet] Generated Scan ID: ${scanId}`);
    const initialState = {
        active: true, scanId: scanId, queue: patientQueue, index: 0, authWait: true,
        authTimestamp: Date.now(), currentPhn: null, currentPatientStartTime: null,
        statusMessage: `Starting scan for ${patientQueue.length} patients...`,
    };
    setPharmaNetState(initialState);
    // *** ADD LOGGING HERE ***
    addLog(`[PharmaNet] State set before opening tab: active=${initialState.active}, scanId=${initialState.scanId}`);
    updatePharmaNetButtonState(); // Update button look

    // 3. Open CareConnect in a new tab with Scan ID
    try {
        const targetUrl = `https://health.careconnect.ca/Welcome/Index?clinistream_scan_id=${scanId}`;
        GM_openInTab(targetUrl, { active: true, setParent: true });
        addLog(`[PharmaNet] Opened CareConnect tab with URL: ${targetUrl}`);
        updatePharmaNetStatus("Waiting for CareConnect Login...");
    } catch (e) {
        addLog(`[PharmaNet Error] Failed to open CareConnect tab: ${e.message}. Ensure @grant GM_openInTab is in the script header.`);
        updatePharmaNetStatus(`Error opening tab: ${e.message}`, { active: false, scanId: null });
        alert(`Error opening CareConnect tab: ${e.message}\nEnsure @grant GM_openInTab is in the script header.`);
    }
}
// ============================================================
// END BLOCK 7
// ============================================================


// ============================================================
// BLOCK 8: REPLACE handleCareConnectPage FUNCTION (Minor Logging Addition)
// ============================================================
const PATIENT_TIMEOUT_MS = 90 * 1000; // 90 seconds per patient timeout

async function handleCareConnectPage() {
    const currentUrl = window.location.href;
    addLog(`[PharmaNet CC Handler] Script running on: ${currentUrl}`);
    let state = getPharmaNetState();
    // *** ADD LOGGING HERE ***
    addLog(`[PharmaNet CC Handler] Initial state read: active=${state.active}, scanId=${state.scanId}, index=${state.index}, authWait=${state.authWait}`);
    let stage = "Initialization";

    // --- Check if this tab/page load is part of an active, intended scan ---
    stage = "Validating Scan Context";
    const urlParams = new URLSearchParams(window.location.search);
    const scanIdFromUrl = urlParams.get('clinistream_scan_id');

    if (!state.active || !scanIdFromUrl || scanIdFromUrl !== state.scanId) {
        addLog(`[PharmaNet CC Handler @ ${stage}] Exiting: Scan not active in state (${state.active}), Scan ID missing from URL (${!!scanIdFromUrl}), or URL ID (${scanIdFromUrl}) doesn't match state ID (${state.scanId}). Assuming manual navigation or stale state.`);
        if (state.active && scanIdFromUrl !== state.scanId) {
             addLog(`[PharmaNet CC Handler @ ${stage}] Clearing potentially stale active state due to Scan ID mismatch.`);
             clearPharmaNetState();
        }
        return; // Do not proceed with automation
    }
    addLog(`[PharmaNet CC Handler @ ${stage}] Context validated (Active: ${state.active}, ScanID: ${state.scanId}).`);

    // --- Handle Authentication Page ---
    if (currentUrl.includes("id.gov.bc.ca/login/entry")) {
        // ... (Login handling logic - unchanged) ...
        stage = "BC Services Login Page";
        if (!state.authWait) { updatePharmaNetStatus("Error: Unexpectedly redirected to login. Scan stopped.", { active: false, authWait: false, scanId: null }); alert("CareConnect session may have expired..."); return; }
        updatePharmaNetStatus("Waiting for manual BC Services Card login...");
        const timeRemaining = ((AUTH_TIMEOUT_MS - (Date.now() - state.authTimestamp)) / 1000).toFixed(0);
        addLog(`[PharmaNet CC Handler @ ${stage}] Waiting for login. Timeout in ${timeRemaining}s`);
        if (Date.now() - state.authTimestamp > AUTH_TIMEOUT_MS) { updatePharmaNetStatus("Error: Login timed out. Scan stopped.", { active: false, authWait: false, scanId: null }); alert("BC Services Card login timed out..."); return; }
        const checkLoginInterval = setInterval(() => {
            if (!window.location.href.includes("id.gov.bc.ca/login/entry")) {
                clearInterval(checkLoginInterval); addLog(`[PharmaNet CC Handler @ ${stage}] Detected navigation away from login page.`);
                let currentState = getPharmaNetState(); if (currentState.active && currentState.scanId === scanIdFromUrl) { updatePharmaNetStatus("Login detected, proceeding...", { authWait: false }); } else { addLog(`[PharmaNet CC Handler @ ${stage}] Scan cancelled or context changed.`); }
            } else {
                 let currentState = getPharmaNetState(); if (!currentState.active || currentState.scanId !== scanIdFromUrl) { clearInterval(checkLoginInterval); addLog(`[PharmaNet CC Handler @ ${stage}] Scan cancelled or context changed.`); return; }
                 if (Date.now() - currentState.authTimestamp > AUTH_TIMEOUT_MS) { clearInterval(checkLoginInterval); updatePharmaNetStatus("Error: Login timed out. Scan stopped.", { active: false, authWait: false, scanId: null }); alert("BC Services Card login timed out..."); }
            }
        }, 3000);
        return;
    }

    // --- Handle CareConnect Pages ---
    if (currentUrl.includes("health.careconnect.ca")) {
        // ... (Rest of the CareConnect logic - unchanged from previous version) ...
        stage = "CareConnect Page Load";
        if (state.authWait) {
            addLog(`[PharmaNet CC Handler @ ${stage}] Login complete or already logged in.`);
            if (state.statusMessage.includes("Waiting for CareConnect Login")) { updatePharmaNetStatus("Login successful, starting lookup...", { authWait: false }); }
            state = getPharmaNetState();
        }
        if (!state.active || state.scanId !== scanIdFromUrl) { addLog(`[PharmaNet CC Handler @ ${stage}] Scan no longer active or context changed. Exiting.`); return; }
        stage = "Validating State";
        if (!Array.isArray(state.queue) || state.queue.length === 0) { updatePharmaNetStatus("Error: Queue invalid. Scan stopped.", { active: false, scanId: null }); alert("Error: Queue invalid."); return; }
        if (state.index >= state.queue.length) { updatePharmaNetStatus("Completed PharmaNet scan.", { active: false, scanId: null }); alert(`PharmaNet scan completed for ${state.queue.length} patients.`); return; }
        const currentPatient = state.queue[state.index];
        if (!currentPatient || !currentPatient.phn) { updatePharmaNetStatus(`Error: Invalid patient data @ index ${state.index}. Scan stopped.`, { active: false, scanId: null }); alert(`Error in patient queue @ index ${state.index}.`); return; }
        stage = "Starting Patient Processing";
        if (state.currentPhn !== currentPatient.phn || !state.currentPatientStartTime) {
            addLog(`[PharmaNet CC Handler @ ${stage}] Starting processing for PHN: ${currentPatient.phn}`);
            updatePharmaNetStatus(`Processing ${currentPatient.phn} (${state.index + 1}/${state.queue.length})...`, { currentPhn: currentPatient.phn, currentPatientStartTime: Date.now() });
            state = getPharmaNetState();
        } else {
            const elapsedPatientTime = Date.now() - state.currentPatientStartTime;
            addLog(`[PharmaNet CC Handler @ ${stage}] Continuing processing for PHN: ${currentPatient.phn} (${(elapsedPatientTime / 1000).toFixed(1)}s elapsed)`);
            if (elapsedPatientTime > PATIENT_TIMEOUT_MS) {
                addLog(`[PharmaNet CC Handler Error @ ${stage}] Patient processing timed out for ${currentPatient.phn}. Skipping.`);
                updatePharmaNetStatus(`Timeout for ${currentPatient.phn}. Skipping.`, { index: state.index + 1, currentPhn: null, currentPatientStartTime: null });
                alert(`Processing timed out for patient ${currentPatient.phn}. Skipping.`); await delay(1000);
                window.location.href = `https://health.careconnect.ca/Welcome/Index?clinistream_scan_id=${state.scanId}`; return;
            }
        }
        try {
            stage = "Checking for Results Table (Stage 4)";
            const resultsTableBody = document.querySelector('table[role="grid"] > tbody[role="rowgroup"]');
            if (resultsTableBody && resultsTableBody.querySelector('tr.customClientRowTemplate')) {
                 addLog(`[PharmaNet CC Handler @ ${stage}] Results table found. Scraping...`); await delay(2000); const medications = [];
                 resultsTableBody.querySelectorAll('tr.customClientRowTemplate').forEach(row => { /* ... (Scraping logic) ... */ });
                 addLog(`[PharmaNet CC Handler @ ${stage}] Scraped ${medications.length} records for ${currentPatient.phn}.`); savePharmaNetResult(currentPatient.phn, medications);
                 const nextIndex = state.index + 1; updatePharmaNetStatus(`Finished ${currentPatient.phn}. Moving next...`, { index: nextIndex, currentPhn: null, currentPatientStartTime: null });
                 await delay(1500); window.location.href = `https://health.careconnect.ca/Welcome/Index?clinistream_scan_id=${state.scanId}`; return;
            }
            stage = "Checking for Location/Search Button (Stage 3)";
             const searchPharmaNetButton = document.querySelector('#medications-checkpoint-submit'); const locationContainer = document.querySelector('#select2-CurrentAccessLocation-container');
             if (searchPharmaNetButton || locationContainer) {
                  addLog(`[PharmaNet CC Handler @ ${stage}] On Medications page.`); let locationSelected = false;
                  try {
                      const locationDropdownTrigger = await waitForSelector('#select2-CurrentAccessLocation-container', 10000); const existingSelectionRemove = locationDropdownTrigger.closest('.select2-selection').querySelector('.select2-selection__choice__remove');
                      if (!existingSelectionRemove) {
                          addLog(`[PharmaNet CC Handler @ ${stage}] No location selected, attempting 'Click and Enter'.`); locationDropdownTrigger.click(); await delay(1000); const searchField = document.querySelector('.select2-search__field');
                          if (searchField) { searchField.focus(); await delay(500); if (simulateEnterKeyPress(searchField)) { await delay(1500); const newSelectionRemove = locationDropdownTrigger.closest('.select2-selection').querySelector('.select2-selection__choice__remove'); if (newSelectionRemove) { locationSelected = true; addLog(`[PharmaNet CC Handler @ ${stage}] Location selected via Enter.`); } else { addLog(`[PharmaNet CC Handler Warning @ ${stage}] Location selection via Enter failed.`); } } else { addLog(`[PharmaNet CC Handler Warning @ ${stage}] Failed to simulate Enter.`); } } else { addLog(`[PharmaNet CC Handler Warning @ ${stage}] Could not find Select2 search field.`); }
                      } else { addLog(`[PharmaNet CC Handler @ ${stage}] Location already selected.`); locationSelected = true; }
                  } catch (locationError) { addLog(`[PharmaNet CC Handler Warning @ ${stage}] Error during location selection: ${locationError.message}.`); }
                  if (locationSelected) { const finalSearchButton = await waitForSelector('#medications-checkpoint-submit', 5000); if (finalSearchButton) { addLog(`[PharmaNet CC Handler @ ${stage}] Found Search PharmaNet button.`); await delay(500); finalSearchButton.click(); addLog(`[PharmaNet CC Handler @ ${stage}] Clicked Search PharmaNet button.`); updatePharmaNetStatus(`Searching PharmaNet for ${currentPatient.phn}...`); } else { throw new Error("Search PharmaNet button not found."); } } else { throw new Error("Location not selected."); }
                  return;
             }
            stage = "Checking for Accept Button (Stage 2)";
            try { const acceptButton = await waitForSelector('#SearchResultAcceptButton:not(.displayNone)', 20000); addLog(`[PharmaNet CC Handler @ ${stage}] Found Accept button.`); await delay(1000); acceptButton.click(); addLog(`[PharmaNet CC Handler @ ${stage}] Clicked Accept button.`); updatePharmaNetStatus(`Accepted patient ${currentPatient.phn}, loading meds...`); return; } catch (e) { addLog(`[PharmaNet CC Handler @ ${stage}] Accept button not found/timed out. Proceeding...`); }
            stage = "Checking for Search Input (Stage 1)";
            const searchInput = document.querySelector('#search'); const goButton = document.querySelector('#search-button');
            if (searchInput && goButton && currentUrl.toLowerCase().includes("/welcome/index")) {
                 addLog(`[PharmaNet CC Handler @ ${stage}] On search page for PHN: ${currentPatient.phn}`); if (searchInput.value !== currentPatient.phn) { searchInput.value = currentPatient.phn; addLog(`[PharmaNet CC Handler @ ${stage}] Entered PHN ${currentPatient.phn}`); } else { addLog(`[PharmaNet CC Handler @ ${stage}] PHN ${currentPatient.phn} already in input.`); }
                 await delay(500); goButton.click(); addLog(`[PharmaNet CC Handler @ ${stage}] Clicked GO button.`); return;
            }
            stage = "Unexpected State"; addLog(`[PharmaNet CC Handler Warning @ ${stage}] Unexpected state (URL: ${currentUrl}). Recovering...`); updatePharmaNetStatus(`Unexpected page state for ${currentPatient.phn}. Recovering.`); await delay(3000); window.location.href = `https://health.careconnect.ca/Welcome/Index?clinistream_scan_id=${state.scanId}`;
        } catch (error) {
            addLog(`[PharmaNet CC Handler Error @ ${stage}] Failed processing PHN ${state.currentPhn || 'unknown'}: ${error.message} ${error.stack}`); updatePharmaNetStatus(`Error for ${state.currentPhn}: ${error.message}. Skipping.`, { index: state.index + 1, currentPhn: null, currentPatientStartTime: null }); alert(`Error processing PHN ${state.currentPhn} @ stage [${stage}]:\n${error.message}\nSkipping.`); await delay(1500); window.location.href = `https://health.careconnect.ca/Welcome/Index?clinistream_scan_id=${state.scanId}`;
        }
    } else { addLog(`[PharmaNet CC Handler Warning] Script running on unexpected URL: ${currentUrl}`); }
}
// ============================================================
// END BLOCK 8
// ============================================================



    // --- Modal Control & Initialization Functions ---
    function enableModalDrag($handle, $modal) {
        let isDragging = false;
        let startX, startY, startLeft, startTop;
        $handle.css('cursor', 'move')
            .off("mousedown")
            .on("mousedown", function(e) {
                if (e.button !== 0) return;
                isDragging = true;
                startX = e.clientX;
                startY = e.clientY;
                startLeft = parseInt($modal.css('left')) || 0;
                startTop = parseInt($modal.css('top')) || 0;
                $handle.css('cursor', 'grabbing');
                e.preventDefault();
                e.stopPropagation();
            });
        $(document)
            .off("mousemove.modalDrag mouseup.modalDrag")
            .on("mousemove.modalDrag", function(e) {
                if (!isDragging) return;
                const dx = e.clientX - startX;
                const dy = e.clientY - startY;
                $modal.css({
                    left: `${startLeft + dx}px`,
                    top: `${startTop + dy}px`
                });
            })
            .on("mouseup.modalDrag", function() {
                if (!isDragging) return;
                isDragging = false;
                $handle.css('cursor', 'move');
                const windowWidth = $(window).width();
                const windowHeight = $(window).height();
                const modalWidth = $modal.outerWidth();
                const modalHeight = $modal.outerHeight();
                const margin = 20;
                let left = parseInt($modal.css('left')) || 0;
                let top = parseInt($modal.css('top')) || 0;
                left = Math.max(margin, Math.min(left, windowWidth - modalWidth - margin));
                top = Math.max(margin, Math.min(top, windowHeight - modalHeight - margin));
                $modal.css({
                    left: `${left}px`,
                    top: `${top}px`
                });
            });
    }

    function initializeModalFunctionality() {
        initializeTemplatesTab();
        initializeAITab();
        initializeBillingTab();
        initializeMultiBillTab();
        initializeLogTab();
        initializeSettingsTab();
        enableModalDrag($('#titlebar'), $('#modal'));
        $('#close-btn').on('click', closeModal);
        $('.tab-button').on('click', function() {
            switchToTab($(this).data('tab'));
        });
        $('#scan-appointments-btn').on('click', function() {
            if (isAppointmentPage) {
                scanAppointments();
            } else {
                alert("Scanning appointments is only available on the appointment page.");
            }
        });
        $('#save-all-btn').on('click', handleSaveAllButton);
        $('#batch-bill-btn').on('click', function() {
            if (isAppointmentPage) {
                startBatchBilling();
            } else {
                alert("Batch billing is only available on the appointment page.");
            }
        });
        $('#link-charts-btn').on('click', function() {
            if (isAppointmentPage) {
                startChartLinking();
            } else {
                alert("Chart linking is only available on the appointment page.");
            }
        });
        addLog("[UI] Modal and controls initialized");
    }

    function initializeTemplatesTab() { /* Template tab specific initialization */ }
    function initializeAITab() { /* AI tab specific initialization */ }
    function initializeBillingTab() {
        $('#billingSubType').on('change', function() {
            const subType = $(this).val();
            const scannedData = getScannedData(currentBillingAptNo) || { age: 0 };
            updateServiceCode(subType, scannedData.age);
            updateAdditionalFields(subType);
        });
        $('#save-billing-info-btn').on('click', saveBillingInfo);
    }
    function initializeMultiBillTab() {
        $('#multibill-refresh').on('click', loadMultiBillData);
        $('#multibill-save-all').on('click', saveMultiBillChanges);
    }
    function initializeLogTab() {
        $('#clear-log-btn').on('click', clearLogDisplay);
        $('#save-log-btn').on('click', saveLogToFile);
    }
    function initializeSettingsTab() {
        $('#settings-save-btn').on('click', saveSettings);
    }
    function handleSaveAllButton() {
        const activeTab = $('.tab-button.active').data('tab');
        if (activeTab === 'billing') {
            saveBillingInfo();
        } else if (activeTab === 'multibill') {
            saveMultiBillChanges();
        } else if (activeTab === 'settings') {
            $('#settings-save-btn').click();
        } else if (activeTab === 'templates' && $('#template-edit-container').is(':visible')) {
            saveTemplateForm();
        } else {
            alert("No changes to save in the current tab.");
        }
    }
    function saveSettings() {
        const apiKey = $('#ai-api-key').val().trim();
        const primaryModel = $('#settings-primary-model').val();
        const backupModel1 = $('#settings-backup-model-1').val();
        const backupModel2 = $('#settings-backup-model-2').val();
        if (apiKey) {
            GM_setValue("AI_API_KEY", apiKey);
            AI_API_KEY = apiKey;
            addLog(`[Settings] API Key updated to: ${apiKey.substring(0, 10)}...`);
        }
        const newModels = [primaryModel, backupModel1, backupModel2];
        GM_setValue("CliniStream_AIModels", JSON.stringify(newModels));
        window.AI_MODELS = newModels;
        addLog(`[Settings] AI Models updated: ${newModels.join(', ')}`);
        let $btn = $('#settings-save-btn');
        let originalText = $btn.text();
        $btn.text("Saved!").css("background-color", "#28a745");
        setTimeout(() => {
            $btn.text(originalText).css("background-color", mainColor);
        }, 2000);
        alert("Settings saved successfully!");
    }

    // --- Chart Linking Functions ---
    function getUnlinkedAppointments() {
        // This function scans the page for appointments that are not linked to patient charts
        const anchors = Array.from(document.querySelectorAll("a"));
        const results = [];

        anchors.forEach(a => {
            const onclickVal = a.getAttribute("onclick") || "";
            // Look for appointments with demographic_no=0 (unlinked appointments)
            if (onclickVal.includes("appointment_no=") && onclickVal.includes("demographic_no=0")) {
                const apptMatch = onclickVal.match(/appointment_no=(\d+)/);
                const apptNo = apptMatch ? apptMatch[1] : null;
                const titleAttr = a.getAttribute("title") || "";
                let hin = "";

                // Try to extract health number from title attribute
                const hinMatch = titleAttr.match(/\(HN not in EMR:\s*(\d+)\)/i);
                if (hinMatch) {
                    hin = hinMatch[1];
                }

                if (apptNo) {
                    results.push({
                        href: a.href || "",
                        apptNo,
                        hin
                    });
                }
            }
        });

        addLog(`[Link] Found ${results.length} unlinked appointments`);
        return results;
    }

    function startChartLinking() {
        try {
            // Step 1: Get all unlinked appointments from the page
            const appts = getUnlinkedAppointments();
            if (!appts.length) {
                alert("No unlinked appointments found!");
                return;
            }

            // Step 2: Save the list of unlinked appointments to global state
            setChartLinkingState(true, appts, 0, "", "");
            addLog(`[Link] Found ${appts.length} unlinked appointments. Starting with first...`);
            setButtonState($('#link-charts-btn'), `Linking (0/${appts.length})`, "#f39c12", true);

            // Step 3: Begin the linking process with the first appointment
            gotoAppointment(0);
        } catch(e) {
            addLog(`[Link Error] Error starting chart linking: ${e.message}`);
            clearChartLinkingState();
            setButtonState($('#link-charts-btn'), "Link Charts", mainColor, false);
        }
    }

    function gotoAppointment(idx) {
        // This function processes the appointment at the given index
        const linkState = getChartLinkingState();
        if (!linkState.active) return;

        const appts = linkState.appts;
        if (!appts[idx]) {
            addLog(`[Link] No appointment at index ${idx}, finishing...`);
            finishChartLinking();
            return;
        }

        const appt = appts[idx];
        setChartLinkingState(true, appts, idx, appt.hin, appt.apptNo);
        addLog(`[Link] Opening appointment #${idx + 1}/${appts.length} => apptNo=${appt.apptNo} hin=${appt.hin || 'none'}`);
        setButtonState($('#link-charts-btn'), `Linking (${idx + 1}/${appts.length})`, "#f39c12", true);

        // Open appointment in new window
        if (appt.href) {
            const newWindow = window.open(appt.href, '_blank');
            const checkWindow = setInterval(() => {
                if (newWindow.closed) {
                    clearInterval(checkWindow);
                    gotoNextAppointment();
                }
            }, 1000);
        } else {
            addLog(`[Link] No href to open for appointment ${appt.apptNo} => skipping.`);
            gotoNextAppointment();
        }
    }

    function handleApptEditPage() {
        // This function runs in the appointment edit window
        if (!isChartLinkingActive()) return;

        const linkState = getChartLinkingState();
        addLog(`[Link] Handling appointment edit page for apptNo=${linkState.apptNo}`);

        try {
            const urlParams = new URLSearchParams(window.location.search);
            const demNo = urlParams.get("demographic_no") || "";

            // If already linked to a demographic, just update and close
            if (demNo && demNo !== "0") {
                addLog(`[Link] Already linked to demographic_no=${demNo} => finalizing...`);
                clickUpdateAppt();
                return;
            }

            // If we see the search dropdown, we need to search by HIN
            if (document.querySelector('select[name="search_mode"]')) {
                addLog(`[Link] Detected search_mode dropdown => switching to search by HIN...`);
                handlePatientSearchPage();
                return;
            }

            // Otherwise try to fill in the HIN and search
            fillHINandSearch();
        } catch (e) {
            addLog(`[Link Error] Error in appointment edit page: ${e.message}`);
            window.close();
        }
    }

    function fillHINandSearch() {
        // This function fills in the HIN and triggers the search
        const linkState = getChartLinkingState();
        const hin = linkState.hin;

        if (!hin) {
            addLog(`[Link] No HIN available for this appointment => closing window...`);
            window.close();
            return;
        }

        const input = document.querySelector('#name_increasedWidth, #keyword');
        if (!input) {
            addLog(`[Link] No name input field found => closing window...`);
            window.close();
            return;
        }

        input.value = hin;
        addLog(`[Link] Filled HIN: ${hin}`);

        const searchBtn = document.querySelector('input[type="submit"][value="Search"]');
        if (!searchBtn) {
            addLog(`[Link] No search button found => closing window...`);
            window.close();
            return;
        }

        addLog(`[Link] Clicking Search button...`);
        setTimeout(() => {
            searchBtn.click();
        }, 1000);
    }

    function gotoNextAppointment() {
        const linkState = getChartLinkingState();
        if (!linkState.active) return;
        let nextIdx = linkState.index + 1;
        if (nextIdx >= linkState.appts.length) {
            finishChartLinking();
            return;
        }
        gotoAppointment(nextIdx);
    }
    function finishChartLinking() {
        clearChartLinkingState();
        addLog(`[Link] All unlinked appointments processed!`);
        alert("All unlinked appointments have been processed!");
        setButtonState($('#link-charts-btn'), "Link Complete", "#28a745", false);
        setTimeout(() => {
            setButtonState($('#link-charts-btn'), "Link Charts", mainColor, false);
        }, 3000);
    }
    function handlePatientSearchPage() {
        const dropdown = document.querySelector('select[name="search_mode"]');
        if (!dropdown) {
            addLog(`[Link] No search_mode dropdown found => closing window...`);
            window.close();
            return;
        }
        dropdown.value = "search_hin";
        dropdown.dispatchEvent(new Event("change"));
        addLog(`[Link] Changed search mode to HIN`);
        const searchBtn = document.querySelector('input[type="submit"][value="Search"], input[type="SUBMIT"][value="Search"], button[type="submit"]');
        if (!searchBtn) {
            addLog(`[Link] No search button found on patient search page => closing window...`);
            window.close();
            return;
        }
        addLog(`[Link] Clicking Search button to search by HIN...`);
        setTimeout(() => {
            searchBtn.click();
        }, 1000);
    }
    function clickUpdateAppt() {
        const updateBtn = document.querySelector('#updateButton, input[type="submit"][value="Update Appt"], button[value="Update Appt"]');
        if (!updateBtn) {
            addLog(`[Link] No Update Appt button found => closing window...`);
            window.close();
            return;
        }
        const frm = document.forms["EDITAPPT"];
        if (frm && frm.displaymode) {
            frm.displaymode.value = "Update Appt";
        }
        if (typeof window.onButUpdate === "function") {
            window.onButUpdate();
        }
        addLog(`[Link] Clicking 'Update Appt' to finalize link...`);
        setTimeout(() => {
            updateBtn.click();
            setTimeout(() => {
                window.close();
            }, 2000);
        }, 1000);
    }

    function createFloatingButtonHTML() {
        const button = document.createElement('button');
        button.id = 'float-btn';
        button.title = 'Open CliniStream';
        button.innerHTML = '⚕<span class="scan-progress"></span>';
        if (buttonPosition.x && buttonPosition.y) {
            button.style.left = buttonPosition.x + 'px';
            button.style.top = buttonPosition.y + 'px';
            button.style.right = 'auto';
            button.style.bottom = 'auto';
        }
        return button;
    }

    function createTemplateToolbarHTML() {
        let dropdownHtml = '';
        encounterTemplates.forEach(template => {
            dropdownHtml += `<div class="template-mini-dropdown-item" data-template-id="${template.id}">${template.name}</div>`;
        });
        return `
        <div class="template-mini-toolbar" id="template-mini-toolbar">
            <div class="template-mini-menu">
                <button id="template-mini-btn">Insert Template</button>
                <div class="template-mini-dropdown" id="template-mini-dropdown">
                    ${dropdownHtml}
                </div>
            </div>
            <button id="template-mini-close" class="close-btn">×</button>
        </div>`;
    }

    function initTemplateVariableButtons() {
        $('.insert-variable-btn').off('click').on('click', function() {
            const variable = $(this).data('variable');
            const textarea = document.getElementById('template-content-input');
            if (textarea) {
                const startPos = textarea.selectionStart;
                const endPos = textarea.selectionEnd;
                textarea.value =
                    textarea.value.substring(0, startPos) +
                    variable +
                    textarea.value.substring(endPos);
                textarea.selectionStart = startPos + variable.length;
                textarea.selectionEnd = startPos + variable.length;
                textarea.focus();
            }
        });
    }

    function createExamTemplate(examData) {
        const container = document.createElement('div');
        container.className = 'exam-template';
        Object.keys(examData).forEach(sectionName => {
            const section = document.createElement('div');
            section.className = 'exam-section';
            const title = document.createElement('h4');
            title.textContent = sectionName;
            section.appendChild(title);
            const options = document.createElement('div');
            options.className = 'exam-options';
            const normalOption = document.createElement('div');
            normalOption.className = 'exam-option selected';
            normalOption.textContent = 'Normal';
            normalOption.dataset.value = 'normal';
            normalOption.dataset.section = sectionName;
            options.appendChild(normalOption);
            examData[sectionName].forEach(finding => {
                const option = document.createElement('div');
                option.className = 'exam-option';
                option.textContent = finding.label;
                option.dataset.value = finding.value;
                option.dataset.type = finding.type || 'abnormal';
                option.dataset.section = sectionName;
                options.appendChild(option);
            });
            section.appendChild(options);
            const preview = document.createElement('div');
            preview.className = 'exam-preview';
            preview.textContent = `${sectionName}: Normal`;
            preview.dataset.section = sectionName;
            section.appendChild(preview);
            container.appendChild(section);
        });
        container.querySelectorAll('.exam-option').forEach(option => {
            option.addEventListener('click', function() {
                const section = this.dataset.section;
                const isNormal = this.dataset.value === 'normal';
                if (isNormal) {
                    container.querySelectorAll(`.exam-option[data-section="${section}"]`).forEach(opt => {
                        if (opt.dataset.value !== 'normal') {
                            opt.classList.remove('selected');
                        } else {
                            opt.classList.add('selected');
                        }
                    });
                } else {
                    container.querySelector(`.exam-option[data-section="${section}"][data-value="normal"]`)
                        .classList.remove('selected');
                    this.classList.toggle('selected');
                    const selectedOptions = container.querySelectorAll(`.exam-option.selected[data-section="${section}"]`);
                    if (selectedOptions.length === 0) {
                        container.querySelector(`.exam-option[data-section="${section}"][data-value="normal"]`)
                            .classList.add('selected');
                    }
                }
                updateExamPreview(container, section);
            });
        });
        return container;
    }

    function updateExamPreview(container, section) {
        const preview = container.querySelector(`.exam-preview[data-section="${section}"]`);
        const selectedOptions = Array.from(
            container.querySelectorAll(`.exam-option.selected[data-section="${section}"]`)
        );
        if (selectedOptions.length === 0 || (selectedOptions.length === 1 && selectedOptions[0].dataset.value === 'normal')) {
            preview.textContent = `${section}: Normal`;
            return;
        }
        const findings = selectedOptions.map(opt => opt.textContent);
        preview.textContent = `${section}: ${findings.join(', ')}`;
        const allOptions = Array.from(
            container.querySelectorAll(`.exam-option[data-section="${section}"]`)
        ).filter(opt => opt.dataset.value !== 'normal');
        const notSelected = allOptions.filter(opt => !selectedOptions.includes(opt));
        if (notSelected.length > 0 && notSelected.some(opt => opt.dataset.type === 'important')) {
            const negatives = notSelected
                .filter(opt => opt.dataset.type === 'important')
                .map(opt => opt.textContent);
            if (negatives.length > 0) {
                preview.textContent += `\nPertinent negatives: No ${negatives.join(', no ')}`;
            }
        }
    }

    function insertExamTemplate(templateId, textarea) {
        if (templateId === 'template_respiratory_exam') {
            const container = createExamTemplate({
                'Inspection': [
                    { label: 'Increased work of breathing', value: 'increased_work', type: 'important' },
                    { label: 'Use of accessory muscles', value: 'accessory_muscles' },
                    { label: 'Barrel chest', value: 'barrel_chest' },
                    { label: 'Scars', value: 'scars' }
                ],
                'Palpation': [
                    { label: 'Decreased expansion', value: 'decreased_expansion', type: 'important' },
                    { label: 'Tenderness', value: 'tenderness', type: 'important' },
                    { label: 'Increased fremitus', value: 'increased_fremitus' },
                    { label: 'Decreased fremitus', value: 'decreased_fremitus' }
                ],
                'Percussion': [
                    { label: 'Dull', value: 'dull', type: 'important' },
                    { label: 'Hyper-resonant', value: 'hyper_resonant' }
                ],
                'Auscultation': [
                    { label: 'Wheezes', value: 'wheezes', type: 'important' },
                    { label: 'Crackles', value: 'crackles', type: 'important' },
                    { label: 'Rhonchi', value: 'rhonchi' },
                    { label: 'Decreased breath sounds', value: 'decreased_breath_sounds', type: 'important' },
                    { label: 'Bronchial breathing', value: 'bronchial_breathing' }
                ]
            });
            textarea.value += '\n\nRespiratory Examination:\n- Inspection: Normal\n- Palpation: Normal\n- Percussion: Normal\n- Auscultation: Normal\n';
            const editorContainer = document.createElement('div');
            editorContainer.className = 'interactive-exam-editor';
            editorContainer.style.position = 'fixed';
            editorContainer.style.top = '50%';
            editorContainer.style.left = '50%';
            editorContainer.style.transform = 'translate(-50%, -50%)';
            editorContainer.style.backgroundColor = '#fff';
            editorContainer.style.padding = '20px';
            editorContainer.style.borderRadius = '8px';
            editorContainer.style.boxShadow = '0 0 20px rgba(0,0,0,0.3)';
            editorContainer.style.zIndex = '10000';
            editorContainer.style.maxWidth = '800px';
            editorContainer.style.maxHeight = '80vh';
            editorContainer.style.overflow = 'auto';
            const title = document.createElement('h3');
            title.textContent = 'Interactive Respiratory Exam Editor';
            editorContainer.appendChild(title);
            editorContainer.appendChild(container);
            const buttonRow = document.createElement('div');
            buttonRow.style.marginTop = '15px';
            buttonRow.style.textAlign = 'right';
            const cancelBtn = document.createElement('button');
            cancelBtn.textContent = 'Cancel';
            cancelBtn.style.marginRight = '10px';
            cancelBtn.style.padding = '5px 15px';
            cancelBtn.onclick = () => {
                document.body.removeChild(editorContainer);
            };
            const insertBtn = document.createElement('button');
            insertBtn.textContent = 'Insert Exam';
            insertBtn.style.padding = '5px 15px';
            insertBtn.style.backgroundColor = '#28a745';
            insertBtn.style.color = 'white';
            insertBtn.style.border = 'none';
            insertBtn.style.borderRadius = '4px';
            insertBtn.onclick = () => {
                let examText = 'Respiratory Examination:\n';
                container.querySelectorAll('.exam-preview').forEach(preview => {
                    examText += preview.textContent + '\n';
                });
                const basicPattern = /Respiratory Examination:\n- Inspection: Normal\n- Palpation: Normal\n- Percussion: Normal\n- Auscultation: Normal\n/;
                textarea.value = textarea.value.replace(basicPattern, examText);
                document.body.removeChild(editorContainer);
            };
            buttonRow.appendChild(cancelBtn);
            buttonRow.appendChild(insertBtn);
            editorContainer.appendChild(buttonRow);
            document.body.appendChild(editorContainer);
            return;
        }
        // Otherwise, use the regular insertion.
    }

    // --- AI Functions ---
    function resetAiUi() {
        $('#ai-error-display').hide();
        $('#ai-summary-panel').html('<i>Click the ⚕️ button next to a note to generate summary.</i>');
        $('#ai-insights-panel').empty();
        $('#ai-full-panel').empty();
        $('#ai-comparison-panel').empty();
        $('.ai-tab-button[data-tab-target="comparison"]').hide();
        $('.ai-tab-button').removeClass('active');
        $('.ai-tab-button[data-tab-target="summary"]').addClass('active');
        $('.ai-tab-panel').removeClass('active').hide();
        $('#ai-summary-panel').addClass('active').show();
        $('#ai-insert-btn, #ai-refine-btn, #ai-regenerate-btn').prop('disabled', true);
        currentAiResponse = { fullText: '', coreSummary: '', insights: '', modelIndex: -1, originalNote: '' };
    }

    function handleAiInsert() {
        if (!lastFocusedTextarea) {
            alert("Please select a textarea first");
            return;
        }

        const options = `
        <div class="ai-action-options">
            <button class="insert-full">Full Response</button>
            <button class="insert-summary">Summary Only</button>
            <button class="insert-insights">Insights Only</button>
            <button class="cancel-btn">Cancel</button>
        </div>
    `;

        const $btn = $('#ai-insert-btn');
        const origText = $btn.text();
        $btn.after(options);
        $btn.hide();

        $('.ai-action-options .insert-full').on('click', function() {
            insertTextIntoTextarea(lastFocusedTextarea, currentAiResponse.fullText);
            cleanupActionOptions();
        });

        $('.ai-action-options .insert-summary').on('click', function() {
            insertTextIntoTextarea(lastFocusedTextarea, currentAiResponse.coreSummary);
            cleanupActionOptions();
        });

        $('.ai-action-options .insert-insights').on('click', function() {
            insertTextIntoTextarea(lastFocusedTextarea, currentAiResponse.insights);
            cleanupActionOptions();
        });

        $('.ai-action-options .cancel-btn').on('click', function() {
            cleanupActionOptions();
        });

        function cleanupActionOptions() {
            $('.ai-action-options').remove();
            $btn.text(origText).show();
        }
    }

    function handleAiRefine() {
        if (!lastFocusedTextarea) {
            alert("Please select a textarea first");
            return;
        }

        const options = `
        <div class="ai-action-options">
            <input type="text" id="refine-instruction" placeholder="Enter instructions...">
            <button class="refine-submit">Refine</button>
            <button class="cancel-btn">Cancel</button>
        </div>
    `;

        const $btn = $('#ai-refine-btn');
        const origText = $btn.text();
        $btn.after(options);
        $btn.hide();

        const $input = $('#refine-instruction');
        $input.focus();

        $('.ai-action-options .refine-submit').on('click', function() {
            const instructions = $input.val().trim();
            if (!instructions) {
                alert("Please enter refining instructions");
                return;
            }

            const prompt = `
ORIGINAL CLINICAL NOTE:
\`\`\`
${currentAiResponse.originalNote}
\`\`\`

CURRENT SUMMARY:
\`\`\`
${currentAiResponse.fullText}
\`\`\`

REFINEMENT INSTRUCTIONS:
${instructions}

Please provide a revised clinical summary based on the original note and the refinement instructions. Maintain the same structured format with Subjective, Objective, Assessment, Plan sections and Critical Insights, but incorporate the requested changes.
`;

            $('#ai-processing-indicator').show();
            $('.ai-action-options').html('<span class="loading-span">Processing refinement request...</span>');

            callOpenRouterAPI(prompt, AI_API_KEY, currentAiResponse.modelIndex)
                .then(function(result) {
                updateAiOverlayContent({
                    fullText: result.text,
                    coreSummary: parseAIResponse(result.text).coreSummary,
                    insights: parseAIResponse(result.text).insights
                }, result.modelIndexUsed);
                cleanupActionOptions();
            })
                .catch(function(error) {
                displayAiError(error.message);
                cleanupActionOptions();
            })
                .finally(function() {
                $('#ai-processing-indicator').hide();
            });
        });

        $('.ai-action-options .cancel-btn').on('click', function() {
            cleanupActionOptions();
        });

        function cleanupActionOptions() {
            $('.ai-action-options').remove();
            $btn.text(origText).show();
        }
    }

    function handleAiRegenerate() {
        if (!currentAiResponse.originalNote) {
            alert("No original note to regenerate from");
            return;
        }

        $('#ai-processing-indicator').show();
        $('.ai-tab-button').prop('disabled', true);

        // Try with backup model
        const currentModelIdx = currentAiResponse.modelIndex;
        const backupModelIdx = (currentModelIdx + 1) % AI_MODELS.length;

        const prompt = `
ENCOUNTER NOTE:
\`\`\`
${currentAiResponse.originalNote}
\`\`\`

CLINICAL SUMMARY GUIDELINES:
Extract key clinical info, use clear language, prioritize actionable insights.

Subjective:
- Concise patient-reported concerns
- Key symptoms
- Visit purpose

Objective:
- Vital signs
- Medications
- Physical exam findings
- Test results

Assessment:
- Primary diagnoses
- Clinical reasoning
- Key considerations

Plan:
- Treatment
- Prescriptions
- Follow-up
- Pending tests

Critical Insights:
- Key clinical considerations
- Care optimization points
- Urgent follow-up needs

Use bullet points, avoid redundancy, focus on relevance.
`;

        callOpenRouterAPI(prompt, AI_API_KEY, backupModelIdx)
            .then(function(result) {
            // Setup comparison view
            setupComparisonView(
                currentAiResponse.fullText,
                result.text,
                AI_MODELS[currentModelIdx],
                AI_MODELS[backupModelIdx]
            );

            $('.ai-tab-button[data-tab-target="comparison"]').show();
            $('.ai-tab-button').removeClass('active');
            $('.ai-tab-button[data-tab-target="comparison"]').addClass('active');
            $('.ai-tab-panel').removeClass('active').hide();
            $('#ai-comparison-panel').addClass('active').show();
        })
            .catch(function(error) {
            displayAiError("Regeneration failed: " + error.message);
        })
            .finally(function() {
            $('#ai-processing-indicator').hide();
            $('.ai-tab-button').prop('disabled', false);
        });
    }

    function setupComparisonView(originalText, newText, originalModel, newModel) {
        const originalModelName = originalModel.split('/')[1] || originalModel;
        const newModelName = newModel.split('/')[1] || newModel;

        const comparisonHtml = `
        <div class="ai-comparison-container">
            <div class="ai-comparison-panel original">
                <h4>Original (${originalModelName})</h4>
                <div class="comparison-content original-content">${originalText}</div>
                <button class="select-btn select-original">Use This Version</button>
            </div>
            <div class="ai-comparison-panel new">
                <h4>New Version (${newModelName})</h4>
                <div class="comparison-content new-content">${newText}</div>
                <button class="select-btn select-new">Use This Version</button>
            </div>
        </div>
    `;

        $('#ai-comparison-panel').html(comparisonHtml);

        $('.select-original').on('click', function() {
            // Keep original, do nothing
            $('.ai-tab-button[data-tab-target="summary"]').click();
        });

        $('.select-new').on('click', function() {
            // Update with new response
            const parsed = parseAIResponse(newText);
            updateAiOverlayContent(parsed, currentAiResponse.modelIndex);
        });
    }

    function insertTextIntoTextarea(textarea, text) {
        if (!textarea) return;

        const startPos = textarea.selectionStart;
        const endPos = textarea.selectionEnd;

        let prefix = textarea.value.substring(0, startPos);
        if (prefix.length > 0 && !prefix.endsWith('\n') && !prefix.endsWith('\r\n')) {
            prefix += '\n\n';
        }

        textarea.value = prefix + text + textarea.value.substring(endPos);
        textarea.selectionStart = startPos + text.length;
        textarea.selectionEnd = startPos + text.length;
        textarea.focus();

        closeModal();
        addLog("[AI] Inserted text into textarea");
    }

    // --- Core Modal Control Functions ---
    function enableButtonDrag($button) {
        let isDragging = false;
        let startX, startY, startLeft, startTop;
        $button.on("mousedown", function(e) {
            if (e.button !== 0) return;
            isDragging = true;
            startX = e.clientX;
            startY = e.clientY;
            startLeft = parseInt($button.css('left')) || parseInt($button.css('right')) || 0;
            startTop = parseInt($button.css('top')) || parseInt($button.css('bottom')) || 0;
            const isRight = $button.css('right') !== 'auto';
            const isBottom = $button.css('bottom') !== 'auto';
            $button.data('position', { isRight, isBottom });
            e.preventDefault();
            e.stopPropagation();
        });
        $(document)
            .on("mousemove", function(e) {
                if (!isDragging) return;
                const dx = e.clientX - startX;
                const dy = e.clientY - startY;
                const pos = $button.data('position') || { isRight: true, isBottom: true };
                const windowWidth = $(window).width();
                const windowHeight = $(window).height();
                const buttonWidth = $button.outerWidth();
                const buttonHeight = $button.outerHeight();
                let left, top;
                if (pos.isRight) {
                    left = windowWidth - startLeft - buttonWidth - dx;
                    $button.css('right', 'auto');
                } else {
                    left = startLeft + dx;
                }
                if (pos.isBottom) {
                    top = windowHeight - startTop - buttonHeight - dy;
                    $button.css('bottom', 'auto');
                } else {
                    top = startTop + dy;
                }
                left = Math.max(10, Math.min(left, windowWidth - buttonWidth - 10));
                top = Math.max(10, Math.min(top, windowHeight - buttonHeight - 10));
                $button.css({
                    left: `${left}px`,
                    top: `${top}px`
                });
                buttonPosition = { x: left, y: top };
            })
            .on("mouseup", function() {
                if (isDragging) {
                    isDragging = false;
                    saveButtonPosition();
                }
            });
    }

    function positionModal(focusedElement) {
        const $modal = $('#modal');
        if (!$modal.length) return;

        const windowWidth = $(window).width();
        const windowHeight = $(window).height();
        const modalWidth = $modal.outerWidth();
        const modalHeight = $modal.outerHeight();
        const margin = 20;

        // Default position (center of screen)
        let left = (windowWidth - modalWidth) / 2;
        let top = (windowHeight - modalHeight) / 2;

        // If modal is too tall for the screen, make it scrollable
        if (modalHeight > windowHeight - 2*margin) {
            $modal.css({
                'max-height': (windowHeight - 2*margin) + 'px',
                'overflow-y': 'auto'
            });
        }

        // If focused element is provided, try to position near it
        if (focusedElement) {
            try {
                const rect = focusedElement.getBoundingClientRect();
                left = Math.min(rect.left, windowWidth - modalWidth - margin);
                top = rect.top + rect.height + 10;

                // If would go off bottom of screen, position above element instead
                if (top + modalHeight > windowHeight - margin) {
                    top = Math.max(margin, rect.top - modalHeight - 10);
                }
            } catch (e) {
                console.log("Error positioning modal:", e);
                // Fall back to center positioning
            }
        }

        // Ensure modal stays within viewport
        left = Math.max(margin, Math.min(left, windowWidth - modalWidth - margin));
        top = Math.max(margin, Math.min(top, windowHeight - modalHeight - margin));

        $modal.css({
            'top': top + 'px',
            'left': left + 'px'
        });
    }

    // ============================================================
    // BLOCK 1: REPLACE openModal FUNCTION
    // ============================================================
// ============================================================
// BLOCK 3: REPLACE openModal FUNCTION
// ============================================================
    function openModal(defaultTab = null, data = {}) {
        addLog(`[UI] openModal called. Target Tab: ${defaultTab || 'default'}, Data: ${JSON.stringify(data)}`); // *** MORE LOGGING ***
        try {
            const $overlay = $('#modal-overlay');
            if (!$overlay.length) {
                addLog("[UI Error] Modal overlay element (#modal-overlay) not found in DOM.");
                alert("Error: CliniStream modal element not found. Please try refreshing the page.");
                return;
            }

            addLog("[UI] Modal overlay found. Setting display: flex and fading in...");
            // Set display and fade in
            $overlay.css('display', 'flex').hide().fadeIn(200, function() {
                addLog("[UI] Modal fadeIn complete."); // Log on completion
                isModalOpen = true; // Set flag after animation starts/completes
            });


            // Handle specific tab loading logic
            if (defaultTab === 'billing' && data.aptNo) {
                currentBillingAptNo = data.aptNo;
                addLog(`[UI] Setting currentBillingAptNo = ${currentBillingAptNo}`);
                switchToTab('billing'); // Switch tab first
                populateBillingForm(currentBillingAptNo); // Then populate
            } else if (defaultTab === 'ai' && data.element) {
                lastFocusedTextarea = data.element; // Store the textarea for AI tab
                switchToTab('ai');
                // AI tab content loading is triggered by the AI button click handler
            } else {
                loadDefaultTabData(); // Load data for the default active tab
            }

            // Position the modal (optional, consider removing if causing issues)
            // positionModal(lastFocusedEl); // Might be better to let CSS handle centering initially

        } catch (e) {
            addLog(`[UI Error] Exception in openModal: ${e.message} ${e.stack}`);
            console.error("Error opening modal:", e);
        }
    }
// ============================================================
// END BLOCK 3
// ============================================================
    // ============================================================
    // END BLOCK 1
    // ============================================================

 // ============================================================
// BLOCK 4: REPLACE closeModal FUNCTION
// ============================================================
    function closeModal() {
        addLog("[UI] closeModal called."); // *** ADDED LOG ***
        // Check if the modal is actually visible/open before trying to close
        if (!$('#modal-overlay').is(':visible')) {
            addLog("[UI] closeModal called but overlay is not visible. Resetting state anyway.");
            isModalOpen = false; // Ensure state is reset
            // Reset relevant states even if visually closed
            lastFocusedEl = null;
            currentBillingAptNo = null;
            selectedICDCodes = [];
            lastFocusedTextarea = null;
            return;
        }

        $('#modal-overlay').fadeOut(150, function() {
            addLog("[UI] Modal fadeOut complete."); // *** ADDED LOG ***
            isModalOpen = false;
            // Reset states after closing
            lastFocusedEl = null;
            currentBillingAptNo = null;
            selectedICDCodes = [];
            lastFocusedTextarea = null;
        });

        // Hide suggestion box if it exists
        const $box = getOrCreateSuggestionBox(); // Assuming this function exists and returns the jQuery object
        if ($box && $box.length) {
            $box.hide().empty();
            addLog("[UI] Suggestion box hidden.");
        }
    }
// ============================================================
// END BLOCK 4
// ============================================================

    function switchToTab(targetTabId) {
        $('.tab-button').removeClass('active');
        $(`.tab-button[data-tab="${targetTabId}"]`).addClass('active');
        $('.tab-pane').removeClass('active').hide();
        $(`#tab-${targetTabId}`).addClass('active').show();
        if (targetTabId === 'templates') {
            loadTemplateList();
        } else if (targetTabId === 'multibill') {
            loadMultiBillData();
        } else if (targetTabId === 'log') {
            updateLogContent();
        }
    }

    // --- Template Tab Functions ---
    function populateTemplateCategories() {
        const categories = [...new Set(encounterTemplates.map(t => t.category))];
        const $tabs = $('#template-category-tabs');
        $tabs.empty();
        categories.forEach(category => {
            const $tab = $(`<button class="template-category-tab" data-category="${category}">${category}</button>`);
            $tabs.append($tab);
        });
        if (categories.length > 0) {
            $tabs.find('.template-category-tab').first().addClass('active');
        }
    }

    function loadTemplateList(category = null) {
        const $list = $('#template-list-container');
        $list.empty();
        if (!category) {
            const $activeTab = $('#template-category-tabs .template-category-tab.active');
            if ($activeTab.length) {
                category = $activeTab.data('category');
            } else if ($('#template-category-tabs .template-category-tab').length) {
                const $firstTab = $('#template-category-tabs .template-category-tab').first();
                $firstTab.addClass('active');
                category = $firstTab.data('category');
            }
        }
        const filteredTemplates = category
        ? encounterTemplates.filter(t => t.category === category)
        : encounterTemplates;
        if (filteredTemplates.length === 0) {
            $list.html('<div class="template-list-empty">No templates in this category. Click "Add New Template" to create one.</div>');
            return;
        }
        filteredTemplates.forEach(template => {
            const $item = $(`
            <div class="template-item" data-template-id="${template.id}">
                <div class="template-name">${template.name}</div>
                <div class="template-actions">
                    <button class="insert-btn">Insert</button>
                    <button class="edit-btn">Edit</button>
                    <button class="delete-btn">Delete</button>
                </div>
            </div>
        `);
            $item.find('.insert-btn').on('click', function(e) {
                e.stopPropagation();
                insertTemplateText(template.id);
                closeModal();
            });
            $item.find('.edit-btn').on('click', function(e) {
                e.stopPropagation();
                openTemplateEditor(template.id);
            });
            $item.find('.delete-btn').on('click', function(e) {
                e.stopPropagation();
                if (confirm(`Are you sure you want to delete the "${template.name}" template?`)) {
                    deleteTemplate(template.id);
                    loadTemplateList(category);
                }
            });
            $item.on('click', function() {
                insertTemplateText(template.id);
                closeModal();
            });
            $list.append($item);
        });
    }

    function openTemplateEditor(templateId = null) {
        const isNew = !templateId;
        const template = isNew ? null : encounterTemplates.find(t => t.id === templateId);

        // Make sure the container exists and has the proper content
        if (!$('#template-edit-container').length || $('#template-edit-container').children().length === 0) {
            $('#template-edit-container').html(`
            <h4 id="template-form-title">Add New Template</h4>
            <label for="template-name-input">Template Name:</label>
            <input type="text" id="template-name-input" placeholder="Enter template name...">
            <label for="template-category-input">Category:</label>
            <select id="template-category-input">
                <option value="Encounter Note">Encounter Note</option>
                <option value="Physical Exam">Physical Exam</option>
                <option value="Presenting Complaint">Presenting Complaint</option>
                <option value="Other">Other</option>
            </select>
            <label for="template-content-input">Template Content:</label>
            <textarea id="template-content-input" placeholder="Enter template content..."></textarea>
            <div class="template-variables">
                <h5>Available Variables:</h5>
                <p>Insert these variables in your template:</p>
                <div class="variable-buttons">
                    <button class="insert-variable-btn" data-variable="{{DATE_TIME}}">Current Date/Time</button>
                    <button class="insert-variable-btn" data-variable="{{REASON}}">Reason for Visit</button>
                </div>
            </div>
            <div class="template-form-actions">
                <button id="template-cancel-btn">Cancel</button>
                <button id="template-save-btn">Save Template</button>
            </div>
        `);

            // Re-attach event handlers
            $('#template-save-btn').on('click', saveTemplateForm);
            $('#template-cancel-btn').on('click', closeTemplateEditor);
        }

        $('#template-form-title').text(isNew ? 'Add New Template' : 'Edit Template');
        $('#template-name-input').val(template ? template.name : '');
        $('#template-category-input').val(template ? template.category : 'Encounter Note');
        $('#template-content-input').val(template ? template.content : '');
        $('#template-edit-container').show();
        $('#template-list-container').hide();
        $('#template-category-tabs').hide();
        $('#add-template-btn').hide();
        $('#template-save-btn').data('template-id', templateId);

        initTemplateVariableButtons();
    }

    function closeTemplateEditor() {
        $('#template-edit-container').hide();
        $('#template-list-container').show();
        $('#template-category-tabs').show();
        $('#add-template-btn').show();
    }
    function saveTemplateForm() {
        const templateId = $('#template-save-btn').data('template-id');
        const name = $('#template-name-input').val().trim();
        const category = $('#template-category-input').val();
        const content = $('#template-content-input').val();
        if (!name) {
            alert('Please enter a template name');
            return;
        }
        if (!content) {
            alert('Please enter template content');
            return;
        }
        if (templateId) {
            editTemplate(templateId, name, category, content);
        } else {
            addTemplate(name, category, content);
        }
        closeTemplateEditor();
        populateTemplateCategories();
        loadTemplateList(category);
    }

    // --- Initialize Mini Template Toolbar ---
    function initTemplateToolbar() {
        if (isEncounterPage && !$('#template-mini-toolbar').length) {
            const textarea = getEncounterNoteTextarea();
            if (!textarea) {
                console.log("Cannot initialize template toolbar - textarea not found");
                return;
            }
            const dropdownItems = encounterTemplates.map(t =>
                `<div class="template-mini-dropdown-item" data-template-id="${t.id}">${t.name}</div>`
            ).join('');
            const toolbarHtml = `
            <div class="template-mini-toolbar" id="template-mini-toolbar">
                <div class="template-mini-menu">
                    <button id="template-mini-btn">Insert Template</button>
                    <div class="template-mini-dropdown" id="template-mini-dropdown">
                        ${dropdownItems}
                    </div>
                </div>
                <button id="template-mini-close" class="close-btn">×</button>
            </div>`;
            $('body').append(toolbarHtml);
            const $textarea = $(textarea);
            const $toolbar = $('#template-mini-toolbar');
            $toolbar.css({
                top: ($textarea.offset().top + 5) + 'px',
                left: ($textarea.offset().left + 5) + 'px'
            });
            $('#template-mini-btn').on('click', function() {
                $('#template-mini-dropdown').toggleClass('active');
            });
            $('#template-mini-close').on('click', function() {
                $toolbar.remove();
            });
            enableToolbarDrag($toolbar);
            $('.template-mini-dropdown-item').on('click', function() {
                const templateId = $(this).data('template-id');
                insertTemplateText(templateId);
                $('#template-mini-dropdown').removeClass('active');
            });
            $(document).on('click', function(e) {
                if (!$(e.target).closest('.template-mini-menu').length) {
                    $('#template-mini-dropdown').removeClass('active');
                }
            });
        }
    }
    function enableToolbarDrag($toolbar) {
        let isDragging = false;
        let startX, startY, startLeft, startTop;
        $toolbar.on('mousedown', function(e) {
            if ($(e.target).is('button') || $(e.target).closest('.template-mini-dropdown').length) {
                return;
            }
            isDragging = true;
            startX = e.clientX;
            startY = e.clientY;
            startLeft = parseInt($toolbar.css('left')) || 0;
            startTop = parseInt($toolbar.css('top')) || 0;
            e.preventDefault();
        });
        $(document).on('mousemove', function(e) {
            if (!isDragging) return;
            const dx = e.clientX - startX;
            const dy = e.clientY - startY;
            $toolbar.css({
                left: (startLeft + dx) + 'px',
                top: (startTop + dy) + 'px'
            });
        });
        $(document).on('mouseup', function() {
            isDragging = false;
        });
    }

    // --- ICD9 Data Handling ---
    async function loadDxData() {
        addLog("[ICD9] Attempting to load codes...");
        return new Promise(resolve => {
            GM_xmlhttpRequest({
                method: 'GET',
                url: DX_JSON_URL,
                onload: function(resp) {
                    if (resp.status === 200 && resp.responseText) {
                        try {
                            dxData = JSON.parse(resp.responseText);
                            addLog(`[ICD9] Successfully loaded ${dxData.length} codes.`);
                        } catch (e) {
                            dxData = [];
                            addLog(`[ICD9] Error parsing JSON: ${e.message}`);
                        }
                    } else {
                        dxData = [];
                        addLog(`[ICD9] Failed to fetch codes. Status: ${resp.status}`);
                    }
                    resolve();
                },
                onerror: function(err) {
                    dxData = [];
                    addLog(`[ICD9] Request error: ${err.error || 'Unknown'}`);
                    resolve();
                },
                ontimeout: function() {
                    dxData = [];
                    addLog(`[ICD9] Request timed out.`);
                    resolve();
                }
            });
        });
    }
    function attachDxAutocomplete($input) {
        if (!$input || !$input.length) {
            return;
        }
        $input.off('.dxSearch');
        $input.data('autocomplete-attached', true);
        addLog(`[ICD9] Attaching autocomplete to ${$input.attr('id') || 'unknown input'}`);
        const $box = getOrCreateSuggestionBox();
        let searchTimer;
        let currentIndex = -1;
        let currentSuggestions = [];
        function showSuggestions() {
            const value = $input.val().trim().toLowerCase();
            $box.hide().empty();
            currentIndex = -1;
            currentSuggestions = [];
            if (!value || value.length < 2) {
                return;
            }
            if (!dxData || !dxData.length) {
                $box.html('<div class="dx-no-results">ICD9 data not loaded</div>');
                positionSuggestionBox($input, $box);
                $box.show();
                return;
            }
            let results = [];
            if (/^\d+/.test(value)) {
                results = dxData.filter(o => (o.code || "").toLowerCase().startsWith(value));
            } else {
                results = dxData.filter(o => (o.description || "").toLowerCase().includes(value));
            }
            results = results.slice(0, 15);
            if (!results.length) {
                $box.html('<div class="dx-no-results">No results found</div>');
            } else {
                results.forEach(r => {
                    const $item = $('<div></div>')
                        .html(`<strong>${r.code}</strong> ${r.description || ""}`)
                        .data('code', r.code)
                        .data('desc', r.description || "");
                    $item.on('mousedown', function(e) {
                        e.preventDefault();
                        addSelectedICDCode($(this).data('code'), $(this).data('desc'));
                        $input.val('').focus();
                        $box.hide();
                    });
                    $box.append($item);
                    currentSuggestions.push($item);
                });
            }
            positionSuggestionBox($input, $box);
            $box.show();
        }
        $input.on('keyup.dxSearch', function(e) {
            const key = e.key;
            if (key === 'ArrowDown' || key === 'ArrowUp' || key === 'Enter' || key === 'Escape') {
                return;
            }
            clearTimeout(searchTimer);
            searchTimer = setTimeout(showSuggestions, 300);
        });
        $input.on('keydown.dxSearch', function(e) {
            const key = e.key;
            if (key === 'ArrowDown') {
                e.preventDefault();
                if (currentSuggestions.length === 0) return;
                if (currentIndex >= 0) {
                    currentSuggestions[currentIndex].removeClass('selected');
                }
                currentIndex = (currentIndex + 1) % currentSuggestions.length;
                currentSuggestions[currentIndex].addClass('selected');
                const $selected = currentSuggestions[currentIndex];
                const $container = $box;
                const selTop = $selected.position().top;
                const selBottom = selTop + $selected.outerHeight();
                const contHeight = $container.height();
                if (selBottom > contHeight) {
                    $container.scrollTop($container.scrollTop() + (selBottom - contHeight));
                } else if (selTop < 0) {
                    $container.scrollTop($container.scrollTop() + selTop);
                }
            } else if (key === 'ArrowUp') {
                e.preventDefault();
                if (currentSuggestions.length === 0) return;
                if (currentIndex >= 0) {
                    currentSuggestions[currentIndex].removeClass('selected');
                }
                currentIndex = currentIndex <= 0 ? currentSuggestions.length - 1 : currentIndex - 1;
                currentSuggestions[currentIndex].addClass('selected');
                const $selected = currentSuggestions[currentIndex];
                const $container = $box;
                const selTop = $selected.position().top;
                const selBottom = selTop + $selected.outerHeight();
                const contHeight = $container.height();
                if (selBottom > contHeight) {
                    $container.scrollTop($container.scrollTop() + (selBottom - contHeight));
                } else if (selTop < 0) {
                    $container.scrollTop($container.scrollTop() + selTop);
                }
            } else if (key === 'Enter') {
                e.preventDefault();
                if (currentIndex >= 0 && currentSuggestions.length > 0) {
                    const $selected = currentSuggestions[currentIndex];
                    addSelectedICDCode($selected.data('code'), $selected.data('desc'));
                    $input.val('');
                    $box.hide();
                } else {
                    const manualCode = $input.val().trim();
                    if (manualCode && /^[a-zA-Z]?\d+(\.\d+)?$/.test(manualCode)) {
                        addSelectedICDCode(manualCode, 'Manual Entry');
                        $input.val('');
                        $box.hide();
                    }
                }
            } else if (key === 'Escape') {
                $box.hide();
            }
        });
        $input.on('focus.dxSearch', function() {
            const value = $input.val().trim();
            if (value.length >= 2) {
                showSuggestions();
            }
        });
        $input.on('blur.dxSearch', function() {
            setTimeout(() => {
                if (!$box.is(':hover')) {
                    $box.hide();
                }
            }, 200);
        });
    }
    function getOrCreateSuggestionBox() {
        if (!icdSuggestionBox) {
            icdSuggestionBox = $('<div class="dx-suggestion-box"></div>');
            icdSuggestionBox.css({
                display: 'none',
                position: 'absolute',
                zIndex: 10001
            });
            $('body').append(icdSuggestionBox);
        }
        return icdSuggestionBox;
    }
    function positionSuggestionBox($input, $box) {
        if (!$input || !$input.length || !$box || !$box.length) return;
        const inputRect = $input[0].getBoundingClientRect();
        const inputHeight = $input.outerHeight();
        const boxWidth = Math.max($input.outerWidth(), 300);
        const windowHeight = window.innerHeight;
        const scrollTop = $(window).scrollTop();
        let top = inputRect.bottom + window.scrollY + 5;
        let left = inputRect.left + window.scrollX;
        const boxHeight = $box.outerHeight() || 200;
        if (top + boxHeight > windowHeight + scrollTop) {
            const spaceAbove = inputRect.top - scrollTop;
            const spaceBelow = windowHeight - inputRect.bottom;
            if (spaceAbove > spaceBelow && spaceAbove >= 100) {
                top = inputRect.top + window.scrollY - boxHeight - 5;
            } else {
                $box.css('max-height', Math.max(100, windowHeight - top - 20) + 'px');
            }
        }
        const rightEdge = left + boxWidth;
        const windowWidth = window.innerWidth;
        if (rightEdge > windowWidth) {
            left = Math.max(5, windowWidth - boxWidth - 5);
        }
        $box.css({
            top: top + 'px',
            left: left + 'px',
            width: boxWidth + 'px'
        });
    }
    function updateSelectedCodesUI() {
        const $container = $('#icd9-selected-codes');
        $container.empty();
        if (!selectedICDCodes.length) {
            $container.html('<div class="placeholder">No codes selected (Max 3).</div>');
            return;
        }
        selectedICDCodes.forEach((item, index) => {
            const $div = $(`
                <div class="chosen-code">
                    <span><strong>${item.code}</strong> - ${item.description}</span>
                    <button title="Remove Code">×</button>
                </div>
            `);
            $div.find('button').on('click', function() {
                selectedICDCodes.splice(index, 1);
                updateSelectedCodesUI();
            });
            $container.append($div);
        });
    }
    function addSelectedICDCode(code, description) {
        if (!code) return;
        if (selectedICDCodes.length >= 3) {
            alert("Maximum of 3 ICD9 codes allowed.");
            return;
        }
        if (selectedICDCodes.some(x => x.code === code)) {
            alert("This code is already added.");
            return;
        }
        selectedICDCodes.push({ code, description });
        updateSelectedCodesUI();
    }
    function populateBillingForm(aptNo) {
        resetBillingUI(); // Clear previous state
        if (!aptNo) {
            $('#billing-apt-no').text('N/A');
            $('#billing-hin-display').text('HIN: N/A'); // Clear HIN display
            return;
        }
        $('#billing-apt-no').text(aptNo);

        // Handle potential aptNo mismatch on encounter page
        if (isEncounterPage) {
            const urlParams = new URLSearchParams(window.location.search);
            const appointmentNoFromUrl = urlParams.get('appointmentNo');
            if (appointmentNoFromUrl && appointmentNoFromUrl !== aptNo) {
                aptNo = appointmentNoFromUrl;
                $('#billing-apt-no').text(aptNo);
                addLog(`[Billing] Updated appointment number from URL: ${aptNo}`);
            }
        }

        // --- Get Data ---
        const scannedData = getScannedData(aptNo); // Get latest scan data
        const existingData = getBillingData(aptNo); // Get saved billing choices
        const patientAge = scannedData?.age || 0;

        // --- Display HIN ---
        const hinDisplay = scannedData?.hin || 'N/A';
        $('#billing-hin-display').text(`HIN: ${hinDisplay}`);
        addLog(`[Billing] Displaying HIN: ${hinDisplay} for Apt #${aptNo}`);
        // --- End Display HIN ---

        addLog(`[Billing] Loading data for Apt #${aptNo}. Scanned: ${JSON.stringify(scannedData)}, Existing: ${JSON.stringify(existingData)}`);

        // --- Populate SubType Dropdown ---
        const $subTypeSelect = $('#billingSubType');
        $subTypeSelect.empty();
        const aptType = (scannedData?.type || 'unknown').toLowerCase();

        // Add options based on scanned type (more dynamic)
        if (aptType.includes("office")) {
            $subTypeSelect.append('<option value="office_visit">Office Visit</option>');
            $subTypeSelect.append('<option value="office_counseling">Office Counseling</option>');
        } else if (aptType.includes("tele") || aptType.includes("phone")) {
            $subTypeSelect.append('<option value="phone_visit">Phone Visit</option>');
            $subTypeSelect.append('<option value="tele_counseling">Telehealth Counseling</option>');
        } else {
            // Fallback if type is unknown or other
            $subTypeSelect.append('<option value="">-- Select --</option>');
            $subTypeSelect.append('<option value="office_visit">Office Visit</option>');
            $subTypeSelect.append('<option value="phone_visit">Phone Visit</option>');
        }
        // Always add other common/manual options
        $subTypeSelect.append(`
            <option value="office_counseling">Office Counseling</option>
            <option value="tele_counseling">Telehealth Counseling</option>
            <option value="brief_conference">Brief Conference (<15m)</option>
            <option value="conference_with_acp">Conference W ACP (15m Units)</option>
            <option value="fp_conference">FP Conf. w/ AH Prof (15m Units)</option>
            <option value="advice_community">Advice To Community Agency</option>
            <option value="fp_advice_response">FP Advice Response To AH Prof</option>
            <option value="fp_advice_per15">FP Advice Per 15m to AH Prof</option>
            <option value="manual">Manual Code Entry</option>
        `);

        // --- Determine Selected Subtype (Prioritize saved data) ---
        const selectedSubtype = existingData?.subType || (
            aptType.includes("office") ? "office_visit" :
            (aptType.includes("tele") || aptType.includes("phone") ? "phone_visit" : "") // Default based on scan if no saved data
        );
        $subTypeSelect.val(selectedSubtype); // Set the dropdown value

        // --- Update Service Code & Additional Fields ---
        // Pass existingData.serviceCode to prioritize it if available
        updateServiceCode(selectedSubtype, patientAge, existingData?.serviceCode);
        updateAdditionalFields(selectedSubtype, {
            serviceStartTime: existingData?.serviceStartTime || scannedData?.startTime || "",
            serviceEndTime: existingData?.serviceEndTime || scannedData?.endTime || "",
            units: existingData?.units || "1"
        });

        // --- Populate ICD9 Codes (Prioritize saved data) ---
        selectedICDCodes = []; // Reset global selection
        if (existingData?.dxString) {
            const dxCodes = existingData.dxString.split(',').map(s => s.trim()).filter(Boolean);
            dxCodes.forEach(code => {
                let desc = 'Manual Entry';
                const found = dxData.find(d => d.code === code); // dxData should be loaded globally
                if (found) desc = found.description;
                // Check limit before pushing
                if (selectedICDCodes.length < 3) {
                    selectedICDCodes.push({ code, description: desc });
                }
            });
        }
        updateSelectedCodesUI(); // Update the display of selected codes

        // --- Attach Autocomplete ---
        const $search = $('#icd9-search-input');
        if ($search.length && !$search.data('autocomplete-attached')) { // Avoid re-attaching
            attachDxAutocomplete($search);
            addLog("[Billing] Attached ICD9 autocomplete");
        } else if ($search.data('autocomplete-attached')) {
            addLog("[Billing] ICD9 autocomplete already attached");
        } else {
            addLog("[Billing] Warning: Could not find ICD9 search input");
        }
    }
    function resetBillingUI() {
        $('#billingSubType').val('');
        $('#billingServiceCode').val('');
        $('#billing-additional-fields').empty().hide();
        selectedICDCodes = [];
        updateSelectedCodesUI();
    }
    function updateServiceCode(subType, age, manualCode = '') {
        let code = manualCode;
        if (subType === 'manual') {
            $('#billingServiceCode').prop('readonly', false);
        } else {
            $('#billingServiceCode').prop('readonly', true);
            const mapping = codeMap[subType];
            if (mapping) {
                const entry = mapping.find(r => age >= r.minAge && age <= r.maxAge);
                code = entry ? entry.code : '';
            } else {
                code = '';
            }
        }
        $('#billingServiceCode').val(code);
    }
    function updateAdditionalFields(subType, data = {}) {
        const $container = $('#billing-additional-fields').empty();
        let fieldsAdded = false;
        if (requiresTime.includes(subType)) {
            $container.append(`
                <label for="serviceStartTime">Start Time:</label>
                <input type="text" id="serviceStartTime" placeholder="HH:MM"><br>
                <label for="serviceEndTime">End Time:</label>
                <input type="text" id="serviceEndTime" placeholder="HH:MM">
            `);
            $('#serviceStartTime').val(data.serviceStartTime || '');
            $('#serviceEndTime').val(data.serviceEndTime || '');
            fieldsAdded = true;
        }
        if (requiresUnits.includes(subType)) {
            $container.append(`
                <label for="billingUnits">Units:</label>
                <input type="text" id="billingUnits" placeholder="1">
            `);
            $('#billingUnits').val(data.units || '1');
            fieldsAdded = true;
        }
        if (fieldsAdded) {
            $container.show();
        } else {
            $container.hide();
        }
    }
    function saveBillingInfo() {
        if (!currentBillingAptNo) {
            alert("No appointment selected.");
            return;
        }
        const subType = $('#billingSubType').val();
        const serviceCode = $('#billingServiceCode').val().trim();
        let serviceStartTime = "";
        let serviceEndTime = "";
        let units = "";
        if (requiresTime.includes(subType)) {
            serviceStartTime = $('#serviceStartTime').val().trim();
            serviceEndTime = $('#serviceEndTime').val().trim();
        }
        if (requiresUnits.includes(subType)) {
            units = $('#billingUnits').val().trim() || '1';
        }
        if (!subType || !serviceCode) {
            alert("Please select an Encounter Type and ensure Service Code is present.");
            return;
        }
        if (selectedICDCodes.length === 0) {
            alert("Please select at least one ICD9 diagnosis code.");
            return;
        }
        const dxString = selectedICDCodes.map(item => item.code).join(',');
        const dataToSave = {
            subType,
            serviceCode,
            dxString,
            serviceStartTime,
            serviceEndTime,
            units
        };
        setBillingData(currentBillingAptNo, dataToSave);
        addLog(`[Billing] Saved data for Apt #${currentBillingAptNo}: ${JSON.stringify(dataToSave)}`);
        updateAppointmentButton(currentBillingAptNo, 'modify', serviceCode, dxString);
        closeModal();
    }
    function updateAppointmentButton(aptNo, status = null, serviceCode = null, dxString = null) {
        const $button = $(`.bill-button[data-apt-no="${aptNo}"]`);
        if (!$button.length) return;

        const scannedData = getScannedData(aptNo); // Get scan data once

        // --- Handle Explicit Status Updates (from saving) ---
        if (status === 'modify') {
            $button.text('Modify')
                  .removeClass('error submitted')
                  .addClass('modify')
                  .attr('title', `Bill ready: ${serviceCode || '?'} / ${dxString || '?'} | HIN: ${scannedData?.hin || 'N/A'}`) // Add HIN
                  .css('background-color', '#28a745');
            return;
        }

        // --- Determine Status Based on Page and Scan Data ---

        // Check if Oscar shows it as billed
        const $billingLink = $(`a[title="Billing"][onclick*="appointment_no=${aptNo}"]`);
        if ($billingLink.length) {
            const linkText = $billingLink.text().trim();
            const onClick = $billingLink.attr('onclick') || '';
            if (linkText === '-B' || onClick.includes('onUnbilled(')) {
                $button.text('Billed')
                       .removeClass('modify error')
                       .addClass('submitted')
                       .attr('title', `Billed | HIN: ${scannedData?.hin || 'N/A'}`) // Add HIN
                       .css('background-color', '#dc3545')
                       .prop('disabled', true); // Disable billed buttons
                return;
            }
        }
         $button.prop('disabled', false); // Re-enable if not billed

        // Check if scan data is missing
        if (!scannedData) {
            $button.text('Bill')
                  .removeClass('modify submitted error')
                  .css('background-color', mainColor)
                  .attr('title', 'Scan needed for patient details');
            return;
        }

        // Check for scan errors (e.g., missing age/DOB or HIN if required)
        // Example: Treat missing HIN as an error for this button state
        if (scannedData.age === 0 || !scannedData.hin) {
            $button.text('Error')
                  .removeClass('modify submitted')
                  .addClass('error')
                  .css('background-color', '#f39c12')
                  .attr('title', `Scan Error - Age: ${scannedData.age}, HIN: ${scannedData.hin || 'Missing'} - Try Scan Again`);
            return;
        }

        // Default 'Bill' state if scanned successfully and not billed
        $button.text('Bill')
              .removeClass('modify error submitted')
              .css('background-color', mainColor)
              .attr('title', `${scannedData.patientName || 'Patient'} - Age: ${scannedData.age} - HIN: ${scannedData.hin} - Type: ${scannedData.type || 'N/A'}`);
    }

    // --- Appointment Scanning Functions ---
// --- Appointment Scanning Functions ---
    function fetchApptDetail(url, aptNo, initialStartTime = "00:00", initialEndTime = "00:00") {
        return new Promise((resolve, reject) => {
            addLog(`[Scan] Fetching details for Apt #${aptNo}...`);
            GM_xmlhttpRequest({
                method: 'GET',
                url: url,
                timeout: 10000, // Increased timeout slightly
                onload: function(resp) {
                    if (resp.status !== 200) {
                        addLog(`[Scan Error] #${aptNo} => Fetch failed with status ${resp.status}`);
                        setScannedData(aptNo, {
                            age: 0,
                            type: 'other',
                            startTime: initialStartTime,
                            endTime: initialEndTime,
                            dob: null,
                            hin: null, // Added HIN field
                            patientName: "Fetch Failed",
                            timestamp: Date.now() // Add timestamp for cleanup
                        });
                        scanFailureCount++;
                        updateAppointmentButton(aptNo); // Update button status
                        reject(`Failed to fetch details for Apt #${aptNo}`);
                        return;
                    }
                    try {
                        const parser = new DOMParser();
                        const doc = parser.parseFromString(resp.responseText, 'text/html');

                        // --- Extract Patient Name ---
                        let patientName = "Unknown";
                        // Try specific header first, fallback to general h3
                        const nameHeaderSpecific = doc.querySelector('td > h3'); // Often name is inside a TD->H3
                        const nameHeaderGeneral = doc.querySelector('h3');
                        if (nameHeaderSpecific) {
                            patientName = nameHeaderSpecific.textContent.trim().split('-')[0].trim();
                        } else if (nameHeaderGeneral) {
                             patientName = nameHeaderGeneral.textContent.trim().split('-')[0].trim();
                        }

                        // --- Extract Appointment Type ---
                        let apptType = 'other';
                        const statusSelect = doc.querySelector('select[name="status"]');
                        if (statusSelect) {
                            const selectedOption = statusSelect.querySelector('option[selected]');
                            if (selectedOption) {
                                const typeText = selectedOption.textContent.toLowerCase();
                                if (typeText.includes('office')) apptType = 'office';
                                else if (typeText.includes('telephon') || typeText.includes('phone')) apptType = 'telephone';
                                else if (typeText.includes('virtual')) apptType = 'virtual';
                                // Add other types as needed
                            }
                        } else {
                            // Fallback: Check text content if select is missing
                            const typeReasonElement = Array.from(doc.querySelectorAll('td, th')).find(el => el.textContent.toLowerCase().includes('type:'));
                            if (typeReasonElement) {
                                const typeText = typeReasonElement.textContent.toLowerCase();
                                if (typeText.includes('office')) apptType = 'office';
                                else if (typeText.includes('telephon') || typeText.includes('phone')) apptType = 'telephone';
                                else if (typeText.includes('virtual')) apptType = 'virtual';
                            }
                        }

                        // --- Extract DOB and Calculate Age ---
                        let age = 0;
                        let dobStr = null;
                        const dobRegex = /DOB:\s*\(?(\d{4}-\d{2}-\d{2})\)?/;
                        // Search all text nodes for DOB pattern
                        const walker = doc.createTreeWalker(doc.body, NodeFilter.SHOW_TEXT, null, false);
                        let node;
                        while(node = walker.nextNode()) {
                            const match = node.nodeValue.match(dobRegex);
                            if (match && match[1]) {
                                dobStr = match[1];
                                age = calcAge(dobStr);
                                break; // Found DOB, stop searching
                            }
                        }
                        // Fallback search in table cells if not found in text nodes
                        if (!dobStr) {
                            const cells = doc.querySelectorAll('th, td');
                            for (const cell of cells) {
                                const match = cell.textContent.match(dobRegex);
                                if (match && match[1]) {
                                    dobStr = match[1];
                                    age = calcAge(dobStr);
                                    break;
                                }
                            }
                        }

                        // --- Extract HIN/PHN ---
                        let hin = null;
                        const hinRegex = /^\s*(\d{9,10})\s*$/; // Regex for 9 or 10 digits, allowing whitespace
                        const potentialHinCells = doc.querySelectorAll('td');
                        for (const cell of potentialHinCells) {
                            const cellText = cell.textContent.trim();
                            const match = cellText.match(hinRegex);
                            if (match && match[1]) {
                                // Basic check: is it near the DOB or name? (Optional refinement)
                                // For simplicity, we take the first match found in a TD.
                                hin = match[1];
                                break; // Found HIN, stop searching
                            }
                        }

                        // --- Store Scanned Data ---
                        setScannedData(aptNo, {
                            age,
                            type: apptType,
                            startTime: initialStartTime,
                            endTime: initialEndTime,
                            dob: dobStr,
                            hin: hin, // Store the extracted HIN
                            patientName,
                            timestamp: Date.now() // Add timestamp for cleanup
                        });

                        updateAppointmentButton(aptNo); // Update button status
                        scanSuccessCount++;
                        addLog(`[Scan Success] #${aptNo} => ${patientName}, age=${age}, HIN=${hin || 'Not Found'}, type=${apptType}`);
                        resolve(aptNo);

                    } catch (error) {
                        addLog(`[Scan Error] #${aptNo} => Parse error: ${error.message}`);
                        setScannedData(aptNo, {
                            age: 0,
                            type: 'other',
                            startTime: initialStartTime,
                            endTime: initialEndTime,
                            dob: null,
                            hin: null, // Added HIN field
                            patientName: "Parse Error",
                            timestamp: Date.now() // Add timestamp for cleanup
                        });
                        scanFailureCount++;
                        updateAppointmentButton(aptNo); // Update button status
                        reject(`Parse error for Apt #${aptNo}: ${error.message}`);
                    }
                },
                onerror: function(error) {
                    addLog(`[Scan Error] #${aptNo} => Request error: ${error.error || 'Unknown'}`);
                    setScannedData(aptNo, {
                        age: 0,
                        type: 'other',
                        startTime: initialStartTime,
                        endTime: initialEndTime,
                        dob: null,
                        hin: null, // Added HIN field
                        patientName: "Request Failed",
                        timestamp: Date.now() // Add timestamp for cleanup
                    });
                    scanFailureCount++;
                    updateAppointmentButton(aptNo); // Update button status
                    reject(`Request error for Apt #${aptNo}`);
                },
                ontimeout: function() {
                    addLog(`[Scan Error] #${aptNo} => Request timed out`);
                     setScannedData(aptNo, {
                        age: 0,
                        type: 'other',
                        startTime: initialStartTime,
                        endTime: initialEndTime,
                        dob: null,
                        hin: null, // Added HIN field
                        patientName: "Timeout",
                        timestamp: Date.now() // Add timestamp for cleanup
                    });
                    scanFailureCount++;
                    updateAppointmentButton(aptNo); // Update button status
                    reject(`Timeout for Apt #${aptNo}`);
                }
            });
        });
    }

    function scanAppointments() {
        if (!isAppointmentPage) {
            alert("Scanning appointments is only available on the appointment page.");
            return;
        }
        addLog("[Scan] Starting appointment scan...");
        const $scanBtn = $('#float-btn, #scan-appointments-btn');
        setButtonState($scanBtn.first(), "Scanning...", "#f39c12", true);
        setButtonState($('#scan-appointments-btn'), "Scanning...", "#f39c12", true);
        scanError = false;
        scanSuccessCount = 0;
        scanFailureCount = 0;
        scanTotalCount = 0;
        const $links = $('a.apptLink');
        if ($links.length === 0) {
            addLog("[Scan] No appointments found.");
            setButtonState($scanBtn.first(), "No Appts", "#c0392b", false);
            setButtonState($('#scan-appointments-btn'), "No Appts", "#c0392b", false);
            setTimeout(() => {
                setButtonState($('#float-btn'), "⚕", mainColor, false);
                setButtonState($('#scan-appointments-btn'), "Scan Appointments", mainColor, false);
                $('.scan-progress').text('');
            }, 3000);
            return;
        }
        const tasks = [];
        const processedAptNos = new Set();
        $links.each(function() {
            const oc = $(this).attr('onclick') || '';
            const aptMatch = oc.match(/appointment_no=(\d+)/);
            if (!aptMatch) return;
            const aptNo = aptMatch[1];
            if (processedAptNos.has(aptNo)) return;
            processedAptNos.add(aptNo);
            const $row = $(this).closest('tr');
            const $billingLink = $row.find(`a[title="Billing"][onclick*="appointment_no=${aptNo}"]`);
            if ($billingLink.length) {
                const linkText = $billingLink.text().trim();
                const billingOc = $billingLink.attr("onclick") || "";
                if (linkText === '-B' || billingOc.includes("onUnbilled(")) {
                    addLog(`[Scan] Skipping billed appointment #${aptNo}`);
                    return;
                }
            }
            const urlMatch = oc.match(/'([^']+)'/);
            if (!urlMatch) return;
            let detailUrl = urlMatch[1].replace('../', '/oscar/');
            if (!detailUrl.startsWith('/')) {
                detailUrl = '/' + detailUrl;
            }
            if (!detailUrl.startsWith('/oscar/')) {
                detailUrl = '/oscar/' + detailUrl.replace(/^\/*/, '');
            }
            const fullUrl = window.location.origin + detailUrl;
            let startTime = "00:00";
            let endTime = "00:00";
            const $timeCell = $row.find('td').first();
            const timeText = $timeCell.text().trim();
            if (timeText.includes('-')) {
                const timeParts = timeText.split('-');
                startTime = convertTo24Hour(timeParts[0].trim());
                endTime = convertTo24Hour(timeParts[1].trim());
            } else if (timeText) {
                startTime = convertTo24Hour(timeText);
            }
            addLog(`[Scan] Queuing Apt #${aptNo} for scanning. Time: ${startTime}-${endTime}`);
            tasks.push(() => fetchApptDetail(fullUrl, aptNo, startTime, endTime));
        });
        scanTotalCount = tasks.length;
        if (scanTotalCount === 0) {
            addLog("[Scan] No valid appointments to scan.");
            setButtonState($scanBtn.first(), "No Valid Appts", "#c0392b", false);
            setTimeout(() => {
                setButtonState($('#float-btn'), "⚕", mainColor, false);
                setButtonState($('#scan-appointments-btn'), "Scan Appointments", mainColor, false);
                $('.scan-progress').text('');
            }, 3000);
            return;
        }
        $('.scan-progress').text(`(0/${scanTotalCount})`);
        (async function() {
            await runSequentialPromises(tasks, SCAN_FETCH_DELAY_MS);
            addLog(`[Scan] Finished. Success: ${scanSuccessCount}, Failed: ${scanFailureCount}`);
            if (scanError || scanFailureCount > 0) {
                setButtonState($scanBtn.first(), "Scan Error", "#c0392b", false);
                setButtonState($('#scan-appointments-btn'), "Scan Error", "#c0392b", false);
            } else {
                setButtonState($scanBtn.first(), "Scan Complete", "#28a745", false);
                setButtonState($('#scan-appointments-btn'), "Scan Complete", "#28a745", false);
                GM_setValue("lastScanTimestamp", Date.now());
            }
            setTimeout(() => {
                setButtonState($('#float-btn'), "⚕", mainColor, false);
                setButtonState($('#scan-appointments-btn'), "Scan Appointments", mainColor, false);
                $('.scan-progress').text('');
                if ($('#tab-multibill').is(':visible')) {
                    loadMultiBillData();
                }
            }, 5000);
        })();
    }
    function loadMultiBillData() {
        if (!isAppointmentPage) {
            $('#multibill-content').html('<p style="text-align:center; padding:20px; color:#721c24;">The Multi-Bill feature is only available on the appointment page.</p>');
            return;
        }

        addLog("[MultiBill] Loading data...");
        const $content = $('#multibill-content');
        $content.html('<p style="text-align:center; padding:20px;"><img src="/oscar/images/Oscar-icon.png" style="width:20px; height:20px; vertical-align:middle; margin-right:5px;"> Loading appointments...</p>');

        const $appts = $('a.apptLink');
        if (!$appts.length) {
            $content.html('<p style="text-align:center; padding:20px; color:#721c24;">No appointments found on this page.</p>');
            return;
        }

        let rowsData = [];
        const processedAptNos = new Set();

        // Gather data for each unique appointment link
        $appts.each(function() {
            const oc = $(this).attr('onclick') || '';
            const aptMatch = oc.match(/appointment_no=(\d+)/);
            if (!aptMatch) return;

            const aptNo = aptMatch[1];
            if (processedAptNos.has(aptNo)) return; // Skip duplicates
            processedAptNos.add(aptNo);

            const patientName = $(this).text().trim();
            const scannedData = getScannedData(aptNo); // Get latest scan
            const existingBillingData = getBillingData(aptNo); // Get saved choices

            rowsData.push({
                aptNo,
                patientName,
                scanned: scannedData, // May be null if scan failed/not run
                existing: existingBillingData // May be null if not saved
            });
        });

        if (!rowsData.length) {
            // Changed message to be more informative
            $content.html('<p style="text-align:center; padding:20px; color:#721c24;">No appointment data found. Try running "Scan Appointments" first.</p>');
            return;
        }

        // --- Build Table HTML ---
        // Added HIN column header
        let tableHtml = `
    <div style="overflow-x: auto; max-height: 60vh;">
        <table class="oscar-table" style="width: 100%; min-width: 900px;">
            <thead>
                <tr style="position: sticky; top: 0; background: #fff; z-index: 10;">
                    <th>Apt#</th>
                    <th>Patient</th>
                    <th>HIN</th>
                    <th>Type</th>
                    <th>Age</th>
                    <th>Sub-Type</th>
                    <th>Service Code</th>
                    <th>Start</th>
                    <th>End</th>
                    <th>Units</th>
                    <th>Dx1</th>
                    <th>Dx2</th>
                    <th>Dx3</th>
                </tr>
            </thead>
            <tbody>
    `;

        // Create table rows
        rowsData.forEach((row, index) => {
            // Check billing status from the link on the page
            const $billingLink = $(`a[title="Billing"][onclick*="appointment_no=${row.aptNo}"]`);
            let isBilled = false;
            if ($billingLink.length) {
                const linkText = $billingLink.text().trim();
                const billingOc = $billingLink.attr("onclick") || "";
                isBilled = (linkText === '-B' || billingOc.includes("onUnbilled("));
            }

            const readOnly = isBilled ? 'disabled' : '';
            const rowClass = isBilled ? 'style="background-color:#f8d7da;"' : (index % 2 === 0 ? 'style="background-color:#f8f9fa;"' : 'style="background-color:#fff;"');

            // Get HIN from scanned data
            const hinDisplay = row.scanned?.hin || 'N/A'; // Use optional chaining

            // Get DX codes from existing saved data
            let dxArr = [];
            if (row.existing?.dxString) { // Use optional chaining
                dxArr = row.existing.dxString.split(',').map(s => s.trim()).filter(Boolean);
            }
            while (dxArr.length < 3) dxArr.push(''); // Pad array to 3 elements

            // Determine default SubType (prioritize existing, fallback to scan type)
            let defaultSubType = row.existing?.subType || '';
            if (!defaultSubType) {
                const apptType = (row.scanned?.type || '').toLowerCase();
                defaultSubType = apptType.includes('office') ? 'office_visit' :
                (apptType.includes('tele') || apptType.includes('phone') ? 'phone_visit' : ''); // Default based on scan
            }

            // Build SubType options HTML
            let subTypeOptionsHtml = '';
             // Add a blank option if no default is set
            if (!defaultSubType) {
                 subTypeOptionsHtml += '<option value="">-- Select --</option>';
            }
            [
                { value: "office_visit", label: "Office Visit" },
                { value: "office_counseling", label: "Office Counseling" },
                { value: "phone_visit", label: "Phone Visit" },
                { value: "tele_counseling", label: "Telehealth Counseling" },
                { value: "brief_conference", label: "Brief Conference" },
                { value: "conference_with_acp", label: "Conference W/ ACP" },
                { value: "fp_conference", label: "FP Conference" },
                { value: "advice_community", label: "Advice Community" },
                { value: "fp_advice_response", label: "FP Advice Response" },
                { value: "fp_advice_per15", label: "FP Advice Per 15min" },
                { value: "manual", label: "Manual Code Entry" }
            ].forEach(opt => {
                // Ensure the currently selected or defaulted type is marked 'selected'
                subTypeOptionsHtml += `<option value="${opt.value}" ${opt.value === defaultSubType ? 'selected' : ''}>${opt.label}</option>`;
            });


            // Determine Service Code (prioritize existing, fallback to calculation)
            let serviceCode = row.existing?.serviceCode || '';
            if (!serviceCode && defaultSubType && row.scanned?.age !== undefined && codeMap[defaultSubType]) {
                const mapping = codeMap[defaultSubType];
                const entry = mapping.find(r => row.scanned.age >= r.minAge && row.scanned.age <= r.maxAge);
                if (entry) serviceCode = entry.code;
            }

            // Add row HTML including the new HIN cell
            tableHtml += `
        <tr data-apt-no="${row.aptNo}" data-age="${row.scanned?.age || 0}" ${rowClass}>
            <td class="mb-apt">${row.aptNo}</td>
            <td class="mb-pat" title="${row.patientName}">${row.patientName.length > 20 ? row.patientName.substring(0, 18) + '...' : row.patientName}</td>
            <td>${hinDisplay}</td>
            <td>${row.scanned?.type || 'N/A'}</td>
            <td>${row.scanned?.age !== undefined ? row.scanned.age : '?'}</td>
            <td class="mb-subtype">
                <select class="mb-sub" ${readOnly}>${subTypeOptionsHtml}</select>
            </td>
            <td>
                <input type="text" class="mb-svc" value="${serviceCode}" ${defaultSubType !== 'manual' ? 'readonly' : ''} ${readOnly}>
            </td>
            <td>
                <input type="text" class="mb-start" value="${row.existing?.serviceStartTime || row.scanned?.startTime || ''}" ${readOnly}>
            </td>
            <td>
                <input type="text" class="mb-end" value="${row.existing?.serviceEndTime || row.scanned?.endTime || ''}" ${readOnly}>
            </td>
            <td>
                <input type="text" class="mb-units" value="${row.existing?.units || '1'}" ${readOnly}>
            </td>
            <td>
                <input type="text" class="mb-dx1" value="${dxArr[0]}" ${readOnly}>
            </td>
            <td>
                <input type="text" class="mb-dx2" value="${dxArr[1]}" ${readOnly}>
            </td>
            <td>
                <input type="text" class="mb-dx3" value="${dxArr[2]}" ${readOnly}>
            </td>
        </tr>
        `;
        });

        tableHtml += '</tbody></table></div>';
        $content.html(tableHtml); // Replace loading message with table

        // --- Attach Event Handlers ---
        $content.find('.mb-sub').on('change', function() {
            const $row = $(this).closest('tr');
            if ($row.find('select.mb-sub').prop('disabled')) return; // Skip if billed

            const age = parseInt($row.data('age'), 10) || 0;
            const subType = $(this).val();
            const $svcInput = $row.find('.mb-svc');

            if (subType === 'manual') {
                $svcInput.prop('readonly', false); // Allow manual entry
                // Optionally clear the code or leave it as is? Let's leave it.
            } else {
                $svcInput.prop('readonly', true); // Disable manual entry
                let calculatedCode = '';
                if (codeMap[subType]) {
                    const mapping = codeMap[subType];
                    const entry = mapping.find(r => age >= r.minAge && age <= r.maxAge);
                    if (entry) {
                        calculatedCode = entry.code;
                    }
                }
                 $svcInput.val(calculatedCode); // Update service code based on selection
            }
            // Update additional fields visibility if needed (e.g., time/units)
            // This requires more complex logic similar to updateAdditionalFields if needed in multibill
        });

        // Attach autocomplete to DX fields that are not disabled
        $content.find('.mb-dx1, .mb-dx2, .mb-dx3').each(function() {
            const $input = $(this);
            if (!$input.prop('disabled') && !$input.data('autocomplete-attached')) { // Check if not disabled and not already attached
                attachDxAutocomplete($input);
            }
        });

        addLog("[MultiBill] Data loaded and table rendered.");
    }
    function saveMultiBillChanges() {
        addLog("[MultiBill] Saving changes...");
        let changesMade = 0;
        let errors = 0;
        $('#multibill-content tbody tr').each(function() {
            const $row = $(this);
            const aptNo = $row.data('apt-no');
            if (!aptNo) return;
            if ($row.find('select.mb-sub').prop('disabled')) {
                return;
            }
            const subType = $row.find('.mb-sub').val();
            const serviceCode = $row.find('.mb-svc').val().trim();
            const startTime = $row.find('.mb-start').val().trim();
            const endTime = $row.find('.mb-end').val().trim();
            const units = $row.find('.mb-units').val().trim() || '1';
            const dx1 = $row.find('.mb-dx1').val().trim();
            const dx2 = $row.find('.mb-dx2').val().trim();
            const dx3 = $row.find('.mb-dx3').val().trim();
            if (!serviceCode) {
                addLog(`[MultiBill] Apt #${aptNo}: Missing service code.`);
                $row.css('background-color', '#fff0f0');
                errors++;
                return;
            }
            if (!dx1 && !dx2 && !dx3) {
                addLog(`[MultiBill] Apt #${aptNo}: Missing diagnosis codes.`);
                $row.css('background-color', '#fff0f0');
                errors++;
                return;
            }
            $row.css('background-color', '');
            const dxCodes = [dx1, dx2, dx3].filter(Boolean);
            const dxString = dxCodes.join(',');
            const dataToSave = {
                subType,
                serviceCode,
                dxString,
                serviceStartTime: startTime,
                serviceEndTime: endTime,
                units
            };
            setBillingData(aptNo, dataToSave);
            updateAppointmentButton(aptNo, 'modify', serviceCode, dxString);
            addLog(`[MultiBill] Saved data for Apt #${aptNo}`);
            changesMade++;
        });
        if (errors > 0) {
            alert(`Saved ${changesMade} appointments. ${errors} appointments had errors (highlighted in red).`);
        } else {
            alert(`Successfully saved data for ${changesMade} appointments.`);
            setButtonState($('#multibill-save-all'), "Saved!", "#28a745", false);
            setTimeout(() => {
                setButtonState($('#multibill-save-all'), "Save All Changes", "#28a745", false);
            }, 2000);
        }
    }

    function startBatchBilling() {
        if (!isAppointmentPage) {
            alert("Batch billing is only available on the appointment page.");
            return;
        }
        if (isModalOpen) {
            closeModal();
        }

        const $btn = $('#batch-bill-btn');
        // Prevent starting a new batch if one is already in progress
        if (isBatchValid()) {
            addLog("[Batch] Batch already in progress.");
            return;
        }

        addLog("[Batch] Starting batch billing process...");
        setButtonState($btn, "Processing Bills...", "#f39c12", true);
        batchError = false;
        batchSuccessCount = 0;
        batchFailureCount = 0;
        batchFailureList = [];
        clearBatchResults();

        // Gather all stored appointment data that haven't been billed
        const allKeys = GM_listValues().filter(k => k.startsWith("PHN-") && k.includes("-Appointment-"));
        if (!allKeys.length) {
            addLog("[Batch] No stored data => abort");
            setButtonState($btn, "No Bills Found", "#c0392b", false);
            setTimeout(() => {
                setButtonState($btn, "Batch Bill", mainColor, false);
            }, 3000);
            batchError = true;
            return;
        }

        // Gather unbilled appointments by checking billing links
        const $billingLinks = $('a[title="Billing"]');
        let aptNos = [];
        for (const key of allKeys) {
            const mm = key.match(/^PHN-9(\d+)-Appointment-(\d+)$/);
            if (!mm) continue;
            const aptNo = mm[2];
            const link = $billingLinks.filter((_, el) => {
                const oc = $(el).attr("onclick") || "";
                return oc.includes(`appointment_no=${aptNo}`);
            });
            if (!link.length) continue;
            const linkText = link.text().trim();
            const oc2 = link.attr("onclick") || "";
            if (linkText === '-B' || oc2.includes("onUnbilled(")) {
                continue;
            }
            aptNos.push(aptNo);
        }

        aptNos = [...new Set(aptNos)]; // Remove duplicates

        if (!aptNos.length) {
            addLog("[Batch] All stored appointments appear billed => nothing left");
            setButtonState($btn, "No Unbilled Appts", "green", false);
            setTimeout(() => {
                setButtonState($btn, "Batch Bill", mainColor, false);
            }, 3000);
            return;
        }

        const newID = "batch_" + Date.now();
        setBatchID(newID);
        setBatchQueueStr(aptNos.join(","));
        setBatchIndex(0);
        setBatchStart(Date.now());

        addLog(`[Batch] Created batch ID=${newID} with ${aptNos.length} appointments.`);
        setButtonState($btn, `Billing (0/${aptNos.length})`, "#f39c12", true);
        openNextBatchWindow();
    }

    function openNextBatchWindow() {
        if (!isBatchValid()) {
            addLog("[Batch] Batch state invalid, cannot continue.");
            setButtonState($('#batch-bill-btn'), "Error", "#c0392b", false);
            setTimeout(() => {
                setButtonState($('#batch-bill-btn'), "Batch Bill", mainColor, false);
            }, 3000);
            return;
        }

        const queue = parseBatchQueue(getBatchQueueStr());
        const index = getBatchIndex();

        if (index >= queue.length) {
            addLog("[Batch] Queue completed.");
            const results = getBatchResults();
            setButtonState($('#batch-bill-btn'), `Done: ${results.success}/${queue.length}`,
                           results.success === queue.length ? "#28a745" : "#f39c12", false);
            setTimeout(() => {
                setButtonState($('#batch-bill-btn'), "Batch Bill", mainColor, false);
            }, 5000);

            alert(`Batch Billing Completed:\nSuccessful: ${results.success}\nFailed: ${results.fail}` +
                  (results.fail > 0 ? `\nFailures (aptNos): ${results.failList.join(", ")}` : ""));

            clearBatchState();
            clearBatchResults();
            return;
        }

        const nextAptNo = queue[index];
        addLog(`[Batch] Processing Apt #${nextAptNo} (${index + 1}/${queue.length})`);
        setButtonState($('#batch-bill-btn'), `Billing (${index+1}/${queue.length})`, "#f39c12", true);

        // Find and click the billing link for this appointment
        const $billingLink = $(`a[title="Billing"][onclick*="appointment_no=${nextAptNo}"]`).first();

        if (!$billingLink.length) {
            addLog(`[Batch] No billing link found for Apt #${nextAptNo}`);
            incrementBatchIndexAndContinue(false, nextAptNo);
            return;
        }

        // Open in new window
        $billingLink[0].setAttribute('target', '_blank');
        $billingLink[0].click();
    }

    function startChartLinking() {
        try {
            const appts = getUnlinkedAppointments();
            if (!appts.length) {
                alert("No unlinked appointments found!");
                return;
            }
            setChartLinkingState(true, appts, 0, "", "");
            addLog(`[Link] Found ${appts.length} unlinked appointments. Starting with first...`);
            setButtonState($('#link-charts-btn'), `Linking (0/${appts.length})`, "#f39c12", true);
            gotoAppointment(0);
        } catch(e) {
            addLog(`[Link Error] Error starting chart linking: ${e.message}`);
            clearChartLinkingState();
            setButtonState($('#link-charts-btn'), "Link Charts", mainColor, false);
        }
    }

    window.incrementBatchIndexAndContinue = function(success, aptNo) {
        addLog(`[Batch child->parent] incrementBatchIndexAndContinue => #${aptNo}, success=${success}`);
        if (!isBatchValid()) return;
        const results = getBatchResults();
        if (success) {
            results.success++;
            addLog(`[Batch] Apt #${aptNo} succeeded.`);
        } else {
            results.fail++;
            results.failList.push(aptNo);
            addLog(`[Batch] Apt #${aptNo} failed.`);
        }
        setBatchResults(results.success, results.fail, results.failList);
        const nextIndex = getBatchIndex() + 1;
        setBatchIndex(nextIndex);
        const queue = parseBatchQueue(getBatchQueueStr());
        if (nextIndex < queue.length) {
            addLog(`[Batch] Moving to next appointment (${nextIndex + 1}/${queue.length}).`);
            setTimeout(() => {
                openNextBatchWindow();
            }, 1000);
        } else {
            addLog(`[Batch] Batch complete. Success: ${results.success}, Failed: ${results.fail}`);
            alert(`Batch Billing Completed:\nSuccessful: ${results.success}\nFailed: ${results.fail}` +
                  (results.fail > 0 ? `\nFailures (aptNos): ${results.failList.join(", ")}` : ""));
            setButtonState($('#batch-bill-btn'), `Done: ${results.success}/${queue.length}`,
                          results.success === queue.length ? "#28a745" : "#f39c12", false);
            setTimeout(() => {
                setButtonState($('#batch-bill-btn'), "Batch Bill", mainColor, false);
            }, 5000);
            clearBatchState();
            clearBatchResults();
        }
    };
    function childAutoFillThenContinue() {
        if (!isBatchValid()) {
            addLog("[Child] No valid batch in progress.");
            return;
        }
        const urlParams = new URLSearchParams(window.location.search);
        const aptNo = urlParams.get('appointment_no');
        if (!aptNo || !/^\d+$/.test(aptNo)) {
            addLog("[Child] Invalid appointment number in URL.");
            return;
        }
        const billingData = getBillingData(aptNo);
        if (!billingData || !billingData.serviceCode || !billingData.dxString) {
            addLog(`[Child] No billing data for appointment #${aptNo}.`);
            window.opener.incrementBatchIndexAndContinue(false, aptNo);
            window.close();
            return;
        }
        addLog(`[Child] Auto-filling form for #${aptNo} with data: ${JSON.stringify(billingData)}`);
        waitForSelector('#billing_1_fee', 10000)
            .then(() => {
                setTimeout(() => {
                    $('#billing_1_fee').val(billingData.serviceCode);
                    if (billingData.dxString) {
                        const dxCodes = billingData.dxString.split(',').map(s => s.trim()).filter(Boolean);
                        if (dxCodes[0]) {
                            $('#billing_1_fee_dx1').val(dxCodes[0]);
                            $('#diagnosis_num_1').val(dxCodes[0]);
                        }
                        if (dxCodes[1]) {
                            $('#billing_1_fee_dx2').val(dxCodes[1]);
                            $('#diagnosis_num_2').val(dxCodes[1]);
                        }
                        if (dxCodes[2]) {
                            $('#billing_1_fee_dx3').val(dxCodes[2]);
                            $('#diagnosis_num_3').val(dxCodes[2]);
                        }
                    }
                    if (billingData.serviceStartTime && $('#billing_1_startTime').length) {
                        $('#billing_1_startTime').val(billingData.serviceStartTime);
                    }
                    if (billingData.serviceEndTime && $('#billing_1_endTime').length) {
                        $('#billing_1_endTime').val(billingData.serviceEndTime);
                    }
                    if (billingData.units && $('#billing_1_quantity').length) {
                        $('#billing_1_quantity').val(billingData.units);
                    }
                    setTimeout(() => {
                        const $continueBtn = $('input[type="submit"][value="Continue"]');
                        if ($continueBtn.length) {
                            addLog(`[Child] Clicking Continue for #${aptNo}`);
                            $continueBtn[0].click();
                        } else {
                            addLog(`[Child] Continue button not found for #${aptNo}`);
                            window.opener.incrementBatchIndexAndContinue(false, aptNo);
                            window.close();
                        }
                    }, CONTINUE_DELAY_MS);
                }, FILL_DELAY_MS);
            })
            .catch(error => {
                addLog(`[Child] Error: ${error}`);
                window.opener.incrementBatchIndexAndContinue(false, aptNo);
                window.close();
            });
    }
    function childAutoClickFinalSubmit() {
        if (!isBatchValid()) {
            addLog("[Child-Final] No valid batch in progress.");
            return;
        }
        const urlParams = new URLSearchParams(window.location.search);
        const aptNo = urlParams.get('appointment_no');
        if (!aptNo || !/^\d+$/.test(aptNo)) {
            addLog("[Child] Invalid appointment number in URL.");
            window.close();
            return;
        }
        addLog(`[Child-Final] Preparing to save bill for #${aptNo}`);
        setTimeout(() => {
            const $saveBtn = $('input[type="submit"][value="Save Bill"]');
            if (!$saveBtn.length) {
                addLog(`[Child-Final] Save Bill button not found for #${aptNo}`);
                window.opener.incrementBatchIndexAndContinue(false, aptNo);
                window.close();
                return;
            }
            addLog(`[Child-Final] Clicking Save Bill for #${aptNo}`);
            $saveBtn[0].click();
            setTimeout(() => {
                try {
                    window.opener.incrementBatchIndexAndContinue(true, aptNo);
                } catch (e) {
                    addLog(`[Child-Final] Error communicating with parent: ${e.message}`);
                }
                addLog(`[Child-Final] Closing window for #${aptNo}`);
                window.close();
            }, FINAL_DELAY_MS);
        }, FILL_DELAY_MS);
    }

// ============================================================
// BLOCK 2: REPLACE injectAppointmentPageButtons FUNCTION
// ============================================================
    function injectAppointmentPageButtons() {
        if (!isAppointmentPage) return;
        addLog("[UI] Injecting appointment page elements...");
        try {
            // --- Floating Button ---
            if ($('#float-btn').length === 0) {
                const floatBtn = createFloatingButtonHTML();
                document.body.appendChild(floatBtn);
                addLog("[UI] Floating button element created and appended.");
            }
            const $floatBtn = $('#float-btn');
            // Ensure it's visible
            $floatBtn.css('display', 'block');
            // Use .off().on() to prevent duplicate listeners
            $floatBtn.off('click').on('click', () => {
                addLog("[UI] Floating button clicked. Attempting to call openModal..."); // *** ADDED LOG ***
                openModal();
            });
            enableButtonDrag($floatBtn);
            addLog("[UI] Floating button visibility set and click listener attached.");

            // --- Individual Bill Buttons ---
            $('a[title="Billing"]').each(function() {
                const $billingLink = $(this);
                // Check if button already exists next to this specific link
                if ($billingLink.next('.bill-button').length === 0) {
                    const onclick = $billingLink.attr('onclick') || '';
                    const aptMatch = onclick.match(/appointment_no=(\d+)/);
                    if (aptMatch && aptMatch[1]) {
                        const aptNo = aptMatch[1];
                        const btn = document.createElement('button');
                        btn.className = 'bill-button';
                        btn.textContent = 'Bill'; // Initial state
                        btn.setAttribute('data-apt-no', aptNo);
                        // Apply styles directly (redundant with CSS but ensures they are applied)
                        btn.style.backgroundColor = mainColor;
                        btn.style.color = '#fff';
                        btn.style.border = 'none';
                        btn.style.marginLeft = '4px';
                        btn.style.padding = '4px 7px';
                        btn.style.borderRadius = '4px';
                        btn.style.cursor = 'pointer';
                        btn.style.fontSize = '11px';
                        btn.style.verticalAlign = 'middle'; // Ensure vertical alignment

                        // Insert button after the billing link
                        $billingLink.after(btn);

                        // Attach click listener using jQuery's .off().on()
                        $(btn).off('click').on('click', function(e) {
                            e.preventDefault(); // Prevent default link behavior
                            e.stopPropagation(); // Stop event bubbling
                            addLog(`[UI] Bill button clicked for Apt #${aptNo}`);
                            lastFocusedEl = this; // Store reference if needed
                            // Pass aptNo directly
                            openModal('billing', { aptNo: aptNo, element: this });
                        });

                        // Update button appearance based on current data/status
                        updateAppointmentButton(aptNo);
                        // addLog(`[UI] Added Bill button for Apt #${aptNo}`); // Log moved to updateAppointmentButton for clarity
                    }
                } else {
                    // If button exists, ensure its state is updated
                    const aptNo = $billingLink.next('.bill-button').data('apt-no');
                    if (aptNo) {
                        updateAppointmentButton(aptNo);
                    }
                }
            });

            addLog("[UI] Appointment page elements injection/update complete.");
        } catch (e) {
            console.error("Error injecting appointment page elements:", e);
            addLog(`[UI Error] Failed to inject appointment page elements: ${e.message} ${e.stack}`);
        }
    }
// ============================================================
// END BLOCK 2
// ============================================================

    function clearLogDisplay() {
        cliniStreamBillLog = "";
        persistLog();
        updateLogContent();
        addLog("[Log] Display cleared.");
    }

    function saveLogToFile() {
        try {
            // Create file contents from the log
            const logContent = cliniStreamBillLog || "";

            // Create a blob with the content
            const blob = new Blob([logContent], { type: 'text/plain;charset=utf-8' });

            // Create a download link and trigger it
            const url = URL.createObjectURL(blob);
            const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
            const filename = `clinistream_log_${timestamp}.txt`;

            const a = document.createElement('a');
            a.href = url;
            a.download = filename;
            a.style.display = 'none';

            document.body.appendChild(a);
            a.click();

            // Clean up
            setTimeout(() => {
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
            }, 200);

            addLog(`[Log] Log file saved as ${filename}`);
        } catch (e) {
            console.error("Error saving log:", e);
            addLog(`[Log Error] Failed to save log: ${e.message}`);
            alert(`Error saving log file: ${e.message}`);
        }
    }

    function clearOldBillingData(olderThanTimestamp) {
        let removedCount = 0;
        const allKeys = GM_listValues();
        const billingKeys = allKeys.filter(k => k.startsWith("PHN-") && k.includes("-Appointment-"));
        const scanKeys = allKeys.filter(k => k.startsWith("ApptScan-"));
        for (const key of billingKeys) {
            const aptMatch = key.match(/Appointment-(\d+)$/);
            if (!aptMatch) continue;
            const aptNo = aptMatch[1];
            let shouldRemove = false;
            try {
                const scanDataJson = GM_getValue(`ApptScan-${aptNo}`, null);
                if (scanDataJson) {
                    const scanData = JSON.parse(scanDataJson);
                    if (scanData.timestamp && scanData.timestamp < olderThanTimestamp) {
                        shouldRemove = true;
                    }
                } else {
                    shouldRemove = true;
                }
            } catch (e) {
                shouldRemove = true;
            }
            if (shouldRemove) {
                GM_deleteValue(key);
                if (GM_getValue(`ApptScan-${aptNo}`)) {
                    GM_deleteValue(`ApptScan-${aptNo}`);
                }
                removedCount++;
            }
        }
        addLog(`[Cleanup] Removed ${removedCount} old appointment records.`);
        return removedCount;
    }
    function exportAllData() {
        try {
            const allKeys = GM_listValues();
            const exportData = {};
            for (const key of allKeys) {
                try {
                    exportData[key] = GM_getValue(key);
                } catch (e) {
                    exportData[key] = `ERROR: ${e.message}`;
                }
            }
            const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
            const json = JSON.stringify(exportData, null, 2);
            const blob = new Blob([json], {type: 'application/json'});
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `clinistream_export_${timestamp}.json`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            addLog("[Export] Data export completed.");
        } catch (e) {
            addLog(`[Export] Error: ${e.message}`);
            alert(`Export failed: ${e.message}`);
        }
    }
// ============================================================
// BLOCK 5: REPLACE addGlobalKeyListener FUNCTION
// ============================================================
    function addGlobalKeyListener() {
        // Use .off().on() to prevent duplicate listeners if script runs multiple times
        $(document).off('keydown.clinistream').on('keydown.clinistream', function(e) {
            // Check if focus is inside an input/textarea/select to avoid interfering with typing
            const isInputFocused = $(e.target).is('input, textarea, select');

            if (e.key === '`' && !isInputFocused) {
                addLog("[UI] Backtick key pressed."); // *** ADDED LOG ***
                e.preventDefault();
                if (isModalOpen) {
                    addLog("[UI] Backtick: Closing modal.");
                    closeModal();
                } else {
                    addLog("[UI] Backtick: Opening modal.");
                    openModal(); // Open with default tab
                }
            }
            else if (e.key === 'Escape') {
                addLog("[UI] Escape key pressed."); // *** ADDED LOG ***
                // Only close modal if it's open AND focus is not in a field where Esc might be used (like ICD9 search)
                if (isModalOpen && !$(e.target).is('#icd9-search-input')) {
                    addLog("[UI] Escape: Closing modal.");
                    closeModal();
                } else if (isModalOpen) {
                    addLog("[UI] Escape: Modal open but focus is potentially in an input, not closing.");
                }
            }
        });
        addLog("[Init] Global key listener attached/re-attached for backtick (`) and Escape keys.");
    }
// ============================================================
// END BLOCK 5
// ============================================================
    function injectEncounterPageElements() {
        if (!isEncounterPage) return;
        addLog("[UI] Encounter page detected, setting up elements...");
        try {
            $(AI_TEXTAREA_SELECTOR).each(function() {
                addAiTriggerButton(this);
            });
            initTemplateToolbar();
            const urlParams = new URLSearchParams(window.location.search);
            const appointmentNo = urlParams.get('appointmentNo');
            if (appointmentNo) {
                const $saveImg = $('#saveImg, input[type="image"][src*="save"], button:contains("Save")').first();
                if ($saveImg.length && !$('#save-bill-btn').length) {
                    const $billBtn = $(`<button id="save-bill-btn" style="margin-right:8px; padding:4px 8px; font-size:13px; background-color:${mainColor}; color:white; border:none; border-radius:4px; cursor:pointer;">Bill</button>`);
                    const existingBill = getBillingData(appointmentNo);
                    if (existingBill && existingBill.serviceCode && existingBill.dxString) {
                        $billBtn.text('Modify Bill').css('background-color', '#28a745');
                    }
                    $billBtn.on('click', function(e) {
                        e.preventDefault();
                        openModal('billing', {appointmentNo, element: this});
                    });
                    $saveImg.before($billBtn);
                    addLog(`[UI] Added billing button for appointment #${appointmentNo}`);
                }
            }
        } catch (e) {
            addLog(`[UI] Error initializing encounter page elements: ${e.message}`);
        }
        const observer = new MutationObserver(mutations => {
            mutations.forEach(mutation => {
                if (mutation.type === 'childList') {
                    mutation.addedNodes.forEach(node => {
                        if (node.nodeType === Node.ELEMENT_NODE) {
                            if (node.matches && node.matches(AI_TEXTAREA_SELECTOR)) {
                                addAiTriggerButton(node);
                            }
                            if (node.querySelectorAll) {
                                $(node).find(AI_TEXTAREA_SELECTOR).each(function() {
                                    addAiTriggerButton(this);
                                });
                            }
                        }
                    });
                }
            });
        });
        const targetNode = document.querySelector('form[name="caseManagementEntryForm"], form[name="encounterFormForm"]') || document.body;
        observer.observe(targetNode, { childList: true, subtree: true });
        addLog(`[UI] Observer set up for new textareas on ${targetNode.nodeName}.`);
    }

    function addAiTriggerButton(textarea) {
        if (!textarea || textarea.dataset.aiHelperButtonAdded) return;
        textarea.dataset.aiHelperButtonAdded = 'true';
        if (!textarea.id) {
            textarea.id = `ai-textarea-${Math.random().toString(36).substring(7)}`;
        }
        const $container = $(textarea.parentElement);
        if ($container.css('position') === 'static') {
            $container.css('position', 'relative');
        }
        const $button = $('<button></button>')
            .addClass('ai-trigger-button')
            .html('⚕️')
            .attr('title', 'AI Summarize Note')
            .attr('data-textarea-id', textarea.id);
        $button.on('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            const textareaEl = document.getElementById($(this).data('textarea-id'));
            if (!textareaEl) return;
            const noteContent = textareaEl.value.trim();
            if (!noteContent) {
                alert("Textarea is empty. Please enter some text.");
                return;
            }
            if ($(this).hasClass('loading')) return;
            $(this).addClass('loading').html('');
            const $triggerBtn = $(this);
            openModal('ai', { element: textareaEl });
            $('#ai-processing-indicator').show();
            $('#ai-summary-panel').html('<i>Generating response, please wait...</i>');
            const prompt = `
ENCOUNTER NOTE:
\`\`\`
${noteContent}
\`\`\`

CLINICAL SUMMARY GUIDELINES:
Extract key clinical info, use clear language, prioritize actionable insights.

Subjective:
- Concise patient-reported concerns
- Key symptoms
- Visit purpose

Objective:
- Vital signs
- Medications
- Physical exam findings
- Test results

Assessment:
- Primary diagnoses
- Clinical reasoning
- Key considerations

Plan:
- Treatment
- Prescriptions
- Follow-up
- Pending tests

Critical Insights:
- Key clinical considerations
- Care optimization points
- Urgent follow-up needs

Use bullet points, avoid redundancy, focus on relevance.
`;
            callOpenRouterAPI(prompt, AI_API_KEY)
                .then(function(result) {
                    currentAiResponse.originalNote = noteContent;
                    const parsed = parseAIResponse(result.text);
                    updateAiOverlayContent(parsed, result.modelIndexUsed);
                    switchToTab('ai');
                })
                .catch(function(error) {
                    displayAiError(error.message);
                })
                .finally(function() {
                    $triggerBtn.removeClass('loading').html('⚕️');
                    $('#ai-processing-indicator').hide();
                });
        });
        $container.append($button);
        addLog(`[AI] Added button to textarea ${textarea.id}`);
    }
    function parseAIResponse(fullResponse) {
        const sections = {
            coreSummary: "",
            insights: "",
            fullText: fullResponse
        };
        try {
            const soapMatch = fullResponse.match(/\*\*Subjective:[\s\S]*?\*\*Plan:/i);
            if (soapMatch) {
                sections.coreSummary = soapMatch[0] + fullResponse.split(/\*\*Plan:/i)[1].split(/\*\*(Insights|Critical|Contextual)/i)[0].trim();
                const insightsMatch = fullResponse.match(/\*\*(Insights|Critical Insights|Clinical Insights):[\s\S]*$/i);
                if (insightsMatch) {
                    sections.insights = insightsMatch[0].trim();
                } else {
                    sections.insights = "No insights section found.";
                }
            } else {
                sections.coreSummary = fullResponse;
                sections.insights = "No separate sections found.";
            }
        } catch (e) {
            console.error("Error parsing AI response:", e);
            sections.coreSummary = "Error parsing response.";
            sections.insights = "Error parsing response.";
        }
        return sections;
    }
    function updateAiOverlayContent(parsedResponse, modelIndexUsed) {
        currentAiResponse.fullText = parsedResponse.fullText;
        currentAiResponse.coreSummary = parsedResponse.coreSummary;
        currentAiResponse.insights = parsedResponse.insights;
        if (typeof modelIndexUsed === 'number' && modelIndexUsed >= 0) {
            currentAiResponse.modelIndex = modelIndexUsed;
            $('#ai-model-select').val(modelIndexUsed);
        }
        $('#ai-summary-panel').text(parsedResponse.coreSummary);
        $('#ai-insights-panel').text(parsedResponse.insights);
        $('#ai-full-panel').text(parsedResponse.fullText);
        const parseFailed = parsedResponse.coreSummary.startsWith("Parsing Error:") ||
                           parsedResponse.insights.startsWith("Parsing Error:");
        $('.ai-tab-button[data-tab-target="insights"]').prop('disabled', parseFailed)
            .css('opacity', parseFailed ? 0.6 : 1)
            .attr('title', parseFailed ? "Response parsing failed" : "");
        $('.ai-tab-button[data-tab-target="comparison"]').hide().removeClass('active');
        $('#ai-comparison-panel').hide().removeClass('active');
        $('.ai-tab-button').removeClass('active');
        $('.ai-tab-button[data-tab-target="summary"]').addClass('active');
        $('.ai-tab-panel').removeClass('active').hide();
        $('#ai-summary-panel').addClass('active').show();
        $('#ai-insert-btn, #ai-refine-btn, #ai-regenerate-btn').prop('disabled', false);
        addLog("[AI] Overlay content updated.");
    }
    function displayAiError(message) {
        $('#ai-error-display').text(`Error: ${message}`).show();
        $('#ai-summary-panel').html(`<i>Error generating response. See message above.</i>`);
        $('#ai-insert-btn, #ai-refine-btn, #ai-regenerate-btn').prop('disabled', true);
        $('#ai-processing-indicator').hide();
        addLog(`[AI Error] ${message}`);
    }
    function callOpenRouterAPI(prompt, apiKey, modelIndex = 0) {
        return new Promise((resolve, reject) => {
            if (!apiKey || apiKey === "YOUR_OPENROUTER_API_KEY_HERE") {
                reject(new Error("API Key not set. Go to Settings tab to add your OpenRouter API key."));
                return;
            }
            if (modelIndex >= AI_MODELS.length) {
                reject(new Error("Model index out of bounds."));
                return;
            }
            const currentModel = AI_MODELS[modelIndex];
            addLog(`[AI] Using model: ${currentModel}`);
            const payload = {
                model: currentModel,
                messages: [{ role: "user", content: prompt }]
            };
            const headers = {
                "Authorization": `Bearer ${apiKey}`,
                "Content-Type": "application/json",
                "HTTP-Referer": window.location.hostname
            };
            GM_xmlhttpRequest({
                method: "POST",
                url: OPENROUTER_API_URL,
                headers: headers,
                data: JSON.stringify(payload),
                responseType: "json",
                timeout: 120000,
                onload: function(response) {
                    if (response.status >= 200 && response.status < 300) {
                        try {
                            const data = response.response;
                            const content = data?.choices?.[0]?.message?.content || "";
                            if (content) {
                                resolve({
                                    text: content.trim(),
                                    modelUsed: currentModel,
                                    modelIndexUsed: modelIndex
                                });
                            } else {
                                reject(new Error("Empty content in response"));
                            }
                        } catch (e) {
                            reject(new Error("Failed to parse API response: " + e.message));
                        }
                    } else {
                        reject(new Error(`API request failed with status ${response.status}: ${response.statusText || "Unknown error"}`));
                    }
                },
                onerror: function(error) {
                    reject(new Error("Network error: " + (error.statusText || "Unknown")));
                },
                ontimeout: function() {
                    reject(new Error("Request timed out after 120 seconds"));
                }
            });
        });
    }

    // --- Global Key Listener ---
    function addGlobalKeyListener() {
        $(document).on('keydown', function(e) {
            if (e.key === '`' && !$(e.target).is('input, textarea, select')) {
                e.preventDefault();
                if (isModalOpen) {
                    closeModal();
                } else {
                    openModal();
                }
            }
            else if (e.key === 'Escape' && isModalOpen) {
                closeModal();
            }
        });
        addLog("[Init] Global key listener added for backtick (`) and Escape keys.");
    }

    // --- Encounter Page Logic ---
    function injectEncounterPageElements() {
        if (!isEncounterPage) return;
        addLog("[UI] Encounter page detected, setting up elements...");
        try {
            $(AI_TEXTAREA_SELECTOR).each(function() {
                addAiTriggerButton(this);
            });
            initTemplateToolbar();
            const urlParams = new URLSearchParams(window.location.search);
            const appointmentNo = urlParams.get('appointmentNo');
            if (appointmentNo) {
                const $saveImg = $('#saveImg, input[type="image"][src*="save"], button:contains("Save")').first();
                if ($saveImg.length && !$('#save-bill-btn').length) {
                    const $billBtn = $(`<button id="save-bill-btn" style="margin-right:8px; padding:4px 8px; font-size:13px; background-color:${mainColor}; color:white; border:none; border-radius:4px; cursor:pointer;">Bill</button>`);
                    const existingBill = getBillingData(appointmentNo);
                    if (existingBill && existingBill.serviceCode && existingBill.dxString) {
                        $billBtn.text('Modify Bill').css('background-color', '#28a745');
                    }
                    $billBtn.on('click', function(e) {
                        e.preventDefault();
                        openModal('billing', {appointmentNo, element: this});
                    });
                    $saveImg.before($billBtn);
                    addLog(`[UI] Added billing button for appointment #${appointmentNo}`);
                }
            }
        } catch (e) {
            addLog(`[UI] Error initializing encounter page elements: ${e.message}`);
        }
        const observer = new MutationObserver(mutations => {
            mutations.forEach(mutation => {
                if (mutation.type === 'childList') {
                    mutation.addedNodes.forEach(node => {
                        if (node.nodeType === Node.ELEMENT_NODE) {
                            if (node.matches && node.matches(AI_TEXTAREA_SELECTOR)) {
                                addAiTriggerButton(node);
                            }
                            if (node.querySelectorAll) {
                                $(node).find(AI_TEXTAREA_SELECTOR).each(function() {
                                    addAiTriggerButton(this);
                                });
                            }
                        }
                    });
                }
            });
        });
        const targetNode = document.querySelector('form[name="caseManagementEntryForm"], form[name="encounterFormForm"]') || document.body;
        observer.observe(targetNode, { childList: true, subtree: true });
        addLog(`[UI] Observer set up for new textareas on ${targetNode.nodeName}.`);
    }

// ============================================================
// BLOCK 1: REPLACE initialize FUNCTION
// ============================================================
function initialize($) {
    // Increased delay slightly to ensure page elements (especially on complex pages like Oscar's) are more likely settled
    setTimeout(async function() {
        let initStage = "Starting";
        try {
            // --- Common Setup ---
            initStage = "Loading Log";
            loadLogFromStorage(); // Load log history first
            const currentUrl = window.location.href; // Get URL early
            addLog(`CliniStream v${GM_info.script.version} initializing on ${currentUrl}`);

            initStage = "Adding Styles";
            addExtraStyles(); // Apply CSS early - CRITICAL for UI visibility

            initStage = "Loading AI Models";
            loadAIModels();   // Load AI model preferences

            // --- Page Specific Routing ---
            initStage = "Routing Page Type";
            if (currentUrl.includes("id.gov.bc.ca/login/entry")) {
                // --- BC Services Card Login Page ---
                addLog("[Init] Detected BC Services Card Login Page");
                initStage = "Handling BC Services Login Page";
                await handleCareConnectPage(); // Handles the auth wait logic
                addLog("[Init] BC Services Card Login handler finished.");
            }
            else if (currentUrl.includes("health.careconnect.ca")) {
                // --- CareConnect Page ---
                addLog("[Init] Detected CareConnect Page");
                initStage = "Handling CareConnect Page";
                await handleCareConnectPage(); // Handles search, accept, scrape, loop
                addLog("[Init] CareConnect handler finished.");
            }
            else {
                // --- Oscar EMR Pages ---
                initStage = "Getting Oscar Page Type";
                const currentPageType = getPageType(); // Determine Oscar page type
                addLog(`[Init] Detected Oscar Page Type: ${currentPageType}`);

                // Handle special Oscar states first (Chart Linking, Batch Billing)
                initStage = `Checking Special States (${currentPageType})`;
                if (currentPageType === 'APPOINTMENT_EDIT' && isChartLinkingActive()) {
                    addLog("[Init] Oscar: Handling active chart linking on edit page.");
                    initStage = "Handling Chart Linking";
                    handleApptEditPage();
                }
                else if (currentPageType === 'BILLING_STEP_1' && isBatchValid()) {
                     addLog("[Init] Oscar: Handling active batch billing on step 1 page.");
                     initStage = "Handling Batch Billing Step 1";
                    childAutoFillThenContinue();
                }
                else if (currentPageType === 'BILLING_STEP_2' && isBatchValid()) {
                     addLog("[Init] Oscar: Handling active batch billing on step 2 page.");
                     initStage = "Handling Batch Billing Step 2";
                    childAutoClickFinalSubmit();
                }
                else {
                    // --- Standard Oscar Page Initialization ---
                    addLog(`[Init] Oscar: Standard initialization for ${currentPageType}.`);

                    initStage = "Loading DX Data";
                    await loadDxData(); // Load diagnoses needed for billing UI

                    initStage = "Adding Global Key Listener";
                    addGlobalKeyListener(); // Add global keys (` ` and Esc)

                    initStage = "Injecting Modal & Styles";
                    injectModalAndStyles(); // Inject modal structure and standard listeners **FIRST**

                    // Page-specific UI injections and logic
                    initStage = `Oscar Page Specific Init (${currentPageType})`;
                    if (currentPageType === 'APPOINTMENT_SCHEDULE') {
                        addLog("[Init] Oscar: Initializing Appointment Schedule page specifics...");

                        initStage = "Injecting Appt Page Buttons";
                        injectAppointmentPageButtons(); // Add floating button, bill buttons **SECOND**

                        initStage = "Setting up PharmaNet Button";
                        setupPharmaNetButton(); // Setup the new PharmaNet button listener *after* modal and button exist

                        initStage = "Updating PharmaNet Button State";
                        updatePharmaNetButtonState(); // Reflect current PharmaNet state on load

                        // Auto-scan logic
                        initStage = "Checking Auto-Scan";
                        const lastScanTimestamp = GM_getValue("lastScanTimestamp", 0);
                        const hoursSinceLastScan = (Date.now() - lastScanTimestamp) / (1000 * 60 * 60);
                        if (hoursSinceLastScan > AUTO_SCAN_INTERVAL_HOURS) {
                            addLog(`[Init] Auto-scan triggered (last scan ${hoursSinceLastScan.toFixed(1)} hours ago).`);
                            setTimeout(scanAppointments, 2500);
                        } else {
                             addLog(`[Init] Skipping auto-scan (last scan ${hoursSinceLastScan.toFixed(1)} hours ago).`);
                        }
                        // Batch resume visual update
                        initStage = "Checking Batch Resume";
                        if (isBatchValid()) {
                             addLog("[Init] Oscar: Detected active batch billing session (visual update).");
                             setTimeout(() => {
                                const queue = parseBatchQueue(getBatchQueueStr());
                                const index = getBatchIndex();
                                if ($('#batch-bill-btn').length) { // Ensure button exists
                                    setButtonState($('#batch-bill-btn'), `Billing (${index}/${queue.length})`, "#f39c12", true);
                                }
                             }, 2000);
                        }

                    } else if (currentPageType === 'ENCOUNTER_NOTE' || currentPageType === 'ENCOUNTER_GENERAL') {
                        addLog("[Init] Oscar: Initializing Encounter page specifics...");
                        initStage = "Injecting Encounter Elements";
                        injectEncounterPageElements(); // Add AI buttons, template toolbar, etc.
                    }
                    // Add other Oscar page initializations if needed
                }
            }
            addLog("[Init] Initialization sequence complete.");
        } catch (e) {
             console.error(`CliniStream Initialization error during stage [${initStage}]:`, e);
             addLog(`[Init CRITICAL ERROR @ ${initStage}] ${e.message} ${e.stack}`); // Add stack trace for better debugging
        }
    }, 2500); // Slightly longer delay just in case
}
// ============================================================
// END BLOCK 1
// ============================================================
})();