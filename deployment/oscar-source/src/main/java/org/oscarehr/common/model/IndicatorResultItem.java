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
package org.oscarehr.common.model;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
public class IndicatorResultItem extends AbstractModel<Integer> {

	@Id
	@GeneratedValue(strategy=GenerationType.AUTO)
	private Integer id;
	/*
    @ManyToOne(fetch=FetchType.EAGER)
    @JoinColumn(name="indicatorResultId", nullable=false)
	private IndicatorResult indicatorResult;
    */
    private String label;
    
    private double result;

    private String providerNo;
	
	@Temporal(TemporalType.TIMESTAMP)
	private Date timeGenerated;
	
	private int indicatorTemplateId;
	
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	/*
	public IndicatorResult getIndicatorResult() {
		return indicatorResult;
	}

	public void setIndicatorResult(IndicatorResult indicatorResult) {
		this.indicatorResult = indicatorResult;
	}
	*/

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public double getResult() {
		return result;
	}

	public void setResult(double result) {
		this.result = result;
	}

	public String getProviderNo() {
		return providerNo;
	}

	public void setProviderNo(String providerNo) {
		this.providerNo = providerNo;
	}

	public Date getTimeGenerated() {
		return timeGenerated;
	}

	public void setTimeGenerated(Date timeGenerated) {
		this.timeGenerated = timeGenerated;
	}

	public int getIndicatorTemplateId() {
		return indicatorTemplateId;
	}

	public void setIndicatorTemplateId(int indicatorTemplateId) {
		this.indicatorTemplateId = indicatorTemplateId;
	}
	
    
	
}
