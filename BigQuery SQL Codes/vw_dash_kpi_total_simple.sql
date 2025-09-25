CREATE OR REPLACE VIEW `hepsiemlak-470514.hepsiemlak_case.vw_dash_kpi_total_simple` AS
SELECT
  COUNT(*)                                                     AS contracts,
  COUNTIF(label_contract IS NOT NULL)                          AS contracts_labeled,
  SAFE_DIVIDE(COUNTIF(label_contract = 1),
              NULLIF(COUNTIF(label_contract IS NOT NULL), 0))  AS renewal_rate,

  SAFE_DIVIDE(SUM(annual_fee), NULLIF(SUM(sum_pv), 0))         AS w_cost_per_view_year,
  SAFE_DIVIDE(SUM(annual_fee), NULLIF(SUM(sum_listings), 0))   AS w_cost_per_listing_year,
  SAFE_DIVIDE(SUM(annual_fee), NULLIF(SUM(sum_conv), 0))       AS w_cost_per_conversion_year,
  SAFE_DIVIDE(SUM(sum_conv),  NULLIF(SUM(sum_pv), 0))          AS w_conv_rate_year,
  SAFE_DIVIDE(SUM(sum_pv),    NULLIF(SUM(sum_listings), 0))    AS w_pv_per_listing_year
FROM `hepsiemlak-470514.hepsiemlak_case.vw_contract_annual_metrics_simple`;
