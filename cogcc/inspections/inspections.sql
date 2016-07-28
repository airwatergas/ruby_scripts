create table cogcc_inspections (
	id serial not null primary key,
	inspection_date varchar(12), 
	document_number integer, 
	document_id integer, 
	location_id integer, 
	api_number varchar(14), 
	inspection_type varchar(2), 
	status_code varchar(2), 
	overall_inspection_status varchar(30),
	overall_ir varchar(4), 
	overall_fr varchar(4), 
	reclamation varchar(1), 
	p_and_a varchar(1), 
	violation varchar(1), 
	created_at date, 
	updated_at date
);

alter table cogcc_inspections add column insp_year smallint;
alter table cogcc_inspections add column insp_month smallint;
alter table cogcc_inspections add column details_scraped boolean not null default false;

update cogcc_inspections set insp_year = right(trim(inspection_date),4)::smallint;
update cogcc_inspections set insp_month = left(trim(inspection_date),2)::smallint;
update cogcc_inspections set details_scraped = 'true' where location_id is not null;

alter table cogcc_inspections alter inspection_date type date using inspection_date::date;
alter table cogcc_inspections alter api_number type varchar(9);
alter table cogcc_inspections alter overall_inspection_status type varchar(15);


COPY (select id, inspection_date, insp_year, insp_month, document_number, document_id, location_id, api_number, inspection_type, status_code, overall_inspection_status, overall_ir, overall_fr, reclamation, p_and_a, violation, created_at, updated_at from cogcc_inspections order by insp_year, insp_month) TO '/Users/troyburke/Projects/ruby/cogcc/inspections/cogcc_inspections.sql' WITH CSV;

create table inspections (
	id serial not null primary key,
	inspection_date date, 
	insp_year smallint, 
	insp_month smallint, 
	document_number integer, 
	document_id integer, 
	location_id integer, 
	api_number varchar(9), 
	inspection_type varchar(2), 
	status_code varchar(2), 
	overall_inspection_status varchar(15),
	overall_ir varchar(4), 
	overall_fr varchar(4), 
	reclamation varchar(1), 
	p_and_a varchar(1), 
	violation varchar(1), 
	created_at date, 
	updated_at date
);

copy inspections from '/Users/troyburke/Projects/ruby/cogcc/inspections/cogcc_inspections.sql' (format csv, delimiter ',', null '');



create table cogcc_inspection_details (
	id serial not null primary key,
	cogcc_inspection_id integer, 
	api_number varchar(16), 
	facility_location_id varchar(16), 
	name varchar(100), 
	location varchar(100),
	lat varchar(30), 
	long varchar(30), 
	operator_number varchar(30), 
	operator_name varchar(100), 
	inspection_date varchar(12), 
	inspector varchar(100), 
	inspection_was varchar(100), 
	insp_type varchar(10), 
	insp_stat varchar(10),
	reclamation varchar(10), 
	p_and_a varchar(4), 
	brhd_pressure varchar(10), 
	inj_pressure varchar(10), 
	t_c_ann_pressure varchar(10), 
	uic_violation_type varchar(50), 
	violation varchar(10), 
	noav_sent varchar(10), 
	date_corrective_action_due varchar(20), 
	date_remedied varchar(20), 
	pit_type varchar(10), 
	oil_on_pit varchar(10), 
	freeboard varchar(10), 
	num_pits varchar(10), 
	num_covered_lined varchar(10), 
	num_uncovered_unlined varchar(10), 
	pit_comments varchar(5000), 
	action varchar(5000), 
	fencecomment varchar(5000), 
	firewall varchar(5000), 
	genhouse varchar(5000),
	historical varchar(5000), 
	misc varchar(5000),
	spilcom varchar(5000),
	surfrh varchar(5000), 
	tankbat varchar(5000), 
	uiccom varchar(5000), 
	wellsign varchar(5000),  
	workov varchar(5000), 
	related_facility_url varchar(100), 
	related_docs_url varchar(100), 
	created_at date, 
	updated_at date
);

alter table cogcc_inspection_details add column insp_year smallint;
alter table cogcc_inspection_details add column insp_month smallint;

update cogcc_inspection_details set insp_year = right(trim(inspection_date),4)::smallint;
update cogcc_inspection_details set insp_month = left(trim(inspection_date),2)::smallint

alter table cogcc_inspection_details alter inspection_date type date using inspection_date::date;
alter table cogcc_inspection_details alter date_corrective_action_due type date using date_corrective_action_due::date;
alter table cogcc_inspection_details alter date_remedied type date using date_remedied::date;

alter table cogcc_inspection_details alter lat type double precision using lat::double precision;
alter table cogcc_inspection_details alter long type double precision using long::double precision;

alter table cogcc_inspection_details alter operator_number type integer using operator_number::integer;

alter table cogcc_inspection_details alter api_number type varchar();



COPY (select id, created_at, updated_at from cogcc_inspection_details order by insp_year, insp_month) TO '/Users/troyburke/Projects/ruby/cogcc/inspections/cogcc_inspection_details.sql' WITH CSV;



create table inspection_details (
	id serial not null primary key,
	cogcc_inspection_id integer, 
	api_number varchar(), 
	name varchar(), 
	location varchar(),
	lat double precision, 
	long double precision, 
	operator_number integer, 
	operator_name varchar(), 
	inspection_date date, 
	insp_year smallint, 
	insp_month smallint, 
	inspector varchar(), 
	inspection_was varchar(), 
	insp_type varchar(), 
	insp_stat varchar(),
	reclamation varchar(), 
	p_and_a varchar(), 
	brhd_pressure varchar(), 
	inj_pressure varchar(), 
	t_c_ann_pressure varchar(), 
	uic_violation_type varchar(), 
	violation varchar(), 
	noav_sent varchar(), 
	date_corrective_action_due date, 
	date_remedied date, 
	action varchar(), 
	fencecomment varchar(), 
	firewall varchar(), 
	genhouse varchar(),
	misc varchar(),
	spilcom varchar(),
	surfrh varchar(), 
	tankbat varchar(), 
	uiccom varchar(), 
	wellsign varchar(),  
	workov varchar(), 
	related_facility_url varchar(), 
	related_docs_url varchar(), 
	created_at date, 
	updated_at date
);

copy inspection_details from '/Users/troyburke/Projects/ruby/cogcc/inspections/cogcc_inspection_details.sql' (format csv, delimiter ',', null '');



create table cogcc_inspection_types (
	id serial not null primary key, 
	name varchar(2), 
	description varchar(50), 
	created_at date, 
	updated_at date
);

insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (1, 'BH', 'Bradenhead Test Witnessed', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (2, 'CA', 'Cementing for Abandon. Witness', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (3, 'CC', 'Cementing of Casing Witnessed', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (4, 'CO', 'Inspection of Public Complaint', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (5, 'DG', 'Drilling Operation Inspection', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (6, 'ER', 'Emergency Response', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (7, 'ES', 'Environmental Issue or Spill', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (8, 'HR', 'Historical PA Surface Reclam', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (9, 'ID', 'Idle Producing Well Inspection', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (10, 'MI', 'MIT Injection Well', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (11, 'MT', 'SI/TA Prod Well MIT Test Witns', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (12, 'PM', 'State-Funded Projects:  On-Site Project Management', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (13, 'PR', 'Producing Well Inspection', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (14, 'RT', 'Routine UIC Inspection', now(), now());
insert into cogcc_inspection_types (id, name, description, created_at, updated_at) values (15, 'SR', 'New Surface Reclam Inspection', now(), now());


create table inspection_types (
	id serial not null primary key, 
	name varchar(2), 
	description varchar(50), 
	created_at date, 
	updated_at date
);

insert into inspection_types (id, name, description, created_at, updated_at) values (1, 'BH', 'Bradenhead Test Witnessed', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (2, 'CA', 'Cementing for Abandon. Witness', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (3, 'CC', 'Cementing of Casing Witnessed', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (4, 'CO', 'Inspection of Public Complaint', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (5, 'DG', 'Drilling Operation Inspection', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (6, 'ER', 'Emergency Response', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (7, 'ES', 'Environmental Issue or Spill', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (8, 'HR', 'Historical PA Surface Reclam', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (9, 'ID', 'Idle Producing Well Inspection', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (10, 'MI', 'MIT Injection Well', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (11, 'MT', 'SI/TA Prod Well MIT Test Witns', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (12, 'PM', 'State-Funded Projects:  On-Site Project Management', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (13, 'PR', 'Producing Well Inspection', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (14, 'RT', 'Routine UIC Inspection', now(), now());
insert into inspection_types (id, name, description, created_at, updated_at) values (15, 'SR', 'New Surface Reclam Inspection', now(), now());






