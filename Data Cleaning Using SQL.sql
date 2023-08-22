Select * 
From PortfolioProject.dbo.NashvilleHousing
-- Standarizing Date Format

Select SaleDateConverted, Convert(Date,saledate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,saledate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(date,saledate)

-- Populating Property Address

Select * 
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	On a.parcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET propertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	On a.parcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-- Splitting Address Into Individual Columns

Select PropertyAddress 
From PortfolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) As Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) As Address

From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


-- Turning Y and N in "sold as vacant" into Yes and No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'y' THEN 'Yes'
	   When SoldAsVacant = 'n' THEN 'No'
	   ELSE SoldAsVacant
	   End
From PortfolioProject.dbo.NashvilleHousing
	   
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'y' THEN 'Yes'
	   When SoldAsVacant = 'n' THEN 'No'
	   ELSE SoldAsVacant
	   End

-- Duplicate Removal

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1
ORDER BY PropertyAddress

-- Unused Column Deletion

Select * 
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate