
-- A. Check Data Uploads

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;


-- B. CRUD Operations (Create, Read, Update, Delete)

-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;


-- Task 2. Update an Existing Member's Address**

SELECT * FROM members;

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';  

-- Task 3. Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table. (Fahrenheit 451)

SELECT * FROM issued_status;

DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4. Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status;

SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';      -- 2 records returned


-- Task 5. List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT * FROM issued_status;

SELECT 
	issued_member_id,
	COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY 2;			-- 6 rows returned ordered by count

-- C. CTAS (Create Table As Select)

-- Task 6. Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

SELECT *
FROM books AS b
JOIN 
issued_status as ist
ON ist.issued_book_isbn = b.isbn;

CREATE TABLE book_issued_cnt AS  -- to review orders
	SELECT 
		b.isbn, 
		b.book_title, 
		COUNT(ist.issued_id) AS issue_count
	FROM issued_status as ist		-- ist refers to issue table
	JOIN books as b
	ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title; 

SELECT * FROM book_issued_cnt;


-- D. Data Analysis & Findings

-- The following SQL queries were used to address specific questions:

-- Task 7. Retrieve All Books in a Specific Category

SELECT * FROM books;

SELECT DISTINCT (category)
FROM books;

SELECT *
FROM books
WHERE category = 'Classic';     --9 rows returned

-- Task 8. Find Total Rental Income by Category

SELECT * FROM books;

SELECT
	b.category,
	SUM(b.rental_price) as rental_income,
	COUNT(*)
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1
ORDER BY 2 desc;

-- Task 9. List Members Who Registered in the Last 180 Days
	   
SELECT * FROM members;

SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Task 10. List Employees ID, name, branch ID, and their Branch Manager's Name and manager ID 

SELECT * FROM employees;
SELECT * FROM branch;

SELECT *
FROM employees as e1
JOIN
branch as b
ON b.branch_id = e1.branch_id;

SELECT *
FROM employees as e1
JOIN
branch as b
ON b.branch_id = e1.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id;

SELECT
	e1.emp_id,
	e1.emp_name,
	b.branch_id,
	b.manager_id,
	e2.emp_name as manager
FROM employees as e1
JOIN branch as b
ON b.branch_id = e1.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id;


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold (above 7.00)

Select * from books;

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;		-- 7 rows

SELECT * FROM expensive_books;

-- Task 12. Retrieve the List of Books Not Yet Returned

SELECT * FROM issued_status;
SELECT * FROM return_status;

SELECT DISTINCT ist.issued_book_name 
FROM issued_status as ist
LEFT JOIN 
return_status as rs
ON ist.issued_id = rs.issued_id     -- ; add to view all books
WHERE rs.return_id IS Null;			-- 19 books not returned

-- Advanced SQL Operations

INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

-- Adding new column in return_status

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');


-- Task 13. Identify Members with Overdue Books; Write a query to identify members who have overdue books 
-- (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
SELECT * FROM  books;
SELECT * FROM  issued_status;
SELECT * FROM  members;
SELECT * FROM  return_status;

SELECT
	ist.issued_member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	CURRENT_DATE - ist.issued_date AS days_over_due
FROM issued_status as ist
JOIN 
members AS m
	ON m.member_id = ist.issued_member_id
JOIN 
books AS b
	ON b.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON ist.issued_id = rs.issued_id    
WHERE 
	rs.return_date IS Null		-- 24 not returned
AND 
	(CURRENT_DATE - ist.issued_date) > 30
ORDER BY  1;					-- 20 rows returned


-- 
/* Task 14: Update Book Status on Return 
Write a query to update the status of books in the books table to "Yes"-- when they are returned (based on entries 
in the return_status table).
*/

SELECT * FROM  books;
SELECT * FROM  issued_status;
SELECT * FROM  return_status;

--1st the manual updates

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2'

SELECT * FROM  issued_status
WHERE issued_book_isbn = '978-0-451-52994-2';

SELECT * FROM  return_status
WHERE issued_id = 'IS130';  -- not returned

INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
VALUES
('RS125', 'IS130', 'CURRENT_DATE' 'Good');

SELECT * FROM return_status
WHERE issued_id ='IS130';

UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-451-52994-2'

SELECT * FROM books
Where isbn = '978-0-451-52994-2';


--  Task 14 stored procedures for automatic update

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10)) 
LANGUAGE plpgsql
AS $$

DECLARE   -- declare all variables
	v_isbn VARCHAR(50);  -- define data type used in issued_book_isbn column in issued_book table, and book table
	v_book_name VARCHAR(80);

BEGIN
	-- all procedure logic and code goes between begin and end
	-- return_date is entered by the system
	-- book_quality is entered by the employee
	-- inserting into return_status based on user input
	INSERT INTO return_status(return_id, issued_id, return_date, book_quality)   
	VALUES
	(p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);  

	SELECT 
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn,    -- saving variable
		v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;

	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank you for returning the book %', v_book_name;  -- python command

END;
$$

CALL add_return_records();     -- call the procedure name to run it in the future


--  Test automatic return records procedure

SELECT * FROM  books
WHERE status = 'no';  -- example, isbn 978-0-307-58837-1, issued_id IS13

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1'; 

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

SELECT * FROM return_status

DELETE FROM return_status
WHERE issued_id = 'IS135';

DELETE FROM return_status
WHERE issued_id = 'IS140';

-- Call Procedure add_return_records

CALL add_return_records('RS138', 'IS135', 'Good');  -- Correct book name returned

CALL add_return_records('RS148', 'IS140', 'Good');


-- 
/* Task 15: Branch Performance Report  
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/

SELECT * FROM branch;
SELECT * FROM issued_status;
SELECT * FROM  return_status;
SELECT * FROM  books;
SELECT * FROM  book_issued_cnt;

CREATE TABLE branch_report
AS
SELECT 
	b.branch_id,
	b.manager_id,
	b.branch_address,
	COUNT(ist.issued_id) AS number_of_books_issued,
	COUNT(rst.return_id) AS number_of_books_returned, 
	SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN 
employees AS emp
	ON emp.emp_id = ist.issued_emp_id
JOIN 
branch AS b
	ON b.branch_id = emp.branch_id
LEFT JOIN
return_status AS rst
	ON ist.issued_id = rst.issued_id
JOIN
books AS bk
	ON ist.issued_book_isbn = bk.isbn
GROUP BY 1,2
ORDER BY 6 DESC;

SELECT * 
FROM branch_report;

/*
Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued 
at least one book in the last 6 months.
*/

SELECT CURRENT_DATE - INTERVAL '6 month';

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT
					DISTINCT(issued_member_id)
				FROM issued_status  
				WHERE issued_date >= CURRENT_DATE - INTERVAL '6 month'
				);

SELECT * FROM active_members;

/*
Task 17: Find Employees with the Most Book Issues Processed  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number 
of books processed, and their branch.
*/

SELECT 
	emp.emp_name,
	COUNT(ist.issued_id) AS total_books_issued
	b.branch_id,
FROM
issued_status AS ist
JOIN 
employees AS emp
	ON emp.emp_id = ist.issued_emp_id
JOIN
branch AS b
	ON emp.branch_id = b.branch_id
GROUP BY 1,2
ORDER BY 3 desc;

/*
Task 18: Identify Members Issuing High-Risk Books  
Write a query to identify members who have issued books more than twice with the status "damaged" in the 
books table. Display the member name, book title, and the number of times they've issued damaged books.  
*/
SELECT * FROM books;
SELECT * FROM  return_status;
SELECT * FROM issued_status;

SELECT 
	m.member_name,
	bk.book_title,
	COUNT(r.book_quality) AS total_damaged_books_issued
FROM
issued_status AS ist
JOIN 
members AS m
	ON ist.issued_member_id = m.member_id
JOIN
return_status AS r
	ON ist.issued_id = r.issued_id
JOIN
books AS bk
	ON bk.isbn = ist.issued_book_isbn
WHERE r.book_quality = 'Damaged'
GROUP BY 1,2;
	
/*
Task 19: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.
Description:  Write a stored procedure that updates the status of a book in the library based on its issuance. The 
procedure should function as follows: 
 - The stored procedure should take the book_id as an input parameter. 
 - 1, The procedure should first check if the book is available (status = 'yes'). If the book is available, 2, it should be 
 issued, and 3, the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), 
 the procedure should return an error message indicating that the book is currently not available.
*/

SELECT * FROM books;
SELECT * FROM issued_status;
--

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), 
							p_issued_member_id VARCHAR(10),
							p_issued_book_isbn VARCHAR(25),
							p_issued_emp_id VARCHAR(10)
							)
LANGUAGE plpgsql
AS $$

DECLARE   -- declare all variables
	v_status VARCHAR(15);  -- define data type used 
	
BEGIN
	-- all procedure logic and code 
	
-- Check if book is available, 'yes'
	SELECT 
		status
		INTO
		v_status
	From books
	WHERE isbn = p_issued_book_isbn;   

	IF 	v_status = 'yes' THEN
			INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id) 
			VALUES(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
			
			UPDATE books
				SET status = 'no'
			WHERE isbn = p_issued_book_isbn;
			
			RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;  -- python command
			
	ELSE
		RAISE NOTICE 'The book you requested is currently unavailable. book_isbn: %', p_issued_book_isbn;
	END IF;
END;
$$

--  Test the function

SELECT * FROM books;
-- '978-0-553-29698-2' is status yes
-- '978-0-375-41398-8' is status no

SELECT * FROM issued_status;
-- IS155
-- IS156

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');     -- call the procedure name to run it in the future

CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-553-29698-2';  -- shows no

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';  --still shows no, because it wasn't available


/* Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have 
issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/

CREATE TABLE past_due_books
AS
SELECT 
	m.member_id,
	m.member_name,
	COUNT(m.member_id) AS books_overdue,
	SUM((CURRENT_DATE - (ist.issued_date + INTERVAL '30 days')::DATE) * 0.50) AS total_fines
FROM
	members AS m
JOIN
issued_status AS ist
	ON m.member_id = ist.issued_member_id
JOIN
books AS b
	ON b.isbn = ist.issued_book_isbn
LEFT JOIN
return_status AS ret
	ON ist.issued_id = ret.issued_id
WHERE return_date IS NULL
	AND CURRENT_DATE - (ist.issued_date + INTERVAL '30 Days')::DATE > 0
GROUP BY 1,2;

SELECT * FROM past_due_books;

