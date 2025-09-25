CREATE OR REPLACE VIEW `hepsiemlak-470514.hepsiemlak_case.vw_ml_summary_simple` AS
SELECT
  end_dt,
  PackageTypeMapping,
  risk_band,
  COUNT(*)                           AS n_contracts,
  AVG(renew_prob)                    AS avg_prob,
  APPROX_QUANTILES(renew_prob,100)[OFFSET(50)] AS median_prob
FROM `hepsiemlak-470514.hepsiemlak_case.vw_retention_scores_simple`
GROUP BY end_dt, PackageTypeMapping, risk_band;
