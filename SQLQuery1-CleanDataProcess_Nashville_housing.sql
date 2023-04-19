--Cleaning Data in SQL Queries

Select *
From PortfolioProject.dbo.nashville_data

-------------------------------------------------------------------------------
-- Sale Date Converted

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.nashville_data

Update PortfolioProject.dbo.nashville_data
SET SaleDateConverted = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProject.dbo.nashville_data
Add SaleDateConverted Date;

Update PortfolioProject.dbo.nashville_data
SET SaleDateConverted = CONVERT(Date,SaleDate)

----------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From PortfolioProject.dbo.nashville_data
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.nashville_data a
JOIN PortfolioProject.dbo.nashville_data b
	on a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.nashville_data a
JOIN PortfolioProject.dbo.nashville_data b
	on a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is null

 ------------------------------------------------------------------------------------------------
 
 --Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.nashville_data

Select
SUBSTRING(Propertyaddress, 1, CHARINDEX( ',', PropertyAddress)-1) as Address,
SUBSTRING(Propertyaddress,  CHARINDEX( ',', PropertyAddress)+1, Len(PropertyAddress)) as Address

From PortfolioProject.dbo.nashville_data

ALTER TABLE nashville_data
Add PropertySplittAddress Nvarchar(255);

update nashville_data
SET PropertySplittAddress = SUBSTRING(Propertyaddress, 1, CHARINDEX( ',', PropertyAddress)-1)

Alter table nashville_data
Add PropertySplitCity Nvarchar(255);

update nashville_data
SET PropertySplitCity = SUBSTRING(Propertyaddress,  CHARINDEX( ',', PropertyAddress)+1, Len(PropertyAddress))


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.nashville_data

Alter table nashville_data
Add OwnerSplitAddress Nvarchar(255);

update nashville_data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter table nashville_data
Add OwnerSplitCity Nvarchar(255);

update nashville_data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter table nashville_data
Add OwnerSplitState Nvarchar(255);

update nashville_data
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------------

--Change Y and N TO Yes and No in "Sold as Vacant" field

Select Distinct SoldAsVacant
From PortfolioProject.dbo.nashville_data

Select Distinct SoldAsVacant, Count(SoldAsVacant)
From PortfolioProject.dbo.nashville_data
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'YES'
		When SoldAsVacant ='N' Then 'NO'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.nashville_data

update nashville_data
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'YES'
		When SoldAsVacant ='N' Then 'NO'
		ELSE SoldAsVacant
		END

--------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID) row_num
From PortfolioProject.dbo.nashville_data
--Order By ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

---------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select * 
From PortfolioProject.dbo.nashville_data

Alter Table PortfolioProject.dbo.nashville_data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject.dbo.nashville_data
DROP COLUMN SaleDate