CREATE OR REPLACE VIEW `hepsiemlak-470514.hepsiemlak_case.vw_listings_with_dq` AS
SELECT
  e.*,
  t.p01, t.p50, t.p99,
  CASE
    WHEN e.PricePerSqm_TL IS NULL THEN NULL
    WHEN e.ListingSqm IS NULL OR e.ListingSqm <= 0 THEN 'BAD_SQM'
    WHEN t.p99 IS NOT NULL AND e.PricePerSqm_TL > t.p99 THEN 'HIGH_PPSQM'
    WHEN t.p01 IS NOT NULL AND e.PricePerSqm_TL < t.p01 THEN 'LOW_PPSQM'
    WHEN t.p50 IS NOT NULL AND e.PricePerSqm_TL > 50 * t.p50 THEN 'CURRENCY_SUSPECT'
    ELSE NULL
  END AS primary_flag,
  (t.p99 IS NOT NULL AND e.PricePerSqm_TL > t.p99) AS is_high_ppsqm,
  (t.p01 IS NOT NULL AND e.PricePerSqm_TL < t.p01) AS is_low_ppsqm,
  (t.p50 IS NOT NULL AND e.PricePerSqm_TL > 50 * t.p50) AS is_currency_suspect,
  (e.ListingSqm IS NULL OR e.ListingSqm <= 0) AS is_bad_sqm
FROM `hepsiemlak-470514.hepsiemlak_case.vw_listings_enriched` e
LEFT JOIN `hepsiemlak-470514.hepsiemlak_case.dq_thresholds_ppsqm_city_cat_ym` t
  ON t.month_id = DATE_TRUNC(e.ListingStartDate, MONTH)
 AND t.City = e.City
 AND t.ListingCategory = e.ListingCategory;