create table cogcc_facility_types (
	id serial primary key not null, 
	description varchar(50)
);

insert into cogcc_facility_types (id, description) values (1, 'WELL');
insert into cogcc_facility_types (id, description) values (2, 'WATER GATHERING SYSTEM/LINE');
insert into cogcc_facility_types (id, description) values (3, 'UIC WATER TRANSFER STATION');
insert into cogcc_facility_types (id, description) values (4, 'UIC SIMULTANEOUS DISPOSAL');
insert into cogcc_facility_types (id, description) values (5, 'UIC ENHANCED RECOVERY');
insert into cogcc_facility_types (id, description) values (6, 'UIC DISPOSAL');
insert into cogcc_facility_types (id, description) values (7, 'TANK BATTERY');
insert into cogcc_facility_types (id, description) values (8, 'SPILL OR RELEASE');
insert into cogcc_facility_types (id, description) values (9, 'SERVICE SITE');
insert into cogcc_facility_types (id, description) values (10, 'PIT');
insert into cogcc_facility_types (id, description) values (11, 'PIPELINE');
insert into cogcc_facility_types (id, description) values (12, 'NONFACILITY');
insert into cogcc_facility_types (id, description) values (13, 'LOCATION');
insert into cogcc_facility_types (id, description) values (14, 'LEASE');
insert into cogcc_facility_types (id, description) values (15, 'LAND APPLICATION SITE');
insert into cogcc_facility_types (id, description) values (16, 'GAS STORAGE FACILITY');
insert into cogcc_facility_types (id, description) values (17, 'GAS PROCESSING PLANT');
insert into cogcc_facility_types (id, description) values (18, 'GAS GATHERING SYSTEM');
insert into cogcc_facility_types (id, description) values (19, 'GAS COMPRESSOR');
insert into cogcc_facility_types (id, description) values (20, 'FLOWLINE');
insert into cogcc_facility_types (id, description) values (21, 'CENTRALIZED EP WASTE MGMT FAC');
insert into cogcc_facility_types (id, description) values (22, 'CDP');


create table cogcc_facilities (
	id serial primary key not null, 
	facility_type_id integer, 
	facility_type varchar(50),
	facility_detail_url varchar(100),  
	facility_id varchar(20), 
	facility_name varchar(100), 
	facility_number varchar(20), 
	operator_name varchar(100),
	operator_number varchar(20), 
	status varchar(20), 
	field_name varchar(100),
	field_number varchar(20), 
	location_county varchar(100),
	location_plss varchar(100), 
	related_facilities_url varchar(100), 
	details_scraped boolean default false
);

alter table cogcc_facilities alter column facility_id type integer using facility_id::integer;

create table cogcc_facility_details (
	id serial primary key not null, 
	cogcc_facility_id integer, 
	status_date varchar(12), 
	latitude double precision, 
	longitude double precision, 
	order_number varchar(20), 
	inj_initial_date varchar(20),
	inj_fluid_type varchar(50),
	comments text
);

alter table cogcc_facility_details add column geom geometry(Point,26913);
alter table cogcc_facility_details add column geom_nad83 geometry(Point,4269);

update cogcc_facility_details set geom_nad83 = ST_SetSRID(ST_Point(longitude, latitude),4269)
where latitude is not null and longitude is not null and geom_nad83 is null;

update cogcc_facility_details set geom = ST_Transform(ST_SetSRID(geom_nad83, 4269), 26913) where geom is null and geom_nad83 is not null;


create table cogcc_facility_formations (
	id serial primary key not null, 
	cogcc_facility_id integer, 
	inj_zone_name varchar(100),
	inj_zone_code varchar(20),
	inj_avg_porosity varchar(20),
	inj_avg_permeability varchar(20), 
	inj_tds varchar(20), 
	inj_frac_gradient varchar(50) 
);


create table cogcc_facility_wells (
	id serial primary key not null, 
	cogcc_facility_id integer,
	cogcc_facility_location_id integer,
	api_number varchar(16),
	well_name varchar(100), 
	well_url varchar(100), 
	facility_status varchar(10),
	wellbore_status varchar(10),
	authorization_date varchar(12),
	no_longer_injector_date varchar(12),
	max_water_inj_psi varchar(20),
	max_gas_inj_psi varchar(20),
	max_inj_volume varchar(20),
	last_mit varchar(50)
);

create table cogcc_facility_locations (
	id serial primary key not null, 
	cogcc_facility_id integer, 
	status_date varchar(12), 
	latitude double precision, 
	longitude double precision, 
	form_2a_doc_num varchar(20), 
	form_2a_exp_date varchar(20), 
	special_purpose_pits varchar(10), 
	drilling_pits varchar(10), 
	wells varchar(10), 
	production_pits varchar(10), 
	condensate_tanks varchar(10), 
	water_tanks varchar(10), 
	separators varchar(10), 
	electric_motors varchar(10), 
	gas_or_diesel_motors varchar(10),
	cavity_pumps varchar(10), 
	lact_unit varchar(10), 
	pump_jacks varchar(10), 
	electric_generators varchar(10),
	gas_pipeline varchar(10), 
	oil_pipeline varchar(10), 
	water_pipeline varchar(10), 
	gas_compressors varchar(10), 
	voc_combustor varchar(10), 
	oil_tanks varchar(10), 
	dehydrator_units varchar(10), 
	multi_well_pits varchar(10), 
	pigging_station varchar(10), 
	flare varchar(10), 
	fuel_tanks varchar(10) 
);

alter table cogcc_facility_locations alter column special_purpose_pits type smallint using special_purpose_pits::smallint;
alter table cogcc_facility_locations alter column drilling_pits type smallint using drilling_pits::smallint;
alter table cogcc_facility_locations alter column wells type smallint using wells::smallint;
alter table cogcc_facility_locations alter column production_pits type smallint using production_pits::smallint;
alter table cogcc_facility_locations alter column condensate_tanks type smallint using condensate_tanks::smallint;
alter table cogcc_facility_locations alter column water_tanks type smallint using water_tanks::smallint;
alter table cogcc_facility_locations alter column separators type smallint using separators::smallint;
alter table cogcc_facility_locations alter column electric_motors type smallint using electric_motors::smallint;
alter table cogcc_facility_locations alter column gas_or_diesel_motors type smallint using gas_or_diesel_motors::smallint;
alter table cogcc_facility_locations alter column cavity_pumps type smallint using cavity_pumps::smallint;
alter table cogcc_facility_locations alter column lact_unit type smallint using lact_unit::smallint;
alter table cogcc_facility_locations alter column pump_jacks type smallint using pump_jacks::smallint;
alter table cogcc_facility_locations alter column electric_generators type smallint using electric_generators::smallint;
alter table cogcc_facility_locations alter column gas_pipeline type smallint using gas_pipeline::smallint;
alter table cogcc_facility_locations alter column oil_pipeline type smallint using oil_pipeline::smallint;
alter table cogcc_facility_locations alter column water_pipeline type smallint using water_pipeline::smallint;
alter table cogcc_facility_locations alter column gas_compressors type smallint using gas_compressors::smallint;
alter table cogcc_facility_locations alter column voc_combustor type smallint using voc_combustor::smallint;
alter table cogcc_facility_locations alter column oil_tanks type smallint using oil_tanks::smallint;
alter table cogcc_facility_locations alter column dehydrator_units type smallint using dehydrator_units::smallint;
alter table cogcc_facility_locations alter column multi_well_pits type smallint using multi_well_pits::smallint;
alter table cogcc_facility_locations alter column pigging_station type smallint using pigging_station::smallint;
alter table cogcc_facility_locations alter column flare type smallint using flare::smallint;
alter table cogcc_facility_locations alter column fuel_tanks type smallint using fuel_tanks::smallint;

alter table cogcc_facility_locations add column geom_nad83 geometry(Point,4269);
alter table cogcc_facility_locations add column geom geometry(Point,26913);

update cogcc_facility_locations set geom_nad83 = ST_SetSRID(ST_Point(longitude, latitude),4269)
where latitude is not null and longitude is not null;

update cogcc_facility_locations set geom = ST_Transform(ST_SetSRID(geom_nad83, 4269), 26913) where geom_nad83 is not null;

select count(*) from cogcc_facility_locations where (wells > 0 or condensate_tanks > 0 or separators > 0 or lact_unit > 0 or gas_pipeline > 0 or oil_pipeline > 0 or gas_compressors > 0 or voc_combustor > 0 or oil_tanks > 0 or dehydrator_units > 0 or flare > 0 or fuel_tanks > 0);
--7788

select 
	sum(case when wells > 0 then 1 else 0 end) as well_count, 
	sum(case when condensate_tanks > 0 then 1 else 0 end) as condensate_tank_count, 
	sum(case when separators > 0 then 1 else 0 end) as separator_count, 
	sum(case when lact_unit > 0 then 1 else 0 end) as lact_unit_count, 
	sum(case when gas_pipeline > 0 then 1 else 0 end) as gas_pipeline_count, 
	sum(case when oil_pipeline > 0 then 1 else 0 end) as oil_pipeline_count, 
	sum(case when gas_compressors > 0 then 1 else 0 end) as gas_compressor_count, 
	sum(case when voc_combustor > 0 then 1 else 0 end) as voc_combustor_count, 
	sum(case when oil_tanks > 0 then 1 else 0 end) as oil_tank_count, 
	sum(case when dehydrator_units > 0 then 1 else 0 end) as dehydrator_unit_count, 
	sum(case when flare > 0 then 1 else 0 end) as flare_count, 
	sum(case when fuel_tanks > 0 then 1 else 0 end) as fuel_tank_count
from 
	cogcc_facility_locations 
where 
	(wells > 0 or condensate_tanks > 0 or separators > 0 or lact_unit > 0 or gas_pipeline > 0 or oil_pipeline > 0 or gas_compressors > 0 or voc_combustor > 0 or oil_tanks > 0 or dehydrator_units > 0 or flare > 0 or fuel_tanks > 0);

alter table cogcc_facility_locations add column has_targeted_inventory boolean not null default false;

update cogcc_facility_locations set has_targeted_inventory = 'true' where (wells > 0 or condensate_tanks > 0 or separators > 0 or lact_unit > 0 or gas_pipeline > 0 or oil_pipeline > 0 or gas_compressors > 0 or voc_combustor > 0 or oil_tanks > 0 or dehydrator_units > 0 or flare > 0 or fuel_tanks > 0);

select 
	sum(case when condensate_tanks > 0 then 1 else 0 end) as condensate_tank_count, 
	sum(case when separators > 0 then 1 else 0 end) as separator_count, 
	sum(case when lact_unit > 0 then 1 else 0 end) as lact_unit_count, 
	sum(case when gas_pipeline > 0 then 1 else 0 end) as gas_pipeline_count, 
	sum(case when oil_pipeline > 0 then 1 else 0 end) as oil_pipeline_count, 
	sum(case when gas_compressors > 0 then 1 else 0 end) as gas_compressor_count, 
	sum(case when voc_combustor > 0 then 1 else 0 end) as voc_combustor_count, 
	sum(case when oil_tanks > 0 then 1 else 0 end) as oil_tank_count, 
	sum(case when dehydrator_units > 0 then 1 else 0 end) as dehydrator_unit_count, 
	sum(case when flare > 0 then 1 else 0 end) as flare_count, 
	sum(case when fuel_tanks > 0 then 1 else 0 end) as fuel_tank_count
from 
	cogcc_facility_locations 
where 
	(condensate_tanks > 0 or separators > 0 or lact_unit > 0 or gas_pipeline > 0 or oil_pipeline > 0 or gas_compressors > 0 or voc_combustor > 0 or oil_tanks > 0 or dehydrator_units > 0 or flare > 0 or fuel_tanks > 0) 
	and cogcc_facility_id in (select cogcc_facility_id from facility_road_proximities where distance < 101);


alter table facility_road_proximities add column is_non_well_location boolean not null default false;

update facility_road_proximities 
set is_non_well_location = 'true' 
where cogcc_facility_id in (select cogcc_facility_id from cogcc_facility_locations where wells = 0 and (condensate_tanks > 0 or separators > 0 or lact_unit > 0 or gas_pipeline > 0 or oil_pipeline > 0 or gas_compressors > 0 or voc_combustor > 0 or oil_tanks > 0 or dehydrator_units > 0 or flare > 0 or fuel_tanks > 0));


