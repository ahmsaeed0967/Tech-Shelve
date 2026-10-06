-- CS-2005 Assignment 02 - Case Study 3: AeroNova (relational schema, Chapter 9 mapping)

CREATE TABLE AIRCRAFT_MODEL (
    model_name  VARCHAR(50) NOT NULL,
    CONSTRAINT pk_aircraft_model PRIMARY KEY (model_name)
);

CREATE TABLE LIVERY (
    livery_color  VARCHAR(30) NOT NULL,
    price_increase_pct  DECIMAL(5,2) NOT NULL,
    CONSTRAINT pk_livery PRIMARY KEY (livery_color),
    CONSTRAINT ck_livery_pct CHECK (price_increase_pct BETWEEN 0 AND 100)
);

CREATE TABLE ONBOARD_SYSTEM (
    system_name  VARCHAR(50) NOT NULL,
    price_increase_pct  DECIMAL(5,2) NOT NULL,
    CONSTRAINT pk_onboard_system PRIMARY KEY (system_name),
    CONSTRAINT ck_system_pct CHECK (price_increase_pct BETWEEN 0 AND 100)
);

CREATE TABLE AIRCRAFT (
    aircraft_id  INT NOT NULL,
    manufacture_year  INT NOT NULL,
    launch_date  DATE NOT NULL,
    base_price  DECIMAL(14,2) NOT NULL,
    passenger_capacity  INT NOT NULL,
    no_of_engines  INT NOT NULL,
    no_of_landing_wheels  INT NOT NULL,
    variant  VARCHAR(10) NOT NULL,
    model_name  VARCHAR(50) NOT NULL,
    livery_color  VARCHAR(30) NOT NULL,
    CONSTRAINT pk_aircraft PRIMARY KEY (aircraft_id),
    CONSTRAINT fk_aircraft_1 FOREIGN KEY (model_name) REFERENCES AIRCRAFT_MODEL (model_name),
    CONSTRAINT fk_aircraft_2 FOREIGN KEY (livery_color) REFERENCES LIVERY (livery_color),
    CONSTRAINT ck_ac_variant CHECK (variant IN ('TURBOFAN', 'TURBOPROP')),
    CONSTRAINT ck_ac_price CHECK (base_price > 0),
    CONSTRAINT ck_ac_counts CHECK (passenger_capacity >= 0 AND no_of_engines >= 0 AND no_of_landing_wheels >= 0)
);

CREATE TABLE PASSENGER_JET (
    aircraft_id  INT NOT NULL,
    cabin_class  VARCHAR(11) NOT NULL,
    CONSTRAINT pk_passenger_jet PRIMARY KEY (aircraft_id),
    CONSTRAINT fk_passenger_jet_1 FOREIGN KEY (aircraft_id) REFERENCES AIRCRAFT (aircraft_id) ON DELETE CASCADE,
    CONSTRAINT ck_pj_cabin CHECK (cabin_class IN ('NARROW_BODY', 'WIDE_BODY'))
);

CREATE TABLE CARGO_PLANE (
    aircraft_id  INT NOT NULL,
    pressurized_hold  CHAR(1) NOT NULL,
    max_payload  DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_cargo_plane PRIMARY KEY (aircraft_id),
    CONSTRAINT fk_cargo_plane_1 FOREIGN KEY (aircraft_id) REFERENCES AIRCRAFT (aircraft_id) ON DELETE CASCADE,
    CONSTRAINT ck_cp_hold CHECK (pressurized_hold IN ('Y', 'N')),
    CONSTRAINT ck_cp_payload CHECK (max_payload > 0)
);

CREATE TABLE HELICOPTER (
    aircraft_id  INT NOT NULL,
    autopilot  CHAR(1) NOT NULL,
    CONSTRAINT pk_helicopter PRIMARY KEY (aircraft_id),
    CONSTRAINT fk_helicopter_1 FOREIGN KEY (aircraft_id) REFERENCES AIRCRAFT (aircraft_id) ON DELETE CASCADE,
    CONSTRAINT ck_heli_auto CHECK (autopilot IN ('Y', 'N'))
);

CREATE TABLE INSTALLED_ON (
    aircraft_id  INT NOT NULL,
    system_name  VARCHAR(50) NOT NULL,
    CONSTRAINT pk_installed_on PRIMARY KEY (aircraft_id, system_name),
    CONSTRAINT fk_installed_on_1 FOREIGN KEY (aircraft_id) REFERENCES AIRCRAFT (aircraft_id) ON DELETE CASCADE,
    CONSTRAINT fk_installed_on_2 FOREIGN KEY (system_name) REFERENCES ONBOARD_SYSTEM (system_name)
);

CREATE TABLE COMPONENT (
    component_id  INT NOT NULL,
    component_name  VARCHAR(80) NOT NULL,
    weight  DECIMAL(10,2) NOT NULL,
    manufacturing_date  DATE NOT NULL,
    CONSTRAINT pk_component PRIMARY KEY (component_id),
    CONSTRAINT ck_comp_weight CHECK (weight > 0)
);

CREATE TABLE ASSEMBLED_FROM (
    aircraft_id  INT NOT NULL,
    component_id  INT NOT NULL,
    CONSTRAINT pk_assembled_from PRIMARY KEY (aircraft_id, component_id),
    CONSTRAINT fk_assembled_from_1 FOREIGN KEY (aircraft_id) REFERENCES AIRCRAFT (aircraft_id) ON DELETE CASCADE,
    CONSTRAINT fk_assembled_from_2 FOREIGN KEY (component_id) REFERENCES COMPONENT (component_id)
);

CREATE TABLE PART_OF (
    parent_id  INT NOT NULL,
    sub_id  INT NOT NULL,
    quantity  INT NOT NULL,
    CONSTRAINT pk_part_of PRIMARY KEY (parent_id, sub_id),
    CONSTRAINT fk_part_of_1 FOREIGN KEY (parent_id) REFERENCES COMPONENT (component_id),
    CONSTRAINT fk_part_of_2 FOREIGN KEY (sub_id) REFERENCES COMPONENT (component_id),
    CONSTRAINT ck_part_qty CHECK (quantity > 0),
    CONSTRAINT ck_part_self CHECK (parent_id <> sub_id)
);

CREATE TABLE DELIVERY_CENTER (
    center_no  INT NOT NULL,
    center_name  VARCHAR(80) NOT NULL,
    manager_first_name  VARCHAR(40) NOT NULL,
    manager_last_name  VARCHAR(40) NOT NULL,
    manager_cnic  CHAR(13) NOT NULL,
    registration_date  DATE NOT NULL,
    city  VARCHAR(50) NOT NULL,
    address  VARCHAR(200) NOT NULL,
    CONSTRAINT pk_delivery_center PRIMARY KEY (center_no)
);

CREATE TABLE DISPLAYS (
    center_no  INT NOT NULL,
    model_name  VARCHAR(50) NOT NULL,
    availability_status  VARCHAR(12) NOT NULL,
    CONSTRAINT pk_displays PRIMARY KEY (center_no, model_name),
    CONSTRAINT fk_displays_1 FOREIGN KEY (center_no) REFERENCES DELIVERY_CENTER (center_no) ON DELETE CASCADE,
    CONSTRAINT fk_displays_2 FOREIGN KEY (model_name) REFERENCES AIRCRAFT_MODEL (model_name),
    CONSTRAINT ck_disp_status CHECK (availability_status IN ('AVAILABLE', 'LIMITED', 'UNAVAILABLE'))
);

CREATE TABLE BUYER (
    buyer_id  INT NOT NULL,
    address  VARCHAR(200) NOT NULL,
    contact_no  VARCHAR(15) NOT NULL,
    email  VARCHAR(100),
    CONSTRAINT pk_buyer PRIMARY KEY (buyer_id)
);

CREATE TABLE AVIATION_OPERATOR (
    buyer_id  INT NOT NULL,
    aoc_number  VARCHAR(20) NOT NULL,
    operator_name  VARCHAR(100) NOT NULL,
    designated_airfield  VARCHAR(100) NOT NULL,
    CONSTRAINT pk_aviation_operator PRIMARY KEY (buyer_id),
    CONSTRAINT uq_aviation_operator_1 UNIQUE (aoc_number),
    CONSTRAINT fk_aviation_operator_1 FOREIGN KEY (buyer_id) REFERENCES BUYER (buyer_id) ON DELETE CASCADE
);

CREATE TABLE PRIVATE_BUYER (
    buyer_id  INT NOT NULL,
    cnic  CHAR(13) NOT NULL,
    first_name  VARCHAR(40) NOT NULL,
    last_name  VARCHAR(40) NOT NULL,
    CONSTRAINT pk_private_buyer PRIMARY KEY (buyer_id),
    CONSTRAINT uq_private_buyer_1 UNIQUE (cnic),
    CONSTRAINT fk_private_buyer_1 FOREIGN KEY (buyer_id) REFERENCES BUYER (buyer_id) ON DELETE CASCADE
);

CREATE TABLE REGISTERS_WITH (
    buyer_id  INT NOT NULL,
    center_no  INT NOT NULL,
    CONSTRAINT pk_registers_with PRIMARY KEY (buyer_id, center_no),
    CONSTRAINT fk_registers_with_1 FOREIGN KEY (buyer_id) REFERENCES PRIVATE_BUYER (buyer_id) ON DELETE CASCADE,
    CONSTRAINT fk_registers_with_2 FOREIGN KEY (center_no) REFERENCES DELIVERY_CENTER (center_no) ON DELETE CASCADE
);

CREATE TABLE AIRCRAFT_ORDER (
    order_id  INT NOT NULL,
    order_date  DATE NOT NULL,
    advance_payment  DECIMAL(14,2) NOT NULL,
    buyer_id  INT NOT NULL,
    aircraft_id  INT NOT NULL,
    center_no  INT,
    CONSTRAINT pk_aircraft_order PRIMARY KEY (order_id),
    CONSTRAINT uq_aircraft_order_1 UNIQUE (aircraft_id),
    CONSTRAINT fk_aircraft_order_1 FOREIGN KEY (buyer_id) REFERENCES BUYER (buyer_id),
    CONSTRAINT fk_aircraft_order_2 FOREIGN KEY (aircraft_id) REFERENCES AIRCRAFT (aircraft_id),
    CONSTRAINT fk_aircraft_order_3 FOREIGN KEY (center_no) REFERENCES DELIVERY_CENTER (center_no),
    CONSTRAINT ck_order_adv CHECK (advance_payment >= 0)
);

CREATE TABLE OPERATOR_ORDER (
    order_id  INT NOT NULL,
    delivery_charges  DECIMAL(12,2),
    cancellation_date  DATE,
    cancellation_fee  DECIMAL(14,2),
    CONSTRAINT pk_operator_order PRIMARY KEY (order_id),
    CONSTRAINT fk_operator_order_1 FOREIGN KEY (order_id) REFERENCES AIRCRAFT_ORDER (order_id) ON DELETE CASCADE,
    CONSTRAINT ck_op_cancel CHECK ((cancellation_date IS NULL AND cancellation_fee IS NULL) OR (cancellation_date IS NOT NULL AND cancellation_fee IS NOT NULL))
);
