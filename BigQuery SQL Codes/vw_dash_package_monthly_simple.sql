CREATE OR REPLACE VIEW `hepsiemlak-470514.hepsiemlak_case.vw_dash_package_monthly_simple` AS
SELECT
  TRIM(Period) AS period_ym,
  TRIM(PackageTypeMapping) AS PackageTypeMapping,

  -- Aylık toplamlar
  SUM(SAFE_CAST(REPLACE(CAST(TotalPageview   AS STRING), ',', '.') AS NUMERIC)) AS pv,
  SUM(SAFE_CAST(REPLACE(CAST(TotalListings   AS STRING), ',', '.') AS NUMERIC)) AS listings,
  SUM(SAFE_CAST(REPLACE(CAST(TotalConversion AS STRING), ',', '.') AS NUMERIC)) AS conv,

  -- Aylık oranlar (ratio-of-sums)
  SAFE_DIVIDE(
    SUM(SAFE_CAST(REPLACE(CAST(TotalConversion AS STRING), ',', '.') AS NUMERIC)),
    NULLIF(SUM(SAFE_CAST(REPLACE(CAST(TotalPageview AS STRING), ',', '.') AS NUMERIC)), 0)
  ) AS conv_rate_month,

  SAFE_DIVIDE(
    SUM(SAFE_CAST(REPLACE(CAST(TotalPageview AS STRING), ',', '.') AS NUMERIC)),
    NULLIF(SUM(SAFE_CAST(REPLACE(CAST(TotalListings AS STRING), ',', '.') AS NUMERIC)), 0)
  ) AS pv_per_listing_month
FROM `hepsiemlak-470514.hepsiemlak_case.retention`
GROUP BY period_ym, PackageTypeMapping
ORDER BY period_ym, PackageTypeMapping;
