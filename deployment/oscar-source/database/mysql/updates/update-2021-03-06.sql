INSERT INTO `secObjPrivilege` VALUES('doctor','_dashboardChgUser','o',0,'999998');
INSERT INTO `secObjPrivilege` VALUES('admin','_dashboardChgUser','o',0,'999998');

--
-- COVID 19 codes for Ontario `billingservice`
--

INSERT INTO `billingservice` ( `service_code`, `description`, `value`,  `billingservice_date`, `region`, `anaesthesia`, `gstFlag`, `termination_date`, `sliFlag`) VALUES
(  'H409A', 'COVID Sessional hourly M-F 7-5', '170.00', '2020-03-14', 'ON', '00', 0, '9999-12-31', 0),
(  'H410A', 'COVID Sessional hourly after 5pm or weekends', '220.00', '2020-03-14', 'ON', '00', 0, '9999-12-31', 0),
(  'G593A', 'COVID Vaccine Administration Initial series per inj', '13.00', '2021-03-06', 'ON', '00', 0, '9999-12-31', 0),
(  'Q593A', 'sole visit premium for COVID 19 Vaccination', '5.60', '2021-03-06', 'ON', '00', 0, '9999-12-31', 0);