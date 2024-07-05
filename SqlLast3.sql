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


INSERT INTO Positions (Name, [Limit]) VALUES ('Manager', 2);
INSERT INTO Positions (Name, [Limit]) VALUES ('Engineer', 5);
INSERT INTO Positions (Name, [Limit]) VALUES ('Salesperson', 3);


INSERT INTO Workers (Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId)
VALUES ('John', 'Doe', '1234567890', 5000.00, '1985-01-15', 1, 1);
INSERT INTO Workers (Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId)
VALUES ('Jane', 'Smith', '0987654321', 4000.00, '1990-04-20', 2, 2);



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



CREATE TRIGGER trg_CheckWorkerAge
ON Workers
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @BirthDate DATE;
    DECLARE @CurrentDate DATE = GETDATE();
    DECLARE @Age INT;

    SELECT @BirthDate = BirthDate FROM INSERTED;

    SELECT @Age = DATEDIFF(YEAR, @BirthDate, @CurrentDate);

    IF @Age >= 18
    BEGIN
        INSERT INTO Workers (Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId)
        SELECT Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId FROM INSERTED;
    END
    ELSE
    BEGIN
        RAISERROR('Worker is younger than 18 years old. Cannot add to the workers.', 16, 1);
    END
END;




CREATE TRIGGER trg_CheckPositionLimit
ON Workers
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @PositionId INT;
    DECLARE @PositionLimit INT;
    DECLARE @WorkerCount INT;

    SELECT @PositionId = PositionId FROM INSERTED;

    SELECT @PositionLimit = [Limit] FROM Positions WHERE Id = @PositionId;

    SELECT @WorkerCount = COUNT(*) FROM Workers WHERE PositionId = @PositionId;

    IF @WorkerCount < @PositionLimit
    BEGIN
        INSERT INTO Workers (Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId)
        SELECT Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId FROM INSERTED;
    END
    ELSE
    BEGIN
        RAISERROR('Position limit exceeded. Cannot add more workers to this position.', 16, 1);
    END
END;

