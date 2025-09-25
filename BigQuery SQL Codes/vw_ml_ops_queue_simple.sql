CREATE OR REPLACE VIEW `hepsiemlak-470514.hepsiemlak_case.vw_ml_ops_queue_simple` AS
SELECT
  s.end_dt,
  s.FirmKey,
  s.FirmPackageKey,
  s.PackageTypeMapping,
  s.renew_prob,
  s.decile,
  s.risk_band,
  m.annual_fee,
  m.sum_listings,
  m.sum_pv,
  m.sum_conv,
  m.pv_per_listing_year,
  m.conv_rate_year,
  (1 - s.renew_prob) * m.annual_fee AS expected_fee_at_risk,
  ROW_NUMBER() OVER (
    PARTITION BY s.end_dt
    ORDER BY (1 - s.renew_prob) * m.annual_fee DESC
  ) AS rank_in_end_dt
FROM `hepsiemlak-470514.hepsiemlak_case.vw_retention_scores_simple` s
JOIN `hepsiemlak-470514.hepsiemlak_case.vw_contract_annual_metrics_simple` m
  USING (FirmKey, FirmPackageKey, end_dt)
WHERE s.risk_band = 'High Risk';
