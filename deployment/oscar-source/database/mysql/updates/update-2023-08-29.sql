-- copying from Open OSP
-- note, this create index if not exists only works in mariadb

CREATE INDEX IF NOT EXISTS `service_date_Index` ON `radetail` (`service_date`);