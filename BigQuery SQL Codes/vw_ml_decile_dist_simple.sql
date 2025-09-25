CREATE OR REPLACE VIEW `hepsiemlak-470514.hepsiemlak_case.vw_ml_decile_dist_simple` AS
SELECT
  end_dt,
  decile,
  COUNT(*)        AS n,
  AVG(renew_prob) AS avg_prob
FROM `hepsiemlak-470514.hepsiemlak_case.vw_retention_scores_simple`
GROUP BY end_dt, decile
ORDER BY end_dt, decile;
