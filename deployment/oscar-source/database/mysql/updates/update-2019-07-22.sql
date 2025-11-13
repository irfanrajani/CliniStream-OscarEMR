CREATE TABLE IndicatorResultItem (
    id int(11) auto_increment,
    providerNo varchar(30),
    timeGenerated timestamp,
    indicatorTemplateId int,
    label varchar(255),
    result float,
    PRIMARY KEY(id)
);

insert into OscarJobType VALUES (\N,'DashboardTrending','','org.oscarehr.integration.dashboard.DashboardTrendingJob',1,now());
