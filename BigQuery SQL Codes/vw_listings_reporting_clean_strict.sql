CREATE OR REPLACE VIEW `hepsiemlak-470514.hepsiemlak_case.vw_listings_reporting_clean_strict` AS
WITH rules AS (
  SELECT 'Satılık' AS ListingCategory,
         20.0 AS sqm_min, 1000.0 AS sqm_max,
         100000.0 AS price_min, 500000000.0 AS price_max,
         1000.0 AS ppsqm_min, 500000.0 AS ppsqm_max
  UNION ALL
  SELECT 'Kiralık',
         15.0, 1000.0,
         1000.0, 5000000.0,
         50.0, 50000.0
)
SELECT
  e.* EXCEPT(p01,p50,p99),
  CASE
    WHEN e.PricePerSqm_TL IS NULL THEN NULL
    WHEN e.is_low_ppsqm  AND e.p01 IS NOT NULL THEN e.p01
    WHEN e.is_high_ppsqm AND e.p99 IS NOT NULL THEN e.p99
    ELSE e.PricePerSqm_TL
  END AS PricePerSqm_TL_winsor
FROM `hepsiemlak-470514.hepsiemlak_case.vw_listings_with_dq` e
LEFT JOIN rules r
  ON r.ListingCategory = e.ListingCategory
WHERE
  e.p01 IS NOT NULL
  AND NOT e.is_low_ppsqm
  AND NOT e.is_high_ppsqm
  AND NOT e.is_bad_sqm
  AND NOT e.is_currency_suspect
  AND e.ListingSqm BETWEEN r.sqm_min AND r.sqm_max
  AND e.Price_TL   BETWEEN r.price_min AND r.price_max
  AND e.PricePerSqm_TL BETWEEN r.ppsqm_min AND r.ppsqm_max;