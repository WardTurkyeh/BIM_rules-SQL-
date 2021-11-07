/****** Script for SelectTopNRows command from SSMS  ******/

--SELECT * FROM [dbo].[RevitColdWaterDraw-offPoint]

CREATE TABLE RevitColdWaterDraw_offPoint_Splitted (
	Category varchar(300),
	ObjectID varchar(300),
    FamilyName varchar(300),
    TypeName varchar(300),
	IfcExportAs varchar(300),
	PredefinedType varchar(300),
	SystemClassification varchar(300),
	SystemName varchar(300),
	SystemID varchar(300),
);
INSERT INTO RevitColdWaterDraw_offPoint_Splitted
SELECT Category, ObjectID, FamilyName, TypeName, IfcExportAs, PredefinedType, SystemClassification, SystemName, (Value) FROM [dbo].[RevitColdWaterDraw-offPoint]
CROSS APPLY string_split(SystemID, ',')

--SELECT * FROM [dbo].[RevitColdWaterDraw_offPoint_Splitted]

CREATE TABLE RevitColdWaterStorageTanks_Splitted (
	Category varchar(300),
	ObjectID varchar(300),
    FamilyName varchar(300),
    TypeName varchar(300),
	IfcExportAs varchar(300),
	PredefinedType varchar(300),
	SystemClassification varchar(300),
	SystemName varchar(300),
	SystemID varchar(300),
);
INSERT INTO RevitColdWaterStorageTanks_Splitted
SELECT Category, ObjectID, FamilyName, TypeName, IfcExportAs, PredefinedType, SystemClassification, SystemName, (Value) FROM [dbo].[RevitColdWaterStorageTanks]
CROSS APPLY string_split(SystemID, ',')

--SELECT * FROM [dbo].[RevitColdWaterDraw_offPoint_Splitted]
--SELECT * FROM [dbo].[RevitColdWaterStorageTanks_Splitted]

CREATE TABLE Unmatched (
	Category varchar(300),
	ObjectID varchar(300),
    FamilyName varchar(300),
    TypeName varchar(300),
	IfcExportAs varchar(300),
	PredefinedType varchar(300),
	SystemClassification varchar(300),
	SystemName varchar(300),
	SystemID varchar(300),
);
INSERT INTO Unmatched
SELECT RevitColdWaterDraw_offPoint_Splitted.Category, RevitColdWaterDraw_offPoint_Splitted.ObjectID, RevitColdWaterDraw_offPoint_Splitted.FamilyName, RevitColdWaterDraw_offPoint_Splitted.TypeName, RevitColdWaterDraw_offPoint_Splitted.IfcExportAs, RevitColdWaterDraw_offPoint_Splitted.PredefinedType, RevitColdWaterDraw_offPoint_Splitted.SystemClassification, RevitColdWaterDraw_offPoint_Splitted.SystemName, RevitColdWaterDraw_offPoint_Splitted.SystemID
FROM RevitColdWaterDraw_offPoint_Splitted LEFT JOIN RevitColdWaterStorageTanks_Splitted ON RevitColdWaterDraw_offPoint_Splitted.[SystemID] = RevitColdWaterStorageTanks_Splitted.[SystemID]
WHERE (((RevitColdWaterStorageTanks_Splitted.SystemID) Is Null));

--SELECT * FROM [dbo].[Unmatched]
--------------------------------------------------------
CREATE TABLE Matched (
	Category varchar(300),
	ObjectID varchar(300),
    FamilyName varchar(300),
    TypeName varchar(300),
	IfcExportAs varchar(300),
	PredefinedType varchar(300),
	SystemClassification varchar(300),
	SystemName varchar(300),
	SystemID varchar(300),
);
INSERT INTO Matched

SELECT RevitColdWaterDraw_offPoint_Splitted.Category, RevitColdWaterDraw_offPoint_Splitted.ObjectID, RevitColdWaterDraw_offPoint_Splitted.FamilyName, RevitColdWaterDraw_offPoint_Splitted.TypeName, RevitColdWaterDraw_offPoint_Splitted.IfcExportAs, RevitColdWaterDraw_offPoint_Splitted.PredefinedType, RevitColdWaterDraw_offPoint_Splitted.SystemClassification, RevitColdWaterDraw_offPoint_Splitted.SystemName, RevitColdWaterDraw_offPoint_Splitted.SystemID
FROM RevitColdWaterDraw_offPoint_Splitted LEFT JOIN Unmatched ON RevitColdWaterDraw_offPoint_Splitted.[SystemID] = Unmatched.[SystemID]
WHERE (((Unmatched.SystemID) Is Null));

--SELECT * FROM [dbo].[Matched]
--SELECT * FROM [dbo].[Unmatched]

ALTER TABLE Matched ADD RESULT VARCHAR(300)
ALTER TABLE Unmatched ADD RESULT VARCHAR(300)

CREATE TABLE FinalResult (
	Category varchar(300),
	ObjectID varchar(300),
    FamilyName varchar(300),
    TypeName varchar(300),
	IfcExportAs varchar(300),
	PredefinedType varchar(300),
	SystemClassification varchar(300),
	SystemName varchar(300),
	SystemID varchar(300),
	Result varchar(300)
);
INSERT INTO FinalResult
SELECT Matched.Category, Matched.ObjectID, Matched.FamilyName, Matched.TypeName, Matched.IfcExportAs, Matched.PredefinedType, Matched.SystemClassification, Matched.SystemName, Matched.SystemID, ISNULL(RESULT,'PASS') AS RESULT FROM Matched
INSERT INTO FinalResult
SELECT Unmatched.Category, Unmatched.ObjectID, Unmatched.FamilyName, Unmatched.TypeName, Unmatched.IfcExportAs, Unmatched.PredefinedType, Unmatched.SystemClassification, Unmatched.SystemName, Unmatched.SystemID, ISNULL(RESULT,'FAIL') AS RESULT FROM Unmatched

SELECT * FROM FinalResult