<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
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

--%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<div class="col-sm-3">
	<fieldset ng-repeat="mod in $ctrl.page.columnOne.modules">
		<legend style="margin-bottom: 0px;">

			<a href="javascript:void(0)"
				style="font-size: 12px; color: #333; padding-top: 10px"
				class="pull-right" ng-click="$ctrl.openAllergies()"
				ng-show="mod.summaryCode=='allergies'"> <span
				class="glyphicon glyphicon-plus-sign" title="{{mod.summaryCode}}"></span>
			</a> {{mod.displayName}}
		</legend>

		<ul style="padding-left: 12px;">
			<%-- href="{{item.action}}" --%>
			<li ng-repeat="item in mod.summaryItem | orderBy: displayName"
				ng-show="$index < mod.displaySize"><span class="pull-right">{{item.date
					| date : 'dd-MMM-yyyy'}}</span> <a
				ng-click="$ctrl.gotoState(item,mod,item.id)"
				href="javascript:void(0)" ng-class="item.indicatorClass"
				popover="{{item.displayName}} {{item.warning}}"
				popover-trigger="'mouseenter'">{{item.displayName | limitTo: 34
					}} {{item.displayName.length > 34 ? '...' : '' }}<small
					ng-show="item.classification">({{item.classification}})</small>
			</a></li>
			<a href="javascript:void(0)" class="text-muted add-summary"
				ng-if="mod.summaryItem==null" ng-click="$ctrl.openAllergies()"
				ng-show="mod.summaryCode=='allergies'"><bean:message
					key="global.btnAdd" />{{mod.displayName}}</a>
		</ul>

		<span ng-class="showMoreItemsSymbol(mod)" ng-click="toggleList(mod)"
			ng-show="showMoreItems(mod)"></span>
	</fieldset>
</div>

<div class="col-sm-6" id="middleSpace" ng-click="checkAction($event)"
	ng-keypress="checkAction($event)">

	<div class="row">
		<ul class="nav nav-pills nav-justified">
			<li ng-class="$ctrl.isCurrentEntryStyle('prescribe')"><a
				ng-click="$ctrl.changeCurrentEntryStyle('prescribe')"
				class="hand-hover">Prescribe</a></li>
			<li ng-class="$ctrl.isCurrentEntryStyle('additional')"><a
				ng-click="$ctrl.changeCurrentEntryStyle('additional')"
				class="hand-hover">Additional Meds</a></li>
		</ul>
		<div class="tab-content"></div>
		<div class="list-group">
			<li class="list-group-item <%--active--%>"
				ng-repeat="med in $ctrl.toRxList">
				<div class="row">
					<div class="col-sm-8">
						<span class="pull-right"> <a
							ng-click="$ctrl.showMore(med);"> <span
								ng-if="med.showmore == null">More</span><span
								ng-if="med.showmore">Less</span>
						</a> <a ng-click="$ctrl.addToFavourite(med)"><span
								class="glyphicon glyphicon-heart"></span></a> <a
							ng-click="$ctrl.cancelMed(med,$index)"><span
								class="glyphicon glyphicon-remove-circle"></span></a>
						</span>
						<h4 class="list-group-item-heading">{{med.getName()}}</h4>
						<form>
							<div class="form-group">
								<input type="text" class="form-control" ng-if="med.custom"
									id="customInput" placeholder="Custom Drug Name"
									ng-model="med.customName" auto-focus>
							</div>
							<div class="form-group">
								<input type="text" class="form-control" id="instructionsInput"
									placeholder="Instructions" ng-blur="$ctrl.parseInstr(med)"
									ng-model="med.instructions" auto-focus
									ng-keyup="$event.keyCode == 13 && $ctrl.showSpecialInstructions(med)">
							</div>
							<div class="form-group">
								<input type="text" class="form-control"
									id="specailInstructionsInput"
									placeholder="Special Instructions"
									ng-model="med.additionalInstructions"
									ng-show="$ctrl.isSpecailInstructionsShow(med)">
							</div>




							<div class="form-group ">
								<div class="row">
									<div class="col-xs-6"
										ng-class="$ctrl.checkForQuantityError(med)">
										<label class="control-label" for="quantityInput">Qty/Mitte</label>
										<input type="text" class="form-control" id="quantityInput"
											placeholder="Qty/Mitte" ng-model="med.quantity"
											ng-change="$ctrl.manualQuantityEntry(med)"> <span
											ng-if="$ctrl.checkForQuantityError(med)" id="helpBlock2"
											class="help-block">Quantity was not calculated. Manual
											Calculation required</span>
									</div>
									<div class="col-xs-6">
										<label for="repeatsInput">Repeat</label> <input type="text"
											class="form-control" id="repeatsInput" placeholder="Repeats"
											ng-model="med.repeats" ng-change="$ctrl.repeatsUpdated(med)">
									</div>
								</div>
								<div class="row" ng-if="med.duration != null">
									<div class="col-xs-12 has-error">
										Duration was calculated to {{med.rxDurationInDays()}} days. <a
											ng-click="$ctrl.changeEndDate(med)">Change?</a>
										<div class="checkbox">
											<label> <input ng-model="med.longTerm"
												type="checkbox"> Long term
											</label>
										</div>
									</div>
								</div>
							</div>
							<lucode med="med"></lucode>
							<div class="form-group"
								ng-if="$ctrl.isCurrentEntryStyle('additional') || med.showmore">
								<div class="row">
									<div class="col-xs-6">
										<label for="repeatsInput">Start Date</label>
										<div class="input-group">
											<input type="text" class="form-control"
												ng-model="med.rxDate" 
												uib-datepicker-popup="yyyy-MM-dd"
												uib-datepicker-append-to-body="false"
												is-open="startDatePicker" ng-click="startDatePicker = true"
												placeholder="YYYY-MM-DD" /> <span
												class="input-group-addon"><span
												class="glyphicon glyphicon-calendar"></span></span>
										</div>
									</div>
									<div class="col-xs-6">
										<label for="repeatsInput">Written Date</label>
										<div class="input-group">
											<input type="text" class="form-control"
												ng-model="med.writtenDate" uib-datepicker-popup="yyyy-MM-dd"
												uib-datepicker-append-to-body="false"
												is-open="startDatePicker" ng-click="startDatePicker = true"
												placeholder="YYYY-MM-DD" /> <span
												class="input-group-addon"><span
												class="glyphicon glyphicon-calendar"></span></span>
										</div>
									</div>
								</div>
							</div>
							<div class="form-group"
								ng-if="$ctrl.isCurrentEntryStyle('additional')">
								<div class="row">
									<div class="col-xs-6">
										<label for="repeatsInput">Outside Provider Name</label>
										<div class="input-group">
											<input type="text" class="form-control" ng-model="med.externalProvider" />
										</div>
									</div>
									<div class="col-xs-6">
										<label for="repeatsInput">Outside Provider #</label>
										<div class="input-group">
											<input type="text" class="form-control" ng-model="med.outsideProviderOhip" /> 
										</div>
									</div>
								</div>
							</div>
							<div class="form-group" ng-if="med.showmore">

								<div class="row">
									<div class="col-xs-6">
										<label></label>
									</div>
								</div>
								<div class="row">
									<div class="col-xs-4">
										<label><bean:message key="WriteScript.msgPrescribedRefill" /> <bean:message key="WriteScript.msgPrescribedRefillDuration" /></label>
										<div class="input-group">
											<input type="text" class="form-control" ng-model="med.refillDuration" placeholder="<bean:message key="WriteScript.msgPrescribedRefillDurationDays"/>" />
										</div>

									</div>
									<div class="col-xs-4">
										<label><bean:message key="WriteScript.msgPrescribedRefill" /> <bean:message
												key="WriteScript.msgPrescribedRefillQuantity" /></label>
										<div class="input-group">
											<input type="text" class="form-control" ng-model="med.refillQuantity" />
										</div>
									</div>
									<div class="col-xs-4">
										<label><bean:message key="WriteScript.msgPrescribedDispenseInterval" /></label>
										<div class="input-group">
											<input type="text" class="form-control" ng-model="med.dispenseInterval" />
										</div>
									</div>
								</div>
								<div class="row">
									<div class="col-xs-12">

										<div class="input-group">
											<label for="patientCompliantSelection"><small><bean:message key="WriteScript.msgPatientCompliance" /></small></label> 
											<label class="radio-inline"><input type="radio" name="inlineRadioOptions" ng-model="med.patientCompliance" id="inlineRadio1" value="true"> <bean:message key="WriteScript.msgYes" /></label>
											<label class="radio-inline"><input type="radio" name="inlineRadioOptions" ng-model="med.patientCompliance" id="inlineRadio2" value="false"> <bean:message key="WriteScript.msgNo" /></label>
											<label class="radio-inline"><input type="radio" name="inlineRadioOptions" ng-model="med.patientCompliance" id="inlineRadio3" value="null"> <bean:message key="WriteScript.msgUnset" /></label>
										</div>
									</div>
								</div>

								<div class="row">
									<div class="col-xs-6">
										<div class="input-group">
											<label><bean:message key="WriteScript.msgPickUpDate" /></label>
											<div class="input-group">
											<input type="text" class="form-control"
												ng-model="med.pickupDate" uib-datepicker-popup="yyyy-MM-dd"
												uib-datepicker-append-to-body="false"
												is-open="pickupDatePicker" ng-click="pickupDatePicker = true"
												placeholder="YYYY-MM-DD" /> <span
												class="input-group-addon"><span
												class="glyphicon glyphicon-calendar"></span></span>
											
											
											</div>
											<label><bean:message key="WriteScript.msgPickUpTime" /></label>
											<div uib-timepicker ng-model="med.pickupDate"  hour-step="1" minute-step="15" show-meridian="true"></div>
											
										</div>
									</div>
									<div class="col-xs-6">
										<div class="input-group">
											<div class="checkbox">
											    <label>
											      <input type="checkbox" ng-model="med.nosubs"> <bean:message key="WriteScript.msgSubNotAllowed" />
											    </label>
											</div>
											
											<div class="checkbox">
											    <label>
											      <input type="checkbox" ng-model="med.nonAuthoritative"> <bean:message key="WriteScript.msgNonAuthoritative" />
											    </label>
											</div>
											
										</div>
									</div> 
								</div>

								<div class="row">
									<div class="col-xs-6">
										<div class="input-group">
											<label><bean:message key="WriteScript.msgProtocolReference" /></label> 
											<input class="form-control" type="text" ng-model="med.protocol" />
										</div>
									</div>
									<div class="col-xs-6">
										<div class="input-group">
											<label>Prior Rx Protocol</label> 
											<input class="form-control" type="text" ng-model="med.priorRxProtocol" />
										</div>
									</div>
								</div>


								<div class="row">
									<div class="col-xs-6">
										<div class="input-group">
											<label><bean:message key="WriteScript.msgETreatmentType" /></label>
											<select ng-model="med.eTreatmentType" class="form-control">
												<option>--</option>
												<option value="CHRON"><bean:message key="WriteScript.msgETreatment.Continuous" /></option>
												<option value="ACU"><bean:message key="WriteScript.msgETreatment.Acute" /></option>
												<option value="ONET"><bean:message key="WriteScript.msgETreatment.OneTime" /></option>
												<option value="PRNL"><bean:message key="WriteScript.msgETreatment.LongTermPRN" /></option>
												<option value="PRNS"><bean:message key="WriteScript.msgETreatment.ShortTermPRN" /></option>
											</select>
										</div>
									</div>
									<div class="col-xs-6">
										<div class="input-group">
											<label>Status</label> 
											<select ng-model="med.rxStatus"class="form-control">
												<option>--</option>
												<option value="New"><bean:message key="WriteScript.msgRxStatus.New" /></option>
												<option value="Active"><bean:message key="WriteScript.msgRxStatus.Active" /></option>
												<option value="Suspended"><bean:message key="WriteScript.msgRxStatus.Suspended" /></option>
												<option value="Aborted"><bean:message key="WriteScript.msgRxStatus.Aborted" /></option>
												<option value="Completed"><bean:message key="WriteScript.msgRxStatus.Completed" /></option>
												<option value="Obsolete"><bean:message key="WriteScript.msgRxStatus.Obsolete" /></option>
												<option value="Nullified"><bean:message key="WriteScript.msgRxStatus.Nullified" /></option>
											</select>
										</div>
									</div>
								</div>







	\


								<%-- if(OscarProperties.getInstance().getProperty("rx.enable_internal_dispensing","false").equals("true")) {%>  
	       <div>
	       	   <bean:message key="WriteScript.msgDispenseInternal"/>	
			  <input type="checkbox" name="dispenseInternal_" id="dispenseInternal_"  />
      	 </div>
      	 <% } --%>
								<%-- 
         
    </div><div>

        <label for="pastMedSelection" title="Medications taken at home that were previously ordered."><bean:message key="WriteScript.msgPastMedication" /></label>
        
        <span id="pastMedSelection">
        	<label for="pastMedY_"><bean:message key="WriteScript.msgYes"/></label> 
            <input  type="radio" value="yes" name="pastMed_" id="pastMedY_"   />
            
            <label for="pastMedN_"><bean:message key="WriteScript.msgNo"/></label> 
            <input  type="radio" value="no" name="pastMed_" id="pastMedN_"  />
            
            <label for="pastMedE_"><bean:message key="WriteScript.msgUnknown"/></label> 
            <input  type="radio" value="unset" name="pastMed_" id="pastMedE_"   />
         </span>         
	</div>
	
	 
	 <div>
          <bean:message key="WriteScript.msgNonAuthoritative"/>
            <input type="checkbox" name="nonAuthoritativeN_" id="nonAuthoritativeN_"  />
    </div>
    <div>
    
    		<bean:message key="WriteScript.msgSubNotAllowed"/>
    		<input type="checkbox" name="nosubs_" id="nosubs_"  />
    </div>
    
    
    <div>
           
           <bean:message key="WriteScript.msgPickUpDate"/>: 
           <input type="text" id="pickupDate_"  name="pickupDate_"  onchange="if (!isValidDate(this.value)) {this.value=null}" />
           <bean:message key="WriteScript.msgPickUpTime"/>: 
           <input type="text" id="pickupTime_"  name="pickupTime_"  onchange="if (!isValidTime(this.value)) {this.value=null}" />
           </div><div>
    
    
    <div>
	<label style="">Last Refill Date:</label>
           <input type="text" id="lastRefillDate_"  name="lastRefillDate_"  />
	</div>
           </div>
           <bean:message key="WriteScript.msgComment"/>:
           <input type="text" id="comment_" name="comment_"  size="60"/>
           </div><div>  
           
           
                </div><div>                
                <bean:message key="WriteScript.msgDrugForm"/>: 
                <%if(rx.getDrugFormList()!=null && rx.getDrugFormList().indexOf(",")!=-1){ %>
                <select name="drugForm_">
                	<%
                		String[] forms = rx.getDrugFormList().split(",");
                		for(String form:forms) {
                	%>
                		<option value="<%=form%>" <%=form.equals(drugForm)?"selected":"" %>><%=form%></option>
                	<% } %>
                </select>    
				<%} else { %>
					<%=drugForm%>
				<% } %>




       			</div>
       --%>

							</div>
							<!-- end of more section -->
						</form>
					</div>
					<div class="col-sm-4">
						<div class="alert alert-danger" ng-if="med.custom">
							<b>Warning</b> you will lose the following functionality:
							<ul style="padding: 10px;">
								<li>Known Dosage Forms / Routes</li>
								<li>Drug Allergy Information</li>
								<li>Drug-Drug Interaction Information</li>
								<li>Drug Information</li>
							</ul>
						</div>

						<div uib-alert
							ng-repeat="alert in $ctrl.page.dsMessageHash[med.atc]"
							class="alert"
							ng-class="'alert-' + ($ctrl.getAlertStyl(alert) || 'warning')"
							style="padding: 9px; margin-bottom: 3px;"
							ng-hide="$ctrl.checkIfHidden(alert)">
							<%-- uib-popover-html="{{alert.body}}" popover-trigger="'mouseenter'"  --%>
							{{alert.heading}}<br> {{alert.summary | limitTo: 150
							}}{{alert.summary.length > 150 ? '...' : ''}} <br> <small>From:{{alert.author}}</small>
						</div>
					</div>

				</div>
			</li>
		</div>
		<medsearch med-selected="$ctrl.medSelected(med)"
			fav-selected="$ctrl.favSelected(fav)"
			favourite-meds="$ctrl.page.favouriteDrugs"
			custom-rx="$ctrl.customRx(nam)"></medsearch>
		<button type="button"
			ng-if="$ctrl.isCurrentEntryStyleBoolean('prescribe')"
			class="btn btn-primary btn-block" style="margin-top: 3px;"
			ng-click="$ctrl.saveAndPrint()">Save And Print</button>
		<button type="button"
			ng-if="$ctrl.isCurrentEntryStyleBoolean('additional')"
			class="btn btn-primary btn-block" style="margin-top: 3px;"
			ng-click="$ctrl.saveAndPrint()">Save</button>

		<h6>
			<small>Preferred Pharmacy:</small>
			{{$ctrl.getCurrentPharmacy().name}}
		</h6>
	</div>
	<hr>
	<div class="row">
		<rx-profile fulldrugs="$ctrl.page.fulldrugs" re-rx="$ctrl.reRx(drug)"
			ds-messages="$ctrl.page.dsMessageHash"
			show-alert="$ctrl.showAlert(alert)"
			add-favorite="$ctrl.addToFavourite(drug)"></rx-profile>
	</div>




</div>
<!-- middleSpace -->


<div class="col-sm-3">

	<fieldset ng-repeat="mod in $ctrl.page.columnThree.modules">
		<legend style="margin-bottom: 0px;">
			{{mod.displayName}}
			<div class="form-group">
				<input type="text" class="form-control search-query"
					ng-model="incomingQ" placeholder="Search">
			</div>
		</legend>
		<ul style="padding-left: 12px;">
			<%-- href="{{item.action}}" --%>
			<li ng-repeat="item in mod.summaryItem | filter:incomingQ"
				ng-show="$index < mod.displaySize"><span class="pull-right">{{item.date
					| date : 'dd-MMM-yyyy'}}</span><a ng-click="gotoState(item)"
				class="hand-hover"
				ng-class="{true: 'abnormal', false: ''}[item.abnormalFlag]">{{item.displayName}}<small
					ng-show="item.classification">({{item.classification}})</small></a></li>
		</ul>

		<span ng-class="showMoreItemsSymbol(mod)" ng-click="toggleList(mod)"
			ng-show="showMoreItems(mod)"></span>
	</fieldset>

	<a style="color: white;" ng-click="$ctrl.shortDSMessage()">Refresh
		Decision Support</a>
</div>
