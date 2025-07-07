-- Library Management System Project

-- Create the Branch table

CREATE TABLE branch
	(
			branch_id VARCHAR(10) PRIMARY KEY,	
			manager_id	VARCHAR(10),
			branch_address VARCHAR(50),	
			contact_no VARCHAR(10)
);

-- Create the Employees table

CREATE TABLE employees
	(
		emp_id VARCHAR(10) PRIMARY KEY,
		emp_name VARCHAR(25),	
		position VARCHAR(15),	
		salary INT,	
		branch_id VARCHAR(25)  --FK
	);

-- Create the Books table

CREATE TABLE books
	(
		isbn VARCHAR(20) PRIMARY KEY,	
		book_title VARCHAR(75),
		category VARCHAR(25),	
		rental_price FLOAT,	
		status	VARCHAR(15),
		author	VARCHAR(35),
		publisher VARCHAR(55)
);

-- Create the Members table

CREATE TABLE members
	(
		member_id  VARCHAR(10) PRIMARY KEY,	
		member_name	VARCHAR(25),
		member_address	VARCHAR(75),
		reg_date DATE
	);

--Create the Issued Status table

CREATE TABLE issued_status
	(
		issued_id  VARCHAR(10) PRIMARY KEY,
		issued_member_id  VARCHAR(10), -- FK
		issued_book_name  VARCHAR(75),
		issued_date	DATE,
		issued_book_isbn  VARCHAR(25),	--FK
		issued_emp_id VARCHAR(10)  --FK
	);

--Create the Return_Status table

CREATE TABLE return_status
	(
		return_id  VARCHAR(10) PRIMARY KEY,
		issued_id  VARCHAR(10),
		return_book_name  VARCHAR(75),	
		return_date	DATE,
		return_book_isbn  VARCHAR(25)
	);

-- Add Foreign Keys

ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_staus
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);




