# CS-2005 Database Systems - Assignment 02
## Case Study 1: Art Gallery Network "Picasso"

Files in this folder: `case-study-1.drawio` (EER diagram, open in draw.io), `schema.sql` (tested DDL), this document.
Notation: Elmasri/Navathe, exactly as in the Chapter 4 and Chapter 9 slides. "Ch4 s22" means Chapter 4 slide 22, "Ch9 s32" means Chapter 9 slide 32.

---

## 1. EER Diagram

Open `case-study-1.drawio` in draw.io. To put it in the PDF: *File > Export as > PDF*, tick "Fit to 1 page", landscape.

**How to read a (min,max) pair:** the pair written next to an entity on its line to a relationship says how many times ONE entity of that type takes part in that relationship (Ch9 s46 uses the same pairs).

| # | Relationship | Left end | Right end | Type | Attribute on the relationship |
|---|---|---|---|---|---|
| 1 | PAINTS | PAINTER (1,N) | PAINTING (1,1) | 1:N | - |
| 2 | EXHIBITED_IN | PAINTING (1,1) | GALLERY (1,N) | 1:N | ExhibitionDate |
| 3 | PURCHASES | CUSTOMER (0,N) | PAINTING (0,1) | 1:N | - |
| 4 | VISITS | GALLERY (0,N) | CUSTOMER (1,N) | M:N | - |
| 5 | MANAGES | MANAGER (1,N) | GALLERY (1,1) | 1:N | - |
| 6 | OFFERS | GALLERY (2,2) | OFFER (1,1) | 1:N | - |
| 7 | AVAILS | CUSTOMER (1,1) | OFFER (0,N) | 1:N | - |

| Superclass | Subclasses (own attributes) | Circle | Line to circle |
|---|---|---|---|
| PAINTING | WATERCOLOUR (x), OILS (y), OTHER_PAINTING (other) | **o** overlapping | double = total |
| CUSTOMER | MEMBER (memno, visitno), NON_MEMBER (none) | **d** disjoint | double = total |
| OFFER | BOOMOFFER (giftoffered), COOLOFFER (offerdiscount) | **d** disjoint | double = total |

Other symbols: underlined oval = primary key; `pname` has two sub-ovals (composite); `contactno` is a double oval (multivalued); the cup symbol on subclass lines is the subset symbol (subclass is a subset of superclass, Ch4 s5). There are no weak entities, so no double rectangles or double diamonds are needed: every entity has its own identifier.

---

## 2. Relational Schema

`[PK]` primary key, `[FK -> Table(col)]` foreign key. Standard SQL types. Full DDL: `schema.sql`.

**PAINTER** (Ch9 Step 1; composite `pname` becomes its simple components, Ch9 s23)

| Column | Type | Key | Constraints | Why |
|---|---|---|---|---|
| pid | INT | [PK] | NOT NULL | identifier given in the case study |
| fname | VARCHAR(30) | | NOT NULL | component of pname; an artist must be identifiable by name |
| lname | VARCHAR(30) | | NOT NULL | component of pname |

**MANAGER** (Step 1)

| Column | Type | Key | Constraints | Why |
|---|---|---|---|---|
| mid | INT | [PK] | NOT NULL | identifier |
| name | VARCHAR(60) | | NOT NULL | "name has to be stored" |

**MANAGER_CONTACT** (Step 6: multivalued attribute `contactno` gets its own table, Ch9 s15)

| Column | Type | Key | Constraints | Why |
|---|---|---|---|---|
| mid | INT | [PK][FK -> MANAGER(mid)] | NOT NULL, ON DELETE CASCADE | a number has no meaning without its manager |
| contactno | VARCHAR(15) | [PK] | NOT NULL | VARCHAR, not INT: phone numbers carry `+` and leading zeros. Composite PK (mid, contactno) stops the same number being stored twice for one manager |

**GALLERY** (Step 1 + Step 4: MANAGES is 1:N so the FK goes on the N side, Ch9 s11)

| Column | Type | Key | Constraints | Why |
|---|---|---|---|---|
| gid | INT | [PK] | NOT NULL | "gid is used as primary key" |
| location | VARCHAR(100) | | NOT NULL | stored for every gallery |
| mid | INT | [FK -> MANAGER(mid)] | NOT NULL | "managed by exactly one manager" = (1,1) = NOT NULL FK. No UNIQUE, because one manager may manage many galleries |

**OFFER** (Step 1 + Step 4 for OFFERS + Step 8C for the disjoint, total specialization, Ch9 s32)

| Column | Type | Key | Constraints | Why |
|---|---|---|---|---|
| offerid | INT | [PK] | NOT NULL | identifier shared by both offer types |
| offertitle | VARCHAR(60) | | NOT NULL | common attribute |
| offerstartdate | DATE | | NOT NULL | common attribute |
| offerexpirydate | DATE | | NOT NULL, CHECK (offerexpirydate >= offerstartdate) | an offer cannot end before it starts |
| offer_type | VARCHAR(4) | | NOT NULL, CHECK IN ('BOOM','COOL') | the 8C type attribute: one value per row gives *disjoint*, NOT NULL gives *total* |
| giftoffered | VARCHAR(60) | | NULL allowed | BoomOffer only |
| offerdiscount | DECIMAL(5,2) | | NULL allowed, CHECK BETWEEN 0 AND 100 | CoolOffer only; percentage |
| gid | INT | [FK -> GALLERY(gid)] | NOT NULL | OFFERS (1,1) |
| | | | UNIQUE (gid, offer_type) | a gallery has at most one offer of each type, so with two types the maximum of (2,2) holds |
| | | | CHECK (BOOM => giftoffered NOT NULL and offerdiscount NULL; COOL => the reverse) | each type carries only its own attribute |

**CUSTOMER** (Step 1 + Step 4 for AVAILS + Step 8C)

| Column | Type | Key | Constraints | Why |
|---|---|---|---|---|
| cid | INT | [PK] | NOT NULL | identifier |
| name | VARCHAR(60) | | NOT NULL | "name has to be stored" |
| customer_type | VARCHAR(10) | | NOT NULL, CHECK IN ('MEMBER','NON_MEMBER') | 8C type attribute: a customer can never be both (disjoint) and must be one of the two (total) |
| memno | INT | | UNIQUE, NULL allowed | MEMBER only; a member number identifies one member |
| visitno | INT | | CHECK (visitno >= 0), NULL allowed | MEMBER only |
| offerid | INT | [FK -> OFFER(offerid)] | NOT NULL | AVAILS (1,1): exactly one offer per customer. No UNIQUE, because an offer can be availed by many customers (0,N) |
| | | | CHECK (MEMBER => memno and visitno NOT NULL; NON_MEMBER => both NULL) | member-only attributes appear only on members |

**PAINTING** (Step 1 + Step 4 for PAINTS, EXHIBITED_IN, PURCHASES)

| Column | Type | Key | Constraints | Why |
|---|---|---|---|---|
| pnid | INT | [PK] | NOT NULL | identifier |
| title | VARCHAR(100) | | NOT NULL | "title has to be stored" |
| exhibition_date | DATE | | NOT NULL | attribute of EXHIBITED_IN; in a 1:N relationship it moves to the N side (Ch9 s11: "include any simple attributes of the 1:N relation type"). NOT NULL because every painting is exhibited exactly once |
| pid | INT | [FK -> PAINTER(pid)] | NOT NULL | PAINTS (1,1) |
| gid | INT | [FK -> GALLERY(gid)] | NOT NULL | EXHIBITED_IN (1,1) |
| cid | INT | [FK -> CUSTOMER(cid)] | NULL allowed | PURCHASES (0,1): NULL means not sold yet |

**WATERCOLOUR / OILS / OTHER_PAINTING** (Step 8A: superclass table plus one table per subclass, same key, Ch9 s26)

| Table | Column | Type | Key | Constraints | Why |
|---|---|---|---|---|---|
| WATERCOLOUR | pnid | INT | [PK][FK -> PAINTING(pnid)] | NOT NULL, ON DELETE CASCADE | a subclass entity is the same entity as the superclass one (Ch4 s7) |
| | x | VARCHAR(50) | | NOT NULL | distinguishing attribute |
| OILS | pnid | INT | [PK][FK -> PAINTING(pnid)] | NOT NULL, ON DELETE CASCADE | same |
| | y | VARCHAR(50) | | NOT NULL | distinguishing attribute |
| OTHER_PAINTING | pnid | INT | [PK][FK -> PAINTING(pnid)] | NOT NULL, ON DELETE CASCADE | same |
| | other | VARCHAR(50) | | NOT NULL | distinguishing attribute |

**VISITS** (Step 5: the only M:N relationship, Ch9 s13)

| Column | Type | Key | Constraints | Why |
|---|---|---|---|---|
| gid | INT | [PK][FK -> GALLERY(gid)] | NOT NULL | |
| cid | INT | [PK][FK -> CUSTOMER(cid)] | NOT NULL | the pair (gid, cid) is the key, so the same visit pair is stored once |

---

## 3. Design Justification

### 3.1 Entities
- **PAINTER, PAINTING, GALLERY, CUSTOMER, MANAGER**: each is a real-world thing with its own identifier (pid, pnid, gid, cid, mid), so each is a strong entity.
- **OFFER** is a *generalization* (Ch4 s14-15): BoomOffer and CoolOffer share four attributes (offerId, offertitle, offerexpirydate, offerstartdate) and differ in one each (giftoffered, offerdiscount). Pulling the shared part into OFFER is the same move as CAR and TRUCK into VEHICLE. It also lets both offer types take part in OFFERS and AVAILS once.
- **MEMBER / NON_MEMBER** and **WATERCOLOUR / OILS / OTHER_PAINTING** are subclasses because the case study gives them attributes or rules of their own.
- **No weak entity**: nothing depends on another entity for its identity.

### 3.2 Relationships and cardinality choices
Each pair comes from a sentence in the case study.

| Relationship | Sentence | Why this pair |
|---|---|---|
| PAINTS | "each painting will be painted by exactly one painter" / "no painter who has not painted any painting" | painting (1,1), painter (1,N) |
| EXHIBITED_IN | "exhibited at exactly one gallery" / "no gallery without painting" | painting (1,1), gallery (1,N). ExhibitionDate "is neither attribute of painting nor gallery", so it hangs on the relationship |
| PURCHASES | "zero, one or many paintings" / "sold out to only one customer" / "some paintings not sold" | customer (0,N), painting (0,1) |
| VISITS | "gallery not visited by any customer" / "no customer who has not visited any gallery" | gallery (0,N), customer (1,N). Many on both sides means M:N |
| MANAGES | "exactly one manager" / "one or more than one gallery" | gallery (1,1), manager (1,N) |
| OFFERS | "exactly two types of different promotions" | gallery (2,2): one BoomOffer plus one CoolOffer (assumption A4) |
| AVAILS | "exactly one offer" / "one, none or multiple customers" | customer (1,1), offer (0,N) |

### 3.3 Specialization choices
- **CUSTOMER: disjoint, total.** "Exactly two types" means every customer is one of them (total). "Never a non-member and vice versa" means never both (disjoint). Ch4 s22 and s24.
- **OFFER: disjoint, total.** "Exactly two types" again; an offer is either a Boomoffer or a CoolOffer.
- **PAINTING: overlapping, total.** "A single painting can belong to multiple categories" means a painting can be in more than one subclass (overlapping, letter **o**). "Categorized into watercolour, oils and many others" with `OTHER_PAINTING` as the catch-all subclass means every painting falls in at least one (total).

**Mapping option per specialization** (Ch9 s38 comparison table; Ch9 s42 shows a schema that mixes options):

| Specialization | Option | Reason |
|---|---|---|
| CUSTOMER | 8C (one table, one type attribute) | disjoint and total; NON_MEMBER has no attributes of its own, so a separate table would hold only a key. One NOT NULL type column enforces disjoint and total with no trigger |
| OFFER | 8C | same argument; only one extra attribute per subclass |
| PAINTING | 8A (superclass table + subclass tables) | overlapping: 8C cannot store two types in one column, and 8A "works for any specialization" (Ch9 s26). Subclass attributes stay NOT NULL in their own tables |

### 3.4 Constraints and how they are enforced
| Rule | Declared in DDL? | How |
|---|---|---|
| exactly one (1,1): painting-painter, painting-gallery, gallery-manager, offer-gallery, customer-offer | Yes | FK column NOT NULL |
| (0,1): painting-customer | Yes | FK column nullable |
| max = N | nothing needed | no limit |
| min 1 on the "one" side: painter (1,N), gallery in EXHIBITED_IN (1,N), manager (1,N), customer in VISITS (1,N) | **No** | a parent row can exist before any child row, so plain SQL cannot say "at least one child". Enforced by transaction order, deferred trigger or application |
| gallery has exactly 2 offers (2,2) | max yes, min no | UNIQUE (gid, offer_type) plus the type CHECK give the maximum; the minimum needs a trigger or application check |
| customer disjoint and total; offer disjoint and total | Yes | `customer_type` / `offer_type` NOT NULL + CHECK IN (...) |
| painting overlapping | Yes | subclass tables are independent, so one pnid may appear in several |
| painting total (in at least one category table) | No | trigger or application |
| **C1**: non-member may avail only a BoomOffer | **No** | needs a value from another table (OFFER.offer_type), which CHECK cannot read; use a trigger, test query in `schema.sql` |
| CHECKs on dates, discount range, visitno | Yes | basic domain sanity |

### 3.5 Assumptions
| # | Assumption | Academic justification |
|---|---|---|
| A1 | pid, pnid, cid, mid, offerId are primary keys, like gid | the case study calls them "identifier"; mid is read the same way |
| A2 | Typos read as: "Iname" = lname; CoolOffer's "offered" = offerId; "offerstartdateand" = offerstartdate | CoolOffer must have the same key as BoomOffer or the generalization to OFFER would not work |
| A3 | BoomOffer and CoolOffer are generalized into OFFER (disjoint, total) | four shared attributes (Ch4 s14: classes with common features are generalized) |
| A4 | A gallery has exactly one BoomOffer and one CoolOffer; each offer belongs to one gallery | "exactly two types" read literally gives (2,2); the text never says an offer is shared. If the instructor means many offers per type, change (2,2) to (2,N) and drop UNIQUE (gid, offer_type); nothing else changes |
| A5 | Every customer avails exactly one offer, and it need not belong to a gallery the customer visited | "exactly one offer" gives (1,1); no link between AVAILS and VISITS is stated |
| A6 | PAINTING specialization is overlapping and total, with OTHER_PAINTING as catch-all and `other` as its attribute | "multiple categories" gives overlapping; three attributes x, y, other "respectively" imply three subclasses. If read as partial, change the double line to a single line and nothing in the schema changes |
| A7 | x, y, other are placeholder attributes, typed VARCHAR(50) | the case study gives names but no types |
| A8 | offerdiscount is a percentage (DECIMAL(5,2), 0 to 100); giftoffered is text | type not stated; percentage is the usual meaning of a discount |
| A9 | memno is a unique member number; visitno is the member's visit count (INT, >= 0) | "visitno" is not defined; either reading is a plain INT |
| A10 | Only pname is composite; customer name and manager name are simple | the case study divides only pname |
| A11 | A manager has at least one contact number | "contactno has to be stored"; a minimum of 1 cannot be declared in SQL |
| A12 | VISITS has no attributes and a customer-gallery pair is stored once | no visit date is mentioned; composite PK (gid, cid) |
| A13 | A painting is exhibited at one gallery at a time, with no history | "exactly one gallery"; hence ExhibitionDate sits in PAINTING |
| A14 | SQL is DBMS-neutral. UNIQUE allows several NULLs (MySQL, PostgreSQL, Oracle) and CHECK is enforced (MySQL 8.0.16+) | needed so non-members can share a NULL memno |

---

## 4. Viva Defence Cheatsheet

- **Cardinality ko aise parhein:** (min,max) entity ke paas likha ho to matlab "us side ki EK entity relationship mein kitni baar aa sakti hai". Misal: PAINTING (1,1) EXHIBITED_IN GALLERY (1,N), kyunke har painting exactly ek gallery mein hai aur "no gallery without painting". Jahan ek side (x,1) ho, wahan FK usi side ke table mein jaata hai (Ch9 Step 4). ExhibitionDate relationship ki attribute hai, is liye wo FK wale PAINTING table mein gayi.
- **CUSTOMER aur OFFER dono disjoint + total (d, double line):** "exactly two types" matlab total, "member kabhi non-member nahi" matlab disjoint. OFFER ek generalization hai kyunke Boomoffer aur CoolOffer ke 4 attributes common hain, sirf giftoffered aur offerdiscount alag.
- **PAINTING overlapping + total (o, double line):** "ek painting multiple categories mein" matlab overlapping. "Others" catch-all subclass hai, is liye har painting kam az kam ek category mein, yani total. Agar professor partial kahe to sirf double line ko single line kar do, schema nahi badalta.
- **Mapping ka reason:** disjoint specialization ko ek table + type column (8C) se map kiya, kyunke ek NOT NULL type column hi disjoint + total guarantee kar deta hai. Overlapping PAINTING ko 8A (superclass + subclass tables) se, kyunke ek type column mein do types nahi aa sakte. Sirf VISITS M:N hai, is liye wohi alag table hai. "Non-member sirf Boomoffer" rule diagram mein note (C1) hai aur DDL mein trigger se lagega, CHECK doosre table ko nahi dekh sakta.

---

## 5. Slide map (where each rule comes from)

| Used for | Slide |
|---|---|
| subclass, superclass, IS-A, subset symbol | Ch4 s4-7 |
| generalization (OFFER) | Ch4 s14-16 |
| disjoint (d) / overlapping (o) | Ch4 s22-23 |
| total (double line) / partial (single line), four combinations | Ch4 s24-25 |
| Step 1 regular entities, composite attribute | Ch9 s4, s23 |
| Step 4 binary 1:N (FK on N side, relationship attributes move) | Ch9 s11-12 |
| Step 5 binary M:N | Ch9 s13-14 |
| Step 6 multivalued attribute | Ch9 s15-16 |
| Step 8A, 8C and comparison of options, mixing options | Ch9 s25-26, s32, s38, s42 |
| (min,max) pairs on an ER diagram | Ch9 s46 |
| Steps not needed (no weak entity, 1:1, n-ary, recursive, category) | Ch9 s7, s9, s17, s20, s43 |
