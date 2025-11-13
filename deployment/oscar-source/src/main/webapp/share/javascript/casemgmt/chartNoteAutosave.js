/*
Copyright (c) 2014-2015. KAI Innovations Inc. All Rights Reserved.
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
*/

class ChartNoteAutosave {
    constructor(formId, demographicId, noteProgramId, noteId, autosaveInterval, saveEndpointContext, saveSuccessCallback, promptSaveOnClose = false) {
        let formElement = document.getElementById(formId);
        if (!formElement) {
            console.error(`FormsTimedAutosave: formElement \'${formId}\' does not exist`)
        }
        
        this.formElement = formElement;
        this.demographicId = demographicId;
        this.noteProgramId = noteProgramId;
        this.noteId = noteId;
        this.autosaveInterval = autosaveInterval;
        this.idleTime = 0;
        this.changed = false;
        this.saveEndpointContext = saveEndpointContext;
        //this.csrfToken = csrfToken;
        this.saveSuccessCallback = saveSuccessCallback;
        this.lastsavedDateString = "";

        // bind events
        let boundTimerIncrement = this.timerIncrement.bind(this);
        this.idleInterval = setInterval(boundTimerIncrement, 1000);
        let boundFormChangedEvent = this.formChangedEvent.bind(this);
        this.formElement.addEventListener('change', boundFormChangedEvent);
        this.formElement.addEventListener('keydown', boundFormChangedEvent);

        if (promptSaveOnClose) {
            let boundPromptSaveBeforeClose = this.promptSaveBeforeClose.bind(this);
            window.addEventListener('beforeunload', boundPromptSaveBeforeClose);
        }

        // Zero the idle timer on change
        this.formElement.addEventListener('dataChanged', () => {
            console.log('changed');
            this.idleTime = 0;
        });
    }

    timerIncrement() {
        if (this.changed) {
            this.idleTime += 1;
        }
        if (this.idleTime >= this.autosaveInterval && this.changed) {
            this.saveNote();
            this.idleTime = 0;
        }
    }

    saveNote() {
        if (this.validateNoteInfo()) {
            this.sendRequest();
        } else {
            let lastSavedText = this.lastsavedDateString ? ' Last autosaved at ' + this.lastsavedDateString : "";
        }
    }

    promptSaveBeforeClose(event) {
        if (this.changed) {
            event.preventDefault();
            event.returnValue = true; // any non-null return value causes browser to prompt user
        }
    }

    sendRequest() {
        const httpRequest = new XMLHttpRequest();
        const formData = new FormData();
        formData.append('method', 'autosave');
        formData.append('demographicNo', this.demographicId);
        formData.append('programId', this.noteProgramId);
        formData.append('note_id', this.noteId);
        formData.append('note', this.formElement.value);
        //formData.append(this.csrfToken['name'], this.csrfToken['value']);

        // bind events
        let onSendRequestSuccessEvent = this.onSendRequestSuccess.bind(this);
        httpRequest.addEventListener('load', onSendRequestSuccessEvent);
        let onSendRequestErrorEvent = this.onSendRequestError.bind(this);
        httpRequest.addEventListener('error', onSendRequestErrorEvent);

        httpRequest.open('POST', `${this.saveEndpointContext}/CaseManagementEntry.do`);
        //httpRequest.setRequestHeader(this.csrfToken['name'], this.csrfToken['value']);
        httpRequest.send(formData);
    }

    formChangedEvent(event) {
        this.changed = true;
    }

    onSendRequestSuccess(event) {
        if ('true' === event.target.getResponseHeader('success')) {
            this.saveSuccessCallback();
        }
        this.changed = false;
    }
    onSendRequestError(event) {
        console.log(event);
        this.changed = false;
    }

    setChanged() {
        this.changed = true;
    }
    setChangedFalse() {
        this.changed = false;
    }

    validateNoteInfo() {
        return true;
    }
}