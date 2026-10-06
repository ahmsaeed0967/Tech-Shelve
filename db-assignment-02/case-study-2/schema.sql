-- CS-2005 Assignment 02 - Case Study 2: Islamabad Digital Media Center (relational schema, Chapter 9 mapping)

CREATE TABLE GENRE (
    genre_id  INT NOT NULL,
    genre_name  VARCHAR(50) NOT NULL,
    CONSTRAINT pk_genre PRIMARY KEY (genre_id),
    CONSTRAINT uq_genre_1 UNIQUE (genre_name)
);

CREATE TABLE CREATOR (
    creator_id  INT NOT NULL,
    name  VARCHAR(100) NOT NULL,
    CONSTRAINT pk_creator PRIMARY KEY (creator_id)
);

CREATE TABLE TITLE (
    iscn  VARCHAR(20) NOT NULL,
    title_name  VARCHAR(150) NOT NULL,
    description  CLOB,
    language  VARCHAR(30) NOT NULL,
    format  VARCHAR(10) NOT NULL,
    edition  VARCHAR(20),
    genre_id  INT NOT NULL,
    CONSTRAINT pk_title PRIMARY KEY (iscn),
    CONSTRAINT fk_title_1 FOREIGN KEY (genre_id) REFERENCES GENRE (genre_id),
    CONSTRAINT ck_title_format CHECK (format IN ('PHYSICAL', 'DIGITAL'))
);

CREATE TABLE TITLE_CREATOR (
    iscn  VARCHAR(20) NOT NULL,
    creator_id  INT NOT NULL,
    CONSTRAINT pk_title_creator PRIMARY KEY (iscn, creator_id),
    CONSTRAINT fk_title_creator_1 FOREIGN KEY (iscn) REFERENCES TITLE (iscn) ON DELETE CASCADE,
    CONSTRAINT fk_title_creator_2 FOREIGN KEY (creator_id) REFERENCES CREATOR (creator_id)
);

CREATE TABLE WISHLIST_TITLE (
    iscn  VARCHAR(20) NOT NULL,
    reason  VARCHAR(100) NOT NULL,
    date_added  DATE NOT NULL,
    CONSTRAINT pk_wishlist_title PRIMARY KEY (iscn),
    CONSTRAINT fk_wishlist_title_1 FOREIGN KEY (iscn) REFERENCES TITLE (iscn) ON DELETE CASCADE
);

CREATE TABLE ITEM (
    iscn  VARCHAR(20) NOT NULL,
    copy_no  INT NOT NULL,
    issuable  CHAR(1) NOT NULL,
    item_class  VARCHAR(30),
    CONSTRAINT pk_item PRIMARY KEY (iscn, copy_no),
    CONSTRAINT fk_item_1 FOREIGN KEY (iscn) REFERENCES TITLE (iscn) ON DELETE CASCADE,
    CONSTRAINT ck_item_issuable CHECK (issuable IN ('Y', 'N'))
);

CREATE TABLE MEMBER (
    member_no  INT NOT NULL,
    name  VARCHAR(100) NOT NULL,
    cnic  CHAR(13) NOT NULL,
    campus_address  VARCHAR(200) NOT NULL,
    home_address  VARCHAR(200),
    photo  VARCHAR(255),
    card_issue_date  DATE NOT NULL,
    CONSTRAINT pk_member PRIMARY KEY (member_no),
    CONSTRAINT uq_member_1 UNIQUE (cnic)
);

CREATE TABLE MEMBER_CONTACT (
    member_no  INT NOT NULL,
    contact_no  VARCHAR(15) NOT NULL,
    CONSTRAINT pk_member_contact PRIMARY KEY (member_no, contact_no),
    CONSTRAINT fk_member_contact_1 FOREIGN KEY (member_no) REFERENCES MEMBER (member_no) ON DELETE CASCADE
);

CREATE TABLE FACULTY_MEMBER (
    member_no  INT NOT NULL,
    employee_id  INT NOT NULL,
    CONSTRAINT pk_faculty_member PRIMARY KEY (member_no),
    CONSTRAINT uq_faculty_member_1 UNIQUE (employee_id),
    CONSTRAINT fk_faculty_member_1 FOREIGN KEY (member_no) REFERENCES MEMBER (member_no) ON DELETE CASCADE
);

CREATE TABLE REGULAR_MEMBER (
    member_no  INT NOT NULL,
    CONSTRAINT pk_regular_member PRIMARY KEY (member_no),
    CONSTRAINT fk_regular_member_1 FOREIGN KEY (member_no) REFERENCES MEMBER (member_no) ON DELETE CASCADE
);

CREATE TABLE STAFF (
    staff_id  INT NOT NULL,
    name  VARCHAR(100) NOT NULL,
    CONSTRAINT pk_staff PRIMARY KEY (staff_id)
);

CREATE TABLE CHIEF_CURATOR (
    staff_id  INT NOT NULL,
    CONSTRAINT pk_chief_curator PRIMARY KEY (staff_id),
    CONSTRAINT fk_chief_curator_1 FOREIGN KEY (staff_id) REFERENCES STAFF (staff_id) ON DELETE CASCADE
);

CREATE TABLE ASSOCIATE_CURATOR (
    staff_id  INT NOT NULL,
    CONSTRAINT pk_associate_curator PRIMARY KEY (staff_id),
    CONSTRAINT fk_associate_curator_1 FOREIGN KEY (staff_id) REFERENCES STAFF (staff_id) ON DELETE CASCADE
);

CREATE TABLE INFORMATION_CURATOR (
    staff_id  INT NOT NULL,
    CONSTRAINT pk_information_curator PRIMARY KEY (staff_id),
    CONSTRAINT fk_information_curator_1 FOREIGN KEY (staff_id) REFERENCES STAFF (staff_id) ON DELETE CASCADE
);

CREATE TABLE CENTER_ASSISTANT (
    staff_id  INT NOT NULL,
    CONSTRAINT pk_center_assistant PRIMARY KEY (staff_id),
    CONSTRAINT fk_center_assistant_1 FOREIGN KEY (staff_id) REFERENCES STAFF (staff_id) ON DELETE CASCADE
);

CREATE TABLE ISSUING_STAFF (
    staff_id  INT NOT NULL,
    CONSTRAINT pk_issuing_staff PRIMARY KEY (staff_id),
    CONSTRAINT fk_issuing_staff_1 FOREIGN KEY (staff_id) REFERENCES STAFF (staff_id) ON DELETE CASCADE
);

CREATE TABLE LOAN (
    loan_id  INT NOT NULL,
    issue_date  DATE NOT NULL,
    due_date  DATE NOT NULL,
    return_date  DATE,
    reminder_date  DATE,
    member_no  INT NOT NULL,
    iscn  VARCHAR(20) NOT NULL,
    copy_no  INT NOT NULL,
    staff_id  INT NOT NULL,
    CONSTRAINT pk_loan PRIMARY KEY (loan_id),
    CONSTRAINT fk_loan_1 FOREIGN KEY (member_no) REFERENCES MEMBER (member_no),
    CONSTRAINT fk_loan_2 FOREIGN KEY (iscn, copy_no) REFERENCES ITEM (iscn, copy_no),
    CONSTRAINT fk_loan_3 FOREIGN KEY (staff_id) REFERENCES ISSUING_STAFF (staff_id),
    CONSTRAINT ck_loan_due CHECK (due_date >= issue_date),
    CONSTRAINT ck_loan_return CHECK (return_date IS NULL OR return_date >= issue_date)
);
