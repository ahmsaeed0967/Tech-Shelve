-- =====================================================================
-- CS-2005 Database Systems - Assignment 02 - Case Study 1
-- Art Gallery Network "Picasso"  -  relational schema (DDL)
-- Mapping follows Chapter 9: Step 1 (entities), 4 (1:N), 5 (M:N),
-- 6 (multivalued), 8A (every specialization: superclass table + one table
-- per subclass). Every rectangle in the EER diagram is a table here.
-- Tables are listed parents-first.
-- =====================================================================

-- Step 1; composite pname -> fname, lname
CREATE TABLE PAINTER (
    pid    INT         NOT NULL,
    fname  VARCHAR(30) NOT NULL,
    lname  VARCHAR(30) NOT NULL,
    CONSTRAINT pk_painter PRIMARY KEY (pid)
);

-- Step 1
CREATE TABLE MANAGER (
    mid   INT         NOT NULL,
    name  VARCHAR(60) NOT NULL,
    CONSTRAINT pk_manager PRIMARY KEY (mid)
);

-- Step 6: multivalued attribute contactno
CREATE TABLE MANAGER_CONTACT (
    mid        INT         NOT NULL,
    contactno  VARCHAR(15) NOT NULL,
    CONSTRAINT pk_manager_contact PRIMARY KEY (mid, contactno),
    CONSTRAINT fk_mc_manager FOREIGN KEY (mid)
        REFERENCES MANAGER (mid) ON DELETE CASCADE
);

-- Step 1 + Step 4 (MANAGES is 1:N, FK on the N side)
CREATE TABLE GALLERY (
    gid       INT          NOT NULL,
    location  VARCHAR(100) NOT NULL,
    mid       INT          NOT NULL,                 -- MANAGES (1,1)
    CONSTRAINT pk_gallery PRIMARY KEY (gid),
    CONSTRAINT fk_gallery_manager FOREIGN KEY (mid) REFERENCES MANAGER (mid)
);

-- Step 1 + Step 4 (OFFERS). Superclass of BOOMOFFER / COOLOFFER.
CREATE TABLE OFFER (
    offerid          INT         NOT NULL,
    offertitle       VARCHAR(60) NOT NULL,
    offerstartdate   DATE        NOT NULL,
    offerexpirydate  DATE        NOT NULL,
    gid              INT         NOT NULL,           -- OFFERS (1,1)
    CONSTRAINT pk_offer PRIMARY KEY (offerid),
    CONSTRAINT fk_offer_gallery FOREIGN KEY (gid) REFERENCES GALLERY (gid),
    CONSTRAINT ck_offer_dates CHECK (offerexpirydate >= offerstartdate)
);

-- Step 8A subclasses of OFFER
CREATE TABLE BOOMOFFER (
    offerid      INT         NOT NULL,
    giftoffered  VARCHAR(60) NOT NULL,
    CONSTRAINT pk_boomoffer PRIMARY KEY (offerid),
    CONSTRAINT fk_boomoffer_offer FOREIGN KEY (offerid)
        REFERENCES OFFER (offerid) ON DELETE CASCADE
);

CREATE TABLE COOLOFFER (
    offerid        INT          NOT NULL,
    offerdiscount  DECIMAL(5,2) NOT NULL,            -- percent
    CONSTRAINT pk_cooloffer PRIMARY KEY (offerid),
    CONSTRAINT fk_cooloffer_offer FOREIGN KEY (offerid)
        REFERENCES OFFER (offerid) ON DELETE CASCADE,
    CONSTRAINT ck_cooloffer_discount CHECK (offerdiscount BETWEEN 0 AND 100)
);

-- Step 1 + Step 4 (AVAILS). Superclass of MEMBER / NON_MEMBER.
CREATE TABLE CUSTOMER (
    cid      INT         NOT NULL,
    name     VARCHAR(60) NOT NULL,
    offerid  INT         NOT NULL,                   -- AVAILS (1,1)
    CONSTRAINT pk_customer PRIMARY KEY (cid),
    CONSTRAINT fk_customer_offer FOREIGN KEY (offerid) REFERENCES OFFER (offerid)
);

-- Step 8A subclasses of CUSTOMER
CREATE TABLE MEMBER (
    cid      INT NOT NULL,
    memno    INT NOT NULL,
    visitno  INT NOT NULL,
    CONSTRAINT pk_member PRIMARY KEY (cid),
    CONSTRAINT uq_member_memno UNIQUE (memno),
    CONSTRAINT fk_member_customer FOREIGN KEY (cid)
        REFERENCES CUSTOMER (cid) ON DELETE CASCADE,
    CONSTRAINT ck_member_visitno CHECK (visitno >= 0)
);

CREATE TABLE NON_MEMBER (
    cid  INT NOT NULL,
    CONSTRAINT pk_non_member PRIMARY KEY (cid),
    CONSTRAINT fk_non_member_customer FOREIGN KEY (cid)
        REFERENCES CUSTOMER (cid) ON DELETE CASCADE
);

-- Step 1 + Step 4 (PAINTS, EXHIBITED_IN, PURCHASES). exhibition_date is the
-- attribute of the 1:N relationship EXHIBITED_IN, so it moves to the N side.
CREATE TABLE PAINTING (
    pnid             INT          NOT NULL,
    title            VARCHAR(100) NOT NULL,
    exhibition_date  DATE         NOT NULL,          -- EXHIBITED_IN attribute
    pid              INT          NOT NULL,          -- PAINTS (1,1)
    gid              INT          NOT NULL,          -- EXHIBITED_IN (1,1)
    cid              INT,                            -- PURCHASES (0,1): NULL = unsold
    CONSTRAINT pk_painting PRIMARY KEY (pnid),
    CONSTRAINT fk_painting_painter  FOREIGN KEY (pid) REFERENCES PAINTER (pid),
    CONSTRAINT fk_painting_gallery  FOREIGN KEY (gid) REFERENCES GALLERY (gid),
    CONSTRAINT fk_painting_customer FOREIGN KEY (cid) REFERENCES CUSTOMER (cid)
);

-- Step 8A subclasses of PAINTING
CREATE TABLE WATERCOLOUR (
    pnid  INT         NOT NULL,
    x     VARCHAR(50) NOT NULL,
    CONSTRAINT pk_watercolour PRIMARY KEY (pnid),
    CONSTRAINT fk_watercolour_painting FOREIGN KEY (pnid)
        REFERENCES PAINTING (pnid) ON DELETE CASCADE
);

CREATE TABLE OILS (
    pnid  INT         NOT NULL,
    y     VARCHAR(50) NOT NULL,
    CONSTRAINT pk_oils PRIMARY KEY (pnid),
    CONSTRAINT fk_oils_painting FOREIGN KEY (pnid)
        REFERENCES PAINTING (pnid) ON DELETE CASCADE
);

CREATE TABLE OTHER_PAINTING (
    pnid   INT         NOT NULL,
    other  VARCHAR(50) NOT NULL,
    CONSTRAINT pk_other_painting PRIMARY KEY (pnid),
    CONSTRAINT fk_other_painting FOREIGN KEY (pnid)
        REFERENCES PAINTING (pnid) ON DELETE CASCADE
);

-- Step 5: VISITS is the only M:N relationship
CREATE TABLE VISITS (
    gid  INT NOT NULL,
    cid  INT NOT NULL,
    CONSTRAINT pk_visits PRIMARY KEY (gid, cid),
    CONSTRAINT fk_visits_gallery  FOREIGN KEY (gid) REFERENCES GALLERY (gid),
    CONSTRAINT fk_visits_customer FOREIGN KEY (cid) REFERENCES CUSTOMER (cid)
);

-- =====================================================================
-- Rules plain DDL cannot declare. Each query must return 0 rows; they are
-- meant to be enforced by triggers / transaction logic.
-- =====================================================================
-- C1  A NON_MEMBER may avail only a BOOM offer
--     SELECT n.cid FROM NON_MEMBER n JOIN CUSTOMER c ON c.cid = n.cid
--     JOIN COOLOFFER co ON co.offerid = c.offerid;
-- C2  Disjoint: no customer in both MEMBER and NON_MEMBER
--     SELECT m.cid FROM MEMBER m JOIN NON_MEMBER n ON n.cid = m.cid;
-- C3  Total: every customer is in MEMBER or NON_MEMBER
--     SELECT c.cid FROM CUSTOMER c
--     WHERE c.cid NOT IN (SELECT cid FROM MEMBER) AND c.cid NOT IN (SELECT cid FROM NON_MEMBER);
-- C4  Disjoint + total for OFFER: no offer in both BOOMOFFER and COOLOFFER,
--     none in neither (same pattern as C2 and C3)
-- C5  Total (overlapping allowed) for PAINTING: every painting is in at least
--     one of WATERCOLOUR, OILS, OTHER_PAINTING
-- C6  Gallery has exactly one BoomOffer and one CoolOffer (2,2)
--     SELECT g.gid FROM GALLERY g
--     WHERE (SELECT COUNT(*) FROM OFFER o JOIN BOOMOFFER b ON b.offerid = o.offerid WHERE o.gid = g.gid) <> 1
--        OR (SELECT COUNT(*) FROM OFFER o JOIN COOLOFFER c ON c.offerid = o.offerid WHERE o.gid = g.gid) <> 1;
-- C7  Minimum 1 on the "one" side of 1:N / M:N: painter has >= 1 painting,
--     gallery has >= 1 painting, manager manages >= 1 gallery,
--     customer has visited >= 1 gallery
