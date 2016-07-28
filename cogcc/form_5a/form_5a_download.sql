-- add download status flag column
alter table cogcc_documents add column form_5a_downloaded varchar(20) default 'not downloaded';
alter table cogcc_documents add column well_api_number varchar(12);
update cogcc_documents set well_api_number = (select w.attrib_1 from cogcc_wells w where w.well_id = cogcc_documents.well_id);
alter table cogcc_documents add column well_api_county varchar(3);
update cogcc_documents set well_api_county = (select w.api_county from cogcc_wells w where w.well_id = cogcc_documents.well_id);
create index cogcc_documents_well_api_county_idx on cogcc_documents (well_api_county);

-- form 5A document catalog links in PDF format
select count(*) from cogcc_documents where form_5a_downloaded = 'not downloaded' and well_api_county in ('045','123') and document_date > '8/15/2010' and (document_name ilike '%completed interval report%' or document_name ilike '%5A%');

-- downloader query
select id, document_id, well_api_number from cogcc_documents where form_5a_downloaded = 'not downloaded' and well_api_county in ('045','123') and document_date > '8/15/2010' and (document_name ilike '%completed interval report%' or document_name ilike '%5A%');


create table cogcc_form5a_documents (
	id serial primary key not null,
	cogcc_document_id integer, 
	well_id integer,
	well_api_number varchar(12),
	document_id integer, 
	pdf_text text
);

alter table cogcc_documents add column form_5a_imported boolean default false;

alter table cogcc_form5a_documents add column water_amounts_reported boolean default false;
update cogcc_form5a_documents set water_amounts_reported = 'true' where pdf_text ilike '%Recycled%';

alter table cogcc_form5a_documents add column total_fluid_used varchar(50);
alter table cogcc_form5a_documents add column recycled_water_used varchar(50);
alter table cogcc_form5a_documents add column fresh_water_used varchar(50);
alter table cogcc_form5a_documents add column flowback_recovered varchar(50);
alter table cogcc_form5a_documents add column flowback_disposition varchar(50);
alter table cogcc_form5a_documents add column document_date date;

update cogcc_form5a_documents set document_date = (select d.document_date from cogcc_documents d where d.id = cogcc_form5a_documents.cogcc_document_id);

-- Example Text

     Total fluid used in treatment (bbl)5008                                      Max pressure during treatment (psi):  4998                       +
                                                                                                                                                   +
     Total gas used in treatment (mcf):                                         Fluid density at initial fracture (lbs/g8.34                       +
        Type of gas used in treatment:                                                                                                             +
                                                                                              Min frac gradient (psi/ft)0.70                       +
     Total acid used in treatment (bbl):                                                  Number of staged intervals:     1                        +
                                                                                                                                                   +
Recycled water used in treatment (bbl):5008                                          Flowback volume recovered (bbl):                              +
                                                                                                                                                   +
   Fresh water used in treatment (bbl):                       Disposition method for flowback:  RECYCLE                                            +
                                                                                                                                                   +
            Total proppant used (lbs): 154000                         Rule 805 green completion techniques were utilized:


 
--Total fluid used in treatment (b
select distinct
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Total fluid used in treatment', 2), E'\n', 1)), '\s\s+'))[1] as total_fluid_used 
from 
	cogcc_form5a_documents
where 
	water_amounts_reported is true
order by 
	total_fluid_used;

select 
	id, 
	well_api_number, 
	document_id, 
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Total fluid used in treatment (b', 2), E'\n', 1)), '\s\s+'))[1] as total_fluid_used 
from 
	cogcc_form5a_documents
where 
	water_amounts_reported is true;

update cogcc_form5a_documents set total_fluid_used = (regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Total fluid used in treatment (b', 2), E'\n', 1)), '\s\s+'))[1] where water_amounts_reported is true;


--Recycled water used in treatment (bb
select distinct
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Recycled water used in treatment', 2), E'\n', 1)), '\s\s+'))[1] as recycled_water_used 
from 
	cogcc_form5a_documents
where 
	water_amounts_reported is true
order by 
	recycled_water_used;

select 
	id, 
	well_api_number, 
	document_id, 
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Recycled water used in treatment (bb', 2), E'\n', 1)), '\s\s+'))[1] as recycled_water_used 
from 
	cogcc_form5a_documents
where 
	water_amounts_reported is true;

update cogcc_form5a_documents set recycled_water_used = (regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Recycled water used in treatment (bb', 2), E'\n', 1)), '\s\s+'))[1] where water_amounts_reported is true;


--Fresh water used in treatment 
select distinct
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Fresh water used in treatment', 2), E'\n', 1)), '\s\s+'))[1] as fresh_water_used 
from 
	cogcc_form5a_documents
where 
	water_amounts_reported is true
order by 
	fresh_water_used;

select 
	id, 
	well_api_number, 
	document_id, 
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Fresh water used in treatment (bbl', 2), E'\n', 1)), '\s\s+'))[1] as fresh_water_used 
from 
	cogcc_form5a_documents
where 
	water_amounts_reported is true;

update cogcc_form5a_documents set fresh_water_used = (regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Fresh water used in treatment (bbl', 2), E'\n', 1)), '\s\s+'))[1] where water_amounts_reported is true;


--Flowback volume recovered (bbl):
select distinct
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Flowback volume recovered', 2), E'\n', 1)), '\s\s+'))[1] as flowback_recovered 
from 
	cogcc_form5a_documents
where 
	water_amounts_reported is true
order by 
	flowback_recovered;

select 
	id, 
	well_api_number, 
	document_id, 
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Flowback volume recovered (bbl):', 2), E'\n', 1)), '\s\s+'))[1] as flowback_recovered 
from 
	cogcc_form5a_documents
where 
	water_amounts_reported is true;

update cogcc_form5a_documents set flowback_recovered = (regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Flowback volume recovered (bbl):', 2), E'\n', 1)), '\s\s+'))[1] where water_amounts_reported is true;


--Disposition method for flowback:
select distinct
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Disposition method for flowback', 2), E'\n', 1)), '\s\s+'))[1] as flowback_disposition 
from 
	cogcc_form5a_documents
where 
	water_amounts_reported is true
order by 
	flowback_disposition;

select 
	id, 
	well_api_number, 
	document_id, 
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Disposition method for flowback:', 2), E'\n', 1)), '\s\s+'))[1] as flowback_disposition 
from 
	cogcc_form5a_documents
where 
	water_amounts_reported is true;

update cogcc_form5a_documents set flowback_disposition = (regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Disposition method for flowback:', 2), E'\n', 1)), '\s\s+'))[1] where water_amounts_reported is true;


select 
	id, 
	well_api_number, 
	document_id,
	total_fluid_used, 
	recycled_water_used, 
	fresh_water_used, 
	flowback_recovered, 
	flowback_disposition 
from 
	cogcc_form5a_documents 
where 
	water_amounts_reported is true and well_id = 12334244;


-- column cleanup
select 
	total_fluid_used, 
	regexp_replace(total_fluid_used, '[^0-9]', '', 'g') 
from 
	cogcc_form5a_documents 
where 
	water_amounts_reported is true;

update 
	cogcc_form5a_documents 
set 
	total_fluid_used = regexp_replace(total_fluid_used, '[^0-9]', '', 'g'), 
	recycled_water_used = regexp_replace(recycled_water_used, '[^0-9]', '', 'g'), 
	fresh_water_used = regexp_replace(fresh_water_used, '[^0-9]', '', 'g'), 
	flowback_recovered = regexp_replace(flowback_recovered, '[^0-9]', '', 'g') 
where 
	water_amounts_reported is true;

update cogcc_form5a_documents set total_fluid_used = null where trim(total_fluid_used) = '';
update cogcc_form5a_documents set recycled_water_used = null where trim(recycled_water_used) = '';
update cogcc_form5a_documents set fresh_water_used = null where trim(fresh_water_used) = '';
update cogcc_form5a_documents set flowback_recovered = null where trim(flowback_recovered) = '';

alter table cogcc_form5a_documents alter column total_fluid_used type integer using total_fluid_used::integer;
alter table cogcc_form5a_documents alter column recycled_water_used type integer using recycled_water_used::integer;
alter table cogcc_form5a_documents alter column fresh_water_used type integer using fresh_water_used::integer;
alter table cogcc_form5a_documents alter column flowback_recovered type integer using flowback_recovered::integer;

update cogcc_form5a_documents set flowback_disposition = null where trim(flowback_disposition) = '';

alter table cogcc_form5a_documents add column all_water_amounts_null boolean default false;
update cogcc_form5a_documents set all_water_amounts_null = 'true' where water_amounts_reported is true and total_fluid_used is null and recycled_water_used is null and fresh_water_used is null and flowback_recovered is null and flowback_disposition is null;


-- bad, but probably accurate query
select w.attrib_1 as well_api_number, 
	case w.api_county when '045' then 'Garfield' when '123' then 'Weld' end as county, 
	w.api_county as well_api_county, 
	w.api_seq_nu as well_api_sequence, 
	--w.attrib_2 as operator_name, 
	--w.well_num as well_number,
	--w.well_name,  
	w.facility_s as well_status, 
	w.lat as latitude, 
	w.long as longitude, 
	w.field_name, 
	(select fracture_date from frac_focus_wells where well_id = w.well_id) as ff_fracture_date, 
	(select gas_basin from frac_focus_wells where well_id = w.well_id) as ff_gas_basin, 
	(select total_water_volume from frac_focus_wells where well_id = w.well_id) as ff_total_water_volume, 
	(select document_date from cogcc_form5a_documents where well_id = w.well_id order by document_date desc limit 1) as f5a_document_date, 
	(select total_fluid_used from cogcc_form5a_documents where well_id = w.well_id order by document_date desc limit 1) as f5a_total_fluid_used, 
	(select recycled_water_used from cogcc_form5a_documents where well_id = w.well_id order by document_date desc limit 1) as f5a_recycled_water_used, 
	(select fresh_water_used from cogcc_form5a_documents where well_id = w.well_id order by document_date desc limit 1) as f5a_fresh_water_used, 
	(select flowback_recovered from cogcc_form5a_documents where well_id = w.well_id order by document_date desc limit 1) as f5a_flowback_recovered, 
	(select flowback_disposition from cogcc_form5a_documents where well_id = w.well_id order by document_date desc limit 1) as f5a_flowback_disposition  
from cogcc_wells w 
where w.api_county in ('045','123') and (w.well_id in (select well_id from frac_focus_wells where total_water_volume is not null union select well_id from cogcc_form5a_documents where water_amounts_reported is true))
order by well_api_county, well_api_sequence;


COPY (select w.attrib_1 as well_api_number, 
	case w.api_county when '045' then 'Garfield' when '123' then 'Weld' end as county, 
	w.attrib_3 as well_number_name, 
	w.facility_s as well_status, 
	w.attrib_2 as operator_name, 
	w.lat as latitude, 
	w.long as longitude, 
	w.field_name, 
	ffw.gas_basin as ff_gas_basin, 
	ffw.fracture_date as ff_fracture_date, 
	ffw.total_water_volume as ff_total_water_volume_gal, 
	f5d.document_date as f5a_document_date, 
	f5d.total_fluid_used as f5a_total_fluid_used_bbl, 
	f5d.recycled_water_used as f5a_recycled_water_used_bbl, 
	f5d.fresh_water_used as f5a_fresh_water_used_bbl, 
	f5d.flowback_recovered as f5a_flowback_recovered_bbl, 
	f5d.flowback_disposition as f5a_flowback_disposition  
from cogcc_wells w 
left outer join frac_focus_wells ffw on w.well_id = ffw.well_id and ffw.total_water_volume is not null 
left outer join cogcc_form5a_documents f5d on w.well_id = f5d.well_id and f5d.water_amounts_reported is true and f5d.all_water_amounts_null is false
where w.api_county in ('045','123') and (w.well_id in (select well_id from frac_focus_wells where total_water_volume is not null union select well_id from cogcc_form5a_documents where water_amounts_reported is true and all_water_amounts_null is false))
order by well_api_number) TO '/Users/troyburke/Data/CSU/fracturing_water_amounts.csv' WITH CSV HEADER;

COPY (select distinct w.attrib_1 as well_api_number, 
	case w.api_county when '045' then 'Garfield' when '123' then 'Weld' end as county, 
	w.attrib_3 as well_number_name, 
	w.facility_s as well_status, 
	w.attrib_2 as operator_name, 
	w.lat as latitude, 
	w.long as longitude, 
	w.field_name, 
	f5d.document_date as f5a_document_date, 
	f5d.total_fluid_used as f5a_total_fluid_used_bbl, 
	f5d.recycled_water_used as f5a_recycled_water_used_bbl, 
	f5d.fresh_water_used as f5a_fresh_water_used_bbl, 
	f5d.flowback_recovered as f5a_flowback_recovered_bbl, 
	f5d.flowback_disposition as f5a_flowback_disposition  
from cogcc_wells w 
left outer join cogcc_form5a_documents f5d on w.well_id = f5d.well_id and f5d.water_amounts_reported is true and f5d.all_water_amounts_null is false
where w.api_county in ('045','123') and (w.well_id in (select well_id from cogcc_form5a_documents where water_amounts_reported is true and all_water_amounts_null is false)) and f5d.id < 9409 
order by county desc, well_api_number) TO '/Users/troyburke/Data/CSU/cogcc_form5a_water_amounts_remove_dupes.csv' WITH CSV HEADER;


#######################################################################################
##        UPDATES USING NEW DOCUMENT INDEX => cogcc_document_names                   ##
#######################################################################################

-- add download status flag column
alter table cogcc_document_names add column form_5a_downloaded varchar(20) default 'not downloaded';
alter table cogcc_document_names add column form_5a_imported boolean default false;

update cogcc_document_names 
set form_5a_downloaded = 'PDF downloaded'
where document_number in (select distinct document_number from cogcc_documents where form_5a_downloaded = 'PDF downloaded');

update cogcc_document_names 
set form_5a_downloaded = 'TIFF image'
where document_number in (select distinct document_number from cogcc_documents where form_5a_downloaded = 'TIFF image');

update cogcc_document_names 
set form_5a_imported = 't'
where document_number in (select distinct document_number from cogcc_documents where form_5a_imported is true);


alter table cogcc_document_names add column well_api_number varchar(12);
update cogcc_document_names set well_api_number = (select w.attrib_1 from cogcc_well_surface_locations w where w.well_id = cogcc_document_names.well_id);
alter table cogcc_document_names add column well_api_county varchar(3);
update cogcc_document_names set well_api_county = (select w.api_county from cogcc_well_surface_locations w where w.well_id = cogcc_document_names.well_id);
create index cogcc_document_names_well_api_county_idx on cogcc_document_names (well_api_county);

update cogcc_form5a_documents set water_amounts_reported = 'true' where parsed is false and pdf_text ilike '%Recycled%'; --5799
update cogcc_form5a_documents set document_date = (select d.document_date from cogcc_document_names d where d.id = cogcc_form5a_documents.cogcc_document_id) where parsed is false; --11718

-- switch value columns back to string for parsing input
alter table cogcc_form5a_documents alter column total_fluid_used type varchar(50) using total_fluid_used::varchar;
alter table cogcc_form5a_documents alter column recycled_water_used type varchar(50) using recycled_water_used::varchar;
alter table cogcc_form5a_documents alter column fresh_water_used type varchar(50) using fresh_water_used::varchar;
alter table cogcc_form5a_documents alter column flowback_recovered type varchar(50) using flowback_recovered::varchar;

--Total fluid used in treatment (b
select distinct
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Total fluid used in treatment', 2), E'\n', 1)), '\s\s+'))[1] as total_fluid_used 
from 
	cogcc_form5a_documents
where 
	parsed is false and water_amounts_reported is true
order by 
	total_fluid_used;

select 
	id, 
	well_api_number, 
	document_id, 
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Total fluid used in treatment (b', 2), E'\n', 1)), '\s\s+'))[1] as total_fluid_used 
from 
	cogcc_form5a_documents
where 
	parsed is false and water_amounts_reported is true;

update cogcc_form5a_documents set total_fluid_used = (regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Total fluid used in treatment (b', 2), E'\n', 1)), '\s\s+'))[1] where parsed is false and water_amounts_reported is true;


--Recycled water used in treatment (bb
select distinct
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Recycled water used in treatment', 2), E'\n', 1)), '\s\s+'))[1] as recycled_water_used 
from 
	cogcc_form5a_documents
where 
	parsed is false and water_amounts_reported is true
order by 
	recycled_water_used;

select 
	id, 
	well_api_number, 
	document_id, 
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Recycled water used in treatment (bb', 2), E'\n', 1)), '\s\s+'))[1] as recycled_water_used 
from 
	cogcc_form5a_documents
where 
	parsed is false and water_amounts_reported is true;

update cogcc_form5a_documents set recycled_water_used = (regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Recycled water used in treatment (bb', 2), E'\n', 1)), '\s\s+'))[1] where parsed is false and water_amounts_reported is true;


--Fresh water used in treatment 
select distinct
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Fresh water used in treatment', 2), E'\n', 1)), '\s\s+'))[1] as fresh_water_used 
from 
	cogcc_form5a_documents
where 
	parsed is false and water_amounts_reported is true
order by 
	fresh_water_used;

select 
	id, 
	well_api_number, 
	document_id, 
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Fresh water used in treatment (bbl', 2), E'\n', 1)), '\s\s+'))[1] as fresh_water_used 
from 
	cogcc_form5a_documents
where 
	parsed is false and water_amounts_reported is true;

update cogcc_form5a_documents set fresh_water_used = (regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Fresh water used in treatment (bbl', 2), E'\n', 1)), '\s\s+'))[1] where parsed is false and water_amounts_reported is true;


--Flowback volume recovered (bbl):
select distinct
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Flowback volume recovered', 2), E'\n', 1)), '\s\s+'))[1] as flowback_recovered 
from 
	cogcc_form5a_documents
where 
	parsed is false and water_amounts_reported is true
order by 
	flowback_recovered;

select 
	id, 
	well_api_number, 
	document_id, 
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Flowback volume recovered (bbl):', 2), E'\n', 1)), '\s\s+'))[1] as flowback_recovered 
from 
	cogcc_form5a_documents
where 
	parsed is false and water_amounts_reported is true;

update cogcc_form5a_documents set flowback_recovered = (regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Flowback volume recovered (bbl):', 2), E'\n', 1)), '\s\s+'))[1] where parsed is false and water_amounts_reported is true;


--Disposition method for flowback:
select distinct
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Disposition method for flowback', 2), E'\n', 1)), '\s\s+'))[1] as flowback_disposition 
from 
	cogcc_form5a_documents
where 
	parsed is false and water_amounts_reported is true
order by 
	flowback_disposition;

select 
	id, 
	well_api_number, 
	document_id, 
	(regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Disposition method for flowback:', 2), E'\n', 1)), '\s\s+'))[1] as flowback_disposition 
from 
	cogcc_form5a_documents
where 
	parsed is false and water_amounts_reported is true;

update cogcc_form5a_documents set flowback_disposition = (regexp_split_to_array(trim(split_part(split_part(pdf_text, 'Disposition method for flowback:', 2), E'\n', 1)), '\s\s+'))[1] where parsed is false and water_amounts_reported is true;

-- column cleanup
select 
	total_fluid_used, 
	regexp_replace(total_fluid_used, '[^0-9]', '', 'g') 
from 
	cogcc_form5a_documents 
where 
	parsed is false and water_amounts_reported is true;

update 
	cogcc_form5a_documents 
set 
	total_fluid_used = regexp_replace(total_fluid_used, '[^0-9]', '', 'g'), 
	recycled_water_used = regexp_replace(recycled_water_used, '[^0-9]', '', 'g'), 
	fresh_water_used = regexp_replace(fresh_water_used, '[^0-9]', '', 'g'), 
	flowback_recovered = regexp_replace(flowback_recovered, '[^0-9]', '', 'g') 
where 
	parsed is false and water_amounts_reported is true;

update cogcc_form5a_documents set total_fluid_used = null where parsed is false and trim(total_fluid_used) = '';
update cogcc_form5a_documents set recycled_water_used = null where parsed is false and trim(recycled_water_used) = '';
update cogcc_form5a_documents set fresh_water_used = null where parsed is false and trim(fresh_water_used) = '';
update cogcc_form5a_documents set flowback_recovered = null where parsed is false and trim(flowback_recovered) = '';

alter table cogcc_form5a_documents alter column total_fluid_used type integer using total_fluid_used::integer;
alter table cogcc_form5a_documents alter column recycled_water_used type integer using recycled_water_used::integer;
alter table cogcc_form5a_documents alter column fresh_water_used type integer using fresh_water_used::integer;
alter table cogcc_form5a_documents alter column flowback_recovered type integer using flowback_recovered::integer;

update cogcc_form5a_documents set flowback_disposition = null where parsed is false and trim(flowback_disposition) = '';

update cogcc_form5a_documents set all_water_amounts_null = 'true' where parsed is false and water_amounts_reported is true and total_fluid_used is null and recycled_water_used is null and fresh_water_used is null and flowback_recovered is null and flowback_disposition is null;

-- http://ogccweblink.state.co.us/DownloadDocument.aspx?DocumentId=2941582

CREATE TABLE cogcc_form5a_documents_backup AS SELECT * FROM cogcc_form5a_documents;

update cogcc_form5a_documents set pdf_text = null, water_amounts_reported = 'f', total_fluid_used = null, recycled_water_used = null, fresh_water_used = null, flowback_recovered = null, flowback_disposition = null, all_water_amounts_null = 'f', parsed = 'f' where id > 9408;

alter table cogcc_form5a_documents add column in_use boolean not null default false;
alter table cogcc_form5a_documents add column pdf_downloaded boolean not null default false;
alter table cogcc_form5a_documents add column well_api_county varchar(3);

update cogcc_form5a_documents set well_api_county = split_part(well_api_number, '-', 2);




create table cogcc_form5a_formations (
	id serial primary key not null,
	cogcc_form5a_document_id integer, 
	formation_text text, 
	total_fluid_used character varying(50), 
	recycled_water_used character varying(50), 
	fresh_water_used character varying(50), 
	flowback_recovered character varying(50), 
	flowback_disposition character varying(50), 
	staged_intervals character varying(50)
);


--Total fluid used in treatment (b
select distinct
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Total fluid used in treatment', 2), E'\n', 1)), '\s\s+'))[1] as total_fluid_used 
from 
	cogcc_form5a_formations;

select 
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Total fluid used in treatment (b', 2), E'\n', 1)), '\s\s+'))[1] as total_fluid_used 
from 
	cogcc_form5a_formations;

update cogcc_form5a_formations set total_fluid_used = (regexp_split_to_array(trim(split_part(split_part(formation_text, 'Total fluid used in treatment (b', 2), E'\n', 1)), '\s\s+'))[1] where cogcc_form5a_document_id > 9408;


--Recycled water used in treatment (bb
select distinct
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Recycled water used in treatment', 2), E'\n', 1)), '\s\s+'))[1] as recycled_water_used 
from 
	cogcc_form5a_formations;

select 
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Recycled water used in treatment (bb', 2), E'\n', 1)), '\s\s+'))[1] as recycled_water_used 
from 
	cogcc_form5a_formations;

update cogcc_form5a_formations set recycled_water_used = (regexp_split_to_array(trim(split_part(split_part(formation_text, 'Recycled water used in treatment (bb', 2), E'\n', 1)), '\s\s+'))[1] where cogcc_form5a_document_id > 9408;


--Fresh water used in treatment 
select distinct
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Fresh water used in treatment', 2), E'\n', 1)), '\s\s+'))[1] as fresh_water_used 
from 
	cogcc_form5a_formations;

select 
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Fresh water used in treatment (bbl', 2), E'\n', 1)), '\s\s+'))[1] as fresh_water_used 
from 
	cogcc_form5a_formations;

update cogcc_form5a_formations set fresh_water_used = (regexp_split_to_array(trim(split_part(split_part(formation_text, 'Fresh water used in treatment (bbl', 2), E'\n', 1)), '\s\s+'))[1] where cogcc_form5a_document_id > 9408;


--Flowback volume recovered (bbl):
select distinct
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Flowback volume recovered', 2), E'\n', 1)), '\s\s+'))[1] as flowback_recovered 
from 
	cogcc_form5a_formations;

select 
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Flowback volume recovered (bbl):', 2), E'\n', 1)), '\s\s+'))[1] as flowback_recovered 
from 
	cogcc_form5a_formations;

update cogcc_form5a_formations set flowback_recovered = (regexp_split_to_array(trim(split_part(split_part(formation_text, 'Flowback volume recovered (bbl):', 2), E'\n', 1)), '\s\s+'))[1] where cogcc_form5a_document_id > 9408;


--Disposition method for flowback:
select distinct
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Disposition method for flowback', 2), E'\n', 1)), '\s\s+'))[1] as flowback_disposition 
from 
	cogcc_form5a_formations;

select 
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Disposition method for flowback:', 2), E'\n', 1)), '\s\s+'))[1] as flowback_disposition 
from 
	cogcc_form5a_formations;

update cogcc_form5a_formations set flowback_disposition = (regexp_split_to_array(trim(split_part(split_part(formation_text, 'Disposition method for flowback:', 2), E'\n', 1)), '\s\s+'))[1] where cogcc_form5a_document_id > 9408;


--Number of staged intervals:
select distinct
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Number of staged intervals:', 2), E'\n', 1)), '\s\s+'))[1] as staged_intervals 
from 
	cogcc_form5a_formations;

update cogcc_form5a_formations set staged_intervals = (regexp_split_to_array(trim(split_part(split_part(formation_text, 'Number of staged intervals:', 2), E'\n', 1)), '\s\s+'))[1] where cogcc_form5a_document_id > 9408;


update 
	cogcc_form5a_formations 
set 
	total_fluid_used = regexp_replace(total_fluid_used, '[^0-9]', '', 'g'), 
	recycled_water_used = regexp_replace(recycled_water_used, '[^0-9]', '', 'g'), 
	fresh_water_used = regexp_replace(fresh_water_used, '[^0-9]', '', 'g'), 
	flowback_recovered = regexp_replace(flowback_recovered, '[^0-9]', '', 'g'), 
	staged_intervals = regexp_replace(staged_intervals, '[^0-9]', '', 'g') 
where 
	cogcc_form5a_document_id > 9408;

update cogcc_form5a_formations set total_fluid_used = null where trim(total_fluid_used) = '' and cogcc_form5a_document_id > 9408;
update cogcc_form5a_formations set recycled_water_used = null where trim(recycled_water_used) = '' and cogcc_form5a_document_id > 9408;
update cogcc_form5a_formations set fresh_water_used = null where trim(fresh_water_used) = '' and cogcc_form5a_document_id > 9408;
update cogcc_form5a_formations set flowback_recovered = null where trim(flowback_recovered) = '' and cogcc_form5a_document_id > 9408;
update cogcc_form5a_formations set flowback_disposition = null where trim(flowback_disposition) = '';
update cogcc_form5a_formations set staged_intervals = null where trim(staged_intervals) = '' and cogcc_form5a_document_id > 9408;


alter table cogcc_form5a_formations add column water_amounts_reported boolean default false;
update cogcc_form5a_formations set water_amounts_reported = 'true' where formation_text ilike '%Recycled%';

alter table cogcc_form5a_formations adqd column all_water_amounts_null boolean default false;
update cogcc_form5a_formations set all_water_amounts_null = 'true' where total_fluid_used is null and recycled_water_used is null and fresh_water_used is null and flowback_recovered is null and flowback_disposition is null and staged_intervals is null;


alter table cogcc_form5a_documents add column approved_date varchar(10);

select 
	id, well_id, document_id, regexp_replace((regexp_matches(split_part(split_part(report_text, 'Date Received:', 1), 'Document Number:', 2), '\s\d\d/\d\d/\d\d\d\d\s'))[1], '[^0-9/]', '', 'g') as approved_date 
from 
	cogcc_form5a_documents 
where 
	report_text_contains_fluid_amounts is true 
limit 2;

update cogcc_form5a_documents set approved_date = regexp_replace((regexp_matches(split_part(split_part(report_text, 'Date Received:', 1), 'Document Number:', 2), '\s\d\d/\d\d/\d\d\d\d\s'))[1], '[^0-9/]', '', 'g') where report_text_contains_fluid_amounts is true;







select 
	id, 
	total_fluid_used, 
	recycled_water_used, 
	fresh_water_used, 
	flowback_recovered, 
	flowback_disposition
from 
	cogcc_form5a_documents 
where 
	water_amounts_reported is true 
	and all_water_amounts_null is false;


select 
	id, 
	cogcc_form5a_document_id, 
	well_id, 
	formation_name, 
	total_fluid_used, 
	recycled_water_used, 
	fresh_water_used, 
	flowback_recovered, 
	flowback_disposition, 
	staged_intervals 
from 
	cogcc_form5a_formations 
where 
	all_values_null is false;


CREATE TABLE cogcc_form5a_formations_backup AS SELECT * FROM cogcc_form5a_formations;

create table cogcc_form5a_formations (
	id serial primary key not null,
	cogcc_form5a_document_id integer, 
	well_id integer, 
	formation_text text, 
	formation_name varchar(100), 
	end_date varchar(10), 
	total_fluid_used varchar(50), 
	recycled_water_used varchar(50), 
	fresh_water_used varchar(50), 
	produced_water_used varchar(50), 
	flowback_recovered varchar(50), 
	flowback_disposition varchar(50), 
	staged_intervals varchar(50)
);

-- run formation text ruby script

-- Total fluid used in treatment (bbl):
select 
	trim(split_part(split_part(formation_text, 'Total fluid used in treatment (bbl):', 2), E'\n', 1)) as total_fluid_used 
from 
	cogcc_form5a_formations;

update cogcc_form5a_formations set total_fluid_used = trim(split_part(split_part(formation_text, 'Total fluid used in treatment (bbl):', 2), E'\n', 1));


-- Recycled water used in treatment (bbl):
select 
	trim(split_part(split_part(formation_text, 'Recycled water used in treatment (bbl):', 2), E'\n', 1)) as recycled_water_used 
from 
	cogcc_form5a_formations;

update cogcc_form5a_formations set recycled_water_used = trim(split_part(split_part(formation_text, 'Recycled water used in treatment (bbl):', 2), E'\n', 1));


-- Fresh water used in treatment (bbl):
select 
	trim(split_part(split_part(formation_text, 'Fresh water used in treatment (bbl):', 2), E'\n', 1)) as fresh_water_used 
from 
	cogcc_form5a_formations;

update cogcc_form5a_formations set fresh_water_used = trim(split_part(split_part(formation_text, 'Fresh water used in treatment (bbl):', 2), E'\n', 1));


-- Flowback volume recovered (bbl):
select 
	trim(split_part(split_part(formation_text, 'Flowback volume recovered (bbl):', 2), E'\n', 1)) as flowback_recovered 
from 
	cogcc_form5a_formations;

update cogcc_form5a_formations set flowback_recovered = trim(split_part(split_part(formation_text, 'Flowback volume recovered (bbl):', 2), E'\n', 1));


-- Disposition method for flowback:
select 
	trim(split_part(split_part(formation_text, 'Disposition method for flowback:', 2), E'\n', 1)) as flowback_disposition 
from 
	cogcc_form5a_formations;

update cogcc_form5a_formations set flowback_disposition = trim(split_part(split_part(formation_text, 'Disposition method for flowback:', 2), E'\n', 1));


-- Number of staged intervals:
select 
	trim(regexp_replace(split_part(split_part(formation_text, 'Rule 805 green completion techniques were utilized:', 2), 'Reason why green completion not utilized:', 1), '[^0-9]', '', 'g')) as staged_intervals 
from 
	cogcc_form5a_formations
where 
	id not in (6547, 6548);

update cogcc_form5a_formations set staged_intervals = trim(regexp_replace(split_part(split_part(formation_text, 'Rule 805 green completion techniques were utilized:', 2), 'Reason why green completion not utilized:', 1), '[^0-9]', '', 'g')) where id not in (6547, 6548);

update cogcc_form5a_formations set staged_intervals = '14' where id in (6547, 6548);


-- Formation Name:
select 
	trim(split_part(split_part(formation_text, 'FORMATION:', 1), 'Status:', 1)) as formation_name 
from 
	cogcc_form5a_formations
where 
	id <> 5194;

update cogcc_form5a_formations set formation_name = trim(split_part(split_part(formation_text, 'FORMATION:', 1), 'Status:', 1)) where id <> 5194;
update cogcc_form5a_formations set formation_name = 'NIOBRARA-CODELL' where id = 5194;


-- End Date:
select 
	trim(split_part(split_part(formation_text, 'End Date:', 2), E'\n', 1)) as end_date 
from 
	cogcc_form5a_formations;

update cogcc_form5a_formations set end_date = trim(split_part(split_part(formation_text, 'End Date:', 2), E'\n', 1));



--Total Proppant Used
alter table cogcc_form5a_formations add column total_proppant_used varchar(50);
select distinct
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Total proppant used (lbs):', 2), E'\n', 1)), '\s\s+'))[1] as total_proppant_used 
from 
	cogcc_form5a_formations;
update cogcc_form5a_formations set total_proppant_used = (regexp_split_to_array(trim(split_part(split_part(formation_text, 'Total proppant used (lbs):', 2), E'\n', 1)), '\s\s+'))[1];

--First Production Date
alter table cogcc_form5a_formations add column first_production_date varchar(50);
select distinct
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Date of First Production this formation:', 2), E'\n', 1)), '\s\s+'))[1] as first_production_date 
from 
	cogcc_form5a_formations;
update cogcc_form5a_formations set first_production_date = (regexp_split_to_array(trim(split_part(split_part(formation_text, 'Date of First Production this formation:', 2), E'\n', 1)), '\s\s+'))[1];

--Treatment Type
alter table cogcc_form5a_formations add column treatment_type varchar(50);
select distinct
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Treatment Type:', 2), E'\n', 1)), '\s\s+'))[1] as treatment_type 
from 
	cogcc_form5a_formations;
update cogcc_form5a_formations set treatment_type = (regexp_split_to_array(trim(split_part(split_part(formation_text, 'Treatment Type:', 2), E'\n', 1)), '\s\s+'))[1];

--Treatment Summary
alter table cogcc_form5a_formations add column treatment_summary text;
select distinct
	id, case when formation_text ilike '%Provide a brief summary of the formation treatment%' then trim(split_part(split_part(formation_text, 'This formation is commingled with another formation:', 2), 'Provide a brief summary of the formation treatment:', 1)) else trim(split_part(split_part(formation_text, 'This formation is commingled with another formation:', 2), 'Total fluid used in treatment', 1)) end as treatment_summary 
from 
	cogcc_form5a_formations;
update cogcc_form5a_formations set treatment_summary = case when formation_text ilike '%Provide a brief summary of the formation treatment%' then trim(split_part(split_part(formation_text, 'This formation is commingled with another formation:', 2), 'Provide a brief summary of the formation treatment:', 1)) else trim(split_part(split_part(formation_text, 'This formation is commingled with another formation:', 2), 'Total fluid used in treatment', 1)) end;

--Treatment Date
alter table cogcc_form5a_formations add column treatment_date varchar(12);
select distinct
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Treatment Date:', 2), 'Date of First Production this formation:', 1)), '\s\s+'))[1] as first_production_date 
from 
	cogcc_form5a_formations;
update cogcc_form5a_formations set treatment_date = (regexp_split_to_array(trim(split_part(split_part(formation_text, 'Treatment Date:', 2), 'Date of First Production this formation:', 1)), '\s\s+'))[1];
alter table cogcc_form5a_formations alter column treatment_date type date using treatment_date::date;

select distinct
	(regexp_split_to_array(trim(split_part(split_part(formation_text, 'Date Run:', 2), 'Doc', 1)), '\s\s+'))[1] as first_production_date 
from 
	cogcc_form5a_formations 
where treatment_date is null;
update cogcc_form5a_formations set treatment_date = (regexp_split_to_array(trim(split_part(split_part(formation_text, 'Date Run:', 2), 'Doc', 1)), '\s\s+'))[1]::date where treatment_date is null;

update cogcc_form5a_formations set total_proppant_used = null where trim(total_proppant_used) = '';
update cogcc_form5a_formations set first_production_date = null where trim(first_production_date) = '';
	alter table cogcc_form5a_formations alter column first_production_date type date using first_production_date::date;
update cogcc_form5a_formations set treatment_type = null where trim(treatment_type) = '';
update cogcc_form5a_formations set treatment_summary = null where trim(treatment_summary) = '';

update cogcc_form5a_formations set all_values_null = 'true' where total_fluid_used is null and recycled_water_used is null and fresh_water_used is null and produced_water_used is null and flowback_recovered is null and flowback_disposition is null and staged_intervals is null and end_date is null and total_proppant_used is null and first_production_date is null and treatment_type is null and treatment_summary is null and treatment_date is null;


update cogcc_form5a_formations set total_fluid_used = null where trim(total_fluid_used) = '';
update cogcc_form5a_formations set recycled_water_used = null where trim(recycled_water_used) = '';
update cogcc_form5a_formations set fresh_water_used = null where trim(fresh_water_used) = '';
update cogcc_form5a_formations set produced_water_used = null where trim(produced_water_used) = '';
update cogcc_form5a_formations set flowback_recovered = null where trim(flowback_recovered) = '';
update cogcc_form5a_formations set flowback_disposition = null where trim(flowback_disposition) = '';
update cogcc_form5a_formations set staged_intervals = null where trim(staged_intervals) = '';
update cogcc_form5a_formations set formation_name = null where trim(formation_name) = '';
update cogcc_form5a_formations set formation_name = upper(formation_name) where formation_name is not null;
update cogcc_form5a_formations set end_date = null where trim(end_date) = '';


alter table cogcc_form5a_formations add column all_values_null boolean default false;
update cogcc_form5a_formations set all_values_null = 'true' where total_fluid_used is null and recycled_water_used is null and fresh_water_used is null and flowback_recovered is null and flowback_disposition is null and staged_intervals is null;


insert into cogcc_form5a_formations (well_id, formation_name, end_date, total_fluid_used, recycled_water_used, produced_water_used, flowback_recovered, flowback_disposition, staged_intervals)	
select 
	t.well_id, (select formation_name from cogcc_well_completed_intervals where id = t.cogcc_well_completed_interval_id), t.treatment_end_date, t.total_fluid_used, t.recycled_water_used, t.produced_water_used, t.total_flowback_recovered, t.flowback_disposition, t.staged_intervals 
from 
	cogcc_well_formation_treatments t 
where 
	t.fluid_amounts_reported is true;


alter table cogcc_form5a_formations alter column end_date type date using end_date::date;

-- produced water used = fresh water used
update cogcc_form5a_formations set fresh_water_used = produced_water_used where produced_water_used is not null;


update cogcc_form5a_formations set all_values_null = 'false';
update cogcc_form5a_formations set all_values_null = 'true' where total_fluid_used is null and recycled_water_used is null and fresh_water_used is null and flowback_recovered is null and flowback_disposition is null and staged_intervals is null;


-- need to remove dupe formations
select count(*) from cogcc_form5a_formations where end_date is not null and all_values_null is false; -- 12,839

select count(*) from cogcc_form5a_formations where end_date is not null and all_values_null is false and cogcc_form5a_document_id is not null; -- 9,132

select count(*) from cogcc_form5a_formations where end_date is not null and all_values_null is false and cogcc_form5a_document_id is null; -- 3,707


select count(distinct(well_id, formation_name, end_date, total_fluid_used, recycled_water_used, fresh_water_used, flowback_recovered, flowback_disposition, staged_intervals)) from cogcc_form5a_formations where all_values_null is false; -- 6,144

select count(distinct(well_id, formation_name, end_date, total_fluid_used, recycled_water_used, fresh_water_used, flowback_recovered, flowback_disposition, 
staged_intervals)) from cogcc_form5a_formations where end_date is not null and all_values_null is false; -- 6,002

select count(distinct(well_id, formation_name, total_fluid_used, recycled_water_used, fresh_water_used, flowback_recovered, flowback_disposition, staged_intervals)) from cogcc_form5a_formations where end_date is null and all_values_null is false; -- 142

select count(distinct(well_id, formation_name, total_fluid_used, recycled_water_used, fresh_water_used, flowback_recovered, flowback_disposition, staged_intervals)) from cogcc_form5a_formations where all_values_null is false; -- 6,109


select distinct
	well_id, 
	formation_name, 
	end_date, 
	total_fluid_used, 
	recycled_water_used, 
	fresh_water_used, 
	flowback_recovered, 
	flowback_disposition, 
	staged_intervals 
from 
	cogcc_form5a_formations 
where 
	all_values_null is false 
	and end_date is not null;

COPY (select w.attrib_1 as well_api_number, case w.api_county when '045' then 'Garfield' when '123' then 'Weld' end as county, w.attrib_3 as well_number_name, w.facility_s as well_status, w.attrib_2 as operator_name, w.lat as latitude, w.long as longitude, w.field_name, t.formation_name, t.end_date, t.total_fluid_used, t.recycled_water_used, t.fresh_water_used, t.flowback_recovered, t.flowback_disposition, t.staged_intervals 
from cogcc_well_surface_locations w 
inner join (select distinct well_id, formation_name, end_date, total_fluid_used, recycled_water_used, fresh_water_used, flowback_recovered, flowback_disposition, staged_intervals 
	from cogcc_form5a_formations where all_values_null is false and end_date is not null) as t on t.well_id = w.well_id
where w.facility_s <> 'IJ' and w.api_county in ('045','123')
order by county desc, well_api_number) TO '/Users/troyburke/Data/CSU/cogcc_form5a_water_amounts_updated.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, case w.api_county when '045' then 'Garfield' when '123' then 'Weld' end as county, w.attrib_3 as well_number_name, w.facility_s as well_status, w.attrib_2 as operator_name, w.lat as latitude, w.long as longitude, w.field_name, t.formation_name, t.end_date, t.total_fluid_used, t.recycled_water_used, t.fresh_water_used, t.flowback_recovered, t.flowback_disposition, t.staged_intervals 
from cogcc_well_surface_locations w 
inner join (select distinct well_id, formation_name, end_date, total_fluid_used, recycled_water_used, fresh_water_used, flowback_recovered, flowback_disposition, staged_intervals 
	from cogcc_form5a_formations where cogcc_form5a_document_id is not null and all_values_null is false and end_date is not null) as t on t.well_id = w.well_id
where w.facility_s <> 'IJ' and w.api_county in ('045','123')
order by county desc, well_api_number) TO '/Users/troyburke/Data/CSU/cogcc_form5a_water_amounts_pdf_only.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, case w.api_county when '045' then 'Garfield' when '123' then 'Weld' end as county, w.attrib_3 as well_number_name, w.facility_s as well_status, w.attrib_2 as operator_name, w.lat as latitude, w.long as longitude, w.field_name, t.formation_name, t.end_date, t.total_fluid_used, t.recycled_water_used, t.fresh_water_used, t.flowback_recovered, t.flowback_disposition, t.staged_intervals 
from cogcc_well_surface_locations w 
inner join (select distinct well_id, formation_name, end_date, total_fluid_used, recycled_water_used, fresh_water_used, flowback_recovered, flowback_disposition, staged_intervals 
	from cogcc_form5a_formations w where w.all_values_null is false and end_date is not null and w.cogcc_form5a_document_id is null and w.well_id not in (select distinct d.well_id from cogcc_form5a_formations d where d.all_values_null is false and end_date is not null and d.cogcc_form5a_document_id is not null)) as t on t.well_id = w.well_id
where w.facility_s <> 'IJ' and w.api_county in ('045','123')
order by county desc, well_api_number) TO '/Users/troyburke/Data/CSU/cogcc_form5a_water_amounts_add_wells.csv' WITH CSV HEADER;

select distinct well_id, 
formation_name, 
end_date, 
total_fluid_used, 
recycled_water_used, 
fresh_water_used, 
flowback_recovered, 
flowback_disposition, 
staged_intervals from cogcc_form5a_formations w where w.all_values_null is false and end_date is not null and w.cogcc_form5a_document_id is null and w.well_id not in (select distinct d.well_id from cogcc_form5a_formations d where d.all_values_null is false and end_date is not null and d.cogcc_form5a_document_id is not null);





COPY (select w.attrib_1 as well_api_number, case w.api_county when '045' then 'Garfield' when '123' then 'Weld' end as county, w.attrib_3 as well_number_name, w.facility_s as well_status, w.attrib_2 as operator_name, w.lat as latitude, w.long as longitude, w.field_name, t.formation_name, t.treatment_type, t.end_date, t.first_production_date, t.total_proppant_used, t.total_fluid_used, t.recycled_water_used, t.fresh_water_used, t.flowback_recovered, t.flowback_disposition, t.staged_intervals, t.treatment_summary 
from cogcc_well_surface_locations w 
inner join (select distinct well_id, formation_name, end_date, total_fluid_used, recycled_water_used, fresh_water_used, flowback_recovered, flowback_disposition, staged_intervals, treatment_type, first_production_date, total_proppant_used, treatment_summary 
	from cogcc_form5a_formations where all_values_null is false and end_date is not null and end_date > '2009-12-31') as t on t.well_id = w.well_id
where w.facility_s <> 'IJ' and w.api_county in ('045','123')
order by county desc, well_api_number) TO '/Users/troyburke/Data/CSU/cogcc_form5a_water_amounts_updated_2015.csv' WITH CSV HEADER;


COPY (select w.attrib_1 as well_api_number, case w.api_county when '045' then 'Garfield' when '123' then 'Weld' end as county, w.attrib_3 as well_number_name, w.facility_s as well_status, w.attrib_2 as operator_name, w.lat as latitude, w.long as longitude, w.field_name, t.approved_date, t.formation_name, t.end_date, t.total_fluid_used, t.recycled_water_used, t.fresh_water_used, t.flowback_recovered, t.flowback_disposition, t.staged_intervals, 'http://ogccweblink.state.co.us/DownloadDocument.aspx?DocumentId=' || t.document_id as download_url 
from cogcc_well_surface_locations w 
inner join (select distinct well_id, approved_date, formation_name, end_date, total_fluid_used, recycled_water_used, fresh_water_used, flowback_recovered, flowback_disposition, staged_intervals, document_id 
	from cogcc_form5a_formation_texts where all_values_null is false) as t on t.well_id = w.well_id
where w.facility_s <> 'IJ' and w.api_county in ('045','123')
order by county desc, well_api_number) TO '/Users/troyburke/Data/CSU/cogcc_form5a_water_amounts_approved.csv' WITH CSV HEADER;





alter table cogcc_form5a_documents add column approved_date varchar(10);

select 
	id, well_id, document_id, regexp_replace((regexp_matches(split_part(split_part(report_text, 'Date Received:', 1), 'Document Number:', 2), '\s\d\d/\d\d/\d\d\d\d\s'))[1], '[^0-9/]', '', 'g') as approved_date 
from 
	cogcc_form5a_documents 
where 
	report_text_contains_fluid_amounts is true 
limit 2;

update cogcc_form5a_documents set approved_date = regexp_replace((regexp_matches(split_part(split_part(report_text, 'Date Received:', 1), 'Document Number:', 2), '\s\d\d/\d\d/\d\d\d\d\s'))[1], '[^0-9/]', '', 'g') where report_text_contains_fluid_amounts is true;


create table cogcc_form5a_formation_texts (
	id serial primary key not null,
	cogcc_form5a_document_id integer, 
	well_id integer, 
	document_id integer, 
	formation_text text, 
	formation_name varchar(100), 
	end_date varchar(10), 
	approved_date varchar(10), 
	total_fluid_used varchar(50), 
	recycled_water_used varchar(50), 
	fresh_water_used varchar(50), 
	flowback_recovered varchar(50), 
	flowback_disposition varchar(50), 
	staged_intervals varchar(50)
);



-- Total fluid used in treatment (bbl):
select 
	trim(split_part(split_part(formation_text, 'Total fluid used in treatment (bbl):', 2), E'\n', 1)) as total_fluid_used 
from 
	cogcc_form5a_formation_texts;

update cogcc_form5a_formation_texts set total_fluid_used = trim(split_part(split_part(formation_text, 'Total fluid used in treatment (bbl):', 2), E'\n', 1));


-- Recycled water used in treatment (bbl):
select 
	trim(split_part(split_part(formation_text, 'Recycled water used in treatment (bbl):', 2), E'\n', 1)) as recycled_water_used 
from 
	cogcc_form5a_formation_texts;

update cogcc_form5a_formation_texts set recycled_water_used = trim(split_part(split_part(formation_text, 'Recycled water used in treatment (bbl):', 2), E'\n', 1));


-- Fresh water used in treatment (bbl):
select 
	trim(split_part(split_part(formation_text, 'Fresh water used in treatment (bbl):', 2), E'\n', 1)) as fresh_water_used 
from 
	cogcc_form5a_formation_texts;

update cogcc_form5a_formation_texts set fresh_water_used = trim(split_part(split_part(formation_text, 'Fresh water used in treatment (bbl):', 2), E'\n', 1));


-- Flowback volume recovered (bbl):
select 
	trim(split_part(split_part(formation_text, 'Flowback volume recovered (bbl):', 2), E'\n', 1)) as flowback_recovered 
from 
	cogcc_form5a_formation_texts;

update cogcc_form5a_formation_texts set flowback_recovered = trim(split_part(split_part(formation_text, 'Flowback volume recovered (bbl):', 2), E'\n', 1));


-- Disposition method for flowback:
select 
	trim(split_part(split_part(formation_text, 'Disposition method for flowback:', 2), E'\n', 1)) as flowback_disposition 
from 
	cogcc_form5a_formation_texts;

update cogcc_form5a_formation_texts set flowback_disposition = trim(split_part(split_part(formation_text, 'Disposition method for flowback:', 2), E'\n', 1));


-- Number of staged intervals:
select 
	id, trim(regexp_replace(split_part(split_part(formation_text, 'Rule 805 green completion techniques were utilized:', 2), 'Reason why green completion not utilized:', 1), '[^0-9]', '', 'g')) as staged_intervals 
from 
	cogcc_form5a_formation_texts
where 
	id <> 2907;

update cogcc_form5a_formation_texts set staged_intervals = trim(regexp_replace(split_part(split_part(formation_text, 'Rule 805 green completion techniques were utilized:', 2), 'Reason why green completion not utilized:', 1), '[^0-9]', '', 'g')) where id <> 2907;

update cogcc_form5a_formation_texts set staged_intervals = '14' where id = 2907;


-- Formation Name:
select 
	id, trim(split_part(split_part(formation_text, 'FORMATION:', 1), 'Status:', 1)) as formation_name 
from 
	cogcc_form5a_formation_texts
where 
	id <> 2134;

update cogcc_form5a_formation_texts set formation_name = trim(split_part(split_part(formation_text, 'FORMATION:', 1), 'Status:', 1)) where id <> 2134;
delete from cogcc_form5a_formation_texts where id = 2134;


-- End Date:
select 
	trim(split_part(split_part(formation_text, 'End Date:', 2), E'\n', 1)) as end_date 
from 
	cogcc_form5a_formation_texts;

update cogcc_form5a_formation_texts set end_date = trim(split_part(split_part(formation_text, 'End Date:', 2), E'\n', 1));


update cogcc_form5a_formation_texts set total_fluid_used = null where trim(total_fluid_used) = '';
update cogcc_form5a_formation_texts set recycled_water_used = null where trim(recycled_water_used) = '';
update cogcc_form5a_formation_texts set fresh_water_used = null where trim(fresh_water_used) = '';
update cogcc_form5a_formation_texts set flowback_recovered = null where trim(flowback_recovered) = '';
update cogcc_form5a_formation_texts set flowback_disposition = null where trim(flowback_disposition) = '';
update cogcc_form5a_formation_texts set staged_intervals = null where trim(staged_intervals) = '';
update cogcc_form5a_formation_texts set formation_name = null where trim(formation_name) = '';
update cogcc_form5a_formation_texts set formation_name = upper(formation_name) where formation_name is not null;
update cogcc_form5a_formation_texts set end_date = null where trim(end_date) = '';
alter table cogcc_form5a_formation_texts alter column end_date type date using end_date::date;
alter table cogcc_form5a_formation_texts alter column approved_date type date using approved_date::date;

alter table cogcc_form5a_formation_texts add column all_values_null boolean default false;
update cogcc_form5a_formation_texts set all_values_null = 'true' where total_fluid_used is null and recycled_water_used is null and fresh_water_used is null and flowback_recovered is null and flowback_disposition is null and staged_intervals is null;


select count(*) from cogcc_form5a_formation_texts where all_values_null is false; -- 4,786

select count(distinct(well_id, formation_name, end_date, total_fluid_used, recycled_water_used, fresh_water_used, flowback_recovered, flowback_disposition, staged_intervals)) from cogcc_form5a_formation_texts where all_values_null is false; -- 4,634

select distinct
	well_id, 
	approved_date, 
	formation_name, 
	end_date, 
	total_fluid_used, 
	recycled_water_used, 
	fresh_water_used, 
	flowback_recovered, 
	flowback_disposition, 
	staged_intervals,
	document_id 
from 
	cogcc_form5a_formation_texts 
where 
	all_values_null is false;

COPY (select w.attrib_1 as well_api_number, case w.api_county when '045' then 'Garfield' when '123' then 'Weld' end as county, w.attrib_3 as well_number_name, w.facility_s as well_status, w.attrib_2 as operator_name, w.lat as latitude, w.long as longitude, w.field_name, t.approved_date, t.formation_name, t.end_date, t.total_fluid_used, t.recycled_water_used, t.fresh_water_used, t.flowback_recovered, t.flowback_disposition, t.staged_intervals, 'http://ogccweblink.state.co.us/DownloadDocument.aspx?DocumentId=' || t.document_id as download_url 
from cogcc_well_surface_locations w 
inner join (select distinct well_id, approved_date, formation_name, end_date, total_fluid_used, recycled_water_used, fresh_water_used, flowback_recovered, flowback_disposition, staged_intervals, document_id 
	from cogcc_form5a_formation_texts where all_values_null is false) as t on t.well_id = w.well_id
where w.facility_s <> 'IJ' and w.api_county in ('045','123')
order by county desc, well_api_number) TO '/Users/troyburke/Data/CSU/cogcc_form5a_water_amounts_approved.csv' WITH CSV HEADER;


COPY (select w.attrib_1 as well_api_number, case w.api_county when '045' then 'Garfield' when '123' then 'Weld' end as county, w.attrib_3 as well_number_name, w.facility_s as well_status, w.attrib_2 as operator_name, w.lat as latitude, w.long as longitude, w.field_name, (select formation_name from cogcc_well_completed_intervals where id = t.cogcc_well_completed_interval_id) as formation_name, t.total_fluid_used, t.recycled_water_used, t.produced_water_used as fresh_water_used, t.total_flowback_recovered, t.flowback_disposition, t.staged_intervals, t.treatment_end_date from cogcc_well_surface_locations w inner join cogcc_well_formation_treatments t on w.well_id = t.well_id where  w.facility_s <> 'IJ' and w.api_county in ('045','123') and t.fluid_amounts_reported is true and w.well_id not in (select distinct well_id from cogcc_form5a_formation_texts where all_values_null is false) order by county desc, well_api_number) TO '/Users/troyburke/Data/CSU/additional_cogcc_well_treatments.csv' WITH CSV HEADER;

COPY (select w.attrib_1 as well_api_number, case w.api_county when '045' then 'Garfield' when '123' then 'Weld' end as county, w.attrib_3 as well_number_name, w.facility_s as well_status, w.attrib_2 as operator_name, w.lat as latitude, w.long as longitude, w.field_name, (select formation_name from cogcc_well_completed_intervals where id = t.cogcc_well_completed_interval_id) as formation_name, t.total_fluid_used, t.recycled_water_used, t.produced_water_used as fresh_water_used, t.total_flowback_recovered, t.flowback_disposition, t.staged_intervals, t.treatment_end_date from cogcc_well_surface_locations w inner join cogcc_well_formation_treatments t on w.well_id = t.well_id where w.facility_s <> 'IJ' and w.api_county in ('045','123') and t.fluid_amounts_reported is true order by county desc, well_api_number) TO '/Users/troyburke/Data/CSU/cogcc_well_treatments.csv' WITH CSV HEADER;


COPY (select w.attrib_1 as well_api_number, case w.api_county when '045' then 'Garfield' when '123' then 'Weld' end as county, w.attrib_3 as well_number_name, w.facility_s as well_status, w.attrib_2 as operator_name, w.lat as latitude, w.long as longitude, w.field_name, i.formation_code, i.formation_name, i.first_production_date, i.perf_bottom, i.perf_top, i.perf_holes_number, i.perf_hole_size, t.treatment_date, t.treatment_end_date, t.treatment_type, t.total_fluid_used, t.recycled_water_used, t.produced_water_used as fresh_water_used, t.total_flowback_recovered, t.flowback_disposition, t.staged_intervals, t.total_proppant_used, t.treatment_summary from cogcc_well_surface_locations w inner join cogcc_well_completed_intervals i on w.well_id = i.well_id inner join cogcc_well_formation_treatments t on i.id = t.cogcc_well_completed_interval_id where w.facility_s <> 'IJ' and w.api_county in ('045','123') and t.fluid_amounts_reported is true order by county desc, well_api_number) TO '/Users/troyburke/Data/CSU/cogcc_well_treatments_updated.csv' WITH CSV HEADER;


create table form5a_totals (
	well_api_number varchar(12), 
	county_name varchar(20), 
	well_number_name varchar(100), 
	well_status varchar(2), 
	operator_name varchar(100), 
	latitude double precision, 
	longitude double precision, 
	field_name varchar(100), 
	formation_name varchar(100), 
	total_fluid_used integer, 
	recycled_water_used integer, 
	fresh_water_used integer, 
	flowback_recovered integer, 
	flowback_disposition varchar(20), 
	staged_intervals integer, 
	end_date date, 
	approved_date date, 
	download_url varchar(250)
);
copy form5a_totals from '/Users/troyburke/Data/CSU/form_5a_qc.csv' (format csv, delimiter ',', null '');


select 
	well_api_number, county_name, well_number_name, well_status, operator_name, latitude, longitude, field_name,
	sum(total_fluid_used) as total_fluid_used, 
	sum(recycled_water_used) as recycled_water_used, 
	sum(fresh_water_used) as fresh_water_used, 
	sum(flowback_recovered) as flowback_recovered, 
	sum(staged_intervals) as staged_intervals, 
	flowback_disposition
from 
	form5a_totals 
group by 
	well_api_number, county_name, well_number_name, well_status, operator_name, latitude, longitude, field_name, flowback_disposition
order by 
	county_name desc, 
	well_api_number;

COPY (select well_api_number, county_name, well_number_name, well_status, operator_name, latitude, longitude, field_name,
	sum(total_fluid_used) as total_fluid_used, 
	sum(recycled_water_used) as recycled_water_used, 
	sum(fresh_water_used) as fresh_water_used, 
	sum(flowback_recovered) as flowback_recovered, 
	flowback_disposition, approved_date, 
	sum(staged_intervals) as staged_intervals 
from form5a_totals 
group by well_api_number, county_name, well_number_name, well_status, operator_name, latitude, longitude, field_name, flowback_disposition, approved_date 
order by county_name desc, well_api_number) TO '/Users/troyburke/Data/CSU/form5a_water_amounts_by_well.csv' WITH CSV HEADER;




insert into cogcc_form5a_formations (well_id, formation_name, end_date, total_fluid_used, recycled_water_used, produced_water_used, flowback_recovered, flowback_disposition, staged_intervals)	
select 
	t.well_id, (select formation_name from cogcc_well_completed_intervals where id = t.cogcc_well_completed_interval_id), t.treatment_end_date, t.total_fluid_used, t.recycled_water_used, t.produced_water_used, t.total_flowback_recovered, t.flowback_disposition, t.staged_intervals 
from 
	cogcc_well_formation_treatments t 
where 
	t.fluid_amounts_reported is true;








