/*

Cleaning Data in SQL

*/

SELECT *
From PortfolioProject1.dbo.NashvilleHousing

--Standardize Data Format - Renaming the Sale Date

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject1.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address data
-- Finding the Null

Select *
From PortfolioProject1.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


-- Do a self joint table

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Populating it with Isnull

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- We update here in order to populate with NULL It could have been done with a string 'No Address'
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
From PortfolioProject1.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address --To get rid of comma 
From PortfolioProject1.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject1.dbo.NashvilleHousing
 

--Creating two new columns

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 

Select *
From PortfolioProject1.dbo.NashvilleHousing




--
Select *
From PortfolioProject1.dbo.NashvilleHousing



Select OwnerAddress
From PortfolioProject1.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

Select *
From PortfolioProject1.dbo.NashvilleHousing -- (More columns were added)


-- Change  Y and N to Yes and No "Sold as Vacant" field
 
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject1.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject1.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END


-- Remove Duplicates

WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject1.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- To Delete we change Select * to Delete,and then change it again to Select and check if there is any duplicates

WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject1.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


-- Delete Unused Columns

Select *
From PortfolioProject1.dbo.NashvilleHousing

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate
