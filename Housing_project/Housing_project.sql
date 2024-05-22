-------------------------------------------------------------------------------------------------------------------------------------
-- standardising date_column --

SELECT SaleDate,Saledate_converted
FROM Housing_project..Housing

ALTER TABLE Housing_project..Housing
ADD Saledate_converted Date;

UPDATE Housing_project..Housing
SET Saledate_converted=CONVERT(date,SaleDate)	

-------------------------------------------------------------------------------------------------------------------------------------
-- populating property address for those which are null --

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing_project..Housing a
JOIN Housing_project..Housing b
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL

SELECT ParcelID,PropertyAddress
FROM Housing_project..Housing

-------------------------------------------------------------------------------------------------------------------------------------
-- seperating property address into diff.columns(address and city) --

ALTER TABLE Housing_project..Housing
ADD prop_add_address NVARCHAR(255);
ALTER TABLE Housing_project..Housing
ADD prop_add_city NVARCHAR(255);

UPDATE Housing_project..Housing
SET prop_add_address=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

UPDATE Housing_project..Housing
SET prop_add_city=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--SELECT PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)	AS address,
--SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS city
--FROM Housing_project..Housing

-------------------------------------------------------------------------------------------------------------------------------------
-- Splitting Owner Address into address,state,city --

ALTER TABLE Housing_project..Housing
ADD owner_add_address NVARCHAR(255)
ALTER TABLE Housing_project..Housing
ADD owner_add_city NVARCHAR(255)
ALTER TABLE Housing_project..Housing
ADD owner_add_state NVARCHAR(255)

UPDATE Housing_project..Housing
SET owner_add_address=PARSENAME(REPLACE(OwnerAddress,',','.'),3)
UPDATE Housing_project..Housing
SET owner_add_city=PARSENAME(REPLACE(OwnerAddress,',','.'),2)
UPDATE Housing_project..Housing
SET owner_add_state=PARSENAME(REPLACE(OwnerAddress,',','.'),1)
--SELECT OwnerAddress,PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS a,
--PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS b,
--PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS c
--FROM Housing_project..Housing

-------------------------------------------------------------------------------------------------------------------------------------
-- standardising 'soldasvacant' column --

UPDATE Housing_project..Housing
SET SoldAsVacant=CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
END
--SELECT SoldAsVacant, 
--CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	 --WHEN SoldAsVacant='N' THEN 'No'
	 --ELSE SoldAsVacant
--END
--FROM Housing_project..Housing
--SELECT DISTINCT(SoldAsVacant)
--FROM Housing_project..Housing

-------------------------------------------------------------------------------------------------------------------------------------
-- removing duplicates --

WITH row_num_cte AS(
SELECT *, ROW_NUMBER()OVER(PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) AS row_num
FROM Housing_project..Housing)

DELETE
FROM row_num_cte
WHERE row_num>1

-------------------------------------------------------------------------------------------------------------------------------------
-- deleting unused column --

ALTER TABLE Housing_project..Housing
DROP COLUMN SaleDate,OwnerAddress,PropertyAddress

SELECT *
FROM Housing_project..Housing

-------------------------------------------------------------------------------------------------------------------------------------