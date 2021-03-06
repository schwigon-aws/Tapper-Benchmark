use `testrundb`;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `bench_backup_additional_relations`;
DROP TABLE IF EXISTS `bench_backup_values`;
DROP TABLE IF EXISTS `bench_additional_relations`;
DROP TABLE IF EXISTS `bench_additional_type_relations`;
DROP TABLE IF EXISTS `bench_additional_values`;
DROP TABLE IF EXISTS `bench_additional_types`;
DROP TABLE IF EXISTS `bench_values`;
DROP TABLE IF EXISTS `benchs`;
DROP TABLE IF EXISTS `bench_units`;
DROP TABLE IF EXISTS `bench_subsume_types`;

CREATE TABLE `bench_subsume_types` (
  `bench_subsume_type_id` TINYINT(3) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'unique key (PK)',
  `bench_subsume_type` VARCHAR(32) NOT NULL COMMENT 'unique string identifier',
  `bench_subsume_type_rank` TINYINT(3) UNSIGNED NOT NULL COMMENT 'subsume type order',
  `datetime_strftime_pattern` VARCHAR(32) NULL COMMENT 'format pattern for per DateTime->strftime for grouping',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'creation date',
  PRIMARY KEY (`bench_subsume_type_id`),
  UNIQUE INDEX `ux_bench_subsume_types_01` (`bench_subsume_type` ASC)
) COMMENT 'types of subsume values';

CREATE TABLE `bench_units` (
  `bench_unit_id` TINYINT(3) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'unique key (PK)',
  `bench_unit` VARCHAR(64) NOT NULL COMMENT 'unique string identifier',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'creation date',
  PRIMARY KEY (`bench_unit_id`),
  UNIQUE INDEX `ux_bench_units_01` (`bench_unit` ASC)
) COMMENT 'units for benchmark data points';

CREATE TABLE `benchs` (
  `bench_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'unique key (PK)',
  `bench_unit_id` TINYINT(3) UNSIGNED NULL,
  `bench` VARCHAR(64) NOT NULL COMMENT 'unique string identifier',
  `active` TINYINT(3) UNSIGNED NOT NULL COMMENT 'is entry still active (1=yes,0=no)',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'creation date',
  PRIMARY KEY (`bench_id`),
  UNIQUE INDEX `ux_benchs_01` (`bench` ASC),
  INDEX `fk_benchs_01` (`bench_unit_id` ASC),
  CONSTRAINT `fk_benchs_01`
    FOREIGN KEY (`bench_unit_id`)
    REFERENCES `bench_units` (`bench_unit_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) COMMENT 'containg benchmark head data';

CREATE TABLE `bench_values` (
  `bench_value_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'unique key (PK)',
  `bench_id` INT(10) UNSIGNED NOT NULL COMMENT 'FK to benchs',
  `bench_subsume_type_id` TINYINT(3) UNSIGNED NOT NULL COMMENT 'FK to bench_subsume_types',
  `bench_value` FLOAT NULL COMMENT 'value for bench data point',
  `active` tinyint(3) unsigned NOT NULL COMMENT 'is entry still active (0=no,1=yes)',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'creation date',
  PRIMARY KEY (`bench_value_id`),
  INDEX `fk_bench_values_01` (`bench_id` ASC),
  INDEX `fk_bench_values_02` (`bench_subsume_type_id` ASC),
  CONSTRAINT `fk_bench_values_01`
    FOREIGN KEY (`bench_id`)
    REFERENCES `benchs` (`bench_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_bench_values_02`
    FOREIGN KEY (`bench_subsume_type_id`)
    REFERENCES `bench_subsume_types` (`bench_subsume_type_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) COMMENT 'containing data points for benchmark';

CREATE TABLE `bench_additional_types` (
  `bench_additional_type_id` SMALLINT(5) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'unique key (PK)',
  `bench_additional_type` VARCHAR(32) NOT NULL COMMENT 'unique string identifier',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'creation date',
  PRIMARY KEY (`bench_additional_type_id`),
  UNIQUE INDEX `ux_bench_additional_types_01` (`bench_additional_type` ASC)
) COMMENT 'types of additional values for benchmark data points';

CREATE TABLE `bench_additional_values` (
  `bench_additional_value_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'unique key (PK)',
  `bench_additional_type_id` SMALLINT(5) UNSIGNED NOT NULL COMMENT 'FK to bench_additional_types',
  `bench_additional_value` VARCHAR(128) NOT NULL COMMENT 'additional value',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'creation date',
  PRIMARY KEY (`bench_additional_value_id`),
  INDEX `fk_bench_additional_values_01` (`bench_additional_type_id` ASC),
  UNIQUE INDEX `ux_bench_additional_values_01` (`bench_additional_type_id` ASC, `bench_additional_value` ASC),
  CONSTRAINT `fk_bench_additional_values_01`
    FOREIGN KEY (`bench_additional_type_id`)
    REFERENCES `bench_additional_types` (`bench_additional_type_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) COMMENT 'additional values for benchmark data point';

CREATE TABLE `bench_additional_type_relations` (
  `bench_id` INT(10) UNSIGNED NOT NULL COMMENT 'FK to benchs (PK)',
  `bench_additional_type_id` SMALLINT(5) UNSIGNED NOT NULL COMMENT 'FK to bench_additional_types (PK)',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'creation date',
  PRIMARY KEY (`bench_id`,`bench_additional_type_id`),
  INDEX `fk_bench_additional_values_01` (`bench_id` ASC),
  INDEX `fk_bench_additional_values_02` (`bench_additional_type_id` ASC),
  CONSTRAINT `fk_bench_additional_type_relations_01`
    FOREIGN KEY (`bench_id`)
    REFERENCES `benchs` (`bench_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_bench_additional_type_relations_02`
    FOREIGN KEY (`bench_additional_type_id`)
    REFERENCES `bench_additional_types` (`bench_additional_type_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) COMMENT 'additional values for benchmark data point';

CREATE TABLE `bench_additional_relations` (
  `bench_value_id` INT(10) UNSIGNED NOT NULL COMMENT 'FK to bench_values',
  `bench_additional_value_id` INT(10) UNSIGNED NOT NULL COMMENT 'FK to bench_additional_values',
  `active` tinyint(3) unsigned NOT NULL COMMENT 'is entry still active (0=no,1=yes)',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'creation date',
  PRIMARY KEY (`bench_value_id`,`bench_additional_value_id`),
  INDEX `fk_bench_additional_relations_01` (`bench_value_id` ASC),
  INDEX `fk_bench_additional_relations_02` (`bench_additional_value_id` ASC),
  CONSTRAINT `fk_bench_additional_relations_01`
    FOREIGN KEY (`bench_value_id`)
    REFERENCES `bench_values` (`bench_value_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_bench_additional_relations_02`
    FOREIGN KEY (`bench_additional_value_id`)
    REFERENCES `bench_additional_values` (`bench_additional_value_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) COMMENT 'add additional values to benchmarks';

CREATE TABLE `bench_backup_values` (
  `bench_backup_value_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'unique key (PK)',
  `bench_value_id` int(10) unsigned NOT NULL COMMENT 'FK to bench_values',
  `bench_id` int(10) unsigned NOT NULL COMMENT 'FK to benchs',
  `bench_subsume_type_id` tinyint(3) unsigned NOT NULL COMMENT 'FK to bench_subsume_types',
  `bench_value` float DEFAULT NULL COMMENT 'value for bench data point',
  `active` tinyint(3) unsigned NOT NULL COMMENT 'is entry still active (0=no,1=yes)',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'creation date',
  PRIMARY KEY (`bench_backup_value_id`),
  KEY `fk_bench_backup_values_01` (`bench_id`),
  KEY `fk_bench_backup_values_02` (`bench_subsume_type_id`),
  KEY `fk_bench_backup_values_03` (`bench_value_id`),
  CONSTRAINT `fk_bench_backup_values_01`
    FOREIGN KEY (`bench_id`)
    REFERENCES `benchs` (`bench_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_bench_backup_values_02`
    FOREIGN KEY (`bench_subsume_type_id`)
    REFERENCES `bench_subsume_types` (`bench_subsume_type_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_bench_backup_values_03`
    FOREIGN KEY (`bench_value_id`)
    REFERENCES `bench_values` (`bench_value_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) COMMENT='backup table for data points for benchmark';

CREATE TABLE `bench_backup_additional_relations` (
  `bench_backup_value_id` int(10) unsigned NOT NULL COMMENT 'FK to bench_backup_values',
  `bench_additional_value_id` int(10) unsigned NOT NULL COMMENT 'FK to bench_additional_values',
  `active` tinyint(3) unsigned NOT NULL COMMENT 'is entry still active (0=no,1=yes)',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'creation date',
  PRIMARY KEY (`bench_backup_value_id`,`bench_additional_value_id`),
  KEY `fk_bench_backup_additional_relations_01` (`bench_backup_value_id`),
  KEY `fk_bench_backup_additional_relations_02` (`bench_additional_value_id`),
  CONSTRAINT `fk_bench_backup_additional_relations_01`
    FOREIGN KEY (`bench_backup_value_id`)
    REFERENCES `bench_backup_values` (`bench_backup_value_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_bench_backup_additional_relations_02`
    FOREIGN KEY (`bench_additional_value_id`)
    REFERENCES `bench_additional_values` (`bench_additional_value_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) COMMENT='add additional values to benchmarks';

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO bench_subsume_types
    ( bench_subsume_type, bench_subsume_type_rank, datetime_strftime_pattern, created_at )
VALUES
    ( 'atomic'  , 1, NULL           , NOW() ),
    ( 'second'  , 2, '%Y%m%d%H%M%S' , NOW() ),
    ( 'minute'  , 3, '%Y%m%d%H%M'   , NOW() ),
    ( 'hour'    , 4, '%Y%m%d%H'     , NOW() ),
    ( 'day'     , 5, '%Y%m%d'       , NOW() ),
    ( 'week'    , 6, '%Y%W'         , NOW() ),
    ( 'month'   , 7, '%Y%m'         , NOW() ),
    ( 'year'    , 8, '%Y'           , NOW() )
;