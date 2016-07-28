create table cogcc_drill_stem_tests (
	id serial primary key not null, 
	cogcc_document_id integer, 
	well_id integer, 
	document_id integer, 
	document_number integer, 
	document_name varchar(500), 
	document_date date, 
	well_api_number varchar(12), 
	api_county varchar(3), 
	in_use boolean not null default false, 
	doc_downloaded boolean not null default false
);

insert into cogcc_drill_stem_tests (cogcc_document_id, well_id, document_id, document_number, document_name, document_date, well_api_number, api_county) 
select id, well_id, document_id, document_number, document_name, document_date, well_api_number, well_api_county 
from cogcc_document_names 
where document_name ilike '%dril%stem%' 
order by document_date desc;