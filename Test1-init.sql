CREATE TABLE cpu_load (
	id bigserial NOT NULL,
	time_frame_start timestamp NOT NULL,
	time_frame_finish timestamp NOT NULL,
	"load" numeric(4, 2) NOT NULL,
	CONSTRAINT cpu_load_pk PRIMARY KEY (id)
);

CREATE TABLE received_types (
	id bigserial NOT NULL,
	file_type varchar NOT NULL,
	received_at timestamp NOT NULL,
	CONSTRAINT received_types_pk PRIMARY KEY (id)
);