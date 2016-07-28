create table cogcc_environmental_locations (
	id serial not null primary key, 
  location_id integer, 
	facility_type varchar(30), 
	project_number varchar(30), 
	county varchar(30), 
	plss_location varchar(100), 
	elevation integer, 
	longitude double precision, 
	latitude double precision, 
	dwr_receipt_number varchar(30), 
	dwr_url varchar(100), 
	well_depth integer, 
	created_at timestamp,  
	updated_at timestamp
);