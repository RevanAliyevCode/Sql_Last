CREATE DATABASE GroupApp;

USE GroupApp;

CREATE TABLE [Group] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    [Limit] INT,
    BeginDate DATE,
    EndDate DATE
);


CREATE TABLE Student (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Surname NVARCHAR(100),
    Email NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    BirthDate DATE,
    GPA DECIMAL(5, 2),
    GroupId INT,
    FOREIGN KEY (GroupId) REFERENCES [Group](Id)
);

TRUNCATE TABLE Student;


INSERT INTO [Group] (Name, [Limit], BeginDate, EndDate) VALUES ('Group A', 2, '2024-01-01', '2024-12-31');
INSERT INTO [Group] (Name, [Limit], BeginDate, EndDate) VALUES ('Group B', 3, '2024-01-01', '2024-12-31');


INSERT INTO Student (Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId) VALUES ('John', 'Doe', 'john.doe@example.com', '1234567890', '2006-01-15', 87.5, 1);
INSERT INTO Student (Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId) VALUES ('Jane', 'Smith', 'jane.smith@example.com', '0987654321', '2018-04-20', 76.8, 1);



CREATE TRIGGER trg_CheckGroupLimit
ON Student
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @GroupId INT;
    DECLARE @GroupLimit INT;
    DECLARE @StudentCount INT;

    SELECT @GroupId = GroupId FROM INSERTED;

    SELECT @GroupLimit = [Limit] FROM [Group] WHERE Id = @GroupId;

    SELECT @StudentCount = COUNT(*) FROM Student WHERE GroupId = @GroupId;

    IF @StudentCount < @GroupLimit
    BEGIN
        INSERT INTO Student (Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId)
        SELECT Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId FROM INSERTED;
    END
    ELSE
    BEGIN
        RAISERROR('Group limit exceeded. Cannot add more students to this group.', 16, 1);
    END
END;

DROP TRIGGER trg_CheckGroupLimit;


CREATE TRIGGER trg_CheckStudentAge
ON Student
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @BirthDate DATE;
    DECLARE @CurrentDate DATE = GETDATE();
    DECLARE @Age INT;

    SELECT @BirthDate = BirthDate FROM INSERTED;

    SELECT @Age = DATEDIFF(YEAR, @BirthDate, @CurrentDate);

    IF @Age > 16
    BEGIN
        INSERT INTO Student (Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId)
        SELECT Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId FROM INSERTED;
    END
    ELSE
    BEGIN
        RAISERROR('Student is 16 years old or younger. Cannot add to the group.', 16, 1);
    END
END;


CREATE FUNCTION GetAverageGPA
    (@groupId INT)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @avgGPA DECIMAL(5, 2);

    SELECT @avgGPA = AVG(GPA)
    FROM Student
    WHERE GroupId = @groupId;

    RETURN @avgGPA;
END;
