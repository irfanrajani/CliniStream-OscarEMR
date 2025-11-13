<%--


    Copyright (c) 2005-2012. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved.
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

    This software was written for
    Centre for Research on Inner City Health, St. Michael's Hospital,
    Toronto, Ontario, Canada

--%>
<%@page contentType="text/javascript"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"	scope="request" />



Messenger.options = {
		delay: 10,
		extraClasses: 'messenger-fixed messenger-on-top messenger-on-left',
		theme: 'future'
};

// global message
var msg;

/*
 * Handles eAAPs notification dismissal
 * 
 * @param notificationId ID of the notification to be dismissed
 * 
 */
function dismissHandler(notificationId) {
	jQuery.ajax({
		type : "POST",
		url : "<c:out value="${ctx}"/>/notification/create.do",
		data : {id: notificationId, type: "eaaps"},
		/*
		 * success : function(response) { msg.update({ message: "Notification
		 * will not be displayed again.", type: "success", actions: false }); },
		 */
		error: function(response) {
			msg.update({
				message: "We are sorry, there was an error saving your preference",
				type: "error",
				actions: false
			})
		}
	});
	return msg.hide();
}

/*
 * Handles messenger display
 * 
 * @param url URL of the notification popup
 * @param notificationId Id of the notification
 * @param message Additional message information
 */
function showMessenger(url, notificationId, message) {
	var messageContent = "";
	// in case URL is specified - make sure it's clickable
	if (url) {
		messageContent = "<a href='javascript:void();' style='color: white' onclick='window.open(\"" + url + "\",\"eaaps\",\"height=700,width=1000,left=10,top=10,resizable=yes,scrollbars=yes,toolbar=yes,menubar=no,location=no,directories=no,status=yes\");return false;'  >"+message+"</a>";
	} else { // otherwise - just show the message provided
		messageContent = message;
	}

	msg = Messenger().post({
		id: url,
		singleton: true,
		type: 'info',
		message: messageContent,
		actions: {
			snooze: {
				label: 'Snooze',
				action: function() {
					return msg.update({
						message: "This message will display next time this eChart is open",
						type: "success",
						actions: false
					});
				}
			}
		}
	});
}

/*
 * Main entry point into the messenger functionality. This function is called from the eAAP eChart
 * window.
 * 
 * @param url URL of the notification popup
 * @param notificationId Id of the notification 
 * @param message additional message information to be displayed in the popup
 */
function displayEaapsWindow(url, notificationId, message) {
	// make sure we give a chance for eChart to load
	setTimeout(
		function() {
			showMessenger(url, notificationId, message);	
		}, 500
	);
}

//////Timer
        var d = new Date();  //the start

        var totalSeconds = 0;
        var myVar = setInterval(setTime, 1000);
	var toggle = true;

	function toggleATimer(){
 	    if (toggle) {
			document.getElementById("toggleTimer").innerHTML="&gt;";
			clearInterval(myVar);
			toggle=false;
		} else {
			document.getElementById("toggleTimer").innerHTML="&#8741;";
			myVar = setInterval(setTime, 1000);
			toggle=true;
		}
	}
	
	function pasteTimer(){
            var ed = new Date();
            $(caseNote).value +="\n"+document.getElementById("startTag").value+": "+d.getHours()+":"+pad(d.getMinutes())+"\n"+document.getElementById("endTag").value+": "+ed.getHours()+":"+pad(ed.getMinutes())+"\n"+pad(parseInt(totalSeconds/3600))+":"+pad(parseInt((totalSeconds/60)%60))+":"+ pad(totalSeconds%60);
            adjustCaseNote();
	}

        function setTime(){
            ++totalSeconds;
            if (totalSeconds > 5) {document.getElementById("aTimer").innerHTML =pad(parseInt(totalSeconds/60))+":"+ pad(totalSeconds%60);}
            if (totalSeconds == 1200) {document.getElementById("aTimer").style.backgroundColor= "#DFF0D8";} //1200 sec = 20 min light green
            if (totalSeconds == 3000) {document.getElementById("aTimer").style.backgroundColor= "#FDFEC7";} //3600 sec = 50 min light yellow
        }

        function pad(val){
            var valString = val + "";
            if(valString.length < 2)
            {
                return "0" + valString;
            } else {
                return valString;
            }
        }



// add Markdown functions for caseNote editing

    function repeat(string, count) {
        var result = '';
        for (var i = 0; i < count; i++) {
            result += string;
        }
        return result;
    };

    function addTab() {
        var textarea = $(caseNote);
        var start = textarea.value.substr(0, textarea.selectionStart);
        var end = textarea.value.substr(textarea.selectionStart);
        var tab = "\t";
        textarea.value = "" + start + tab + end;
        textarea.selectionStart = start.length + tab.length;
        textarea.selectionEnd = textarea.selectionStart;
        textarea.focus();
    };
    function shiftTab() {
        var textarea = $(caseNote);
        var _a;
        var start = textarea.value.substr(0, textarea.selectionStart);
        var end = textarea.value.substr(textarea.selectionStart);
        if (start[start.length - 1] == '\t') {
            start = (_a = start.substr(0, start.length - 1)) !== null && _a !== void 0 ? _a : '';
        }
        else if (end[0] == '\t') {
            end = end.substr(1);
        }
        textarea.value = "" + start + end;
        textarea.selectionStart = start.length;
        textarea.selectionEnd = textarea.selectionStart;
        textarea.focus();
    };

    function addBold() {
	    var textarea = $(caseNote);
        var start = textarea.value.substr(0, textarea.selectionStart);
        var end = textarea.value.substr(textarea.selectionStart);
        var bold = "****";
        var offset = bold.length - 2;
        if (textarea.selectionStart != textarea.selectionEnd) {
            end = textarea.value.substr(textarea.selectionEnd);
            var range = textarea.value.slice(textarea.selectionStart, textarea.selectionEnd);
            bold = "**" + range + "**";
            offset = 2;
        }
        if (start.length && start[start.length - 1] != '\n' && start[start.length - 1] != ' ') {
            bold = " " + bold;
        }
        if (end.length && end[0] != '\n' && end[0] != ' ') {
            bold = bold + " ";
            offset += 1;
        }
        textarea.value = "" + start + bold + end;
        textarea.selectionStart = start.length + bold.length - offset;
        textarea.selectionEnd = textarea.selectionStart;
        textarea.focus();

    }

    function addItalic() {
	    var textarea = $(caseNote);
        var start = textarea.value.substr(0, textarea.selectionStart);
        var end = textarea.value.substr(textarea.selectionStart);
        var bold = "**";
        var offset = bold.length - 1;
        if (textarea.selectionStart != textarea.selectionEnd) {
            end = textarea.value.substr(textarea.selectionEnd);
            var range = textarea.value.slice(textarea.selectionStart, textarea.selectionEnd);
            bold = "*" + range + "*";
            offset = 1;
        }
        if (start.length && start[start.length - 1] != '\n' && start[start.length - 1] != ' ') {
            bold = " " + bold;
        }
        if (end.length && end[0] != '\n' && end[0] != ' ') {
            bold = bold + " ";
            offset += 1;
        }
        textarea.value = "" + start + bold + end;
        textarea.selectionStart = start.length + bold.length - offset;
        textarea.selectionEnd = textarea.selectionStart;
        textarea.focus();
    };

	
	 function addLink(type) {
	    var textarea = $(caseNote);
        if (type === void 0) { type = 0; }
        var start = textarea.value.substr(0, textarea.selectionStart);
        var end = textarea.value.substr(textarea.selectionStart);
        var link = '';
        var offset = 0;
        if (type === 0) {
            link = '[](http://)';
            offset = link.length - 1;
            if (textarea.selectionStart != textarea.selectionEnd) {
                end = textarea.value.substr(textarea.selectionEnd);
                var range = textarea.value.slice(textarea.selectionStart, textarea.selectionEnd);
                var rangeIsURL = range.match(/https?:\/\/(.+)/);
                link = rangeIsURL ? "[](" + range.trim() + ")" : "[" + range.trim() + "](http://)";
                offset = rangeIsURL ? range.trim().length + 3 : 1;
            }
        }
        else {
            link = '<>';
            offset = link.length - 1;
            if (textarea.selectionStart != textarea.selectionEnd) {
                end = textarea.value.substr(textarea.selectionEnd);
                var range = textarea.value.slice(textarea.selectionStart, textarea.selectionEnd);
                link = "<" + range + ">";
                offset = 1;
            }
        }
        if (start.length && start[start.length - 1] != '\n' && start[start.length - 1] != ' ') {
            link = " " + link;
        }
        if (end.length && end[0] != '\n' && end[0] != ' ') {
            link = link + " ";
            offset += 1;
        }
        textarea.value = "" + start + link + end;
        textarea.selectionStart = start.length + link.length - offset;
        textarea.selectionEnd = textarea.selectionStart;
        textarea.focus();
    };

    function addHeading (level) {
	    var textarea = $(caseNote);
        if (level === void 0) { level = 1; }
        var start = textarea.value.substr(0, textarea.selectionStart);
        var end = textarea.value.substr(textarea.selectionStart);
        var heading = repeat('#', level) + " ";
        var offset = 0;
        if (textarea.selectionStart != textarea.selectionEnd) {
            end = textarea.value.substr(textarea.selectionEnd);
            var range = textarea.value.slice(textarea.selectionStart, textarea.selectionEnd);
            heading = "" + heading + range.trim();
            offset = 0;
        }
        if (start.length && start[start.length - 1] != '\n') {
            heading = "\n" + heading;
        }
        if (end.length && end[0] != '\n') {
            heading = heading + "\n";
            offset = 1;
        }
        textarea.value = "" + start + heading + end;
        textarea.selectionStart = start.length + heading.length - offset;
        textarea.selectionEnd = textarea.selectionStart;
        textarea.focus();
    };

    var handlerOn = 0;
    function addHandler() {
        if (handlerOn == 1) { return;}
        var textarea = $(caseNote);
        textarea.addEventListener('keydown', function (e) {
            if (e.key.toLowerCase() === 'enter' && onListing !== null) {
                e.preventDefault();
                var start = textarea.value.substr(0, textarea.selectionStart);
                var end = textarea.value.substr(textarea.selectionStart);
                var splittedStart = start.split(/\n/g);
                var list = '';
                var pattern = onListing.type === 'unordered' ? /-\s?/ : /\d+\.\s?/;
                if (splittedStart.length) {
                    var match = splittedStart[splittedStart.length - 1].trim().match(pattern);
                    if (match && match[0] === match.input) {
                        splittedStart.pop();
                        textarea.value = splittedStart.join('\n') + "\n" + end;
                        textarea.selectionStart = splittedStart.join('\n').length + '\n'.length;
                        textarea.selectionEnd = textarea.selectionStart;
                        return onListing = null;
                    }
                }
                if (onListing.type === 'unordered') {
                    list = "\n- ";
                }
                if (onListing.type === 'ordered') {
                    list = "\n" + onListing.number + ". ";
                    onListing.number++;
                }
                textarea.value = "" + start + list + end;
                textarea.selectionStart = start.length + list.length;
                textarea.selectionEnd = textarea.selectionStart;
                textarea.focus();
            }
            if (e.key.toLowerCase() === 'tab') {
                e.preventDefault();
                if (e.shiftKey) {
                    self.shiftTab(self);
                }
                else {
                    self.addTab(self);
                }
            }
        });
        handlerOn = 1;

    }
    function addUnorderedList() {
        var textarea = $(caseNote);
        var start = textarea.value.substr(0, textarea.selectionStart);
        var end = textarea.value.substr(textarea.selectionStart);
        var list = "- ";
        var offset = 0;
        if (textarea.selectionStart != textarea.selectionEnd) {
            end = textarea.value.substr(textarea.selectionEnd);
            var range = textarea.value.slice(textarea.selectionStart, textarea.selectionEnd);
            list = "" + list + range.trim();
        }
        if (start.length && start[start.length - 1] != '\n') {
            list = "\n" + list;
        }
        if (end.length && end[0] != '\n') {
            list = list + "\n";
            offset = 1;
        }
        textarea.value = "" + start + list + end;
        textarea.selectionStart = start.length + list.length - offset;
        textarea.selectionEnd = textarea.selectionStart;
        textarea.focus();
        onListing = {
            type: 'unordered'
        };
    };
    function addOrderedList() {
        var textarea = $(caseNote);
        var start = textarea.value.substr(0, textarea.selectionStart);
        var end = textarea.value.substr(textarea.selectionStart);
        var list = "1. ";
        var offset = 0;
        if (textarea.selectionStart != textarea.selectionEnd) {
            end = textarea.value.substr(textarea.selectionEnd);
            var range = textarea.value.slice(textarea.selectionStart, textarea.selectionEnd);
            list = "" + list + range.trim();
        }
        if (start.length && start[start.length - 1] != '\n') {
            list = "\n" + list;
        }
        if (end.length && end[0] != '\n') {
            list = list + "\n";
            offset = 1;
        }
        textarea.value = "" + start + list + end;
        textarea.selectionStart = start.length + list.length - offset;
        textarea.selectionEnd = textarea.selectionStart;
        textarea.focus();
        onListing = {
            type: 'ordered',
            number: 2,
        };
    };

// Smart Template code
var smartTmplVM = {
    STATE: {
        TRAVERSING: "TRAVERSING",
        SELECTED_PLACEHOLDER_TEXT: "SELECTED_PLACEHOLDER_TEXT",
        SELECTED_OPTION_TEXT: "SELECTED_OPTION_TEXT"
    },
    TMPL_DELIM_START: '<',
    TMPL_DELIM_END: '>',
    TMPL_DELIM_CHOICE: '|',
    TMPL_PLACEHOLDER_CHAR: '?'
}
// «»
var smartTmpl = (function () {
    function init(el) {
        if (!el) {
            return;
        }

        el.addEventListener('click', function (event) {
            var value = event.target.value;
            if (!value) {
                return;
            }

            var selection = getTextSelection(event.target);

            var sectionStart = selection.start || 0;
            var i = sectionStart;
            var sectionStartFound = false;
            for (i = sectionStart; i > 0; --i) {
                if (value[i - 1] === smartTmplVM.TMPL_DELIM_END) {
                    return;
                }
                if (value[i - 1] === smartTmplVM.TMPL_DELIM_START) {
                    sectionStart = i - 1;
                    sectionStartFound = true;
                    break;
                }
            }
            if (!sectionStartFound) {
                return;
            }

            var sectionEnd = sectionStart;
            for (i = sectionStart; i < value.length; ++i) {
                if (value[i + 1] === smartTmplVM.TMPL_DELIM_START) {
                    return;
                }
                if (value[i + 1] === smartTmplVM.TMPL_DELIM_END) {
                    sectionEnd = i + 2;
                    break;
                }
            }

            var section = value.substring(sectionStart, sectionEnd);
            if (!section || section && !section.length) {
                return;
            }

            var choiceStart = selection.start;
            for (i = selection.start; i >= sectionStart; --i) {
                if (value[i - 1] ===  smartTmplVM.TMPL_DELIM_START || value[i - 1] === smartTmplVM.TMPL_DELIM_CHOICE) {
                    choiceStart = i;
                    break;
                }
            }

            var choiceEnd = choiceStart;
            for (i = choiceEnd; i <= sectionEnd; i++) {
                if (value[i + 1] === smartTmplVM.TMPL_DELIM_END || value[i + 1] === smartTmplVM.TMPL_DELIM_CHOICE) {
                    choiceEnd = i;
                    break;
                }
            }

            var choice = value.substring(choiceStart, choiceEnd + 1)
            if (!choice || choice && !choice.length) {
                return;
            }

            event.target.value = value.substring(0, sectionStart) + choice + value.substring(sectionEnd, value.length);
        });

        el.onkeydown = (event) => {
            const value = event.target.value;

            // Proceed if "tab" or "enter" key is pressed
            if (event.keyCode === 9 || event.keyCode === 13 ) {
                let selectionStart = el.selectionStart;
                let selectionEnd = el.selectionEnd;
                if ( selectionEnd == selectionStart && event.keyCode === 13) { return; }
                const highlighted = value
                    .substring(selectionStart, selectionEnd)
                    .trim();

               // Check if a keyword is already highlighted
                if (isHighlighting(el) && event.keyCode === 13) {
                    // Check if highlighted a placeholder char or option text
                    if (highlighted === smartTmplVM.TMPL_PLACEHOLDER_CHAR) {
                        state = smartTmplVM.STATE.SELECTED_PLACEHOLDER_TEXT;
                    } else {
                        state = smartTmplVM.STATE.SELECTED_OPTION_TEXT;
                    }
                } else {
                    state = smartTmplVM.STATE.TRAVERSING;
                }

                switch (state) {
                    case smartTmplVM.STATE.TRAVERSING: {
                        // Find first index of placeholder char
                        const placeholderCharIndex = findPlaceholderCharIndex(selectionEnd,value);

                        // Find first index of option text
                        const selectionTextIndex = findSelectionTextIndex(selectionEnd,value);

						if (
							placeholderCharIndex == -1 &&
							selectionTextIndex.startIndex == -1 &&
							selectionTextIndex.endIndex == -1
							) {
								// nothing found, so wrap to the top and check again
								el.setSelectionRange(1,1);
								const placeholderCharIndex = findPlaceholderCharIndex(0,value);
								const selectionTextIndex = findSelectionTextIndex(0,value);
							}
                        // Highlight the next occurrence
                        if (
                            selectionTextIndex.startIndex !== -1 &&
                            selectionTextIndex.endIndex !== -1
                        ) {
                            if (
                                selectionTextIndex.startIndex < placeholderCharIndex ||
                                placeholderCharIndex === -1
                            ) {
                                el.setSelectionRange(
                                    selectionTextIndex.startIndex,
                                    selectionTextIndex.endIndex
                                );
                                state = smartTmplVM.STATE.SELECTED_OPTION_TEXT;
                            } else {
                                el.setSelectionRange(
                                    placeholderCharIndex,
                                    placeholderCharIndex +
                                    smartTmplVM.TMPL_PLACEHOLDER_CHAR.length
                                );
                                state = smartTmplVM.STATE.SELECTED_PLACEHOLDER_TEXT;
                            }
                        } else if (placeholderCharIndex !== -1) {
                            el.setSelectionRange(
                                placeholderCharIndex,
                                placeholderCharIndex + smartTmplVM.TMPL_PLACEHOLDER_CHAR.length
                            );
                            state = smartTmplVM.STATE.SELECTED_PLACEHOLDER_TEXT;
                        }
						// scroll to selection
						el.blur();
						el.focus();
                        break;
                    }

                    case smartTmplVM.STATE.SELECTED_PLACEHOLDER_TEXT: {
                        // Replace highlighted placeholder text
                        if (highlighted === smartTmplVM.TMPL_PLACEHOLDER_CHAR) {
                            const updatedValue =
                                value.substring(0, selectionStart) +
                                "" +
                                value.substring(selectionEnd, value.length);
                            event.target.value = updatedValue;
							if (value.length == selectionEnd) { selectionEnd = 0; } //ensure the end of value end case doesn't break
                            el.setSelectionRange(selectionEnd+1, selectionEnd+1);  
                        }

                        break;
                    }

                    case smartTmplVM.STATE.SELECTED_OPTION_TEXT: {
                        // Replace entire selection options with the highlighted option text
                        selectionStart--;

                        selectionEnd = value
                            .substring(selectionStart, value.length)
                            .indexOf(smartTmplVM.TMPL_DELIM_END);
                        if (selectionEnd !== -1) {
                            selectionEnd += selectionStart + 1;
							selectionStart = value.lastIndexOf(smartTmplVM.TMPL_DELIM_START,selectionEnd);

                            const updatedValue =
                                value.substring(0, selectionStart) +
                                highlighted +
                                value.substring(selectionEnd, value.length);
                            event.target.value = updatedValue;
                            el.setSelectionRange(selectionStart, selectionStart);
                        }

                        break;
                    }

                    default: {
                        break;
                    }
                }

                event.preventDefault();
                event.stopPropagation();
            } else {
                state = smartTmplVM.STATE.TRAVERSING;
            }
        }
    }

    // Return selected text
    function getTextSelection(el) {
        var start = 0, end = 0, normalizedValue, range,
            textInputRange, len, endRange;

        if (typeof el.selectionStart == "number" && typeof el.selectionEnd == "number") {
            start = el.selectionStart;
            end = el.selectionEnd;
        } else {
            range = document.selection.createRange();

            if (range && range.parentElement() == el) {
                len = el.value.length;
                normalizedValue = el.value.replace(/\r\n/g, "\n");

                textInputRange = el.createTextRange();
                textInputRange.moveToBookmark(range.getBookmark());

                endRange = el.createTextRange();
                endRange.collapse(false);

                if (textInputRange.compareEndPoints("StartToEnd", endRange) > -1) {
                    start = end = len;
                } else {
                    start = -textInputRange.moveStart("character", -len);
                    start += normalizedValue.slice(0, start).split("\n").length - 1;

                    if (textInputRange.compareEndPoints("EndToEnd", endRange) > -1) {
                        end = len;
                    } else {
                        end = -textInputRange.moveEnd("character", -len);
                        end += normalizedValue.slice(0, end).split("\n").length - 1;
                    }
                }
            }
        }

        return {
            start: start,
            end: end
        }
    }

    // Return if a keyword is highlighted
    function isHighlighting(el) {
        return el.selectionStart !== el.selectionEnd;
    }

    // Return index of placeholder char
    function findPlaceholderCharIndex(selectionEnd,value) {
        if (!value || (value && !value.length)) {
            return -1;
        }
        return value.indexOf(smartTmplVM.TMPL_PLACEHOLDER_CHAR,selectionEnd);  

    }

    // Return index of selection option text
    function findSelectionTextIndex(selectionEnd,value) {
        let startIndex = -1;
        let endIndex = -1;

        if (!value || (value && !value.length)) {
            return {
                startIndex,
                endIndex
            };
        }

        try {
            startIndex = value.indexOf(smartTmplVM.TMPL_DELIM_START,selectionEnd);
            var startIndex2 = value.indexOf(smartTmplVM.TMPL_DELIM_CHOICE,selectionEnd); 
       
            if (startIndex == -1) { startIndex = startIndex2; }
            if (startIndex !== -1) {
                if (startIndex > startIndex2) { //there is a delimiter that should start the selection
                    startIndex = startIndex2;
                    endIndex = value
                        .substring(startIndex, value.length)
                        .indexOf(smartTmplVM.TMPL_DELIM_END);
                    if (endIndex !== -1) {
                        endIndex += startIndex + 1;
                    }

                } else {
                    endIndex = value
                        .substring(startIndex, value.length)
                        .indexOf(smartTmplVM.TMPL_DELIM_END);
                    if (endIndex !== -1) {
                        endIndex += startIndex + 1;
                    }

                }
            }

            if (startIndex !== -1 && endIndex !== -1) {
                startIndex++;

                const substring = value.substring(startIndex, endIndex);
                if (substring && substring.includes(smartTmplVM.TMPL_DELIM_CHOICE)) {
                    endIndex = substring.indexOf(smartTmplVM.TMPL_DELIM_CHOICE);
                } else if (substring) {
                    endIndex = substring.indexOf(smartTmplVM.TMPL_DELIM_END);
                }

                if (endIndex !== -1) {
                    endIndex += startIndex;
                }
            }

        } catch (error) { }

        return {
            startIndex,
            endIndex
        };
    }

    return {
        init: init
    }
})();	

