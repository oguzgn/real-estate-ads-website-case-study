CREATE OR REPLACE VIEW `hepsiemlak-470514.hepsiemlak_case.vw_retention_scores_simple` AS
WITH to_score AS (
  SELECT *
  FROM `hepsiemlak-470514.hepsiemlak_case.vw_contract_annual_metrics_simple`
  WHERE label_contract IS NULL                    -- <-- max(end_dt) FİLTRESİ YOK
),
pred AS (
  SELECT
    s.FirmKey, s.FirmPackageKey, s.PackageTypeMapping, s.end_dt,
    (SELECT y.prob FROM UNNEST(p.predicted_label_probs) y
     WHERE y.label = 1 LIMIT 1) AS renew_prob
  FROM ML.PREDICT(
         MODEL `hepsiemlak-470514.hepsiemlak_case.retention_lr_simple`,
         (SELECT
            PackageTypeMapping, annual_fee, sum_active_days, sum_listings, sum_pv, sum_conv,
            pv_per_listing_year, conv_rate_year, FirmKey, FirmPackageKey, end_dt
          FROM to_score)
       ) p
  JOIN to_score s USING (FirmKey, FirmPackageKey, end_dt)
)
SELECT
  FirmKey, FirmPackageKey, PackageTypeMapping, end_dt, renew_prob,
  -- decile'ı her dönem içinde ver: görselleştirirken daha anlamlı
  NTILE(10) OVER (PARTITION BY end_dt ORDER BY renew_prob) AS decile,
  CASE
    WHEN renew_prob >= 0.43        THEN 'Low Risk'
    WHEN renew_prob >= 0.43 * 0.75 THEN 'Medium Risk'
    ELSE 'High Risk'
  END AS risk_band
FROM pred;
