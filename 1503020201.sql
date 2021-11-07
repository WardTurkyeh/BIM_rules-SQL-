/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT * FROM [dbo].[RevitColdStoreRoom]

--SELECT * FROM RevitColdStoreArea
--SELECT * FROM RevitColdStoreVolume

CREATE TABLE RevitColdStoreArea(
	Category VARCHAR(300),
	ObjectID VARCHAR(300),
	RoomArea DECIMAL,
	AreaUnit VARCHAR(300),
	Result VARCHAR(300)	
)

CREATE TABLE RevitColdStoreVolume(
	Category VARCHAR(300),
	ObjectID VARCHAR(300),
	RoomVolume DECIMAL,
	VolumeUnit VARCHAR(300),
	Result VARCHAR(300)
)


WITH UNIT_CTE AS
(SELECT Category, ObjectID, RoomArea, RoomVolume, VALUE
, ROW_NUMBER() OVER(partition by ObjectID Order by ObjectID) as RowNum
From [dbo].[RevitColdStoreRoom]
CROSS APPLY
string_split(RoomArea, ' ')
)
--INSERT INTO RevitColdStoreArea(Category, ObjectID,RoomArea,AreaUnit)

SELECT Category, ObjectID,
[1] AS RoomArea, [2] AS AreaUnit
FROM UNIT_CTE
PIVOT
(MAX(VALUE)
FOR RowNum in ([1],[2])) as PVT

-------------------------------

WITH UNIT_CTE AS
(SELECT Category, ObjectID, RoomArea, RoomVolume, VALUE
, ROW_NUMBER() OVER(partition by ObjectID Order by ObjectID) as RowNum
From [dbo].[RevitColdStoreRoom]
CROSS APPLY
string_split(RoomVolume, ' ')
)

INSERT INTO RevitColdStoreVolume(Category, ObjectID,RoomVolume,VolumeUnit)

SELECT Category, ObjectID,
[1] AS RoomVolume, [2] AS VolumeUnit
FROM UNIT_CTE
PIVOT
(MAX(VALUE)
FOR RowNum in ([1],[2])) as PVT

CREATE TABLE RevitColdStore(
	Category VARCHAR(300),
	ObjectID VARCHAR(300),
	RoomArea DECIMAL,
	AreaUnit VARCHAR(300),
	RoomVolume DECIMAL,
	VolumeUnit VARCHAR(300),
	Result VARCHAR(300)
)

INSERT INTO RevitColdStore(Category, ObjectID,RoomArea,AreaUnit,RoomVolume,VolumeUnit)

SELECT A.Category, A.ObjectID, A.RoomArea, A.AreaUnit, 
V.RoomVolume,V.VolumeUnit
FROM RevitColdStoreArea AS A
JOIN RevitColdStoreVolume AS V
ON A.ObjectID=V.ObjectID


CREATE TABLE Pass(
	Category VARCHAR(300),
	ObjectID VARCHAR(300),
	RoomArea DECIMAL,
	AreaUnit VARCHAR(300),
	RoomVolume DECIMAL,
	VolumeUnit VARCHAR(300),
	RoomHeight DECIMAL,
	Result VARCHAR(300)
)

INSERT INTO Pass
SELECT Category, ObjectID, RoomArea, AreaUnit, RoomVolume, VolumeUnit, Round((RoomVolume/RoomArea),3) AS RoomHeight, ISNULL(Result,'PASS') AS Result
FROM RevitColdStore
WHERE (RoomVolume/RoomArea) >= 2.5



CREATE TABLE Fail(
	Category VARCHAR(300),
	ObjectID VARCHAR(300),
	RoomArea DECIMAL,
	AreaUnit VARCHAR(300),
	RoomVolume DECIMAL,
	VolumeUnit VARCHAR(300),
	RoomHeight DECIMAL,
	Result VARCHAR(300)
)
INSERT INTO Fail
SELECT Category, ObjectID, RoomArea, AreaUnit, RoomVolume, VolumeUnit, Round((RoomVolume/RoomArea),3) AS RoomHeight, ISNULL(Result,'FAIL') AS Result
FROM RevitColdStore
WHERE (RoomVolume/RoomArea) <= 2.5

CREATE TABLE FinalResult_1503020201(
	Category VARCHAR(300),
	ObjectID VARCHAR(300),
	RoomArea DECIMAL,
	AreaUnit VARCHAR(300),
	RoomVolume DECIMAL,
	VolumeUnit VARCHAR(300),
	RoomHeight DECIMAL,
	Result VARCHAR(300)
)
INSERT INTO FinalResult_1503020201
SELECT * FROM Pass
INSERT INTO FinalResult_1503020201
SELECT * FROM Fail

SELECT * FROM FinalResult_1503020201