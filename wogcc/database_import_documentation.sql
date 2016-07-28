
drop table pa_wh_wells;
create table pa_wh_wells (
	apino real,
	company varchar(100),
	wn varchar(50),
	unit_lease varchar(50),
	lease_no varchar(50),
	field_name varchar(50),
	horiz_dir varchar(10), 
	land_type real, 
	county integer,
	county_name varchar(30), 
	--permit varchar(5), 
	--land_type smallint, 
	sec real,
	twp real,
	t_dir varchar(1),
	rge real,
	r_dir varchar(1),
	qtr1 varchar(2),
	qtr2 varchar(2),
	lon double precision,
	lat double precision,
	foot1 varchar(20),
	foot2 varchar(20),
	elev varchar(10),
	elevkb varchar(10), 
	bsec real, 
	btwp real, 
	bt_dir varchar(1), 
	brge real, 
	br_dir varchar(1), 
	bqtr1 varchar(2), 
	bqtr2 varchar(2), 
	blon double precision, 
	blat double precision, 
	botform varchar(50),
	well_class varchar(2),
	td real,
	pb real,
	rn varchar(50),
	coalbed boolean,
	status varchar(2),
	statusdate varchar(20),
	--stat_day varchar(2), 
	--stat_month varchar(2), 
	--stat_year varchar(4), 
	capino varchar(12),
	--rn varchar(50), 
	--res_code smallint, 
	--form_2_status varchar(2), 
	--form_2_month varchar(2), 
	--form_2_year varchar(4), 
	--cumm_gas real, 
	--cumm_water real, 
	--hold_1 varchar(12), 
	--hold_2 varchar(12), 
	--ap_month varchar(2), 
	--ap_day varchar(2), 
	--ap_year varchar(4), 
	--approved varchar(12) 
	firstspud varchar(12),
	firstcomp varchar(12)
);

copy pa_wh_wells from '/Users/troyburke/Data/wogcc/010616_Wells/010616PA.csv' (format csv, delimiter ',', null '');
--53391
copy pa_wh_wells from '/Users/troyburke/Data/wogcc/010616_Wells/010616WH.csv' (format csv, delimiter ',', null '');
--67031


"APINO","COMPANY","WN","UNIT_LEASE","Lease_no","FIELD_NAME","COUNTY","PERMIT","LAND_TYPE","SEC","TWP","T_DIR","RGE","R_DIR","QTR1","QTR2","LON","LAT","FOOT1","FOOT2","ELEV","WELL_CLASS","TD","STATUS","STATDAY","STATMONTH","STATYEAR","CAPINO","RN","RES_CODE","FORM2STAT","FORM2MON","FORM2YEAR","CUM_GAS","CUM_WATER","hold1","hold2","apmonth","apday","apyear","approved"

drop table og_wells;
create table og_wells (
	apino real,
	company varchar(100),
	wn varchar(50),
	unit_lease varchar(50),
	lease_no varchar(50),
	field_name varchar(50),
	--horiz_dir varchar(10), 
	--land_type real,
	county integer,
	--county_name varchar(30), 
	permit varchar(5), 
	land_type real, 
	sec real,
	twp real,
	t_dir varchar(1),
	rge real,
	r_dir varchar(1),
	qtr1 varchar(2),
	qtr2 varchar(2),
	lon double precision,
	lat double precision,
	foot1 varchar(20),
	foot2 varchar(20),
	elev varchar(10),
	--elevkb varchar(10), 
	--bsec real, 
	--btwp real, 
	--bt_dir varchar(1), 
	--brge real, 
	--br_dir varchar(1), 
	--bqtr1 varchar(2), 
	--bqtr2 varchar(2), 
	--blon double precision, 
	--blat double precision, 
	--botform varchar(50),
	well_class varchar(2),
	td real,
	--pb real,
	--rn varchar(50),
	--coalbed boolean,
	status varchar(2),
	--statusdate varchar(20),
	stat_day varchar(2), 
	stat_month varchar(2), 
	stat_year varchar(4), 
	capino varchar(12),
	rn varchar(50), 
	res_code smallint, 
	form_2_status varchar(2), 
	form_2_month varchar(2), 
	form_2_year varchar(4), 
	cumm_gas real, 
	cumm_water real, 
	hold_1 varchar(12), 
	hold_2 varchar(12), 
	ap_month varchar(2), 
	ap_day varchar(2), 
	ap_year varchar(4), 
	approved varchar(12) 
	--firstspud varchar(12),
	--firstcomp varchar(12)
);

copy og_wells from '/Users/troyburke/Data/wogcc/CBMWells010816.txt' (format csv, delimiter ',', null '');
--46907


drop table wells;
create table wells (
	apino real,
	company varchar(100),
	wn varchar(50),
	unit_lease varchar(50),
	lease_no varchar(50),
	field_name varchar(50),
	horiz_dir varchar(10),
	land_type smallint,
	county integer,
	county_name varchar(30),
	permit varchar(5), 
	sec real,
	twp real,
	t_dir varchar(1),
	rge real,
	r_dir varchar(1),
	qtr1 varchar(2),
	qtr2 varchar(2),
	lon double precision,
	lat double precision,
	foot1 varchar(20),
	foot2 varchar(20),
	elev varchar(10),
	elevkb varchar(10),
	bsec real,
	btwp real,
	bt_dir varchar(1),
	brge real,
	br_dir varchar(1),
	bqtr1 varchar(2),
	bqtr2 varchar(2),
	blon double precision,
	blat double precision,
	botform varchar(50),
	well_class varchar(2),
	td real,
	pb real,
	rn varchar(50),
	coalbed boolean,
	status varchar(2),
	statusdate varchar(20),
	stat_day varchar(2), 
	stat_month varchar(2), 
	stat_year varchar(4), 
	capino varchar(12),
	res_code smallint,  
	form_2_status varchar(2),  
	form_2_month varchar(2),  
	form_2_year varchar(4),  
	cumm_gas real, 
	cumm_water real, 
	hold_1 varchar(12), 
	hold_2 varchar(12), 
	ap_month varchar(2), 
	ap_day varchar(2), 
	ap_year varchar(4), 
	approved varchar(12), 
	firstspud varchar(12),
	firstcomp varchar(12)
);


insert into wells (apino, company, wn, unit_lease, lease_no, field_name, horiz_dir, land_type, county, county_name, sec, twp, t_dir, rge, r_dir, qtr1, qtr2, lon, lat, foot1, foot2, elev, elevkb, bsec, btwp, bt_dir, brge, br_dir, bqtr1, bqtr2, blon, blat, botform, well_class, td, pb, rn, coalbed, status, statusdate, capino, firstspud, firstcomp) 
select apino, company, wn, unit_lease, lease_no, field_name, horiz_dir, land_type, county, county_name, sec, twp, t_dir, rge, r_dir, qtr1, qtr2, lon, lat, foot1, foot2, elev, elevkb, bsec, btwp, bt_dir, brge, br_dir, bqtr1, bqtr2, blon, blat, botform, well_class, td, pb, rn, coalbed, status, statusdate, capino, firstspud, firstcomp 
from pa_wh_wells order by apino;
--120422

create index index_wells_on_apino on wells (apino);
create index index_og_wells_on_apino on og_wells (apino);

alter table og_wells add column not_in_wells boolean not null default false;ALTER TABLE
update og_wells set not_in_wells = 't' where apino not in (select apino from wells);
--15028

alter table wells add column from_og_table boolean not null default false;

insert into wells (apino, company, wn, unit_lease, lease_no, field_name, county, permit, land_type, sec, twp, t_dir, rge, r_dir, qtr1, qtr2, lon, lat, foot1, foot2, elev, well_class, td, status, stat_day, stat_month, stat_year, capino, rn, res_code, form_2_status, form_2_month, form_2_year, cumm_gas, cumm_water, hold_1, hold_2, ap_month, ap_day, ap_year, approved, from_og_table) 
select apino, company, wn, unit_lease, lease_no, field_name, county, permit, land_type, sec, twp, t_dir, rge, r_dir, qtr1, qtr2, lon, lat, foot1, foot2, elev, well_class, td, status, stat_day, stat_month, stat_year, capino, rn, res_code, form_2_status, form_2_month, form_2_year, cumm_gas, cumm_water, hold_1, hold_2, ap_month, ap_day, ap_year, approved, 't' 
from og_wells where not_in_wells is true order by apino;
--15028



update wells set permit = (select permit from og_wells where apino = wells.apino) where from_og_table is false;
update wells set stat_day = (select stat_day from og_wells where apino = wells.apino) where from_og_table is false;
update wells set stat_month = (select stat_month from og_wells where apino = wells.apino) where from_og_table is false;
update wells set stat_year = (select stat_year from og_wells where apino = wells.apino) where from_og_table is false;
update wells set res_code = (select res_code from og_wells where apino = wells.apino) where from_og_table is false;
update wells set form_2_status = (select form_2_status from og_wells where apino = wells.apino) where from_og_table is false;
update wells set form_2_month = (select form_2_month from og_wells where apino = wells.apino) where from_og_table is false;
update wells set form_2_year = (select form_2_year from og_wells where apino = wells.apino) where from_og_table is false;
update wells set cumm_gas = (select cumm_gas from og_wells where apino = wells.apino) where from_og_table is false;
update wells set cumm_water = (select cumm_water from og_wells where apino = wells.apino) where from_og_table is false;
update wells set hold_1 = (select hold_1 from og_wells where apino = wells.apino) where from_og_table is false;
update wells set hold_2 = (select hold_2 from og_wells where apino = wells.apino) where from_og_table is false;
update wells set ap_month = (select ap_month from og_wells where apino = wells.apino) where from_og_table is false;
update wells set ap_day = (select ap_day from og_wells where apino = wells.apino) where from_og_table is false;
update wells set ap_year = (select ap_year from og_wells where apino = wells.apino) where from_og_table is false;
update wells set approved = (select approved from og_wells where apino = wells.apino) where from_og_table is false;

alter table wells add column well_api_number varchar(12);
update wells set well_api_number = '49-' || lpad(county::varchar,3,'0') || '-' || right(apino::varchar,5);

alter table wells alter column statusdate type varchar using statusdate::varchar;

update wells set statusdate = replace(statusdate,'.00000','');

select statusdate, left(statusdate,4) || '-' || substr(statusdate,5,2) || '-' || right(statusdate,2) from wells where statusdate is not null and length(statusdate) = 8;

update wells set statusdate = left(statusdate,4) || '-' || substr(statusdate,5,2) || '-' || right(statusdate,2) where statusdate is not null and length(statusdate) = 8;

update wells set statusdate = null where statusdate = '-24982';
update wells set statusdate = null where statusdate = '2099009';

select statusdate, left(statusdate,4) || '-' || substr(statusdate,5,1) || '-' || right(statusdate,2) from wells where statusdate is not null and length(statusdate) = 7;

update wells set statusdate = left(statusdate,4) || '-' || substr(statusdate,5,1) || '-' || right(statusdate,2) where statusdate is not null and length(statusdate) = 7;

update wells set statusdate = null where statusdate = '130605';
update wells set statusdate = '2007-09-04' where statusdate = '200794';
update wells set statusdate = '2007-09-05' where statusdate = '200795';
update wells set statusdate = '2007-09-07' where statusdate = '200797';
update wells set statusdate = '2015-04-08' where statusdate = '201548';
update wells set statusdate = '2007-09-06' where statusdate = '200796';
update wells set statusdate = '2001-02-01' where statusdate = '200102';

update wells set statusdate = '2006-12-01' where statusdate = '1006-12-01';
update wells set statusdate = '2016-01-04' where statusdate = '2016-04-04';
update wells set statusdate = '2004-08-10' where statusdate = '2040-8-10';
update wells set statusdate = '2009-09-09' where statusdate = '2099-09-09';
update wells set statusdate = '2015-03-03' where statusdate = '3015-03-03';
update wells set statusdate = '1999-09-09' where statusdate = '9999-09-09';

update wells set statusdate = '1992-02-01' where statusdate = '1992-0-02';
update wells set statusdate = '2007-09-04' where statusdate = '2007-0-94';
update wells set statusdate = '2010-12-01' where statusdate = '2010-0-12';
update wells set statusdate = '2010-08-09' where statusdate = '2010-0-89';
update wells set statusdate = '2005-06-30' where statusdate = '2005-06-31';--904
update wells set statusdate = '1976-01-01' where statusdate = '1976-0-10';
update wells set statusdate = '2005-04-30' where statusdate = '2005-04-31';--11
update wells set statusdate = '1999-04-30' where statusdate = '1999-04-31';
update wells set statusdate = '2000-01-04' where statusdate = '2000-00-14';
update wells set statusdate = '2002-09-30' where statusdate = '2002-09-31';--5
update wells set statusdate = '1999-02-28' where statusdate = '1999-02-29';--1
update wells set statusdate = '2002-06-30' where statusdate = '2002-06-31';

alter table wells alter column statusdate type date using statusdate::date;




create table well_land_types (
	id integer,
	code integer,
	description varchar(20)
);

insert into well_land_types (id, code, description)
values (1, 10, 'Federal/Unknown');
insert into well_land_types (code, description)
values (2, 11, 'Federal/Federal');
insert into well_land_types (code, description)
values (3, 12, 'Federal/Fee');
insert into well_land_types (code, description)
values (4, 13, 'Federal/Fee');
insert into well_land_types (code, description)
values (5, 14, 'Federal/State');
insert into well_land_types (code, description)
values (6, 20, 'Patented');
insert into well_land_types (code, description)
values (7, 23, 'Fee/Fee');
insert into well_land_types (code, description)
values (8, 30, 'Fee');
insert into well_land_types (code, description)
values (9, 31, 'Fee/Federal');
insert into well_land_types (code, description)
values (10, 34, 'Fee/State');
insert into well_land_types (code, description)
values (11, 40, 'State');
insert into well_land_types (code, description)
values (12, 41, 'State/Federal');
insert into well_land_types (code, description)
values (13, 43, 'State/Fee');
insert into well_land_types (code, description)
values (14, 60, 'Tribal');
insert into well_land_types (code, description)
values (15, 61, 'Tribal/Federal');
insert into well_land_types (code, description)
values (16, 63, 'Tribal/Fee');
insert into well_land_types (code, description)
values (17, 64, 'Tribal/State');
insert into well_land_types (code, description)
values (18, 81, 'MM /Fed');
insert into well_land_types (code, description)
values (19, 83, 'MM /Fee');
insert into well_land_types (code, description)
values (20, 84, 'MM /State');
insert into well_land_types (code, description)
values (21, 85, 'MM-State/Fee');
insert into well_land_types (code, description)
values (22, 91, 'MM w-Fed/Fed');
insert into well_land_types (code, description)
values (23, 93, 'MM w-Fed/Fee');
insert into well_land_types (code, description)
values (24, 94, 'MM w-Fed/State');



create table well_classes (
	id integer,
	code varchar(2),
	description varchar(50)
);

insert into well_classes  (code, description)
values (1, 'AP', 'Active Permit');
insert into well_classes  (code, description)
values (2, 'C', 'Condensate');
insert into well_classes  (code, description)
values (2, 'CB', null);
insert into well_classes  (code, description)
values (3, 'D', 'Disposal');
insert into well_classes  (code, description)
values (4, 'DO', 'Disposal Orphaned');
insert into well_classes  (code, description)
values (5, 'G', 'Gas Well');
insert into well_classes  (code, description)
values (6, 'GO', 'Gas Orphaned');
insert into well_classes  (code, description)
values (7, 'GS', 'Gas Storage');
insert into well_classes  (code, description)
values (8, 'I', 'Injector Well');
insert into well_classes  (code, description)
values (9, 'IO', 'Injector Orphaned');
insert into well_classes  (code, description)
values (10, 'LW', 'Landowner Water Well');
insert into well_classes  (code, description)
values (11, 'M', 'Monitor Well');
insert into well_classes  (code, description)
values (12, 'MO', 'Monitor Well Orphaned');
insert into well_classes  (code, description)
values (13, 'MW', 'Monitor Well (Not for Form 2 Reporting)');
insert into well_classes  (code, description)
values (14, 'NA', 'Not Applicable');
insert into well_classes  (code, description)
values (15, 'O', 'Oil Well');
insert into well_classes  (code, description)
values (16, 'OO', 'Oil Orphaned');
insert into well_classes  (code, description)
values (17, 'S', 'Source Well');
insert into well_classes  (code, description)
values (18, 'ST', 'Strat Test');
insert into well_classes  (code, description)
values (19, 'WS', 'Water Source');
insert into well_classes  (code, description)
values (20, '01', null);
insert into well_classes  (code, description)
values (21, '05', null);


create table well_statuses (
	id integer,
	code varchar(2),
	description varchar(50)
);

insert into well_statuses  (code, description)
values (1, 'AI', 'Active Injector');
insert into well_statuses  (code, description)
values (2, 'AP', 'Active Permit');
insert into well_statuses  (code, description)
values (3, 'DH', 'Dry Hole');
insert into well_statuses  (code, description)
values (4, 'DP', 'Drilling or Drilled Permit');
insert into well_statuses  (code, description)
values (5, 'DR', 'Dormant');
insert into well_statuses  (code, description)
values (6, 'EP', 'Expired Permit');
insert into well_statuses  (code, description)
values (7, 'FL', 'Flowing');
insert into well_statuses  (code, description)
values (8, 'GL', 'Gas Lift');
insert into well_statuses  (code, description)
values (9, 'GS', 'Gas Storage');
insert into well_statuses  (code, description)
values (10, 'M', 'Monitor Well');
insert into well_statuses  (code, description)
values (11, 'MW', 'Monitor Well (Not for Form 2 Reporting)');
insert into well_statuses  (code, description)
values (12, 'ND', null);
insert into well_statuses  (code, description)
values (13, 'NI', 'Notice of Intent to Abandon');
insert into well_statuses  (code, description)
values (14, 'NO', 'Denied or Cancelled');
insert into well_statuses  (code, description)
values (15, 'NR', 'No Report');
insert into well_statuses  (code, description)
values (16, 'PA', 'Permanently Abandoned');
insert into well_statuses  (code, description)
values (17, 'PG', 'Producing Gas Well');
insert into well_statuses  (code, description)
values (18, 'PH', 'Pumping Hydraulic');
insert into well_statuses  (code, description)
values (19, 'PL', 'Plunger Lift');
insert into well_statuses  (code, description)
values (20, 'PO', 'Producing Oil Well');
insert into well_statuses  (code, description)
values (21, 'PR', 'Pumping Rods');
insert into well_statuses  (code, description)
values (22, 'PS', 'Pumping Submersible');
insert into well_statuses  (code, description)
values (23, 'SI', 'Shut-In');
insert into well_statuses  (code, description)
values (24, 'SO', 'Suspended Operations');
insert into well_statuses  (code, description)
values (25, 'SP', 'Well Spudded');
insert into well_statuses  (code, description)
values (26, 'SR', 'Subsequent Report of Abandonment');
insert into well_statuses  (code, description)
values (27, 'TA', 'Temporarily Abandoned');
insert into well_statuses  (code, description)
values (28, 'WP', 'Waiting on Approval');


create table scrape_statuses (
	id serial primary key not null,
	api_no integer, 
	well_class varchar(2), 
	well_status varchar(2), 
	in_use boolean not null default false, 
	war_status varchar(20) not null default 'not scraped', 
	war_html text
);

insert into scrape_statuses (api_no, well_class, well_status)
select apino, well_class, status from wells order by apino;




select api_no, (length(war_html) - length(replace(war_html, '<hr size="9" color="grey">', '')))/26 as test_count from scrape_statuses where war_status = 'html saved';


update scrape_statuses set war_sample_count = (length(war_html) - length(replace(war_html, '<hr size="9" color="grey">', '')))/26 where war_status = 'html saved';

update scrape_statuses set war_sample_count = (length(war_html) - length(replace(war_html, '<hr size="9" color="grey">', '')))/26 where war_status = 'html saved' and war_sample_count = 0;



select api_no, (length(war_html) - length(replace(war_html, 'Liquid Analysis Available', '')))/25 as test_count from scrape_statuses where war_status = 'html saved';
update scrape_statuses set war_liquid_analysis_count = (length(war_html) - length(replace(war_html, 'Liquid Analysis Available', '')))/25 where war_status = 'html saved';

select api_no, (length(war_html) - length(replace(war_html, 'Gas Analysis Available', '')))/22 as test_count from scrape_statuses where war_status = 'html saved';
update scrape_statuses set war_gas_analysis_count = (length(war_html) - length(replace(war_html, 'Gas Analysis Available', '')))/22 where war_status = 'html saved';




create table water_analysis_reports (
	id serial not null primary key, 
	api_no integer, 
	operator_name varchar(100), 
	field_name varchar(100), 
	well_api_number varchar(20), 
	well_name varchar(100), 
	formation_name varchar(100), 
	plss_location varchar(100), 
	date_sampled varchar(8), 
	perf_interval varchar(30), 
	sampled_by varchar(100), 
	comments varchar(1000), 
	sodium_mgl real, 
	sodium_meql real, 
	potassium_mgl real, 
	potassium_meql real,
	lithium_mgl real, 
	lithium_meql real,
	calcium_mgl real, 
	calcium_meql real,
	magnesium_mgl real, 
	magnesium_meql real,
	iron_mgl real, 
	iron_meql real,
	total_cations real, 
	sulfate_mgl real, 
	sulfate_meql real,
	chloride_mgl real, 
	chloride_meql real,
	carbonate_mgl real, 
	carbonate_meql real,
	bicarbonate_mgl real, 
	bicarbonate_meql real,
	hydroxide_mgl real, 
	hydroxide_meql real,
	hydrogen_sulfide_mgl real, 
	hydrogen_sulfide_meql real,
	total_anions real,
	specific_resistance real, 
	conductivity real, 
	total_dissolved_solids real, 
	nacl_equivalent real, 
	observed_ph real, 
	sar real, 
	created_at date, 
	updated_at date
);

create table form_top_scrapes (
	id serial primary key not null,
	api_no integer, 
	well_class varchar(2), 
	well_status varchar(2), 
	in_use boolean not null default false, 
	scrape_status varchar(20) not null default 'not scraped'
);
insert into form_top_scrapes (api_no, well_class, well_status)
select apino, well_class, status from wells order by apino;


create table formation_tops (
	id serial not null primary key, 
	api_no integer, 
	formation varchar(50), 
	depth integer, 
	created_at date, 
	updated_at date
);


create table casing_scrapes (
	id serial primary key not null,
	api_no integer, 
	well_class varchar(2), 
	well_status varchar(2), 
	in_use boolean not null default false, 
	scrape_status varchar(20) not null default 'not scraped'
);
insert into casing_scrapes (api_no, well_class, well_status)
select apino, well_class, status from wells order by apino;


create table casings (
	id serial not null primary key, 
	api_no integer, 
	hole_size varchar(20), 
	casing_size varchar(20), 
	casing_depth varchar(20), 
	casing_weight varchar(20), 
	casing_type varchar(20), 
	cement varchar(20), 
	created_at date, 
	updated_at date
);



create table production_scrapes (
	id serial primary key not null,
	api_no integer, 
	well_class varchar(2), 
	well_status varchar(2), 
	in_use boolean not null default false, 
	scrape_status varchar(20) not null default 'not scraped'
);
insert into production_scrapes (api_no, well_class, well_status)
select apino, well_class, status from wells order by apino;


create table productions (
	id serial not null primary key, 
	api_no integer, 
	api_res varchar(20), 
	month_year varchar(20), 
	oil_bbls varchar(20), 
	gas_mcf varchar(20), 
	water_bbls varchar(20), 
	days varchar(10), 
	created_at date, 
	updated_at date
);


create table sundry_scrapes (
	id serial primary key not null,
	api_no integer, 
	well_class varchar(2), 
	well_status varchar(2), 
	in_use boolean not null default false, 
	scrape_status varchar(20) not null default 'not scraped'
);
insert into sundry_scrapes (api_no, well_class, well_status)
select apino, well_class, status from wells order by apino;


create table sundries (
	id serial not null primary key, 
	api_no integer, 
	document_url varchar(100), 
	submit_date varchar(10), 
	submission varchar(100), 
	action varchar(100), 
	action_other varchar(100), 
	date_received varchar(10), 
	created_at date, 
	updated_at date
);



-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

create table wogcc_wells (
	id serial primary key not null,
	well_id integer,
	company_name varchar(50),
	field_name varchar(30),
	horiz_dir varchar(1),
	land_type integer,
	county_fips_code varchar(3),
	county_name varchar(12),
	section integer,
	township integer,
	twp_dir varchar(1),
	range integer,
	rng_dir varchar(1),
	qtr_1 varchar(2),
	qtr_2 varchar(2),
	longitude double precision,
	latitude double precision,
	elevation varchar(8),
	bottom_formation varchar(30),
	well_class varchar(2),
	top_depth integer,
	coal_bed boolean,
	status varchar(2),
	status_date varchar(8),
	api_number varchar(12),
	first_spud_date varchar(8),
	first_comp_date varchar(8),
	gas_reservoir varchar(50)
);

insert into wogcc_wells (well_id, company_name, field_name, horiz_dir, land_type, county_fips_code, county_name, section, township, twp_dir, range, rng_dir, qtr_1, qtr_2, longitude, latitude, elevation, bottom_formation, well_class, top_depth, coal_bed, status, status_date, api_number, first_spud_date, first_comp_date)
select
 	apino::integer as api_no, company, field_name, horiz_dir, land_type, lpad(county::varchar, 3, '0'), county_name, sec::integer, twp::integer, t_dir, rge::integer, r_dir, qtr1, qtr2, lon, lat, elev, botform, well_class, td::integer, coalbed, status, split_part(statusdate,'.',1), capino, firstspud, firstcomp 
from 
	wogcc_well_import
order by 
	api_no;

update 
	wogcc_wells
set 
	api_number = '49-' || county_fips_code || '-' || right(well_id::varchar,5)
where
	api_number is null;



create table wogcc_land_types (
	id integer,
	code integer,
	description varchar(20)
);

insert into wogcc_land_types (id, code, description)
values (1, 10, 'Federal/Unknown');
insert into wogcc_land_types (code, description)
values (2, 11, 'Federal/Federal');
insert into wogcc_land_types (code, description)
values (3, 12, 'Federal/Fee');
insert into wogcc_land_types (code, description)
values (4, 13, 'Federal/Fee');
insert into wogcc_land_types (code, description)
values (5, 14, 'Federal/State');
insert into wogcc_land_types (code, description)
values (6, 20, 'Patented');
insert into wogcc_land_types (code, description)
values (7, 23, 'Fee/Fee');
insert into wogcc_land_types (code, description)
values (8, 30, 'Fee');
insert into wogcc_land_types (code, description)
values (9, 34, 'Fee/State');
insert into wogcc_land_types (code, description)
values (10, 40, 'State');
insert into wogcc_land_types (code, description)
values (11, 41, 'State/Federal');
insert into wogcc_land_types (code, description)
values (12, 43, 'State/Fee');
insert into wogcc_land_types (code, description)
values (13, 60, 'Tribal');
insert into wogcc_land_types (code, description)
values (14, 61, 'Tribal/Federal');
insert into wogcc_land_types (code, description)
values (15, 63, 'Tribal/State');
insert into wogcc_land_types (code, description)
values (16, 85, null);


create table wogcc_well_classes (
	id integer,
	code varchar(2),
	description varchar(50)
);

insert into wogcc_well_classes  (code, description)
values (1, 'AP',	'Permit to Drill');
insert into wogcc_well_classes  (code, description)
values (2, 'D',	'Disposal');
insert into wogcc_well_classes  (code, description)
values (3, 'G',	'Gas Well');
insert into wogcc_well_classes  (code, description)
values (4, 'GO',	'Gas & Oil Well');
insert into wogcc_well_classes  (code, description)
values (5, 'I',	'Injector Well');
insert into wogcc_well_classes  (code, description)
values (6, 'M',	'Monitor Well');
insert into wogcc_well_classes  (code, description)
values (7, 'MW',	'Monitor Well (Not for Form 2 Reporting)');
insert into wogcc_well_classes  (code, description)
values (8, 'NA', 'Not Applicable');
insert into wogcc_well_classes  (code, description)
values (9, 'O',	'Oil Well');
insert into wogcc_well_classes  (code, description)
values (10, 'S',	'Source Well');
insert into wogcc_well_classes  (code, description)
values (11, 'ST',	'Strat Test');
insert into wogcc_well_classes  (code, description)
values (12, 'WS',	'Water Source');


create table wogcc_well_statuses (
	id integer,
	code varchar(2),
	description varchar(50)
);

insert into wogcc_well_statuses  (code, description)
values (1, 'AI',	'Active Injector');
insert into wogcc_well_statuses  (code, description)
values (2, 'AP',	'Permit to Drill');
insert into wogcc_well_statuses  (code, description)
values (3, 'DH',	'Dry Hole');
insert into wogcc_well_statuses  (code, description)
values (4, 'DP',	'Drilling or Drilled Permit');
insert into wogcc_well_statuses  (code, description)
values (5, 'DR',	'Dormant');
insert into wogcc_well_statuses  (code, description)
values (6, 'EP',	'Expired Permit');
insert into wogcc_well_statuses  (code, description)
values (7, 'FL',	'Flowing');
insert into wogcc_well_statuses  (code, description)
values (8, 'GL',	'Gas Lift');
insert into wogcc_well_statuses  (code, description)
values (9, 'M', 'Monitor Well');
insert into wogcc_well_statuses  (code, description)
values (10, 'MW',	'Monitor Well (Not for Form 2 Reporting)');
insert into wogcc_well_statuses  (code, description)
values (11, 'ND',	null);
insert into wogcc_well_statuses  (code, description)
values (12, 'NI',	'Notice of Intent to Abandon');
insert into wogcc_well_statuses  (code, description)
values (13, 'NO',	'Denied or Cancelled');
insert into wogcc_well_statuses  (code, description)
values (14, 'NR',	'No Report');
insert into wogcc_well_statuses  (code, description)
values (15, 'PA',	'Permanently Abandoned');
insert into wogcc_well_statuses  (code, description)
values (16, 'PG',	'Producing Gas Well');
insert into wogcc_well_statuses  (code, description)
values (17, 'PH',	'Pumping Hydraulic');
insert into wogcc_well_statuses  (code, description)
values (18, 'PL',	'Plunger Lift');
insert into wogcc_well_statuses  (code, description)
values (19, 'PO',	'Producing Oil Well');
insert into wogcc_well_statuses  (code, description)
values (20, 'PR',	'Pumping Rods');
insert into wogcc_well_statuses  (code, description)
values (21, 'PS',	'Pumping Submersible');
insert into wogcc_well_statuses  (code, description)
values (22, 'S', 'Source Well');
insert into wogcc_well_statuses  (code, description)
values (23, 'SI',	'Shut-In');
insert into wogcc_well_statuses  (code, description)
values (24, 'SO',	'Suspended Operations');
insert into wogcc_well_statuses  (code, description)
values (25, 'SP',	'Well Spudded');
insert into wogcc_well_statuses  (code, description)
values (26, 'SR',	'Subsequent Report of Abandonment');
insert into wogcc_well_statuses  (code, description)
values (27, 'SW',	'Source Well');
insert into wogcc_well_statuses  (code, description)
values (28, 'TA',	'Temporarily Abandoned');
insert into wogcc_well_statuses  (code, description)
values (29, 'UK',	'Unknown');
insert into wogcc_well_statuses  (code, description)
values (30, 'WP',	null);
insert into wogcc_well_statuses  (code, description)
values (31, 'WS',	'Water Source');




create table wogcc_scrape_statuses (
	id serial primary key not null,
	well_id integer,
	api_number varchar(12),
	api_state varchar(2),
	api_county varchar(3),
	api_sequence varchar(5),
	frac_focus_status varchar(50)
);

insert into wogcc_scrape_statuses (well_id, api_number, api_state, api_county, api_sequence, frac_focus_status)
select 
	well_id, api_number, split_part(api_number,'-',1), split_part(api_number,'-',2), split_part(api_number,'-',3), 'not scraped'
from 
	wogcc_wells;


alter table wogcc_wells add column well_status_id integer;
update wogcc_wells set well_status_id = (select ws.id from wogcc_well_statuses ws where lower(ws.code) = lower(wogcc_wells.status));
create unique index wogcc_wells_well_id_idx on wogcc_wells (well_id);
create index wogcc_wells_well_status_id_idx on wogcc_wells (well_status_id);


alter table wogcc_scrape_statuses add column well_status_id integer;
create unique index wogcc_scrape_statuses_well_id_idx on wogcc_scrape_statuses (well_id);
update wogcc_scrape_statuses set well_status_id = (select w.well_status_id from wogcc_wells w where w.well_id = wogcc_scrape_statuses.well_id);

alter table wogcc_scrape_statuses add column well_api_number varchar(12);
update wogcc_scrape_statuses set well_api_number = (select w.api_number from wogcc_wells w where w.well_id = wogcc_scrape_statuses.well_id);


alter table wogcc_wells add column utm_x double precision;
alter table wogcc_wells add column utm_y double precision;
alter table wogcc_wells add column geom geometry(Point,26913);


update 
	wogcc_wells 
set 
	utm_x = get_utm_coordinate('x',longitude,latitude), 
	utm_y = get_utm_coordinate('y',longitude,latitude)
where 
	latitude is not null 
	and longitude is not null;

update 
	wogcc_wells 
set 
	geom = ST_SetSRID(ST_Point(utm_x, utm_y),26913);










select count(*) from wells where is_denver_basin is true and gor > 100; --5315
select count(*) from wells where is_denver_basin is true and gor <= 100; --25139

select count(distinct well_id) from completed_intervals where calc_gor_int > 100000 and well_id in (select id from wells where is_denver_basin is true);
--1289
select count(distinct well_id) from completed_intervals where calc_gor_int <= 100000 and well_id in (select id from wells where is_denver_basin is true);
--22447


select count(s.*) as count_count, s.sidetrack_count from (select count(*) as sidetrack_count, well_id from sidetracks group by well_id) s group by s.sidetrack_count order by sidetrack_count;

--By well
select count(*) from wells where is_denver_basin is true; --64507
select count(*) from wells where is_denver_basin is true and status_code not in ('AB','AL'); --57478
select count(*) from wells where is_denver_basin is true and is_fracked is true and is_vertical is true; --15131
select count(*) from wells where is_denver_basin is true and is_fracked is true and is_horizontal is true; --3495
select count(*) from wells where is_denver_basin is true and is_fracked is true and is_directional is true; --4731
select count(*) from wells where is_denver_basin is true and is_fracked is true and is_drifted is true; --1353


--By sidetrack
select count(*) from sidetracks where is_denver_basin is true; --65065
select count(*) from sidetracks where well_id in (select id from wells where is_denver_basin is true and status_code not in ('AB','AL')); --
select count(*) from sidetracks where is_denver_basin is true and is_fracked is true and is_vertical is true; --15234
select count(*) from sidetracks where is_denver_basin is true and is_fracked is true and is_horizontal is true; --3663
select count(*) from sidetracks where is_denver_basin is true and is_fracked is true and is_directional is true; --4762
select count(*) from sidetracks where is_denver_basin is true and is_fracked is true and is_drifted is true; --1362



update sidetracks set is_fracked = 'true' where well_id in (select id from wells where has_frac_focus_report is true); --10023
update sidetracks set is_fracked = 'true' where is_fracked is false and id in (select sidetrack_id from formation_treatments where treatment_type = 'FRACTURE STIMULATION'); --78
update sidetracks set is_fracked = 'true' where  is_fracked is false and id in (select sidetrack_id from formation_treatments where treatment_summary ilike '%frac%fluid%' or treatment_summary ilike '%fluid%frac%' or treatment_summary ilike '%frac%perf%' or treatment_summary ilike '%perf%frac%' or treatment_summary ilike '%frac%sand%' or treatment_summary ilike '%sand%frac%' or treatment_summary ilike '%perf%sand%' or treatment_summary ilike '%sand%perf%' or treatment_summary ilike '%sand%fluid%' or treatment_summary ilike '%fluid%sand%' or treatment_summary ilike '%sand%gal%' or treatment_summary ilike '%gal%sand%' or treatment_summary ilike '%water%sand%' or treatment_summary ilike '%sand%water%' or treatment_summary ilike '%h2o%sand%' or treatment_summary ilike '%sand%h2o%' or treatment_summary ilike '%mesh%sand%' or treatment_summary ilike '%sand%mesh%' or treatment_summary ilike '%sand%slurry%' or treatment_summary ilike '%slurry%sand%' or treatment_summary ilike '%sand%bbl%' or treatment_summary ilike '%bbl%sand%' or treatment_summary ilike '%fw%sand%' or treatment_summary ilike '%sand%fw%' or treatment_summary ilike '%bw%sand%' or treatment_summary ilike '%sand%bw%' or treatment_summary ilike '%#%#%sand%' or treatment_summary ilike '%sand%#%#%' or treatment_summary ilike '%clay%stab%' or treatment_summary ilike '%claytreat%' or treatment_summary ilike '%clayfix%' or treatment_summary ilike '%resin%' or treatment_summary ilike '%proppant%' or treatment_summary ilike '%ottawa%'or treatment_summary ilike '%slick%water%' or treatment_summary ilike '%cross%link%' or treatment_summary ilike '%emulsifrac%' or treatment_summary ilike '%siber%prop%' or treatment_summary ilike '%permstim%' or treatment_summary ilike '%silver%stim%' or treatment_summary ilike '%vistar%' or treatment_summary ilike '%x-linked%' or treatment_summary ilike '%gel%fluid%' or treatment_summary ilike '%fluid%gel%' or treatment_summary ilike '%gel%water%' or treatment_summary ilike '%water%gel%' or treatment_summary ilike '%gel%agent%' or treatment_summary ilike '%agent%gel%' or treatment_summary ilike '%gel%sand%' or treatment_summary ilike '%sand%gel%'); --28798




select count(*) from formation_treatments where well_id in (select id from wells where is_denver_basin is true) and (treatment_summary ilike '%recompl%' or treatment_summary ilike '%re-compl%' or treatment_summary ilike '%recomp%ion%' or treatment_summary ilike '%re-comp%ion%' or treatment_summary ilike '%recomp%oin%' or treatment_summary ilike '%re-comp%oin%'); --777

select count(distinct well_id) from formation_treatments where well_id in (select id from wells where is_denver_basin is true) and (treatment_summary ilike '%recompl%' or treatment_summary ilike '%re-compl%' or treatment_summary ilike '%recomp%ion%' or treatment_summary ilike '%re-comp%ion%' or treatment_summary ilike '%recomp%oin%' or treatment_summary ilike '%re-comp%oin%'); --609

select count(distinct sidetrack_id) from formation_treatments where well_id in (select id from wells where is_denver_basin is true) and (treatment_summary ilike '%recompl%' or treatment_summary ilike '%re-compl%' or treatment_summary ilike '%recomp%ion%' or treatment_summary ilike '%re-comp%ion%' or treatment_summary ilike '%recomp%oin%' or treatment_summary ilike '%re-comp%oin%'); --609




