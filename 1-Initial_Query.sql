USE USDA
GO

/*
fdcId, description, dataType, publicationDate, foodNutrients - (number, name, amount, unitName)
*/

DECLARE @FoodJSON VARCHAR(MAX)

SELECT @FoodJSON = BulkColumn
FROM OPENROWSET(BULK 'D:\Downloads\Projects\MS-SQL-Nutrition\food_list_fdcId.json', SINGLE_CLOB) as JSON

SELECT
TableA.fdcId,
TableA.description,
TableA.dataType,
TableA.publicationDate,
TableNutrients.*
FROM OPENJSON(@FoodJSON)
	WITH (
		fdcId			INT,
		description		VARCHAR(100),
		dataType		VARCHAR(100),
		publicationDate	DATE,
		foodNutrients	NVARCHAR(MAX) as JSON
	) as TableA
CROSS APPLY OPENJSON(TableA.foodNutrients)
	WITH(
		number		INT,
		name		VARCHAR(50),
		amount		FLOAT,
		unitName	VARCHAR(20)
	) as TableNutrients

DROP TABLE FoodNutrition

CREATE TABLE FoodNutrition (
	fdcId			INT,
	description		VARCHAR(100),
	dataType		VARCHAR(100),
	publicationDate	DATE,
	number			INT,
	name			VARCHAR(100),
	amount			FLOAT,
	unitName		VARCHAR(20)
	);

INSERT INTO FoodNutrition
SELECT 
TableA.fdcId,
TableA.description,
TableA.dataType,
TableA.publicationDate,
TableNutrients.*

FROM OPENJSON(@FoodJSON)