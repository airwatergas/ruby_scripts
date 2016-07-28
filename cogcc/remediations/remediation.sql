CREATE TABLE cogcc_remediations_backup AS SELECT * FROM cogcc_remediations;
CREATE TABLE cogcc_remediation_details_backup AS SELECT * FROM cogcc_remediation_details;
CREATE TABLE cogcc_remediation_medias_backup AS SELECT * FROM cogcc_remediation_medias;

drop table cogcc_remediations;
drop table cogcc_remediation_details;
drop table cogcc_remediation_medias;

create table cogcc_remediations (
	id serial primary key not null, 
	submit_date varchar(10), 
	received_date varchar(10), 
	assigned_by varchar(100), 
	document_number integer,
	document_type varchar(20),  
	document_url varchar(100),
	related_documents_url varchar(100), 
	api_number varchar(16), 
	project_number varchar(10),
	facility_type varchar(30),
	facility_id varchar(20),
	facility_name varchar(100),
	operator_name varchar(100),  
	operator_number varchar(20),
	operator_address varchar(250), 
	operator_contact varchar(50),
	county_name varchar(50), 
	qtr_qtr varchar(10),
	section varchar(10),
	township varchar(10),
	range varchar(10),
	meridian varchar(10), 
	fips_code varchar(3), 
	details_scraped boolean default false, 
	in_use boolean default false, 
	invalid_text boolean default false
);

create table cogcc_remediation_details (
	id serial primary key not null, 
	cogcc_remediation_id integer, 
	report_reason varchar(50),
	condition_cause varchar(100),
	potential_receptors text,
	initial_action text,
	source_removed text,
	how_remediate text,
	monitoring_plan text,
	reclamation_plan text,
	approval_conditions text
);

create table cogcc_remediation_medias (
	id serial primary key not null, 
	cogcc_remediation_id integer, 
	media varchar(50),
	impacted varchar(10),
	extent varchar(100),
	how_determined varchar(100)
);


update cogcc_remediations set submit_date = trim(submit_date);
update cogcc_remediations set submit_date = null where submit_date = '';
update cogcc_remediations set submit_date = null where submit_date = 'N/A';
alter table cogcc_remediations alter column submit_date type date using submit_date::date;
update cogcc_remediations set received_date = trim(received_date);
update cogcc_remediations set received_date = null where received_date = '';
update cogcc_remediations set received_date = null where received_date = 'N/A';
alter table cogcc_remediations alter column received_date type date using received_date::date;
update cogcc_remediations set assigned_by = trim(assigned_by);
update cogcc_remediations set assigned_by = null where assigned_by = '';
update cogcc_remediations set document_type = trim(document_type);
update cogcc_remediations set document_type = null where document_type = '';
update cogcc_remediations set api_number = trim(api_number);
update cogcc_remediations set api_number = null where api_number = '';
update cogcc_remediations set project_number = trim(project_number);
update cogcc_remediations set project_number = null where project_number = '';
update cogcc_remediations set facility_type = trim(facility_type);
update cogcc_remediations set facility_type = null where facility_type = '';
update cogcc_remediations set facility_id = trim(facility_id);
update cogcc_remediations set facility_id = null where facility_id = '';
update cogcc_remediations set facility_name = trim(facility_name);
update cogcc_remediations set facility_name = null where facility_name = '';
update cogcc_remediations set operator_name = trim(operator_name);
update cogcc_remediations set operator_name = null where operator_name = '';
update cogcc_remediations set operator_number = trim(operator_number);
update cogcc_remediations set operator_number = null where operator_number = '';
update cogcc_remediations set operator_address = trim(operator_address);
update cogcc_remediations set operator_address = null where operator_address = '';
update cogcc_remediations set operator_contact = trim(operator_contact);
update cogcc_remediations set operator_contact = null where operator_contact = '';
update cogcc_remediations set county_name = trim(county_name);
update cogcc_remediations set county_name = null where county_name = '';
update cogcc_remediations set qtr_qtr = trim(qtr_qtr);
update cogcc_remediations set qtr_qtr = null where qtr_qtr = '';
update cogcc_remediations set section = trim(section);
update cogcc_remediations set section = null where section = '';
update cogcc_remediations set township = trim(township);
update cogcc_remediations set township = null where township = '';
update cogcc_remediations set range = trim(range);
update cogcc_remediations set range = null where range = '';
update cogcc_remediations set meridian = trim(meridian);
update cogcc_remediations set meridian = null where meridian = '';

update cogcc_remediation_details set report_reason = trim(upper(report_reason));
update cogcc_remediation_details set report_reason = null where report_reason = '';
update cogcc_remediation_details set condition_cause = trim(upper(condition_cause));
update cogcc_remediation_details set condition_cause = null where condition_cause = '';
update cogcc_remediation_details set potential_receptors = trim(potential_receptors);
update cogcc_remediation_details set potential_receptors = null where potential_receptors = '';
update cogcc_remediation_details set initial_action = trim(initial_action);
update cogcc_remediation_details set initial_action = null where initial_action = '';
update cogcc_remediation_details set source_removed = trim(source_removed);
update cogcc_remediation_details set source_removed = null where source_removed = '';
update cogcc_remediation_details set how_remediate = trim(how_remediate);
update cogcc_remediation_details set how_remediate = null where how_remediate = '';
update cogcc_remediation_details set monitoring_plan = trim(monitoring_plan);
update cogcc_remediation_details set monitoring_plan = null where monitoring_plan = '';
update cogcc_remediation_details set reclamation_plan = trim(reclamation_plan);
update cogcc_remediation_details set reclamation_plan = null where reclamation_plan = '';
update cogcc_remediation_details set approval_conditions = trim(approval_conditions);
update cogcc_remediation_details set approval_conditions = null where approval_conditions = '';

update cogcc_remediation_medias set media = trim(media);
update cogcc_remediation_medias set media = null where media = '';
update cogcc_remediation_medias set impacted = trim(impacted);
update cogcc_remediation_medias set impacted = null where impacted = '';
update cogcc_remediation_medias set extent = trim(extent);
update cogcc_remediation_medias set extent = null where extent = '';
update cogcc_remediation_medias set how_determined = trim(how_determined);
update cogcc_remediation_medias set how_determined = null where how_determined = '';


COPY(
select 
	r.submit_date, 
	r.received_date, 
	r.assigned_by, 
	r.document_number, 
	r.related_documents_url,
	r.api_number,  
	r.project_number, 
	r.facility_type, 
	r.facility_id, 
	r.facility_name, 
	r.operator_name, 
	r.operator_number, 
	r.operator_address, 
	r.operator_contact, 
	r.county_name, 
	r.fips_code, 
	r.qtr_qtr, 
	r.section, 
	r.township, 
	r.range, 
	r.meridian, 
	rd.report_reason, 
	rd.condition_cause, 
	rd.potential_receptors, 
	rd.initial_action, 
	rd.source_removed, 
	rd.how_remediate, 
	rd.monitoring_plan, 
	rd.reclamation_plan, 
	rd.approval_conditions, 
	(select array_to_string(array(select 'Media: ' || media || ' ~ ' || impacted || ' ~ ' || extent || ' ~ ' || how_determined from cogcc_remediation_medias where cogcc_remediation_id = r.id), E'\r')) as impacted_medias 
from 
	cogcc_remediations r 
inner join 
	cogcc_remediation_details rd on r.id = rd.cogcc_remediation_id 
order by 
	r.submit_date desc 
) TO '/Users/troyburke/Data/cogcc/remediations_for_owen.csv' WITH CSV HEADER NULL 'NA';









