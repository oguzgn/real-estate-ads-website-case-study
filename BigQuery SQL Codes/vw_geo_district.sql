CREATE OR REPLACE VIEW `hepsiemlak-470514.hepsiemlak_case.vw_geo_district` AS
WITH b AS (
  SELECT
    CASE
      WHEN City ='Kıbrıs'
        THEN CONCAT(TRIM(District), ', ', TRIM(County), ', ', TRIM(City), ', Cyprus')
      ELSE CONCAT(TRIM(District), ', ', TRIM(County), ', ', TRIM(City), ', Turkey')
    END AS geo_address_district,
    ListingCategory,
    PricePerSqm_TL_winsor,
    Price_TL, City
  FROM `hepsiemlak-470514.hepsiemlak_case.vw_listings_reporting_clean_strict`
  WHERE District IS NOT NULL AND County IS NOT NULL AND City IS NOT NULL
)
SELECT
  City,
  geo_address_district,
  AVG(CASE WHEN ListingCategory='Satılık' THEN PricePerSqm_TL_winsor END) AS avg_ppsqm_sale_tl,
  AVG(CASE WHEN ListingCategory='Kiralık' THEN PricePerSqm_TL_winsor END) AS avg_ppsqm_rent_tl,
  AVG(CASE WHEN ListingCategory='Satılık' THEN Price_TL END)              AS avg_price_sale_tl,
  AVG(CASE WHEN ListingCategory='Kiralık' THEN Price_TL END)              AS avg_price_rent_tl,
  COUNTIF(ListingCategory='Satılık')                                       AS sale_n,
  COUNTIF(ListingCategory='Kiralık')                                       AS rent_n
FROM b
GROUP BY geo_address_district , City