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

package oscar.util;

import org.apache.logging.log4j.Logger;
import org.oscarehr.util.MiscUtils;

import java.lang.reflect.AccessibleObject;
import java.lang.reflect.Field;
import java.security.InvalidParameterException;
import java.util.ArrayList;
import java.util.List;

public class ChangedField {
    private static final Logger logger = MiscUtils.getLogger();
    
    private String fieldName;
    private String oldValue;
    private String newValue;

    public ChangedField(String fieldName, String oldValue, String newValue) {
        this.fieldName = fieldName;
        this.oldValue = oldValue;
        this.newValue = newValue;
    }

    public String getFieldName() {
        return fieldName;
    }
    public void setFieldName(String fieldName) {
        this.fieldName = fieldName;
    }

    public String getOldValue() {
        return oldValue;
    }
    public void setOldValue(String oldValue) {
        this.oldValue = oldValue;
    }

    public String getNewValue() {
        return newValue;
    }
    public void setNewValue(String newValue) {
        this.newValue = newValue;
    }

    @Override
    public String toString() {
        return getFieldName() + ": " + getOldValue() + " -> " + getNewValue() + ";";
    }

    /**
     * Compares all NON-INHERITED fields
     * @param oldObject object to compare
     * @param newObject new object to compare
     * @return a List of ChangedFields for the two Objects
     */
    public static List<ChangedField> getChangedFieldsAndValues(Object oldObject, Object newObject) {
        if (oldObject.getClass() != newObject.getClass()) {
            throw new InvalidParameterException();
        }
        //For recursively getting fields from parent class
//        for (Class<?> c = someClass; c != null; c = c.getSuperclass())
//        {
//            Field[] fields = c.getDeclaredFields();
//            for (Field classField : fields)
//            {
//                result.add(classField);
//            }
//        }

        List<ChangedField> changedFields = new ArrayList<ChangedField>();
        Field[] fields = oldObject.getClass().getDeclaredFields();
        
        AccessibleObject.setAccessible(fields, true);
        for (Field field : fields) {
            try {
                Object oldValue = field.get(oldObject);
                Object newValue = field.get(newObject);
                if (oldValue != null && newValue == null) {
                    changedFields.add(new ChangedField(field.getName(), oldValue.toString(), "null"));
                } else if (oldValue == null && newValue != null) {
                    changedFields.add(new ChangedField(field.getName(), "null", newValue.toString()));
                } else if (oldValue != null && newValue != null && 
                        !field.get(oldObject).equals(field.get(newObject))) {
                    changedFields.add(new ChangedField(field.getName(), oldValue.toString(), newValue.toString()));
                }
            } catch (IllegalAccessException e) {
                logger.error("Error creating ChangedField list", e);
                changedFields.add(new ChangedField(field.getName(), "ERROR logging field", e.getClass().getName()));
            }
        }
        return changedFields;
    }
}
