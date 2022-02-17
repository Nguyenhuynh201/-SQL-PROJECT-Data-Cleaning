/*
Cleaning Data uses SQL queries
*/
SELECT *
FROM NasshvilleHousing$

-- Standardize Date Format on the SaleDate

ALTER TABLE NasshvilleHousing$
ADD SaleDate2 Date;

UPDATE NasshvilleHousing$
SET SaleDate2 = CONVERT(Date, SaleDate);

SELECT SaleDate2
FROM NasshvilleHousing$;

--Populate Property Address Data

SELECT *
FROM NasshvilleHousing$
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NasshvilleHousing$ a
JOIN NasshvilleHousing$ b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NasshvilleHousing$ a
JOIN NasshvilleHousing$ b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS ( ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM NasshvilleHousing$

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM NasshvilleHousing$ 

ALTER TABLE NasshvilleHousing$
ADD PropertySplitAddress Nvarchar(255)

ALTER TABLE NasshvilleHousing$
ADD PropertySplitCity Nvarchar(255)

UPDATE NasshvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1);

UPDATE NasshvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));

SELECT PropertySplitAddress, PropertySplitCity
FROM NasshvilleHousing$

SELECT
PARSENAME (REPLACE(OwnerAddress,',','.'),1)
FROM NasshvilleHousing$

ALTER TABLE NasshvilleHousing$ 
ADD PropertyState Nvarchar(255);

UPDATE NasshvilleHousing$
SET PropertyState = PARSENAME (REPLACE(OwnerAddress,',','.'),1)
FROM NasshvilleHousing$;

SELECT PropertySplitAddress,PropertySplitCity,PropertyState
FROM NasshvilleHousing$

-- Change Y and N to 'Yes' and 'No' in 'Sold As Vacant'

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO' 
	ELSE SoldAsVacant END
FROM NasshvilleHousing$

UPDATE NasshvilleHousing$
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO' 
	ELSE SoldAsVacant END
FROM NasshvilleHousing$


-- REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *,
	ROW_Number () OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
	) row_num

FROM NasshvilleHousing$
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

-- Clean table
ALTER TABLE NasshvilleHousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE NasshvilleHousing$
DROP COLUMN SaleDate

--RECAP
SELECT * FROM NasshvilleHousing$