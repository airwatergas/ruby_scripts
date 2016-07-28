create table cogcc_scrape_statuses (
	id serial primary key not null, 
	gid integer, 
	link_fld varchar(8),
	well_api_number varchar(12),
	well_api_county varchar(3),
	well_api_sequence varchar(5),
	well_id integer, 
	document_scrape_status varchar(20),
	mit_scrape_status varchar(20), 
	noav_scrape_status varchar(20)
);

insert into cogcc_scrape_statuses (gid, link_fld, well_api_number, well_api_county, well_api_sequence, well_id, document_scrape_status)
select gid, link_fld, attrib_1, substring(attrib_1 from 4 for 3), substring(attrib_1 from 8 for 5), well_id, document_scrape_status
from cogcc_wells
order by gid;

update cogcc_scrape_statuses set mit_scrape_status = 'not scraped';

alter table cogcc_scrape_statuses add column noav_scrape_status varchar(20);
update cogcc_scrape_statuses set noav_scrape_status = 'not scraped';

create table cogcc_documents (
	well_id integer, -- srn database id for well
	well_link_id varchar(10), -- aka link_fld
	document_id integer, 
	document_number integer,
	document_name varchar(500),
	document_date varchar(20),
	download_link varchar(100)
);

ALTER TABLE cogcc_documents ADD COLUMN id SERIAL;
UPDATE cogcc_documents SET id = nextval(pg_get_serial_sequence('cogcc_documents','id'));
ALTER TABLE cogcc_documents ADD PRIMARY KEY (id);

create index cogcc_document_well_id_idx on cogcc_documents(well_id);
create index cogcc_document_document_id_idx on cogcc_documents(document_id);
create index cogcc_document_document_number_idx on cogcc_documents(document_number);

update cogcc_documents set document_date = null where document_date = '';
alter table cogcc_documents alter column document_date type date using document_date::date;

select * from cogcc_documents where document_date < '1913-11-22' order by document_date;
-- dates are clearly wrong prior to 1913. 
alter table cogcc_documents add column date_suspect boolean default false;
update cogcc_documents set date_suspect = 'true' where document_date < '1913-11-22';

select max(length(document_name)) from cogcc_documents;
alter table cogcc_documents add column doc_name_ucase varchar(65);
update cogcc_documents set doc_name_ucase = upper(trim(document_name));
update cogcc_documents set doc_name_ucase = replace(doc_name_ucase, '  ', ' ');


select count(doc_name_ucase) as document_count, doc_name_ucase from cogcc_documents where date_suspect is false group by doc_name_ucase order by doc_name_ucase;


SUMMARY
-------

1,794,148 document links cataloged

5816 documents with no name


-- re-catalog documents to pick up multiple pages

create table cogcc_document_names (
	id serial primary key not null,
	well_id integer, 
	well_link_id varchar(10), 
	document_id integer, 
	document_number integer,
	document_name varchar(500),
	document_date varchar(20)
);










KEYWORDS:
	violation
	treatment
	crack
	failure
	damage
	restoration
	repair
	geological
	incomplete
	recompletion
	mit testing
	rework
	problem
	rehab
	aquifier
	rule
	thermal
	investigation
	remediation
	spill
	porous

select lower(document_name) from cogcc_documents where lower(document_name) ilike '%violation%' or lower(document_name) ilike '%treatment%' or lower(document_name) ilike '%crack%' or lower(document_name) ilike '%failure%' or lower(document_name) ilike '%restoration%' or lower(document_name) ilike '%repair%' or lower(document_name) ilike '%incomplete%' or lower(document_name) ilike '%recompletion%' or lower(document_name) ilike '%mit testing%' or lower(document_name) ilike '%rework%' or lower(document_name) ilike '%problem%' or lower(document_name) ilike '%rehab%' or lower(document_name) ilike '%aquifier%' or lower(document_name) ilike '%investigation%' or lower(document_name) ilike '%remediation%' or lower(document_name) ilike '%porous%' order by lower(document_name);

-- document name contains 'violation' but not 'lease' or 'abandon'
select lower(document_name) from cogcc_documents where (lower(document_name) like '%violation%' and lower(document_name) not like '%lease%' and lower(document_name) not like '%abandon%') order by lower(document_name);



#######################################################################################
##        UPDATES USING NEW DOCUMENT INDEX => cogcc_document_names                   ##
#######################################################################################

create index cogcc_document_names_well_id_idx on cogcc_document_names(well_id);
create index cogcc_document_names_document_id_idx on cogcc_document_names(document_id);
create index cogcc_document_names_document_number_idx on cogcc_document_names(document_number);

update cogcc_document_names set document_date = null where document_date = '';
alter table cogcc_document_names alter column document_date type date using document_date::date;

select * from cogcc_document_names where document_date < '1913-11-22' order by document_date;
-- dates are clearly wrong prior to 1913. 
alter table cogcc_document_names add column date_suspect boolean default false;
update cogcc_document_names set date_suspect = 'true' where document_date < '1913-11-22';

select max(length(document_name)) from cogcc_document_names;
alter table cogcc_document_names add column doc_name_ucase varchar(65);
update cogcc_document_names set doc_name_ucase = upper(trim(document_name));
update cogcc_document_names set doc_name_ucase = replace(doc_name_ucase, '  ', ' ');

select count(doc_name_ucase) as document_count, doc_name_ucase from cogcc_document_names where date_suspect is false group by doc_name_ucase order by doc_name_ucase;

create table cogcc_document_names_backup as table cogcc_document_names;

SELECT 
	tab1.id, 
	tab1.well_id, 
	tab1.document_id, 
	tab2.id, 
	tab2.well_id, 
	tab2.document_id 
FROM 
	cogcc_document_names tab1, cogcc_document_names tab2
WHERE 
	tab1.well_id = tab2.well_id 
	AND tab1.document_id = tab2.document_id 
  AND tab1.id <> tab2.id
  AND tab1.id = (SELECT MAX(id) FROM cogcc_document_names tab WHERE tab.well_id = tab2.well_id AND tab.document_id = tab2.document_id);

DELETE FROM cogcc_document_names 
WHERE id IN
(
	SELECT 
		tab2.id
  FROM 
		cogcc_document_names tab1, cogcc_document_names tab2
  WHERE 
		tab1.well_id = tab2.well_id 
		AND tab1.document_id = tab2.document_id 
    AND tab1.id <> tab2.id
    AND tab1.id = (SELECT MAX(id) FROM cogcc_document_names tab WHERE tab.well_id = tab1.well_id AND tab.document_id = tab1.document_id)
);
-- 10946


SELECT 
	tab1.id, 
	tab1.well_id, 
	tab1.document_number, 
	tab2.id, 
	tab2.well_id, 
	tab2.document_number 
FROM 
	cogcc_document_names tab1, cogcc_document_names tab2
WHERE 
	tab1.well_id = tab2.well_id 
	AND tab1.document_number = tab2.document_number 
  AND tab1.id <> tab2.id
  AND tab1.id = (SELECT MAX(id) FROM cogcc_document_names tab WHERE tab.well_id = tab2.well_id AND tab.document_number = tab2.document_number);

DELETE FROM cogcc_document_names 
WHERE id IN
(
	SELECT 
		tab2.id
  FROM 
		cogcc_document_names tab1, cogcc_document_names tab2
  WHERE 
		tab1.well_id = tab2.well_id 
		AND tab1.document_number = tab2.document_number 
    AND tab1.id <> tab2.id
    AND tab1.id = (SELECT MAX(id) FROM cogcc_document_names tab WHERE tab.well_id = tab1.well_id AND tab.document_number = tab1.document_number)
);
-- 40805

# uniqueness exists on (well_id, document_number)



