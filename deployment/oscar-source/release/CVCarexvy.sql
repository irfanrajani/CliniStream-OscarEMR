-- patch for CVC 1.1.34 for RSV vaccine
INSERT INTO `CVCImmunization` ( versionId, snomedConceptId, generic, parentConceptId, ispa, typicalDose, typicalDoseUofM, strength, shelfStatus)
VALUES ( '0', '51311000087100', '1', '', '0', '0.5', 'mL', 'see Product Monograph', 'Marketed');
SET @gen_imm_id = LAST_INSERT_ID();

INSERT INTO `CVCImmunization` ( versionId, snomedConceptId, generic, parentConceptId, ispa, typicalDose, typicalDoseUofM, strength, shelfStatus)
VALUES ( '0', '51301000087102', '0', '51311000087100', '0', '0.5', 'mL', 'see Product Monograph', 'Marketed');
SET @trade_imm_id = LAST_INSERT_ID();


INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('en','http://snomed.info/sct', '900000000000003001','Fully Specified Name','Vaccine product containing only Human orthopneumovirus antigen (medicinal product)', @gen_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('en','http://snomed.info/sct', '900000000000013009','Synonym','RSV respiratory syncytial virus unspecified', @gen_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('fr','http://snomed.info/sct', '900000000000013009','Synonym','VRS respiratory syncytial virus unspecified', @gen_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('en','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'enPublicPicklistTerm','Public Tradename Picklist (en)','Respiratory syncytial virus', @gen_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('fr','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'frPublicPicklistTerm','Public Tradename Picklist (fr)','virus respiratoire syncytial', @gen_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('en','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'enClinicianPicklistTerm','Clinician Tradename Picklist (en)','[RSV] Respiratory syncytial virus', @gen_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('fr','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'frClinicianPicklistTerm','Clinician Tradename Picklist (fr)','[VRS] virus respiratoire syncytial', @gen_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('en','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'enAbbreviation','Generic Agent Abbreviation (en)','RSV', @gen_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('fr','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'frAbbreviation','Generic Agent Abbreviation (fr)','VRS', @gen_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('en','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'enAbbreviationON','Ontario Generic Agent Abbreviation (en)','RSV', @gen_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('fr','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'frAbbreviationON','Ontario Generic Agent Abbreviation (fr)','VRS', @gen_imm_id);

INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('en','http://snomed.info/sct', '900000000000003001','Fully Specified Name','Vaccine product containing only Human orthopneumovirus antigen (medicinal product)', @trade_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('en','http://snomed.info/sct', '900000000000013009','Synonym','RSV respiratory syncytial virus unspecified', @trade_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('fr','http://snomed.info/sct', '900000000000013009','Synonym','VRS virus respiratoire syncytial unspecified', @trade_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('en','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'enPublicPicklistTerm','Public Tradename Picklist (en)','Respiratory syncytial virus', @trade_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('fr','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'frPublicPicklistTerm','Public Tradename Picklist (fr)','Respiratory syncytial virus', @trade_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('en','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'enClinicianPicklistTerm', 'Clinician Tradename Picklist (en)', 'AREXVY (RSV)', @trade_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('fr','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'frClinicianPicklistTerm', 'Clinician Tradename Picklist (fr)', 'AREXVY (VSR)', @trade_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('en','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'enAbbreviation','Generic Agent Abbreviation (en)','RSV', @trade_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('fr','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'frAbbreviation','Generic Agent Abbreviation (fr)','VSR', @trade_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('en','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'enAbbreviationON','Ontario Generic Agent Abbreviation (en)','RSV', @trade_imm_id);
INSERT INTO `CVCImmunizationName` (language,useSystem,useCode,useDisplay,`value`,CVCImmunizationId)
VALUES ('fr','https://api.cvc.canimmunize.ca/v3/NamingSystem/ca-cvc-display-terms-designation', 'frAbbreviationON','Ontario Generic Agent Abbreviation (fr)','VSR', @trade_imm_id);

INSERT INTO `CVCMedication` (versionId,din,dinDisplayName,snomedCode,snomedDisplay,status,isBrand,manufacturerDisplay)
VALUES ('0',2540207,'02540207', '51301000087102', 'AREXVY 120 micrograms per 0.5 milliliter powder and suspension for suspension for injection GlaxoSmithKline Inc', 'Marketed','0','GSK');
SET @cvcmed_id = LAST_INSERT_ID();

INSERT INTO `CVCMedicationGTIN` (cvcMedicationId, gtin) VALUES (@cvcmed_id,"None");

INSERT INTO `CVCMedicationLotNumber` (cvcMedicationId, lotNumber, expiryDate) VALUES (@cvcmed_id,"BT354", "2025-03-31");
INSERT INTO `CVCMedicationLotNumber` (cvcMedicationId, lotNumber, expiryDate) VALUES (@cvcmed_id,"9FJ54", "2024-09-30");
INSERT INTO `CVCMedicationLotNumber` (cvcMedicationId, lotNumber, expiryDate) VALUES (@cvcmed_id,"FA374", "2024-09-30");
INSERT INTO `CVCMedicationLotNumber` (cvcMedicationId, lotNumber, expiryDate) VALUES (@cvcmed_id,"B3Z25", "2025-03-31");
INSERT INTO `CVCMedicationLotNumber` (cvcMedicationId, lotNumber, expiryDate) VALUES (@cvcmed_id,"XY43C", "2025-03-31");

