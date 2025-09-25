CREATE OR REPLACE VIEW `hepsiemlak-470514.hepsiemlak_case.vw_dash_contract_list_simple` AS
SELECT
  FirmKey,
  FirmPackageKey,
  PackageTypeMapping,
  start_dt,
  end_dt,
  first_period,
  last_period,
  label_contract,                 -- 1=Yeniledi, 0=Yenilemedi, NULL=bilinmiyor
  EXTRACT(YEAR FROM end_dt) AS end_year,

  annual_fee,                     -- yıllık ücret (tek değer)
  sum_pv,
  sum_listings,
  sum_conv,

  conv_rate_year,
  pv_per_listing_year,
  cost_per_view_year,
  cost_per_listing_year,
  cost_per_conversion_year
FROM `hepsiemlak-470514.hepsiemlak_case.vw_contract_annual_metrics_simple`;
