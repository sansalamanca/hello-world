

- --Create new SaleDate column with a more understandable format  (Date)


select saledate, convert(DATE,saledate) 
from PortfolioProject.dbo.NashvilleHousing 


alter table NashvilleHousing
add SaleDateConverted date


update  NashvilleHousing
set saledateconverted=convert(date, saledate)


--  The PropertyAddress column has 29 records with NULL value
    --Is evident that there are duplicated records recognizable only because they have different UniqueID

select * 
from PortfolioProject.dbo.NashvilleHousing 
where PropertyAddress is null

--  Lets see the duplicated records and "discover" that the duplicated records have the PropertyAddress that is missing in those original records

SELECT a.ParcelID , a.PropertyAddress, b.ParcelID , b.PropertyAddress
FROM dbo.NashvilleHousing a JOIN  dbo.NashvilleHousing  b     ON a.ParcelID=b.ParcelID
AND a.uniqueID<>b.uniqueID
WHERE a.PropertyAddress is null

-- Using ISNULL()  we´ll see how we could fill the NULL PropertyAddress fields with the correct address

SELECT a.ParcelID , a.PropertyAddress, b.ParcelID , b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress )
FROM dbo.NashvilleHousing a JOIN  dbo.NashvilleHousing  b     ON a.ParcelID=b.ParcelID
AND a.uniqueID<>b.uniqueID


-- We proceed to alter the table filling NULL empty PropertyAddress with the data in the corresponding duplicate´s field

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress)
FROM dbo.NashvilleHousing a JOIN  dbo.NashvilleHousing  b     ON a.ParcelID=b.ParcelID
AND a.uniqueID<>b.uniqueID
WHERE a.PropertyAddress IS NULL

-- Finally we re-run our code looking for records with NULL PropertyAddress fields, and it will produce none
SELECT a.ParcelID , a.PropertyAddress, b.ParcelID , b.PropertyAddress
FROM dbo.NashvilleHousing a JOIN  dbo.NashvilleHousing  b     ON a.ParcelID=b.ParcelID 
AND a.uniqueID<>b.uniqueID
WHERE a.PropertyAddress is null


-- The column OwnerAddres contains Address, City and State separated by commas. By using the Parse function, We´re gonna get 3 different columns (Address, City and State)
-- Lets see what we´d get...

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

-- Altering the Table NashVilleHousing; creating  3 new columns and filling them with data (Address, City and State)

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject.dbo.NashvilleHousing


--  "Sold as Vacant" sometimes is filled with "Yes" and "no"   but other times is filled with "Y" and "N". lets see

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

-- Let´s see how the field SoldAsVacant could be filled, according to the case...

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE 
						When SoldAsVacant = 'Y' THEN 'Yes'
						When SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
					END

-- See how the field SolAsVacant is not standardized

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



-- ==================================FINDING AND REMOVING DUPLICATED RECORDS. =====================================

-- First , Using the ROW_NUMBER() function, lets create a new column that counts records with identical fillings (duplicates)
   --Any partition with more than 2 in its ROW_NUMBER column, is a duplicate

Select *,
	ROW_NUMBER() OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference  ORDER BY UniqueID
					  ) row_num
From PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID
-- Where row_num > 1   It doesn´t work

-- Since isn´t allowed to use  [  Where row_num > 1 ]   will will put this code inside a WITH Query to bypass the problem

WITH RowNumCTE AS(
					Select *, 	ROW_NUMBER() OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference  ORDER BY UniqueID  )   row_num
					From PortfolioProject.dbo.NashvilleHousing
				  )

Select * From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Now we´ll remove permanently the duplicates

WITH RowNumCTE AS(
					Select *, 	ROW_NUMBER() OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference  ORDER BY UniqueID  )   row_num
					From PortfolioProject.dbo.NashvilleHousing
				  )

DELETE FROM RowNumCTE 
Where row_num > 1




-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

