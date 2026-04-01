/*
====================================================================
PROJECT: Appointment Booking Database Tutorial
TOOLS: MySQL, Lucidchart
LEVEL: Beginner
====================================================================

PROJECT PURPOSE:
This project teaches beginners how to:
1. Create a simple relational database
2. Understand primary keys and foreign keys
3. Import or insert data into related tables
4. Join tables together
5. Answer basic business questions with SQL

BUSINESS SCENARIO:
A small appointment-based business needs a database to track:
- customers
- services
- staff members
- appointments

This project can represent a salon, tutoring business,
consulting service, wellness studio, or similar small business.

DATABASE DESIGN IDEA:
The "appointments" table is the central table because it connects:
- one customer
- one service
- one staff member
- one appointment date/time
- one appointment status

RELATIONSHIPS:
- One customer can have many appointments
- One service can appear in many appointments
- One staff member can handle many appointments

TUTORIAL NOTE:
This script is written with extra comments to help beginner SQL
learners understand what each section is doing.
====================================================================
*/


/*
====================================================================
STEP 1: CREATE THE DATABASE
====================================================================

This creates the database if it does not already exist.

"IF NOT EXISTS" prevents an error if the database was already created.
*/

CREATE DATABASE IF NOT EXISTS appointment_project;


/*
Now tell MySQL to use this database for all upcoming work.
Without USE, MySQL may try to run commands in the wrong database.
*/

USE appointment_project;


/*
====================================================================
STEP 2: OPTIONAL CLEANUP FOR RE-RUNNING THE SCRIPT
====================================================================

If you want to run this script again from scratch, uncomment the
DROP TABLE statements below.

IMPORTANT:
We drop the child table first ("appointments") because it depends
on the parent tables through foreign keys.
*/

/*
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS customers;
*/


/*
====================================================================
STEP 3: CREATE THE TABLES
====================================================================

A table stores data in rows and columns.

Each table should have:
- a name
- columns
- data types
- constraints when needed

KEY TERMS:
- PRIMARY KEY: uniquely identifies each row in a table
- FOREIGN KEY: creates a relationship to another table
- VARCHAR(n): variable-length text up to n characters
- INT: whole number
- DECIMAL(10,2): number with 2 decimal places, useful for prices
- DATETIME: date + time
*/


/*
--------------------------------------------------------------------
TABLE: customers
--------------------------------------------------------------------

PURPOSE:
Stores basic customer information.

GRAIN:
One row = one customer

PRIMARY KEY:
customer_id

NOTE:
A customer can appear many times in the appointments table,
but only once in the customers table.
*/

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100)
);


/*
--------------------------------------------------------------------
TABLE: services
--------------------------------------------------------------------

PURPOSE:
Stores the services offered by the business.

GRAIN:
One row = one service

PRIMARY KEY:
service_id

EXAMPLES:
Haircut, Consultation, Styling, Coloring
*/

CREATE TABLE services (
    service_id INT PRIMARY KEY,
    service_name VARCHAR(100),
    duration_minutes INT,
    price DECIMAL(10,2)
);


/*
--------------------------------------------------------------------
TABLE: staff
--------------------------------------------------------------------

PURPOSE:
Stores staff members who provide the services.

GRAIN:
One row = one staff member

PRIMARY KEY:
staff_id
*/

CREATE TABLE staff (
    staff_id INT PRIMARY KEY,
    staff_name VARCHAR(100),
    role VARCHAR(50)
);


/*
--------------------------------------------------------------------
TABLE: appointments
--------------------------------------------------------------------

PURPOSE:
Stores each appointment booked by the business.

GRAIN:
One row = one appointment

PRIMARY KEY:
appointment_id

FOREIGN KEYS:
customer_id -> customers(customer_id)
service_id  -> services(service_id)
staff_id    -> staff(staff_id)

WHY THIS TABLE IS IMPORTANT:
This is the central transactional table because it connects
customers, services, and staff together.
*/

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    customer_id INT,
    service_id INT,
    staff_id INT,
    appointment_date DATETIME,
    status VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (service_id) REFERENCES services(service_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);


/*
====================================================================
STEP 4: HOW TO LOAD DATA
====================================================================

You have two common options:

OPTION A: Import CSV files using MySQL Workbench
- Right-click the desired table
- Choose "Table Data Import Wizard"
- Select the CSV file
- Follow the prompts

OPTION B: Insert data using SQL INSERT statements
- This is useful for tutorials and portfolios
- It shows your SQL skills more clearly

IMPORTANT LOAD ORDER:
Import or insert parent tables first:
1. customers
2. services
3. staff
4. appointments

WHY?
Because appointments contains foreign keys.
The referenced rows must already exist in the parent tables.
*/


/*
====================================================================
STEP 5: INSERT SAMPLE DATA
====================================================================

This sample data gives us enough records to test joins,
grouping, counts, and revenue calculations.
*/


/*
Insert sample customers
*/
INSERT INTO customers (customer_id, first_name, last_name, phone, email) VALUES
(1, 'Ana', 'Rivera', '8175551001', 'ana@email.com'),
(2, 'John', 'Smith', '8175551002', 'john@email.com'),
(3, 'Laura', 'Gomez', '8175551003', 'laura@email.com'),
(4, 'David', 'Lee', '8175551004', 'david@email.com'),
(5, 'Maria', 'Lopez', '8175551005', 'maria@email.com');


/*
Insert sample services
*/
INSERT INTO services (service_id, service_name, duration_minutes, price) VALUES
(1, 'Haircut', 45, 35.00),
(2, 'Coloring', 90, 85.00),
(3, 'Consultation', 30, 20.00),
(4, 'Styling', 60, 50.00);


/*
Insert sample staff members
*/
INSERT INTO staff (staff_id, staff_name, role) VALUES
(1, 'Sophia', 'Stylist'),
(2, 'Daniel', 'Color Specialist'),
(3, 'Emma', 'Consultant');


/*
Insert sample appointments

NOTICE:
The customer_id, service_id, and staff_id values here must already
exist in their corresponding parent tables.
*/
INSERT INTO appointments (
    appointment_id,
    customer_id,
    service_id,
    staff_id,
    appointment_date,
    status
) VALUES
(1, 1, 1, 1, '2026-03-01 09:00:00', 'Completed'),
(2, 2, 2, 2, '2026-03-01 11:00:00', 'Completed'),
(3, 3, 3, 3, '2026-03-02 10:30:00', 'Cancelled'),
(4, 1, 4, 1, '2026-03-03 14:00:00', 'Completed'),
(5, 4, 1, 1, '2026-03-04 09:30:00', 'Scheduled'),
(6, 5, 2, 2, '2026-03-04 13:00:00', 'Completed'),
(7, 2, 3, 3, '2026-03-05 15:00:00', 'Completed'),
(8, 3, 1, 1, '2026-03-06 10:00:00', 'Scheduled');


/*
====================================================================
STEP 6: VALIDATE THE DATA
====================================================================

Before doing analysis, always check that:
- the data loaded correctly
- the tables contain the expected rows
- nothing is missing
*/


/*
View all rows from each table
*/
SELECT * FROM customers;
SELECT * FROM services;
SELECT * FROM staff;
SELECT * FROM appointments;


/*
Count rows in each table

WHY DO THE COUNTS DIFFER?
The customers, services, and staff tables store unique entities.
The appointments table stores transactions/events, so it will
usually have more rows over time.
*/
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_services FROM services;
SELECT COUNT(*) AS total_staff FROM staff;
SELECT COUNT(*) AS total_appointments FROM appointments;


/*
====================================================================
STEP 7: CREATE A FULL APPOINTMENT VIEW USING JOINS
====================================================================

PURPOSE:
Show complete appointment details by combining multiple tables.

WHY JOINS MATTER:
The appointments table stores IDs, but IDs alone are not very
readable for business users.

For example:
- customer_id = 1 is less useful than "Ana Rivera"
- service_id = 2 is less useful than "Coloring"

INNER JOIN LOGIC:
Only returns rows where matching records exist in both tables.
Since appointments should always link to valid parent rows,
INNER JOIN is appropriate here.
*/

SELECT
    a.appointment_id,
    c.first_name,
    c.last_name,
    s.service_name,
    st.staff_name,
    a.appointment_date,
    a.status
FROM appointments a
JOIN customers c
    ON a.customer_id = c.customer_id
JOIN services s
    ON a.service_id = s.service_id
JOIN staff st
    ON a.staff_id = st.staff_id
ORDER BY a.appointment_date;


/*
====================================================================
STEP 8: BUSINESS QUESTION 1
How many appointments has each customer booked?
====================================================================

PURPOSE:
Count the number of appointments linked to each customer.

WHY LEFT JOIN?
We want to include all customers, even if one has zero appointments.

WHY COUNT(a.appointment_id)?
COUNT(column_name) only counts non-NULL values.
If a customer has no matching appointment, that appointment_id
will be NULL, so the count becomes 0.

WHY GROUP BY MULTIPLE COLUMNS?
Because customer_id, first_name, and last_name all appear in
the SELECT list without aggregation.
*/

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(a.appointment_id) AS total_appointments
FROM customers c
LEFT JOIN appointments a
    ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_appointments DESC;


/*
====================================================================
STEP 9: BUSINESS QUESTION 2
Which services are booked most often?
====================================================================

PURPOSE:
Measure service popularity.

WHY LEFT JOIN?
To include every service, even if some services have never
been booked.

HOW THE JOIN WORKS:
- Start with the services table
- Match appointments that use each service_id
- If there is no match, appointment columns become NULL
- COUNT(a.appointment_id) then counts only actual bookings
*/

SELECT
    s.service_name,
    COUNT(a.appointment_id) AS times_booked
FROM services s
LEFT JOIN appointments a
    ON s.service_id = a.service_id
GROUP BY s.service_name
ORDER BY times_booked DESC;


/*
====================================================================
STEP 10: BUSINESS QUESTION 3
Which staff member handled the most appointments?
====================================================================

PURPOSE:
Compare workload across staff members.

WHY LEFT JOIN?
To include staff members even if they currently have zero
appointments.
*/

SELECT
    st.staff_name,
    COUNT(a.appointment_id) AS total_appointments
FROM staff st
LEFT JOIN appointments a
    ON st.staff_id = a.staff_id
GROUP BY st.staff_name
ORDER BY total_appointments DESC;


/*
====================================================================
STEP 11: BUSINESS QUESTION 4
What is the total revenue from completed appointments?
====================================================================

PURPOSE:
Calculate actual earned revenue.

WHY FILTER ON status = 'Completed'?
Scheduled appointments have not happened yet.
Cancelled appointments did not generate revenue.

WHY JOIN TO services?
The appointment table tells us which service was booked,
but the service price is stored in the services table.
*/

SELECT
    ROUND(SUM(s.price), 2) AS total_revenue
FROM appointments a
JOIN services s
    ON a.service_id = s.service_id
WHERE a.status = 'Completed';


/*
====================================================================
STEP 12: BUSINESS QUESTION 5
What is revenue by service?
====================================================================

PURPOSE:
Show which services generate the most revenue.

WHAT THIS QUERY DOES:
- filters to completed appointments only
- counts how many times each service was completed
- sums service price to calculate revenue
- sorts highest revenue first
*/

SELECT
    s.service_name,
    COUNT(a.appointment_id) AS completed_bookings,
    ROUND(SUM(s.price), 2) AS revenue
FROM appointments a
JOIN services s
    ON a.service_id = s.service_id
WHERE a.status = 'Completed'
GROUP BY s.service_name
ORDER BY revenue DESC;


/*
====================================================================
STEP 13: BUSINESS QUESTION 6
Which days have the most bookings?
====================================================================

PURPOSE:
Summarize booking volume by calendar day.

WHY DATE(appointment_date)?
appointment_date is stored as DATETIME, which includes both
date and time.

DATE(appointment_date) removes the time portion so that all
appointments from the same day are grouped together.
*/

SELECT
    DATE(appointment_date) AS booking_day,
    COUNT(*) AS total_bookings
FROM appointments
GROUP BY DATE(appointment_date)
ORDER BY booking_day;


/*
====================================================================
STEP 14: OPTIONAL BEGINNER PRACTICE QUERIES
====================================================================

These extra queries are helpful for reinforcing filtering,
sorting, and grouping.
*/


/*
Practice 1:
Show only completed appointments
*/
SELECT *
FROM appointments
WHERE status = 'Completed';


/*
Practice 2:
Show services that cost more than 40 dollars
*/
SELECT *
FROM services
WHERE price > 40.00
ORDER BY price DESC;


/*
Practice 3:
Show appointments scheduled after March 3, 2026
*/
SELECT *
FROM appointments
WHERE appointment_date > '2026-03-03 00:00:00'
ORDER BY appointment_date;


/*
Practice 4:
Count appointments by status
*/
SELECT
    status,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY status
ORDER BY total_appointments DESC;


/*
====================================================================
STEP 15: CONNECTION TO LUCIDCHART
====================================================================

Before building the tables in MySQL, this database can be mapped
visually in Lucidchart using an Entity Relationship Diagram (ERD).

TABLES IN THE ERD:
- customers
- services
- staff
- appointments

PRIMARY KEYS:
- customers.customer_id
- services.service_id
- staff.staff_id
- appointments.appointment_id

FOREIGN KEYS:
- appointments.customer_id -> customers.customer_id
- appointments.service_id  -> services.service_id
- appointments.staff_id    -> staff.staff_id

WHY THIS MATTERS:
Lucidchart helps beginners see the structure visually before
working with SQL code.
*/


/*
====================================================================
STEP 16: HOW TO EXPLAIN THIS PROJECT
====================================================================

Portfolio version:
"I designed a small relational database for an appointment-based
business by first mapping the entities, attributes, and key
relationships in an ERD. I then implemented the schema in MySQL,
loaded sample data, and wrote SQL queries to analyze bookings,
service demand, staff workload, and revenue."

Beginner teaching version:
"This project teaches how database design and SQL work together.
The ERD shows the structure visually, and the SQL code turns that
structure into working tables and analysis queries."
====================================================================
*/