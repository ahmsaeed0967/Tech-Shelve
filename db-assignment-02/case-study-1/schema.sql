-- =====================================================================
-- CS-2005 Database Systems - Assignment 02 - Case Study 1
-- Art Gallery Network "Picasso"  -  relational schema (DDL)
-- Mapping rules follow Chapter 9 slides (Steps 1, 4, 5, 6, 8A, 8C).
-- Tables are listed in dependency order (parents before children).
-- =====================================================================

-- Step 1 (regular entity) + composite pname -> fname, lname (Table 7.1)
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

-- Step 6: multivalued attribute contactno -> its own table
CREATE TABLE MANAGER_CONTACT (
    mid        INT         NOT NULL,
    contactno  VARCHAR(15) NOT NULL,
    CONSTRAINT pk_manager_contact PRIMARY KEY (mid, contactno),
    CONSTRAINT fk_mc_manager FOREIGN KEY (mid)
        REFERENCES MANAGER (mid) ON DELETE CASCADE
);

-- Step 1 + Step 4: MANAGES is 1:N, so the FK goes on the N side (GALLERY)
CREATE TABLE GALLERY (
    gid       INT          NOT NULL,
    location  VARCHAR(100) NOT NULL,
    mid       INT          NOT NULL,                 -- MANAGES (1,1)
    CONSTRAINT pk_gallery PRIMARY KEY (gid),
    CONSTRAINT fk_gallery_manager FOREIGN KEY (mid) REFERENCES MANAGER (mid)
);

-- Step 1 + Step 4 (OFFERS) + Step 8C (disjoint, total specialization:
-- one table, one type attribute). BOOMOFFER / COOLOFFER live in this table.
CREATE TABLE OFFER (
    offerid          INT           NOT NULL,
    offertitle       VARCHAR(60)   NOT NULL,
    offerstartdate   DATE          NOT NULL,
    offerexpirydate  DATE          NOT NULL,
    offer_type       VARCHAR(4)    NOT NULL,         -- 8C type attribute
    giftoffered      VARCHAR(60),                    -- BOOMOFFER only
    offerdiscount    DECIMAL(5,2),                   -- COOLOFFER only (percent)
    gid              INT           NOT NULL,         -- OFFERS (1,1)
    CONSTRAINT pk_offer PRIMARY KEY (offerid),
    CONSTRAINT fk_offer_gallery FOREIGN KEY (gid) REFERENCES GALLERY (gid),
    CONSTRAINT uq_offer_gallery_type UNIQUE (gid, offer_type),   -- max 1 of each type per gallery => (2,2)
    CONSTRAINT ck_offer_type CHECK (offer_type IN ('BOOM', 'COOL')),
    CONSTRAINT ck_offer_dates CHECK (offerexpirydate >= offerstartdate),
    CONSTRAINT ck_offer_discount CHECK (offerdiscount IS NULL OR offerdiscount BETWEEN 0 AND 100),
    CONSTRAINT ck_offer_subclass CHECK (
           (offer_type = 'BOOM' AND giftoffered  IS NOT NULL AND offerdiscount IS NULL)
        OR (offer_type = 'COOL' AND offerdiscount IS NOT NULL AND giftoffered  IS NULL))
);

-- Step 1 + Step 4 (AVAILS) + Step 8C (disjoint, total specialization:
-- MEMBER / NON_MEMBER live in this table, told apart by customer_type).
CREATE TABLE CUSTOMER (
    cid            INT         NOT NULL,
    name           VARCHAR(60) NOT NULL,
    customer_type  VARCHAR(10) NOT NULL,             -- 8C type attribute
    memno          INT,                              -- MEMBER only
    visitno        INT,                              -- MEMBER only
    offerid        INT         NOT NULL,             -- AVAILS (1,1)
    CONSTRAINT pk_customer PRIMARY KEY (cid),
    CONSTRAINT uq_customer_memno UNIQUE (memno),
    CONSTRAINT fk_customer_offer FOREIGN KEY (offerid) REFERENCES OFFER (offerid),
    CONSTRAINT ck_customer_type CHECK (customer_type IN ('MEMBER', 'NON_MEMBER')),
    CONSTRAINT ck_customer_subclass CHECK (
           (customer_type = 'MEMBER'     AND memno IS NOT NULL AND visitno IS NOT NULL)
        OR (customer_type = 'NON_MEMBER' AND memno IS NULL     AND visitno IS NULL)),
    CONSTRAINT ck_customer_visitno CHECK (visitno IS NULL OR visitno >= 0)
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

-- Step 8A (overlapping, total specialization: superclass table + one table
-- per subclass, each sharing the superclass key)
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

-- Step 5: VISITS is the only M:N relationship -> relationship table whose
-- primary key is the combination of the two foreign keys
CREATE TABLE VISITS (
    gid  INT NOT NULL,
    cid  INT NOT NULL,
    CONSTRAINT pk_visits PRIMARY KEY (gid, cid),
    CONSTRAINT fk_visits_gallery  FOREIGN KEY (gid) REFERENCES GALLERY (gid),
    CONSTRAINT fk_visits_customer FOREIGN KEY (cid) REFERENCES CUSTOMER (cid)
);

-- =====================================================================
-- Rules that plain DDL cannot declare (checked by trigger / application):
-- =====================================================================
-- C1  A NON_MEMBER may avail only a BOOM offer.  This query must return 0 rows:
--     SELECT c.cid
--     FROM   CUSTOMER c JOIN OFFER o ON o.offerid = c.offerid
--     WHERE  c.customer_type = 'NON_MEMBER' AND o.offer_type <> 'BOOM';
--
-- C2  Minimum participation of 1 on the "one" side of a 1:N relationship
--     (painter has >= 1 painting, gallery has >= 1 painting, manager manages
--     >= 1 gallery, customer visited >= 1 gallery, gallery has exactly 2 offers)
--     and "every painting is in >= 1 category table" are enforced by
--     transaction logic / deferred triggers.
