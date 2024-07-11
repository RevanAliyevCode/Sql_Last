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
DROP TABLE [Group]


INSERT INTO [Group] (Name, [Limit], BeginDate, EndDate) VALUES ('Group A', 1, '2024-01-01', '2024-12-31');
INSERT INTO [Group] (Name, [Limit], BeginDate, EndDate) VALUES ('Group B', 3, '2024-01-01', '2024-12-31');


INSERT INTO Student (Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId) VALUES ('John', 'Doe', 'john.doe@example.com', '1234567890', '2006-01-15', 87.5, 1);
INSERT INTO Student (Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId) VALUES ('Jane', 'Smith', 'jane.smith@example.com', '0987654321', '2006-04-20', 76.8, 2);



CREATE TRIGGER trg_CheckGroupLimitAndAge
ON Student
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @BirthDate DATE;
    DECLARE @CurrentDate DATE = GETDATE();
    DECLARE @Age INT;
    DECLARE @GroupId INT;
    DECLARE @GroupLimit INT;
    DECLARE @StudentCount INT;

    SELECT @GroupId = GroupId FROM INSERTED;
    SELECT @BirthDate = BirthDate FROM INSERTED;
    SELECT @Age = DATEDIFF(YEAR, @BirthDate, @CurrentDate);
    SELECT @GroupLimit = [Limit] FROM [Group] WHERE Id = @GroupId;
    SELECT @StudentCount = COUNT(*) FROM Student WHERE GroupId = @GroupId;


    IF @Age > 16 AND @StudentCount < @GroupLimit
    BEGIN
        INSERT INTO Student (Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId)
        SELECT Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId FROM INSERTED;
    END
    ELSE
    BEGIN
		IF @Age <= 16
		BEGIN
			RAISERROR('Student is 16 years old or younger', 16, 1);
		END

		IF @StudentCount >= @GroupLimit
		BEGIN
			RAISERROR('There is no place left in this group', 16, 1);
		END
    END
END;

DROP TRIGGER trg_CheckGroupLimitAndAge;


CREATE FUNCTION FindAverageGPA
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
