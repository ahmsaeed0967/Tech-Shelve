-- CS-2005 Assignment 02 - Case Study 1: Art Gallery Network "Picasso" (relational schema, Chapter 9 mapping with option 8A)

CREATE TABLE PAINTER (
    pid  INT NOT NULL,
    fname  VARCHAR(30) NOT NULL,
    lname  VARCHAR(30) NOT NULL,
    CONSTRAINT pk_painter PRIMARY KEY (pid)
);

CREATE TABLE MANAGER (
    mid  INT NOT NULL,
    name  VARCHAR(60) NOT NULL,
    CONSTRAINT pk_manager PRIMARY KEY (mid)
);

CREATE TABLE MANAGER_CONTACT (
    mid  INT NOT NULL,
    contactno  VARCHAR(15) NOT NULL,
    CONSTRAINT pk_manager_contact PRIMARY KEY (mid, contactno),
    CONSTRAINT fk_manager_contact_1 FOREIGN KEY (mid) REFERENCES MANAGER (mid) ON DELETE CASCADE
);

CREATE TABLE GALLERY (
    gid  INT NOT NULL,
    location  VARCHAR(100) NOT NULL,
    mid  INT NOT NULL,
    CONSTRAINT pk_gallery PRIMARY KEY (gid),
    CONSTRAINT fk_gallery_1 FOREIGN KEY (mid) REFERENCES MANAGER (mid)
);

CREATE TABLE OFFER (
    offerid  INT NOT NULL,
    offertitle  VARCHAR(60) NOT NULL,
    offerstartdate  DATE NOT NULL,
    offerexpirydate  DATE NOT NULL,
    gid  INT NOT NULL,
    CONSTRAINT pk_offer PRIMARY KEY (offerid),
    CONSTRAINT fk_offer_1 FOREIGN KEY (gid) REFERENCES GALLERY (gid),
    CONSTRAINT ck_offer_dates CHECK (offerexpirydate >= offerstartdate)
);

CREATE TABLE BOOMOFFER (
    offerid  INT NOT NULL,
    giftoffered  VARCHAR(60) NOT NULL,
    CONSTRAINT pk_boomoffer PRIMARY KEY (offerid),
    CONSTRAINT fk_boomoffer_1 FOREIGN KEY (offerid) REFERENCES OFFER (offerid) ON DELETE CASCADE
);

CREATE TABLE COOLOFFER (
    offerid  INT NOT NULL,
    offerdiscount  DECIMAL(5,2) NOT NULL,
    CONSTRAINT pk_cooloffer PRIMARY KEY (offerid),
    CONSTRAINT fk_cooloffer_1 FOREIGN KEY (offerid) REFERENCES OFFER (offerid) ON DELETE CASCADE,
    CONSTRAINT ck_discount CHECK (offerdiscount BETWEEN 0 AND 100)
);

CREATE TABLE CUSTOMER (
    cid  INT NOT NULL,
    name  VARCHAR(60) NOT NULL,
    offerid  INT NOT NULL,
    CONSTRAINT pk_customer PRIMARY KEY (cid),
    CONSTRAINT fk_customer_1 FOREIGN KEY (offerid) REFERENCES OFFER (offerid)
);

CREATE TABLE MEMBER (
    cid  INT NOT NULL,
    memno  INT NOT NULL,
    visitno  INT NOT NULL,
    CONSTRAINT pk_member PRIMARY KEY (cid),
    CONSTRAINT uq_member_1 UNIQUE (memno),
    CONSTRAINT fk_member_1 FOREIGN KEY (cid) REFERENCES CUSTOMER (cid) ON DELETE CASCADE,
    CONSTRAINT ck_visitno CHECK (visitno >= 0)
);

CREATE TABLE NON_MEMBER (
    cid  INT NOT NULL,
    CONSTRAINT pk_non_member PRIMARY KEY (cid),
    CONSTRAINT fk_non_member_1 FOREIGN KEY (cid) REFERENCES CUSTOMER (cid) ON DELETE CASCADE
);

CREATE TABLE PAINTING (
    pnid  INT NOT NULL,
    title  VARCHAR(100) NOT NULL,
    exhibition_date  DATE NOT NULL,
    pid  INT NOT NULL,
    gid  INT NOT NULL,
    cid  INT,
    CONSTRAINT pk_painting PRIMARY KEY (pnid),
    CONSTRAINT fk_painting_1 FOREIGN KEY (pid) REFERENCES PAINTER (pid),
    CONSTRAINT fk_painting_2 FOREIGN KEY (gid) REFERENCES GALLERY (gid),
    CONSTRAINT fk_painting_3 FOREIGN KEY (cid) REFERENCES CUSTOMER (cid)
);

CREATE TABLE WATERCOLOUR (
    pnid  INT NOT NULL,
    x  VARCHAR(50) NOT NULL,
    CONSTRAINT pk_watercolour PRIMARY KEY (pnid),
    CONSTRAINT fk_watercolour_1 FOREIGN KEY (pnid) REFERENCES PAINTING (pnid) ON DELETE CASCADE
);

CREATE TABLE OILS (
    pnid  INT NOT NULL,
    y  VARCHAR(50) NOT NULL,
    CONSTRAINT pk_oils PRIMARY KEY (pnid),
    CONSTRAINT fk_oils_1 FOREIGN KEY (pnid) REFERENCES PAINTING (pnid) ON DELETE CASCADE
);

CREATE TABLE OTHER_PAINTING (
    pnid  INT NOT NULL,
    other  VARCHAR(50) NOT NULL,
    CONSTRAINT pk_other_painting PRIMARY KEY (pnid),
    CONSTRAINT fk_other_painting_1 FOREIGN KEY (pnid) REFERENCES PAINTING (pnid) ON DELETE CASCADE
);

CREATE TABLE VISITS (
    gid  INT NOT NULL,
    cid  INT NOT NULL,
    CONSTRAINT pk_visits PRIMARY KEY (gid, cid),
    CONSTRAINT fk_visits_1 FOREIGN KEY (gid) REFERENCES GALLERY (gid),
    CONSTRAINT fk_visits_2 FOREIGN KEY (cid) REFERENCES CUSTOMER (cid)
);
