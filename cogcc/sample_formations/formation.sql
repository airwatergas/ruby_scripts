drop table well_sample_dates;
create table well_sample_dates (
	facility_id integer, 
	api_number varchar(12), 
	sample_date_string varchar(11)
);
copy well_sample_dates from '/Users/troyburke/Projects/ruby/cogcc/sample_formations/well_sample_dates.csv' (format csv, delimiter ',', null ''); --339 records
alter table well_sample_dates add column id serial not null primary key;

alter table well_sample_dates add column well_id integer;
alter table well_sample_dates add column sample_date date;
update well_sample_dates set well_id = (select well_id from cogcc_well_surface_locations where attrib_1 = well_sample_dates.api_number);
update well_sample_dates set sample_date = trim(substring(sample_date_string,2,length(sample_date_string)))::date;

alter table well_sample_dates add column sample_year smallint;
alter table well_sample_dates add column sample_month smallint;
update well_sample_dates set sample_year = EXTRACT(YEAR FROM sample_date);
update well_sample_dates set sample_month = EXTRACT(MONTH FROM sample_date);

alter table well_sample_dates add column prod_formation_list varchar(255);
update well_sample_dates set prod_formation_list = array_to_string(array(select distinct formation_name from cogcc_production_amounts where well_id = well_sample_dates.well_id and prod_year = well_sample_dates.sample_year and prod_month = well_sample_dates.sample_month), ',');
update well_sample_dates set prod_formation_list = null where prod_formation_list = ''; --110 records

alter table well_sample_dates add column prod_form_1_name varchar(50);
alter table well_sample_dates add column prod_form_1_days smallint;
alter table well_sample_dates add column prod_form_1_oil_bbls integer;
alter table well_sample_dates add column prod_form_1_gas_mcf integer;
alter table well_sample_dates add column prod_form_2_name varchar(50);
alter table well_sample_dates add column prod_form_2_days smallint;
alter table well_sample_dates add column prod_form_2_oil_bbls integer;
alter table well_sample_dates add column prod_form_2_gas_mcf integer;
alter table well_sample_dates add column prod_form_3_name varchar(50);
alter table well_sample_dates add column prod_form_3_days smallint;
alter table well_sample_dates add column prod_form_3_oil_bbls integer;
alter table well_sample_dates add column prod_form_3_gas_mcf integer;

update well_sample_dates set prod_form_1_name = split_part(prod_formation_list, ',', 1);
update well_sample_dates set prod_form_2_name = split_part(prod_formation_list, ',', 2);
update well_sample_dates set prod_form_3_name = split_part(prod_formation_list, ',', 3);

update well_sample_dates set prod_form_1_days = (select days_producing from cogcc_production_amounts where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.prod_form_1_name and prod_year = well_sample_dates.sample_year and prod_month = well_sample_dates.sample_month), prod_form_1_oil_bbls = (select oil_produced from cogcc_production_amounts where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.prod_form_1_name and prod_year = well_sample_dates.sample_year and prod_month = well_sample_dates.sample_month), prod_form_1_gas_mcf = (select gas_production from cogcc_production_amounts where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.prod_form_1_name and prod_year = well_sample_dates.sample_year and prod_month = well_sample_dates.sample_month);

update well_sample_dates set prod_form_2_days = (select days_producing from cogcc_production_amounts where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.prod_form_2_name and prod_year = well_sample_dates.sample_year and prod_month = well_sample_dates.sample_month), prod_form_2_oil_bbls = (select oil_produced from cogcc_production_amounts where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.prod_form_2_name and prod_year = well_sample_dates.sample_year and prod_month = well_sample_dates.sample_month), prod_form_2_gas_mcf = (select gas_production from cogcc_production_amounts where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.prod_form_2_name and prod_year = well_sample_dates.sample_year and prod_month = well_sample_dates.sample_month);

update well_sample_dates set prod_form_3_days = (select days_producing from cogcc_production_amounts where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.prod_form_3_name and prod_year = well_sample_dates.sample_year and prod_month = well_sample_dates.sample_month), prod_form_3_oil_bbls = (select oil_produced from cogcc_production_amounts where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.prod_form_3_name and prod_year = well_sample_dates.sample_year and prod_month = well_sample_dates.sample_month), prod_form_3_gas_mcf = (select gas_production from cogcc_production_amounts where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.prod_form_3_name and prod_year = well_sample_dates.sample_year and prod_month = well_sample_dates.sample_month);

alter table well_sample_dates add column completed_formation_list varchar(500);
update well_sample_dates set completed_formation_list = array_to_string(array(select distinct formation_name from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id), ',');
update well_sample_dates set completed_formation_list = null where completed_formation_list = ''; --4 records

alter table well_sample_dates add column comp_form_1_name varchar(50);
alter table well_sample_dates add column comp_form_1_1st_prod varchar(10);
alter table well_sample_dates add column comp_form_1_perf_top varchar(10);
alter table well_sample_dates add column comp_form_1_perf_bot varchar(10);
alter table well_sample_dates add column comp_form_2_name varchar(50);
alter table well_sample_dates add column comp_form_2_1st_prod varchar(25);
alter table well_sample_dates add column comp_form_2_perf_top varchar(10);
alter table well_sample_dates add column comp_form_2_perf_bot varchar(10);
alter table well_sample_dates add column comp_form_3_name varchar(50);
alter table well_sample_dates add column comp_form_3_1st_prod varchar(25);
alter table well_sample_dates add column comp_form_3_perf_top varchar(10);
alter table well_sample_dates add column comp_form_3_perf_bot varchar(10);
alter table well_sample_dates add column comp_form_4_name varchar(50);
alter table well_sample_dates add column comp_form_4_1st_prod varchar(10);
alter table well_sample_dates add column comp_form_4_perf_top varchar(10);
alter table well_sample_dates add column comp_form_4_perf_bot varchar(10);
alter table well_sample_dates add column comp_form_5_name varchar(50);
alter table well_sample_dates add column comp_form_5_1st_prod varchar(10);
alter table well_sample_dates add column comp_form_5_perf_top varchar(10);
alter table well_sample_dates add column comp_form_5_perf_bot varchar(10);
alter table well_sample_dates add column comp_form_6_name varchar(50);
alter table well_sample_dates add column comp_form_6_1st_prod varchar(10);
alter table well_sample_dates add column comp_form_6_perf_top varchar(10);
alter table well_sample_dates add column comp_form_6_perf_bot varchar(10);

update well_sample_dates set comp_form_1_name = split_part(completed_formation_list, ',', 1);
update well_sample_dates set comp_form_2_name = split_part(completed_formation_list, ',', 2);
update well_sample_dates set comp_form_3_name = split_part(completed_formation_list, ',', 3);
update well_sample_dates set comp_form_4_name = split_part(completed_formation_list, ',', 4);
update well_sample_dates set comp_form_5_name = split_part(completed_formation_list, ',', 5);
update well_sample_dates set comp_form_6_name = split_part(completed_formation_list, ',', 6);

update well_sample_dates set comp_form_1_1st_prod = (select first_production_date from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_1_name), comp_form_1_perf_top = (select perf_top from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_1_name), comp_form_1_perf_bot = (select perf_bottom from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_1_name);

update well_sample_dates set comp_form_2_1st_prod = array_to_string(array(select first_production_date from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_2_name), '/'), comp_form_2_perf_top = array_to_string(array(select perf_top from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_2_name), '/'), comp_form_2_perf_bot = array_to_string(array(select perf_bottom from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_2_name), '/');

update well_sample_dates set comp_form_3_1st_prod = array_to_string(array(select first_production_date from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_3_name), '/'), comp_form_3_perf_top = array_to_string(array(select perf_top from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_3_name), '/'), comp_form_3_perf_bot = array_to_string(array(select perf_bottom from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_3_name), '/');

update well_sample_dates set comp_form_4_1st_prod = (select first_production_date from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_4_name), comp_form_4_perf_top = (select perf_top from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_4_name), comp_form_4_perf_bot = (select perf_bottom from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_4_name);

update well_sample_dates set comp_form_5_1st_prod = (select first_production_date from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_5_name), comp_form_5_perf_top = (select perf_top from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_5_name), comp_form_5_perf_bot = (select perf_bottom from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_5_name);

update well_sample_dates set comp_form_6_1st_prod = (select first_production_date from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_6_name), comp_form_6_perf_top = (select perf_top from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_6_name), comp_form_6_perf_bot = (select perf_bottom from cogcc_well_completed_intervals where well_id = well_sample_dates.well_id and formation_name = well_sample_dates.comp_form_6_name);

select * from well_sample_dates where prod_formation_list is null and completed_formation_list is null order by id; --4 records

-- 05-013-05011 => no completed formations, DA (line 19)
-- 05-013-05011 => no completed formations, DA (line 20)
-- 05-123-07322 => completed formation, no completed intervals, DA/XX (line 48)
-- 05-123-07322 => completed formation, no completed intervals, DA/XX (line 49)

COPY (select * from well_sample_dates order by id) TO '/Users/troyburke/Projects/ruby/cogcc/sample_formations/dj_producing_formations.csv' WITH CSV HEADER;





