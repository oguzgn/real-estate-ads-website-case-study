CREATE OR REPLACE VIEW `hepsiemlak-470514.hepsiemlak_case.vw_listings_enriched` AS
WITH base AS (
  SELECT
    SAFE_CAST(ListingKey AS INT64) AS ListingKey,
    SAFE_CAST(FirmKey AS INT64) AS FirmKey,
    TRIM(ListingType) AS ListingType,
    TRIM(ListingCategory) AS ListingCategory,
    TRIM(ListingSubCategory) AS ListingSubCategory,
    SAFE_CAST(ListingPrice AS NUMERIC) AS ListingPrice,
    UPPER(TRIM(ListingPriceCurrency)) AS ListingPriceCurrency,
    SAFE_CAST(ListingSqm AS NUMERIC) AS ListingSqm,
    SAFE_CAST(ListingStartDateTime AS DATE) AS ListingStartDate,
    SAFE_CAST(ListingEndDateTime AS DATE) AS ListingEndDate,
    SAFE_CAST(ListingFloorCount AS INT64) AS ListingFloorCount,
    TRIM(ListingFloor) AS ListingFloor,
    SAFE_CAST(ListingAge AS INT64) AS ListingAge,
    SAFE_CAST(ListingLocationID AS INT64) AS ListingLocationID
  FROM `hepsiemlak-470514.hepsiemlak_case.listings`
)
SELECT
  b.*,
  TRIM(m.City) AS City,
  TRIM(m.County) AS County,
  TRIM(m.District) AS District,
  CASE WHEN b.ListingPriceCurrency='TL' THEN b.ListingPrice END AS Price_TL,
  CASE WHEN b.ListingPriceCurrency='TL'
       THEN SAFE_DIVIDE(b.ListingPrice, NULLIF(b.ListingSqm, 0)) END AS PricePerSqm_TL,
  CASE
    WHEN b.ListingStartDate IS NULL THEN NULL
    ELSE GREATEST(DATE_DIFF(COALESCE(b.ListingEndDate, CURRENT_DATE()), b.ListingStartDate, DAY), 0)
  END AS ListingActiveDays,
  (b.ListingEndDate IS NULL OR b.ListingEndDate >= CURRENT_DATE()) AS IsActive
FROM base b
LEFT JOIN `hepsiemlak-470514.hepsiemlak_case.location_mapping` m
  ON b.ListingLocationID = SAFE_CAST(m.DistrictID AS INT64);