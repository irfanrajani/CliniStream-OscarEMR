-- add diagnostic codes
INSERT INTO `diagnosticcode`(`diagnostic_code`, `description`, `status`, `region`) VALUES ('80', 'Coronavirus suspected or confirmed', 'A', 'ON') ON DUPLICATE KEY UPDATE region='ON';
INSERT INTO `diagnosticcode`(`diagnostic_code`, `description`, `status`, `region`) VALUES ('81', 'Long COVID post COVID condition PCC', 'A', 'ON') ON DUPLICATE KEY UPDATE region='ON';

-- upgrade jquery from 1.4.2 to 1.12.3 to restore  eform pdf and printing functions.  
-- Note that the update for eform_data will be database intensive in older installations
UPDATE eform SET form_html = REPLACE(form_html, "${oscar_javascript_path}jquery/jquery-1.4.2.js", "../js/jquery-1.12.3.js");
UPDATE eform_data SET form_data = REPLACE(form_data, "${oscar_javascript_path}jquery/jquery-1.4.2.js", "../js/jquery-1.12.3.js");