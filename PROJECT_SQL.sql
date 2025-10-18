CREATE DATABASE EMPLOYEDB;
USE EMPLOYEDB;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);


-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

SELECT * FROM EMPLOYEE;
SELECT * FROM JOBDEPARTMENT;
SELECT * FROM LEAVES;
SELECT * FROM PAYROLL;
SELECT * FROM QUALIFICATION;
SELECT * FROM SALARYBONUS;


## Analysis Questions
##  EMPLOYEE INSIGHTS
-- 1.How many unique employees are currently in the system?

SELECT 
COUNT(DISTINCT EMP_ID) AS UNIQUE_EMPLOYEES   
FROM EMPLOYEE;


-- 2. Which departments have the highest number of employees?

SELECT J.JOBDEPT AS DEPARTMENT,
COUNT(E.EMP_ID) AS EMPLOYEECOUNT
FROM EMPLOYEE E
JOIN JOBDEPARTMENT J ON E.JOB_ID = J.JOB_ID
GROUP BY J.JOBDEPT
ORDER BY EMPLOYEECOUNT DESC;

-- 3.What is the average salary per department?

SELECT J.JOBDEPT AS DEPARTMENT,
AVG(S.AMOUNT) AS AVERAGE_SALARY
FROM SALARYBONUS S
JOIN JOBDEPARTMENT J ON S.JOB_ID = J.JOB_ID
GROUP BY J.JOBDEPT
ORDER BY AVERAGE_SALARY DESC;

-- 4.Who are the top 5 highest-paid employees?

SELECT E.FIRSTNAME, E.LASTNAME, P.TOTAL_AMOUNT AS SALARY
FROM EMPLOYEE E
JOIN PAYROLL P ON E.EMP_ID = P.EMP_ID
ORDER BY P.TOTAL_AMOUNT DESC
LIMIT 5;


-- 5.What is the total salary expenditure across the company?

SELECT SUM(S.AMOUNT + S.BONUS) AS TOTAL_SALARY_EXPENDITURE
FROM EMPLOYEE E
INNER JOIN SALARYBONUS S ON E.JOB_ID = S.JOB_ID;

## 2.JOB ROLE AND DEPARTMENT ANALYSIS
-- 1. How many different job roles exist in each department?
SELECT JOBDEPT ,
COUNT(DISTINCT NAME)  AS NUMBER_OF_JOBROLES
FROM JOBDEPARTMENT 
GROUP BY JOBDEPT;
 
-- 2.What is the average salary range per department?

SELECT JOBDEPT AS DEPARTMENT,
AVG(S.AMOUNT) AS AVG_SALARY
FROM JOBDEPARTMENT J
JOIN SALARYBONUS S ON J.JOB_ID = S.JOB_ID
GROUP BY JOBDEPT ;


-- 3.Which job roles offer the highest salary?
SELECT J.NAME AS JOB_TITLE , JOBDEPT ,S.AMOUNT AS SALARY  
FROM JOBDEPARTMENT J 
JOIN  SALARYBONUS S ON J.JOB_ID = S.JOB_ID 
ORDER BY S.AMOUNT DESC;

-- 4.Which departments have the highest total salary allocation? 

SELECT J.JOBDEPT,
SUM(S.AMOUNT + S.BONUS) AS TOTAL_SALARY_ALLOCATION
FROM JOBDEPARTMENT J
INNER JOIN SALARYBONUS S 
ON J.JOB_ID = S.JOB_ID
GROUP BY J.JOBDEPT
ORDER BY TOTAL_SALARY_ALLOCATION DESC
LIMIT 1;

## 3. QUALIFICATION AND SKILLS ANALYSIS
-- 1. How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT EMP_ID) AS EMPLOYEES_WITH_ONE_QUALIFICATION
FROM QUALIFICATION;

-- 2.Which positions require the most qualifications
SELECT POSITION, COUNT(QUALID) AS NUMBER_OF_QUALIFICATIONS
FROM QUALIFICATION
GROUP BY POSITION
ORDER BY NUMBER_OF_QUALIFICATIONS DESC;

-- 3.Which employees have the highest number of qualifications?
SELECT EMP_ID, COUNT(QUALID) AS NUMBER_OF_QUALIFICATIONS
FROM QUALIFICATION
GROUP BY EMP_ID
ORDER BY NUMBER_OF_QUALIFICATIONS DESC;

## 4.LEAVE AND ABSENCE PATTERNS

-- 1.Which year had the most employees taking leaves?
SELECT YEAR(DATE) AS YEAR,
COUNT(DISTINCT EMP_ID) AS LEAVECOUNT
FROM LEAVES
GROUP BY YEAR(DATE)
ORDER BY LEAVECOUNT DESC
LIMIT 1;
-- 2.What is the average number of leave days taken by its employees per department?
SELECT J.jobdept AS Department,
 AVG(emp_leaves.Leave_Count) AS Avg_Leave_Days
FROM (
    SELECT E.Job_ID, COUNT(L.leave_ID) AS Leave_Count
    FROM Employee E
    JOIN Leaves L ON E.emp_ID = L.emp_ID
    GROUP BY E.emp_ID, E.Job_ID
) emp_leaves
JOIN JobDepartment J ON emp_leaves.Job_ID = J.Job_ID
GROUP BY J.jobdept;

-- 3.Which employees have taken the most leaves?

SELECT E.EMP_ID, E.FIRSTNAME, 
COUNT(L.LEAVE_ID) AS LEAVES_COUNT
FROM EMPLOYEE E
JOIN LEAVES L ON E.EMP_ID = L.EMP_ID
GROUP BY E.EMP_ID, E.FIRSTNAME
ORDER BY LEAVES_COUNT DESC;

-- 4.What is the total number of leave days taken company-wide?

SELECT COUNT(LEAVE_ID) AS TOTAL_LEAVE_DAYS
FROM LEAVES;

-- 5. How do leave days correlate with payroll amounts?
SELECT P.EMP_ID, COUNT(L.LEAVE_ID) AS LEAVE_DAYS, 
SUM(P.TOTAL_AMOUNT) AS TOTAL_PAY
FROM PAYROLL P
LEFT JOIN LEAVES L ON P.EMP_ID = L.EMP_ID
GROUP BY P.EMP_ID;


## 5. PAYROLL AND COMPENSATION ANALYSIS
-- 1.What is the total monthly payroll processed?
SELECT DATE_FORMAT(DATE, '%Y-%m') AS MONTH, 
SUM(TOTAL_AMOUNT) AS TOTAL_PAYROLL
FROM PAYROLL
GROUP BY DATE_FORMAT(DATE, '%Y-%m')
ORDER BY MONTH;


-- 2.What is the average bonus given per department?

SELECT J.JOBDEPT, AVG(S.BONUS) AS AVG_BONUS
FROM SALARYBONUS S
JOIN JOBDEPARTMENT J ON S.JOB_ID = J.JOB_ID
GROUP BY J.JOBDEPT
ORDER BY AVG_BONUS DESC;


-- 3.Which department receives the highest total bonuses?

SELECT J.JOBDEPT, SUM(S.BONUS) AS TOTAL_BONUS
FROM SALARYBONUS S
JOIN JOBDEPARTMENT J ON S.JOB_ID = J.JOB_ID
GROUP BY J.JOBDEPT
ORDER BY TOTAL_BONUS DESC
LIMIT 1;


-- 4.What is the average value of total_amount after considering leave deductions?

SELECT AVG(TOTAL_AMOUNT) AS AVG_NET_PAY
FROM PAYROLL;



