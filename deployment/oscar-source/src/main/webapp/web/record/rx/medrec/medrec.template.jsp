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
<button type="button" class="btn btn-primary btn-xs" ng-class="$ctrl.buttonStyle(0)" ng-click="$ctrl.showNewButton()">Med Rec</button>
 <small><small><small><small> {{$ctrl.providerName}}  <small>({{$ctrl.lastMedRecDate | date}})</small></small></small></small>  </small> 
<div ng-if="$ctrl.showAddNew" class="row" style="margin-top:3px,margin-bottom:3px;">
	<div class="col-sm-5">
		Med Rec Date:
	</div>
	<div class="col-sm-5">
		
	<div class="input-group">
	
		<input type="text" class="form-control"
			ng-model="$ctrl.newMedRec" uib-datepicker-popup="yyyy-MM-dd"
			uib-datepicker-append-to-body="false"
			is-open="medRecDatePicker" ng-click="medRecDatePicker = true"
			placeholder="YYYY-MM-DD" /> <span
			class="input-group-addon"><span
			class="glyphicon glyphicon-calendar"></span></span>
	</div>
	</div>
	<div class="col-sm-2">
	<button type="button" class="btn btn-primary"  ng-click="$ctrl.saveNewMedRec()">Save</button>
	</div>
</div>
