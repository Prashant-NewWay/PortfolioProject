

-- Cleaning Data using Sql

SELECT * 
FROM PortfolioProject.dbo.HousingData

--Standardize Sale Date

SELECT SaleDate , CONVERT(Date , SaleDate) 
FROM PortfolioProject.dbo.HousingData

UPDATE HousingData
SET SaleDate = CONVERT(Date , SaleDate)

ALTER TABLE HousingData
ADD SaleDateUpdated Date

UPDATE HousingData
SET SaleDateUpdated = CONVERT(Date , SaleDate)

SELECT SaleDateUpdated , CONVERT(Date , SaleDate) 
FROM PortfolioProject.dbo.HousingData


-- Populate Property Address

SELECT PropertyAddress
FROM PortfolioProject.dbo.HousingData
WHERE PropertyAddress IS NULL

-- Property Address can not be NULL since its a permanent address unlike other fiels like owner address which can be updated.

SELECT *
FROM PortfolioProject.dbo.HousingData
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID 

-- Using order by Parcel ID will result in finding same ids which can be used to populate the property address
-- Use Unique Parcel ID to populate with same details

-- Using Self Join

SELECT A.ParcelID,A.PropertyAddress , B.ParcelID,B.PropertyAddress
FROM PortfolioProject.dbo.HousingData A
JOIN PortfolioProject.dbo.HousingData B					
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]							-- Same Parcel ID but need unique id which distinguishes rows in self join


SELECT A.ParcelID,A.PropertyAddress , B.ParcelID,B.PropertyAddress --, ISNULL(A.PropertyAddress,B.PropertyAddress)			-- ISNULL checks for null and returns output in new column if condition true
FROM PortfolioProject.dbo.HousingData A
JOIN PortfolioProject.dbo.HousingData B					
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]	
WHERE A.PropertyAddress IS NULL					-- NULL Values

UPDATE A
SET A.PropertyAddress = B.PropertyAddress					-- Updating by replacing NULL value with the address of the property
FROM PortfolioProject.dbo.HousingData A
JOIN PortfolioProject.dbo.HousingData B					
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]	
WHERE A.PropertyAddress IS NULL	




-- Breaking Address into individuls units



SELECT PropertyAddress
FROM PortfolioProject.dbo.HousingData
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID 

-- Using Substring to break around delimiter ",",starting position is 1,CHARINDEX for Comma position,LEN for length as positio index

SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address, 
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress) )AS City
FROM PortfolioProject.dbo.HousingData

-- To Create new Columns 

ALTER TABLE PortfolioProject.dbo.HousingData
ADD PropertySplitAddress Nvarchar(255)					--Using Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.HousingData
ADD PropertySplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress) )


SELECT *
FROM PortfolioProject.dbo.HousingData


-- Breaking Owner Address which has two delimiters by using PARSENAME

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),		-- PARSENAME Works on periods(.) so used
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.HousingData


ALTER TABLE PortfolioProject.dbo.HousingData
ADD OwnerSplitAddress Nvarchar(255)					--Using Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.HousingData
ADD OwnerSplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.HousingData
ADD OwnerSplitState Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM PortfolioProject.dbo.HousingData




--Changing the Values Y and N to Yes and No of SoldAsVacant Field


SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.HousingData
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.HousingData

UPDATE PortfolioProject.dbo.HousingData										
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
				   END





--Remove Duplicates

-- Using CTE and Window Functions

WITH RowNumTable AS								-- Using CTE since Window Functions cannot be used directly for Where Clause 
(SELECT  *,
		ROW_NUMBER() over(
						Partition By 
						ParcelID,
						PropertyAddress,
						SaleDate,
						LegalReference
						Order By [UniqueID ]
						) RowNum
FROM PortfolioProject.dbo.HousingData
--Order By ParcelID
)
SELECT *
FROM RowNumTable
WHERE RowNum>1

--Deleting rows which are Duplicates									
WITH RowNumTable AS								
(SELECT  *,
		ROW_NUMBER() over(
						Partition By 
						ParcelID,
						PropertyAddress,
						SaleDate,
						LegalReference
						Order By [UniqueID ]
						) RowNum
FROM PortfolioProject.dbo.HousingData
--Order By ParcelID
)
DELETE
FROM RowNumTable
WHERE RowNum>1



--Delete Unused columns

SELECT *
FROM PortfolioProject.dbo.HousingData

ALTER TABLE PortfolioProject.dbo.HousingData
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject.dbo.HousingData
DROP COLUMN SaleDate
