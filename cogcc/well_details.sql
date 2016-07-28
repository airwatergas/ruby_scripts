drop table cogcc_well_scout_card_scrapes;
drop table cogcc_well_scout_cards;
drop table cogcc_well_sidetracks;
drop table cogcc_well_objective_formations;
drop table cogcc_well_planned_casings;
drop table cogcc_well_completed_casings;
drop table cogcc_well_completed_formations;
drop table cogcc_well_completed_intervals;
drop table cogcc_well_formation_treatments;


create table cogcc_well_scout_card_scrapes (
	id serial primary key not null,
	well_id integer, 
	well_facility_id varchar(8), 
	html_saved boolean not null default false, 
	html_status varchar(20), 
	in_use boolean not null default false
);
insert into cogcc_well_scout_card_scrapes (well_id, well_facility_id) 
select well_id, lpad(well_id::varchar, 8, '0')
from cogcc_well_surface_locations;


create table cogcc_well_scout_cards (
	id serial primary key not null, 
	well_id integer, 
	status_date varchar(30), 
	lease_number varchar(20), 
	has_frac_focus_report boolean not null default false, 
	job_start_date varchar(10), 
	job_end_date varchar(10), 
	reported_date varchar(30), 
	days_to_report varchar(10)
);

create table cogcc_well_sidetracks (
	id serial primary key not null, 
	well_id integer, 
	cogcc_well_scout_card_id integer, 
	sidetrack_number varchar(2), 
	status_code varchar(30), 
	status_date varchar(30), 
	spud_date varchar(10), 
	spud_date_type varchar(30),
	wellbore_permit varchar(50),
	permit_number varchar(50), 
	permit_expiration_date varchar(30), 
	prop_depth_form varchar(20), 
	surface_mineral_owner_same varchar(30),
	mineral_owner varchar(30),
	surface_owner varchar(30), 
	unit varchar(50), 
	unit_number varchar(50), 
	completion_date varchar(10),
	measured_td varchar(20),
	measured_pb_depth varchar(20), 
	true_vertical_td varchar(20), 
	true_vertical_pb_depth varchar(20), 
	top_pz_location varchar(30), 
	footage varchar(30), 
	bottom_hole_location varchar(30), 
	footages varchar(30), 
	log_types varchar(1000), 
	completion_data_confidential boolean not null default false, 
	confidential_end_date varchar(10)
);

create table cogcc_well_objective_formations (
	id serial primary key not null, 
	well_id integer, 
	cogcc_well_scout_card_id integer, 
	cogcc_well_sidetrack_id integer, 
	description varchar(250)
);

create table cogcc_well_planned_casings (
	id serial primary key not null, 
	well_id integer, 
	cogcc_well_scout_card_id integer,
	cogcc_well_sidetrack_id integer, 
	casing_description varchar(250),
	cement_description varchar(250)
);

create table cogcc_well_completed_casings (
	id serial primary key not null, 
	well_id integer, 
	cogcc_well_scout_card_id integer,
	cogcc_well_sidetrack_id integer, 
	casing_description varchar(250),
	cement_description varchar(250),
	is_additional boolean not null default false
);

create table cogcc_well_completed_formations (
	id serial primary key not null, 
	well_id integer, 
	cogcc_well_scout_card_id integer,
	cogcc_well_sidetrack_id integer, 
	formation_name varchar(100), 
	log_top varchar(20), 
	log_bottom varchar(20), 
	cored varchar(30), 
	dst varchar(30)
);

create table cogcc_well_completed_intervals (
	id serial primary key not null, 
	well_id integer, 
	cogcc_well_scout_card_id integer,
	cogcc_well_sidetrack_id integer, 
	formation_code varchar(20), 
	status_code varchar(2), 
	status_date varchar(10), 
	first_production_date varchar(10), 
	choke_size varchar(20), 
	open_hole_completion varchar(20), 
	commingled varchar(20), 
	production_method varchar(250), 
	formation_name varchar(50), 
	tubing_size varchar(20), 
	tubing_setting_depth varchar(20), 
	tubing_packer_depth varchar(20), 
	tubing_multiple_packer varchar(20), 
	open_hole_top varchar(20), 
	open_hole_bottom varchar(20), 
	test_date varchar(10), 
	test_method varchar(50), 
	hours_tested varchar(20), 
	test_gas_type varchar(30), 
	gas_disposal varchar(30), 
	bbls_h20 varchar(20), 
	bbls_oil varchar(20), 
	btu_gas varchar(20), 
	calc_bbls_h20 varchar(20), 
	calc_bbls_oil varchar(20), 
	calc_gor varchar(20), 
	calc_mcf_gas varchar(20), 
	casing_press varchar(20), 
	gravity_oil varchar(20), 
	mcf_gas varchar(20), 
	tubing_press varchar(20),
	perf_bottom varchar(20), 
	perf_top varchar(20), 
	perf_holes_number varchar(20), 
	perf_hole_size varchar(20)
);

create table cogcc_well_formation_treatments (
	id serial primary key not null, 
	well_id integer, 
	cogcc_well_scout_card_id integer,
	cogcc_well_sidetrack_id integer, 
	cogcc_well_completed_interval_id integer,
	treatment_type varchar(50), 
	treatment_date varchar(10), 
	treatment_end_date varchar(10), 
	treatment_summary text, 
	total_fluid_used varchar(20), 
	max_pressure varchar(20), 
	total_gas_used varchar(20), 
	fluid_density varchar(20), 
	gas_type varchar(20), 
	staged_intervals varchar(20), 
	total_acid_used varchar(20), 
	max_frac_gradient varchar(20), 
	recycled_water_used varchar(20), 
	total_flowback_recovered varchar(20), 
	produced_water_used varchar(20), 
	flowback_disposition varchar(30), 
	total_proppant_used varchar(20), 
	green_completions varchar(20), 
	no_green_reasons varchar(250)
);


select * from cogcc_well_scout_card_scrapes where well_facility_id in ('12508214','08705969');


select 
	sc.id as scout_card_id, sc.well_id, sc.status_date, sc.has_frac_focus_report, 
	st.id as sidetrack_id, st.sidetrack_number, st.status_code as st_status, st.spud_date, st.completion_date,
	ci.formation_code, ci.status_code, ci.first_production_date, ci.treatment_type
from 
	cogcc_well_scout_cards sc 
left outer join 
	cogcc_well_sidetracks st on sc.id = st.cogcc_well_scout_card_id
left outer join 
	cogcc_well_completed_intervals ci on st.id = ci.cogcc_well_sidetrack_id


select 
	st.id as sidetrack_id, st.sidetrack_number, st.status_code as st_status, st.spud_date, st.completion_date, 
	of.id as obj_form_id, pc.id as plan_case_id, cc.id as comp_case_id, cf.formation_name, cf.log_top, 
	ci.formation_code, ci.status_code, ci.first_production_date, ci.treatment_type
from 
	cogcc_well_sidetracks st 
left outer join 
	cogcc_well_completed_intervals ci on st.id = ci.cogcc_well_sidetrack_id
where 
	st.cogcc_well_scout_card_id in (select id from cogcc_well_scout_cards);


update cogcc_well_scout_card_scrapes set completion_data_confidential = 't'
where lpad(well_id::varchar,8,'0') in ('00109801','00109803','00109804','00109802','00507191','00507222','00507189','00507219','00507221','00507192','00507220','00507194','00906675','01106194','01106199','01707773','01707774','01707752','02906109','03306155','04306219','04306226','04306225','04516947','04512084','04512121','04512255','04522488','04513105','04513284','04520514','04520515','04520521','04520516','04520513','04522155','04522157','04520517','04520518','04513286','04513297','05106125','05706524','05706509','06706777','06708988','07306603','07306594','07306421','07306475','07306583','07306628','07306629','07306486','07306567','07306615','07306642','07306634','07306569','07306621','07306638','07306563','07509417','07710095','07710079','08107720','08107774','08107769','08107683','08107770','08107771','08107773','08107804','08107763','08107760','08107811','08107761','08107742','08107762','08105709','08107624','08107749','08107754','08107641','08306662','08306663','08708173','08708174','08708171','08708170','10311886','10311887','10311954','10706263','10706260','10706258','10706246','11306271','12111037','12111042','12334405','12324340','12324341','12325739','12326467','12326505','12326705','12326841','12329061','12329060','12329088','12330086','12330090','12330168','12331632','12332151','12333855','12335751','12335803','12335864','12335890','12335889','12336108','12337701','12336121','12336388','12336420','12336587','12336726','12336881','12336973','12337044','12338011','12337985','12337986','12338010','12338019','12338020','12338021','12338022','12338023','12338307','12338619','12338620','12338618','12338780','12338781','12338777','12338778','12338779','12338782','12338813','12338814','12338815','12338879','12338880','12338881','12338882','12338883','12338884','12338885','12339390','12339462','12338812','12339392','12338878','12339393','12338893','12338925','12338926','12338927','12338928','12338892','12339024','12339518','12339519','12339520','12339517','12339701','12339863','12340089','12331573','12334144','12337912','12338776','12326704');

# fix status_code and status_date
alter table cogcc_well_sidetracks add column status_string varchar(30);
update cogcc_well_sidetracks set status_string = status_code;

# update status_code
select left(status_string,2) from cogcc_well_sidetracks where left(status_string,2) ~ '[a-zA-Z]'; 
update cogcc_well_sidetracks set status_code = left(status_string,2) where left(status_string,2) ~ '[a-zA-Z]';
update cogcc_well_sidetracks set status_code = null where length(status_code) > 2;
alter table cogcc_well_sidetracks alter column status_code type varchar(2);

# update status_date
select regexp_replace(status_string, '[a-zA-Z]', '', 'g') from cogcc_well_sidetracks order by length(status_string);
update cogcc_well_sidetracks set status_date = trim(regexp_replace(status_string, '[a-zA-Z]', '', 'g'));
update cogcc_well_sidetracks set status_date = null where status_date = '/';
alter table cogcc_well_sidetracks alter column status_date type date using status_date::date;

# casing_description       | String Type: CONDUCTOR , Hole Size: 17.5, Size: 13.375, Top: 0, Depth: 46, Weight:
# cement_description       | Sacks: 78, Top: 0, Bottom: 55, Method Grade: CALC

select distinct trim(split_part(split_part(casing_description, 'String Type:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is false;
alter table cogcc_well_completed_casings add column casing_string_type varchar(20);
update cogcc_well_completed_casings set casing_string_type = trim(split_part(split_part(casing_description, 'String Type:', 2), ',', 1)) where is_additional is false;

select distinct trim(split_part(split_part(casing_description, 'Hole Size:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is false;
alter table cogcc_well_completed_casings add column casing_hole_size varchar(10);
update cogcc_well_completed_casings set casing_hole_size = trim(split_part(split_part(casing_description, 'Hole Size:', 2), ',', 1)) where is_additional is false;

select distinct trim(split_part(split_part(casing_description, ', Size:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is false;
alter table cogcc_well_completed_casings add column casing_size varchar(10);
update cogcc_well_completed_casings set casing_size = trim(split_part(split_part(casing_description, ', Size:', 2), ',', 1)) where is_additional is false;

select distinct trim(split_part(split_part(casing_description, 'Top:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is false;
alter table cogcc_well_completed_casings add column casing_top varchar(10);
update cogcc_well_completed_casings set casing_top = trim(split_part(split_part(casing_description, 'Top:', 2), ',', 1)) where is_additional is false;

select distinct trim(split_part(split_part(casing_description, 'Depth:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is false;
alter table cogcc_well_completed_casings add column casing_depth varchar(10);
update cogcc_well_completed_casings set casing_depth = trim(split_part(split_part(casing_description, 'Depth:', 2), ',', 1)) where is_additional is false;

select distinct trim(split_part(split_part(casing_description, 'Weight:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is false;
alter table cogcc_well_completed_casings add column casing_weight varchar(15);
update cogcc_well_completed_casings set casing_weight = trim(split_part(split_part(casing_description, 'Weight:', 2), ',', 1)) where is_additional is false;

select distinct trim(split_part(split_part(cement_description, 'Sacks:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is false;
alter table cogcc_well_completed_casings add column cement_sacks varchar(10);
update cogcc_well_completed_casings set cement_sacks = trim(split_part(split_part(cement_description, 'Sacks:', 2), ',', 1)) where is_additional is false;

select distinct trim(split_part(split_part(cement_description, 'Top:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is false;
alter table cogcc_well_completed_casings add column cement_top varchar(10);
update cogcc_well_completed_casings set cement_top = trim(split_part(split_part(cement_description, 'Top:', 2), ',', 1)) where is_additional is false;

select distinct trim(split_part(split_part(cement_description, 'Bottom:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is false;
alter table cogcc_well_completed_casings add column cement_bottom varchar(10);
update cogcc_well_completed_casings set cement_bottom = trim(split_part(split_part(cement_description, 'Bottom:', 2), ',', 1)) where is_additional is false;

select distinct trim(split_part(split_part(cement_description, 'Method Grade:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is false;
alter table cogcc_well_completed_casings add column cement_method_grade varchar(10);
update cogcc_well_completed_casings set cement_method_grade = trim(split_part(split_part(cement_description, 'Method Grade:', 2), ',', 1)) where is_additional is false;



select distinct trim(split_part(split_part(casing_description, 'String Type:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is true;
update cogcc_well_completed_casings set casing_string_type = trim(split_part(split_part(casing_description, 'String Type:', 2), ',', 1)) where is_additional is true;

select distinct trim(split_part(split_part(casing_description, 'Top:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is true;
update cogcc_well_completed_casings set cement_top = trim(split_part(split_part(casing_description, 'Top:', 2), ',', 1)) where is_additional is true;

select distinct trim(split_part(split_part(casing_description, 'Depth:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is true;
alter table cogcc_well_completed_casings add column cement_depth varchar(10);
update cogcc_well_completed_casings set cement_depth = trim(split_part(split_part(casing_description, 'Depth:', 2), ',', 1)) where is_additional is true;

select distinct trim(split_part(split_part(casing_description, 'Bottom:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is true;
update cogcc_well_completed_casings set cement_bottom = trim(split_part(split_part(casing_description, 'Bottom:', 2), ',', 1)) where is_additional is true;

select distinct trim(split_part(split_part(casing_description, 'Sacks:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is true;
update cogcc_well_completed_casings set cement_sacks = trim(split_part(split_part(casing_description, 'Sacks:', 2), ',', 1)) where is_additional is true;

select distinct trim(split_part(split_part(casing_description, 'Method Grade:', 2), ',', 1)) from cogcc_well_completed_casings where is_additional is true;
update cogcc_well_completed_casings set cement_method_grade = trim(split_part(split_part(casing_description, 'Method Grade:', 2), ',', 1)) where is_additional is true;











# description              | Code: FRLDC , Formation: FRUITLAND COAL              , Order: 60        , Unit Acreage: 320, Drill Unit: W2

select distinct trim(split_part(split_part(description, 'Code:', 2), ',', 1)) from cogcc_well_objective_formations;
alter table cogcc_well_objective_formations add column formation_code varchar(10);
update cogcc_well_objective_formations set formation_code = trim(split_part(split_part(description, 'Code:', 2), ',', 1));

select distinct trim(split_part(split_part(description, 'Formation:', 2), ',', 1)) from cogcc_well_objective_formations;
alter table cogcc_well_objective_formations add column formation_name varchar(100);
update cogcc_well_objective_formations set formation_name = trim(split_part(split_part(description, 'Formation:', 2), ',', 1));

select distinct trim(split_part(split_part(description, 'Order:', 2), ',', 1)) from cogcc_well_objective_formations;
alter table cogcc_well_objective_formations add column order_detail varchar(30);
update cogcc_well_objective_formations set order_detail = trim(split_part(split_part(description, 'Order:', 2), ',', 1));

select distinct trim(split_part(split_part(description, 'Unit Acreage:', 2), ',', 1)) from cogcc_well_objective_formations;
alter table cogcc_well_objective_formations add column unit_acreage varchar(10);
update cogcc_well_objective_formations set unit_acreage = trim(split_part(split_part(description, 'Unit Acreage:', 2), ',', 1));

select distinct trim(split_part(split_part(description, 'Drill Unit:', 2), ',', 1)) from cogcc_well_objective_formations;
alter table cogcc_well_objective_formations add column drill_unit varchar(100);
update cogcc_well_objective_formations set drill_unit = trim(split_part(split_part(description, 'Drill Unit:', 2), ',', 1));


select distinct trim(split_part(split_part(casing_description, 'String Type:', 2), ',', 1)) from cogcc_well_planned_casings;
alter table cogcc_well_planned_casings add column casing_string_type varchar(20);
update cogcc_well_planned_casings set casing_string_type = trim(split_part(split_part(casing_description, 'String Type:', 2), ',', 1));

select distinct trim(split_part(split_part(casing_description, 'Hole Size:', 2), ',', 1)) from cogcc_well_planned_casings;
alter table cogcc_well_planned_casings add column casing_hole_size varchar(10);
update cogcc_well_planned_casings set casing_hole_size = trim(split_part(split_part(casing_description, 'Hole Size:', 2), ',', 1));

select distinct trim(split_part(split_part(casing_description, ', Size:', 2), ',', 1)) from cogcc_well_planned_casings;
alter table cogcc_well_planned_casings add column casing_size varchar(10);
update cogcc_well_planned_casings set casing_size = trim(split_part(split_part(casing_description, ', Size:', 2), ',', 1));

select distinct trim(split_part(split_part(casing_description, 'Top:', 2), ',', 1)) from cogcc_well_planned_casings;
alter table cogcc_well_planned_casings add column casing_top varchar(10);
update cogcc_well_planned_casings set casing_top = trim(split_part(split_part(casing_description, 'Top:', 2), ',', 1));

select distinct trim(split_part(split_part(casing_description, 'Depth:', 2), ',', 1)) from cogcc_well_planned_casings;
alter table cogcc_well_planned_casings add column casing_depth varchar(10);
update cogcc_well_planned_casings set casing_depth = trim(split_part(split_part(casing_description, 'Depth:', 2), ',', 1));

select distinct trim(split_part(split_part(casing_description, 'Weight:', 2), ',', 1)) from cogcc_well_planned_casings;
alter table cogcc_well_planned_casings add column casing_weight varchar(15);
update cogcc_well_planned_casings set casing_weight = trim(split_part(split_part(casing_description, 'Weight:', 2), ',', 1));

select distinct trim(split_part(split_part(cement_description, 'Sacks:', 2), ',', 1)) from cogcc_well_planned_casings;
alter table cogcc_well_planned_casings add column cement_sacks varchar(10);
update cogcc_well_planned_casings set cement_sacks = trim(split_part(split_part(cement_description, 'Sacks:', 2), ',', 1));

select distinct trim(split_part(split_part(cement_description, 'Top:', 2), ',', 1)) from cogcc_well_planned_casings;
alter table cogcc_well_planned_casings add column cement_top varchar(10);
update cogcc_well_planned_casings set cement_top = trim(split_part(split_part(cement_description, 'Top:', 2), ',', 1));

select distinct trim(split_part(split_part(cement_description, 'Bottom:', 2), ',', 1)) from cogcc_well_planned_casings;
alter table cogcc_well_planned_casings add column cement_bottom varchar(10);
update cogcc_well_planned_casings set cement_bottom = trim(split_part(split_part(cement_description, 'Bottom:', 2), ',', 1));

select distinct trim(split_part(split_part(cement_description, 'Method Grade:', 2), ',', 1)) from cogcc_well_planned_casings;
alter table cogcc_well_planned_casings add column cement_method_grade varchar(10);
update cogcc_well_planned_casings set cement_method_grade = trim(split_part(split_part(cement_description, 'Method Grade:', 2), ',', 1));


# 4520 total
select count(*) from cogcc_well_formation_treatments where treatment_summary ilike '%refrac%' or treatment_summary ilike '%re-frac%' or treatment_summary ilike '%reperf%' or treatment_summary ilike '%re-perf%';
alter table cogcc_well_formation_treatments add column is_refrac boolean not null default false;
update cogcc_well_formation_treatments set is_refrac = 't' where treatment_summary ilike '%refrac%' or treatment_summary ilike '%re-frac%' or treatment_summary ilike '%reperf%' or treatment_summary ilike '%re-perf%';


# formation treatment volumes clean up
CREATE TABLE cogcc_well_formation_treatments_backup AS TABLE cogcc_well_formation_treatments;

update cogcc_well_formation_treatments set total_fluid_used = null where trim(total_fluid_used) = '';
#1165
alter table cogcc_well_formation_treatments alter column total_fluid_used type integer using total_fluid_used::integer;

update cogcc_well_formation_treatments set recycled_water_used = null where trim(recycled_water_used) = '';
#1923
alter table cogcc_well_formation_treatments alter column recycled_water_used type integer using recycled_water_used::integer;

update cogcc_well_formation_treatments set total_flowback_recovered = null where trim(total_flowback_recovered) = '';
#2039
alter table cogcc_well_formation_treatments alter column total_flowback_recovered type integer using total_flowback_recovered::integer;

update cogcc_well_formation_treatments set produced_water_used = null where trim(produced_water_used) = '';
#2606
alter table cogcc_well_formation_treatments alter column produced_water_used type integer using produced_water_used::integer;

update cogcc_well_formation_treatments set flowback_disposition = null where trim(flowback_disposition) = '';
#1399

alter table cogcc_well_formation_treatments add column fluid_amounts_reported boolean default false;
update cogcc_well_formation_treatments set fluid_amounts_reported = 'true' where total_fluid_used is not null or recycled_water_used is not null or produced_water_used is not null or total_flowback_recovered is not null;

COPY (select w.attrib_1 as well_api_number,
	(select sidetrack_number from cogcc_well_sidetracks where id = ft.cogcc_well_sidetrack_id) as sidetrack_number, 
	case w.api_county when '045' then 'Garfield' when '123' then 'Weld' end as county, 
	w.attrib_3 as well_number_name, 
	w.facility_s as well_status, 
	w.attrib_2 as operator_name, 
	w.lat as latitude, 
	w.long as longitude, 
	w.field_name, 
	(select formation_name from cogcc_well_completed_intervals where id = ft.cogcc_well_completed_interval_id) as formation_name, 
	ft.treatment_date, 
	ft.total_fluid_used as total_fluid_used_bbl, 
	ft.recycled_water_used as recycled_water_used_bbl, 
	ft.produced_water_used as fresh_water_used_bbl, 
	ft.total_flowback_recovered as total_flowback_recovered_bbl, 
	ft.flowback_disposition as flowback_disposition  
from cogcc_well_surface_locations w 
left outer join cogcc_well_formation_treatments ft on w.well_id = ft.well_id
where w.api_county in ('045','123') and ft.fluid_amounts_reported is true 
order by county desc, well_api_number) TO '/Users/troyburke/Data/CSU/cogcc_formation_treatment_fluid_amounts.csv' WITH CSV HEADER;

select count(*) from cogcc_form5a_documents where id < 9409 and water_amounts_reported is true and all_water_amounts_null is false and well_id not in (select distinct well_id from cogcc_well_formation_treatments where fluid_amounts_reported is true);


