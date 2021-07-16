

--Cleaning Data in SQL Queries
select *
from PortfolioProject.dbo.[Nashville Housing]

-- Standardize Date Format
Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.[Nashville Housing]

update [Nashville Housing]
set SaleDate = CONVERT(date,saleDate)

-- If it doesn't Update properly
Alter Table [Nashville Housing]
add SaleDateConverted Date;

update [Nashville Housing]
set SaleDateConverted = CONVERT(date,saleDate)

---- Populate Property Address data
Select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.[Nashville Housing] a
join PortfolioProject.dbo.[Nashville Housing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b .[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.[Nashville Housing] a
join PortfolioProject.dbo.[Nashville Housing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b .[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.[Nashville Housing]

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.[Nashville Housing]

-------------

ALTER TABLE  [Nashville Housing]
Add PropertySplitAddress Nvarchar(255);
Update[Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )
-----------------

ALTER TABLE [Nashville Housing]
Add PropertySplitCity Nvarchar(255);
Update [Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.[Nashville Housing]


Select OwnerAddress
From PortfolioProject.dbo.[Nashville Housing]

---#it understands period not comma, so replaced comma with period and it give the value from the end.
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)   
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.[Nashville Housing]

ALTER TABLE  [Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);
Update[Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)  
-----------------

ALTER TABLE [Nashville Housing]
Add OwnerSplitCity Nvarchar(255);
Update [Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Nashville Housing]
Add OwnerSplitState Nvarchar(255);
Update [Nashville Housing]
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject.dbo.[Nashville Housing]



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.[Nashville Housing]
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
case when SoldAsVacant ='Y' then 'YES'
	when SoldAsVacant ='N' then 'NO'
	ELSE SoldAsVacant
	END
From PortfolioProject.dbo.[Nashville Housing]

Update dbo.[Nashville Housing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.[Nashville Housing]
)
select *
From RowNumCTE
Where row_num > 1

-- Delete Unused Columns
select *
from PortfolioProject.dbo.[Nashville Housing]

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

