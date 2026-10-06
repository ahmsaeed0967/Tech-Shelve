-- CS-2005 Assignment 02 - Case Study 4: Journal of E-Commerce Research Knowledge (relational schema, Chapter 9 mapping)

CREATE TABLE AUTHOR (
    author_id  INT NOT NULL,
    author_name  VARCHAR(100) NOT NULL,
    mailing_address  VARCHAR(200) NOT NULL,
    email  VARCHAR(100) NOT NULL,
    affiliation  VARCHAR(150),
    CONSTRAINT pk_author PRIMARY KEY (author_id)
);

CREATE TABLE MANUSCRIPT (
    manuscript_no  INT NOT NULL,
    title  VARCHAR(200) NOT NULL,
    date_received  DATE NOT NULL,
    status  VARCHAR(12) NOT NULL,
    CONSTRAINT pk_manuscript PRIMARY KEY (manuscript_no),
    CONSTRAINT ck_ms_status CHECK (status IN ('received', 'rejected', 'under review', 'accepted', 'scheduled', 'published'))
);

CREATE TABLE WRITES (
    manuscript_no  INT NOT NULL,
    author_id  INT NOT NULL,
    author_order  INT NOT NULL,
    CONSTRAINT pk_writes PRIMARY KEY (manuscript_no, author_id),
    CONSTRAINT uq_writes_1 UNIQUE (manuscript_no, author_order),
    CONSTRAINT fk_writes_1 FOREIGN KEY (manuscript_no) REFERENCES MANUSCRIPT (manuscript_no) ON DELETE CASCADE,
    CONSTRAINT fk_writes_2 FOREIGN KEY (author_id) REFERENCES AUTHOR (author_id),
    CONSTRAINT ck_writes_order CHECK (author_order >= 1)
);

CREATE TABLE REVIEWER (
    reviewer_no  INT NOT NULL,
    reviewer_name  VARCHAR(100) NOT NULL,
    email  VARCHAR(100) NOT NULL,
    affiliation  VARCHAR(150),
    CONSTRAINT pk_reviewer PRIMARY KEY (reviewer_no)
);

CREATE TABLE AREA_OF_INTEREST (
    is_code  VARCHAR(10) NOT NULL,
    description  VARCHAR(100) NOT NULL,
    CONSTRAINT pk_area_of_interest PRIMARY KEY (is_code)
);

CREATE TABLE HAS_INTEREST (
    reviewer_no  INT NOT NULL,
    is_code  VARCHAR(10) NOT NULL,
    CONSTRAINT pk_has_interest PRIMARY KEY (reviewer_no, is_code),
    CONSTRAINT fk_has_interest_1 FOREIGN KEY (reviewer_no) REFERENCES REVIEWER (reviewer_no) ON DELETE CASCADE,
    CONSTRAINT fk_has_interest_2 FOREIGN KEY (is_code) REFERENCES AREA_OF_INTEREST (is_code)
);

CREATE TABLE REVIEWS (
    manuscript_no  INT NOT NULL,
    reviewer_no  INT NOT NULL,
    date_sent  DATE NOT NULL,
    appropriateness_rating  INT,
    clarity_rating  INT,
    methodology_rating  INT,
    contribution_rating  INT,
    recommendation  VARCHAR(6),
    feedback_date  DATE,
    CONSTRAINT pk_reviews PRIMARY KEY (manuscript_no, reviewer_no),
    CONSTRAINT fk_reviews_1 FOREIGN KEY (manuscript_no) REFERENCES MANUSCRIPT (manuscript_no) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_2 FOREIGN KEY (reviewer_no) REFERENCES REVIEWER (reviewer_no),
    CONSTRAINT ck_rev_ratings CHECK ((appropriateness_rating BETWEEN 1 AND 10 OR appropriateness_rating IS NULL) AND (clarity_rating BETWEEN 1 AND 10 OR clarity_rating IS NULL) AND (methodology_rating BETWEEN 1 AND 10 OR methodology_rating IS NULL) AND (contribution_rating BETWEEN 1 AND 10 OR contribution_rating IS NULL)),
    CONSTRAINT ck_rev_rec CHECK (recommendation IS NULL OR recommendation IN ('accept', 'reject')),
    CONSTRAINT ck_rev_dates CHECK (feedback_date IS NULL OR feedback_date >= date_sent)
);

CREATE TABLE ISSUE (
    issue_id  INT NOT NULL,
    issue_period  VARCHAR(6) NOT NULL,
    issue_year  INT NOT NULL,
    volume  INT NOT NULL,
    issue_number  INT NOT NULL,
    print_date  DATE,
    CONSTRAINT pk_issue PRIMARY KEY (issue_id),
    CONSTRAINT uq_issue_1 UNIQUE (volume, issue_number),
    CONSTRAINT ck_issue_period CHECK (issue_period IN ('fall', 'winter', 'spring', 'summer'))
);

CREATE TABLE ACCEPTED_MANUSCRIPT (
    manuscript_no  INT NOT NULL,
    date_accepted  DATE NOT NULL,
    number_of_pages  INT,
    issue_id  INT,
    begin_page  INT,
    order_in_issue  INT,
    CONSTRAINT pk_accepted_manuscript PRIMARY KEY (manuscript_no),
    CONSTRAINT uq_accepted_manuscript_1 UNIQUE (issue_id, order_in_issue),
    CONSTRAINT fk_accepted_manuscript_1 FOREIGN KEY (manuscript_no) REFERENCES MANUSCRIPT (manuscript_no) ON DELETE CASCADE,
    CONSTRAINT fk_accepted_manuscript_2 FOREIGN KEY (issue_id) REFERENCES ISSUE (issue_id),
    CONSTRAINT ck_acc_pages CHECK (number_of_pages IS NULL OR number_of_pages > 0),
    CONSTRAINT ck_acc_sched CHECK ((issue_id IS NULL AND begin_page IS NULL AND order_in_issue IS NULL) OR (issue_id IS NOT NULL AND begin_page IS NOT NULL AND order_in_issue IS NOT NULL))
);
