CREATE DATABASE JobApp;

USE JobApp;

CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100)
);


CREATE TABLE Positions (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    [Limit] INT
);


CREATE TABLE Workers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Surname NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    Salary DECIMAL(10, 2),
    BirthDate DATE,
    DepartmentId INT,
    PositionId INT,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id),
    FOREIGN KEY (PositionId) REFERENCES Positions(Id)
);


INSERT INTO Departments (Name) VALUES ('HR');
INSERT INTO Departments (Name) VALUES ('IT');
INSERT INTO Departments (Name) VALUES ('Sales');


INSERT INTO Positions (Name, [Limit]) VALUES ('Manager', 1);
INSERT INTO Positions (Name, [Limit]) VALUES ('Engineer', 5);
INSERT INTO Positions (Name, [Limit]) VALUES ('Salesperson', 3);

TRUNCATE TABLE Workers;

INSERT INTO Workers (Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId)
VALUES ('John', 'Doe', '1234567890', 5000.00, '1985-01-15', 1, 1);
INSERT INTO Workers (Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId)
VALUES ('Jane', 'Smith', '0987654321', 4000.00, '2016-04-20', 2, 1);



CREATE FUNCTION GetAverageSalaryByDepartment
    (@departmentId INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @avgSalary DECIMAL(10, 2);

    SELECT @avgSalary = AVG(Salary)
    FROM Workers
    WHERE DepartmentId = @departmentId;

    RETURN @avgSalary;
END;



CREATE TRIGGER trg_CheckWorkerAgeAndPositionLimit
ON Workers
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @BirthDate DATE;
    DECLARE @CurrentDate DATE = GETDATE();
    DECLARE @Age INT;

	DECLARE @PositionId INT;
    DECLARE @PositionLimit INT;
    DECLARE @WorkerCount INT;

    SELECT @BirthDate = BirthDate FROM INSERTED;
    SELECT @Age = DATEDIFF(YEAR, @BirthDate, @CurrentDate);

    SELECT @PositionId = PositionId FROM INSERTED;
    SELECT @PositionLimit = [Limit] FROM Positions WHERE Id = @PositionId;
    SELECT @WorkerCount = COUNT(*) FROM Workers WHERE PositionId = @PositionId;

    IF @Age >= 18 AND @WorkerCount < @PositionLimit
    BEGIN
        INSERT INTO Workers (Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId)
        SELECT Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId FROM INSERTED;
    END
    ELSE
    BEGIN
		IF @Age < 18
		BEGIN
			RAISERROR('Worker is younger than 18 years old', 16, 1);
		END

		IF @WorkerCount >= @PositionLimit
		BEGIN
			RAISERROR('Position reached own limit', 16, 1);
		END
    END
END;

DROP TRIGGER trg_CheckWorkerAgeAndPositionLimit;
