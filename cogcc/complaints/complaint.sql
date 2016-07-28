CREATE TABLE cogcc_complaints_backup AS SELECT * FROM cogcc_complaints;
CREATE TABLE cogcc_complaint_issues_backup AS SELECT * FROM cogcc_complaint_issues;
CREATE TABLE cogcc_complaint_notifications_backup AS SELECT * FROM cogcc_complaint_notifications;

drop table cogcc_complaints;
drop table cogcc_complaint_issues;
drop table cogcc_complaint_notifications;

create table cogcc_complaints (
	id serial primary key not null, 
	incident_date varchar(10), 
	document_number integer, 
	complaint_taken_by varchar(100), 
	well_api_number varchar(16), 
	complaint_type varchar(100), 
	complainant_name varchar(100), 
	complainant_address varchar(100), 
	complaint_date varchar(20), 
	complainant_connection varchar(100), 
	operator_name varchar(100), 
	operator_number varchar(20), 
	facility_type varchar(50), 
	facility_id varchar(20), 
	well_name_no varchar(100), 
	county_name varchar(50), 
	operator_contact varchar(100), 
	qtr_qtr varchar(20), 
	section varchar(20), 
	township varchar(20), 
	range varchar(20), 
	meridian varchar(20), 
	details_scraped boolean default false, 
	invalid_text boolean default false, 
	in_use boolean default false
);

create table cogcc_complaint_issues (
	id serial primary key not null, 
	cogcc_complaint_id integer, 
	issue varchar(250), 
	assigned_to varchar(100), 
	status varchar(100), 
	description text, 
	resolution text, 
	letter_sent varchar(1), 
	report_links varchar(250) 
);

create table cogcc_complaint_notifications (
	id serial primary key not null, 
	cogcc_complaint_id integer, 
	notification_date varchar(10), 
	agency varchar(100), 
	contact varchar(100), 
	response_details text
);

create table cogcc_complaint_visits (
	id serial primary key not null, 
	cogcc_complaint_id integer, 
	visitor_nmae varchar(100), 
	visitor_phone varchar(50), 
	visit_date varchar(10), 
	visit_description text 
);

create table cogcc_complaint_responses (
	id serial primary key not null, 
	cogcc_complaint_id integer, 
	respondant_name varchar(100), 
	respondant_phone varchar(50), 
	response_date varchar(10), 
	response_description text
);

create table cogcc_complaint_resolutions (
	id serial primary key not null, 
	cogcc_complaint_id integer, 
	resolution_date varchar(1), 
	case_closed varchar(1),
	letter_sent varchar(1), 
	cogcc_persion varchar(100), 
	resolution_description text
);


update cogcc_complaints set incident_date = trim(incident_date);
update cogcc_complaints set incident_date = null where incident_date = 'N/A';
alter table cogcc_complaints alter column incident_date type date using incident_date::date;
update cogcc_complaints set complaint_taken_by = trim(complaint_taken_by);
update cogcc_complaints set complaint_taken_by = null where complaint_taken_by = '';
update cogcc_complaints set well_api_number = trim(well_api_number);
update cogcc_complaints set well_api_number = null where well_api_number = '';
update cogcc_complaints set complaint_type = trim(complaint_type);
update cogcc_complaints set complaint_type = null where complaint_type = '';
update cogcc_complaints set complainant_name = trim(complainant_name);
update cogcc_complaints set complainant_name = null where complainant_name = '';
update cogcc_complaints set complainant_address = trim(complainant_address);
update cogcc_complaints set complainant_address = null where complainant_address = '';
update cogcc_complaints set complaint_date = trim(complaint_date);
update cogcc_complaints set complaint_date = null where complaint_date = '';
update cogcc_complaints set complaint_date = null where complaint_date = 'N/A';
alter table cogcc_complaints alter column complaint_date type date using complaint_date::date;
update cogcc_complaints set complainant_connection = trim(complainant_connection);
update cogcc_complaints set complainant_connection = null where complainant_connection = '';
update cogcc_complaints set operator_name = trim(operator_name);
update cogcc_complaints set operator_name = null where operator_name = '';
update cogcc_complaints set operator_number = trim(operator_number);
update cogcc_complaints set operator_number = null where operator_number = '';
update cogcc_complaints set facility_type = trim(upper(facility_type));
update cogcc_complaints set facility_type = null where facility_type = '';
update cogcc_complaints set facility_id = trim(facility_id);
update cogcc_complaints set facility_id = null where facility_id = '';
update cogcc_complaints set well_name_no = trim(well_name_no);
update cogcc_complaints set well_name_no = null where well_name_no = '';
update cogcc_complaints set operator_contact = trim(operator_contact);
update cogcc_complaints set operator_contact = null where operator_contact = '';
update cogcc_complaints set qtr_qtr = trim(qtr_qtr);
update cogcc_complaints set qtr_qtr = null where qtr_qtr = '';
update cogcc_complaints set section = trim(section);
update cogcc_complaints set section = null where section = '';
update cogcc_complaints set township = trim(upper(township));
update cogcc_complaints set township = null where township = '';
update cogcc_complaints set range = trim(upper(range));
update cogcc_complaints set range = null where range = '';
update cogcc_complaints set meridian = trim(meridian);
update cogcc_complaints set meridian = null where meridian = '';
update cogcc_complaints set county_name = trim(upper(county_name));
update cogcc_complaints set county_name = null where county_name = '';

update cogcc_complaint_issues set issue = trim(upper(issue));
update cogcc_complaint_issues set issue = null where issue = '';
update cogcc_complaint_issues set assigned_to = trim(assigned_to);
update cogcc_complaint_issues set assigned_to = null where assigned_to = '';
update cogcc_complaint_issues set status = trim(status);
update cogcc_complaint_issues set status = null where status = '';
update cogcc_complaint_issues set description = trim(description);
update cogcc_complaint_issues set description = null where description = '';
update cogcc_complaint_issues set resolution = trim(resolution);
update cogcc_complaint_issues set resolution = null where resolution = '';
update cogcc_complaint_issues set letter_sent = trim(letter_sent);
update cogcc_complaint_issues set letter_sent = null where letter_sent = '';
update cogcc_complaint_issues set report_links = trim(report_links);
update cogcc_complaint_issues set report_links = null where report_links = '';

update cogcc_complaint_notifications set notification_date = trim(notification_date);
update cogcc_complaint_notifications set notification_date = null where notification_date = '';
update cogcc_complaint_notifications set notification_date = null where notification_date = 'N/A';
alter table cogcc_complaint_notifications alter column notification_date type date using notification_date::date;
update cogcc_complaint_notifications set agency = trim(agency);
update cogcc_complaint_notifications set agency = null where agency = '';
update cogcc_complaint_notifications set contact = trim(contact);
update cogcc_complaint_notifications set contact = null where contact = '';
update cogcc_complaint_notifications set response_details = trim(response_details);
update cogcc_complaint_notifications set response_details = null where response_details = '';



COPY (
select 
	c.incident_date, 
	c.document_number,
	'http://ogccweblink.state.co.us/results.aspx?classid=02&id=' || c.document_number as related_docs_url, 
	c.complaint_taken_by, 
	c.complainant_name, 
	c.complainant_address, 
	c.complaint_date, 
	c.complainant_connection, 
	c.operator_name, 
	c.operator_number,
	c.operator_contact, 
	c.facility_type, 
	c.facility_id, 
	c.well_api_number, 
	c.well_name_no, 
	c.county_name, 
	c.qtr_qtr, 
	c.section, 
	c.township, 
	c.range, 
	c.meridian, 
	ci.issue, 
	ci.assigned_to, 
	ci.status, 
	ci.description || ' ' || ci.resolution as description_resolution_text 
from 
	cogcc_complaints c 
left outer join 
	cogcc_complaint_issues ci on c.id = ci.cogcc_complaint_id 
order by 
	c.incident_date desc, 
	c.document_number, 
	ci.id 
) TO '/Users/troyburke/Data/cogcc/updated_complaints_for_owen.csv' WITH CSV HEADER NULL 'NA';




COPY (
select 
	c.incident_date, 
	c.document_number,
	c.complaintant_name, 
	c.operator_name, 
	c.operator_number,
	c.facility_type, 
	c.facility_id, 
	ci.issue, 
	ci.assigned_to, 
 	ci.status, 
	case when c.facility_id like '%-%' then w.location_plss else cf.location_plss end as location_plss, 
	ci.description || ' ' || ci.resolution as description_resolution 
from 
	cogcc_complaints c 
left outer join 
	cogcc_complaint_issues ci on c.id = ci.cogcc_complaint_id 
left outer join 
	cogcc_facilities cf on cf.facility_id::varchar = c.facility_id and c.facility_id not like '%-%'
left outer join 
	(
	select 
		f.location_plss, 
		fw.api_number 
	from 
		cogcc_facilities f 
	inner join 
		cogcc_facility_wells fw on f.id = fw.cogcc_facility_id 
	) w on w.api_number = c.facility_id and c.facility_id like '%-%' 
order by 
	c.incident_date desc, 
	c.document_number, 
	ci.id 
) TO '/Users/troyburke/Data/cogcc/complaints_for_owen.csv' WITH CSV HEADER NULL 'NA';




select 
	sum(case when incident_date between '2010-01-01' and now() then 1 else 0 end) as complaints_2010_to_present, 
	sum(case when incident_date between '2000-01-01' and '2009-12-31' then 1 else 0 end) as complaints_2000_to_2009, 
	sum(case when incident_date between '1990-01-01' and '1999-12-31' then 1 else 0 end) as complaints_1990_to_1999, 
	sum(case when incident_date between '1980-01-01' and '1989-12-31' then 1 else 0 end) as complaints_1980_to_1989
from 
	cogcc_complaints;
	
	select 
		sum(case when incident_date between '2003-01-01' and now() then 1 else 0 end) as complaints_2003_to_present, 
		sum(case when incident_date between '2000-01-01' and '2002-12-31' then 1 else 0 end) as complaints_1990_to_2003
	from 
		cogcc_complaints;
	
select count(*) as issue_count, upper(issue) from cogcc_complaint_issues group by upper(issue) order by issue_count desc;


-- 'spill' complaints
COPY (
select 
	c.incident_date, 
	c.document_number,
	c.complainant_name, 
	c.operator_name, 
	c.operator_number,
	c.facility_type, 
	c.facility_id, 
	ci.issue, 
	ci.assigned_to, 
 	ci.status, 
	ci.description, 
	ci.resolution
from 
	cogcc_complaints c 
left outer join 
	cogcc_complaint_issues ci on c.id = ci.cogcc_complaint_id 
where 
	ci.issue ilike '%spill%' or ci.description ilike '%spill%' or ci.resolution ilike '%spill%'
order by 
	c.incident_date desc, 
	c.document_number, 
	ci.id 
) TO '/Users/troyburke/Data/cogcc/spill_complaints.csv' WITH CSV HEADER NULL 'NA';

-- 'historical' complaints
COPY (
select 
	c.incident_date, 
	c.document_number,
	c.complainant_name, 
	c.operator_name, 
	c.operator_number,
	c.facility_type, 
	c.facility_id, 
	ci.issue, 
	ci.assigned_to, 
 	ci.status, 
	ci.description, 
	ci.resolution 
from 
	cogcc_complaints c 
left outer join 
	cogcc_complaint_issues ci on c.id = ci.cogcc_complaint_id 
where 
	ci.issue ilike '%historical%' or ci.description ilike '%historical%' or ci.resolution ilike '%historical%'
order by 
	c.incident_date desc, 
	c.document_number, 
	ci.id 
) TO '/Users/troyburke/Data/cogcc/historical_complaints.csv' WITH CSV HEADER NULL 'NA';



