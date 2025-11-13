-- this update deprecates phone_best in favour of preferredPhone tag that is used by a large OSCAR fork
-- for end user convenience for eform development regardless if they are using OSCAR or a fork
UPDATE `eform` SET `form_html` = REPLACE(`form_html`,"phone_best","preferredPhone");
UPDATE `eform_data` SET `form_data` = REPLACE(`form_data`,"phone_best","preferredPhone");