#  API,WELL_NAME,ACCT_NUM,ALT_ADDRES,FIELD_NUM,ELEVATION,LOCAT_FOOT,UTM_SURF_N,UTM_SURF_E,UTM_BHL_N,UTM_BHL_E,QTR_QTR,SECTION,TOWNSHIP,RANGE,MERIDIAN,COUNTY,DIR_HORIZ,CONF_FLAG,CONF_DATE,LEASE_NUM,LEASE_TYPE,ABNDONDATE,WELLSTATUS,WELL_TYPE,TOTCUM_OIL,TOTCUM_GAS,TOTCUM_WTR,IND_TRIBE,MULTI_LATS,CBMETHFLAG,SURFOWNTYP,BOND_NUM,BOND_TYPE,CA_NUMBER,FIELD_TYPE,UNIT_NAME,LAT_SURF,LONG_SURF,COMMENTS,MODIFYDATE

create table utogm_wells_backup as table utogm_wells;
drop table utogm_wells;

create table utogm_wells (
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

copy utogm_wells from '/Users/troyburke/Data/utogm/utah_welldata.csv' (format csv, delimiter ',', null '');

alter table utogm_wells add column well_id serial primary key not null;


# PLANT_CD,PLANT_NAME,ACCT_NUM,ALT_ADDRES,PLANT_ADDR,PLANT_CITY,PLANTSTATE,PLANT_ZIP,PLANT_LOC,COUNTY,STATUS

create table utogm_gas_plants (
	id serial primary key not null,
	plant_cd varchar(4) not null, 
	plant_name varchar(50) not null, 
	acct_num varchar(5) not null, 
	alt_addres varchar(100), 
	plant_addr varchar(100), 
	plant_city varchar(50), 
	plantstate varchar(2), 
	plant_zip varchar(5), 
	plant_loc varchar(20), 
	county varchar(30), 
	status varchar(1)
);

copy utogm_gas_plants from '/Users/troyburke/Data/utogm/utah_plantdata.csv' (format csv, delimiter ',', null '');

create table utogm_well_statuses (
	id serial primary key not null,
	code varchar(3),
	description varchar(40)
);

insert into utogm_well_statuses (id, code, description) values (1, 'NEW', 'new apd; not yet approved');
insert into utogm_well_statuses (id, code, description) values (2, 'RET', 'apd returned to operator unapproved');
insert into utogm_well_statuses (id, code, description) values (3, 'APD', 'approved apd');
insert into utogm_well_statuses (id, code, description) values (4, 'DRL', 'spudded; not complete');
insert into utogm_well_statuses (id, code, description) values (5, 'OPS', 'drilling operations suspended');
insert into utogm_well_statuses (id, code, description) values (6, 'P', 'producing');
insert into utogm_well_statuses (id, code, description) values (7, 'S', 'shut-in');
insert into utogm_well_statuses (id, code, description) values (8, 'TA', 'temporarily-abandoned');
insert into utogm_well_statuses (id, code, description) values (9, 'PA', 'plugged and abandoned');
insert into utogm_well_statuses (id, code, description) values (10, 'A', 'active (service well)');
insert into utogm_well_statuses (id, code, description) values (11, 'I', 'inactive (service well)');
insert into utogm_well_statuses (id, code, description) values (12, 'LA', 'location abandoned; permit rescinded');

alter table utogm_wells add column well_status_id integer;

update utogm_wells set well_status_id = (select ws.id from utogm_well_statuses ws where trim(utogm_wells.wellstatus) = ws.code);



create table utogm_well_types (
	id serial primary key not null,
	code varchar(2),
	description varchar(40)
);

insert into utogm_well_types (id, code, description) values (1, 'OW', 'oil well');
insert into utogm_well_types (id, code, description) values (2, 'GW', 'gas well');
insert into utogm_well_types (id, code, description) values (3, 'D', 'dry hole');
insert into utogm_well_types (id, code, description) values (4, 'WI', 'water injection (service well)');
insert into utogm_well_types (id, code, description) values (5, 'GI', 'gas injection (service well)');
insert into utogm_well_types (id, code, description) values (6, 'GS', 'gas storage (service well)');
insert into utogm_well_types (id, code, description) values (7, 'WD', 'water disposal (service well)');
insert into utogm_well_types (id, code, description) values (8, 'WS', 'water source (service well)');
insert into utogm_well_types (id, code, description) values (9, 'TW', 'test well (service well)');
insert into utogm_well_types (id, code, description) values (10, 'NA', 'well type not available');

alter table utogm_wells add column well_type_id integer;

update utogm_wells set well_type_id = (select wt.id from utogm_well_types wt where trim(utogm_wells.well_type) = wt.code);


create index utogm_wells_well_type_id_idx on utogm_wells(well_type_id);
create index utogm_wells_well_status_id_idx on utogm_wells(well_status_id);


create table utogm_scrape_statuses (
	id serial primary key not null,
	well_id integer,
	well_status_id integer,
	well_type_id integer,
	well_api_number varchar(12),
	api_number varchar(10),
	api_state varchar(2),
	api_county varchar(3),
	api_sequence varchar(5),
	frac_focus_status varchar(50)
);

insert into utogm_scrape_statuses (well_id, well_status_id, well_type_id, well_api_number, api_number, api_state, api_county, api_sequence, frac_focus_status)
select well_id, well_status_id, well_type_id, '43-' || substr(api,3,3) || '-' || right(api,5), api, '43', substr(api,3,3), right(api,5), 'not scraped'
from utogm_wells;


-- Add Geometry
alter table utogm_wells add column geom geometry(Point,26912);
update utogm_wells set geom = ST_SetSRID(ST_Point(utm_surf_e, utm_surf_n),26912);


# utah road proximities

# Carbon, Duchesne, Emery, Grand, San Juan, Uintah
# ('007','013','015','019','037','047')

alter table utogm_wells add column county_fips varchar(3);
update utogm_wells set county_fips = (select cnty_fips from counties where state_name = 'Utah' and upper(trim(utogm_wells.county)) = upper(trim(name)));


# proximity table
create table utah_well_road_distances (
	id serial primary key not null, 
	well_id integer, 
	well_api varchar(10), 
	well_status_id integer, 
	well_type_id integer, 
	county_name varchar(50), 
	county_fips varchar(3), 
	lat double precision, 
	long double precision, 
	well_geom geometry(POINT,26912), 
	road_gid integer, 
	road_fullname varchar(100), 
	road_streetname varchar(100), 
	road_direction varchar(2), 
	road_geom geometry(LineString,26912), 
	closest_point_lat double precision, 
	closest_point_long double precision, 
	closest_point_geom geometry(POINT,26912),
	distance real, 
	closest_direction varchar(2), 
	wind_direction varchar(2), 
	wind_dir_suspect boolean not null default false
);

insert into utah_well_road_distances (well_id, well_api, well_status_id, well_type_id, county_name, county_fips, lat, long, well_geom, road_gid, road_fullname, road_streetname, road_direction, road_geom, closest_point_geom) 
select 
	w.well_id, 
	w.api, 
	w.well_status_id, 
	w.well_type_id, 
	w.county, 
	w.county_fips, 
	w.lat_surf, 
	w.long_surf, 
	w.geom, 
	r.gid, 
	r.fullname,
	r.streetname, 
	case when r.predir is null then r.direction else r.predir end as road_direction,
	r.geom_line, 
	ST_ClosestPoint(r.geom_line,w.geom)
from 
	utogm_wells w 
cross join 
	utah_roads r 
where 
	w.well_status_id in (6,7,8,10) -- P-producing, S-shut-in, TA-temporarily-abandoned, A-active (service well) 
	and w.well_type_id in (1,2,5,6) -- OW-oil well, GW-gas well, GI-gas injection (service well), GS-gas storage (service well)
	and w.county_fips in ('007','013','015','019','037','047') --Carbon, Duchesne, Emery, Grand, San Juan, Uintah
	and r.cofips in ('49007','49013','49015','49019','49037','49047') --Carbon, Duchesne, Emery, Grand, San Juan, Uintah
	and ST_Distance(w.geom, ST_ClosestPoint(r.geom_line,w.geom)) < 101;


update utah_well_road_distances 
set closest_point_lat = ST_Y(ST_Transform(ST_SetSRID(closest_point_geom, 26912), 4269)), closest_point_long = ST_X(ST_Transform(ST_SetSRID(closest_point_geom, 26912), 4269)), distance = ST_Distance(well_geom, closest_point_geom)
where distance is null;

-- closest point => point on road closest to well and direction is relative to well
update utah_well_road_distances 
set closest_direction = case 
when road_direction = 'E' and lat > closest_point_lat then 'S' 
when road_direction = 'E' and lat < closest_point_lat then 'N' 
when road_direction = 'N' and long < closest_point_long then 'E' 
when road_direction = 'N' and long > closest_point_long then 'W' 
when road_direction = 'W' and lat > closest_point_lat then 'S' 
when road_direction = 'W' and lat < closest_point_lat then 'N' 
when road_direction = 'S' and long < closest_point_long then 'E' 
when road_direction = 'S' and long > closest_point_long then 'W' 
when road_direction = 'NE' and lat < closest_point_lat and long > closest_point_long then 'NW'
when road_direction = 'NE' and lat > closest_point_lat and long < closest_point_long then 'SE'
when road_direction = 'SW' and lat < closest_point_lat and long > closest_point_long then 'NW'
when road_direction = 'SW' and lat > closest_point_lat and long < closest_point_long then 'SE'
when road_direction = 'NW' and lat > closest_point_lat and long > closest_point_long then 'NE'
when road_direction = 'NW' and lat < closest_point_lat and long < closest_point_long then 'SW'
when road_direction = 'SE' and lat > closest_point_lat and long > closest_point_long then 'NE'
when road_direction = 'SE' and lat < closest_point_lat and long < closest_point_long then 'SW'
else null end
where road_direction is not null;

update utah_well_road_distances 
set closest_direction = case 
when road_direction = 'E' and lat > closest_point_lat then 'S' 
when road_direction = 'E' and lat < closest_point_lat then 'N' 
when road_direction = 'N' and long < closest_point_long then 'E' 
when road_direction = 'N' and long > closest_point_long then 'W' 
when road_direction = 'W' and lat > closest_point_lat then 'S' 
when road_direction = 'W' and lat < closest_point_lat then 'N' 
when road_direction = 'S' and long < closest_point_long then 'E' 
when road_direction = 'S' and long > closest_point_long then 'W' 
else null end
where road_direction is not null;


update utah_well_road_distances set wind_direction = 'N' where closest_direction = 'S';
update utah_well_road_distances set wind_direction = 'S' where closest_direction = 'N';
update utah_well_road_distances set wind_direction = 'E' where closest_direction = 'W';
update utah_well_road_distances set wind_direction = 'W' where closest_direction = 'E';

update utah_well_road_distances set wind_direction = 'NE' where closest_direction = 'SW';
update utah_well_road_distances set wind_direction = 'SW' where closest_direction = 'NE';
update utah_well_road_distances set wind_direction = 'NW' where closest_direction = 'SE';
update utah_well_road_distances set wind_direction = 'SE' where closest_direction = 'NW';

-- error correction for N,S road orientation
select well_api, lat, long, road_fullname, road_direction, closest_point_lat, closest_point_long, distance, closest_direction, wind_direction 
from utah_well_road_distances 
where road_direction in ('N','S') and closest_direction in ('E','W') and abs(closest_point_lat - lat) > (10 * abs(closest_point_long - long));
select well_api, lat, long, road_fullname, road_direction, closest_point_lat, closest_point_long, distance, closest_direction, wind_direction 
from utah_well_road_distances 
where road_direction in ('E','W') and closest_direction in ('N','S') and abs(closest_point_long - long) > (10 * abs(closest_point_lat - lat));

update utah_well_road_distances set wind_dir_suspect = 'true' where road_direction in ('N','S') and closest_direction in ('E','W') and abs(closest_point_lat - lat) > (10 * abs(closest_point_long - long));
update utah_well_road_distances set wind_dir_suspect = 'true' where road_direction in ('E','W') and closest_direction in ('N','S') and abs(closest_point_long - long) > (10 * abs(closest_point_lat - lat));


select w.api, w.api || '0000' as link, w.well_name, w.wellstatus, w.well_type, f.lat, f.long, w.elevation, f.road_fullname, f.distance from utah_well_road_distances f inner join utogm_wells w on f.well_id = w.well_id where f.wind_dir_suspect is false and f.wind_direction = '#{wind_dir}' and f.distance < #{distance} order by f.well_api;


SELECT COUNT( CASE WHEN ST_NumGeometries(geom) > 1 THEN 1 END ) AS multi, COUNT(geom) AS total FROM utah_roads;

alter table utah_roads add column geom_line geometry(MultiLineString,26912);
update utah_roads set geom_line = geom where ST_NumGeometries(geom) < 2;
alter table utah_roads alter column geom_line type geometry(LineString,26912) using ST_GeometryN(geom, 1);

alter table utah_roads add column azimuth double precision;
update utah_roads set azimuth = ST_Azimuth(ST_StartPoint(geom_line),ST_EndPoint(geom_line)) where geom_line is not null;

alter table utah_roads add column heading double precision;
update utah_roads set heading = azimuth*180/pi() where azimuth is not null;

alter table utah_roads add column direction varchar(2);
update utah_roads set direction = 
	case 
		when heading < 22.5 then 'N' 
		when heading < 67.5 then 'NE' 
		when heading < 112.5 then 'E' 
		when heading < 157.5 then 'SE' 
		when heading < 202.5 then 'S' 
		when heading < 247.5 then 'SW' 
		when heading < 292.5 then 'W' 
		when heading < 337.5 then 'NW' 
		when heading <= 360 then 'N' 
	end 
where heading > 0;
update utah_roads set direction = 
	case 
		when heading < 30 then 'N' 
		when heading < 60 then 'NE' 
		when heading < 120 then 'E' 
		when heading < 150 then 'SE' 
		when heading < 210 then 'S' 
		when heading < 240 then 'SW' 
		when heading < 300 then 'W' 
		when heading < 330 then 'NW' 
		when heading <= 360 then 'N' 
	end 
where heading > 0;

update utah_roads set direction = 
	case 
		when heading < 45 then 'N' 
		when heading < 135 then 'E' 
		when heading < 225 then 'S' 
		when heading < 315 then 'W' 
		when heading <= 360 then 'N' 
	end 
where heading > 0;


alter table utogm_gas_plants add column lat double precision;
alter table utogm_gas_plants add column long double precision;

update utogm_gas_plants set lat = 40.6842588, long = -112.2835806 where id = 1;
update utogm_gas_plants set lat = 37.2512786, long = -109.3235047 where id = 3;
update utogm_gas_plants set lat = 40.0359790, long = -109.4260919 where id = 9;		
update utogm_gas_plants set lat = 39.0813349, long = -109.2669456 where id = 10;
update utogm_gas_plants set lat = 39.1107521, long = -109.1171632 where id = 12;
update utogm_gas_plants set lat = 40.0504994, long = -109.4639021 where id = 13;
update utogm_gas_plants set lat = 40.9959023, long = -109.2122514 where id = 14;
update utogm_gas_plants set lat = 40.3989222, long = -112.2409402 where id = 15;
update utogm_gas_plants set lat = 38.1633134, long = -109.2752845 where id = 16;
update utogm_gas_plants set lat = 40.9371886, long = -111.1424405 where id = 22;
update utogm_gas_plants set lat = 40.0598260, long = -110.1054824 where id = 24;
update utogm_gas_plants set lat = 39.6228990, long = -110.8254106 where id = 26;
update utogm_gas_plants set lat = 39.6228990, long = -110.8254106 where id = 27;
update utogm_gas_plants set lat = 40.1950333, long = -109.2754188 where id = 28;
update utogm_gas_plants set lat = 40.0360063, long = -109.4449706 where id = 31;

alter table utogm_gas_plants add column geom geometry(point,4269);
update utogm_gas_plants set geom = ST_SetSRID(ST_Point(long, lat),4269);

alter table utogm_gas_plants add column geom_utm geometry(point,26912);
update utogm_gas_plants set geom_utm = ST_Transform(ST_SetSRID(geom, 4269), 26912);


39.076973, -109.291410
39.942299, -109.444560
39.903575, -109.605200
39.988318, -109.610112
39.989333, -109.845963
40.002750, -109.924863
40.083169, -110.216726
40.103735, -110.151733
40.028947, -109.430234
40.053282, -109.451843
40.063283, -109.399344
40.070377, -109.412873
40.071907, -109.459475
40.086563, -109.285909
40.140434, -108.841036
40.083874, -108.857573
40.087673, -108.854188
38.957780, -109.799058

select api, api || '0000' as link, well_name, wellstatus, well_type, lat_surf, long_surf, elevation from utogm_wells where well_status_id in (6,7,8,10) and well_type_id in (1,2,5,6) and county_fips in ('007','013','015','019','037','047');






