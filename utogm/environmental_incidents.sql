create table utah_environmental_incidents (
	id integer not null primary key, 
	report_text text
);

alter table utah_environmental_incidents add column null_report boolean not null default false;
update utah_environmental_incidents set null_report = 'true' where report_text not like 'ENVIRONMENTAL INCIDENT REPORT%';

alter table utah_environmental_incidents add column report_taken_by varchar(100);
alter table utah_environmental_incidents add column report_date_time varchar(100);
alter table utah_environmental_incidents add column reporting_party_name varchar(100);
alter table utah_environmental_incidents add column reporting_party_title varchar(100);
alter table utah_environmental_incidents add column reporting_party_phone varchar(50);
alter table utah_environmental_incidents add column company_name varchar(100);
alter table utah_environmental_incidents add column discovered_date_time varchar(100);
alter table utah_environmental_incidents add column responsible_party_name varchar(100);
alter table utah_environmental_incidents add column responsible_party_phone varchar(50);
alter table utah_environmental_incidents add column responsible_party_address varchar(100);
alter table utah_environmental_incidents add column incident_address varchar(100);
alter table utah_environmental_incidents add column nearest_town varchar(50);
alter table utah_environmental_incidents add column county varchar(50);
alter table utah_environmental_incidents add column highway varchar(50);
alter table utah_environmental_incidents add column mile_marker varchar(50);
alter table utah_environmental_incidents add column utm varchar(100);
alter table utah_environmental_incidents add column land_ownership varchar(50);
alter table utah_environmental_incidents add column incident_summary text;
alter table utah_environmental_incidents add column chemicals_reported varchar(1000);
alter table utah_environmental_incidents add column impacted_media varchar(1000);

-- report_taken_by
select trim(split_part(split_part(report_text, 'Report Taken By:', 2), E'\n', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set report_taken_by = trim(split_part(split_part(report_text, 'Report Taken By:', 2), E'\n', 1)) where null_report is false;
--9582
update utah_environmental_incidents set report_taken_by = null where null_report is false and report_taken_by = '';
--528

-- report_date_time
select trim(split_part(split_part(report_text, 'Time Reported:', 2), E'\n', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set report_date_time = trim(split_part(split_part(report_text, 'Time Reported:', 2), E'\n', 1)) where null_report is false;
--9582
update utah_environmental_incidents set report_date_time = null where null_report is false and report_date_time = '';
--0

-- reporting_party_name
select trim(split_part(split_part(report_text, 'Reporting Party:', 2), 'Title:', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set reporting_party_name = trim(split_part(split_part(report_text, 'Reporting Party:', 2), 'Title:', 1)) where null_report is false;
--9582
update utah_environmental_incidents set reporting_party_name = null where null_report is false and reporting_party_name = '';
--67

-- reporting_party_title
select trim(split_part(split_part(report_text, 'Title:', 2), E'\n', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set reporting_party_title = trim(split_part(split_part(report_text, 'Title:', 2), E'\n', 1)) where null_report is false;
--9582
update utah_environmental_incidents set reporting_party_title = null where null_report is false and reporting_party_title = '';
--5875

-- reporting_party_phone
select trim(split_part(split_part(split_part(report_text, 'RESPONSIBLE PARTY', 1), 'Phone:', 2), E'\n', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set reporting_party_phone = trim(split_part(split_part(split_part(report_text, 'RESPONSIBLE PARTY', 1), 'Phone:', 2), E'\n', 1)) where null_report is false;
--9582
update utah_environmental_incidents set reporting_party_phone = null where null_report is false and reporting_party_phone = '';
--742

-- company_name
select trim(split_part(split_part(report_text, 'Company:', 2), 'Phone:', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set company_name = trim(split_part(split_part(report_text, 'Company:', 2), 'Phone:', 1)) where null_report is false;
--9582
update utah_environmental_incidents set company_name = null where null_report is false and company_name = '';
--1077

-- discovered_date_time
select trim(split_part(split_part(report_text, 'Time Discovered:', 2), E'\n', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set discovered_date_time = trim(split_part(split_part(report_text, 'Time Discovered:', 2), E'\n', 1)) where null_report is false;
--9582
update utah_environmental_incidents set discovered_date_time = null where null_report is false and discovered_date_time = '';
--0

-- responsible_party_name
select trim(split_part(split_part(split_part(report_text, 'RESPONSIBLE PARTY', 2), 'Name:', 2), 'Phone', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set responsible_party_name = trim(split_part(split_part(split_part(report_text, 'RESPONSIBLE PARTY', 2), 'Name:', 2), 'Phone', 1)) where null_report is false;
--9582
update utah_environmental_incidents set responsible_party_name = null where null_report is false and responsible_party_name = '';
--190

-- responsible_party_phone
select trim(split_part(split_part(split_part(report_text, 'RESPONSIBLE PARTY', 2), 'Phone:', 2),  E'\n', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set responsible_party_phone = trim(split_part(split_part(split_part(report_text, 'RESPONSIBLE PARTY', 2), 'Phone:', 2),  E'\n', 1)) where null_report is false;
--9582
update utah_environmental_incidents set responsible_party_phone = null where null_report is false and responsible_party_phone = '';
--3142

-- responsible_party_address
select trim(split_part(split_part(split_part(report_text, 'INCIDENT LOCATION', 1), 'Address:', 2), E'\n', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set responsible_party_address = trim(split_part(split_part(split_part(report_text, 'INCIDENT LOCATION', 1), 'Address:', 2), E'\n', 1)) where null_report is false;
--9582
update utah_environmental_incidents set responsible_party_address = null where null_report is false and responsible_party_address = '';
--3196

-- incident_address
select trim(split_part(split_part(report_text, 'Incident Address:', 2), E'\n', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set incident_address = trim(split_part(split_part(report_text, 'Incident Address:', 2), E'\n', 1)) where null_report is false;
--9582
update utah_environmental_incidents set incident_address = null where null_report is false and incident_address = '';
--564

-- nearest_town
select trim(split_part(split_part(report_text, 'Nearest Town:', 2), 'County:', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set nearest_town = trim(split_part(split_part(report_text, 'Nearest Town:', 2), 'County:', 1)) where null_report is false;
--9582
update utah_environmental_incidents set nearest_town = null where null_report is false and nearest_town = '';
--0
update utah_environmental_incidents set nearest_town = null where null_report is false and nearest_town = '- Please Select -';
--1074

-- county
select trim(split_part(split_part(split_part(report_text, 'INCIDENT LOCATION', 2), 'County:', 2), E'\n', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set county = trim(split_part(split_part(split_part(report_text, 'INCIDENT LOCATION', 2), 'County:', 2), E'\n', 1)) where null_report is false;
--9582
update utah_environmental_incidents set county = null where null_report is false and county = '';
--0
update utah_environmental_incidents set county = null where null_report is false and county = '- Please Select -';
--106

-- highway
select trim(split_part(split_part(report_text, 'Highway:', 2), 'Mile Marker:', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set highway = trim(split_part(split_part(report_text, 'Highway:', 2), 'Mile Marker:', 1)) where null_report is false;
--9582
update utah_environmental_incidents set highway = null where null_report is false and highway = '';
--8355

-- mile_marker
select trim(split_part(split_part(report_text, 'Mile Marker:', 2), E'\n', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set mile_marker = trim(split_part(split_part(report_text, 'Mile Marker:', 2), E'\n', 1)) where null_report is false;
--9582
update utah_environmental_incidents set mile_marker = null where null_report is false and mile_marker = '';
--9144

-- utm
select trim(split_part(split_part(split_part(report_text, 'Mile Marker:', 2), 'UTM:', 2), 'Land Ownership:', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set utm = trim(split_part(split_part(split_part(report_text, 'Mile Marker:', 2), 'UTM:', 2), 'Land Ownership:', 1)) where null_report is false;
--9582
update utah_environmental_incidents set utm = null where null_report is false and utm = '';
--0
update utah_environmental_incidents set utm = null where null_report is false and utm = '(E) (N)';
--6806

-- land_ownership
select trim(split_part(split_part(report_text, 'Land Ownership:', 2), E'\n', 1)) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set land_ownership = trim(split_part(split_part(report_text, 'Land Ownership:', 2), E'\n', 1)) where null_report is false;
--9582
update utah_environmental_incidents set land_ownership = null where null_report is false and land_ownership = '';
--9308

-- incident_summary
select id, trim(regexp_replace(split_part(split_part(report_text, 'INCIDENT SUMMARY', 2), 'CHEMICAL(S)', 1), E'\n', ' ', 'g')) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set incident_summary = trim(regexp_replace(split_part(split_part(report_text, 'INCIDENT SUMMARY', 2), 'CHEMICAL(S)', 1), E'\n', ' ', 'g')) where null_report is false;
--9582
update utah_environmental_incidents set incident_summary = null where null_report is false and incident_summary = '';
--22

-- chemicals_reported
select id, trim(regexp_replace(split_part(split_part(split_part(split_part(report_text, 'CHEMICAL(S)', 2), 'REPORTED', 2), 'Incident notification', 1), 'IMPACTED', 1), E'\n', '~~', 'g')) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set chemicals_reported = trim(regexp_replace(split_part(split_part(split_part(split_part(report_text, 'CHEMICAL(S)', 2), 'REPORTED', 2), 'Incident notification', 1), 'IMPACTED', 1), E'\n', '~~', 'g')) where null_report is false;
--9582
update utah_environmental_incidents set chemicals_reported = null where null_report is false and chemicals_reported = '';
--1
update utah_environmental_incidents set chemicals_reported = null where null_report is false and chemicals_reported = '~~';
--1465

select id, chemicals_reported, upper(substr(chemicals_reported,3,length(chemicals_reported)-4)) from utah_environmental_incidents where chemicals_reported is not null;
update utah_environmental_incidents set chemicals_reported = upper(substr(chemicals_reported,3,length(chemicals_reported)-4)) where chemicals_reported is not null;

update utah_environmental_incidents set chemicals_reported = 'UNKNOWN' where chemicals_reported = '?';
--1



-- impacted_media
select id, trim(regexp_replace(replace(split_part(split_part(split_part(split_part(report_text, 'NOTIFICATIONS', 1), 'IMPACTED', 2), 'Incident notification', 1), 'MEDIA', 2), 'Media Media Other Land Use Waterway Name Near Water Distance NRC Rpt. #', ''), E'\n', ' ', 'g')) from utah_environmental_incidents where null_report is false;
update utah_environmental_incidents set impacted_media = trim(regexp_replace(replace(split_part(split_part(split_part(split_part(report_text, 'NOTIFICATIONS', 1), 'IMPACTED', 2), 'Incident notification', 1), 'MEDIA', 2), 'Media Media Other Land Use Waterway Name Near Water Distance NRC Rpt. #', ''), E'\n', ' ', 'g')) where null_report is false;
--9582
update utah_environmental_incidents set impacted_media = null where null_report is false and impacted_media = '';
--3865


create table utah_environmental_incident_chemicals (
	utah_environmental_incident_id integer, 
	chemical_name varchar(250)
);

update utah_environmental_incident_chemicals set chemical_name = 'MEAN GREEN (CORROSIVE)' where chemical_name = '"MEAN GREEN" (CORROSIVE)';
--1
update utah_environmental_incident_chemicals set chemical_name = 'OILY SHEEN?' where chemical_name = '"OILY SHEEN?"';
--1
update utah_environmental_incident_chemicals set chemical_name = 'UNKNOWN' where chemical_name = '- PLEASE SELECT - N/A - UNKNOWN';
--2
delete from utah_environmental_incident_chemicals where chemical_name = '.';
--1


update utah_environmental_incidents set company_name = 'The Garage' where company_name = '"The Garage"';
--1
update utah_environmental_incidents set company_name = null where company_name = '*';
--1

alter table utah_environmental_incidents add column is_og_operator boolean not null default false;

update utah_environmental_incidents set is_og_operator = 'true' where left(company_name,2) = '3E';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'AMOCO%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'ANADAR%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'ANSCHUTZ%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'ARCO%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'AS AGENT FOR MTN STATES PETROLEUM CORP%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'AUGUSTUS ENERGY%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'BAKER-HUGHES%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'BASIN TRANSPORTATION%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'BERRY PETROLEUM%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'BIG WEST%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'BILL BARRET%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'BINGHAM%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'BP AMOCO%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'CHERVON%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'CHEVERON%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'CHEVRON%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'CITATION OIL%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'COASTAL FIELD SERVICES%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'COASTAL GAS%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'COASTAL OIL%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'COLORADO INTERSTATE GAS%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'COLT RESOURCES%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'CONOCO%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'COSTAL STATES OIL%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'DALBO%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'DAVIS ENERGY%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'DEVON%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'DUKE ENERGY%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'E&P ENERGY%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'E.P. ENERGY%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'EL PASO%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'ELPASO%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'ENCANA%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'EOG RESOURCES%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'EP ENERGY%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'EPIC%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'ETC CANYON PIPELINE%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'EXXON%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'FLYING "J"%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'FLYING J%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'FOUNDATION ENERGY%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'GENESIS PETROLEUM%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'HALIBURTON%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'HOLLEY REFINERY%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'HOLLY %';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'HOLY FRONTIER%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'HYLAND %';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'INLAND PRODUCTION%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'JACKSON OIL%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'KERR MCGEE%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'KERR-MCGEE%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'MATHATHON OIL%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'MEDALLION EXPLORATION%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'MOBIL %';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'MOBILE %';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'MONARCH NATURAL GAS%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'MONTEZUMA WELL SERVICE%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'MOUNTAIN FUEL%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'NAVAJO NATION OIL%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'NAVAJO OIL%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'NEW FIELD%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'NEWFIELD %';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'NN OIL AND GAS%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'PATARA OIL%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'PENZOIL %';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'PETERSON OIL%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'PHILIPS PETROLEUM%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'PHILLIP REFINERY%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'PHILLIPS %';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'PIERCE OIL COMPANY%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'PIONEER PIPELINE%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'PLAINES ALL AMERICAN PIPELINE%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'PLAINS %';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'PRODUCTION OPERAT%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'QEP %';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'QUESTAR %';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'RESOLUTE NATURAL RESOURCES%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'RESULUTE NATUAL RESOURCES%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'ROCKY MOUNTAIN%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'ROCKY MTN%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'SCHLUMBERGER%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'SHELL%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'SINCLAIR OIL%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'TESORO%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'TEXACO%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'TOM BROWN%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'WESTERN PETROLEUM%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'WETHERFORD FRACTURING%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'WEXPRO%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'WHITING%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'WILLIAMS%';
update utah_environmental_incidents set is_og_operator = 'true' where company_name ilike 'XTO ENERGY%';


-- is drill or exercise
alter table utah_environmental_incidents add column is_drill_or_exercise boolean not null default false;
select id, company_name, left(chemicals_reported,40), left(incident_summary,250) from utah_environmental_incidents where incident_summary ilike '%THIS IS A DRILL%' or incident_summary ilike '%EXERCISE MESSAGE%' or incident_summary ilike '%***DRILL%' or incident_summary ilike '%PRACTICE EXERCISE%' or incident_summary ilike '%WAR EXERCISE%' or incident_summary ilike '%Not an incident%' or incident_summary ilike '%mock drill%';
update utah_environmental_incidents set is_drill_or_exercise = 'true' where incident_summary ilike '%THIS IS A DRILL%' or incident_summary ilike '%EXERCISE MESSAGE%' or incident_summary ilike '%***DRILL%' or incident_summary ilike '%PRACTICE EXERCISE%' or incident_summary ilike '%WAR EXERCISE%' or incident_summary ilike '%Not an incident%' or incident_summary ilike '%mock drill%';

-- production water
alter table utah_environmental_incidents add column is_production_water boolean not null default false;
update utah_environmental_incidents set is_production_water = 'true' where chemicals_reported ilike '%prod%water%' and is_drill_or_exercise is false;
--123 (compared to 81 on website)

-- crude oil
alter table utah_environmental_incidents add column is_crude_oil boolean not null default false;
update utah_environmental_incidents set is_crude_oil = 'true' where chemicals_reported ilike '%crude%' and is_drill_or_exercise is false;
--191 (compared to 188 on website)

-- natural gas (methane)
alter table utah_environmental_incidents add column is_natural_gas boolean not null default false;
update utah_environmental_incidents set is_natural_gas = 'true' where is_drill_or_exercise is false and (chemicals_reported ilike '%nat%gas%' or chemicals_reported ilike '%methane%');
--106 (compared to 77 on website)

-- propane
alter table utah_environmental_incidents add column is_propane boolean not null default false;
update utah_environmental_incidents set is_propane = 'true' where chemicals_reported ilike '%propane%' and is_drill_or_exercise is false;
--34 (compared to 34 on website)

-- petroleum
alter table utah_environmental_incidents add column is_petroleum boolean not null default false;
update utah_environmental_incidents set is_petroleum = 'true' where chemicals_reported ilike '%petrol%' and is_drill_or_exercise is false;
--174 (compared to NA on website (23 for petroleum mixture))

-- condensate
alter table utah_environmental_incidents add column is_condensate boolean not null default false;
update utah_environmental_incidents set is_condensate = 'true' where chemicals_reported ilike '%condensate%' and is_drill_or_exercise is false;
--33 (compared to NA on website)

-- spill
alter table utah_environmental_incidents add column is_spill boolean not null default false;
update utah_environmental_incidents set is_spill = 'true' where incident_summary ilike '%spill%' and is_drill_or_exercise is false;
--2950 (compared to NA on website)

-- groundwater
alter table utah_environmental_incidents add column is_groundwater boolean not null default false;
update utah_environmental_incidents set is_groundwater = 'true' where impacted_media ilike '%ground%water%' and is_drill_or_exercise is false;
--29 (compared to NA on website)

-- 
alter table utah_environmental_incidents add column  boolean not null default false;
update utah_environmental_incidents set  = 'true' where chemicals_reported ilike '%%';
-- (compared to  on website)












