create table txrrc_districts (
	id serial primary key not null, 
	code varchar(2)
);

insert into txrrc_districts (id, code) values (1, '01');
insert into txrrc_districts (id, code) values (2, '02');
insert into txrrc_districts (id, code) values (3, '03');
insert into txrrc_districts (id, code) values (4, '04');
insert into txrrc_districts (id, code) values (5, '05');
insert into txrrc_districts (id, code) values (6, '06');
insert into txrrc_districts (id, code) values (7, '6E');
insert into txrrc_districts (id, code) values (8, '7B');
insert into txrrc_districts (id, code) values (9, '7C');
insert into txrrc_districts (id, code) values (10, '08');
insert into txrrc_districts (id, code) values (11, '8A');
insert into txrrc_districts (id, code) values (12, '09');
insert into txrrc_districts (id, code) values (13, '10');


create table txrrc_well_types (
	id serial primary key not null, 
	code varchar(2),
	description varchar(30)
);

insert into txrrc_well_types (id, code, description) values (1, 'AB', 'ABANDONED');
insert into txrrc_well_types (id, code, description) values (2, 'BM', 'BRINE MINING');
insert into txrrc_well_types (id, code, description) values (3, 'DW', 'DOMESTIC USE WELL');
insert into txrrc_well_types (id, code, description) values (4, 'GJ', 'GAS STRG-INJECTION');
insert into txrrc_well_types (id, code, description) values (5, 'GL', 'GAS STRG-SALT FORMATION');
insert into txrrc_well_types (id, code, description) values (6, 'GT', 'GEOTHERMAL WELL');
insert into txrrc_well_types (id, code, description) values (7, 'GW', 'GAS STRG-WITHDRAWAL');
insert into txrrc_well_types (id, code, description) values (8, 'HI', 'HISTORY');
insert into txrrc_well_types (id, code, description) values (9, 'IN', 'INJECTION');
insert into txrrc_well_types (id, code, description) values (10, 'LP', 'LPG STORAGE');
insert into txrrc_well_types (id, code, description) values (11, 'LU', 'LEASE-USE-WELL');
insert into txrrc_well_types (id, code, description) values (12, 'NP', 'NO PRODUCTION');
insert into txrrc_well_types (id, code, description) values (13, 'OB', 'OBSERVATION');
insert into txrrc_well_types (id, code, description) values (14, 'OS', 'OTHER TYPE SERVICE');
insert into txrrc_well_types (id, code, description) values (15, 'PF', 'PROD FACTOR WELL');
insert into txrrc_well_types (id, code, description) values (16, 'PP', 'PARTIAL PLUG');
insert into txrrc_well_types (id, code, description) values (17, 'PR', 'PRODUCING');
insert into txrrc_well_types (id, code, description) values (18, 'RT', 'SWR-10-WELL');
insert into txrrc_well_types (id, code, description) values (19, 'SD', 'SEALED');
insert into txrrc_well_types (id, code, description) values (20, 'SH', 'SHUT IN');
insert into txrrc_well_types (id, code, description) values (21, 'SM', 'SHUT IN-MULTI-COMPL');
insert into txrrc_well_types (id, code, description) values (22, 'TA', 'TEMP ABANDONED');
insert into txrrc_well_types (id, code, description) values (23, 'TR', 'TRAINING');
insert into txrrc_well_types (id, code, description) values (24, 'WS', 'WATER SUPPLY');
insert into txrrc_well_types (id, code, description) values (25, 'ZZ', 'NOT ELIGIBLE FOR ALLOWABLE');


create table txrrc_counties (
	id serial primary key not null, 
	code varchar(3),
	name varchar(50)
);

insert into txrrc_counties (code, name)
select cnty_fips, name from counties where state_name ilike 'Texas' order by name;

insert into txrrc_counties (id, code, name) values (255, '600', 'S PADRE IS-SB');
insert into txrrc_counties (id, code, name) values (256, '601', 'N PADRE IS-SB');
insert into txrrc_counties (id, code, name) values (257, '602', 'MUSTANG IS-SB');
insert into txrrc_counties (id, code, name) values (258, '603', 'MATGRDA IS-SB');
insert into txrrc_counties (id, code, name) values (259, '604', 'BRAZOS-SB');
insert into txrrc_counties (id, code, name) values (260, '605', 'GALVESTON-SB');
insert into txrrc_counties (id, code, name) values (261, '606', 'HIGH IS-SB');
insert into txrrc_counties (id, code, name) values (262, '700', 'S PADRE IS-LB');
insert into txrrc_counties (id, code, name) values (263, '701', 'N PADRE IS-LB');
insert into txrrc_counties (id, code, name) values (264, '702', 'MUSTANG IS-LB');
insert into txrrc_counties (id, code, name) values (265, '703', 'MATGRDA IS-LB');
insert into txrrc_counties (id, code, name) values (266, '704', 'BRAZOS-LB');
insert into txrrc_counties (id, code, name) values (267, '705', 'BRAZOS-S');
insert into txrrc_counties (id, code, name) values (268, '706', 'GALVESTON-LB');
insert into txrrc_counties (id, code, name) values (269, '707', 'GALVESTON-S');
insert into txrrc_counties (id, code, name) values (270, '708', 'HIGH IS-LB');
insert into txrrc_counties (id, code, name) values (271, '709', 'HIGH IS-S');
insert into txrrc_counties (id, code, name) values (272, '710', 'HIGH IS-E');
insert into txrrc_counties (id, code, name) values (273, '711', '&quot;HIGH IS-E,S&quot;');
insert into txrrc_counties (id, code, name) values (274, '712', 'MUSTANG IS-E');
insert into txrrc_counties (id, code, name) values (275, '713', 'N PADRE IS-E');
insert into txrrc_counties (id, code, name) values (276, '714', 'S PADRE IS-E');
insert into txrrc_counties (id, code, name) values (277, '715', 'SABINE PASS');


create table txrrc_api_searches (
	id serial primary key not null, 
	well_type_code varchar(2), 
	county_code varchar(3), 
	in_use boolean not null default false, 
	search_completed boolean not null default false, 
	search_comments varchar(100)
);

insert into txrrc_api_searches (well_type_code, county_code)
select wt.code, c.code from txrrc_well_types wt cross join txrrc_counties c;


create table txrrc_wells (
	id serial primary key not null, 
	well_type_code varchar(2),
	county_fips_code varchar(3),
	api_number varchar(14),
	district varchar(2),
	lease_number varchar(20),
	lease_name varchar(250), 
	well_number varchar(20), 
	field_name varchar(100),
	operator_name varchar(250),
	county_name varchar(50),
	on_schedule varchar(10),
	api_depth varchar(10)
);



update txrrc_api_searches set search_completed = 't' where well_type_code not in ('IN','PR','SH','TA');

create table txrrc_shale_counties (
	id serial primary key not null, 
	shale_play varchar(30),
	county_name varchar(20),
	is_core_county boolean
);

insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Atascosa', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Bastrop', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Bee', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Brazos', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Burleson', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'De Witt', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Dimmitt', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Fayette', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Frio', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Gonzales', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Grimes', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Karnes', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'La Salle', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Lavaca', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Lee', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Leon', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Live Oak', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Madison', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Maverick', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Mcmullen', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Milam', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Robertson', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Walker', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Webb', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Wilson', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Eagle Ford', 'Zavala', 't');

insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Denton', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Johnson', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Tarrant', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Wise', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Archer', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Bosque', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Clay', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Comanche', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Cooke', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Coryell', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Dallas', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Eastland', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Ellis', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Erath', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Hamilton', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Hill', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Hood', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Jack', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Montague', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Palo Pinto', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Parker', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Shakleford', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Somervell', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Stephens', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Barnett', 'Young', 'f');


insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Haynesville/Bossier', 'Harrison', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Haynesville/Bossier', 'Panola', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Haynesville/Bossier', 'Shelby', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Haynesville/Bossier', 'San Augustine', 't');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Haynesville/Bossier', 'Angelina', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Haynesville/Bossier', 'Gregg', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Haynesville/Bossier', 'Marion', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Haynesville/Bossier', 'Nacogdoches', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Haynesville/Bossier', 'Rusk', 'f');
insert into txrrc_shale_counties (shale_play, county_name, is_core_county) values ('Haynesville/Bossier', 'Sabine', 'f');

alter table txrrc_shale_counties add column county_fips_code varchar(3);

update txrrc_shale_counties set county_fips_code = (select c.code from txrrc_counties c where trim(lower(c.name)) = trim(lower(txrrc_shale_counties.county_name)));


alter table txrrc_wells add column well_type_id integer;
update txrrc_wells set well_type_id = (select wt.id from txrrc_well_types wt where wt.code = txrrc_wells.well_type_code);


create table txrrc_scrape_statuses (
	id serial primary key not null,
	well_id integer,
	well_type_id integer,
	well_api_number varchar(12),
	api_number varchar(14),
	api_state varchar(2),
	api_county varchar(3),
	api_sequence varchar(5),
	frac_focus_status varchar(50),
	is_core_county boolean not null default false
);

insert into txrrc_scrape_statuses (well_id, well_type_id, well_api_number, api_number, api_state, api_county, api_sequence, frac_focus_status)
select id, well_type_id, '42-' || left(api_number,3) || '-' || right(api_number,5), api_number, '42', left(api_number,3), right(api_number,5), 'not scraped'
from txrrc_wells
where county_fips_code in (select county_fips_code from txrrc_shale_counties);

update txrrc_scrape_statuses set is_core_county = 't' where api_county in (select county_fips_code from txrrc_shale_counties where is_core_county is true);



insert into txrrc_scrape_statuses (well_id, well_type_id, well_api_number, api_number, api_state, api_county, api_sequence, frac_focus_status)
select id, well_type_id, '42-' || left(api_number,3) || '-' || right(api_number,5), api_number, '42', left(api_number,3), right(api_number,5), 'not scraped'
from txrrc_wells
where well_type_id in (17,20,21,22) and in_scrape_table is false;



create table txrrc_fields (
	code integer, 
	name varchar(100)
);

copy txrrc_fields from '/Users/troyburke/Projects/ruby/txrrc/fields.csv' (format csv, delimiter ',', null '');

alter table txrrc_fields add id serial not null primary key;


drop table txrrc_coordinate_scrapes;
create table txrrc_coordinate_scrapes (
	id serial not null primary key, 
	api_number varchar(14), 
	scraped boolean not null default false
);
insert into txrrc_coordinate_scrapes (api_number) select api_number from txrrc_wells order by api_number;
--424028

drop table txrrc_well_coordinates;
create table txrrc_well_coordinates (
	id serial not null primary key, 
	unique_id integer, 
	api_number varchar(8), 
	gis_symbol_num smallint, 
	gis_symbol_desc varchar(50), 
	obj_id integer, 
	longitude double precision, 
	latitude double precision 
);


http://wwwgisp.rrc.state.tx.us/arcgis/rest/services/rrc_public/RRC_GIS_Viewer/MapServer/0/query?where=API%3D%2700310744%27&outFields=*&f=pjson


{
 "displayFieldName": "API",
 "fieldAliases": {
  "API": "API"
 },
 "geometryType": "esriGeometryPoint",
 "spatialReference": {
  "wkid": 4269,
  "latestWkid": 4269
 },
 "fields": [
  {
   "name": "API",
   "type": "esriFieldTypeString",
   "alias": "API",
   "length": 8
  }
 ],
 "features": [
  {
   "attributes": {
    "API": "07901027"
   },
   "geometry": {
    "x": -102.96218106444853,
    "y": 33.497196963824514
   }
  }
 ]
}



http://wwwgisp.rrc.state.tx.us/arcgis/rest/services/rrc_public/RRC_GIS_Viewer/MapServer/1/query?f=json&where=API%20%3D%20%2700932157%27&returnGeometry=true&spatialRel=esriSpatialRelIntersects&outFields=*&outSR=102100

{
"displayFieldName":"API",
"fieldAliases":{
	"UNIQID":"UNIQID",
	"API":"API",
	"GIS_API5":"GIS_API5",
	"GIS_WELL_NUMBER":"GIS_WELL_NUMBER",
	"SYMNUM":"SYMNUM",
	"GIS_SYMBOL_DESCRIPTION":"GIS_SYMBOL_DESCRIPTION",
	"RELIAB":"RELIAB",
	"GIS_LOCATION_SOURCE":"GIS_LOCATION_SOURCE",
	"GIS_LAT27":"GIS_LAT27",
	"GIS_LONG27":"GIS_LONG27",
	"GIS_LAT83":"GIS_LAT83",
	"GIS_LONG83":"GIS_LONG83",
	"OBJECTID":"OBJECTID"
	},
"geometryType":"esriGeometryPoint",
"spatialReference":{"wkid":102100,"latestWkid":3857},
"fields":[
	{"name":"UNIQID","type":"esriFieldTypeInteger","alias":"UNIQID"},
	{"name":"API","type":"esriFieldTypeString","alias":"API","length":8},
	{"name":"GIS_API5","type":"esriFieldTypeString","alias":"GIS_API5","length":5},
	{"name":"GIS_WELL_NUMBER","type":"esriFieldTypeString","alias":"GIS_WELL_NUMBER","length":6},
	{"name":"SYMNUM","type":"esriFieldTypeSmallInteger","alias":"SYMNUM"},
	{"name":"GIS_SYMBOL_DESCRIPTION","type":"esriFieldTypeString","alias":"GIS_SYMBOL_DESCRIPTION","length":50},
	{"name":"RELIAB","type":"esriFieldTypeString","alias":"RELIAB","length":2},
	{"name":"GIS_LOCATION_SOURCE","type":"esriFieldTypeString","alias":"GIS_LOCATION_SOURCE","length":80},
	{"name":"GIS_LAT27","type":"esriFieldTypeDouble","alias":"GIS_LAT27"},
	{"name":"GIS_LONG27","type":"esriFieldTypeDouble","alias":"GIS_LONG27"},
	{"name":"GIS_LAT83","type":"esriFieldTypeDouble","alias":"GIS_LAT83"},
	{"name":"GIS_LONG83","type":"esriFieldTypeDouble","alias":"GIS_LONG83"},
	{"name":"OBJECTID","type":"esriFieldTypeOID","alias":"OBJECTID"}
	],
"features":[
	{
	"attributes":{
		"UNIQID":351570961,
		"API":"00932157",
		"GIS_API5":"32157",
		"GIS_WELL_NUMBER":"2",
		"SYMNUM":4,
		"GIS_SYMBOL_DESCRIPTION":"Oil Well",
		"RELIAB":"20",
		"GIS_LOCATION_SOURCE":"Mainframe WELLBORE distances",
		"GIS_LAT27":33.780411800000003,
		"GIS_LONG27":-98.621734700000005,
		"GIS_LAT83":33.780511400000002,
		"GIS_LONG83":-98.622069800000006,
		"OBJECTID":543259
		},
		"geometry":{
			"x":-10978558.068667118,
			"y":3999366.2835585787
		}
	}]
}


http://wwwgisp.rrc.state.tx.us/GISViewer2/GISViewer/proxy/proxy.ashx?http://gis2.rrc.state.tx.us/cgi-bin/wellattrs_ags.cgi?apinum=00932157

<table cellpadding=2 cellspacing=4 nowrap>
<tr><th align=left valign=bottom height=40><b>OPERATOR/WELLBORE</b></th></tr><tr><th align=left>WELLBORE STATUS</th><td>OPEN</td></tr><tr><th align=left >LAST PERMIT ISSUED</th><td>286326</td></tr><tr><th align=left>LAST PERMIT OPERATOR NUMBER</th><td>072398</td></tr><tr><th align=left>LAST PERMIT OPERATOR</th><td>BIRGE, DONALD</td></tr><tr><th align=left>LAST PERMIT LEASE NAME</th><td>NOVELLA</td></tr><tr><th align=left>TOTAL DEPTH</th><td>560</td></tr><tr><th align=left>SURFACE LOCATION</th><td>Land</td></tr><tr><th align=left>ABSTRACT</th><td>1240</td></tr><tr><th align=left>SURVEY</th><td>HT&B #2/J. W. DOWLEN</td></tr><tr><th align=left>BLOCK</th><td></td></tr><tr><th align=left>SECTION</th><td></td></tr><tr><th align=left>DISTANCE 1</th><td>1000</td></tr><tr><th align=left>DIRECTION 1</th><td>SL</td></tr><tr><th align=left>DISTANCE 2</th><td>50</td></tr><tr><th align=left>DIRECTION 2</th><td>EL</td></tr><tr><td align=center><a href='https://rrcsearch3.neubus.com/esd3-rrc/api.php?function=GetImage&api_no=00932157' target='_blank'>Oil/Gas Imaged Records for API: 009-32157</a></td></tr><tr><th align=left valign=bottom height=40><b>COMPLETION RECORD</b></th></tr><tr><th align=left>PRORATION SCHEDULE</th><td>OIL</td></tr><tr><th align=left>DISTRICT</th><td>09</td></tr><tr><th align=left>LEASE/ID</th><td>00611</td></tr><tr><th align=left>OPERATOR NUMBER</th><td>871173</td></tr><tr><th align=left>OPERATOR</th><td>TROFA</td></tr><tr><th align=left>LEASE NAME</th><td>NOVELLA</td></tr><tr><th align=left>FIELD</th><td>ARCHER COUNTY REGULAR</td></tr><tr><th align=left>WELL NUMBER</th><td>   2</td></tr><tr><th align=left>TYPE WELL</th><td>PRODUCING</td></tr><tr><th align=left>ON SCHEDULE</th><td>YES</td></tr><tr><td align=left><a href='http://webapps2.rrc.state.tx.us/EWA/specificLeaseQueryAction.do?tab=init&viewType=prodAndTotalDisp&methodToCall=fromGisViewer&pdqSearchArgs.paramValue=|2=02|3=2015|4=01|5=2016|103=00611|6=O|102=09|8=specificLease|204=district|9=dispDetails|10=0' target='_blank'>Production Data Query(PDQ)</a></td><td align=left><a href='https://rrcsearch3.neubus.com/esd3-rrc/api.php?function=GetImage&district=09&lease_id=00611' target='_blank'>Oil/Gas Imaged Records for Lease/ID: 00611</a></td></tr>