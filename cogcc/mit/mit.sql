create table cogcc_mechanical_integrity_tests (
	id serial primary key not null, 
	well_id integer, 
	document_number integer, 
	facility_id integer, 
	facility_status varchar(2), 
	test_date varchar(12), 
	approved_date varchar(13), 
	last_approved varchar(13), 
	test_type varchar(30), 
	repair_type varchar(50), 
	repair_description varchar(1000), 
	formation_zones varchar(100), 
	perforation_interval varchar(50), 
	open_hole_interval varchar(50), 
	plug_depth varchar(20), 
	tubing_size varchar(10), 
	tubing_depth varchar(10), 
	top_packer_depth varchar(10), 
	multiple_packers varchar(10), 
	ten_min_case_psi varchar(10), 
	five_min_case_psi varchar(10), 
	case_before_psi varchar(10), 
	final_case_psi varchar(10), 
	final_tube_psi varchar(10), 
	initial_tube_psi varchar(10),  
	loss_gain_psi varchar(10), 
	start_case_psi varchar(10)
);

-- temp columnn to store value being converted (in case we mess up)
alter table cogcc_mechanical_integrity_tests add column fixer varchar(5);

-- alter five_min_case_psi to integer
update cogcc_mechanical_integrity_tests set fixer = five_min_case_psi;
update cogcc_mechanical_integrity_tests set five_min_case_psi = regexp_replace(five_min_case_psi, '[^0-9]', '');
update cogcc_mechanical_integrity_tests set five_min_case_psi = null where five_min_case_psi = '';
alter table cogcc_mechanical_integrity_tests alter column five_min_case_psi type integer using five_min_case_psi::integer;

-- alter ten_min_case_psi to integer
update cogcc_mechanical_integrity_tests set fixer = ten_min_case_psi;
update cogcc_mechanical_integrity_tests set ten_min_case_psi = regexp_replace(ten_min_case_psi, '[^0-9]', '');
update cogcc_mechanical_integrity_tests set ten_min_case_psi = null where ten_min_case_psi = '';
alter table cogcc_mechanical_integrity_tests alter column ten_min_case_psi type integer using ten_min_case_psi::integer;

-- alter final_case_psi to integer
update cogcc_mechanical_integrity_tests set fixer = final_case_psi;
update cogcc_mechanical_integrity_tests set final_case_psi = regexp_replace(final_case_psi, '[^0-9]', '');
update cogcc_mechanical_integrity_tests set final_case_psi = null where final_case_psi = '';
alter table cogcc_mechanical_integrity_tests alter column final_case_psi type integer using final_case_psi::integer;

-- alter start_case_psi to integer
update cogcc_mechanical_integrity_tests set fixer = start_case_psi;
update cogcc_mechanical_integrity_tests set start_case_psi = regexp_replace(start_case_psi, '[^0-9]', '');
update cogcc_mechanical_integrity_tests set start_case_psi = null where start_case_psi = '';
alter table cogcc_mechanical_integrity_tests alter column start_case_psi type integer using start_case_psi::integer;

-- alter case_before_psi to integer
update cogcc_mechanical_integrity_tests set fixer = case_before_psi;
update cogcc_mechanical_integrity_tests set case_before_psi = regexp_replace(case_before_psi, '[^0-9-]', '');
update cogcc_mechanical_integrity_tests set case_before_psi = null where case_before_psi = '';
alter table cogcc_mechanical_integrity_tests alter column case_before_psi type integer using case_before_psi::integer;

-- alter final_tube_psi to integer
update cogcc_mechanical_integrity_tests set fixer = final_tube_psi;
update cogcc_mechanical_integrity_tests set final_tube_psi = regexp_replace(final_tube_psi, '[^0-9-]', '');
update cogcc_mechanical_integrity_tests set final_tube_psi = null where final_tube_psi = '';
alter table cogcc_mechanical_integrity_tests alter column final_tube_psi type integer using final_tube_psi::integer;

-- alter initial_tube_psi to integer
update cogcc_mechanical_integrity_tests set fixer = initial_tube_psi;
update cogcc_mechanical_integrity_tests set initial_tube_psi = regexp_replace(initial_tube_psi, '[^0-9-]', '');
update cogcc_mechanical_integrity_tests set initial_tube_psi = null where initial_tube_psi = '';
alter table cogcc_mechanical_integrity_tests alter column initial_tube_psi type integer using initial_tube_psi::integer;

-- alter loss_gain_psi to integer
update cogcc_mechanical_integrity_tests set fixer = loss_gain_psi;
update cogcc_mechanical_integrity_tests set loss_gain_psi = regexp_replace(loss_gain_psi, '[^0-9-]', '');
update cogcc_mechanical_integrity_tests set loss_gain_psi = null where loss_gain_psi = '';
alter table cogcc_mechanical_integrity_tests alter column loss_gain_psi type integer using loss_gain_psi::integer;



-- summary queries

-- record count = 5,703
select count(*) from cogcc_mechanical_integrity_tests;

-- distinct document count = 5,699
select count(distinct(document_number)) from cogcc_mechanical_integrity_tests;

-- distinct well count = 2,870
select count(distinct(well_id)) from cogcc_mechanical_integrity_tests;

-- find duplicate documents
select count(document_number) as doc_count, document_number from cogcc_mechanical_integrity_tests group by document_number order by doc_count desc;

-- forgot to add id (primary key) column, let's add one after the fact
ALTER TABLE cogcc_mechanical_integrity_tests ADD COLUMN id SERIAL;
UPDATE cogcc_mechanical_integrity_tests SET id = nextval(pg_get_serial_sequence('cogcc_mechanical_integrity_tests','id'));
ALTER TABLE cogcc_mechanical_integrity_tests ADD PRIMARY KEY (id);

-- delete duplicate document_numbers: 200405260, 1801105
delete from cogcc_mechanical_integrity_tests where id in (8908,11401,11402,11403);

-- clean up facility_status
alter table cogcc_mechanical_integrity_tests alter column facility_status type varchar(2) using facility_status::varchar;
update cogcc_mechanical_integrity_tests set fixer = facility_status;
update cogcc_mechanical_integrity_tests set facility_status = regexp_replace(facility_status, '[^A-Z]', '');
update cogcc_mechanical_integrity_tests set facility_status = null where facility_status = '';

-- clean up perforation_interval
update cogcc_mechanical_integrity_tests set perforation_interval = null where perforation_interval = '';

-- clean up open_hole_interval
update cogcc_mechanical_integrity_tests set open_hole_interval = null where open_hole_interval = '';

-- clean up plug_depth and change to integer
select * from cogcc_mechanical_integrity_tests where plug_depth ilike '%.%';
update cogcc_mechanical_integrity_tests set plug_depth = '6259' where id = 11245;
update cogcc_mechanical_integrity_tests set plug_depth = '6970' where id = 11253;
update cogcc_mechanical_integrity_tests set plug_depth = '6498' where id = 10297;
update cogcc_mechanical_integrity_tests set plug_depth = '7393' where id = 11256;
update cogcc_mechanical_integrity_tests set fixer = plug_depth;
update cogcc_mechanical_integrity_tests set plug_depth = regexp_replace(plug_depth, '[^0-9]', '');
update cogcc_mechanical_integrity_tests set plug_depth = null where plug_depth = '';

-- clean up tubing_size
update cogcc_mechanical_integrity_tests set tubing_size = null where tubing_size = '';

-- clean up multiple_packers
update cogcc_mechanical_integrity_tests set multiple_packers = null where multiple_packers = '';
alter table cogcc_mechanical_integrity_tests alter column multiple_packers type boolean using multiple_packers::boolean;

-- clean up tubing_depth
update cogcc_mechanical_integrity_tests set fixer = tubing_depth;
update cogcc_mechanical_integrity_tests set tubing_depth = null where tubing_depth = '';
update cogcc_mechanical_integrity_tests set tubing_depth = regexp_replace(tubing_depth, '[^0-9.]', '');
update cogcc_mechanical_integrity_tests set tubing_depth = round(tubing_depth::real)::varchar where tubing_depth ilike '%.%';
update cogcc_mechanical_integrity_tests set tubing_depth = regexp_replace(tubing_depth, '[^0-9]', '');
alter table cogcc_mechanical_integrity_tests alter column tubing_depth type integer using tubing_depth::integer;

-- clean up top_packer_depth
update cogcc_mechanical_integrity_tests set fixer = top_packer_depth;
update cogcc_mechanical_integrity_tests set top_packer_depth = null where top_packer_depth = '';
update cogcc_mechanical_integrity_tests set top_packer_depth = regexp_replace(top_packer_depth, '[^0-9.]', '');
update cogcc_mechanical_integrity_tests set top_packer_depth = round(top_packer_depth::real)::varchar where top_packer_depth ilike '%.%';
update cogcc_mechanical_integrity_tests set top_packer_depth = regexp_replace(top_packer_depth, '[^0-9]', '');
--alter table cogcc_mechanical_integrity_tests alter column top_packer_depth type integer using top_packer_depth::integer;


-- clean up channel_test
alter table cogcc_mechanical_integrity_tests drop column channel_test;


-- test criteria

-- min 300 psi differential between tubing pressure and casing-tubing annulus pressure
-- a drop or increase greater than 10% during 15 min is a failure
select well_id, document_number, facility_id, facility_status, test_date, test_type, formation_zones, ten_min_case_psi, five_min_case_psi, case_before_psi, final_case_psi, final_tube_psi, initial_tube_psi, loss_gain_psi, start_case_psi 
from cogcc_mechanical_integrity_tests
;

select well_id, document_number, facility_id, facility_status, test_date, test_type, formation_zones, ten_min_case_psi, five_min_case_psi, case_before_psi, final_case_psi, final_tube_psi, initial_tube_psi, loss_gain_psi, start_case_psi from cogcc_mechanical_integrity_tests where loss_gain_psi <> 0 order by loss_gain_psi desc;


select * from cogcc_mechanical_integrity_tests where ten_min_case_psi > 0 and abs(loss_gain_psi/ten_min_case_psi) > .1;

COPY(
select distinct 
	w.attrib_1 as api_number, w.attrib_3 as well_number_name, w.attrib_2 as operator_name, w.operator_n as operator_number, w.spud_date, w.completion_date, w.field_code, w.field_name, w.lat, w.long, m.document_number, m.facility_id, m.facility_status, m.test_date, m.approved_date, m.last_approved, m.test_type, m.repair_type, m.repair_description, m.formation_zones, m.perforation_interval, m.open_hole_interval, m.plug_depth, m.tubing_size, m.tubing_depth, m.top_packer_depth, m.multiple_packers, m.ten_min_case_psi, m.five_min_case_psi, m.case_before_psi, m.final_case_psi, m.final_tube_psi, m.initial_tube_psi, m.loss_gain_psi, m.start_case_psi 
from 
	cogcc_mechanical_integrity_tests m 
inner join 
	cogcc_wells w on m.well_id = w.well_id 
where 
	m.facility_status = 'SI' 
order by 
	api_number, m.approved_date desc
) TO '/Users/troyburke/Data/cogcc/shut_in_mits.csv' WITH CSV HEADER;


COPY(
select distinct 
	w.attrib_1 as api_number, w.attrib_3 as well_number_name, w.facility_s as current_well_status, w.attrib_2 as operator_name, w.operator_n as operator_number, w.spud_date, w.completion_date, w.field_code, w.field_name, w.lat, w.long, m.document_number, m.facility_id, m.facility_status, m.test_date, m.approved_date, m.last_approved, m.test_type, m.repair_type, m.repair_description, m.formation_zones, m.perforation_interval, m.open_hole_interval, m.plug_depth, m.tubing_size, m.tubing_depth, m.top_packer_depth, m.multiple_packers, m.ten_min_case_psi, m.five_min_case_psi, m.case_before_psi, m.final_case_psi, m.final_tube_psi, m.initial_tube_psi, m.loss_gain_psi, m.start_case_psi 
from 
	cogcc_mechanical_integrity_tests m 
inner join 
	cogcc_wells w on m.well_id = w.well_id 
order by 
	api_number, m.approved_date desc
) TO '/Users/troyburke/Data/cogcc/cogcc_mits.csv' WITH CSV HEADER;

COPY(select distinct(upper(document_name)) from cogcc_document_names where document_name ilike '%mechanical integrity%' order by upper(document_name)) TO '/Users/troyburke/Data/cogcc/mit_document_names.csv' WITH CSV HEADER;
