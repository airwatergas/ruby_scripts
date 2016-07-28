---------------------------------------------------------------
-------------------  UTAH DATA (UTOGM)  -----------------------
---------------------------------------------------------------

-- create role and database
create user "utogm" with superuser password '';
create database utogm_development with owner utogm;

-- create import and backup schemas
create schema import;
create schema backup;



---------------------------------------------------------------
------------------  STATIC DATA TABLES  -----------------------
---------------------------------------------------------------

---------------------------------------------------------------
--------------------  WELL STATUSES  --------------------------
---------------------------------------------------------------
set search_path to public;
drop table backup.well_statuses;
create table backup.well_statuses as table well_statuses;
drop table well_statuses;
create table well_statuses (
	id integer not null primary key,
	code varchar(3),
	description varchar(30), 
	alt_desc varchar(40)
);

insert into well_statuses (id, code, description, alt_desc) values (1, 'NEW', 'New Permit', 'new apd; not yet approved');
insert into well_statuses (id, code, description, alt_desc) values (2, 'RET', 'Returned APD (Unapproved)', 'apd returned to operator unapproved');
insert into well_statuses (id, code, description, alt_desc) values (3, 'APD', 'Approved Permit', 'approved apd');
insert into well_statuses (id, code, description, alt_desc) values (4, 'DRL', 'Drilling', 'spudded; not complete');
insert into well_statuses (id, code, description, alt_desc) values (5, 'OPS', 'Drilling Operations Suspended', 'drilling operations suspended');
insert into well_statuses (id, code, description, alt_desc) values (6, 'P', 'Producing', 'producing');
insert into well_statuses (id, code, description, alt_desc) values (7, 'S', 'Shut-in', 'shut-in');
insert into well_statuses (id, code, description, alt_desc) values (8, 'TA', 'Temporarily-abandoned', 'temporarily-abandoned');
insert into well_statuses (id, code, description, alt_desc) values (9, 'PA', 'Plugged and Abandoned', 'plugged and abandoned');
insert into well_statuses (id, code, description, alt_desc) values (10, 'A', 'Active', 'active (service well)');
insert into well_statuses (id, code, description, alt_desc) values (11, 'I', 'Inactive', 'inactive (service well)');
insert into well_statuses (id, code, description, alt_desc) values (12, 'LA', 'Location Abandoned', 'location abandoned; permit rescinded');
insert into well_statuses (id, code, description, alt_desc) values (13, 'NA', '	Not available', 'na');

create index index_well_statuses_on_code on well_statuses (code);



---------------------------------------------------------------
----------------------  WELL TYPES  ---------------------------
---------------------------------------------------------------
set search_path to public;
drop table backup.well_types;
create table backup.well_types as table well_types;
drop table well_types;
create table well_types (
	id integer not null primary key,
	code varchar(2),
	description varchar(20), 
	alt_desc varchar(40)
);

insert into well_types (id, code, description, alt_desc) values (1, 'OW', 'Oil Well', 'oil well');
insert into well_types (id, code, description, alt_desc) values (2, 'GW', 'Gas Well', 'gas well');
insert into well_types (id, code, description, alt_desc) values (3, 'D', 'Dry Hole', 'dry hole');
insert into well_types (id, code, description, alt_desc) values (4, 'WI', 'Water Injection Well', 'water injection (service well)');
insert into well_types (id, code, description, alt_desc) values (5, 'GI', 'Gas Injection Well', 'gas injection (service well)');
insert into well_types (id, code, description, alt_desc) values (6, 'GS', 'Gas Storage Well', 'gas storage (service well)');
insert into well_types (id, code, description, alt_desc) values (7, 'WD', 'Water Disposal Well', 'water disposal (service well)');
insert into well_types (id, code, description, alt_desc) values (8, 'WS', 'Water Source Well', 'water source (service well)');
insert into well_types (id, code, description, alt_desc) values (9, 'TW', 'Test Well', 'test well (service well)');
insert into well_types (id, code, description, alt_desc) values (10, 'NA', 'Not Available', 'well type not available');
insert into well_types (id, code, description, alt_desc) values (11, 'CD', 'Carbon Dioxide Well', 'carbon dioxide well');

create index index_well_types_on_code on well_types (code);



---------------------------------------------------------------
---------------------  API COUNTIES  --------------------------
---------------------------------------------------------------
set search_path to public;
drop table backup.api_counties;
create table backup.api_counties as table api_counties;
drop table api_counties;
create table api_counties (
	id integer not null primary key,
	code varchar(3),
	county varchar(20)
);

insert into api_counties (id, code, county) values (1,'001','Beaver');
insert into api_counties (id, code, county) values (2,'003','Box Elder');
insert into api_counties (id, code, county) values (3,'005','Cache');
insert into api_counties (id, code, county) values (4,'007','Carbon');
insert into api_counties (id, code, county) values (5,'009','Daggett');
insert into api_counties (id, code, county) values (6,'011','Davis');
insert into api_counties (id, code, county) values (7,'013','Duchesne');
insert into api_counties (id, code, county) values (8,'015','Emery');
insert into api_counties (id, code, county) values (9,'017','Garfield');
insert into api_counties (id, code, county) values (10,'019','Grand');
insert into api_counties (id, code, county) values (11,'021','Iron');
insert into api_counties (id, code, county) values (12,'023','Juab');
insert into api_counties (id, code, county) values (13,'025','Kane');
insert into api_counties (id, code, county) values (14,'027','Millard');
insert into api_counties (id, code, county) values (15,'029','Morgan');
insert into api_counties (id, code, county) values (16,'031','Piute');
insert into api_counties (id, code, county) values (17,'033','Rich');
insert into api_counties (id, code, county) values (18,'035','Salt Lake');
insert into api_counties (id, code, county) values (19,'037','San Juan');
insert into api_counties (id, code, county) values (20,'039','Sanpete');
insert into api_counties (id, code, county) values (21,'041','Sevier');
insert into api_counties (id, code, county) values (22,'043','Summit');
insert into api_counties (id, code, county) values (23,'045','Tooele');
insert into api_counties (id, code, county) values (24,'047','Uintah');
insert into api_counties (id, code, county) values (25,'049','Utah');
insert into api_counties (id, code, county) values (26,'051','Wasatch');
insert into api_counties (id, code, county) values (27,'053','Washington');
insert into api_counties (id, code, county) values (28,'055','Wayne');
insert into api_counties (id, code, county) values (29,'057','Weber');

create index index_api_counties_on_code on api_counties (code);



---------------------------------------------------------------
-----------------  ZONES (aka FORMATIONS)  --------------------
---------------------------------------------------------------
-- csv header rows
-- ZONE_CODE,ZONE_DESC

set search_path to import;
drop table zones;
create table zones (
	code varchar(5),
	description varchar(30)
);
copy zones from '/Users/troyburke/Data/utah/imported_csv/zonedata.csv' (format csv, delimiter ',', null '');
--341

alter table zones add column id serial primary key not null;


set search_path to public;
drop table backup.zones;
create table backup.zones as table zones;
drop table zones;
create table zones (
	id integer not null primary key, 
	code varchar(5),
	description varchar(30)
);
insert into zones (id, code, description) select id, code, description from import.zones order by id;



---------------------------------------------------------------
------------------------  FIELDS  -----------------------------
---------------------------------------------------------------
-- csv header rows
-- FIELD_NUM,FIELD_NAME

set search_path to import;
drop table fields;
create table fields (
	field_num integer, 
	field_name varchar(25)
);
copy fields from '/Users/troyburke/Data/utah/imported_csv/fieldata.csv' (format csv, delimiter ',', null '');
--281

alter table fields add column id serial primary key not null;


set search_path to public;
drop table backup.fields;
create table backup.fields as table fields;
drop table fields;
create table fields (
	id integer not null primary key, 
	field_num integer, 
	field_name varchar(25)
);
insert into fields (id, field_num, field_name) select id, field_num, field_name from import.fields order by id;





---------------------------------------------------------------
------------------  DYNAMIC DATA TABLES  ----------------------
---------------------------------------------------------------

---------------------------------------------------------------
------------------------  ENTITIES  ---------------------------
---------------------------------------------------------------
-- entities csv header row
-- ENTITY_NUM,ACCT_NUM,ENT_NAME,COMMENT

set search_path to import;
drop table entities;
create table entities (
	entity_num integer, 
	acct_num varchar(5), 
	ent_name varchar(30), 
	comment varchar(150)
);

copy entities from '/Users/troyburke/Data/utah/imported_csv/entydata.csv' (format csv, delimiter ',', null '');
--11333

alter table entities add column id serial primary key not null;


-- move imported data to staging for clean up
set search_path to import;
drop table staging.entities;
create table staging.entities as table entities;
set search_path to staging;

-- clean up scripts
alter table entities add column has_wells boolean not null default false;
update entities set has_wells = 'true' where acct_num in (select distinct acct_num from wells);
--11275

alter table entities add column has_well_productions boolean not null default false;
update entities set has_well_productions = 'true' where acct_num in (select distinct acct_num from well_productions);
--11173

alter table entities add column has_well_dispositions boolean not null default false;
update entities set has_well_dispositions = 'true' where entity_num in (select distinct entity from well_dispositions);
--9750







set search_path to public;
drop table backup.entities;
create table backup.entities as table entities;
drop table entities;
create table entities (
	id integer not null primary key, 
	entity_num integer, 
	acct_num varchar(5), 
	ent_name varchar(30), 
	comment varchar(150), 
	created_at date, 
	updated_at date
);
insert into entities (id, entity_num, acct_num, ent_name, comment, created_at, updated_at) select id, entity_num, acct_num, ent_name, comment, '2015-12-17', '2015-12-17' from import.entities order by id;

create index index_entities_on_entity_num on entities (entity_num);
create index index_entities_on_acct_num on entities (acct_num);











---------------------------------------------------------------
--------------------  WELL OPERATORS  -------------------------
---------------------------------------------------------------
-- csv header rows
-- ACCT_NUM,ALT_ADDRES,CO_NAME,CO_ADDRESS,CO_CITY,CO_STATE,CO_ZIP,CO_CONTACT,CO_PHONE,CO_FAX,EMAIL_ADDR,ACTIVE_OPR

set search_path to import;
drop table well_operators;
create table well_operators (
	acct_num varchar(5), 
	alt_address varchar(1), 
	co_name varchar(50), 
	co_address varchar(40), 
	co_city varchar(20), 
	co_state varchar(2), 
	co_zip varchar(9), 
	co_contact varchar(25), 
	co_phone varchar(10), 
	co_fax varchar(10), 
	email_addr varchar(40), 
	active_opr boolean
);

copy well_operators from '/Users/troyburke/Data/utah/imported_csv/operdata.csv' (format csv, delimiter ',', null '');
--2298

alter table well_operators add column id serial primary key not null;


-- move imported data to staging for clean up
set search_path to import;
drop table staging.well_operators;
create table staging.well_operators as table well_operators;
set search_path to staging;

-- clean up scripts
--alt_adress possible values => #,1,A,B,C,K,U,X (# is primary address)

--co_address
update well_operators set co_address = null where co_address = 'XXXXXXXXXXXXXXXXXXXXXXXXX';
--35

--co_city
update well_operators set co_city = upper(trim(co_city));
update well_operators set co_city = null where co_city = 'XXXXXXXXXXXXXXX';
--36

--co_state
update well_operators set co_state = null where co_state = 'XX';
--36

--co_zip
update well_operators set co_zip = null where co_zip = '999999999';
--29
update well_operators set co_zip = null where co_zip = 'XXXXX';
--4
update well_operators set co_zip = null where co_zip = 'XXXXXXXXX';
--3

--co_contact
update well_operators set co_contact = upper(trim(co_contact));

--co_phone
update well_operators set co_phone = null where co_phone = 'XXXXXXXXXX';
--5

--co_fax
update well_operators set co_fax = null where co_fax = '0';
--2
update well_operators set co_fax = null where co_fax = 'None';
--972

--email_addr
update well_operators set email_addr = null where email_addr = 'None';
--1626


-- copy staging records to csv file
COPY (select id, acct_num, alt_address, co_name, co_address, co_city, co_state, co_zip, co_contact, co_phone, co_fax, email_addr, active_opr, '2015-12-17', '2015-12-17' from well_operators order by acct_num desc) TO '/Users/troyburke/Data/utah/table_dumps_2016/well_operators.csv' WITH CSV;

set search_path to public;
drop table backup.well_operators;
create table backup.well_operators as table well_operators;
drop table well_operators;
create table well_operators (
	id integer, 
	acct_num varchar(5), 
	alt_addres varchar(1), 
	co_name varchar(50), 
	co_address varchar(40), 
	co_city varchar(20), 
	co_state varchar(2), 
	co_zip varchar(9), 
	co_contact varchar(25), 
	co_phone varchar(10), 
	co_fax varchar(10), 
	email_addr varchar(40), 
	active_opr boolean, 
	created_at date, 
	updated_at date
);

copy well_operators from '/Users/troyburke/Data/utah/table_dumps_2016/well_operators.csv' (format csv, delimiter ',', null '');

alter table well_operators add primary key (id);

create index index_well_operators_on_acct_num on well_operators (acct_num);
create index index_well_operators_on_active_opr on well_operators (active_opr);





---------------------------------------------------------------
-------------------------  WELLS  -----------------------------
---------------------------------------------------------------

-- well csv header
--  API,WELL_NAME,ACCT_NUM,ALT_ADDRES,FIELD_NUM,ELEVATION,LOCAT_FOOT,UTM_SURF_N,UTM_SURF_E,UTM_BHL_N,UTM_BHL_E,QTR_QTR,SECTION,TOWNSHIP,RANGE,MERIDIAN,COUNTY,DIR_HORIZ,CONF_FLAG,CONF_DATE,LEASE_NUM,LEASE_TYPE,ABNDONDATE,WELLSTATUS,WELL_TYPE,TOTCUM_OIL,TOTCUM_GAS,TOTCUM_WTR,IND_TRIBE,MULTI_LATS,CBMETHFLAG,SURFOWNTYP,BOND_NUM,BOND_TYPE,CA_NUMBER,FIELD_TYPE,UNIT_NAME,LAT_SURF,LONG_SURF,COMMENTS,MODIFYDATE


set search_path to import;
drop table wells;
create table wells (
	api varchar(10), 
	well_name varchar(100), 
	acct_num varchar(5), 
	alt_addres varchar(100), 
	field_num integer, 
	elevation varchar(20), 
	locat_foot varchar(40), 
	utm_surf_n double precision, 
	utm_surf_e double precision, 
	utm_bhl_n double precision, 
	utm_bhl_e double precision, 
	qtr_qtr varchar(10), 
	section integer, 
	township varchar(10), 
	range varchar(10), 
	meridian varchar(1), 
	county varchar(30), 
	dir_horiz varchar(1), -- D or H 
	conf_flag boolean, -- T=yes or F=no
	conf_date date, 
	lease_num varchar(30), 
	lease_type smallint, -- 0=unknown, 1=federal, 2=indian, 3=state, 4=fee
	abndondate date, 
	wellstatus varchar(3), 
	well_type varchar(2), 
	totcum_oil integer, 
	totcum_gas integer, 
	totcum_wtr integer, 
	ind_tribe varchar(10), 
	multi_lats integer, 
	cbmethflag boolean, -- T=yes or F=no
	surfowntyp smallint, -- 0=unknown, 1=federal, 2=indian, 3=state, 4=fee 
	bond_num varchar(20), 
	bond_type smallint, -- 1=federal, 2=indian, 3=state, 4=fee, 5=state&fee combined 
	ca_number varchar(20), 
	field_type varchar(1), -- D=development, E=extension, W=wildcat
	unit_name varchar(50), 
	lat_surf double precision, 
	long_surf double precision, 
	comments varchar(500), 
	modifydate date
);

copy wells from '/Users/troyburke/Data/utah/imported_csv/welldata.csv' (format csv, delimiter ',', null '');
--35246

-- move imported data to staging for clean up
set search_path to import;
drop table staging.wells;
create table staging.wells as table wells;
set search_path to staging;

alter table wells add column id serial primary key not null;

-- clean up scripts
--add well_operator_id
alter table wells add column well_operator_id integer;
update wells set well_operator_id = (select id from well_operators where alt_address = '#' and acct_num = wells.acct_num);
--add county_fips
alter table wells add column county_fips varchar(3);
update wells set county_fips = (select code from public.api_counties where upper(trim(wells.county)) = upper(trim(county)));

alter table wells alter column api type bigint using api::bigint;
alter table wells alter column well_name type varchar(40);
alter table wells alter column alt_addres type varchar(1);
alter table wells alter column elevation type varchar(10);
alter table wells alter column locat_foot type varchar(20);
alter table wells alter column qtr_qtr type varchar(4);
alter table wells alter column township type varchar(4);
alter table wells alter column range type varchar(4);
alter table wells alter column county type varchar(10);
alter table wells alter column lease_num type varchar(15);
alter table wells alter column ind_tribe type varchar(6);
alter table wells alter column unit_name type varchar(30);
alter table wells alter column comments type varchar(255);


set search_path to public;
drop table backup.wells;
create table backup.wells as table wells;
drop table wells;
create table wells (
	id integer not null primary key, 
	api bigint, 
	well_name varchar(40), 
	wellstatus varchar(3), 
	well_type varchar(2), 
	dir_horiz varchar(1), -- D or H 
	lease_type smallint, -- 0=unknown, 1=federal, 2=indian, 3=state, 4=fee
	lease_num varchar(15), 
	acct_num varchar(5), --aka operator
	unit_name varchar(30), 
	field_num integer, 
	field_type varchar(1), -- D=development, E=extension, W=wildcat
	county varchar(10), 
	county_fips varchar(3), 
	elevation varchar(10), 
	lat_surf double precision, 
	long_surf double precision, 
	utm_surf_n double precision, 
	utm_surf_e double precision, 
	utm_bhl_n double precision, 
	utm_bhl_e double precision, 
	locat_foot varchar(20), 
	qtr_qtr varchar(4), 
	section integer, 
	township varchar(4), 
	range varchar(4), 
	meridian varchar(1), 
	alt_addres varchar(1), 
	conf_flag boolean, -- T=yes or F=no
	conf_date date, 
	abndondate date, 
	totcum_oil integer, 
	totcum_gas integer, 
	totcum_wtr integer, 
	ind_tribe varchar(6), 
	multi_lats integer, 
	cbmethflag boolean, -- T=yes or F=no
	surfowntyp smallint, -- 0=unknown, 1=federal, 2=indian, 3=state, 4=fee 
	bond_num varchar(20), 
	bond_type smallint, -- 1=federal, 2=indian, 3=state, 4=fee, 5=state&fee combined 
	ca_number varchar(20), 
	comments varchar(255), 
	modifydate date, 
	well_operator_id integer, 
	created_at date, 
	updated_at date
);

insert into wells (id, api, well_name, wellstatus, well_type, dir_horiz, lease_type, lease_num, acct_num, unit_name, field_num, field_type, county, county_fips, elevation, lat_surf, long_surf, utm_surf_n, utm_surf_e, utm_bhl_n, utm_bhl_e, locat_foot, qtr_qtr, section, township, range, meridian, alt_addres, conf_flag, conf_date, abndondate, totcum_oil, totcum_gas, totcum_wtr, ind_tribe, multi_lats, cbmethflag, surfowntyp, bond_num, bond_type, ca_number, comments, modifydate, well_operator_id, created_at, updated_at) 
select id, api, well_name, wellstatus, well_type, dir_horiz, lease_type, lease_num, acct_num, unit_name, field_num, field_type, county, county_fips, elevation, lat_surf, long_surf, utm_surf_n, utm_surf_e, utm_bhl_n, utm_bhl_e, locat_foot, qtr_qtr, section, township, range, meridian, alt_addres, conf_flag, conf_date, abndondate, totcum_oil, totcum_gas, totcum_wtr, ind_tribe, multi_lats, cbmethflag, surfowntyp, bond_num, bond_type, ca_number, comments, modifydate, well_operator_id, '2015-12-17', '2015-12-17' from staging.wells order by id;
--35246


create index index_wells_on_wellstatus on wells(wellstatus);
create index index_wells_on_well_type on wells(well_type);



---------------------------------------------------------------
----------------------  WELL HISTORIES  -----------------------
---------------------------------------------------------------
--  csv header
-- API,APD_APROVD,WORK_TYPE,SPUD_DRY,SPUD_ROTRY,PROD_ZONE,COMPL_DATE,INTENT_REC,WORK_COMPL,TD_MD,TD_TVD,PBTD_MD,PBTD_TVD,WELLSTATUS,WELL_TYPE,FIRST_PROD,TESTMETHOD,CHOKE,TUBNG_PRS,CASNG_PRS,OIL_24HR,GAS_24HR,WATER_24HR,DIR_SURVEY,CORED,DST,COMP_TYPE,DIRECTION,LAT_COUNT,REC_SEQ,CONF_FLAG

set search_path to import;
drop table well_histories;
create table well_histories (
	api varchar(10), 
	apd_aprovd date, 
	work_type varchar(7), 
	spud_dry date, 
	spud_rotry date, 
	prod_zone varchar(5), 
	compl_date date, 
	intent_rec date, 
	work_compl date, 
	td_md integer, 
	td_tvd integer, 
	pbtd_md integer, 
	pbtd_tvd integer, 
	wellstatus varchar(3), 
	well_type varchar(2), 
	first_prod date, 
	testmethod varchar(4), 
	choke varchar(5), 
	tubng_prs varchar(4), -- needs to integer (clean up SI value)
	casng_prs varchar(4), -- integer (clean up S value)
	oil_24hr integer, 
	gas_24hr integer, 
	water_24hr integer, 
	dir_survey varchar(1), -- boolean after clean up
	cored varchar(1), -- boolean after clean up
	dst varchar(1), -- boolean after clean up
	comp_type varchar(13), -- clean up perforated= 
	direction varchar(1), 
	lat_count smallint, 
	rec_seq smallint, 
	conf_flag varchar(1) -- boolean
);

copy well_histories from '/Users/troyburke/Data/utah/imported_csv/histdata.csv' (format csv, delimiter ',', null '');
--43458

-- move imported data to staging for clean up
set search_path to import;
drop table staging.well_histories;
create table staging.well_histories as table well_histories;
set search_path to staging;

alter table well_histories add column id serial primary key not null;

alter table well_histories alter column api type bigint using api::bigint;

alter table well_histories add column well_id integer;
update well_histories set well_id = (select id from wells where api = well_histories.api);


set search_path to public;
drop table backup.well_histories;
create table backup.well_histories as table well_histories;
drop table well_histories;
create table well_histories (
	id integer not null primary key, 
	well_id integer, 
	api bigint, 
	apd_aprovd date, 
	work_type varchar(7), 
	spud_dry date, 
	spud_rotry date, 
	prod_zone varchar(5), 
	compl_date date, 
	intent_rec date, 
	work_compl date, 
	td_md integer, 
	td_tvd integer, 
	pbtd_md integer, 
	pbtd_tvd integer, 
	wellstatus varchar(3), 
	well_type varchar(2), 
	first_prod date, 
	testmethod varchar(4), 
	choke varchar(5), 
	tubng_prs varchar(4), -- needs to integer (clean up SI value)
	casng_prs varchar(4), -- integer (clean up S value)
	oil_24hr integer, 
	gas_24hr integer, 
	water_24hr integer, 
	dir_survey varchar(1), -- boolean after clean up
	cored varchar(1), -- boolean after clean up
	dst varchar(1), -- boolean after clean up
	comp_type varchar(13), -- clean up perforated= 
	direction varchar(1), 
	lat_count smallint, 
	rec_seq smallint, 
	conf_flag varchar(1), -- boolean
	created_at date, 
	updated_at date
);

insert into well_histories (id, well_id, api, apd_aprovd, work_type, spud_dry, spud_rotry, prod_zone, compl_date, intent_rec, work_compl, td_md, td_tvd, pbtd_md, pbtd_tvd, wellstatus, well_type, first_prod, testmethod, choke, tubng_prs, casng_prs, oil_24hr, gas_24hr, water_24hr, dir_survey, cored, dst, comp_type, direction, lat_count, rec_seq, conf_flag, created_at, updated_at) select id, well_id, api, apd_aprovd, work_type, spud_dry, spud_rotry, prod_zone, compl_date, intent_rec, work_compl, td_md, td_tvd, pbtd_md, pbtd_tvd, wellstatus, well_type, first_prod, testmethod, choke, tubng_prs, casng_prs, oil_24hr, gas_24hr, water_24hr, dir_survey, cored, dst, comp_type, direction, lat_count, rec_seq, conf_flag, '2015-12-17', '2015-12-17' from staging.well_histories order by api;


---------------------------------------------------------------
---------------------  WELL COMPLETIONS  ----------------------
---------------------------------------------------------------
--  csv header
-- Completion Date	 Well Name	 API Number	 Operator	 Work Type	 Well Status at Completion	 Well Type at Completion	 Coalbed Methane Well?	 County	 Qtr/Qtr	 Section	 Township	 Range	 Surface Location	 UTM Eastings	 UTM Northings	 Latitude	 Longitude	 Field Name	 Development Type	 Total Depth (MD)	 Total Depth TVD)	 Plug Back Total Depth (MD)	 Plug Back Total Depth (TVD)	 Elevation	 Producing Zone at Completion	 Perforations	 Oil 24hr Test (BBLs)	 Gas 24hr Test (MCF)	 Water 24hr Test (BBLs)	 Directional/ Horizontal	 Total Horizontal Laterals	 Current Well Status	 Cumulative Oil Production (BBLs)	 Cumulative Gas Production (MCF)	 Cumulative Water Production (BBLs)	 Completion Report Received	 Confidential?	 Confidential Status Expires

set search_path to import;
drop table well_completions;
create table well_completions (
	completion_date varchar(30), 
	well_name varchar(50), 
	api_number varchar(10), 
	operator varchar(50), 
	work_type varchar(30), 
	well_status_at_completion varchar(50), 
	well_type_at_completion varchar(50), 
	coalbed_methane_well varchar(50), 
	county varchar(30), 
	qtr_qtr varchar(10), 
	section varchar(10), 
	township varchar(10), 
	range varchar(10), 
	surface_location varchar(50), 
	utm_eastings numeric(10,0), 
	utm_northings numeric(10,0), 
	latitude double precision, 
	longitude double precision, 
	field_name varchar(50), 
	development_type varchar(50), 
	total_depth_md varchar(30), 
	total_depth_tvd varchar(30), 
	plug_back_total_depth_md varchar(30), 
	plug_back_total_depth_tvd varchar(30), 
	elevation varchar(30), 
	producing_zone_at_completion varchar(30), 
	perforations varchar(100), 
	oil_24hr_test_bbls varchar(30), 
	gas_24hr_test_mcf varchar(30), 
	water_24hr_test_bbls varchar(30), 
	directional_horizontal varchar(30), 
	total_horizontal_laterals varchar(30), 
	current_well_status varchar(30), 
	cumulative_oil_production_bbls varchar(30), 
	cumulative_gas_production_mcf varchar(30), 
	cumulative_water_production_bbls varchar(30), 
	completion_report_received varchar(30), 
	confidential varchar(30), 
	confidential_status_expires varchar(30)
);

copy well_completions from '/Users/troyburke/Data/utah/csv_files/utah_well_completions.csv' (format csv, delimiter ',', null '');
--13675


-- move imported data to staging for clean up
set search_path to import;
drop table staging.well_completions;
create table staging.well_completions as table well_completions;
set search_path to staging;

alter table well_completions add column id serial primary key not null;

-- fix bad rows 178,235,475,1996,2857
update well_completions set perforations = '5090-8968; 8940-8954; 8966-8968 SQZ', oil_24hr_test_bbls = '', current_well_status = 'Shut-in', cumulative_oil_production_bbls = '0', cumulative_gas_production_mcf = '0', cumulative_water_production_bbls = '0', completion_report_received = '12/12/2005', confidential = '' where id = 178;

update well_completions set perforations = '6088-6943 OPEN; 6088-6943 OPEN', oil_24hr_test_bbls = '3', gas_24hr_test_mcf = '836', water_24hr_test_bbls = '210', directional_horizontal = '', current_well_status = 'Shut-in', cumulative_oil_production_bbls = '218', cumulative_gas_production_mcf = '94879', cumulative_water_production_bbls = '14884', completion_report_received = '04/28/2005', confidential = '' where id = 235;

update well_completions set perforations = '4715-8448 (CIBP @ 7050 7220 8285)', oil_24hr_test_bbls = '', gas_24hr_test_mcf = '', current_well_status = 'Producing', cumulative_oil_production_bbls = '596', cumulative_gas_production_mcf = '386716', cumulative_water_production_bbls = '5717', completion_report_received = '10/06/2005', confidential = '' where id = 475;

update well_completions set perforations = '4550-7085 OPEN; 7436-7578 WET', oil_24hr_test_bbls = '5', gas_24hr_test_mcf = '1899', water_24hr_test_bbls = '555', directional_horizontal = '', current_well_status = 'Producing', cumulative_oil_production_bbls = '2325', cumulative_gas_production_mcf = '474484', cumulative_water_production_bbls = '48748', completion_report_received = '04/05/2007', confidential = '' where id = 1996;

update well_completions set perforations = '3132-7620 CMT SQZ 3189-3400; 3600-3946', oil_24hr_test_bbls = '3', gas_24hr_test_mcf = '5714', water_24hr_test_bbls = '0', directional_horizontal = 'DIRECTIONAL', total_horizontal_laterals = '', current_well_status = 'Shut-in', cumulative_oil_production_bbls = '1113', cumulative_gas_production_mcf = '792063', cumulative_water_production_bbls = '9764', completion_report_received = '09/07/2007', confidential = '' where id = 2857;


update well_completions set completion_date = trim(completion_date);
alter table well_completions alter column completion_date type date using completion_date::date;

update well_completions set well_name = upper(trim(well_name));
alter table well_completions alter column well_name type varchar(40);

update well_completions set api_number = trim(api_number);
alter table well_completions alter column api_number type bigint using api_number::bigint;

update well_completions set operator = upper(trim(operator));
alter table well_completions alter column operator type varchar(40);

update well_completions set work_type = trim(work_type);
alter table well_completions alter column work_type type varchar(8);

update well_completions set well_status_at_completion = trim(well_status_at_completion);
alter table well_completions alter column well_status_at_completion type varchar(30);

update well_completions set well_type_at_completion = trim(well_type_at_completion);
update well_completions set well_type_at_completion = null where well_type_at_completion = '';
--3879
alter table well_completions alter column well_type_at_completion type varchar(20);

update well_completions set coalbed_methane_well = trim(coalbed_methane_well);
update well_completions set coalbed_methane_well = 'NO' where coalbed_methane_well = '';
--13415
alter table well_completions alter column coalbed_methane_well type boolean using coalbed_methane_well::boolean;

update well_completions set county = upper(trim(county));
alter table well_completions alter column county type varchar(10);

update well_completions set qtr_qtr = upper(trim(qtr_qtr));
alter table well_completions alter column qtr_qtr type varchar(4);

update well_completions set section = trim(section);
alter table well_completions alter column section type smallint using section::smallint;

update well_completions set township = upper(trim(township));
alter table well_completions alter column township type varchar(5);

update well_completions set range = upper(trim(range));
alter table well_completions alter column range type varchar(5);

update well_completions set surface_location = upper(trim(surface_location));
alter table well_completions alter column surface_location type varchar(20);

update well_completions set field_name = upper(trim(field_name));
alter table well_completions alter column field_name type varchar(25);

update well_completions set development_type = trim(development_type);
update well_completions set development_type = null where development_type = '';
--1
alter table well_completions alter column development_type type varchar(11);

update well_completions set total_depth_md = trim(total_depth_md);
update well_completions set total_depth_md = null where total_depth_md = '';
--4175
alter table well_completions alter column total_depth_md type integer using total_depth_md::integer;

update well_completions set total_depth_tvd = trim(total_depth_tvd);
update well_completions set total_depth_tvd = null where total_depth_tvd = '';
--4178
alter table well_completions alter column total_depth_tvd type integer using total_depth_tvd::integer;

update well_completions set plug_back_total_depth_md = trim(plug_back_total_depth_md);
update well_completions set plug_back_total_depth_md = null where plug_back_total_depth_md = '';
--4808
alter table well_completions alter column plug_back_total_depth_md type integer using plug_back_total_depth_md::integer;

update well_completions set plug_back_total_depth_tvd = trim(plug_back_total_depth_tvd);
update well_completions set plug_back_total_depth_tvd = null where plug_back_total_depth_tvd = '';
--4830
alter table well_completions alter column plug_back_total_depth_tvd type integer using plug_back_total_depth_tvd::integer;

update well_completions set elevation = upper(trim(elevation));
alter table well_completions alter column elevation type varchar(8);

update well_completions set producing_zone_at_completion = upper(trim(producing_zone_at_completion));
update well_completions set producing_zone_at_completion = null where producing_zone_at_completion = '';
--4502
alter table well_completions alter column producing_zone_at_completion type varchar(5);

update well_completions set perforations = upper(trim(perforations));
update well_completions set perforations = null where perforations = '';
--4547
alter table well_completions alter column perforations type varchar(50);

update well_completions set oil_24hr_test_bbls = trim(oil_24hr_test_bbls);
update well_completions set oil_24hr_test_bbls = null where oil_24hr_test_bbls = '';
--4716
alter table well_completions alter column oil_24hr_test_bbls type integer using oil_24hr_test_bbls::integer;

update well_completions set gas_24hr_test_mcf = trim(gas_24hr_test_mcf);
update well_completions set gas_24hr_test_mcf = null where gas_24hr_test_mcf = '';
--4687
alter table well_completions alter column gas_24hr_test_mcf type integer using gas_24hr_test_mcf::integer;

update well_completions set water_24hr_test_bbls = trim(water_24hr_test_bbls);
update well_completions set water_24hr_test_bbls = null where water_24hr_test_bbls = '';
--4671
alter table well_completions alter column water_24hr_test_bbls type integer using water_24hr_test_bbls::integer;

update well_completions set directional_horizontal = trim(directional_horizontal);
update well_completions set directional_horizontal = null where directional_horizontal = '';
--8865
alter table well_completions alter column directional_horizontal type varchar(11);

update well_completions set total_horizontal_laterals = trim(total_horizontal_laterals);
update well_completions set total_horizontal_laterals = null where total_horizontal_laterals = '';
--13430
alter table well_completions alter column total_horizontal_laterals type smallint using total_horizontal_laterals::smallint;

update well_completions set current_well_status = trim(current_well_status);
update well_completions set current_well_status = null where current_well_status = '';
--5
alter table well_completions alter column current_well_status type varchar(30);

update well_completions set cumulative_oil_production_bbls = trim(cumulative_oil_production_bbls);
update well_completions set cumulative_oil_production_bbls = null where cumulative_oil_production_bbls = '';
--437
alter table well_completions alter column cumulative_oil_production_bbls type integer using cumulative_oil_production_bbls::integer;

update well_completions set cumulative_gas_production_mcf = trim(cumulative_gas_production_mcf);
update well_completions set cumulative_gas_production_mcf = null where cumulative_gas_production_mcf = '';
--437
alter table well_completions alter column cumulative_gas_production_mcf type integer using cumulative_gas_production_mcf::integer;

update well_completions set cumulative_water_production_bbls = trim(cumulative_water_production_bbls);
update well_completions set cumulative_water_production_bbls = null where cumulative_water_production_bbls = '';
--437
alter table well_completions alter column cumulative_water_production_bbls type integer using cumulative_water_production_bbls::integer;

update well_completions set completion_report_received = trim(completion_report_received);
alter table well_completions alter column completion_report_received type date using completion_report_received::date;

update well_completions set confidential = trim(confidential);
update well_completions set confidential = 'NO' where confidential = '';
--13416
alter table well_completions alter column confidential type boolean using confidential::boolean;

update well_completions set confidential_status_expires = trim(confidential_status_expires);
update well_completions set confidential_status_expires = null where confidential_status_expires = '';
--10494
alter table well_completions alter column confidential_status_expires type date using confidential_status_expires::date;


alter table well_completions add column well_id integer;
update well_completions set well_id = (select id from wells where api = well_completions.api_number);

alter table well_completions add column completion_year smallint;
update well_completions set completion_year = extract(year from completion_date) where completion_date is not null;

alter table well_completions add column completion_month smallint;
update well_completions set completion_month = extract(month from completion_date) where completion_date is not null;



set search_path to public;
drop table backup.well_completions;
create table backup.well_completions as table well_completions;
drop table well_completions;
create table well_completions (
	id integer not null primary key, 
	well_id integer, 
	completion_date date, 
	completion_year smallint, 
	completion_month smallint, 
	well_name varchar(40), 
	api_number bigint, 
	operator varchar(40), 
	work_type varchar(8), 
	well_status_at_completion varchar(30), 
	well_type_at_completion varchar(20), 
	coalbed_methane_well boolean, 
	county varchar(10), 
	qtr_qtr varchar(4), 
	section smallint, 
	township varchar(5), 
	range varchar(5), 
	surface_location varchar(20), 
	utm_eastings numeric(10,0), 
	utm_northings numeric(10,0), 
	latitude double precision, 
	longitude double precision, 
	field_name varchar(25), 
	development_type varchar(11), 
	total_depth_md integer, 
	total_depth_tvd integer, 
	plug_back_total_depth_md integer, 
	plug_back_total_depth_tvd integer, 
	elevation varchar(8), 
	producing_zone_at_completion varchar(5), 
	perforations varchar(50), 
	oil_24hr_test_bbls integer, 
	gas_24hr_test_mcf integer, 
	water_24hr_test_bbls integer, 
	directional_horizontal varchar(11), 
	total_horizontal_laterals smallint, 
	current_well_status varchar(30), 
	cumulative_oil_production_bbls integer, 
	cumulative_gas_production_mcf integer, 
	cumulative_water_production_bbls integer, 
	completion_report_received date, 
	confidential boolean, 
	confidential_status_expires date, 
	created_at date, 
	updated_at date
);
insert into well_completions (id, well_id, completion_date, completion_year, completion_month, well_name, api_number, operator, work_type, well_status_at_completion, well_type_at_completion, coalbed_methane_well, county, qtr_qtr, section, township, range, surface_location, utm_eastings, utm_northings, latitude, longitude, field_name, development_type, total_depth_md, total_depth_tvd, plug_back_total_depth_md, plug_back_total_depth_tvd, elevation, producing_zone_at_completion, perforations, oil_24hr_test_bbls, gas_24hr_test_mcf, water_24hr_test_bbls, directional_horizontal, total_horizontal_laterals, current_well_status, cumulative_oil_production_bbls, cumulative_gas_production_mcf, cumulative_water_production_bbls, completion_report_received, confidential, confidential_status_expires, created_at, updated_at) select id, well_id, completion_date, completion_year, completion_month, well_name, api_number, operator, work_type, well_status_at_completion, well_type_at_completion, coalbed_methane_well, county, qtr_qtr, section, township, range, surface_location, utm_eastings, utm_northings, latitude, longitude, field_name, development_type, total_depth_md, total_depth_tvd, plug_back_total_depth_md, plug_back_total_depth_tvd, elevation, producing_zone_at_completion, perforations, oil_24hr_test_bbls, gas_24hr_test_mcf, water_24hr_test_bbls, directional_horizontal, total_horizontal_laterals, current_well_status, cumulative_oil_production_bbls, cumulative_gas_production_mcf, cumulative_water_production_bbls, completion_report_received, confidential, confidential_status_expires, '2015-12-17', '2015-12-17' from staging.well_completions order by id;

create index index_well_completions_on_api_number on well_completions (api_number);
create index index_well_completions_on_completion_date on well_completions (completion_date);



---------------------------------------------------------------
---------------------  WELL DISPOSITIONS  ----------------------
---------------------------------------------------------------
--  csv header
-- RPT_PERIOD,ACCT_NUM,ALT_ADDRES,ENTITY,PRODUCT,GRAV_BTU,BEGIN_INV,VOL_PROD,VOL_TRANS,USED_SITE,VENT_FLARE,VOL_OTHER,END_INV,DATE_RECD,AMEND_FLAG

set search_path to import;
drop table well_dispositions;
create table well_dispositions (
	rpt_period date, 
	acct_num varchar(5), 
	alt_addres varchar(1), 
	entity integer, 
	product varchar(2), 
	grav_btu integer, 
	begin_inv integer, 
	vol_prod integer, 
	vol_trans integer, 
	used_site integer, 
	vent_flare integer, 
	vol_other integer, 
	end_inv integer, 
	date_recd date, 
	amend_flag varchar(1)
);

copy well_dispositions from '/Users/troyburke/Data/utah/imported_csv/dispdata.csv' (format csv, delimiter ',', null '');
--1048575
copy well_dispositions from '/Users/troyburke/Data/utah/imported_csv/dispdata1.csv' (format csv, delimiter ',', null '');
--717049
copy well_dispositions from '/Users/troyburke/Data/utah/imported_csv/dispdata2.csv' (format csv, delimiter ',', null '');
--763899
copy well_dispositions from '/Users/troyburke/Data/utah/imported_csv/dispdata3.csv' (format csv, delimiter ',', null '');
--855635


-- move imported data to staging for clean up
set search_path to import;
drop table staging.well_dispositions;
create table staging.well_dispositions as table well_dispositions;
set search_path to staging;

alter table well_dispositions add column id serial primary key not null;

-- clean up scripts
alter table well_dispositions add column entity_id integer;
update well_dispositions set entity_id = (select id from entities where entity_num = well_dispositions.entity);

alter table well_dispositions add column report_year smallint;
update well_dispositions set report_year = extract(year from rpt_period) where rpt_period is not null;

alter table well_dispositions add column report_month smallint;
update well_dispositions set report_month = extract(month from rpt_period) where rpt_period is not null;


set search_path to public;
drop table backup.well_dispositions;
create table backup.well_dispositions as table well_dispositions;
drop table well_dispositions;
create table well_dispositions (
	id integer not null primary key, 
	entity_id integer, 
	rpt_period date, 
	report_year smallint, 
	report_month smallint, 
	acct_num varchar(5), 
	alt_address varchar(1), 
	entity_num integer, 
	product varchar(2), 
	grav_btu integer, 
	begin_inv integer, 
	vol_prod integer, 
	vol_trans integer, 
	used_site integer, 
	vent_flare integer, 
	vol_other integer, 
	end_inv integer, 
	date_recd date, 
	amend_flag varchar(1), 
	created_at date, 
	updated_at date
);

insert into well_dispositions (id, entity_id, rpt_period, report_year, report_month, acct_num, alt_address, entity_num, product, grav_btu, begin_inv, vol_prod, vol_trans, used_site, vent_flare, vol_other, end_inv, date_recd, amend_flag, created_at, updated_at) select id, entity_id, rpt_period, report_year, report_month, acct_num, alt_addres, entity, product, grav_btu, begin_inv, vol_prod, vol_trans, used_site, vent_flare, vol_other, end_inv, date_recd, amend_flag, '2015-12-17', '2015-12-17' from staging.well_dispositions order by id;





---------------------------------------------------------------
---------------------  WELL PRODUCTIONS  ----------------------
---------------------------------------------------------------
--  csv header
-- RPT_PERIOD,ACCT_NUM,ALT_ADDRES,API,PROD_ZONE,ENTITY,WELLSTATUS,WELL_TYPE,DAYS_PROD,OIL_PROD,GAS_PROD,WATER_PROD,DATE_RECD,AMEND_FLAG

set search_path to import;
drop table well_productions;
create table well_productions (
	rpt_period date, 
	acct_num varchar(5), 
	alt_addres varchar(1), 
	api varchar(10), 
	prod_zone varchar(5), 
	entity integer, 
	wellstatus varchar(3), 
	well_type varchar(2), 
	days_prod integer, 
	oil_prod integer, 
	gas_prod integer, 
	water_prod integer, 
	date_recd date, 
	amend_flag varchar(1)
);

copy well_productions from '/Users/troyburke/Data/utah/imported_csv/proddata.csv' (format csv, delimiter ',', null '');
--1048575
copy well_productions from '/Users/troyburke/Data/utah/imported_csv/proddata1.csv' (format csv, delimiter ',', null '');
--723893
copy well_productions from '/Users/troyburke/Data/utah/imported_csv/proddata2.csv' (format csv, delimiter ',', null '');
--846984
copy well_productions from '/Users/troyburke/Data/utah/imported_csv/proddata3.csv' (format csv, delimiter ',', null '');
--1009844

-- move imported data to staging for clean up
set search_path to import;
drop table staging.well_productions;
create table staging.well_productions as table well_productions;
set search_path to staging;

alter table well_productions add column id serial primary key not null;

-- clean up scripts
alter table well_productions alter column api type bigint using api::bigint;

alter table well_productions add column well_id integer;
update well_productions set well_id = (select id from wells where api = well_productions.api);

alter table well_productions add column entity_id integer;
update well_productions set entity_id = (select id from entities where entity_num = well_productions.entity);

alter table well_productions add column report_year smallint;
update well_productions set report_year = extract(year from rpt_period) where rpt_period is not null;

alter table well_productions add column report_month smallint;
update well_productions set report_month = extract(month from rpt_period) where rpt_period is not null;


set search_path to public;
drop table backup.well_dispositions;
create table backup.well_dispositions as table well_dispositions;
drop table well_dispositions;
create table well_dispositions (
	id integer not null primary key, 
	entity_id integer, 
	rpt_period date, 
	report_year smallint, 
	report_month smallint, 
	acct_num varchar(5), 
	alt_address varchar(1), 
	entity_num integer, 
	product varchar(2), 
	grav_btu integer, 
	begin_inv integer, 
	vol_prod integer, 
	vol_trans integer, 
	used_site integer, 
	vent_flare integer, 
	vol_other integer, 
	end_inv integer, 
	date_recd date, 
	amend_flag varchar(1), 
	created_at date, 
	updated_at date
);

insert into well_dispositions (id, entity_id, rpt_period, report_year, report_month, acct_num, alt_address, entity_num, product, grav_btu, begin_inv, vol_prod, vol_trans, used_site, vent_flare, vol_other, end_inv, date_recd, amend_flag, created_at, updated_at) select id, entity_id, rpt_period, report_year, report_month, acct_num, alt_addres, entity, product, grav_btu, begin_inv, vol_prod, vol_trans, used_site, vent_flare, vol_other, end_inv, date_recd, amend_flag, '2015-12-17', '2015-12-17' from staging.well_dispositions order by id;






---------------------------------------------------------------
----------------------  GAS PLANTS  ---------------------------
---------------------------------------------------------------
-- csv header row
-- PLANT_CD,PLANT_NAME,ACCT_NUM,ALT_ADDRES,PLANT_ADDR,PLANT_CITY,PLANTSTATE,PLANT_ZIP,PLANT_LOC,COUNTY,STATUS

set search_path to import;
drop table gas_plants;
create table gas_plants (
	plant_cd varchar(4), 
	plant_name varchar(50), 
	acct_num varchar(5), 
	alt_addres varchar(100), 
	plant_addr varchar(100), 
	plant_city varchar(50), 
	plantstate varchar(2), 
	plant_zip varchar(5), 
	plant_loc varchar(20), 
	county varchar(30), 
	status varchar(1)
);

copy gas_plants from '/Users/troyburke/Data/utah/csv_files/PLNTLOC.csv' (format csv, delimiter ',', null '');
--35

alter table gas_plants add column id serial primary key not null;

alter table gas_plants add column lat double precision;
alter table gas_plants add column long double precision;

update gas_plants set lat = 40.6842588, long = -112.2835806 where plant_cd = 'ALTA';
update gas_plants set lat = 37.2512786, long = -109.3235047 where plant_cd = 'ANET';
update gas_plants set lat = 40.0359790, long = -109.4260919 where plant_cd = 'CHIP';
update gas_plants set lat = 39.0813349, long = -109.2669456 where plant_cd = 'CISC';
update gas_plants set lat = 39.1107521, long = -109.1171632 where plant_cd = 'HARL';
update gas_plants set lat = 40.0504994, long = -109.4639021 where plant_cd = 'IRON';
update gas_plants set lat = 40.9959023, long = -109.2122514 where plant_cd = 'KAST';
update gas_plants set lat = 40.3989222, long = -112.2409402 where plant_cd = 'LINN';
update gas_plants set lat = 38.1633134, long = -109.2752845 where plant_cd = 'LISB';
update gas_plants set lat = 40.9371886, long = -111.1424405 where plant_cd = 'PINE';
update gas_plants set lat = 40.0598260, long = -110.1054824 where plant_cd = 'PVGP';
update gas_plants set lat = 39.6228990, long = -110.8254106 where plant_cd = 'PRIC';
update gas_plants set lat = 39.6228990, long = -110.8254106 where plant_cd = 'PRIR';
update gas_plants set lat = 40.1950333, long = -109.2754188 where plant_cd = 'REDW';
update gas_plants set lat = 40.0360063, long = -109.4449706 where plant_cd = 'STAG';


set search_path to public;
drop table backup.gas_plants;
create table backup.gas_plants as table gas_plants;
drop table gas_plants;
create table gas_plants (
	id integer not null primary key, 
	plant_code varchar(4), 
	plant_name varchar(50), 
	acct_num varchar(5), 
	status varchar(1), 
	county varchar(30), 
	latitude double precision, 
	longitude double precision, 
	plant_location varchar(20), 
	alt_address varchar(100), 
	plant_address varchar(100), 
	plant_city varchar(50), 
	plant_state varchar(2), 
	plant_zip varchar(5), 
	created_at date, 
	updated_at date
);
insert into gas_plants (id, plant_code, plant_name, acct_num, status, county, latitude, longitude, plant_location, alt_address, plant_address, plant_city, plant_state, plant_zip, created_at, updated_at) select id, plant_cd, plant_name, acct_num, status, county, lat, long, plant_loc, alt_addres, plant_addr, plant_city, plantstate, plant_zip, '2015-12-17', '2015-12-17' from import.gas_plants order by plant_cd;



---------------------------------------------------------------
------------------  GAS PLANT OPERATORS  ----------------------
---------------------------------------------------------------
-- csv header row
-- OPER_NAME,ACCT_NUM,ALT_ADDRES,OPER_ADDR,OPER_CITY,OPER_STATE,OPER_ZIP,CONTACT,PHONE

set search_path to import;
drop table gas_plant_operators;
create table gas_plant_operators (
	oper_name varchar(40), 
	acct_num varchar(5), 
	alt_addres varchar(1), 
	oper_addr varchar(35), 
	oper_city varchar(20), 
	oper_state varchar(2), 
	oper_zip varchar(9), 
	contact varchar(20), 
	phone varchar(12)
);

copy gas_plant_operators from '/Users/troyburke/Data/utah/csv_files/PLNTOPER.csv' (format csv, delimiter ',', null '');
--35

alter table gas_plant_operators add column id serial primary key not null;


set search_path to public;
drop table backup.gas_plant_operators;
create table backup.gas_plant_operators as table gas_plant_operators;
drop table gas_plant_operators;
create table gas_plant_operators (
	id integer not null primary key, 
	oper_name varchar(40), 
	acct_num varchar(5), 
	alt_addr varchar(1), 
	oper_addr varchar(35), 
	oper_city varchar(20), 
	oper_state varchar(2), 
	oper_zip varchar(9), 
	contact varchar(20), 
	phone varchar(12), 
	created_at date, 
	updated_at date
);
insert into gas_plant_operators (id, oper_name, acct_num, alt_addr, oper_addr, oper_city, oper_state, oper_zip, contact, phone, created_at, updated_at) select id, oper_name, acct_num, alt_addres, oper_addr, oper_city, oper_state, oper_zip, contact, phone, '2015-12-17', '2015-12-17' from import.gas_plant_operators order by oper_name;




---------------------------------------------------------------
------------------  GAS PLANT ALLOCATIONS  --------------------
---------------------------------------------------------------
-- csv header row
-- PLANT_CD,RPT_PERIOD,DATE_RECD,WELL_ACCT,ENTITY_NUM,API_NUM,WELL_VOL,GAS_FIELD,GAS_SOLD,NGL,REC_SEQ

set search_path to import;
drop table gas_plant_allocations;
create table gas_plant_allocations (
	plant_cd varchar(4), 
	rpt_period date, 
	date_recd date, 
	well_acct varchar(5), 
	entity_num integer, 
	api_num varchar(10), 
	well_vol integer, 
	gas_field integer, 
	gas_sold integer, 
	ngl integer, 
	rec_seq integer
);

copy gas_plant_allocations from '/Users/troyburke/Data/utah/imported_csv/PLNTALOC.csv' (format csv, delimiter ',', null '');
--468056

alter table gas_plant_allocations add column id serial primary key not null;

alter table gas_plant_allocations add column gas_plant_id integer;
update gas_plant_allocations set gas_plant_id = (select id from gas_plants where plant_cd = gas_plant_allocations.plant_cd);

alter table gas_plant_allocations add column report_year smallint;
update gas_plant_allocations set report_year = extract(year from rpt_period) where rpt_period is not null;

alter table gas_plant_allocations add column report_month smallint;
update gas_plant_allocations set report_month = extract(month from rpt_period) where rpt_period is not null;


set search_path to public;
drop table backup.gas_plant_allocations;
create table backup.gas_plant_allocations as table gas_plant_allocations;
drop table gas_plant_allocations;
create table gas_plant_allocations (
	id integer not null primary key, 
	gas_plant_id integer, 
	plant_cd varchar(4),
	report_year smallint, 
	report_month smallint,  
	rpt_period date, 
	date_recd date, 
	well_acct varchar(5), 
	entity_num integer, 
	api_num varchar(10), 
	well_vol integer, 
	gas_field integer, 
	gas_sold integer, 
	ngl integer, 
	rec_seq integer, 
	created_at date, 
	updated_at date
);

insert into gas_plant_allocations (id, gas_plant_id, plant_cd, report_year, report_month, rpt_period, date_recd, well_acct, entity_num, api_num, well_vol, gas_field, gas_sold, ngl, rec_seq, created_at, updated_at) select id, gas_plant_id, plant_cd, report_year, report_month, rpt_period, date_recd, well_acct, entity_num, api_num, well_vol, gas_field, gas_sold, ngl, rec_seq, '2015-12-17', '2015-12-17' from import.gas_plant_allocations order by report_year, report_month, plant_cd;



---------------------------------------------------------------
--------------------  GAS PLANT PRODUCTS  ---------------------
---------------------------------------------------------------
-- csv header row
-- PLANT_CD,RPT_PERIOD,DATE_RECD,PRODUCT,OPEN_STOCK,RECEIPTS,PRODUCTION,DELIVERIES,CLOS_STOCK,AMEND_FLAG

set search_path to import;
drop table gas_plant_products;
create table gas_plant_products (
	plant_cd varchar(4), 
	rpt_period date, 
	date_recd date, 
	product varchar(10), 
	open_stock integer, 
	receipts integer, 
	production integer, 
	deliveries integer, 
	clos_stock integer, 
	amend_flag varchar(1)
);

copy gas_plant_products from '/Users/troyburke/Data/utah/csv_files/PLNTPROD.csv' (format csv, delimiter ',', null '');
--11379

alter table gas_plant_products add column id serial primary key not null;

alter table gas_plant_products add column gas_plant_id integer;
update gas_plant_products set gas_plant_id = (select id from gas_plants where plant_cd = gas_plant_products.plant_cd);

alter table gas_plant_products add column report_year smallint;
update gas_plant_products set report_year = extract(year from rpt_period) where rpt_period is not null;

alter table gas_plant_products add column report_month smallint;
update gas_plant_products set report_month = extract(month from rpt_period) where rpt_period is not null;


set search_path to public;
drop table backup.gas_plant_products;
create table backup.gas_plant_products as table gas_plant_products;
drop table gas_plant_products;
create table gas_plant_products (
	id integer not null primary key, 
	gas_plant_id integer, 
	plant_cd varchar(4),
	report_year smallint, 
	report_month smallint,  
	rpt_period date, 
	date_recd date, 
	product varchar(10), 
	open_stock integer, 
	receipts integer, 
	production integer, 
	deliveries integer, 
	clos_stock integer, 
	amend_flag varchar(1), 
	created_at date, 
	updated_at date
);

insert into gas_plant_products (id, gas_plant_id, plant_cd, report_year, report_month, rpt_period, date_recd, product, open_stock, receipts, production, deliveries, clos_stock, amend_flag, created_at, updated_at) select id, gas_plant_id, plant_cd, report_year, report_month, rpt_period, date_recd, product, open_stock, receipts, production, deliveries, clos_stock, amend_flag, '2015-12-17', '2015-12-17' from import.gas_plant_products order by report_year, report_month, plant_cd;


---------------------------------------------------------------
-------------------  GAS PLANT SUMMARIES  ---------------------
---------------------------------------------------------------
-- csv header row
-- PLANT_CD,ACCT_NUM,RPT_PERIOD,DATE_RECD,GATHER_INT,WET_DISP,PLANT_INT,GAS_PLANT,GAS_LINE,GAS_STORGE,PLANT_FUEL,VENT_FLARE,SHRINKAGE,FIELD_USE,LIFT_GAS,PRES_MAINT,CYCLED,UNDRGRD_ST,OTHR_PLANT,TRANSMISSN,METER_DIFF,OTHER_DISP,BTU_SOLD,SULFUR,HELIUM,AMEND_FLAG

set search_path to import;
drop table gas_plant_summaries;
create table gas_plant_summaries (
	plant_cd varchar(4), 
	acct_num varchar(5), 
	rpt_period date, 
	date_recd date, 
	gather_int integer, 
	wet_disp integer, 
	plant_int integer, 
	gas_plant integer, 
	gas_line integer, 
	gas_storge integer, 
	plant_fuel integer, 
	vent_flare integer, 
	shrinkage integer, 
	field_use integer, 
	lift_gas integer, 
	pres_maint integer, 
	cycled integer, 
	undrgrd_st integer, 
	othr_plant integer, 
	transmissn integer, 
	meter_diff integer, 
	other_disp integer, 
	btu_sold integer, 
	sulfur integer, 
	helium integer, 
	amend_flag varchar(1)
);

copy gas_plant_summaries from '/Users/troyburke/Data/utah/csv_files/PLNTSUMM.csv' (format csv, delimiter ',', null '');
--5218

alter table gas_plant_summaries add column id serial primary key not null;

alter table gas_plant_summaries add column gas_plant_id integer;
update gas_plant_summaries set gas_plant_id = (select id from gas_plants where plant_cd = gas_plant_summaries.plant_cd);

alter table gas_plant_summaries add column report_year smallint;
update gas_plant_summaries set report_year = extract(year from rpt_period) where rpt_period is not null;

alter table gas_plant_summaries add column report_month smallint;
update gas_plant_summaries set report_month = extract(month from rpt_period) where rpt_period is not null;


set search_path to public;
drop table backup.gas_plant_summaries;
create table backup.gas_plant_summaries as table gas_plant_summaries;
drop table gas_plant_summaries;
create table gas_plant_summaries (
	id integer not null primary key, 
	gas_plant_id integer, 
	plant_cd varchar(4),
	report_year smallint, 
	report_month smallint,  
	rpt_period date, 
	date_recd date, 
	gather_int integer, 
	wet_disp integer, 
	plant_int integer, 
	gas_plant integer, 
	gas_line integer, 
	gas_storge integer, 
	plant_fuel integer, 
	vent_flare integer, 
	shrinkage integer, 
	field_use integer, 
	lift_gas integer, 
	pres_maint integer, 
	cycled integer, 
	undrgrd_st integer, 
	othr_plant integer, 
	transmissn integer, 
	meter_diff integer, 
	other_disp integer, 
	btu_sold integer, 
	sulfur integer, 
	helium integer, 
	amend_flag varchar(1), 
	created_at date, 
	updated_at date
);

insert into gas_plant_summaries (id, gas_plant_id, plant_cd, report_year, report_month, rpt_period, date_recd, gather_int, wet_disp, plant_int, gas_plant, gas_line, gas_storge, plant_fuel, vent_flare, shrinkage, field_use, lift_gas, pres_maint, cycled, undrgrd_st, othr_plant, transmissn, meter_diff, other_disp, btu_sold, sulfur, helium, amend_flag, created_at, updated_at) select id, gas_plant_id, plant_cd, report_year, report_month, rpt_period, date_recd, gather_int, wet_disp, plant_int, gas_plant, gas_line, gas_storge, plant_fuel, vent_flare, shrinkage, field_use, lift_gas, pres_maint, cycled, undrgrd_st, othr_plant, transmissn, meter_diff, other_disp, btu_sold, sulfur, helium, amend_flag, '2015-12-17', '2015-12-17' from import.gas_plant_summaries order by report_year, report_month, plant_cd;




set search_path to import;
drop table environmental_incidents;
create table environmental_incidents (
	id integer not null primary key, 
	report_text text, 
	null_report boolean not null default false, 
	report_taken_by varchar(100), 
	report_date_time varchar(100), 
	reporting_party_name varchar(100), 
	reporting_party_title varchar(100), 
	reporting_party_phone varchar(50), 
	company_name varchar(100), 
	discovered_date_time varchar(100), 
	responsible_party_name varchar(100), 
	responsible_party_phone varchar(50), 
	responsible_party_address varchar(100), 
	incident_address varchar(100), 
	nearest_town varchar(50), 
	county varchar(50), 
	highway varchar(50), 
	mile_marker varchar(50), 
	utm varchar(100), 
	land_ownership varchar(50), 
	incident_summary text, 
	chemicals_reported varchar(1000), 
	impacted_media varchar(1000), 
	is_og_operator boolean not null default false, 
	is_drill_or_exercise boolean not null default false, 
	is_production_water boolean not null default false, 
	is_crude_oil boolean not null default false, 
	is_natural_gas boolean not null default false, 
	is_propane boolean not null default false, 
	is_petroleum boolean not null default false, 
	is_condensate boolean not null default false, 
	is_spill boolean not null default false, 
	is_groundwater boolean not null default false
);
copy environmental_incidents from '/Users/troyburke/Data/utah/table_dumps_2016/utah_environmental_incidents.csv' (format csv, delimiter ',', null '');

set search_path to import;
drop table staging.environmental_incidents;
create table staging.environmental_incidents as table environmental_incidents;
set search_path to staging;

alter table environmental_incidents drop column report_text;
delete from environmental_incidents where null_report is true;
alter table environmental_incidents drop column null_report;
delete from environmental_incidents where is_drill_or_exercise is true;
alter table environmental_incidents drop column is_drill_or_exercise;

update environmental_incidents set report_taken_by = upper(trim(report_taken_by));
update environmental_incidents set report_taken_by = null where report_taken_by = '';
--0
alter table environmental_incidents alter column report_taken_by type varchar(35);

update environmental_incidents set report_date_time = trim(report_date_time);
update environmental_incidents set report_date_time = null where report_date_time = '';
--0
alter table environmental_incidents alter column report_date_time type varchar(20);

update environmental_incidents set reporting_party_name = upper(trim(reporting_party_name));
update environmental_incidents set reporting_party_name = null where reporting_party_name = '';
--0
alter table environmental_incidents alter column reporting_party_name type varchar(35);

update environmental_incidents set reporting_party_title = upper(trim(reporting_party_title));
update environmental_incidents set reporting_party_title = null where reporting_party_title = '';
--0
alter table environmental_incidents alter column reporting_party_title type varchar(35);

update environmental_incidents set reporting_party_phone = trim(reporting_party_phone);
update environmental_incidents set reporting_party_phone = null where reporting_party_phone = '';
--0
alter table environmental_incidents alter column reporting_party_phone type varchar(20);

update environmental_incidents set company_name = upper(trim(company_name));
update environmental_incidents set company_name = null where company_name = '';
--0
alter table environmental_incidents alter column company_name type varchar(50);

update environmental_incidents set discovered_date_time = trim(discovered_date_time);
update environmental_incidents set discovered_date_time = null where discovered_date_time = '';
--0
alter table environmental_incidents alter column discovered_date_time type varchar(20);

update environmental_incidents set responsible_party_name = upper(trim(responsible_party_name));
update environmental_incidents set responsible_party_name = null where responsible_party_name = '';
--0
alter table environmental_incidents alter column responsible_party_name type varchar(100);

update environmental_incidents set responsible_party_phone = trim(responsible_party_phone);
update environmental_incidents set responsible_party_phone = null where responsible_party_phone = '';
--0
alter table environmental_incidents alter column responsible_party_phone type varchar(25);

update environmental_incidents set responsible_party_address = trim(responsible_party_address);
update environmental_incidents set responsible_party_address = null where responsible_party_address = '';
--0
alter table environmental_incidents alter column responsible_party_address type varchar(100);

update environmental_incidents set incident_address = trim(incident_address);
update environmental_incidents set incident_address = null where incident_address = '';
--0
alter table environmental_incidents alter column incident_address type varchar(100);

update environmental_incidents set nearest_town = upper(trim(nearest_town));
update environmental_incidents set nearest_town = null where nearest_town = '';
--0
alter table environmental_incidents alter column nearest_town type varchar(30);

update environmental_incidents set county = upper(trim(county));
update environmental_incidents set county = null where county = '';
--0
alter table environmental_incidents alter column county type varchar(10);

update environmental_incidents set highway = trim(highway);
update environmental_incidents set highway = null where highway = '';
--0
alter table environmental_incidents alter column highway type varchar(30);

update environmental_incidents set mile_marker = trim(mile_marker);
update environmental_incidents set mile_marker = null where mile_marker = '';
--0
alter table environmental_incidents alter column mile_marker type varchar(6);

update environmental_incidents set utm = trim(utm);
update environmental_incidents set utm = null where utm = '';
--0
alter table environmental_incidents alter column utm type varchar(30);

update environmental_incidents set land_ownership = trim(land_ownership);
update environmental_incidents set land_ownership = null where land_ownership = '';
--0
alter table environmental_incidents alter column land_ownership type varchar(9);

update environmental_incidents set chemicals_reported = upper(trim(chemicals_reported));
update environmental_incidents set chemicals_reported = null where chemicals_reported = '';
--0
alter table environmental_incidents alter column chemicals_reported type varchar(255);

update environmental_incidents set impacted_media = trim(impacted_media);
update environmental_incidents set impacted_media = null where impacted_media = '';
--0
alter table environmental_incidents alter column impacted_media type varchar(255);



set search_path to public;
drop table backup.environmental_incidents;
create table backup.environmental_incidents as table environmental_incidents;
drop table environmental_incidents;
create table environmental_incidents (
	id integer not null primary key, 
	report_taken_by varchar(35), 
	report_date_time varchar(20), 
	reporting_party_name varchar(35), 
	reporting_party_title varchar(35), 
	reporting_party_phone varchar(20), 
	company_name varchar(50), 
	discovered_date_time varchar(20), 
	responsible_party_name varchar(100), 
	responsible_party_phone varchar(25), 
	responsible_party_address varchar(100), 
	incident_address varchar(100), 
	nearest_town varchar(30), 
	county varchar(10), 
	highway varchar(30), 
	mile_marker varchar(6), 
	utm varchar(30), 
	land_ownership varchar(9), 
	incident_summary text, 
	chemicals_reported varchar(255), 
	impacted_media varchar(255), 
	is_og_operator boolean not null default false, 
	is_production_water boolean not null default false, 
	is_crude_oil boolean not null default false, 
	is_natural_gas boolean not null default false, 
	is_propane boolean not null default false, 
	is_petroleum boolean not null default false, 
	is_condensate boolean not null default false, 
	is_spill boolean not null default false, 
	is_groundwater boolean not null default false, 
	created_at date, 
	updated_at date
);

insert into environmental_incidents (id, report_taken_by, report_date_time, reporting_party_name, reporting_party_title, reporting_party_phone, company_name, discovered_date_time, responsible_party_name, responsible_party_phone, responsible_party_address, incident_address, nearest_town, county, highway, mile_marker, utm, land_ownership, incident_summary, chemicals_reported, impacted_media, is_og_operator, is_production_water, is_crude_oil, is_natural_gas, is_propane, is_petroleum, is_condensate, is_spill, is_groundwater, created_at, updated_at) select id, report_taken_by, report_date_time, reporting_party_name, reporting_party_title, reporting_party_phone, company_name, discovered_date_time, responsible_party_name, responsible_party_phone, responsible_party_address, incident_address, nearest_town, county, highway, mile_marker, utm, land_ownership, incident_summary, chemicals_reported, impacted_media, is_og_operator, is_production_water, is_crude_oil, is_natural_gas, is_propane, is_petroleum, is_condensate, is_spill, is_groundwater, '2016-01-01', '2016-01-01' from staging.environmental_incidents order by id;
--9466


set search_path to import;
drop table environmental_incident_chemicals;
create table environmental_incident_chemicals (
	environmental_incident_id integer, 
	chemical_name varchar(250)
);
copy environmental_incident_chemicals from '/Users/troyburke/Data/utah/table_dumps_2016/utah_environmental_incident_chemicals.csv' (format csv, delimiter ',', null '');

set search_path to public;
create table environmental_incident_chemicals (
	environmental_incident_id integer, 
	chemical_name varchar(250)
);
insert into environmental_incident_chemicals (environmental_incident_id, chemical_name) select environmental_incident_id, chemical_name from import.environmental_incident_chemicals order by environmental_incident_id;
delete from environmental_incident_chemicals where environmental_incident_id not in (select id from environmental_incidents);


--utah environmental incidents
COPY (select * from utah_environmental_incidents order by id) TO '/Users/troyburke/Data/utah/table_dumps_2016/utah_environmental_incidents.csv' WITH CSV;
--10016

--utah env incident chemicals
COPY (select * from utah_environmental_incident_chemicals order by utah_environmental_incident_id) TO '/Users/troyburke/Data/utah/table_dumps_2016/utah_environmental_incident_chemicals.csv' WITH CSV;
--9586



pg_dump -t 'public.*' utogm_development > utogm.sql


psql utogm_production utogm < /home/trbu5654/utogm/utogm.sql



create index index_fields_on_field_num on fields (field_num);
create index index_gas_plants_on_plant_code on gas_plants (plant_code);
create index index_gas_plants_on_acct_num on gas_plants (acct_num);
create index index_gas_plant_summaries_on_gas_plant_id on gas_plant_summaries (gas_plant_id);
create index index_gas_plant_summaries_on_report_year on gas_plant_summaries (report_year);
create index index_gas_plant_summaries_on_report_month on gas_plant_summaries (report_month);
create index index_gas_plant_summaries_on_rpt_period on gas_plant_summaries (rpt_period);
create index index_gas_plant_products_on_gas_plant_id on gas_plant_products (gas_plant_id);
create index index_gas_plant_products_on_plant_cd on gas_plant_products (plant_cd);
create index index_gas_plant_summaries_on_plant_cd on gas_plant_summaries (plant_cd);
create index index_gas_plant_products_on_report_year on gas_plant_products (report_year);
create index index_gas_plant_products_on_report_month on gas_plant_products (report_month);
create index index_gas_plant_products_on_rpt_period on gas_plant_products (rpt_period);
create index index_gas_plant_operators_on_acct_num on gas_plant_operators (acct_num);
create index index_gas_plant_allocations_on_gas_plant_id on gas_plant_allocations (gas_plant_id);
create index index_gas_plant_allocations_on_plant_cd on gas_plant_allocations (plant_cd);
create index index_gas_plant_allocations_on_report_year on gas_plant_allocations (report_year);
create index index_gas_plant_allocations_on_report_month on gas_plant_allocations (report_month);
create index index_gas_plant_allocations_on_rpt_period on gas_plant_allocations (rpt_period);
create index index_zones_on_code on zones (code);
create index index_wells_on_api on wells (api);
create index index_wells_on_wellstatus on wells (wellstatus);
create index index_wells_on_well_type on wells (well_type);
create index index_wells_on_well_operator_id on wells (well_operator_id);
create index index_well_completions_on_well_id on well_completions (well_id);
create index index_well_completions_on_completion_date on well_completions (completion_date);
create index index_well_completions_on_completion_year on well_completions (completion_year);
create index index_well_completions_on_completion_month on well_completions (completion_month);
create index index_well_completions_on_completion_api_number on well_completions (api_number);
create index index_well_histories_on_well_id on well_histories (well_id);
create index index_well_histories_on_api on well_histories (api);



import  staging  public   table
  X        na      X      api_counties
  X                X      entities
  X                       environmental_incident_chemicals
  X                       environmental_incidents
  X        na      X      fields
  X        na      X      gas_plant_allocations
  X        na      X      gas_plant_operators
  X        na      X      gas_plant_products
  X        na      X      gas_plant_summaries
  X        na      X      gas_plants
  X        X       X      well_completions
  X        X       X      well_dispositions
  X        X       X      well_histories
  X        X       X      well_operators
  X        X       X      well_productions
  X        na      X      well_statuses
  X        na      X      well_types
  X        X       X      wells
  X        na      X      zones


























--utah frac focus scrape statuses
COPY (select api_number, frac_focus_status from utogm_scrape_statuses order by api_number desc) TO '/Users/troyburke/Data/utah/table_dumps_2016/utah_frac_focus_well_scrape_statuses.csv' WITH CSV;
--34168



--utah well to road distances
COPY (select well_api, county_name, county_fips, lat, long, road_gid, road_fullname, road_streetname, road_direction, closest_point_lat, closest_point_long, distance, closest_direction, wind_direction, wind_dir_suspect from utah_well_road_distances order by well_api desc) TO '/Users/troyburke/Data/utah/table_dumps_2016/utah_well_to_road_distances.csv' WITH CSV;
--8759























