CREATE OR REPLACE VIEW `hepsiemlak-470514.hepsiemlak_case.vw_dash_kpi_by_package_simple` AS
SELECT
  c.PackageTypeMapping,

  COUNT(*)                                                     AS contracts,
  COUNTIF(c.label_contract IS NOT NULL)                        AS contracts_labeled,
  SAFE_DIVIDE(COUNTIF(c.label_contract = 1),
              NULLIF(COUNTIF(c.label_contract IS NOT NULL), 0)) AS renewal_rate,

  -- Weighted (ratio-of-sums) KPI'lar
  SAFE_DIVIDE(SUM(c.annual_fee), NULLIF(SUM(c.sum_pv), 0))        AS w_cost_per_view_year,
  SAFE_DIVIDE(SUM(c.annual_fee), NULLIF(SUM(c.sum_listings), 0))  AS w_cost_per_listing_year,
  SAFE_DIVIDE(SUM(c.annual_fee), NULLIF(SUM(c.sum_conv), 0))      AS w_cost_per_conversion_year,
  SAFE_DIVIDE(SUM(c.sum_conv),  NULLIF(SUM(c.sum_pv), 0))         AS w_conv_rate_year,
  SAFE_DIVIDE(SUM(c.sum_pv),    NULLIF(SUM(c.sum_listings), 0))   AS w_pv_per_listing_year
FROM `hepsiemlak-470514.hepsiemlak_case.vw_contract_annual_metrics_simple` c
GROUP BY c.PackageTypeMapping
ORDER BY c.PackageTypeMapping;
