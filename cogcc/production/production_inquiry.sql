create table cogcc_well_productions (
	id serial primary key not null, 
	well_id integer, 
	production_year varchar(4),
	production_month varchar(3),
	formation_name varchar(50),
	well_status_code varchar(2),
	days_producing integer,
	oil_bom integer,
	oil_produced integer,
	oil_sold integer,
	oil_adj integer,
	oil_eom integer,
	oil_gravity real,
	gas_production integer,
	gas_flared integer,
	gas_used integer,
	gas_shrinkage integer,
	gas_sold integer,
	gas_btu real,
	water_production integer,
	water_disposal_code varchar(1)
);

alter table cogcc_scrape_statuses add column production_scrape_status varchar(100) default 'not scraped';

-- not scraped --(default)
-- not found --no production inquiry records found for well api number
-- 'year list' --comma separated list of years found and data saved


select sum(p.gas_flared), w.well_id, w.long, w.lat from cogcc_wells w inner join cogcc_well_productions p on w.well_id = p.well_id where p.production_year = '2013' and p.gas_flared is not null group by w.well_id, w.long, w.lat;

select 
	--gas.flared_amount,
	--gas.well_id, 
	--gas.long,
	--gas.lat
	'{"type":"Point","coordinates":[' || gas.long || ',' || gas.lat || ']},'
from 
	(
		select 
			sum(p.gas_flared) as flared_amount, 
			w.well_id, 
			w.long, 
			w.lat 
		from 
			cogcc_wells w 
		inner join 
			cogcc_well_productions p on w.well_id = p.well_id 
		where 
			p.production_year = '2013' 
			and p.gas_flared is not null 
		group by 
			w.well_id, 
			w.long, 
			w.lat
	) gas
where 
	flared_amount > 100 
order by 
	flared_amount desc;


select 
	sum(case when gas.flared_amount >= 10000 then 1 else 0 end) as gt_10000,
	sum(case when gas.flared_amount between 5000 and 9999 then 1 else 0 end) as bet_5000_10000,
	sum(case when gas.flared_amount between 4000 and 4999 then 1 else 0 end) as bet_4000_5000,
	sum(case when gas.flared_amount between 3000 and 3999 then 1 else 0 end) as bet_3000_4000,
	sum(case when gas.flared_amount between 2000 and 2999 then 1 else 0 end) as bet_2000_3000,
	sum(case when gas.flared_amount between 1000 and 1999 then 1 else 0 end) as bet_1000_2000,
	sum(case when gas.flared_amount between 500 and 999 then 1 else 0 end) as bet_500_1000,
	sum(case when gas.flared_amount between 100 and 499 then 1 else 0 end) as bet_100_500
from 
	(
		select 
			sum(p.gas_flared) as flared_amount, 
			w.well_id, 
			w.long, 
			w.lat 
		from 
			cogcc_wells w 
		inner join 
			cogcc_well_productions p on w.well_id = p.well_id 
		where 
			p.production_year = '2013' 
			and p.gas_flared is not null 
		group by 
			w.well_id, 
			w.long, 
			w.lat
	) gas;

select sum(gas_flared) as flared_amount, production_year from cogcc_well_productions group by production_year order by production_year;





select 
	f.facility_id, f.facility_name, f.facility_number, f.operator_name as facility_operator_name, f.operator_number as facility_operator_number, f.status as facility_status, f.field_name as facility_field_name, f.field_number as facility_field_number, fl.latitude as facility_latitude, fl.longitude as facility_longitude, fw.api_number as well_api_number, w.spud_date, w.completion_date, w.lat as well_latitude, w.long as well_longitude,
	sum(case p.prod_year when 2000 then p.oil_produced else 0 end) as bbl_2000, 
	sum(case p.prod_year when 2001 then p.oil_produced else 0 end) as bbl_2001, 
	sum(case p.prod_year when 2002 then p.oil_produced else 0 end) as bbl_2002, 
	sum(case p.prod_year when 2003 then p.oil_produced else 0 end) as bbl_2003, 
	sum(case p.prod_year when 2004 then p.oil_produced else 0 end) as bbl_2004, 
	sum(case p.prod_year when 2005 then p.oil_produced else 0 end) as bbl_2005, 
	sum(case p.prod_year when 2006 then p.oil_produced else 0 end) as bbl_2006, 
	sum(case p.prod_year when 2007 then p.oil_produced else 0 end) as bbl_2007,  
	sum(case p.prod_year when 2008 then p.oil_produced else 0 end) as bbl_2008, 
	sum(case p.prod_year when 2009 then p.oil_produced else 0 end) as bbl_2009, 
	sum(case p.prod_year when 2010 then p.oil_produced else 0 end) as bbl_2010, 
	sum(case p.prod_year when 2011 then p.oil_produced else 0 end) as bbl_2011, 
	sum(case p.prod_year when 2012 then p.oil_produced else 0 end) as bbl_2012, 
	sum(case p.prod_year when 2013 then p.oil_produced else 0 end) as bbl_2013, 
	sum(case p.prod_year when 2014 then p.oil_produced else 0 end) as bbl_2014
from cogcc_facilities f 
inner join cogcc_facility_locations fl on f.id = fl.cogcc_facility_id 
inner join cogcc_facility_wells fw on f.id = fw.cogcc_facility_id 
inner join cogcc_wells w on fw.api_number = w.attrib_1 
left outer join cogcc_well_productions p on w.well_id = p.well_id 
group by f.facility_id, f.facility_name, f.facility_number, f.operator_name, f.operator_number, f.status, f.field_name, f.field_number, fl.latitude, fl.longitude, fw.api_number, w.spud_date, w.completion_date, w.lat, w.long
order by 
	f.facility_name, 
	fw.api_number desc;


create table cogcc_production_amount_types (
	id serial primary key not null, 
	description varchar(20)
);
insert into cogcc_production_amount_types (id, description) values (1, 'Oil BOM');
insert into cogcc_production_amount_types (id, description) values (2, 'Oil Produced');
insert into cogcc_production_amount_types (id, description) values (3, 'Oil Sold');
insert into cogcc_production_amount_types (id, description) values (4, 'Oil Adjusted');
insert into cogcc_production_amount_types (id, description) values (5, 'Oil EOM');
insert into cogcc_production_amount_types (id, description) values (6, 'Gas Produced');
insert into cogcc_production_amount_types (id, description) values (7, 'Gas Flared');
insert into cogcc_production_amount_types (id, description) values (8, 'Gas Used');
insert into cogcc_production_amount_types (id, description) values (9, 'Gas Shrinkage');
insert into cogcc_production_amount_types (id, description) values (10, 'Gas Sold');
insert into cogcc_production_amount_types (id, description) values (11, 'Gas BTU');
insert into cogcc_production_amount_types (id, description) values (12, 'Water Produced');


create table cogcc_production_amounts (
	id serial primary key not null, 
	well_id integer, 
	amount_type_id integer, 
	period_1999_01 integer, 
	period_1999_02 integer, 
	period_1999_03 integer, 
	period_1999_04 integer, 
	period_1999_05 integer, 
	period_1999_06 integer, 
	period_1999_07 integer, 
	period_1999_08 integer, 
	period_1999_09 integer, 
	period_1999_10 integer, 
	period_1999_11 integer, 
	period_1999_12 integer, 
	period_2000_01 integer, 
	period_2000_02 integer, 
	period_2000_03 integer, 
	period_2000_04 integer, 
	period_2000_05 integer, 
	period_2000_06 integer, 
	period_2000_07 integer, 
	period_2000_08 integer, 
	period_2000_09 integer, 
	period_2000_10 integer, 
	period_2000_11 integer, 
	period_2000_12 integer, 
	period_2001_01 integer, 
	period_2001_02 integer, 
	period_2001_03 integer, 
	period_2001_04 integer, 
	period_2001_05 integer, 
	period_2001_06 integer, 
	period_2001_07 integer, 
	period_2001_08 integer, 
	period_2001_09 integer, 
	period_2001_10 integer, 
	period_2001_11 integer, 
	period_2001_12 integer, 
	period_2002_01 integer, 
	period_2002_02 integer, 
	period_2002_03 integer, 
	period_2002_04 integer, 
	period_2002_05 integer, 
	period_2002_06 integer, 
	period_2002_07 integer, 
	period_2002_08 integer, 
	period_2002_09 integer, 
	period_2002_10 integer, 
	period_2002_11 integer, 
	period_2002_12 integer, 
	period_2003_01 integer, 
	period_2003_02 integer, 
	period_2003_03 integer, 
	period_2003_04 integer, 
	period_2003_05 integer, 
	period_2003_06 integer, 
	period_2003_07 integer, 
	period_2003_08 integer, 
	period_2003_09 integer, 
	period_2003_10 integer, 
	period_2003_11 integer, 
	period_2003_12 integer, 
	period_2004_01 integer, 
	period_2004_02 integer, 
	period_2004_03 integer, 
	period_2004_04 integer, 
	period_2004_05 integer, 
	period_2004_06 integer, 
	period_2004_07 integer, 
	period_2004_08 integer, 
	period_2004_09 integer, 
	period_2004_10 integer, 
	period_2004_11 integer, 
	period_2004_12 integer, 
	period_2005_01 integer, 
	period_2005_02 integer, 
	period_2005_03 integer, 
	period_2005_04 integer, 
	period_2005_05 integer, 
	period_2005_06 integer, 
	period_2005_07 integer, 
	period_2005_08 integer, 
	period_2005_09 integer, 
	period_2005_10 integer, 
	period_2005_11 integer, 
	period_2005_12 integer, 
	period_2006_01 integer, 
	period_2006_02 integer, 
	period_2006_03 integer, 
	period_2006_04 integer, 
	period_2006_05 integer, 
	period_2006_06 integer, 
	period_2006_07 integer, 
	period_2006_08 integer, 
	period_2006_09 integer, 
	period_2006_10 integer, 
	period_2006_11 integer, 
	period_2006_12 integer, 
	period_2007_01 integer, 
	period_2007_02 integer, 
	period_2007_03 integer, 
	period_2007_04 integer, 
	period_2007_05 integer, 
	period_2007_06 integer, 
	period_2007_07 integer, 
	period_2007_08 integer, 
	period_2007_09 integer, 
	period_2007_10 integer, 
	period_2007_11 integer, 
	period_2007_12 integer, 
	period_2008_01 integer, 
	period_2008_02 integer, 
	period_2008_03 integer, 
	period_2008_04 integer, 
	period_2008_05 integer, 
	period_2008_06 integer, 
	period_2008_07 integer, 
	period_2008_08 integer, 
	period_2008_09 integer, 
	period_2008_10 integer, 
	period_2008_11 integer, 
	period_2008_12 integer, 
	period_2009_01 integer, 
	period_2009_02 integer, 
	period_2009_03 integer, 
	period_2009_04 integer, 
	period_2009_05 integer, 
	period_2009_06 integer, 
	period_2009_07 integer, 
	period_2009_08 integer, 
	period_2009_09 integer, 
	period_2009_10 integer, 
	period_2009_11 integer, 
	period_2009_12 integer, 
	period_2010_01 integer, 
	period_2010_02 integer, 
	period_2010_03 integer, 
	period_2010_04 integer, 
	period_2010_05 integer, 
	period_2010_06 integer, 
	period_2010_07 integer, 
	period_2010_08 integer, 
	period_2010_09 integer, 
	period_2010_10 integer, 
	period_2010_11 integer, 
	period_2010_12 integer, 
	period_2011_01 integer, 
	period_2011_02 integer, 
	period_2011_03 integer, 
	period_2011_04 integer, 
	period_2011_05 integer, 
	period_2011_06 integer, 
	period_2011_07 integer, 
	period_2011_08 integer, 
	period_2011_09 integer, 
	period_2011_10 integer, 
	period_2011_11 integer, 
	period_2011_12 integer, 
	period_2012_01 integer, 
	period_2012_02 integer, 
	period_2012_03 integer, 
	period_2012_04 integer, 
	period_2012_05 integer, 
	period_2012_06 integer, 
	period_2012_07 integer, 
	period_2012_08 integer, 
	period_2012_09 integer, 
	period_2012_10 integer, 
	period_2012_11 integer, 
	period_2012_12 integer, 
	period_2013_01 integer, 
	period_2013_02 integer, 
	period_2013_03 integer, 
	period_2013_04 integer, 
	period_2013_05 integer, 
	period_2013_06 integer, 
	period_2013_07 integer, 
	period_2013_08 integer, 
	period_2013_09 integer, 
	period_2013_10 integer, 
	period_2013_11 integer, 
	period_2013_12 integer, 
	period_2014_01 integer, 
	period_2014_02 integer, 
	period_2014_03 integer, 
	period_2014_04 integer, 
	period_2014_05 integer, 
	period_2014_06 integer, 
	period_2014_07 integer, 
	period_2014_08 integer, 
	period_2014_09 integer, 
	period_2014_10 integer, 
	period_2014_11 integer, 
	period_2014_12 integer
);


create table cogcc_oil_produced_amounts (
	id serial primary key not null, 
	well_id integer, 
	period_1999_01 integer, 
	period_1999_02 integer, 
	period_1999_03 integer, 
	period_1999_04 integer, 
	period_1999_05 integer, 
	period_1999_06 integer, 
	period_1999_07 integer, 
	period_1999_08 integer, 
	period_1999_09 integer, 
	period_1999_10 integer, 
	period_1999_11 integer, 
	period_1999_12 integer, 
	period_2000_01 integer, 
	period_2000_02 integer, 
	period_2000_03 integer, 
	period_2000_04 integer, 
	period_2000_05 integer, 
	period_2000_06 integer, 
	period_2000_07 integer, 
	period_2000_08 integer, 
	period_2000_09 integer, 
	period_2000_10 integer, 
	period_2000_11 integer, 
	period_2000_12 integer, 
	period_2001_01 integer, 
	period_2001_02 integer, 
	period_2001_03 integer, 
	period_2001_04 integer, 
	period_2001_05 integer, 
	period_2001_06 integer, 
	period_2001_07 integer, 
	period_2001_08 integer, 
	period_2001_09 integer, 
	period_2001_10 integer, 
	period_2001_11 integer, 
	period_2001_12 integer, 
	period_2002_01 integer, 
	period_2002_02 integer, 
	period_2002_03 integer, 
	period_2002_04 integer, 
	period_2002_05 integer, 
	period_2002_06 integer, 
	period_2002_07 integer, 
	period_2002_08 integer, 
	period_2002_09 integer, 
	period_2002_10 integer, 
	period_2002_11 integer, 
	period_2002_12 integer, 
	period_2003_01 integer, 
	period_2003_02 integer, 
	period_2003_03 integer, 
	period_2003_04 integer, 
	period_2003_05 integer, 
	period_2003_06 integer, 
	period_2003_07 integer, 
	period_2003_08 integer, 
	period_2003_09 integer, 
	period_2003_10 integer, 
	period_2003_11 integer, 
	period_2003_12 integer, 
	period_2004_01 integer, 
	period_2004_02 integer, 
	period_2004_03 integer, 
	period_2004_04 integer, 
	period_2004_05 integer, 
	period_2004_06 integer, 
	period_2004_07 integer, 
	period_2004_08 integer, 
	period_2004_09 integer, 
	period_2004_10 integer, 
	period_2004_11 integer, 
	period_2004_12 integer, 
	period_2005_01 integer, 
	period_2005_02 integer, 
	period_2005_03 integer, 
	period_2005_04 integer, 
	period_2005_05 integer, 
	period_2005_06 integer, 
	period_2005_07 integer, 
	period_2005_08 integer, 
	period_2005_09 integer, 
	period_2005_10 integer, 
	period_2005_11 integer, 
	period_2005_12 integer, 
	period_2006_01 integer, 
	period_2006_02 integer, 
	period_2006_03 integer, 
	period_2006_04 integer, 
	period_2006_05 integer, 
	period_2006_06 integer, 
	period_2006_07 integer, 
	period_2006_08 integer, 
	period_2006_09 integer, 
	period_2006_10 integer, 
	period_2006_11 integer, 
	period_2006_12 integer, 
	period_2007_01 integer, 
	period_2007_02 integer, 
	period_2007_03 integer, 
	period_2007_04 integer, 
	period_2007_05 integer, 
	period_2007_06 integer, 
	period_2007_07 integer, 
	period_2007_08 integer, 
	period_2007_09 integer, 
	period_2007_10 integer, 
	period_2007_11 integer, 
	period_2007_12 integer, 
	period_2008_01 integer, 
	period_2008_02 integer, 
	period_2008_03 integer, 
	period_2008_04 integer, 
	period_2008_05 integer, 
	period_2008_06 integer, 
	period_2008_07 integer, 
	period_2008_08 integer, 
	period_2008_09 integer, 
	period_2008_10 integer, 
	period_2008_11 integer, 
	period_2008_12 integer, 
	period_2009_01 integer, 
	period_2009_02 integer, 
	period_2009_03 integer, 
	period_2009_04 integer, 
	period_2009_05 integer, 
	period_2009_06 integer, 
	period_2009_07 integer, 
	period_2009_08 integer, 
	period_2009_09 integer, 
	period_2009_10 integer, 
	period_2009_11 integer, 
	period_2009_12 integer, 
	period_2010_01 integer, 
	period_2010_02 integer, 
	period_2010_03 integer, 
	period_2010_04 integer, 
	period_2010_05 integer, 
	period_2010_06 integer, 
	period_2010_07 integer, 
	period_2010_08 integer, 
	period_2010_09 integer, 
	period_2010_10 integer, 
	period_2010_11 integer, 
	period_2010_12 integer, 
	period_2011_01 integer, 
	period_2011_02 integer, 
	period_2011_03 integer, 
	period_2011_04 integer, 
	period_2011_05 integer, 
	period_2011_06 integer, 
	period_2011_07 integer, 
	period_2011_08 integer, 
	period_2011_09 integer, 
	period_2011_10 integer, 
	period_2011_11 integer, 
	period_2011_12 integer, 
	period_2012_01 integer, 
	period_2012_02 integer, 
	period_2012_03 integer, 
	period_2012_04 integer, 
	period_2012_05 integer, 
	period_2012_06 integer, 
	period_2012_07 integer, 
	period_2012_08 integer, 
	period_2012_09 integer, 
	period_2012_10 integer, 
	period_2012_11 integer, 
	period_2012_12 integer, 
	period_2013_01 integer, 
	period_2013_02 integer, 
	period_2013_03 integer, 
	period_2013_04 integer, 
	period_2013_05 integer, 
	period_2013_06 integer, 
	period_2013_07 integer, 
	period_2013_08 integer, 
	period_2013_09 integer, 
	period_2013_10 integer, 
	period_2013_11 integer, 
	period_2013_12 integer, 
	period_2014_01 integer, 
	period_2014_02 integer, 
	period_2014_03 integer, 
	period_2014_04 integer, 
	period_2014_05 integer, 
	period_2014_06 integer, 
	period_2014_07 integer, 
	period_2014_08 integer, 
	period_2014_09 integer, 
	period_2014_10 integer, 
	period_2014_11 integer, 
	period_2014_12 integer
);



create table cogcc_dj_production_amounts (
	id serial primary key not null, 
	well_id integer, 
	production_year varchar(4),
	production_month varchar(3),
	formation_name varchar(50),
	well_status_code varchar(2),
	days_producing integer,
	oil_bom integer,
	oil_produced integer,
	oil_sold integer,
	oil_adj integer,
	oil_eom integer,
	oil_gravity real,
	gas_production integer,
	gas_flared integer,
	gas_used integer,
	gas_shrinkage integer,
	gas_sold integer,
	gas_btu real,
	water_production integer,
	water_disposal_code varchar(1),
	prod_year smallint, 
	prod_month smallint
);

insert into cogcc_dj_production_amounts (well_id, production_year, production_month, formation_name, well_status_code, days_producing, oil_bom, oil_produced, oil_sold, oil_adj, oil_eom, oil_gravity, gas_production, gas_flared, gas_used, gas_shrinkage, gas_sold, gas_btu, water_production, water_disposal_code, prod_year, prod_month)
select distinct
	well_id, production_year, production_month, formation_name, well_status_code, days_producing, oil_bom, oil_produced, oil_sold, oil_adj, oil_eom, oil_gravity, gas_production, gas_flared, gas_used, gas_shrinkage, gas_sold, gas_btu, water_production, water_disposal_code, prod_year, prod_month 
from cogcc_well_productions where prod_year = 2014 and prod_month in (1,2,3) and well_id in (select w.well_id from cogcc_wells w where w.api_county in ('013','069','123'));




select count(*) as row_count, well_id, production_year, production_month, formation_name from cogcc_dj_production_amounts group by well_id, production_year, production_month, formation_name order by row_count desc;

 row_count | well_id  | production_year | production_month |              formation_name
-----------+----------+-----------------+------------------+-------------------------------------------
         2 | 12337923 | 2014            | Mar              | NOT COMPLETED
         2 | 12332893 | 2014            | Mar              | NOT COMPLETED
         2 | 12331571 | 2014            | Jan              | NOT COMPLETED
         2 | 12330739 | 2014            | Mar              | NOT COMPLETED
         2 | 12332893 | 2014            | Feb              | NOT COMPLETED
         2 | 12331201 | 2014            | Jan              | NOT COMPLETED
         2 | 12336620 | 2014            | Jan              | NOT COMPLETED
         2 | 12331378 | 2014            | Mar              | NOT COMPLETED
         2 | 12331378 | 2014            | Jan              | NOT COMPLETED
         2 | 12331571 | 2014            | Mar              | NOT COMPLETED
         2 | 12337823 | 2014            | Feb              | NOT COMPLETED
         2 | 12330739 | 2014            | Jan              | NOT COMPLETED
         2 | 12336861 | 2014            | Feb              | NOT COMPLETED
         2 | 12329267 | 2014            | Mar              | NOT COMPLETED
         2 | 12337612 | 2014            | Jan              | NOT COMPLETED
         2 | 12336801 | 2014            | Feb              | NOT COMPLETED
         2 | 12329267 | 2014            | Jan              | NOT COMPLETED
         2 | 12338056 | 2014            | Jan              | NOT COMPLETED
         2 | 12336801 | 2014            | Mar              | NOT COMPLETED
         2 | 12332759 | 2014            | Feb              | NOT COMPLETED
         2 | 12337823 | 2014            | Mar              | NOT COMPLETED
         2 | 12332759 | 2014            | Jan              | NOT COMPLETED
         2 | 12336801 | 2014            | Jan              | NOT COMPLETED
         2 | 12332895 | 2014            | Mar              | NOT COMPLETED
         2 | 12332895 | 2014            | Jan              | NOT COMPLETED
         2 | 12329187 | 2014            | Jan              | NOT COMPLETED
         2 | 12332895 | 2014            | Feb              | NOT COMPLETED
         2 | 12336861 | 2014            | Jan              | NOT COMPLETED
         2 | 12330739 | 2014            | Feb              | NOT COMPLETED
         2 | 12336861 | 2014            | Mar              | NOT COMPLETED
         2 | 12336620 | 2014            | Feb              | NOT COMPLETED
         2 | 12337612 | 2014            | Feb              | NOT COMPLETED
         2 | 12337612 | 2014            | Mar              | NOT COMPLETED
         2 | 12332759 | 2014            | Mar              | NOT COMPLETED
         2 | 12337590 | 2014            | Mar              | NOT COMPLETED
         2 | 12331571 | 2014            | Feb              | NOT COMPLETED
         2 | 12331378 | 2014            | Feb              | NOT COMPLETED
         2 | 12336620 | 2014            | Mar              | NOT COMPLETED
         2 | 12332893 | 2014            | Jan              | NOT COMPLETED


select distinct
	p.well_id
from 
	cogcc_dj_production_amounts p 
inner join 
	(
	select 
		count(*) as row_count, 
		well_id, 
		production_year, 
		production_month, 
		formation_name 
	from 
		cogcc_dj_production_amounts 
	group by 
		well_id, 
		production_year, 
		production_month, 
		formation_name
	) cp on p.well_id = cp.well_id 
where 
	cp.row_count > 1;


update cogcc_dj_production_amounts set formation_name = 'J SAND' where id in (35541,61168,61223);
update cogcc_dj_production_amounts set formation_name = 'J SAND' where id in (59701,3386,5701);
update cogcc_dj_production_amounts set formation_name = 'J SAND' where id in (24672,32617,66740);


14 wells with NOT COMPLETED
	 well_id
	----------
	 12329187
	 12329267
	 12330739
	 12331201
	 12331378
	 12331571
	 12332759
	 12336620
	 12336861
	 12337590
	 12337612
	 12337823
	 12337923
	 12338056
	(14 rows)


select count(*) as row_count, well_id, production_year, production_month, formation_name, well_status_code, days_producing 
from cogcc_dj_production_amounts 
group by well_id, production_year, production_month, formation_name, well_status_code, days_producing  
order by row_count desc;


select count(*) as row_count, well_id, production_year, production_month, formation_name, well_status_code, days_producing, oil_bom, oil_produced, oil_sold, oil_adj, oil_eom, oil_gravity, gas_production, gas_flared, gas_used, gas_shrinkage, gas_sold, gas_btu, water_production, water_disposal_code
from cogcc_well_productions 
where prod_year = 2014 and prod_month in (1,2,3) and well_id in (select w.well_id from cogcc_wells w where w.api_county in ('013','069','123')) 
group by well_id, production_year, production_month, formation_name, well_status_code, days_producing, oil_bom, oil_produced, oil_sold, oil_adj, oil_eom, oil_gravity, gas_production, gas_flared, gas_used, gas_shrinkage, gas_sold, gas_btu, water_production, water_disposal_code
order by row_count desc;


select count(distinct(well_id, production_year, production_month, formation_name, well_status_code, days_producing, oil_bom, oil_produced, oil_sold, oil_adj, oil_eom, oil_gravity, gas_production, gas_flared, gas_used, gas_shrinkage, gas_sold, gas_btu, water_production, water_disposal_code)) from cogcc_well_productions where well_id in (select distinct well_id from cogcc_production_amounts);


create table cogcc_production_amounts_import (
	id serial primary key not null, 
	well_id integer, 
	production_year varchar(4),
	production_month varchar(3),
	formation_name varchar(50),
	sidetrack varchar(2),
	well_status_code varchar(2),
	days_producing integer,
	oil_bom varchar(20),
	oil_produced varchar(20),
	oil_sold varchar(20),
	oil_adj varchar(20),
	oil_eom varchar(20),
	oil_gravity varchar(20),
	gas_production varchar(20),
	gas_flared varchar(20),
	gas_used varchar(20),
	gas_shrinkage varchar(20),
	gas_sold varchar(20),
	gas_btu varchar(20),
	water_production varchar(20), 
	water_disposal_code varchar(1)
);


create table cogcc_production_amounts (
	id serial primary key not null, 
	well_id integer, 
	production_year varchar(4),
	production_month varchar(3),
	formation_name varchar(50),
	sidetrack varchar(2),
	well_status_code varchar(2),
	days_producing integer,
	oil_bom integer,
	oil_produced integer,
	oil_sold integer,
	oil_adj integer,
	oil_eom integer,
	oil_gravity real,
	gas_production integer,
	gas_flared integer,
	gas_used integer,
	gas_shrinkage integer,
	gas_sold integer,
	gas_btu integer,
	water_production integer, 
	water_disposal_code varchar(1), 
	prod_year smallint, 
	prod_month smallint, 
	disposition_code_id integer
);

insert into cogcc_production_amounts (well_id, production_year, production_month, formation_name, sidetrack, well_status_code, days_producing, oil_bom, oil_produced, oil_sold, oil_adj, oil_eom, oil_gravity, gas_production, gas_flared, gas_used, gas_shrinkage, gas_sold, gas_btu, water_production, water_disposal_code, prod_year, prod_month, disposition_code_id) 
select distinct well_id, production_year, production_month, formation_name, sidetrack, well_status_code, days_producing, oil_bom, oil_produced, oil_sold, oil_adj, oil_eom, oil_gravity, gas_production, gas_flared, gas_used, gas_shrinkage, gas_sold, gas_btu, water_production, water_disposal_code, prod_year, prod_month, disposition_code_id from cogcc_production_amts;


create table well_production_scrapes (
	id serial primary key not null,
	well_id integer, 
	well_status varchar(2), 
	api_county varchar(3), 
	api_sequence varchar(5), 
	is_scraped boolean not null default false, 
	scrape_status varchar(20), 
	in_use boolean not null default false
);
insert into well_production_scrapes (well_id, well_status, api_county, api_sequence) 
select well_id, facility_s, api_county, api_seq_nu 
from cogcc_well_surface_locations;


-- string to integer/real conversions

update cogcc_production_amounts set oil_bom = replace(oil_bom, ',', '') where oil_bom like '%,%';
update cogcc_production_amounts set oil_bom = null where trim(oil_bom) = '';
alter table cogcc_production_amounts alter column oil_bom type integer using oil_bom::integer;

update cogcc_production_amounts set oil_produced = replace(oil_produced, ',', '') where oil_produced like '%,%';
update cogcc_production_amounts set oil_produced = null where trim(oil_produced) = '';
alter table cogcc_production_amounts alter column oil_produced type integer using oil_produced::integer;

update cogcc_production_amounts set oil_sold = replace(oil_sold, ',', '') where oil_sold like '%,%';
update cogcc_production_amounts set oil_sold = null where trim(oil_sold) = '';
alter table cogcc_production_amounts alter column oil_sold type integer using oil_sold::integer;

update cogcc_production_amounts set oil_adj = replace(oil_adj, ',', '') where oil_adj like '%,%';
update cogcc_production_amounts set oil_adj = null where trim(oil_adj) = '';
alter table cogcc_production_amounts alter column oil_adj type integer using oil_adj::integer;

update cogcc_production_amounts set oil_eom = replace(oil_eom, ',', '') where oil_eom like '%,%';
update cogcc_production_amounts set oil_eom = null where trim(oil_eom) = '';
alter table cogcc_production_amounts alter column oil_eom type integer using oil_eom::integer;

update cogcc_production_amounts set oil_gravity = null where trim(oil_gravity) = '';
alter table cogcc_production_amounts alter column oil_gravity type real using oil_gravity::real;

update cogcc_production_amounts set gas_production = replace(gas_production, ',', '') where gas_production like '%,%';
update cogcc_production_amounts set gas_production = null where trim(gas_production) = '';
alter table cogcc_production_amounts alter column gas_production type integer using gas_production::integer;

update cogcc_production_amounts set gas_flared = replace(gas_flared, ',', '') where gas_flared like '%,%';
update cogcc_production_amounts set gas_flared = null where trim(gas_flared) = '';
alter table cogcc_production_amounts alter column gas_flared type integer using gas_flared::integer;

update cogcc_production_amounts set gas_used = replace(gas_used, ',', '') where gas_used like '%,%';
update cogcc_production_amounts set gas_used = null where trim(gas_used) = '';
alter table cogcc_production_amounts alter column gas_used type integer using gas_used::integer;

update cogcc_production_amounts set gas_shrinkage = replace(gas_shrinkage, ',', '') where gas_shrinkage like '%,%';
update cogcc_production_amounts set gas_shrinkage = null where trim(gas_shrinkage) = '';
alter table cogcc_production_amounts alter column gas_shrinkage type integer using gas_shrinkage::integer;

update cogcc_production_amounts set gas_sold = replace(gas_sold, ',', '') where gas_sold like '%,%';
update cogcc_production_amounts set gas_sold = null where trim(gas_sold) = '';
alter table cogcc_production_amounts alter column gas_sold type integer using gas_sold::integer;

update cogcc_production_amounts set gas_btu = replace(gas_btu, ',', '') where gas_btu like '%,%';
update cogcc_production_amounts set gas_btu = null where trim(gas_btu) = '';
alter table cogcc_production_amounts alter column gas_btu type integer using gas_btu::integer;

update cogcc_production_amounts set water_production = replace(water_production, ',', '') where water_production like '%,%';
update cogcc_production_amounts set water_production = null where trim(water_production) = '';
alter table cogcc_production_amounts alter column water_production type integer using water_production::integer;

alter table cogcc_production_amounts add column prod_year smallint;
update cogcc_production_amounts set prod_year = production_year::smallint;

alter table cogcc_production_amounts add column prod_month smallint;
update cogcc_production_amounts set prod_month = 1 where production_month = 'Jan';
update cogcc_production_amounts set prod_month = 2 where production_month = 'Feb';
update cogcc_production_amounts set prod_month = 3 where production_month = 'Mar';
update cogcc_production_amounts set prod_month = 4 where production_month = 'Apr';
update cogcc_production_amounts set prod_month = 5 where production_month = 'May';
update cogcc_production_amounts set prod_month = 6 where production_month = 'Jun';
update cogcc_production_amounts set prod_month = 7 where production_month = 'Jul';
update cogcc_production_amounts set prod_month = 8 where production_month = 'Aug';
update cogcc_production_amounts set prod_month = 9 where production_month = 'Sep';
update cogcc_production_amounts set prod_month = 10 where production_month = 'Oct';
update cogcc_production_amounts set prod_month = 11 where production_month = 'Nov';
update cogcc_production_amounts set prod_month = 12 where production_month = 'Dec';

alter table cogcc_production_amounts add column disposition_code_id integer;
update cogcc_production_amounts set water_disposal_code = 'C' where water_disposal_code = 'c';
update cogcc_production_amounts set water_disposal_code = 'I' where water_disposal_code = 'i';
update cogcc_production_amounts set water_disposal_code = 'M' where water_disposal_code = 'm';
update cogcc_production_amounts set water_disposal_code = 'P' where water_disposal_code = 'p';
update cogcc_production_amounts set water_disposal_code = null where trim(water_disposal_code) = '';
update cogcc_production_amounts set disposition_code_id = (select dc.id from cogcc_water_disposition_codes dc where dc.code = cogcc_production_amounts.water_disposal_code) where water_disposal_code is not null;

create index cogcc_production_amounts_prod_year_idx on cogcc_production_amounts(prod_year);
create index cogcc_production_amounts_prod_month_idx on cogcc_production_amounts(prod_month);
create index cogcc_production_amounts_well_id_idx on cogcc_production_amounts(well_id);

-- check for dupes (counts should match if no dupes)
select count(distinct(well_id, production_year, production_month, formation_name, sidetrack, well_status_code, days_producing, oil_bom, oil_produced, oil_sold, oil_adj, oil_eom, oil_gravity, gas_production, gas_flared, gas_used, gas_shrinkage, gas_sold, gas_btu, water_production, water_disposal_code)) from cogcc_production_amts;
-- 7459906
select count(*) from cogcc_production_amounts;
-- 7461109
-- 1203 dupes, dammit!  ==FIXED==




awgsrn=# update cogcc_production_amounts set oil_bom = replace(oil_bom, ',', '') where oil_bom like '%,%';
UPDATE 1767
awgsrn=# update cogcc_production_amounts set oil_bom = null where trim(oil_bom) = '';
UPDATE 3032903
awgsrn=# alter table cogcc_production_amounts alter column oil_bom type integer using oil_bom::integer;
ALTER TABLE
awgsrn=# update cogcc_production_amounts set oil_produced = replace(oil_produced, ',', '') where oil_produced like '%,%';
UPDATE 77454
awgsrn=# update cogcc_production_amounts set oil_produced = null where trim(oil_produced) = '';
UPDATE 3491919
awgsrn=# alter table cogcc_production_amounts alter column oil_produced type integer using oil_produced::integer;
ALTER TABLE
awgsrn=# update cogcc_production_amounts set oil_sold = replace(oil_sold, ',', '') where oil_sold like '%,%';
UPDATE 76798
awgsrn=# update cogcc_production_amounts set oil_sold = null where trim(oil_sold) = '';
UPDATE 4818624
awgsrn=# alter table cogcc_production_amounts alter column oil_sold type integer using oil_sold::integer;
ALTER TABLE
awgsrn=# update cogcc_production_amounts set oil_adj = replace(oil_adj, ',', '') where oil_adj like '%,%';
UPDATE 26
awgsrn=# update cogcc_production_amounts set oil_adj = null where trim(oil_adj) = '';
UPDATE 6936802
awgsrn=# alter table cogcc_production_amounts alter column oil_adj type integer using oil_adj::integer;
ALTER TABLE
awgsrn=# update cogcc_production_amounts set oil_eom = replace(oil_eom, ',', '') where oil_eom like '%,%';
UPDATE 1798
awgsrn=# update cogcc_production_amounts set oil_eom = null where trim(oil_eom) = '';
UPDATE 3008126
awgsrn=# alter table cogcc_production_amounts alter column oil_eom type integer using oil_eom::integer;
ALTER TABLE
awgsrn=# update cogcc_production_amounts set oil_gravity = null where trim(oil_gravity) = '';
UPDATE 4818386
awgsrn=# alter table cogcc_production_amounts alter column oil_gravity type real using oil_gravity::real;
ALTER TABLE
awgsrn=# update cogcc_production_amounts set gas_production = replace(gas_production, ',', '') where gas_production like '%,%';
UPDATE 3097662
awgsrn=# update cogcc_production_amounts set gas_production = null where trim(gas_production) = '';
UPDATE 1450586
awgsrn=# alter table cogcc_production_amounts alter column gas_production type integer using gas_production::integer;
ALTER TABLE
awgsrn=# update cogcc_production_amounts set gas_flared = replace(gas_flared, ',', '') where gas_flared like '%,%';
UPDATE 5525
awgsrn=# update cogcc_production_amounts set gas_flared = null where trim(gas_flared) = '';
UPDATE 7317631
awgsrn=# alter table cogcc_production_amounts alter column gas_flared type integer using gas_flared::integer;
ALTER TABLE
awgsrn=# update cogcc_production_amounts set gas_used = replace(gas_used, ',', '') where gas_used like '%,%';
UPDATE 92032
awgsrn=# update cogcc_production_amounts set gas_used = null where trim(gas_used) = '';
UPDATE 4878731
awgsrn=# alter table cogcc_production_amounts alter column gas_used type integer using gas_used::integer;
ALTER TABLE
awgsrn=# update cogcc_production_amounts set gas_shrinkage = replace(gas_shrinkage, ',', '') where gas_shrinkage like '%,%';
UPDATE 15777
awgsrn=# update cogcc_production_amounts set gas_shrinkage = null where trim(gas_shrinkage) = '';
UPDATE 7118348
awgsrn=# alter table cogcc_production_amounts alter column gas_shrinkage type integer using gas_shrinkage::integer;
ALTER TABLE
awgsrn=# update cogcc_production_amounts set gas_sold = replace(gas_sold, ',', '') where gas_sold like '%,%';
UPDATE 2989199
awgsrn=# update cogcc_production_amounts set gas_sold = null where trim(gas_sold) = '';
UPDATE 1623852
awgsrn=# alter table cogcc_production_amounts alter column gas_sold type integer using gas_sold::integer;
ALTER TABLE
awgsrn=# update cogcc_production_amounts set gas_btu = replace(gas_btu, ',', '') where gas_btu like '%,%';
UPDATE 4759682
awgsrn=# update cogcc_production_amounts set gas_btu = null where trim(gas_btu) = '';
UPDATE 1623821
awgsrn=# alter table cogcc_production_amounts alter column gas_btu type integer using gas_btu::integer;
ALTER TABLE
awgsrn=# update cogcc_production_amounts set water_production = replace(water_production, ',', '') where water_production like '%,%';
UPDATE 623130
awgsrn=# update cogcc_production_amounts set water_production = null where trim(water_production) = '';
UPDATE 3439311
awgsrn=# alter table cogcc_production_amounts alter column water_production type integer using water_production::integer;
ALTER TABLE

select count(*)
from cogcc_production_amounts p 
inner join cogcc_well_surface_locations w on p.well_id = w.well_id 
where p.prod_year = 2014 and p.prod_month < 7 and w.api_county in ('013','069','123');

COPY(
select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as current_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, w.utm_x, w.utm_y, p.production_year, p.production_month, p.formation_name, p.sidetrack, p.well_status_code as production_status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code 
from cogcc_production_amounts p 
inner join cogcc_well_surface_locations w on p.well_id = w.well_id 
where p.prod_year = 2014 and p.prod_month < 7 and w.api_county in ('013','069','123')
-- and (p.oil_bom is not null or p.oil_produced is not null or p.oil_sold is not null or p.oil_adj is not null or p.oil_eom is not null or p.oil_gravity is not null or p.gas_production is not null or p.gas_flared is not null or p.gas_used is not null or p.gas_shrinkage is not null or p.gas_sold is not null or p.gas_btu is not null or p.water_production is not null)
order by w.attrib_1, p.prod_month, p.formation_name
) TO '/Users/troyburke/Data/cogcc/dj_formation_production_2014.csv' WITH CSV HEADER;

COPY (select code, description from cogcc_well_status) TO '/Users/troyburke/Data/cogcc/well_status_codes.csv' WITH CSV HEADER;
COPY (select code, description from cogcc_water_disposition_codes) TO '/Users/troyburke/Data/cogcc/water_disposition_codes.csv' WITH CSV HEADER;



select count(*) from cogcc_production_amounts where prod_year = 2014 and prod_month = 1 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123'));
select count(*) from cogcc_production_amounts where prod_year = 2014 and prod_month = 2 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123'));
select count(*) from cogcc_production_amounts where prod_year = 2014 and prod_month = 3 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123'));
select count(*) from cogcc_production_amounts where prod_year = 2014 and prod_month = 4 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123'));
select count(*) from cogcc_production_amounts where prod_year = 2014 and prod_month = 5 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123'));
select count(*) from cogcc_production_amounts where prod_year = 2014 and prod_month = 6 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123'));

Row counts by month
 18530 <~ suspicious, but verified by two scrapes
 24968
 25437
 23664
 21839
 15865 <~ okay, reporting incomplete

Total row count
130303

select count(distinct(well_id)) from cogcc_production_amounts where prod_year = 2014 and prod_month < 7 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123'));
 count
-------
 21638

select count(distinct(well_id)) from cogcc_production_amounts where prod_year = 2014 and prod_month < 7 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123')) and (oil_bom is not null or oil_produced is not null or oil_sold is not null or oil_adj is not null or oil_eom is not null or oil_gravity is not null or gas_production is not null or gas_flared is not null or gas_used is not null or gas_shrinkage is not null or gas_sold is not null or gas_btu is not null or water_production is not null);
 count
-------
 20522


select count(distinct(well_id)) from cogcc_production_amounts where prod_year = 2014 and prod_month = 1 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123')) and (oil_bom is not null or oil_produced is not null or oil_sold is not null or oil_adj is not null or oil_eom is not null or oil_gravity is not null or gas_production is not null or gas_flared is not null or gas_used is not null or gas_shrinkage is not null or gas_sold is not null or gas_btu is not null or water_production is not null);
select count(distinct(well_id)) from cogcc_production_amounts where prod_year = 2014 and prod_month = 2 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123')) and (oil_bom is not null or oil_produced is not null or oil_sold is not null or oil_adj is not null or oil_eom is not null or oil_gravity is not null or gas_production is not null or gas_flared is not null or gas_used is not null or gas_shrinkage is not null or gas_sold is not null or gas_btu is not null or water_production is not null);
select count(distinct(well_id)) from cogcc_production_amounts where prod_year = 2014 and prod_month = 3 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123')) and (oil_bom is not null or oil_produced is not null or oil_sold is not null or oil_adj is not null or oil_eom is not null or oil_gravity is not null or gas_production is not null or gas_flared is not null or gas_used is not null or gas_shrinkage is not null or gas_sold is not null or gas_btu is not null or water_production is not null);
select count(distinct(well_id)) from cogcc_production_amounts where prod_year = 2014 and prod_month = 4 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123')) and (oil_bom is not null or oil_produced is not null or oil_sold is not null or oil_adj is not null or oil_eom is not null or oil_gravity is not null or gas_production is not null or gas_flared is not null or gas_used is not null or gas_shrinkage is not null or gas_sold is not null or gas_btu is not null or water_production is not null);
select count(distinct(well_id)) from cogcc_production_amounts where prod_year = 2014 and prod_month = 5 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123')) and (oil_bom is not null or oil_produced is not null or oil_sold is not null or oil_adj is not null or oil_eom is not null or oil_gravity is not null or gas_production is not null or gas_flared is not null or gas_used is not null or gas_shrinkage is not null or gas_sold is not null or gas_btu is not null or water_production is not null);
select count(distinct(well_id)) from cogcc_production_amounts where prod_year = 2014 and prod_month = 6 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123')) and (oil_bom is not null or oil_produced is not null or oil_sold is not null or oil_adj is not null or oil_eom is not null or oil_gravity is not null or gas_production is not null or gas_flared is not null or gas_used is not null or gas_shrinkage is not null or gas_sold is not null or gas_btu is not null or water_production is not null);
select count(distinct(well_id)) from cogcc_production_amounts where prod_year = 2014 and prod_month = 7 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123')) and (oil_bom is not null or oil_produced is not null or oil_sold is not null or oil_adj is not null or oil_eom is not null or oil_gravity is not null or gas_production is not null or gas_flared is not null or gas_used is not null or gas_shrinkage is not null or gas_sold is not null or gas_btu is not null or water_production is not null);
select count(distinct(well_id)) from cogcc_production_amounts where prod_year = 2013 and prod_month = 11 and well_id in (select well_id from cogcc_well_surface_locations where api_county in ('013','069','123')) and (oil_bom is not null or oil_produced is not null or oil_sold is not null or oil_adj is not null or oil_eom is not null or oil_gravity is not null or gas_production is not null or gas_flared is not null or gas_used is not null or gas_shrinkage is not null or gas_sold is not null or gas_btu is not null or water_production is not null);







COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, 
	coalesce(sum(case p.prod_month when 1 then p.oil_bom else 0 end),0) as oil_bom_2014_01, 
	coalesce(sum(case p.prod_month when 2 then p.oil_bom else 0 end),0) as oil_bom_2014_02, 
	coalesce(sum(case p.prod_month when 3 then p.oil_bom else 0 end),0) as oil_bom_2014_03, 
	coalesce(sum(case p.prod_month when 4 then p.oil_bom else 0 end),0) as oil_bom_2014_04, 
	coalesce(sum(case p.prod_month when 5 then p.oil_bom else 0 end),0) as oil_bom_2014_05, 
	coalesce(sum(case p.prod_month when 6 then p.oil_bom else 0 end),0) as oil_bom_2014_06,
	coalesce(sum(case p.prod_month when 1 then p.oil_produced else 0 end),0) as oil_produced_2014_01, 
	coalesce(sum(case p.prod_month when 2 then p.oil_produced else 0 end),0) as oil_produced_2014_02, 
	coalesce(sum(case p.prod_month when 3 then p.oil_produced else 0 end),0) as oil_produced_2014_03, 
	coalesce(sum(case p.prod_month when 4 then p.oil_produced else 0 end),0) as oil_produced_2014_04, 
	coalesce(sum(case p.prod_month when 5 then p.oil_produced else 0 end),0) as oil_produced_2014_05, 
	coalesce(sum(case p.prod_month when 6 then p.oil_produced else 0 end),0) as oil_produced_2014_06, 
	coalesce(sum(case p.prod_month when 1 then p.oil_sold else 0 end),0) as oil_sold_2014_01, 
	coalesce(sum(case p.prod_month when 2 then p.oil_sold else 0 end),0) as oil_sold_2014_02, 
	coalesce(sum(case p.prod_month when 3 then p.oil_sold else 0 end),0) as oil_sold_2014_03, 
	coalesce(sum(case p.prod_month when 4 then p.oil_sold else 0 end),0) as oil_sold_2014_04, 
	coalesce(sum(case p.prod_month when 5 then p.oil_sold else 0 end),0) as oil_sold_2014_05, 
	coalesce(sum(case p.prod_month when 6 then p.oil_sold else 0 end),0) as oil_sold_2014_06,
	coalesce(sum(case p.prod_month when 1 then p.oil_adj else 0 end),0) as oil_adj_2014_01, 
	coalesce(sum(case p.prod_month when 2 then p.oil_adj else 0 end),0) as oil_adj_2014_02, 
	coalesce(sum(case p.prod_month when 3 then p.oil_adj else 0 end),0) as oil_adj_2014_03, 
	coalesce(sum(case p.prod_month when 4 then p.oil_adj else 0 end),0) as oil_adj_2014_04, 
	coalesce(sum(case p.prod_month when 5 then p.oil_adj else 0 end),0) as oil_adj_2014_05, 
	coalesce(sum(case p.prod_month when 6 then p.oil_adj else 0 end),0) as oil_adj_2014_06,
	coalesce(sum(case p.prod_month when 1 then p.oil_eom else 0 end),0) as oil_eom_2014_01, 
	coalesce(sum(case p.prod_month when 2 then p.oil_eom else 0 end),0) as oil_eom_2014_02, 
	coalesce(sum(case p.prod_month when 3 then p.oil_eom else 0 end),0) as oil_eom_2014_03, 
	coalesce(sum(case p.prod_month when 4 then p.oil_eom else 0 end),0) as oil_eom_2014_04, 
	coalesce(sum(case p.prod_month when 5 then p.oil_eom else 0 end),0) as oil_eom_2014_05, 
	coalesce(sum(case p.prod_month when 6 then p.oil_eom else 0 end),0) as oil_eom_2014_06,
	coalesce(sum(case p.prod_month when 1 then p.gas_production else 0 end),0) as gas_production_2014_01, 
	coalesce(sum(case p.prod_month when 2 then p.gas_production else 0 end),0) as gas_production_2014_02, 
	coalesce(sum(case p.prod_month when 3 then p.gas_production else 0 end),0) as gas_production_2014_03, 
	coalesce(sum(case p.prod_month when 4 then p.gas_production else 0 end),0) as gas_production_2014_04, 
	coalesce(sum(case p.prod_month when 5 then p.gas_production else 0 end),0) as gas_production_2014_05, 
	coalesce(sum(case p.prod_month when 6 then p.gas_production else 0 end),0) as gas_production_2014_06, 
	coalesce(sum(case p.prod_month when 1 then p.gas_flared else 0 end),0) as gas_flared_2014_01, 
	coalesce(sum(case p.prod_month when 2 then p.gas_flared else 0 end),0) as gas_flared_2014_02, 
	coalesce(sum(case p.prod_month when 3 then p.gas_flared else 0 end),0) as gas_flared_2014_03, 
	coalesce(sum(case p.prod_month when 4 then p.gas_flared else 0 end),0) as gas_flared_2014_04, 
	coalesce(sum(case p.prod_month when 5 then p.gas_flared else 0 end),0) as gas_flared_2014_05, 
	coalesce(sum(case p.prod_month when 6 then p.gas_flared else 0 end),0) as gas_flared_2014_06, 
	coalesce(sum(case p.prod_month when 1 then p.gas_used else 0 end),0) as gas_used_2014_01, 
	coalesce(sum(case p.prod_month when 2 then p.gas_used else 0 end),0) as gas_used_2014_02, 
	coalesce(sum(case p.prod_month when 3 then p.gas_used else 0 end),0) as gas_used_2014_03, 
	coalesce(sum(case p.prod_month when 4 then p.gas_used else 0 end),0) as gas_used_2014_04, 
	coalesce(sum(case p.prod_month when 5 then p.gas_used else 0 end),0) as gas_used_2014_05, 
	coalesce(sum(case p.prod_month when 6 then p.gas_used else 0 end),0) as gas_used_2014_06, 
	coalesce(sum(case p.prod_month when 1 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_01, 
	coalesce(sum(case p.prod_month when 2 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_02, 
	coalesce(sum(case p.prod_month when 3 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_03, 
	coalesce(sum(case p.prod_month when 4 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_04, 
	coalesce(sum(case p.prod_month when 5 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_05, 
	coalesce(sum(case p.prod_month when 6 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_06, 
	coalesce(sum(case p.prod_month when 1 then p.gas_sold else 0 end),0) as gas_sold_2014_01, 
	coalesce(sum(case p.prod_month when 2 then p.gas_sold else 0 end),0) as gas_sold_2014_02, 
	coalesce(sum(case p.prod_month when 3 then p.gas_sold else 0 end),0) as gas_sold_2014_03, 
	coalesce(sum(case p.prod_month when 4 then p.gas_sold else 0 end),0) as gas_sold_2014_04, 
	coalesce(sum(case p.prod_month when 5 then p.gas_sold else 0 end),0) as gas_sold_2014_05, 
	coalesce(sum(case p.prod_month when 6 then p.gas_sold else 0 end),0) as gas_sold_2014_06, 
	coalesce(sum(case p.prod_month when 1 then p.gas_btu else 0 end),0) as gas_btu_2014_01, 
	coalesce(sum(case p.prod_month when 2 then p.gas_btu else 0 end),0) as gas_btu_2014_02, 
	coalesce(sum(case p.prod_month when 3 then p.gas_btu else 0 end),0) as gas_btu_2014_03, 
	coalesce(sum(case p.prod_month when 4 then p.gas_btu else 0 end),0) as gas_btu_2014_04, 
	coalesce(sum(case p.prod_month when 5 then p.gas_btu else 0 end),0) as gas_btu_2014_05, 
	coalesce(sum(case p.prod_month when 6 then p.gas_btu else 0 end),0) as gas_btu_2014_06, 
	coalesce(sum(case p.prod_month when 1 then p.water_production else 0 end),0) as produced_water_2014_01, 
	coalesce(sum(case p.prod_month when 2 then p.water_production else 0 end),0) as produced_water_2014_02, 
	coalesce(sum(case p.prod_month when 3 then p.water_production else 0 end),0) as produced_water_2014_03, 
	coalesce(sum(case p.prod_month when 4 then p.water_production else 0 end),0) as produced_water_2014_04, 
	coalesce(sum(case p.prod_month when 5 then p.water_production else 0 end),0) as produced_water_2014_05, 
	coalesce(sum(case p.prod_month when 6 then p.water_production else 0 end),0) as produced_water_2014_06 
from cogcc_production_amounts p 
inner join cogcc_well_surface_locations w on p.well_id = w.well_id 
where p.prod_year = 2014 and p.prod_month < 7 and w.api_county = '123' 
group by  w.attrib_1, w.api_county, w.api_seq_nu, w.attrib_3, w.facility_s, w.locationid, w.attrib_2, w.operator_n, w.field_name, w.field_code, w.lat, w.long
order by w.attrib_1) TO '/Users/troyburke/Data/cogcc/2014_production_all.csv' WITH CSV HEADER;


COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, coalesce(sum(case p.prod_month when 1 then p.oil_bom else 0 end),0) as oil_bom_2014_01, coalesce(sum(case p.prod_month when 2 then p.oil_bom else 0 end),0) as oil_bom_2014_02, coalesce(sum(case p.prod_month when 3 then p.oil_bom else 0 end),0) as oil_bom_2014_03, coalesce(sum(case p.prod_month when 4 then p.oil_bom else 0 end),0) as oil_bom_2014_04, coalesce(sum(case p.prod_month when 5 then p.oil_bom else 0 end),0) as oil_bom_2014_05, coalesce(sum(case p.prod_month when 6 then p.oil_bom else 0 end),0) as oil_bom_2014_06, coalesce(sum(case p.prod_month when 1 then p.oil_produced else 0 end),0) as oil_produced_2014_01, coalesce(sum(case p.prod_month when 2 then p.oil_produced else 0 end),0) as oil_produced_2014_02, coalesce(sum(case p.prod_month when 3 then p.oil_produced else 0 end),0) as oil_produced_2014_03, coalesce(sum(case p.prod_month when 4 then p.oil_produced else 0 end),0) as oil_produced_2014_04, coalesce(sum(case p.prod_month when 5 then p.oil_produced else 0 end),0) as oil_produced_2014_05, coalesce(sum(case p.prod_month when 6 then p.oil_produced else 0 end),0) as oil_produced_2014_06, coalesce(sum(case p.prod_month when 1 then p.oil_sold else 0 end),0) as oil_sold_2014_01, coalesce(sum(case p.prod_month when 2 then p.oil_sold else 0 end),0) as oil_sold_2014_02, coalesce(sum(case p.prod_month when 3 then p.oil_sold else 0 end),0) as oil_sold_2014_03, coalesce(sum(case p.prod_month when 4 then p.oil_sold else 0 end),0) as oil_sold_2014_04, coalesce(sum(case p.prod_month when 5 then p.oil_sold else 0 end),0) as oil_sold_2014_05, coalesce(sum(case p.prod_month when 6 then p.oil_sold else 0 end),0) as oil_sold_2014_06, coalesce(sum(case p.prod_month when 1 then p.oil_adj else 0 end),0) as oil_adj_2014_01, coalesce(sum(case p.prod_month when 2 then p.oil_adj else 0 end),0) as oil_adj_2014_02, coalesce(sum(case p.prod_month when 3 then p.oil_adj else 0 end),0) as oil_adj_2014_03, coalesce(sum(case p.prod_month when 4 then p.oil_adj else 0 end),0) as oil_adj_2014_04, coalesce(sum(case p.prod_month when 5 then p.oil_adj else 0 end),0) as oil_adj_2014_05, coalesce(sum(case p.prod_month when 6 then p.oil_adj else 0 end),0) as oil_adj_2014_06, coalesce(sum(case p.prod_month when 1 then p.oil_eom else 0 end),0) as oil_eom_2014_01, coalesce(sum(case p.prod_month when 2 then p.oil_eom else 0 end),0) as oil_eom_2014_02, coalesce(sum(case p.prod_month when 3 then p.oil_eom else 0 end),0) as oil_eom_2014_03, coalesce(sum(case p.prod_month when 4 then p.oil_eom else 0 end),0) as oil_eom_2014_04, coalesce(sum(case p.prod_month when 5 then p.oil_eom else 0 end),0) as oil_eom_2014_05, coalesce(sum(case p.prod_month when 6 then p.oil_eom else 0 end),0) as oil_eom_2014_06, coalesce(sum(case p.prod_month when 1 then p.gas_production else 0 end),0) as gas_production_2014_01, coalesce(sum(case p.prod_month when 2 then p.gas_production else 0 end),0) as gas_production_2014_02, coalesce(sum(case p.prod_month when 3 then p.gas_production else 0 end),0) as gas_production_2014_03, coalesce(sum(case p.prod_month when 4 then p.gas_production else 0 end),0) as gas_production_2014_04, coalesce(sum(case p.prod_month when 5 then p.gas_production else 0 end),0) as gas_production_2014_05, coalesce(sum(case p.prod_month when 6 then p.gas_production else 0 end),0) as gas_production_2014_06, coalesce(sum(case p.prod_month when 1 then p.gas_flared else 0 end),0) as gas_flared_2014_01, coalesce(sum(case p.prod_month when 2 then p.gas_flared else 0 end),0) as gas_flared_2014_02, coalesce(sum(case p.prod_month when 3 then p.gas_flared else 0 end),0) as gas_flared_2014_03, coalesce(sum(case p.prod_month when 4 then p.gas_flared else 0 end),0) as gas_flared_2014_04, coalesce(sum(case p.prod_month when 5 then p.gas_flared else 0 end),0) as gas_flared_2014_05, coalesce(sum(case p.prod_month when 6 then p.gas_flared else 0 end),0) as gas_flared_2014_06, coalesce(sum(case p.prod_month when 1 then p.gas_used else 0 end),0) as gas_used_2014_01, coalesce(sum(case p.prod_month when 2 then p.gas_used else 0 end),0) as gas_used_2014_02, coalesce(sum(case p.prod_month when 3 then p.gas_used else 0 end),0) as gas_used_2014_03, coalesce(sum(case p.prod_month when 4 then p.gas_used else 0 end),0) as gas_used_2014_04, coalesce(sum(case p.prod_month when 5 then p.gas_used else 0 end),0) as gas_used_2014_05, coalesce(sum(case p.prod_month when 6 then p.gas_used else 0 end),0) as gas_used_2014_06, coalesce(sum(case p.prod_month when 1 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_01, coalesce(sum(case p.prod_month when 2 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_02, coalesce(sum(case p.prod_month when 3 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_03, coalesce(sum(case p.prod_month when 4 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_04, coalesce(sum(case p.prod_month when 5 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_05, coalesce(sum(case p.prod_month when 6 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_06, coalesce(sum(case p.prod_month when 1 then p.gas_sold else 0 end),0) as gas_sold_2014_01, coalesce(sum(case p.prod_month when 2 then p.gas_sold else 0 end),0) as gas_sold_2014_02, coalesce(sum(case p.prod_month when 3 then p.gas_sold else 0 end),0) as gas_sold_2014_03, coalesce(sum(case p.prod_month when 4 then p.gas_sold else 0 end),0) as gas_sold_2014_04, coalesce(sum(case p.prod_month when 5 then p.gas_sold else 0 end),0) as gas_sold_2014_05, coalesce(sum(case p.prod_month when 6 then p.gas_sold else 0 end),0) as gas_sold_2014_06, coalesce(sum(case p.prod_month when 1 then p.gas_btu else 0 end),0) as gas_btu_2014_01, coalesce(sum(case p.prod_month when 2 then p.gas_btu else 0 end),0) as gas_btu_2014_02, coalesce(sum(case p.prod_month when 3 then p.gas_btu else 0 end),0) as gas_btu_2014_03, coalesce(sum(case p.prod_month when 4 then p.gas_btu else 0 end),0) as gas_btu_2014_04, coalesce(sum(case p.prod_month when 5 then p.gas_btu else 0 end),0) as gas_btu_2014_05, coalesce(sum(case p.prod_month when 6 then p.gas_btu else 0 end),0) as gas_btu_2014_06, coalesce(sum(case p.prod_month when 1 then p.water_production else 0 end),0) as produced_water_2014_01, coalesce(sum(case p.prod_month when 2 then p.water_production else 0 end),0) as produced_water_2014_02, coalesce(sum(case p.prod_month when 3 then p.water_production else 0 end),0) as produced_water_2014_03, coalesce(sum(case p.prod_month when 4 then p.water_production else 0 end),0) as produced_water_2014_04, coalesce(sum(case p.prod_month when 5 then p.water_production else 0 end),0) as produced_water_2014_05,	coalesce(sum(case p.prod_month when 6 then p.water_production else 0 end),0) as produced_water_2014_06 from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2014 and p.prod_month < 7 group by  w.attrib_1, w.api_county, w.api_seq_nu, w.attrib_3, w.facility_s, w.locationid, w.attrib_2, w.operator_n, w.field_name, w.field_code, w.lat, w.long order by w.attrib_1) TO '/Users/troyburke/Data/cogcc/2014_production_all.csv' WITH CSV HEADER;


COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.days_producing, p.water_disposal_code, coalesce(sum(case p.prod_month when 1 then p.oil_bom else 0 end),0) as oil_bom_2014_01, coalesce(sum(case p.prod_month when 2 then p.oil_bom else 0 end),0) as oil_bom_2014_02, coalesce(sum(case p.prod_month when 3 then p.oil_bom else 0 end),0) as oil_bom_2014_03, coalesce(sum(case p.prod_month when 4 then p.oil_bom else 0 end),0) as oil_bom_2014_04, coalesce(sum(case p.prod_month when 5 then p.oil_bom else 0 end),0) as oil_bom_2014_05, coalesce(sum(case p.prod_month when 6 then p.oil_bom else 0 end),0) as oil_bom_2014_06, coalesce(sum(case p.prod_month when 1 then p.oil_produced else 0 end),0) as oil_produced_2014_01, coalesce(sum(case p.prod_month when 2 then p.oil_produced else 0 end),0) as oil_produced_2014_02, coalesce(sum(case p.prod_month when 3 then p.oil_produced else 0 end),0) as oil_produced_2014_03, coalesce(sum(case p.prod_month when 4 then p.oil_produced else 0 end),0) as oil_produced_2014_04, coalesce(sum(case p.prod_month when 5 then p.oil_produced else 0 end),0) as oil_produced_2014_05, coalesce(sum(case p.prod_month when 6 then p.oil_produced else 0 end),0) as oil_produced_2014_06, coalesce(sum(case p.prod_month when 1 then p.oil_sold else 0 end),0) as oil_sold_2014_01, coalesce(sum(case p.prod_month when 2 then p.oil_sold else 0 end),0) as oil_sold_2014_02, coalesce(sum(case p.prod_month when 3 then p.oil_sold else 0 end),0) as oil_sold_2014_03, coalesce(sum(case p.prod_month when 4 then p.oil_sold else 0 end),0) as oil_sold_2014_04, coalesce(sum(case p.prod_month when 5 then p.oil_sold else 0 end),0) as oil_sold_2014_05, coalesce(sum(case p.prod_month when 6 then p.oil_sold else 0 end),0) as oil_sold_2014_06, coalesce(sum(case p.prod_month when 1 then p.oil_adj else 0 end),0) as oil_adj_2014_01, coalesce(sum(case p.prod_month when 2 then p.oil_adj else 0 end),0) as oil_adj_2014_02, coalesce(sum(case p.prod_month when 3 then p.oil_adj else 0 end),0) as oil_adj_2014_03, coalesce(sum(case p.prod_month when 4 then p.oil_adj else 0 end),0) as oil_adj_2014_04, coalesce(sum(case p.prod_month when 5 then p.oil_adj else 0 end),0) as oil_adj_2014_05, coalesce(sum(case p.prod_month when 6 then p.oil_adj else 0 end),0) as oil_adj_2014_06, coalesce(sum(case p.prod_month when 1 then p.oil_eom else 0 end),0) as oil_eom_2014_01, coalesce(sum(case p.prod_month when 2 then p.oil_eom else 0 end),0) as oil_eom_2014_02, coalesce(sum(case p.prod_month when 3 then p.oil_eom else 0 end),0) as oil_eom_2014_03, coalesce(sum(case p.prod_month when 4 then p.oil_eom else 0 end),0) as oil_eom_2014_04, coalesce(sum(case p.prod_month when 5 then p.oil_eom else 0 end),0) as oil_eom_2014_05, coalesce(sum(case p.prod_month when 6 then p.oil_eom else 0 end),0) as oil_eom_2014_06, coalesce(sum(case p.prod_month when 1 then p.gas_production else 0 end),0) as gas_production_2014_01, coalesce(sum(case p.prod_month when 2 then p.gas_production else 0 end),0) as gas_production_2014_02, coalesce(sum(case p.prod_month when 3 then p.gas_production else 0 end),0) as gas_production_2014_03, coalesce(sum(case p.prod_month when 4 then p.gas_production else 0 end),0) as gas_production_2014_04, coalesce(sum(case p.prod_month when 5 then p.gas_production else 0 end),0) as gas_production_2014_05, coalesce(sum(case p.prod_month when 6 then p.gas_production else 0 end),0) as gas_production_2014_06, coalesce(sum(case p.prod_month when 1 then p.gas_flared else 0 end),0) as gas_flared_2014_01, coalesce(sum(case p.prod_month when 2 then p.gas_flared else 0 end),0) as gas_flared_2014_02, coalesce(sum(case p.prod_month when 3 then p.gas_flared else 0 end),0) as gas_flared_2014_03, coalesce(sum(case p.prod_month when 4 then p.gas_flared else 0 end),0) as gas_flared_2014_04, coalesce(sum(case p.prod_month when 5 then p.gas_flared else 0 end),0) as gas_flared_2014_05, coalesce(sum(case p.prod_month when 6 then p.gas_flared else 0 end),0) as gas_flared_2014_06, coalesce(sum(case p.prod_month when 1 then p.gas_used else 0 end),0) as gas_used_2014_01, coalesce(sum(case p.prod_month when 2 then p.gas_used else 0 end),0) as gas_used_2014_02, coalesce(sum(case p.prod_month when 3 then p.gas_used else 0 end),0) as gas_used_2014_03, coalesce(sum(case p.prod_month when 4 then p.gas_used else 0 end),0) as gas_used_2014_04, coalesce(sum(case p.prod_month when 5 then p.gas_used else 0 end),0) as gas_used_2014_05, coalesce(sum(case p.prod_month when 6 then p.gas_used else 0 end),0) as gas_used_2014_06, coalesce(sum(case p.prod_month when 1 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_01, coalesce(sum(case p.prod_month when 2 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_02, coalesce(sum(case p.prod_month when 3 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_03, coalesce(sum(case p.prod_month when 4 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_04, coalesce(sum(case p.prod_month when 5 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_05, coalesce(sum(case p.prod_month when 6 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014_06, coalesce(sum(case p.prod_month when 1 then p.gas_sold else 0 end),0) as gas_sold_2014_01, coalesce(sum(case p.prod_month when 2 then p.gas_sold else 0 end),0) as gas_sold_2014_02, coalesce(sum(case p.prod_month when 3 then p.gas_sold else 0 end),0) as gas_sold_2014_03, coalesce(sum(case p.prod_month when 4 then p.gas_sold else 0 end),0) as gas_sold_2014_04, coalesce(sum(case p.prod_month when 5 then p.gas_sold else 0 end),0) as gas_sold_2014_05, coalesce(sum(case p.prod_month when 6 then p.gas_sold else 0 end),0) as gas_sold_2014_06, coalesce(sum(case p.prod_month when 1 then p.gas_btu else 0 end),0) as gas_btu_2014_01, coalesce(sum(case p.prod_month when 2 then p.gas_btu else 0 end),0) as gas_btu_2014_02, coalesce(sum(case p.prod_month when 3 then p.gas_btu else 0 end),0) as gas_btu_2014_03, coalesce(sum(case p.prod_month when 4 then p.gas_btu else 0 end),0) as gas_btu_2014_04, coalesce(sum(case p.prod_month when 5 then p.gas_btu else 0 end),0) as gas_btu_2014_05, coalesce(sum(case p.prod_month when 6 then p.gas_btu else 0 end),0) as gas_btu_2014_06, coalesce(sum(case p.prod_month when 1 then p.water_production else 0 end),0) as produced_water_2014_01, coalesce(sum(case p.prod_month when 2 then p.water_production else 0 end),0) as produced_water_2014_02, coalesce(sum(case p.prod_month when 3 then p.water_production else 0 end),0) as produced_water_2014_03, coalesce(sum(case p.prod_month when 4 then p.water_production else 0 end),0) as produced_water_2014_04, coalesce(sum(case p.prod_month when 5 then p.water_production else 0 end),0) as produced_water_2014_05,	coalesce(sum(case p.prod_month when 6 then p.water_production else 0 end),0) as produced_water_2014_06 from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2014 and p.prod_month < 7 group by  w.attrib_1, w.api_county, w.api_seq_nu, w.attrib_3, w.facility_s, w.locationid, w.attrib_2, w.operator_n, w.field_name, w.field_code, w.lat, w.long, p.days_producing, p.water_disposal_code order by w.attrib_1) TO '/Users/troyburke/Data/cogcc/2014_production_all_with_days_and_disposition.csv' WITH CSV HEADER;


-- SAN JUAN BASIN QUERIES
select distinct(api_county) from cogcc_well_surface_locations where ST_Within(geom,(select gb.geom_nad83 from gas_basins gb where gb.name ='SAN JUAN'));
-- Counties => Archuleta, La Plata ('007','067')

COPY(
select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as current_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, w.utm_x, w.utm_y, p.production_year, p.production_month, p.formation_name, p.sidetrack, p.well_status_code as production_status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code 
from cogcc_production_amounts p 
inner join cogcc_well_surface_locations w on p.well_id = w.well_id 
where p.prod_year = 2014 and p.prod_month < 7 and w.api_county in ('007','067')
-- and (p.oil_bom is not null or p.oil_produced is not null or p.oil_sold is not null or p.oil_adj is not null or p.oil_eom is not null or p.oil_gravity is not null or p.gas_production is not null or p.gas_flared is not null or p.gas_used is not null or p.gas_shrinkage is not null or p.gas_sold is not null or p.gas_btu is not null or p.water_production is not null)
order by w.attrib_1, p.prod_month, p.formation_name
) TO '/Users/troyburke/Data/cogcc/san_juan_formation_production_2014.csv' WITH CSV HEADER;

COPY(
select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as current_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, w.utm_x, w.utm_y, p.production_year, p.production_month, p.formation_name, p.sidetrack, p.well_status_code as production_status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code 
from cogcc_production_amounts p 
inner join cogcc_well_surface_locations w on p.well_id = w.well_id 
where p.prod_year = 2014 and p.prod_month < 7 and w.api_county in ('007','067') and (p.oil_bom is not null or p.oil_produced is not null or p.oil_sold is not null or p.oil_adj is not null or p.oil_eom is not null or p.oil_gravity is not null or p.gas_production is not null or p.gas_flared is not null or p.gas_used is not null or p.gas_shrinkage is not null or p.gas_sold is not null or p.gas_btu is not null or p.water_production is not null)
order by w.attrib_1, p.prod_month, p.formation_name
) TO '/Users/troyburke/Data/cogcc/san_juan_formation_production_2014_null_rows_removed.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2014 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2014.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2013 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2013.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2012 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2012.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2011 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2011.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2010 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2010.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2009 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2009.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2008 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2008.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2007 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2007.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2006 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2006.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2005 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2005.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2004 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2004.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2003 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2003.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2002 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2002.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2001 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2001.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 2000 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_2000.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, w.api_county, w.api_seq_nu as api_sequence, w.attrib_3 as well_number_name, w.facility_s as well_status_code, w.locationid as location_id, w.attrib_2 as operator_name, w.operator_n as operator_number, w.field_name, w.field_code, w.lat as latitude, w.long as longitude, p.prod_year as year, p.production_month as month, p.formation_name as formation, p.sidetrack, p.well_status_code as status_code, p.days_producing, p.oil_bom, p.oil_produced, p.oil_sold, p.oil_adj, p.oil_eom, p.oil_gravity, p.gas_production, p.gas_flared, p.gas_used, p.gas_shrinkage, p.gas_sold, p.gas_btu, p.water_production, p.water_disposal_code from cogcc_production_amounts p inner join cogcc_well_surface_locations w on p.well_id = w.well_id where p.prod_year = 1999 and w.api_county in ('007','067') order by w.attrib_1, p.prod_month, p.formation_name) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_dump_1999.csv' WITH CSV HEADER;

COPY (
select 
	w.attrib_1 as well_api_number, 
	w.api_county, 
	w.api_seq_nu as api_sequence, 
	w.attrib_3 as well_number_name, 
	w.facility_s as well_status_code, 
	w.locationid as location_id, 
	w.attrib_2 as operator_name, 
	w.operator_n as operator_number, 
	w.field_name, 
	w.field_code, 
	w.lat as latitude, 
	w.long as longitude, 
	coalesce(sum(case p.prod_year when 1999 then p.oil_bom else 0 end),0) as oil_bom_1999, 
	coalesce(sum(case p.prod_year when 2000 then p.oil_bom else 0 end),0) as oil_bom_2000, 
	coalesce(sum(case p.prod_year when 2001 then p.oil_bom else 0 end),0) as oil_bom_2001, 
	coalesce(sum(case p.prod_year when 2002 then p.oil_bom else 0 end),0) as oil_bom_2002, 
	coalesce(sum(case p.prod_year when 2003 then p.oil_bom else 0 end),0) as oil_bom_2003, 
	coalesce(sum(case p.prod_year when 2004 then p.oil_bom else 0 end),0) as oil_bom_2004,
	coalesce(sum(case p.prod_year when 2005 then p.oil_bom else 0 end),0) as oil_bom_2005, 
	coalesce(sum(case p.prod_year when 2006 then p.oil_bom else 0 end),0) as oil_bom_2006, 
	coalesce(sum(case p.prod_year when 2007 then p.oil_bom else 0 end),0) as oil_bom_2007, 
	coalesce(sum(case p.prod_year when 2008 then p.oil_bom else 0 end),0) as oil_bom_2008, 
	coalesce(sum(case p.prod_year when 2009 then p.oil_bom else 0 end),0) as oil_bom_2009, 
	coalesce(sum(case p.prod_year when 2010 then p.oil_bom else 0 end),0) as oil_bom_2010,
	coalesce(sum(case p.prod_year when 2011 then p.oil_bom else 0 end),0) as oil_bom_2011,
	coalesce(sum(case p.prod_year when 2012 then p.oil_bom else 0 end),0) as oil_bom_2012,
	coalesce(sum(case p.prod_year when 2013 then p.oil_bom else 0 end),0) as oil_bom_2013,
	coalesce(sum(case p.prod_year when 2014 then p.oil_bom else 0 end),0) as oil_bom_2014,
	coalesce(sum(case p.prod_year when 1999 then p.oil_produced else 0 end),0) as oil_produced_1999, 
	coalesce(sum(case p.prod_year when 2000 then p.oil_produced else 0 end),0) as oil_produced_2000, 
	coalesce(sum(case p.prod_year when 2001 then p.oil_produced else 0 end),0) as oil_produced_2001, 
	coalesce(sum(case p.prod_year when 2002 then p.oil_produced else 0 end),0) as oil_produced_2002, 
	coalesce(sum(case p.prod_year when 2003 then p.oil_produced else 0 end),0) as oil_produced_2003, 
	coalesce(sum(case p.prod_year when 2004 then p.oil_produced else 0 end),0) as oil_produced_2004,
	coalesce(sum(case p.prod_year when 2005 then p.oil_produced else 0 end),0) as oil_produced_2005, 
	coalesce(sum(case p.prod_year when 2006 then p.oil_produced else 0 end),0) as oil_produced_2006, 
	coalesce(sum(case p.prod_year when 2007 then p.oil_produced else 0 end),0) as oil_produced_2007, 
	coalesce(sum(case p.prod_year when 2008 then p.oil_produced else 0 end),0) as oil_produced_2008, 
	coalesce(sum(case p.prod_year when 2009 then p.oil_produced else 0 end),0) as oil_produced_2009, 
	coalesce(sum(case p.prod_year when 2010 then p.oil_produced else 0 end),0) as oil_produced_2010,
	coalesce(sum(case p.prod_year when 2011 then p.oil_produced else 0 end),0) as oil_produced_2011,
	coalesce(sum(case p.prod_year when 2012 then p.oil_produced else 0 end),0) as oil_produced_2012,
	coalesce(sum(case p.prod_year when 2013 then p.oil_produced else 0 end),0) as oil_produced_2013,
	coalesce(sum(case p.prod_year when 2014 then p.oil_produced else 0 end),0) as oil_produced_2014,
	coalesce(sum(case p.prod_year when 1999 then p.oil_sold else 0 end),0) as oil_sold_1999, 
	coalesce(sum(case p.prod_year when 2000 then p.oil_sold else 0 end),0) as oil_sold_2000, 
	coalesce(sum(case p.prod_year when 2001 then p.oil_sold else 0 end),0) as oil_sold_2001, 
	coalesce(sum(case p.prod_year when 2002 then p.oil_sold else 0 end),0) as oil_sold_2002, 
	coalesce(sum(case p.prod_year when 2003 then p.oil_sold else 0 end),0) as oil_sold_2003, 
	coalesce(sum(case p.prod_year when 2004 then p.oil_sold else 0 end),0) as oil_sold_2004,
	coalesce(sum(case p.prod_year when 2005 then p.oil_sold else 0 end),0) as oil_sold_2005, 
	coalesce(sum(case p.prod_year when 2006 then p.oil_sold else 0 end),0) as oil_sold_2006, 
	coalesce(sum(case p.prod_year when 2007 then p.oil_sold else 0 end),0) as oil_sold_2007, 
	coalesce(sum(case p.prod_year when 2008 then p.oil_sold else 0 end),0) as oil_sold_2008, 
	coalesce(sum(case p.prod_year when 2009 then p.oil_sold else 0 end),0) as oil_sold_2009, 
	coalesce(sum(case p.prod_year when 2010 then p.oil_sold else 0 end),0) as oil_sold_2010,
	coalesce(sum(case p.prod_year when 2011 then p.oil_sold else 0 end),0) as oil_sold_2011,
	coalesce(sum(case p.prod_year when 2012 then p.oil_sold else 0 end),0) as oil_sold_2012,
	coalesce(sum(case p.prod_year when 2013 then p.oil_sold else 0 end),0) as oil_sold_2013,
	coalesce(sum(case p.prod_year when 2014 then p.oil_sold else 0 end),0) as oil_sold_2014,
	coalesce(sum(case p.prod_year when 1999 then p.oil_adj else 0 end),0) as oil_adj_1999, 
	coalesce(sum(case p.prod_year when 2000 then p.oil_adj else 0 end),0) as oil_adj_2000, 
	coalesce(sum(case p.prod_year when 2001 then p.oil_adj else 0 end),0) as oil_adj_2001, 
	coalesce(sum(case p.prod_year when 2002 then p.oil_adj else 0 end),0) as oil_adj_2002, 
	coalesce(sum(case p.prod_year when 2003 then p.oil_adj else 0 end),0) as oil_adj_2003, 
	coalesce(sum(case p.prod_year when 2004 then p.oil_adj else 0 end),0) as oil_adj_2004,
	coalesce(sum(case p.prod_year when 2005 then p.oil_adj else 0 end),0) as oil_adj_2005, 
	coalesce(sum(case p.prod_year when 2006 then p.oil_adj else 0 end),0) as oil_adj_2006, 
	coalesce(sum(case p.prod_year when 2007 then p.oil_adj else 0 end),0) as oil_adj_2007, 
	coalesce(sum(case p.prod_year when 2008 then p.oil_adj else 0 end),0) as oil_adj_2008, 
	coalesce(sum(case p.prod_year when 2009 then p.oil_adj else 0 end),0) as oil_adj_2009, 
	coalesce(sum(case p.prod_year when 2010 then p.oil_adj else 0 end),0) as oil_adj_2010,
	coalesce(sum(case p.prod_year when 2011 then p.oil_adj else 0 end),0) as oil_adj_2011,
	coalesce(sum(case p.prod_year when 2012 then p.oil_adj else 0 end),0) as oil_adj_2012,
	coalesce(sum(case p.prod_year when 2013 then p.oil_adj else 0 end),0) as oil_adj_2013,
	coalesce(sum(case p.prod_year when 2014 then p.oil_adj else 0 end),0) as oil_adj_2014,
	coalesce(sum(case p.prod_year when 1999 then p.oil_eom else 0 end),0) as oil_eom_1999, 
	coalesce(sum(case p.prod_year when 2000 then p.oil_eom else 0 end),0) as oil_eom_2000, 
	coalesce(sum(case p.prod_year when 2001 then p.oil_eom else 0 end),0) as oil_eom_2001, 
	coalesce(sum(case p.prod_year when 2002 then p.oil_eom else 0 end),0) as oil_eom_2002, 
	coalesce(sum(case p.prod_year when 2003 then p.oil_eom else 0 end),0) as oil_eom_2003, 
	coalesce(sum(case p.prod_year when 2004 then p.oil_eom else 0 end),0) as oil_eom_2004,
	coalesce(sum(case p.prod_year when 2005 then p.oil_eom else 0 end),0) as oil_eom_2005, 
	coalesce(sum(case p.prod_year when 2006 then p.oil_eom else 0 end),0) as oil_eom_2006, 
	coalesce(sum(case p.prod_year when 2007 then p.oil_eom else 0 end),0) as oil_eom_2007, 
	coalesce(sum(case p.prod_year when 2008 then p.oil_eom else 0 end),0) as oil_eom_2008, 
	coalesce(sum(case p.prod_year when 2009 then p.oil_eom else 0 end),0) as oil_eom_2009, 
	coalesce(sum(case p.prod_year when 2010 then p.oil_eom else 0 end),0) as oil_eom_2010,
	coalesce(sum(case p.prod_year when 2011 then p.oil_eom else 0 end),0) as oil_eom_2011,
	coalesce(sum(case p.prod_year when 2012 then p.oil_eom else 0 end),0) as oil_eom_2012,
	coalesce(sum(case p.prod_year when 2013 then p.oil_eom else 0 end),0) as oil_eom_2013,
	coalesce(sum(case p.prod_year when 2014 then p.oil_eom else 0 end),0) as oil_eom_2014,
	coalesce(sum(case p.prod_year when 1999 then p.gas_production else 0 end),0) as gas_production_1999, 
	coalesce(sum(case p.prod_year when 2000 then p.gas_production else 0 end),0) as gas_production_2000, 
	coalesce(sum(case p.prod_year when 2001 then p.gas_production else 0 end),0) as gas_production_2001, 
	coalesce(sum(case p.prod_year when 2002 then p.gas_production else 0 end),0) as gas_production_2002, 
	coalesce(sum(case p.prod_year when 2003 then p.gas_production else 0 end),0) as gas_production_2003, 
	coalesce(sum(case p.prod_year when 2004 then p.gas_production else 0 end),0) as gas_production_2004,
	coalesce(sum(case p.prod_year when 2005 then p.gas_production else 0 end),0) as gas_production_2005, 
	coalesce(sum(case p.prod_year when 2006 then p.gas_production else 0 end),0) as gas_production_2006, 
	coalesce(sum(case p.prod_year when 2007 then p.gas_production else 0 end),0) as gas_production_2007, 
	coalesce(sum(case p.prod_year when 2008 then p.gas_production else 0 end),0) as gas_production_2008, 
	coalesce(sum(case p.prod_year when 2009 then p.gas_production else 0 end),0) as gas_production_2009, 
	coalesce(sum(case p.prod_year when 2010 then p.gas_production else 0 end),0) as gas_production_2010,
	coalesce(sum(case p.prod_year when 2011 then p.gas_production else 0 end),0) as gas_production_2011,
	coalesce(sum(case p.prod_year when 2012 then p.gas_production else 0 end),0) as gas_production_2012,
	coalesce(sum(case p.prod_year when 2013 then p.gas_production else 0 end),0) as gas_production_2013,
	coalesce(sum(case p.prod_year when 2014 then p.gas_production else 0 end),0) as gas_production_2014,
	coalesce(sum(case p.prod_year when 1999 then p.gas_flared else 0 end),0) as gas_flared_1999, 
	coalesce(sum(case p.prod_year when 2000 then p.gas_flared else 0 end),0) as gas_flared_2000, 
	coalesce(sum(case p.prod_year when 2001 then p.gas_flared else 0 end),0) as gas_flared_2001, 
	coalesce(sum(case p.prod_year when 2002 then p.gas_flared else 0 end),0) as gas_flared_2002, 
	coalesce(sum(case p.prod_year when 2003 then p.gas_flared else 0 end),0) as gas_flared_2003, 
	coalesce(sum(case p.prod_year when 2004 then p.gas_flared else 0 end),0) as gas_flared_2004,
	coalesce(sum(case p.prod_year when 2005 then p.gas_flared else 0 end),0) as gas_flared_2005, 
	coalesce(sum(case p.prod_year when 2006 then p.gas_flared else 0 end),0) as gas_flared_2006, 
	coalesce(sum(case p.prod_year when 2007 then p.gas_flared else 0 end),0) as gas_flared_2007, 
	coalesce(sum(case p.prod_year when 2008 then p.gas_flared else 0 end),0) as gas_flared_2008, 
	coalesce(sum(case p.prod_year when 2009 then p.gas_flared else 0 end),0) as gas_flared_2009, 
	coalesce(sum(case p.prod_year when 2010 then p.gas_flared else 0 end),0) as gas_flared_2010,
	coalesce(sum(case p.prod_year when 2011 then p.gas_flared else 0 end),0) as gas_flared_2011,
	coalesce(sum(case p.prod_year when 2012 then p.gas_flared else 0 end),0) as gas_flared_2012,
	coalesce(sum(case p.prod_year when 2013 then p.gas_flared else 0 end),0) as gas_flared_2013,
	coalesce(sum(case p.prod_year when 2014 then p.gas_flared else 0 end),0) as gas_flared_2014,
	coalesce(sum(case p.prod_year when 1999 then p.gas_used else 0 end),0) as gas_used_1999, 
	coalesce(sum(case p.prod_year when 2000 then p.gas_used else 0 end),0) as gas_used_2000, 
	coalesce(sum(case p.prod_year when 2001 then p.gas_used else 0 end),0) as gas_used_2001, 
	coalesce(sum(case p.prod_year when 2002 then p.gas_used else 0 end),0) as gas_used_2002, 
	coalesce(sum(case p.prod_year when 2003 then p.gas_used else 0 end),0) as gas_used_2003, 
	coalesce(sum(case p.prod_year when 2004 then p.gas_used else 0 end),0) as gas_used_2004,
	coalesce(sum(case p.prod_year when 2005 then p.gas_used else 0 end),0) as gas_used_2005, 
	coalesce(sum(case p.prod_year when 2006 then p.gas_used else 0 end),0) as gas_used_2006, 
	coalesce(sum(case p.prod_year when 2007 then p.gas_used else 0 end),0) as gas_used_2007, 
	coalesce(sum(case p.prod_year when 2008 then p.gas_used else 0 end),0) as gas_used_2008, 
	coalesce(sum(case p.prod_year when 2009 then p.gas_used else 0 end),0) as gas_used_2009, 
	coalesce(sum(case p.prod_year when 2010 then p.gas_used else 0 end),0) as gas_used_2010,
	coalesce(sum(case p.prod_year when 2011 then p.gas_used else 0 end),0) as gas_used_2011,
	coalesce(sum(case p.prod_year when 2012 then p.gas_used else 0 end),0) as gas_used_2012,
	coalesce(sum(case p.prod_year when 2013 then p.gas_used else 0 end),0) as gas_used_2013,
	coalesce(sum(case p.prod_year when 2014 then p.gas_used else 0 end),0) as gas_used_2014,
	coalesce(sum(case p.prod_year when 1999 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_1999, 
	coalesce(sum(case p.prod_year when 2000 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2000, 
	coalesce(sum(case p.prod_year when 2001 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2001, 
	coalesce(sum(case p.prod_year when 2002 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2002, 
	coalesce(sum(case p.prod_year when 2003 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2003, 
	coalesce(sum(case p.prod_year when 2004 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2004,
	coalesce(sum(case p.prod_year when 2005 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2005, 
	coalesce(sum(case p.prod_year when 2006 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2006, 
	coalesce(sum(case p.prod_year when 2007 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2007, 
	coalesce(sum(case p.prod_year when 2008 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2008, 
	coalesce(sum(case p.prod_year when 2009 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2009, 
	coalesce(sum(case p.prod_year when 2010 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2010,
	coalesce(sum(case p.prod_year when 2011 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2011,
	coalesce(sum(case p.prod_year when 2012 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2012,
	coalesce(sum(case p.prod_year when 2013 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2013,
	coalesce(sum(case p.prod_year when 2014 then p.gas_shrinkage else 0 end),0) as gas_shrinkage_2014,
	coalesce(sum(case p.prod_year when 1999 then p.gas_sold else 0 end),0) as gas_sold_1999, 
	coalesce(sum(case p.prod_year when 2000 then p.gas_sold else 0 end),0) as gas_sold_2000, 
	coalesce(sum(case p.prod_year when 2001 then p.gas_sold else 0 end),0) as gas_sold_2001, 
	coalesce(sum(case p.prod_year when 2002 then p.gas_sold else 0 end),0) as gas_sold_2002, 
	coalesce(sum(case p.prod_year when 2003 then p.gas_sold else 0 end),0) as gas_sold_2003, 
	coalesce(sum(case p.prod_year when 2004 then p.gas_sold else 0 end),0) as gas_sold_2004,
	coalesce(sum(case p.prod_year when 2005 then p.gas_sold else 0 end),0) as gas_sold_2005, 
	coalesce(sum(case p.prod_year when 2006 then p.gas_sold else 0 end),0) as gas_sold_2006, 
	coalesce(sum(case p.prod_year when 2007 then p.gas_sold else 0 end),0) as gas_sold_2007, 
	coalesce(sum(case p.prod_year when 2008 then p.gas_sold else 0 end),0) as gas_sold_2008, 
	coalesce(sum(case p.prod_year when 2009 then p.gas_sold else 0 end),0) as gas_sold_2009, 
	coalesce(sum(case p.prod_year when 2010 then p.gas_sold else 0 end),0) as gas_sold_2010,
	coalesce(sum(case p.prod_year when 2011 then p.gas_sold else 0 end),0) as gas_sold_2011,
	coalesce(sum(case p.prod_year when 2012 then p.gas_sold else 0 end),0) as gas_sold_2012,
	coalesce(sum(case p.prod_year when 2013 then p.gas_sold else 0 end),0) as gas_sold_2013,
	coalesce(sum(case p.prod_year when 2014 then p.gas_sold else 0 end),0) as gas_sold_2014,
	coalesce(sum(case p.prod_year when 1999 then p.gas_btu else 0 end),0) as gas_btu_1999, 
	coalesce(sum(case p.prod_year when 2000 then p.gas_btu else 0 end),0) as gas_btu_2000, 
	coalesce(sum(case p.prod_year when 2001 then p.gas_btu else 0 end),0) as gas_btu_2001, 
	coalesce(sum(case p.prod_year when 2002 then p.gas_btu else 0 end),0) as gas_btu_2002, 
	coalesce(sum(case p.prod_year when 2003 then p.gas_btu else 0 end),0) as gas_btu_2003, 
	coalesce(sum(case p.prod_year when 2004 then p.gas_btu else 0 end),0) as gas_btu_2004,
	coalesce(sum(case p.prod_year when 2005 then p.gas_btu else 0 end),0) as gas_btu_2005, 
	coalesce(sum(case p.prod_year when 2006 then p.gas_btu else 0 end),0) as gas_btu_2006, 
	coalesce(sum(case p.prod_year when 2007 then p.gas_btu else 0 end),0) as gas_btu_2007, 
	coalesce(sum(case p.prod_year when 2008 then p.gas_btu else 0 end),0) as gas_btu_2008, 
	coalesce(sum(case p.prod_year when 2009 then p.gas_btu else 0 end),0) as gas_btu_2009, 
	coalesce(sum(case p.prod_year when 2010 then p.gas_btu else 0 end),0) as gas_btu_2010,
	coalesce(sum(case p.prod_year when 2011 then p.gas_btu else 0 end),0) as gas_btu_2011,
	coalesce(sum(case p.prod_year when 2012 then p.gas_btu else 0 end),0) as gas_btu_2012,
	coalesce(sum(case p.prod_year when 2013 then p.gas_btu else 0 end),0) as gas_btu_2013,
	coalesce(sum(case p.prod_year when 2014 then p.gas_btu else 0 end),0) as gas_btu_2014,
	coalesce(sum(case p.prod_year when 1999 then p.water_production else 0 end),0) as produced_water_1999, 
	coalesce(sum(case p.prod_year when 2000 then p.water_production else 0 end),0) as produced_water_2000, 
	coalesce(sum(case p.prod_year when 2001 then p.water_production else 0 end),0) as produced_water_2001, 
	coalesce(sum(case p.prod_year when 2002 then p.water_production else 0 end),0) as produced_water_2002, 
	coalesce(sum(case p.prod_year when 2003 then p.water_production else 0 end),0) as produced_water_2003, 
	coalesce(sum(case p.prod_year when 2004 then p.water_production else 0 end),0) as produced_water_2004,
	coalesce(sum(case p.prod_year when 2005 then p.water_production else 0 end),0) as produced_water_2005, 
	coalesce(sum(case p.prod_year when 2006 then p.water_production else 0 end),0) as produced_water_2006, 
	coalesce(sum(case p.prod_year when 2007 then p.water_production else 0 end),0) as produced_water_2007, 
	coalesce(sum(case p.prod_year when 2008 then p.water_production else 0 end),0) as produced_water_2008, 
	coalesce(sum(case p.prod_year when 2009 then p.water_production else 0 end),0) as produced_water_2009, 
	coalesce(sum(case p.prod_year when 2010 then p.water_production else 0 end),0) as produced_water_2010,
	coalesce(sum(case p.prod_year when 2011 then p.water_production else 0 end),0) as produced_water_2011,
	coalesce(sum(case p.prod_year when 2012 then p.water_production else 0 end),0) as produced_water_2012,
	coalesce(sum(case p.prod_year when 2013 then p.water_production else 0 end),0) as produced_water_2013,
	coalesce(sum(case p.prod_year when 2014 then p.water_production else 0 end),0) as produced_water_2014
from 
	cogcc_production_amounts p 
inner join 
	cogcc_well_surface_locations w on p.well_id = w.well_id 
where 
	 w.api_county in ('007','067')
group by 
	w.attrib_1, 
	w.api_county, 
	w.api_seq_nu, 
	w.attrib_3, 
	w.facility_s, 
	w.locationid, 
	w.attrib_2, 
	w.operator_n, 
	w.field_name, 
	w.field_code, 
	w.lat, 
	w.long
order by 
	w.attrib_1 
) TO '/Users/troyburke/Data/cogcc/cogcc_san_juan_production_by_year.csv' WITH CSV HEADER;



