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


-- pgshape import road shapefile

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

alter table new_mexico_roads add column geom_line geometry(LineString,4326);
update new_mexico_roads set geom_line = ST_MakeLine();

alter table new_mexico_roads add column azimuth double precision;
update new_mexico_roads set azimuth = ST_Azimuth(ST_StartPoint(ST_GeometryN(geom,1)),ST_EndPoint(ST_GeometryN(geom,1)));

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





