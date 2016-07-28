create table nmocd_wells (
	acres double precision,
	api varchar(10),
	operator varchar(45),
	plug_date date,
	producing_poolid integer,
	property integer,
	range varchar(5),
	sdiv_ul varchar(3),
	section integer,
	spud_date date,
	township varchar(5),
	tvd_depth integer,
	water_inj_2012 integer,
	water_inj_2013 integer,
	water_inj_2014 integer,
	water_prod_2012 integer,
	water_prod_2013 integer,
	water_prod_2014 integer,
	well_name varchar(50),
	well_type varchar(1),
	compl_status varchar(100),
	county varchar(15),
	days_prod_2012 integer,
	days_prod_2013 integer,
	days_prod_2014 integer,
	elevgl integer,
	ew_cd varchar(1),
	ftg_ew integer,
	ftg_ns integer,
	gas_prod_2012 integer,
	gas_prod_2013 integer,
	gas_prod_2014 integer,
	land_type varchar(2),
	last_prod_inj varchar(7),
	latitude double precision,
	longitude double precision,
	nbr_compls integer,
	ns_cd varchar(1),
	ocd_ul varchar(1),
	ogrid_cde integer,
	oil_prod_2012 integer,
	oil_prod_2013 integer,
	oil_prod_2014 integer,
	one_producing_pool_name varchar(35)
);

copy nmocd_wells from '/Users/troyburke/Data/nmocd/NewMexicoAllWells.txt' (format csv, delimiter ',', null '');

alter table nmocd_wells add column well_id serial primary key not null;


create table nmocd_well_statuses (
	id serial primary key not null,
	description varchar(50)
);

insert into nmocd_well_statuses (id, description) values (1, 'Active');
insert into nmocd_well_statuses (id, description) values (2, 'Dry Hole');
insert into nmocd_well_statuses (id, description) values (3, 'Never Drilled');
insert into nmocd_well_statuses (id, description) values (4, 'New (Not drilled or compl)');
insert into nmocd_well_statuses (id, description) values (5, 'Plugged');
insert into nmocd_well_statuses (id, description) values (6, 'TA');
insert into nmocd_well_statuses (id, description) values (7, 'Zone Plugged');
insert into nmocd_well_statuses (id, description) values (8, 'Zones Aban, not plgd');

alter table nmocd_wells add column well_status_id integer;

update nmocd_wells set well_status_id = (select ws.id from nmocd_well_statuses ws where trim(nmocd_wells.compl_status) = ws.description);


create table nmocd_well_types (
	id serial primary key not null,
	code varchar(1),
	description varchar(20)
);

insert into nmocd_well_types (id, code, description) values (1, 'G', 'Gas');
insert into nmocd_well_types (id, code, description) values (2, 'O', 'Oil');
insert into nmocd_well_types (id, code, description) values (3, 'W', 'Water');
insert into nmocd_well_types (id, code, description) values (4, 'I', 'Injection');
insert into nmocd_well_types (id, code, description) values (5, 'S', 'Salt Water Disposal');
insert into nmocd_well_types (id, code, description) values (6, 'C', 'CO2');
insert into nmocd_well_types (id, code, description) values (7, 'M', 'Miscellaneous');

alter table nmocd_wells add column well_type_id integer;

update nmocd_wells set well_type_id = (select wt.id from nmocd_well_types wt where trim(nmocd_wells.well_type) = wt.code);


create table nmocd_land_types (
	id serial primary key not null,
	code varchar(1),
	description varchar(20)
);

insert into nmocd_land_types (id, code, description) values (1, 'F', 'Federal');
insert into nmocd_land_types (id, code, description) values (2, 'S', 'State');
insert into nmocd_land_types (id, code, description) values (3, 'P', 'Private');
insert into nmocd_land_types (id, code, description) values (4, 'I', 'Indian');	
insert into nmocd_land_types (id, code, description) values (5, 'J', 'Jicarilla');
insert into nmocd_land_types (id, code, description) values (6, 'N', 'Navajo');
insert into nmocd_land_types (id, code, description) values (7, 'U', 'Ute');

alter table nmocd_wells add column land_type_id integer;

update nmocd_wells set land_type_id = (select lt.id from nmocd_land_types lt where trim(nmocd_wells.land_type) = lt.code);

update nmocd_wells set land_type = null where trim(land_type) = '';

create index nmocd_wells_well_type_id_idx on nmocd_wells(well_type_id);
create index nmocd_wells_well_status_id_idx on nmocd_wells(well_status_id);


create table nmocd_scrape_statuses (
	id serial primary key not null,
	well_id integer,
	well_status_id integer,
	well_api_number varchar(12),
	api_number varchar(10),
	api_state varchar(2),
	api_county varchar(3),
	api_sequence varchar(5),
	frac_focus_status varchar(50)
);

insert into nmocd_scrape_statuses (well_id, well_status_id, well_api_number, api_number, api_state, api_county, api_sequence, frac_focus_status)
select well_id, well_status_id, '30-' || substr(api,3,3) || '-' || right(api,5), api, '30', substr(api,3,3), right(api,5), 'not scraped'
from nmocd_wells;

alter table nmocd_scrape_statuses add column well_type_id integer;

update nmocd_scrape_statuses set well_type_id = (select w.well_type_id from nmocd_wells w where nmocd_scrape_statuses.well_id = w.well_id);




select 
	count(ffw.id) as well_count, 
	ws.code as status_code, 
	ws.description as status_description 
from 
	cogcc_well_status ws
left outer join 
	cogcc_wells w on ws.id = w.well_status_id
left outer join 
	frac_focus_wells ffw on w.well_id = ffw.well_id
group by 
	ws.code,
	ws.description
order by 
	well_count desc;


-- pgshape import road shapefile srid=4326

-- dir values missing from shapefile, get from csv download
create table new_mexico_road_dirs (
	objectid integer,
	cardinal varchar(1)
);
copy new_mexico_road_dirs from '/Users/troyburke/Data/nmocd/road_dirs.csv' (format csv, delimiter ',', null '-9999');
create index new_mexico_road_dirs_objectid_idx on new_mexico_road_dirs (objectid);
alter table new_mexico_roads alter column objectid type integer using objectid::integer;
create index new_mexico_roads_objectid_idx on new_mexico_roads (objectid);
update new_mexico_roads set cardinal = null;
alter table new_mexico_roads alter column cardinal type varchar(1) using cardinal::varchar;
update new_mexico_roads set cardinal = (select cardinal from new_mexico_road_dirs where objectid = new_mexico_roads.objectid);

alter table new_mexico_roads add column geom_line geometry(MultiLineString,4326);
SELECT COUNT( CASE WHEN ST_NumGeometries(geom) = 1 THEN 1 END ) AS multi, COUNT(geom) AS total FROM new_mexico_roads;
update new_mexico_roads set geom_line = geom where ST_NumGeometries(geom) < 2;
alter table new_mexico_roads alter column geom_line type geometry(LineString,4326) using ST_GeometryN(geom_line, 1);
create index new_mexico_roads_geom_line_gist on new_mexico_roads using gist (geom_line);

alter table new_mexico_roads add column azimuth double precision;
update new_mexico_roads set azimuth = ST_Azimuth(ST_StartPoint(geom_line),ST_EndPoint(geom_line)) where geom_line is not null;

alter table new_mexico_roads add column heading double precision;
update new_mexico_roads set heading = azimuth*180/pi() where azimuth is not null;

alter table new_mexico_roads add column direction varchar(2);
update new_mexico_roads set direction = 
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
update new_mexico_roads set direction = 
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

update new_mexico_roads set direction = 
	case 
		when heading < 45 then 'N' 
		when heading < 135 then 'E' 
		when heading < 225 then 'S' 
		when heading < 315 then 'W' 
		when heading <= 360 then 'N' 
	end 
where heading > 0;



CREATE TABLE nmocd_wells_backup AS SELECT * FROM nmocd_wells;
drop table nmocd_wells;


create table nmocd_wells (
	api varchar(10), 
	well_name varchar(100), 
	well_number varchar(30), 
	type varchar(30), 
	lease varchar(20), 
	status varchar(30), 
	initial_apd_approval_date varchar(20), 
	unit_letter varchar(10), 
	section varchar(10), 
	township varchar(10), 
	range varchar(10), 
	ocd_unit_letter varchar(10), 
	footages varchar(100), 
	latitude double precision, 
	longitude double precision, 
	last_production varchar(20), 
	spud_date varchar(20), 
	measured_depth varchar(10), 
	true_vertical_depth varchar(10), 
	elevation varchar(10), 
	last_inspection varchar(20), 
	last_mit varchar(20), 
	plugged_on varchar(20), 
	current_operator  varchar(250), 
	district varchar(100)
);


CREATE TABLE nmocd_wells_backup AS SELECT * FROM nmocd_wells;
drop table nmocd_wells;


create table nmocd_wells (
	api varchar(30), 
	well_name varchar(100), 
	well_number varchar(30), 
	type varchar(30), 
	lease varchar(20), 
	status varchar(30), 
	initial_apd_approval_date varchar(30), 
	unit_letter varchar(20), 
	section varchar(10), 
	township varchar(10), 
	range varchar(10), 
	ocd_unit_letter varchar(10), 
	footages varchar(100), 
	latitude double precision, 
	longitude double precision, 
	last_production varchar(30), 
	spud_date varchar(30), 
	measured_depth varchar(20), 
	true_vertical_depth varchar(20), 
	elevation varchar(20), 
	last_inspection varchar(30), 
	last_mit varchar(30), 
	plugged_on varchar(20), 
	current_operator varchar(250), 
	district varchar(100)
);

alter table nmocd_wells add column id serial primary key not null;
alter table nmocd_wells add column well_id bigint;
update nmocd_wells set well_id = replace(api,'-','')::bigint;


update nmocd_wells set elevation = null where trim(elevation) = '';
alter table nmocd_wells alter column elevation type integer using elevation::integer;

alter table nmocd_wells add column operator_number integer;
alter table nmocd_wells add column operator_name varchar(250);

select trim(split_part(current_operator, '] ', 2)) from nmocd_wells;
update nmocd_wells set operator_name = trim(split_part(current_operator, '] ', 2));

select trim(replace(split_part(current_operator, '] ', 1), '[', '')) from nmocd_wells;
update nmocd_wells set operator_number = trim(replace(split_part(current_operator, '] ', 1), '[', ''))::integer;


CREATE TABLE nmocd_well_statuses_backup AS SELECT * FROM nmocd_well_statuses;
drop table nmocd_well_statuses;
create table nmocd_well_statuses (
	id serial primary key not null,
	description varchar(50)
);

insert into nmocd_well_statuses (id, description) values (1, 'Active');
insert into nmocd_well_statuses (id, description) values (2, 'Approved Temporary Abandonment');
insert into nmocd_well_statuses (id, description) values (3, 'Cancelled Apd');
insert into nmocd_well_statuses (id, description) values (4, 'Dry Hole');
insert into nmocd_well_statuses (id, description) values (5, 'Expired Temporary Abandonment');
insert into nmocd_well_statuses (id, description) values (6, 'Never Drilled');
insert into nmocd_well_statuses (id, description) values (7, 'New');
insert into nmocd_well_statuses (id, description) values (8, 'Plugged, Not Released');
insert into nmocd_well_statuses (id, description) values (9, 'Plugged, Site Released');
insert into nmocd_well_statuses (id, description) values (10, 'Shut In');
insert into nmocd_well_statuses (id, description) values (11, 'Zones Permanently Plugged');
insert into nmocd_well_statuses (id, description) values (12, 'Zones Temporarily Plugged');

alter table nmocd_wells add column well_status_id integer;
update nmocd_wells set well_status_id = (select ws.id from nmocd_well_statuses ws where trim(nmocd_wells.status) = ws.description);

CREATE TABLE nmocd_well_types_backup AS SELECT * FROM nmocd_well_types;
drop table nmocd_well_types;
create table nmocd_well_types (
	id serial primary key not null,
	description varchar(20)
);

insert into nmocd_well_types (id, description) values (1, 'Gas');
insert into nmocd_well_types (id, description) values (2, 'Oil');
insert into nmocd_well_types (id, description) values (3, 'Water');
insert into nmocd_well_types (id, description) values (4, 'Gas Storage');
insert into nmocd_well_types (id, description) values (5, 'Injection');
insert into nmocd_well_types (id, description) values (6, 'Geosequestration');
insert into nmocd_well_types (id, description) values (7, 'Salt Water Disposal');
insert into nmocd_well_types (id, description) values (8, 'CO2');
insert into nmocd_well_types (id, description) values (9, 'Miscellaneous');
insert into nmocd_well_types (id, description) values (10, 'Monitor');
insert into nmocd_well_types (id, description) values (11, 'Observation');

alter table nmocd_wells add column well_type_id integer;
update nmocd_wells set well_type_id = (select wt.id from nmocd_well_types wt where trim(nmocd_wells.type) = wt.description);

SELECT AddGeometryColumn ('public','nmocd_wells','geom',4269,'POINT',2);
SELECT AddGeometryColumn ('public','nmocd_wells','geom_utm',26913,'POINT',2);

update nmocd_wells SET geom = ST_SetSRID(ST_Point(longitude,latitude),4269) where longitude < 0 and latitude > 0;
update nmocd_wells set geom_utm = ST_Transform(geom, 26913) where geom is not null;


--  13 | SAN JUAN
alter table nmocd_wells add column is_san_juan boolean not null default false;
update nmocd_wells set is_san_juan = 'true' where ST_Within(geom_utm,(select gb.geom_nad83 from gas_basins gb where gb.name ='SAN JUAN'));
-- 34,201 wells

-- add san juan flag to cogcc as well
alter table cogcc_well_surface_locations add column is_san_juan boolean not null default false;
update cogcc_well_surface_locations set is_san_juan = 'true' where ST_Within(geom,(select gb.geom_nad83 from gas_basins gb where gb.name ='SAN JUAN'));
--4,829 wells


Active and Producing (1/11)
Shut In (10/13)
Temporarily Abandoned (2,5,12/15)
Injecting (type=5/9)
Plugged and Abandoned (8,9,11/10)
Dry and Abandoned (4/6)



-- san juan well file (CO + NM)
COPY (select 
	'CO' as state, 
	co.attrib_1 as api_number, 
	co.well_name, 
	'#' || co.well_num as well_number, 
	null as land_type, 
	case well_status_id when 6 then 'Dry and Abandoned' when 9 then 'Injecting' when 10 then 'Plugged and Abandoned' when 11 then 'Active and Producing' when 13 then 'Shut In' when 15 then 'Temporarily Abandoned' end as status, 
	co.facility_t as type, 
	co.operator_n as operator_number, 
	co.name as operator_name, 
	co.lat as latitude, 
	co.long as longitude, 
	co.ground_ele as elevation 
from 
	cogcc_well_surface_locations co 
where 
	co.is_san_juan is true 
	and well_status_id in (6,9,10,11,13,15) -- EXCLUDED STATUSES: Abandoned Location, Drilling, Waiting on Completion, Permitted Location
union 
select 
	'NM' as state, 
	api as api_number, 
	nm.well_name, 
	nm.well_number, 
	nm.lease as land_type, 
	case when well_status_id = 6 then 'Dry and Abandoned' when well_type_id = 5 then 'Injecting' when well_status_id in (8,9,11) then 'Plugged and Abandoned' when well_status_id = 1 then 'Active and Producing' when well_status_id  = 10 then 'Shut In' when well_status_id in (2,5,12) then 'Temporarily Abandoned' end as status, 
	nm.type, 
	nm.operator_number, 
	nm.operator_name, 
	nm.latitude, 
	nm.longitude, 
	nm.elevation 
from 
	nmocd_wells nm 
where 
	nm.is_san_juan is true 
	and well_type_id in (1,2,5) -- gas, oil, injection
	and well_status_id in (1,2,4,5,8,9,10,11,12) -- EXCLUDED STATUSES: Cancelled Apd, Never Drilled, New
	and status is not null 
order by 
	state, 
	api_number) TO '/Users/troyburke/Projects/ruby/nmocd/san_juan_basin_wells.csv' WITH CSV HEADER;


alter table cdot_local_roads add column is_san_juan_basin boolean not null default false;
alter table cdot_major_roads add column is_san_juan_basin boolean not null default false;
alter table highways add column is_san_juan_basin boolean not null default false;
alter table new_mexico_roads add column is_san_juan_basin boolean not null default false;

update cdot_local_roads set is_san_juan_basin = 'true' where ST_Contains((select gb.geom_nad83 from gas_basins gb where gb.name ='SAN JUAN'),geom);
update cdot_major_roads set is_san_juan_basin = 'true' where ST_Contains((select gb.geom_nad83 from gas_basins gb where gb.name ='SAN JUAN'),geom);
update highways set is_san_juan_basin = 'true' where ST_Contains((select gb.geom_nad83 from gas_basins gb where gb.name ='SAN JUAN'),geom);

SELECT AddGeometryColumn ('public','new_mexico_roads','geom_utm',26913,'MultiLineString',2);
update new_mexico_roads set geom_utm = ST_Transform(geom, 26913) where geom is not null;
update new_mexico_roads set is_san_juan_basin = 'true' where ST_Contains((select gb.geom_nad83 from gas_basins gb where gb.name ='SAN JUAN'),geom_utm);




# proximity table
create table san_juan_well_road_distances (
	id serial primary key not null, 
	facility_id integer, 
	facility_type_id integer, 
	facility_type_name varchar(50), 
	well_id bigint, 
	well_api_number varchar(12),
	well_status_id integer, 
	well_type_id integer, 
	county_name varchar(50), 
	county_fips varchar(3), 
	lat double precision, 
	long double precision, 
	well_geom geometry(POINT,26913), 
	road_gid integer, 
	road_fullname varchar(100), 
	road_streetname varchar(100), 
	road_direction varchar(2), 
	road_geom geometry(MultiLineString,26913), 
	closest_point_lat double precision, 
	closest_point_long double precision, 
	closest_point_geom geometry(POINT,26913),
	distance real, 
	closest_direction varchar(2), 
	wind_direction varchar(2), 
	wind_dir_suspect boolean not null default false
);


select 
	w.well_id, 
	w.api, 
	w.well_status_id, 
	w.well_type_id, 
	w.latitude, 
	w.longitude, 
	r.gid, 
	r.route,
	r.pstd_rte, 
	case when r.dir is null then r.direction else r.dir end as road_direction
from 
	nmocd_wells w 
cross join 
	new_mexico_roads r 
where 
	w.is_san_juan is true 
	and w.well_type_id in (1,2,5) -- gas, oil, injection
	and w.well_status_id in (1,2,4,5,8,9,10,11,12) -- EXCLUDED STATUSES: Cancelled Apd, Never Drilled, New
	and w.status is not null 
	and r.is_san_juan_basin is true 
	and ST_Distance(w.geom_utm, ST_ClosestPoint(r.geom_utm,w.geom_utm)) < 101;




insert into san_juan_well_road_distances (well_id, well_api_number, well_status_id, well_type_id, lat, long, well_geom, road_gid, road_fullname, road_streetname, road_direction, road_geom, closest_point_geom) 
select 
	w.well_id, 
	w.api, 
	w.well_status_id, 
	w.well_type_id, 
	w.latitude, 
	w.longitude, 
	w.geom_utm, 
	r.gid, 
	r.route,
	r.pstd_rte, 
	case when r.dir is null then r.direction else r.dir end as road_direction,
	r.geom_utm, 
	ST_ClosestPoint(r.geom_utm,w.geom_utm)
from 
	nmocd_wells w 
cross join 
	new_mexico_roads r 
where 
	w.is_san_juan is true 
	and w.well_type_id in (1,2,5) -- gas, oil, injection
	and w.well_status_id in (1,2,4,5,8,9,10,11,12) -- EXCLUDED STATUSES: Cancelled Apd, Never Drilled, New
	and w.status is not null 
	and r.is_san_juan_basin is true 
	and ST_Distance(w.geom_utm, ST_ClosestPoint(r.geom_utm,w.geom_utm)) < 101;


update san_juan_well_road_distances 
set closest_point_lat = ST_Y(ST_Transform(ST_SetSRID(closest_point_geom, 26913), 4269)), closest_point_long = ST_X(ST_Transform(ST_SetSRID(closest_point_geom, 26913), 4269)), distance = ST_Distance(well_geom, closest_point_geom)
where distance is null;

-- closest point => point on road closest to well and direction is relative to well
update san_juan_well_road_distances 
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

update san_juan_well_road_distances 
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


update san_juan_well_road_distances set wind_direction = 'N' where closest_direction = 'S';
update san_juan_well_road_distances set wind_direction = 'S' where closest_direction = 'N';
update san_juan_well_road_distances set wind_direction = 'E' where closest_direction = 'W';
update san_juan_well_road_distances set wind_direction = 'W' where closest_direction = 'E';

update san_juan_well_road_distances set wind_direction = 'NE' where closest_direction = 'SW';
update san_juan_well_road_distances set wind_direction = 'SW' where closest_direction = 'NE';
update san_juan_well_road_distances set wind_direction = 'NW' where closest_direction = 'SE';
update san_juan_well_road_distances set wind_direction = 'SE' where closest_direction = 'NW';

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



-- ################################### STARTING OVER WITH PRIOR WELL APPROACH ##################################################

CREATE TABLE nmocd_wells_aborted AS SELECT * FROM nmocd_wells;
drop table nmocd_wells;
alter table nmocd_well_statuses rename to nmocd_well_statuses_aborted;
alter table nmocd_well_types rename to nmocd_well_types_aborted;
alter table nmocd_well_types rename to nmocd_well_types_aborted;

create table nmocd_wells (
	acres double precision,
	api varchar(10),
	operator varchar(45),
	plug_date date,
	producing_poolid integer,
	property integer,
	range varchar(5),
	sdiv_ul varchar(3),
	section integer,
	spud_date date,
	township varchar(5),
	tvd_depth integer,
	water_inj_2013 integer,
	water_inj_2014 integer,
	water_inj_2015 integer,
	water_prod_2013 integer,
	water_prod_2014 integer,
	water_prod_2015 integer,
	well_name varchar(50),
	well_type varchar(1),
	compl_status varchar(100),
	county varchar(15),
	days_prod_2013 integer,
	days_prod_2014 integer,
	days_prod_2015 integer,
	elevgl integer,
	ew_cd varchar(1),
	ftg_ew integer,
	ftg_ns integer,
	gas_prod_2013 integer,
	gas_prod_2014 integer,
	gas_prod_2015 integer,
	land_type varchar(2),
	last_prod_inj varchar(7),
	latitude double precision,
	longitude double precision,
	nbr_compls integer,
	ns_cd varchar(1),
	ocd_ul varchar(1),
	ogrid_cde integer,
	oil_prod_2013 integer,
	oil_prod_2014 integer,
	oil_prod_2015 integer,
	one_producing_pool_name varchar(35)
);

copy nmocd_wells from '/Users/troyburke/Data/nmocd/AllWells_20150310.txt' (format csv, delimiter ',', null '');

alter table nmocd_wells add column id serial primary key not null;
alter table nmocd_wells add column well_id bigint;
update nmocd_wells set well_id = replace(api,'-','')::bigint;

drop table nmocd_well_statuses;
create table nmocd_well_statuses (
	id serial primary key not null,
	description varchar(50)
);

insert into nmocd_well_statuses (id, description) values (1, 'Active');
insert into nmocd_well_statuses (id, description) values (2, 'Dry Hole');
insert into nmocd_well_statuses (id, description) values (3, 'Never Drilled');
insert into nmocd_well_statuses (id, description) values (4, 'New (Not drilled or compl)');
insert into nmocd_well_statuses (id, description) values (5, 'Plugged');
insert into nmocd_well_statuses (id, description) values (6, 'TA');
insert into nmocd_well_statuses (id, description) values (7, 'Zone Plugged');
insert into nmocd_well_statuses (id, description) values (8, 'Zones Aban, not plgd');

alter table nmocd_wells add column well_status_id integer;
update nmocd_wells set well_status_id = (select ws.id from nmocd_well_statuses ws where trim(nmocd_wells.compl_status) = ws.description);


drop table nmocd_well_types;
create table nmocd_well_types (
	id serial primary key not null,
	code varchar(1),
	description varchar(20)
);

insert into nmocd_well_types (id, code, description) values (1, 'G', 'Gas');
insert into nmocd_well_types (id, code, description) values (2, 'O', 'Oil');
insert into nmocd_well_types (id, code, description) values (3, 'W', 'Water');
insert into nmocd_well_types (id, code, description) values (4, 'I', 'Injection');
insert into nmocd_well_types (id, code, description) values (5, 'S', 'Salt Water Disposal');
insert into nmocd_well_types (id, code, description) values (6, 'C', 'CO2');
insert into nmocd_well_types (id, code, description) values (7, 'M', 'Miscellaneous');

alter table nmocd_wells add column well_type_id integer;
update nmocd_wells set well_type_id = (select wt.id from nmocd_well_types wt where trim(nmocd_wells.well_type) = wt.code);


drop table nmocd_land_types;
create table nmocd_land_types (
	id serial primary key not null,
	code varchar(1),
	description varchar(20)
);

insert into nmocd_land_types (id, code, description) values (1, 'F', 'Federal');
insert into nmocd_land_types (id, code, description) values (2, 'S', 'State');
insert into nmocd_land_types (id, code, description) values (3, 'P', 'Private');
insert into nmocd_land_types (id, code, description) values (4, 'I', 'Indian');	
insert into nmocd_land_types (id, code, description) values (5, 'J', 'Jicarilla');
insert into nmocd_land_types (id, code, description) values (6, 'N', 'Navajo');
insert into nmocd_land_types (id, code, description) values (7, 'U', 'Ute');

alter table nmocd_wells add column land_type_id integer;
update nmocd_wells set land_type_id = (select lt.id from nmocd_land_types lt where trim(nmocd_wells.land_type) = lt.code);
update nmocd_wells set land_type = null where trim(land_type) = '';

create index nmocd_wells_well_type_id_idx on nmocd_wells(well_type_id);
create index nmocd_wells_well_status_id_idx on nmocd_wells(well_status_id);
create index nmocd_wells_well_id_idx on nmocd_wells(well_id);

SELECT AddGeometryColumn ('public','nmocd_wells','geom',4269,'POINT',2);
SELECT AddGeometryColumn ('public','nmocd_wells','geom_utm13',26913,'POINT',2);

update nmocd_wells SET geom = ST_SetSRID(ST_Point(longitude,latitude),4269) where zero_lat_long is false;
update nmocd_wells set geom_utm13 = ST_Transform(geom, 26913) where geom is not null;

create index nmocd_wells_geom_umt13_gist on nmocd_wells using gist (geom_utm13);

--SELECT AddGeometryColumn ('public','nmocd_wells','geom_wgs84',4326,'POINT',2);
--update nmocd_wells set geom_wgs84 = ST_Transform(geom, 4326) where geom is not null;
--alter table nmocd_wells add column lat_wgs84 double precision;
--update nmocd_wells set lat_wgs84 = ST_Y(geom_wgs84) where geom_wgs84 is not null;
--alter table nmocd_wells add column long_wgs84 double precision;
--update nmocd_wells set long_wgs84 = ST_X(geom_wgs84) where geom_wgs84 is not null;

--update nmocd_wells set geom = ST_SetSRID(ST_Point(longitude,latitude),4267) where geom is null and longitude < 0 and latitude > 0;
--update nmocd_wells set geom_wgs84 = ST_Transform(geom, 4326) where geom_wgs84 is null and longitude < 0 and latitude > 0;
--update nmocd_wells set lat_wgs84 = ST_Y(geom_wgs84) where lat_wgs84 is null and longitude < 0 and latitude > 0;
--update nmocd_wells set long_wgs84 = ST_X(geom_wgs84) where long_wgs84 is null and longitude < 0 and latitude > 0;

--  13 | SAN JUAN
alter table nmocd_wells add column is_san_juan boolean not null default false;
--update nmocd_wells set is_san_juan = 'true' where ST_Contains((select gb.geom_nad83 from gas_basins gb where gb.name ='SAN JUAN'),geom_utm);
-- 29,509 wells
update nmocd_wells set is_san_juan = 'true' where county in ('San Juan','Rio Arriba','McKinley','Sandoval');
-- 34,059 wells

-- pgshape import san juan roads shapefile srid=4326
alter table nm_san_juan_roads add column geom_line geometry(MultiLineString,26913);
SELECT COUNT( CASE WHEN ST_NumGeometries(geom) = 1 THEN 1 END ) AS multi, COUNT(geom) AS total FROM nm_san_juan_roads;
update nm_san_juan_roads set geom_line = ST_Transform(geom, 26913) where ST_NumGeometries(geom) < 2;
alter table nm_san_juan_roads alter column geom_line type geometry(LineString,26913) using ST_GeometryN(geom_line, 1);
create index nm_san_juan_roads_geom_line_gist on nm_san_juan_roads using gist (geom_line);

alter table nm_san_juan_roads add column azimuth double precision;
update nm_san_juan_roads set azimuth = ST_Azimuth(ST_StartPoint(geom_line),ST_EndPoint(geom_line)) where geom_line is not null;

alter table nm_san_juan_roads add column heading double precision;
update nm_san_juan_roads set heading = azimuth*180/pi() where azimuth is not null;

alter table nm_san_juan_roads add column direction varchar(2);
update nm_san_juan_roads set direction = 
	case 
		when heading < 45 then 'N' 
		when heading < 135 then 'E' 
		when heading < 225 then 'S' 
		when heading < 315 then 'W' 
		when heading <= 360 then 'N' 
	end 
where heading > 0;

-- pgshape import rio arriba roads shapefile srid=4326
alter table nm_rio_arriba_roads add column geom_line geometry(MultiLineString,26913);
SELECT COUNT( CASE WHEN ST_NumGeometries(geom) = 1 THEN 1 END ) AS multi, COUNT(geom) AS total FROM nm_rio_arriba_roads;
update nm_rio_arriba_roads set geom_line = ST_Transform(geom, 26913) where ST_NumGeometries(geom) < 2;
alter table nm_rio_arriba_roads alter column geom_line type geometry(LineString,26913) using ST_GeometryN(geom_line, 1);
create index nm_rio_arriba_roads_geom_line_gist on nm_rio_arriba_roads using gist (geom_line);

alter table nm_rio_arriba_roads add column azimuth double precision;
update nm_rio_arriba_roads set azimuth = ST_Azimuth(ST_StartPoint(geom_line),ST_EndPoint(geom_line)) where geom_line is not null;

alter table nm_rio_arriba_roads add column heading double precision;
update nm_rio_arriba_roads set heading = azimuth*180/pi() where azimuth is not null;

alter table nm_rio_arriba_roads add column direction varchar(2);
update nm_rio_arriba_roads set direction = 
	case 
		when heading < 45 then 'N' 
		when heading < 135 then 'E' 
		when heading < 225 then 'S' 
		when heading < 315 then 'W' 
		when heading <= 360 then 'N' 
	end 
where heading > 0;

-- pgshape import sandoval roads shapefile srid=4326
alter table nm_sandoval_roads add column geom_line geometry(MultiLineString,26913);
SELECT COUNT( CASE WHEN ST_NumGeometries(geom) = 1 THEN 1 END ) AS multi, COUNT(geom) AS total FROM nm_sandoval_roads;
update nm_sandoval_roads set geom_line = ST_Transform(geom, 26913) where ST_NumGeometries(geom) < 2;
alter table nm_sandoval_roads alter column geom_line type geometry(LineString,26913) using ST_GeometryN(geom_line, 1);
create index nm_sandoval_roads_geom_line_gist on nm_sandoval_roads using gist (geom_line);

alter table nm_sandoval_roads add column azimuth double precision;
update nm_sandoval_roads set azimuth = ST_Azimuth(ST_StartPoint(geom_line),ST_EndPoint(geom_line)) where geom_line is not null;

alter table nm_sandoval_roads add column heading double precision;
update nm_sandoval_roads set heading = azimuth*180/pi() where azimuth is not null;

alter table nm_sandoval_roads add column direction varchar(2);
update nm_sandoval_roads set direction = 
	case 
		when heading < 45 then 'N' 
		when heading < 135 then 'E' 
		when heading < 225 then 'S' 
		when heading < 315 then 'W' 
		when heading <= 360 then 'N' 
	end 
where heading > 0;

-- pgshape import mckinley roads shapefile srid=4326
alter table nm_mckinley_roads add column geom_line geometry(MultiLineString,26913);
SELECT COUNT( CASE WHEN ST_NumGeometries(geom) = 1 THEN 1 END ) AS multi, COUNT(geom) AS total FROM nm_mckinley_roads;
update nm_mckinley_roads set geom_line = ST_Transform(geom, 26913) where ST_NumGeometries(geom) < 2;
alter table nm_mckinley_roads alter column geom_line type geometry(LineString,26913) using ST_GeometryN(geom_line, 1);
create index nm_mckinley_roads_geom_line_gist on nm_mckinley_roads using gist (geom_line);

alter table nm_mckinley_roads add column azimuth double precision;
update nm_mckinley_roads set azimuth = ST_Azimuth(ST_StartPoint(geom_line),ST_EndPoint(geom_line)) where geom_line is not null;

alter table nm_mckinley_roads add column heading double precision;
update nm_mckinley_roads set heading = azimuth*180/pi() where azimuth is not null;

alter table nm_mckinley_roads add column direction varchar(2);
update nm_mckinley_roads set direction = 
	case 
		when heading < 45 then 'N' 
		when heading < 135 then 'E' 
		when heading < 225 then 'S' 
		when heading < 315 then 'W' 
		when heading <= 360 then 'N' 
	end 
where heading > 0;

-- pgshape import new mexico roads shapefile srid=4326
alter table new_mexico_roads add column geom_line geometry(MultiLineString,26913);
SELECT COUNT( CASE WHEN ST_NumGeometries(geom) = 1 THEN 1 END ) AS multi, COUNT(geom) AS total FROM new_mexico_roads;
update new_mexico_roads set geom_line = ST_Transform(geom, 26913) where ST_NumGeometries(geom) < 2;
alter table new_mexico_roads alter column geom_line type geometry(LineString,26913) using ST_GeometryN(geom_line, 1);
create index new_mexico_roads_geom_line_gist on new_mexico_roads using gist (geom_line);

alter table new_mexico_roads add column azimuth double precision;
update new_mexico_roads set azimuth = ST_Azimuth(ST_StartPoint(geom_line),ST_EndPoint(geom_line)) where geom_line is not null;

alter table new_mexico_roads add column heading double precision;
update new_mexico_roads set heading = azimuth*180/pi() where azimuth is not null;

alter table new_mexico_roads add column direction varchar(2);
update new_mexico_roads set direction = 
	case 
		when heading < 45 then 'N' 
		when heading < 135 then 'E' 
		when heading < 225 then 'S' 
		when heading < 315 then 'W' 
		when heading <= 360 then 'N' 
	end 
where heading > 0;


update new_mexico_roads set direction = 
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


create table new_mexico_well_road_distances (
	id serial primary key not null, 
	well_id bigint, 
	well_api varchar(10), 
	well_status_id integer, 
	well_type_id integer, 
	land_type_id integer, 
	county_name varchar(50), 
	county_fips varchar(3), 
	lat double precision, 
	long double precision, 
	well_geom geometry(POINT,26913), 
	road_gid integer, 
	road_fullname varchar(100), 
	road_streetname varchar(100), 
	road_direction varchar(2), 
	road_geom geometry(LineString,26913), 
	closest_point_lat double precision, 
	closest_point_long double precision, 
	closest_point_geom geometry(POINT,26913),
	distance real, 
	closest_direction varchar(2), 
	wind_direction varchar(2), 
	wind_dir_suspect boolean not null default false
);

select gid, route, chdbst, cardinal, tims_rt, id, dir, lanes, pstd_rte, source, strname, rtprefix, lineage, end_mpnt, rtsys, rtsystem, objectid, pstd_rte_d, beg_mpnt, rtno_c, maint, src_stname, gismilen, direction from new_mexico_roads;


insert into new_mexico_well_road_distances (well_id, well_api, well_status_id, well_type_id, land_type_id, county_name, county_fips, lat, long, well_geom, road_gid, road_fullname, road_direction, road_geom, closest_point_geom) 
select 
	w.well_id, 
	w.api, 
	w.well_status_id, 
	w.well_type_id, 
	w.land_type_id, 
	w.county, 
	w.county_fips, 
	w.latitude, 
	w.longitude, 
	w.geom_utm13, 
	r.gid, 
	r.fename,
	r.direction, 
	r.geom_line, 
	ST_ClosestPoint(r.geom_line,w.geom_utm13)
from 
	nmocd_wells w 
cross join 
	nm_san_juan_roads r 
where 
	w.is_san_juan is true 
	and w.well_status_id = 1 -- Active
	and w.well_type_id in (1,2) -- Gas, Oil
	and ST_Distance(w.geom_utm13, ST_ClosestPoint(r.geom_line,w.geom_utm13)) < 101;

insert into new_mexico_well_road_distances (well_id, well_api, well_status_id, well_type_id, land_type_id, county_name, county_fips, lat, long, well_geom, road_gid, road_fullname, road_direction, road_geom, closest_point_geom) 
select 
	w.well_id, 
	w.api, 
	w.well_status_id, 
	w.well_type_id, 
	w.land_type_id, 
	w.county, 
	w.county_fips, 
	w.latitude, 
	w.longitude, 
	w.geom_utm13, 
	r.gid, 
	r.fename,
	r.direction, 
	r.geom_line, 
	ST_ClosestPoint(r.geom_line,w.geom_utm13)
from 
	nmocd_wells w 
cross join 
	nm_rio_arriba_roads r 
where 
	w.is_san_juan is true 
	and w.well_status_id = 1 -- Active
	and w.well_type_id in (1,2) -- Gas, Oil
	and ST_Distance(w.geom_utm13, ST_ClosestPoint(r.geom_line,w.geom_utm13)) < 101;


insert into new_mexico_well_road_distances (well_id, well_api, well_status_id, well_type_id, land_type_id, county_name, county_fips, lat, long, well_geom, road_gid, road_fullname, road_direction, road_geom, closest_point_geom) 
select 
	w.well_id, 
	w.api, 
	w.well_status_id, 
	w.well_type_id, 
	w.land_type_id, 
	w.county, 
	w.county_fips, 
	w.latitude, 
	w.longitude, 
	w.geom_utm13, 
	r.gid, 
	r.fename,
	r.direction, 
	r.geom_line, 
	ST_ClosestPoint(r.geom_line,w.geom_utm13)
from 
	nmocd_wells w 
cross join 
	nm_sandoval_roads r 
where 
	w.is_san_juan is true 
	and w.well_status_id = 1 -- Active
	and w.well_type_id in (1,2) -- Gas, Oil
	and ST_Distance(w.geom_utm13, ST_ClosestPoint(r.geom_line,w.geom_utm13)) < 101;

insert into new_mexico_well_road_distances (well_id, well_api, well_status_id, well_type_id, land_type_id, county_name, county_fips, lat, long, well_geom, road_gid, road_fullname, road_direction, road_geom, closest_point_geom) 
select 
	w.well_id, 
	w.api, 
	w.well_status_id, 
	w.well_type_id, 
	w.land_type_id, 
	w.county, 
	w.county_fips, 
	w.latitude, 
	w.longitude, 
	w.geom_utm13, 
	r.gid, 
	r.fename,
	r.direction, 
	r.geom_line, 
	ST_ClosestPoint(r.geom_line,w.geom_utm13)
from 
	nmocd_wells w 
cross join 
	nm_mckinley_roads r 
where 
	w.is_san_juan is true 
	and w.well_status_id = 1 -- Active
	and w.well_type_id in (1,2) -- Gas, Oil
	and ST_Distance(w.geom_utm13, ST_ClosestPoint(r.geom_line,w.geom_utm13)) < 101;

insert into new_mexico_well_road_distances (well_id, well_api, well_status_id, well_type_id, land_type_id, county_name, county_fips, lat, long, well_geom, road_gid, road_fullname, road_direction, road_geom, closest_point_geom, county_shapefile) 
select 
	w.well_id, 
	w.api, 
	w.well_status_id, 
	w.well_type_id, 
	w.land_type_id, 
	w.county, 
	w.county_fips, 
	w.latitude, 
	w.longitude, 
	w.geom_utm13, 
	r.gid, 
	r.route,
	r.direction, 
	r.geom_line, 
	ST_ClosestPoint(r.geom_line,w.geom_utm13), 
	'false'
from 
	nmocd_wells w 
cross join 
	new_mexico_roads r 
where 
	w.is_san_juan is true 
	and w.well_status_id = 1 -- Active
	and w.well_type_id in (1,2) -- Gas, Oil
	and ST_Distance(w.geom_utm13, ST_ClosestPoint(r.geom_line,w.geom_utm13)) < 101;

-- inserted wrong lat/long, need wgs84 instead of nad27
--alter table new_mexico_well_road_distances add column lat_wgs84 double precision;
--update new_mexico_well_road_distances set lat_wgs84 = (select lat_wgs84 from nmocd_wells where well_id = new_mexico_well_road_distances.well_id);
--alter table new_mexico_well_road_distances add column long_wgs84 double precision;
--update new_mexico_well_road_distances set long_wgs84 = (select long_wgs84 from nmocd_wells where well_id = new_mexico_well_road_distances.well_id);

update new_mexico_well_road_distances 
set closest_point_lat = ST_Y(ST_Transform(ST_SetSRID(closest_point_geom, 26913), 4269)), closest_point_long = ST_X(ST_Transform(ST_SetSRID(closest_point_geom, 26913), 4269)), distance = ST_Distance(well_geom, closest_point_geom)
where distance is null;

update new_mexico_well_road_distances 
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

update new_mexico_well_road_distances set wind_direction = 'N' where closest_direction = 'S';
update new_mexico_well_road_distances set wind_direction = 'S' where closest_direction = 'N';
update new_mexico_well_road_distances set wind_direction = 'E' where closest_direction = 'W';
update new_mexico_well_road_distances set wind_direction = 'W' where closest_direction = 'E';

update new_mexico_well_road_distances set wind_dir_suspect = 'true' where road_direction in ('N','S') and closest_direction in ('E','W') and abs(closest_point_lat - lat) > (10 * abs(closest_point_long - long));
update new_mexico_well_road_distances set wind_dir_suspect = 'true' where road_direction in ('E','W') and closest_direction in ('N','S') and abs(closest_point_long - long) > (10 * abs(closest_point_lat - lat));






insert into nmocd_wells (api, well_name, latitude, longitude, spud_date, tvd_depth, elevgl, plug_date, well_id, well_status_id, well_type_id, land_type_id, is_san_juan, geom, from_locations_table) select replace(api,'-',''), well_name || ' ' || well_number, latitude, longitude, spud_date::date, true_vertical_depth::integer, elevation, plugged_on::date, well_id, case when well_status_id = 1 then 1 when well_status_id in (2,5,10) then 6 when well_status_id in (3,6) then 3 when well_status_id = 4 then 2 when well_status_id = 7 then 4 when well_status_id in (8,9) then 5 when well_status_id = 11 then 7 when well_status_id = 12 then 8 else null end, case when well_type_id = 1 then 1 when well_type_id = 2 then 2 when well_type_id = 3 then 3 when well_type_id in (4,6,9,10,11) then 7 when well_type_id = 5 then 4 when well_type_id = 7 then 5 when well_type_id = 8 then 6 else null end, case trim(lease) when 'Federal' then 1 when 'State' then 2 when 'Private' then 3 when 'Indian' then 4 when 'Jicarilla' then 5 when 'Navajo' then 6 when 'Ute' then 7 else null end, is_san_juan, geom, 'true' from nmocd_well_locations where in_geo_table is false;

select count(*) from nmocd_wells where is_san_juan is true and geom is not null and well_status_id is not null and well_status_id = 1 and well_type_id in (1,2);
select count(*) from nmocd_wells where is_san_juan is true and geom is not null and well_status_id is not null and well_status_id in (2,4,5,8,9,10,11,12) and well_type_id in (1,2);
select count(*) from nmocd_wells where is_san_juan is true and geom is not null and well_status_id is not null and well_type_id in (1,2);


alter table nmocd_wells add column water_inj_2012 integer;
alter table nmocd_wells add column water_prod_2012 integer;
alter table nmocd_wells add column days_prod_2012 integer;
alter table nmocd_wells add column gas_prod_2012 integer;
alter table nmocd_wells add column oil_prod_2012 integer;

alter table nmocd_wells_backup drop column well_id;
alter table nmocd_wells_backup add column well_id bigint;
update nmocd_wells_backup set well_id = api::bigint;
create unique index nmocd_wells_backup_well_id_idx on nmocd_wells_backup (well_id);

update nmocd_wells set water_inj_2012 = (select water_inj_2012 from nmocd_wells_backup where well_id = nmocd_wells.well_id);
update nmocd_wells set water_prod_2012 = (select water_prod_2012 from nmocd_wells_backup where well_id = nmocd_wells.well_id);
update nmocd_wells set days_prod_2012 = (select days_prod_2012 from nmocd_wells_backup where well_id = nmocd_wells.well_id);
update nmocd_wells set gas_prod_2012 = (select gas_prod_2012 from nmocd_wells_backup where well_id = nmocd_wells.well_id);
update nmocd_wells set oil_prod_2012 = (select oil_prod_2012 from nmocd_wells_backup where well_id = nmocd_wells.well_id);

alter table nmocd_wells add column api_number varchar(12);
alter table nmocd_wells add column api_state varchar(2);
alter table nmocd_wells add column api_county varchar(3);
alter table nmocd_wells add column api_seq_num varchar(5);

update nmocd_wells set api_number = left(api,2) || '-' || substring(api,3,3) || '-' || right(api,5), api_state = left(api,2), api_county = substring(api,3,3), api_seq_num = right(api,5);

alter table nmocd_wells add column initial_apd_approval_date varchar(30);
alter table nmocd_wells add column last_production varchar(30);
alter table nmocd_wells add column measured_depth varchar(20);
alter table nmocd_wells add column last_inspection varchar(30);
alter table nmocd_wells add column last_mit varchar(30);
alter table nmocd_wells add column district varchar(100);

update nmocd_wells set initial_apd_approval_date = (select initial_apd_approval_date from nmocd_well_locations where well_id = nmocd_wells.well_id);
update nmocd_wells set last_production = (select last_production from nmocd_well_locations where well_id = nmocd_wells.well_id);
update nmocd_wells set measured_depth = (select measured_depth from nmocd_well_locations where well_id = nmocd_wells.well_id);
update nmocd_wells set last_inspection = (select last_inspection from nmocd_well_locations where well_id = nmocd_wells.well_id);
update nmocd_wells set last_mit = (select last_mit from nmocd_well_locations where well_id = nmocd_wells.well_id);
update nmocd_wells set district = (select district from nmocd_well_locations where well_id = nmocd_wells.well_id);
update nmocd_wells set section = (select section::integer from nmocd_well_locations where well_id = nmocd_wells.well_id) where section is null;
update nmocd_wells set township = (select township from nmocd_well_locations where well_id = nmocd_wells.well_id) where township is null;
update nmocd_wells set range = (select range from nmocd_well_locations where well_id = nmocd_wells.well_id) where range is null;
update nmocd_wells set tvd_depth = (select true_vertical_depth::integer from nmocd_well_locations where well_id = nmocd_wells.well_id) where tvd_depth is null;
update nmocd_wells set elevgl = (select elevation::integer from nmocd_well_locations where well_id = nmocd_wells.well_id) where elevgl is null;
update nmocd_wells set operator = (select operator_name from nmocd_well_locations where well_id = nmocd_wells.well_id) where operator is null;
update nmocd_wells set ogrid_cde = (select operator_number from nmocd_well_locations where well_id = nmocd_wells.well_id) where ogrid_cde is null;
update nmocd_wells set spud_date = (select spud_date::date from nmocd_well_locations where well_id = nmocd_wells.well_id) where spud_date is null;
update nmocd_wells set plug_date = (select plugged_on::date from nmocd_well_locations where well_id = nmocd_wells.well_id) where plug_date is null;





COPY (select 
	w.well_id, w.api_number, w.api_state, w.api_county, w.api_seq_num, w.well_name, w.latitude, w.longitude, w.section, w.township, w.range, w.ftg_ew, w.ew_cd, w.ftg_ns, w.ns_cd, w.tvd_depth, w.elevgl, w.county, l.code as land_type_code, l.description as land_type, t.code as well_type_code, t.description as well_type, s.description as well_status, w.operator as operator_name, w.ogrid_cde as operator_number, w.producing_poolid as prod_pool_id, w.one_producing_pool_name as prod_pool_name, w.nbr_compls, w.initial_apd_approval_date, w.spud_date, w.plug_date, w.last_production, w.last_prod_inj, w.last_inspection, w.last_mit, w.water_inj_2012, w.water_inj_2013, w.water_inj_2014, w.water_inj_2015, w.water_prod_2012, w.water_prod_2013, w.water_prod_2014, w.water_prod_2015, w.days_prod_2012, w.days_prod_2013, w.days_prod_2014, w.days_prod_2015, w.gas_prod_2012, w.gas_prod_2013, w.gas_prod_2014, w.gas_prod_2015, w.oil_prod_2012, w.oil_prod_2013, w.oil_prod_2014, w.oil_prod_2015 
from 
	nmocd_wells w 
inner join 
	nmocd_well_types t on t.id = w.well_type_id 
inner join 
	nmocd_well_statuses s on s.id = w.well_status_id 
inner join 
	nmocd_land_types l on l.id = w.land_type_id 
where 
	is_san_juan is true 
order by 	
	well_id) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_wells_all.csv' WITH CSV HEADER;

COPY (select 
	w.well_id, w.api_number, w.api_state, w.api_county, w.api_seq_num, w.well_name, w.latitude, w.longitude, w.section, w.township, w.range, w.ftg_ew, w.ew_cd, w.ftg_ns, w.ns_cd, w.tvd_depth, w.elevgl, w.county, l.code as land_type_code, l.description as land_type, t.code as well_type_code, t.description as well_type, s.description as well_status, w.operator as operator_name, w.ogrid_cde as operator_number, w.producing_poolid as prod_pool_id, w.one_producing_pool_name as prod_pool_name, w.nbr_compls, w.initial_apd_approval_date, w.spud_date, w.plug_date, w.last_production, w.last_prod_inj, w.last_inspection, w.last_mit, w.water_inj_2012, w.water_inj_2013, w.water_inj_2014, w.water_inj_2015, w.water_prod_2012, w.water_prod_2013, w.water_prod_2014, w.water_prod_2015, w.days_prod_2012, w.days_prod_2013, w.days_prod_2014, w.days_prod_2015, w.gas_prod_2012, w.gas_prod_2013, w.gas_prod_2014, w.gas_prod_2015, w.oil_prod_2012, w.oil_prod_2013, w.oil_prod_2014, w.oil_prod_2015 
from 
	nmocd_wells w 
inner join 
	nmocd_well_types t on t.id = w.well_type_id 
inner join 
	nmocd_well_statuses s on s.id = w.well_status_id 
inner join 
	nmocd_land_types l on l.id = w.land_type_id 
where 
	is_san_juan is true 
	and w.well_status_id = 1 -- Active
order by 	
	well_id) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_wells_all_active.csv' WITH CSV HEADER;

COPY (select 
	w.well_id, w.api_number, w.api_state, w.api_county, w.api_seq_num, w.well_name, w.latitude, w.longitude, w.section, w.township, w.range, w.ftg_ew, w.ew_cd, w.ftg_ns, w.ns_cd, w.tvd_depth, w.elevgl, w.county, l.code as land_type_code, l.description as land_type, t.code as well_type_code, t.description as well_type, s.description as well_status, w.operator as operator_name, w.ogrid_cde as operator_number, w.producing_poolid as prod_pool_id, w.one_producing_pool_name as prod_pool_name, w.nbr_compls, w.initial_apd_approval_date, w.spud_date, w.plug_date, w.last_production, w.last_prod_inj, w.last_inspection, w.last_mit, w.water_inj_2012, w.water_inj_2013, w.water_inj_2014, w.water_inj_2015, w.water_prod_2012, w.water_prod_2013, w.water_prod_2014, w.water_prod_2015, w.days_prod_2012, w.days_prod_2013, w.days_prod_2014, w.days_prod_2015, w.gas_prod_2012, w.gas_prod_2013, w.gas_prod_2014, w.gas_prod_2015, w.oil_prod_2012, w.oil_prod_2013, w.oil_prod_2014, w.oil_prod_2015 
from 
	nmocd_wells w 
inner join 
	nmocd_well_types t on t.id = w.well_type_id 
inner join 
	nmocd_well_statuses s on s.id = w.well_status_id 
inner join 
	nmocd_land_types l on l.id = w.land_type_id 
where 
	is_san_juan is true 
	and w.well_status_id <> 1 -- Active
order by 	
	well_id) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_wells_all_non_active.csv' WITH CSV HEADER;

COPY (select 
	w.well_id, w.api_number, w.api_state, w.api_county, w.api_seq_num, w.well_name, w.latitude, w.longitude, w.section, w.township, w.range, w.ftg_ew, w.ew_cd, w.ftg_ns, w.ns_cd, w.tvd_depth, w.elevgl, w.county, l.code as land_type_code, l.description as land_type, t.code as well_type_code, t.description as well_type, s.description as well_status, w.operator as operator_name, w.ogrid_cde as operator_number, w.producing_poolid as prod_pool_id, w.one_producing_pool_name as prod_pool_name, w.nbr_compls, w.initial_apd_approval_date, w.spud_date, w.plug_date, w.last_production, w.last_prod_inj, w.last_inspection, w.last_mit, w.water_inj_2012, w.water_inj_2013, w.water_inj_2014, w.water_inj_2015, w.water_prod_2012, w.water_prod_2013, w.water_prod_2014, w.water_prod_2015, w.days_prod_2012, w.days_prod_2013, w.days_prod_2014, w.days_prod_2015, w.gas_prod_2012, w.gas_prod_2013, w.gas_prod_2014, w.gas_prod_2015, w.oil_prod_2012, w.oil_prod_2013, w.oil_prod_2014, w.oil_prod_2015 
from 
	nmocd_wells w 
inner join 
	nmocd_well_types t on t.id = w.well_type_id 
inner join 
	nmocd_well_statuses s on s.id = w.well_status_id 
inner join 
	nmocd_land_types l on l.id = w.land_type_id 
where 
	is_san_juan is true 
	and w.well_status_id = 1 -- Active
	and w.well_type_id in (1,2) -- Gas, Oil
order by 	
	well_id) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_wells_active_oil_gas.csv' WITH CSV HEADER;

COPY (select 
	w.well_id, w.api_number, w.api_state, w.api_county, w.api_seq_num, w.well_name, w.latitude, w.longitude, w.section, w.township, w.range, w.ftg_ew, w.ew_cd, w.ftg_ns, w.ns_cd, w.tvd_depth, w.elevgl, w.county, l.code as land_type_code, l.description as land_type, t.code as well_type_code, t.description as well_type, s.description as well_status, w.operator as operator_name, w.ogrid_cde as operator_number, w.producing_poolid as prod_pool_id, w.one_producing_pool_name as prod_pool_name, w.nbr_compls, w.initial_apd_approval_date, w.spud_date, w.plug_date, w.last_production, w.last_prod_inj, w.last_inspection, w.last_mit, w.water_inj_2012, w.water_inj_2013, w.water_inj_2014, w.water_inj_2015, w.water_prod_2012, w.water_prod_2013, w.water_prod_2014, w.water_prod_2015, w.days_prod_2012, w.days_prod_2013, w.days_prod_2014, w.days_prod_2015, w.gas_prod_2012, w.gas_prod_2013, w.gas_prod_2014, w.gas_prod_2015, w.oil_prod_2012, w.oil_prod_2013, w.oil_prod_2014, w.oil_prod_2015 
from 
	nmocd_wells w 
inner join 
	nmocd_well_types t on t.id = w.well_type_id 
inner join 
	nmocd_well_statuses s on s.id = w.well_status_id 
inner join 
	nmocd_land_types l on l.id = w.land_type_id 
where 
	is_san_juan is true 
	and w.well_status_id = 1 -- Active
	and w.well_type_id not in (1,2) -- Gas, Oil
order by 	
	well_id) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_wells_active_non_oil_gas.csv' WITH CSV HEADER;

COPY (select 
	w.well_id, w.api_number, w.api_state, w.api_county, w.api_seq_num, w.well_name, w.latitude, w.longitude, w.section, w.township, w.range, w.ftg_ew, w.ew_cd, w.ftg_ns, w.ns_cd, w.tvd_depth, w.elevgl, w.county, l.code as land_type_code, l.description as land_type, t.code as well_type_code, t.description as well_type, s.description as well_status, w.operator as operator_name, w.ogrid_cde as operator_number, w.producing_poolid as prod_pool_id, w.one_producing_pool_name as prod_pool_name, w.nbr_compls, w.initial_apd_approval_date, w.spud_date, w.plug_date, w.last_production, w.last_prod_inj, w.last_inspection, w.last_mit, w.water_inj_2012, w.water_inj_2013, w.water_inj_2014, w.water_inj_2015, w.water_prod_2012, w.water_prod_2013, w.water_prod_2014, w.water_prod_2015, w.days_prod_2012, w.days_prod_2013, w.days_prod_2014, w.days_prod_2015, w.gas_prod_2012, w.gas_prod_2013, w.gas_prod_2014, w.gas_prod_2015, w.oil_prod_2012, w.oil_prod_2013, w.oil_prod_2014, w.oil_prod_2015 
from 
	nmocd_wells w 
inner join 
	nmocd_well_types t on t.id = w.well_type_id 
inner join 
	nmocd_well_statuses s on s.id = w.well_status_id 
inner join 
	nmocd_land_types l on l.id = w.land_type_id 
where 
	is_san_juan is true 
	and w.well_status_id <> 1 -- Active
	and w.well_type_id in (1,2) -- Gas, Oil
order by 	
	well_id) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_wells_non_active_oil_gas.csv' WITH CSV HEADER;

COPY (select 
	w.well_id, w.api_number, w.api_state, w.api_county, w.api_seq_num, w.well_name, w.latitude, w.longitude, w.section, w.township, w.range, w.ftg_ew, w.ew_cd, w.ftg_ns, w.ns_cd, w.tvd_depth, w.elevgl, w.county, l.code as land_type_code, l.description as land_type, t.code as well_type_code, t.description as well_type, s.description as well_status, w.operator as operator_name, w.ogrid_cde as operator_number, w.producing_poolid as prod_pool_id, w.one_producing_pool_name as prod_pool_name, w.nbr_compls, w.initial_apd_approval_date, w.spud_date, w.plug_date, w.last_production, w.last_prod_inj, w.last_inspection, w.last_mit, w.water_inj_2012, w.water_inj_2013, w.water_inj_2014, w.water_inj_2015, w.water_prod_2012, w.water_prod_2013, w.water_prod_2014, w.water_prod_2015, w.days_prod_2012, w.days_prod_2013, w.days_prod_2014, w.days_prod_2015, w.gas_prod_2012, w.gas_prod_2013, w.gas_prod_2014, w.gas_prod_2015, w.oil_prod_2012, w.oil_prod_2013, w.oil_prod_2014, w.oil_prod_2015 
from 
	nmocd_wells w 
inner join 
	nmocd_well_types t on t.id = w.well_type_id 
inner join 
	nmocd_well_statuses s on s.id = w.well_status_id 
inner join 
	nmocd_land_types l on l.id = w.land_type_id 
where 
	is_san_juan is true 
	and w.well_status_id <> 1 -- Active
	and w.well_type_id not in (1,2) -- Gas, Oil
order by 	
	well_id) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_wells_non_active_non_oil_gas.csv' WITH CSV HEADER;



create table new_mexico_well_enhanced_road_distances (
	id serial primary key not null, 
	well_id bigint, 
	well_api varchar(10), 
	well_status_id integer, 
	well_type_id integer, 
	land_type_id integer, 
	county_name varchar(50), 
	county_fips varchar(3), 
	lat double precision, 
	long double precision, 
	well_geom geometry(POINT,26913), 
	road_gid integer, 
	road_fullname varchar(100), 
	road_streetname varchar(100), 
	road_direction varchar(2), 
	road_geom geometry(LineString,26913), 
	closest_point_lat double precision, 
	closest_point_long double precision, 
	closest_point_geom geometry(POINT,26913),
	distance real, 
	closest_direction varchar(2), 
	wind_direction varchar(2), 
	wind_dir_suspect boolean not null default false
);

update new_mexico_roads set direction = 
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

update nm_san_juan_roads set direction = 
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

update nm_sandoval_roads set direction = 
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

update nm_rio_arriba_roads set direction = 
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

update nm_mckinley_roads set direction = 
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

insert into new_mexico_well_enhanced_road_distances (well_id, well_api, well_status_id, well_type_id, land_type_id, county_name, county_fips, lat, long, well_geom, road_gid, road_fullname, road_direction, road_geom, closest_point_geom) 
select 
	w.well_id, 
	w.api, 
	w.well_status_id, 
	w.well_type_id, 
	w.land_type_id, 
	w.county, 
	w.county_fips, 
	w.latitude, 
	w.longitude, 
	w.geom_utm13, 
	r.gid, 
	r.fename,
	r.direction, 
	r.geom_line, 
	ST_ClosestPoint(r.geom_line,w.geom_utm13)
from 
	nmocd_wells w 
cross join 
	nm_san_juan_roads r 
where 
	w.is_san_juan is true 
	and w.well_status_id = 1 -- Active
	and w.well_type_id in (1,2) -- Gas, Oil
	and ST_Distance(w.geom_utm13, ST_ClosestPoint(r.geom_line,w.geom_utm13)) < 101;

insert into new_mexico_well_enhanced_road_distances (well_id, well_api, well_status_id, well_type_id, land_type_id, county_name, county_fips, lat, long, well_geom, road_gid, road_fullname, road_direction, road_geom, closest_point_geom) 
select 
	w.well_id, 
	w.api, 
	w.well_status_id, 
	w.well_type_id, 
	w.land_type_id, 
	w.county, 
	w.county_fips, 
	w.latitude, 
	w.longitude, 
	w.geom_utm13, 
	r.gid, 
	r.fename,
	r.direction, 
	r.geom_line, 
	ST_ClosestPoint(r.geom_line,w.geom_utm13)
from 
	nmocd_wells w 
cross join 
	nm_rio_arriba_roads r 
where 
	w.is_san_juan is true 
	and w.well_status_id = 1 -- Active
	and w.well_type_id in (1,2) -- Gas, Oil
	and ST_Distance(w.geom_utm13, ST_ClosestPoint(r.geom_line,w.geom_utm13)) < 101;

insert into new_mexico_well_enhanced_road_distances (well_id, well_api, well_status_id, well_type_id, land_type_id, county_name, county_fips, lat, long, well_geom, road_gid, road_fullname, road_direction, road_geom, closest_point_geom) 
select 
	w.well_id, 
	w.api, 
	w.well_status_id, 
	w.well_type_id, 
	w.land_type_id, 
	w.county, 
	w.county_fips, 
	w.latitude, 
	w.longitude, 
	w.geom_utm13, 
	r.gid, 
	r.fename,
	r.direction, 
	r.geom_line, 
	ST_ClosestPoint(r.geom_line,w.geom_utm13)
from 
	nmocd_wells w 
cross join 
	nm_sandoval_roads r 
where 
	w.is_san_juan is true 
	and w.well_status_id = 1 -- Active
	and w.well_type_id in (1,2) -- Gas, Oil
	and ST_Distance(w.geom_utm13, ST_ClosestPoint(r.geom_line,w.geom_utm13)) < 101;

insert into new_mexico_well_enhanced_road_distances (well_id, well_api, well_status_id, well_type_id, land_type_id, county_name, county_fips, lat, long, well_geom, road_gid, road_fullname, road_direction, road_geom, closest_point_geom) 
select 
	w.well_id, 
	w.api, 
	w.well_status_id, 
	w.well_type_id, 
	w.land_type_id, 
	w.county, 
	w.county_fips, 
	w.latitude, 
	w.longitude, 
	w.geom_utm13, 
	r.gid, 
	r.fename,
	r.direction, 
	r.geom_line, 
	ST_ClosestPoint(r.geom_line,w.geom_utm13)
from 
	nmocd_wells w 
cross join 
	nm_mckinley_roads r 
where 
	w.is_san_juan is true 
	and w.well_status_id = 1 -- Active
	and w.well_type_id in (1,2) -- Gas, Oil
	and ST_Distance(w.geom_utm13, ST_ClosestPoint(r.geom_line,w.geom_utm13)) < 101;

insert into new_mexico_well_enhanced_road_distances (well_id, well_api, well_status_id, well_type_id, land_type_id, county_name, county_fips, lat, long, well_geom, road_gid, road_fullname, road_direction, road_geom, closest_point_geom) 
select 
	w.well_id, 
	w.api, 
	w.well_status_id, 
	w.well_type_id, 
	w.land_type_id, 
	w.county, 
	w.county_fips, 
	w.latitude, 
	w.longitude, 
	w.geom_utm13, 
	r.gid, 
	r.route,
	r.direction, 
	r.geom_line, 
	ST_ClosestPoint(r.geom_line,w.geom_utm13) 
from 
	nmocd_wells w 
cross join 
	new_mexico_roads r 
where 
	w.is_san_juan is true 
	and w.well_status_id = 1 -- Active
	and w.well_type_id in (1,2) -- Gas, Oil
	and ST_Distance(w.geom_utm13, ST_ClosestPoint(r.geom_line,w.geom_utm13)) < 101;

update new_mexico_well_enhanced_road_distances 
set closest_point_lat = ST_Y(ST_Transform(ST_SetSRID(closest_point_geom, 26913), 4269)), closest_point_long = ST_X(ST_Transform(ST_SetSRID(closest_point_geom, 26913), 4269)), distance = ST_Distance(well_geom, closest_point_geom)
where distance is null;


update new_mexico_well_enhanced_road_distances 
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

update new_mexico_well_enhanced_road_distances set wind_direction = 'N' where closest_direction = 'S';
update new_mexico_well_enhanced_road_distances set wind_direction = 'S' where closest_direction = 'N';
update new_mexico_well_enhanced_road_distances set wind_direction = 'E' where closest_direction = 'W';
update new_mexico_well_enhanced_road_distances set wind_direction = 'W' where closest_direction = 'E';
update new_mexico_well_enhanced_road_distances set wind_direction = 'NE' where closest_direction = 'SW';
update new_mexico_well_enhanced_road_distances set wind_direction = 'SW' where closest_direction = 'NE';
update new_mexico_well_enhanced_road_distances set wind_direction = 'NW' where closest_direction = 'SE';
update new_mexico_well_enhanced_road_distances set wind_direction = 'SE' where closest_direction = 'NW';

update new_mexico_well_enhanced_road_distances set wind_dir_suspect = 'true' where road_direction in ('N','S') and closest_direction in ('E','W') and abs(closest_point_lat - lat) > (5 * abs(closest_point_long - long));
update new_mexico_well_enhanced_road_distances set wind_dir_suspect = 'true' where road_direction in ('E','W') and closest_direction in ('N','S') and abs(closest_point_long - long) > (5 * abs(closest_point_lat - lat));


update new_mexico_well_enhanced_road_distances set wind_dir_suspect = 'true' where road_direction in ('NE','SW') and closest_direction = 'SE' and (ST_Azimuth(closest_point_geom,well_geom)*180/pi()) not between 90 and 180;
update new_mexico_well_enhanced_road_distances set wind_dir_suspect = 'true' where road_direction in ('NE','SW') and closest_direction = 'NW' and (ST_Azimuth(closest_point_geom,well_geom)*180/pi()) not between 270 and 360;
update new_mexico_well_enhanced_road_distances set wind_dir_suspect = 'true' where road_direction in ('NW','SE') and closest_direction = 'SW' and (ST_Azimuth(closest_point_geom,well_geom)*180/pi()) not between 180 and 270;
update new_mexico_well_enhanced_road_distances set wind_dir_suspect = 'true' where road_direction in ('NW','SE') and closest_direction = 'NE' and (ST_Azimuth(closest_point_geom,well_geom)*180/pi()) not between 0 and 90;


--------------------------- WELL SCOUT CARD HTML -------------------------------

create table nmocd_well_details (
	id serial not null primary key, 
	nmocd_well_id integer, 
	api_number varchar(12), 
	api_county varchar(3), 
	api_seq_num varchar(5), 
	is_san_juan boolean, 
	html_heading varchar(1000), 
	html_data_details text, 
	in_use boolean not null default false, 
	html_status varchar(30), 
	html_saved boolean not null default false,	
	date_saved timestamp
);

insert into nmocd_well_details (nmocd_well_id, api_number, api_county, api_seq_num, is_san_juan) 
select id, api_number, api_county, api_seq_num, is_san_juan from nmocd_wells order by id;


-- well formation tops
create table nmocd_well_formation_tops (
	id serial not null primary key, 
	nmocd_well_id integer, 
	formation_name varchar(100), 
	top_depth varchar(10)
);

create table nmocd_well_casings (
	id serial not null primary key, 
	nmocd_well_id integer, 
	string_hole_type varchar(100), 
	taper varchar(10), 
	date_set varchar(10), 
	diameter varchar(10), 
	top varchar(10), 
	bottom varchar(10), 
	grade varchar(20),
	length varchar(10), 
	weight varchar(10),
	cement_bottom varchar(10), 
	cement_top varchar(10),
	cement_method varchar(10), 
	cement_class varchar(50), 
	cement_sacks varchar(10), 
	presure_test varchar(3)
);

create table nmocd_well_productions (
	id serial not null primary key, 
	nmocd_well_id integer,
	record_year varchar(30), 
	record_month varchar(3), 
	formation_name varchar(100), 
	prod_oil_bbls varchar(10), 
	prod_gas_mcf varchar(10), 
	prod_water_bbls varchar(10), 
	days_prod_inj varchar(10), 
	inj_water_bbls varchar(10), 
  inj_co2_mcf varchar(10), 
  inj_gas_mcf varchar(10), 
  inj_other varchar(10), 
	inj_pressure varchar(10)
);


create table nmocd_formations (
	code integer, 
	name varchar(35)
);
insert into nmocd_formations select distinct producing_poolid, one_producing_pool_name from nmocd_wells order by one_producing_pool_name; 
alter table nmocd_formations add column id serial not null primary key;

alter table nmocd_well_productions add column formation_id integer;
update nmocd_well_productions set formation_id = (select id from nmocd_formations where name = nmocd_well_productions.formation_name);


create table nmocd_pools (
	pool_id integer, 
	pool_name varchar(100), 
	std_oil_spacing smallint, 
	std_gas_spacing smallint, 
	depth_allowable integer, 
	region_of_state varchar(1), 
	pool_type varchar(10)
);
copy nmocd_pools from from '/Users/troyburke/Data/new_mexico/new_mexico_pools.csv' (format csv, delimiter ',', null '');
alter table nmocd_pools add column id serial not null primary key;



COPY (select w.well_id, w.api_number, w.longitude, w.latitude, w.api_county, l.code as land_type_code, t.code as well_type_code, w.well_status_id, p.record_year as prod_year, p.prod_month, f.code as formation_id, p.formation_name, p.prod_oil_bbls, p.prod_gas_mcf, p.prod_water_bbls, p.days_prod_inj as prod_days 
from nmocd_wells w 
inner join nmocd_well_productions p on w.id = p.nmocd_well_id 
inner join nmocd_well_types t on t.id = w.well_type_id 
inner join nmocd_well_statuses s on s.id = w.well_status_id 
inner join nmocd_land_types l on l.id = w.land_type_id 
left outer join nmocd_formations f on f.id = p.formation_id 
where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999
order by w.well_id, p.record_year desc, p.record_month, p.formation_name) TO '/Users/troyburke/Projects/ruby/nmocd/new_mexico_san_juan_production.csv' WITH CSV HEADER;

File Description
-----------------

column | name | datatype | description
---------------------------------------
1 | well_id | integer | unique well identifer (integer representaion of api number)
2 | api_number | varchar(12) | 30-xxx-xxxxx (api_state-api_county-api_sequence)
3 | longitude | double precision | well x location
4 | latitude | double precision | well y location
5 | api_county | varchar(3) | 031=McKinley, 039=Rio Arriba, 043=Sandoval, 045=San Juan 
6 | land_type_code | varchar(1) | F=Federal, S=State, P=Private, I=Indian, J=Jicarilla, N=Navajo, U=Ute
7 | well_type_code | varchar(1) | G=Gas, O=Oil
8 | well_status_id | integer | 1=Active, 3=Never Drilled, 4=New (Not drilled or compl), 5=Plugged, 6=TA, 7=Zone Plugged, 8=Zones Aban, not plgd
9 | prod_year | smallint | reporting year (2000 to 2015)
10 | prod_month | smallint | report month (1 to 12)
11 | formation_id | integer | unique formation indentifer (76,290 null values)
12 | formation_name | varchar(35) | producing formation name
13 | prod_oil_bbls | integer | oil produced (barrels)
14 | prod_gas_mcf | integer | gas produced (mcf)
15 | prod_water_bbls | integer | produced water amount (barrels)
16 | prod_days | smallint | number of days in reporting period (prod_year/prod_month)

Constraints
------------
Time period:
Jan-2000 to present (data scraped in early April 2015)

Well types:
Gas and Oil

Location:
San Juan Basin counties (031=McKinley, 039=Rio Arriba, 043=Sandoval, 045=San Juan)

Quick File Stats
-----------------
File Size:
528.2 MB (unzipped)

Total Records:
4,611,332

By Well Type:
4,250,719 Gas
360,613 Oil

By County:
2,573,888 San Juan
1,936,340 Rio Arriba
63,388 Sandoval
37,716 McKinley

By Land Type:
3,229,587 (F)ederal
474,895 (J)icarilla
434,414 (P)rivate
333,119 (S)tate
101,595 (N)avajo
29,366 (U)te
8,356 (I)ndian

By Well Status [id]:
4,249,495 Active [1]
273,642 Plugged [5]
81,972 New (Not drilled or compl) [5]
5,406 TA [6]
501 Zone Plugged [7]
272 Zones Aban, not plgd [8]
44 Never Drilled [3]

By Year:
29,222 - 2015
339,518 - 2014
340,306 - 2013
341,169 - 2012
340,036 - 2011
337,931 - 2010
334,042 - 2009
326,432 - 2008
317,034 - 2007
305,080 - 2006
291,849 - 2005
281,052 - 2004
269,890 - 2003
259,261 - 2002
253,063 - 2001
245,447 - 2000

Top Ten Producing Formations [id]:
1,275,136 BLANCO-MESAVERDE (PRORATED GAS) [192]
989,604 BASIN DAKOTA (PRORATED GAS) [121]
776,501 BASIN FRUITLAND COAL (GAS) [122]
262,243 BLANCO P. C. SOUTH (PRORATED GAS) [187]
132,028 BLANCO PICTURED CLIFFS (GAS) [188]
125,413 OTERO CHACRA (GAS) [1270]
109,010 BALLARD PICTURED CLIFFS (GAS) [111]
85,144 LINDRITH GALLUP-DAKOTA,WEST [1011]
83,066 AZTEC PICTURED CLIFFS (GAS) [95]
59,574 FULCHER KUTZ PICTURED CLIFFS (GAS) [676]


select count(w.*) as well_count,  well_status_id from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by well_status_id order by well_count desc;

 well_count | well_status_id
------------+----------------
    4249495 |              1 Active
     273642 |              5 Plugged
      81972 |              4 New (Not drilled or compl)
       5406 |              6 TA
        501 |              7 Zone Plugged
        272 |              8 Zones Aban, not plgd
         44 |              3 Never Drilled


select count(w.*) as well_count,  well_type_id from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by well_type_id order by well_count desc;

well_count | well_type_id
------------+--------------
    4250719 |            1 Gas
     360613 |            2 Oil


select count(w.*) as well_count, land_type_id from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by land_type_id order by well_count desc;

 well_count | land_type_id
------------+--------------
    3229587 |            1 Federal
     474895 |            5 Jicarilla
     434414 |            3 Private
     333119 |            2 State
     101595 |            6 Navajo
      29366 |            7 Ute
       8356 |            4 Indian


select count(w.*) as well_count, api_county, county from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by api_county, county order by well_count desc;

 well_count | api_county |   county
------------+------------+------------
    2573888 | 045        | San Juan
    1936340 | 039        | Rio Arriba
      63388 | 043        | Sandoval
      37716 | 031        | McKinley

select count(p.*) as num_records, p.record_year from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by p.record_year order by num_records desc;

 num_records | record_year
-------------+-------------
       29222 |        2015
      339518 |        2014
      340306 |        2013
      341169 |        2012
      340036 |        2011
      337931 |        2010
      334042 |        2009
      326432 |        2008
      317034 |        2007
      305080 |        2006
      291849 |        2005
      281052 |        2004
      269890 |        2003
      259261 |        2002
      253063 |        2001
      245447 |        2000

select count(p.*) as num_records, p.formation_id, p.formation_name from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by p.formation_id, p.formation_name order by num_records desc limit 10;

 num_records | formation_id |           formation_name
-------------+--------------+------------------------------------
     1275136 |          192 | BLANCO-MESAVERDE (PRORATED GAS)
      989604 |          121 | BASIN DAKOTA (PRORATED GAS)
      776501 |          122 | BASIN FRUITLAND COAL (GAS)
      262243 |          187 | BLANCO P. C. SOUTH (PRORATED GAS)
      132028 |          188 | BLANCO PICTURED CLIFFS (GAS)
      125413 |         1270 | OTERO CHACRA (GAS)
      109010 |          111 | BALLARD PICTURED CLIFFS (GAS)
       85144 |         1011 | LINDRITH GALLUP-DAKOTA,WEST
       83066 |           95 | AZTEC PICTURED CLIFFS (GAS)
       59574 |          676 | FULCHER KUTZ PICTURED CLIFFS (GAS)



SELECT count(*) FROM nmocd_well_details WHERE is_san_juan IS TRUE AND html_data_details IS NOT NULL
			<span id="ctl00_ctl00__main_main_ucProduction_lblLastProduction">2/2015</span>
			<span id="ctl00_ctl00__main_main_ucProduction_lblLastProduction"></span>


246 in details not in productions

185 in productions not in details

61 diff

26824

26885

30-045-21573
30-045-21571
30-039-26306


-- production totals by year (2000 to present)
COPY (select p.record_year, sum(p.prod_oil_bbls) as prod_oil_bbls, sum(p.prod_gas_mcf) as prod_gas_mcf, sum(p.prod_water_bbls) as prod_water_bbls from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by p.record_year order by p.record_year desc) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_prod_by_year.csv' WITH CSV HEADER;

-- production totals by year/month (2000 to present)
COPY (select p.record_year, p.record_month, p.prod_month, sum(p.prod_oil_bbls) as prod_oil_bbls, sum(p.prod_gas_mcf) as prod_gas_mcf, sum(p.prod_water_bbls) as prod_water_bbls from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by p.record_year, p.record_month, p.prod_month order by p.record_year desc, p.prod_month) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_prod_by_month.csv' WITH CSV HEADER;

-- production totals by county (2000 to present)
COPY (select w.api_county, w.county, sum(p.prod_oil_bbls) as prod_oil_bbls, sum(p.prod_gas_mcf) as prod_gas_mcf, sum(p.prod_water_bbls) as prod_water_bbls from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by api_county, county order by w.api_county) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_prod_by_county.csv' WITH CSV HEADER;

-- production totals by county/year (2000 to present)
COPY (select w.api_county, w.county, p.record_year, sum(p.prod_oil_bbls) as prod_oil_bbls, sum(p.prod_gas_mcf) as prod_gas_mcf, sum(p.prod_water_bbls) as prod_water_bbls from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by w.api_county, w.county, p.record_year order by w.api_county, p.record_year desc) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_prod_by_county_year.csv' WITH CSV HEADER;

-- production totals by county/year/month (2000 to present)
COPY (select w.api_county, w.county, p.record_year, p.record_month, p.prod_month, sum(p.prod_oil_bbls) as prod_oil_bbls, sum(p.prod_gas_mcf) as prod_gas_mcf, sum(p.prod_water_bbls) as prod_water_bbls from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by w.api_county, w.county, p.record_year, p.record_month, p.prod_month order by w.api_county, p.record_year desc, p.prod_month) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_prod_by_county_month.csv' WITH CSV HEADER;

-- production totals by land type (2000 to present)
COPY (select w.land_type_id, l.code as land_type_code, l.description as land_type_desc, sum(p.prod_oil_bbls) as prod_oil_bbls, sum(p.prod_gas_mcf) as prod_gas_mcf, sum(p.prod_water_bbls) as prod_water_bbls from nmocd_wells w inner join nmocd_land_types l on l.id = w.land_type_id inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by w.land_type_id, l.code, l.description order by w.land_type_id) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_prod_by_land_type.csv' WITH CSV HEADER;

-- production totals by land type/year (2000 to present)
COPY (select w.land_type_id, l.code as land_type_code, l.description as land_type_desc, p.record_year, sum(p.prod_oil_bbls) as prod_oil_bbls, sum(p.prod_gas_mcf) as prod_gas_mcf, sum(p.prod_water_bbls) as prod_water_bbls from nmocd_wells w inner join nmocd_land_types l on l.id = w.land_type_id inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by w.land_type_id, l.code, l.description, p.record_year order by w.land_type_id, p.record_year desc) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_prod_by_land_type_year.csv' WITH CSV HEADER;

-- production totals by land type/year/month (2000 to present)
COPY (select w.land_type_id, l.code as land_type_code, l.description as land_type_desc, p.record_year, p.record_month, p.prod_month, sum(p.prod_oil_bbls) as prod_oil_bbls, sum(p.prod_gas_mcf) as prod_gas_mcf, sum(p.prod_water_bbls) as prod_water_bbls from nmocd_wells w inner join nmocd_land_types l on l.id = w.land_type_id inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by w.land_type_id, l.code, l.description, p.record_year, p.record_month, p.prod_month order by w.land_type_id, p.record_year desc, p.prod_month) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_prod_by_land_type_month.csv' WITH CSV HEADER;

-- production totals by formation (2000 to present)
COPY (select p.formation_name, p.formation_id, sum(p.prod_oil_bbls) as prod_oil_bbls, sum(p.prod_gas_mcf) as prod_gas_mcf, sum(p.prod_water_bbls) as prod_water_bbls from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by p.formation_id, p.formation_name order by p.formation_name) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_prod_by_formation.csv' WITH CSV HEADER;

-- production totals by formation/year (2000 to present)
COPY (select p.formation_name, p.formation_id, p.record_year, sum(p.prod_oil_bbls) as prod_oil_bbls, sum(p.prod_gas_mcf) as prod_gas_mcf, sum(p.prod_water_bbls) as prod_water_bbls from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by p.formation_id, p.formation_name, p.record_year order by p.formation_name, p.record_year desc) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_prod_by_formation_year.csv' WITH CSV HEADER;

-- production totals by formation/year/month (2000 to present)
COPY (select p.formation_name, p.formation_id, p.record_year, p.record_month, p.prod_month, sum(p.prod_oil_bbls) as prod_oil_bbls, sum(p.prod_gas_mcf) as prod_gas_mcf, sum(p.prod_water_bbls) as prod_water_bbls from nmocd_wells w inner join nmocd_well_productions p on w.id = p.nmocd_well_id where w.is_san_juan is true and w.well_type_id in (1,2) and p.record_year > 1999 group by p.formation_id, p.formation_name, p.record_year, p.record_month, p.prod_month order by p.formation_name, p.record_year desc, p.prod_month) TO '/Users/troyburke/Projects/ruby/nmocd/nm_san_juan_prod_by_formation_month.csv' WITH CSV HEADER;
























