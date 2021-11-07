/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Name]
      ,[Area]
      ,[Volume]
      ,[Field5]
      ,[WallID]
  FROM [mvd].[dbo].[Room_Schedule_Splitted]


SELECT * FROM Room_Schedule_Splitted

WITH UNIT_CTE AS
(SELECT Name, Area, Volume, WallID, VALUE
, ROW_NUMBER() OVER(partition by WallID Order by WallID) as RowNum
From [dbo].[Room_Schedule_Splitted]
CROSS APPLY
string_split(Area, ' ')
)

SELECT Name, Area, Volume, WallID,
[1] AS Number, [2] AS Unit
FROM UNIT_CTE
PIVOT
(MAX(VALUE)
FOR RowNum in ([1],[2])) as PVT

