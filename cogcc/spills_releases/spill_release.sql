create table cogcc_spill_releases (
	id serial primary key not null, 
	submit_date varchar(10), 
	document_number integer, 
	document_url varchar(100),
	facility_id varchar(20), 
	operator_number varchar(20), 
	company_name varchar(100), 
	ground_water varchar(1), 
	surface_water varchar(1), 
	berm_contained varchar(1), 
	spill_area varchar(20), 
	details_scraped boolean default false, 
	invalid_text boolean default false
);

alter table cogcc_spill_releases add column html_details boolean default false;
update cogcc_spill_releases set html_details = 'true' where left(document_url,1) = 'S';


create table cogcc_spill_release_details (
	id serial primary key not null, 
	cogcc_spill_release_id integer, 
	facility_status varchar(10),
	facility_name_no varchar(100),
	status_date varchar(10),
	county_name varchar(50),
	county_fips varchar(3),
	location varchar(100),
	latitude double precision, 
	longitude double precision, 
	comment varchar(2500),
	date_received varchar(10),
	report_taken_by varchar(100),
	api_number varchar(20),
	operator_address varchar(250),
	operator_phone varchar(30),
	operator_fax varchar(30),
	operator_contact varchar(50),
	incident_date varchar(10),
	facility_type varchar(30),
	well_name_no varchar(250),
	qtr_qtr varchar(10),
	section varchar(10),
	township varchar(10),
	range varchar(10),
	meridian varchar(10),
	oil_spilled varchar(20), 
	oil_recovered varchar(20),
	water_spilled varchar(20),
	water_recovered varchar(20),
	other_spilled varchar(20),
	other_recovered varchar(20),
	condensate_spilled varchar(20),
	flow_back_spilled varchar(20),
	produced_water_spilled varchar(20),
	drilling_fluid_spilled varchar(20),
	current_land_use varchar(100),
	weather_conditions varchar(100),
	soil_geology_description varchar(250),
	distance_to_surface_water varchar(20),
	depth_to_ground_water varchar(20),
	wetlands varchar(20),
	buildings varchar(20),
	livestock varchar(20),
	water_wells varchar(20),
	spill_cause varchar(500),
	immediate_response varchar(1000),
	emergency_pits varchar(1000), 
	extent_determination varchar(1000),
	further_remediation varchar(1000),
	problem_prevention varchar(2500),
	detailed_description text
);












 