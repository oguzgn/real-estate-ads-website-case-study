# Real-Estate Ads Website — Case Study

BigQuery üzerinde veri temizliği (**strict** raporlama katmanı), kontrat-seviyesi (**simple**) retention analizi ve BigQuery ML ile yenileme tahmini. 
Görselleştirme ve iş takibi **Looker Studio** dashboard’ı ile yapılmıştır.

> Dashboard: https://lookerstudio.google.com/u/0/reporting/2bec2839-99ce-4cb6-9bf8-779b0b6dfa72/page/1fIWF

---

## 1) Proje Özeti

- **Soru 1 (Raporlama):** İlan verisini temizleyip (DQ + outlier trim) **strict** bir görünüm oluşturduk; coğrafi (il/ilçe/mahalle) özetlerle yönetim KPI’larını çıkardık.
- **Soru 2 (Retention):**
  - **Aşama 1 – Mevcut Durum:** Aylık satırlarda yıllık alanların (annual fee vb.) tekrar ettiğini saptadık. Analizi **kontrat** seviyesine indirdik (annual tekilleşti, aylık metrikler yıl toplamına çevrildi).
  - **Aşama 2 – ML:** Contract-level “simple” veriyle BigQuery ML (logistic regression) kurduk, eşiği F1’e göre optimize ettik ve **ops kuyruk** (High Risk) oluşturarak aksiyona bağladık.

---

## 2) İçerik / Klasörler

- **BigQuery SQL Codes/**
  - `vw_listings_reporting_clean_strict.sql` → DQ + p01–p99 trim + iş kuralları
  - `vw_geo_district.sql` → District bazlı fiyat / TL/m² / adet özetleri
  - `vw_dash_contract_list_simple.sql` → Kontrat-seviyesi (annual tekil + yıllık toplam)
  - `vw_dash_kpi_by_package_simple.sql`, `vw_dash_kpi_total_simple.sql`, `vw_dash_package_monthly_simple.sql`
  - `vw_ml_summary_simple.sql`, `vw_ml_decile_dist_simple.sql`, `vw_ml_ops_queue_simple.sql`
- **Looker Dashboard Snapshot/** → Ekran görüntüleri
- **Retention ML – Threshold Selection/** → Eşik tarama (F1 maks.) çıktısı
- **Hepsiemlak-Oguzhan_Gunduz_.pdf** → Sunum/PDF

---

## 3) Metodoloji (Kısa)

### 3.1 Raporlama (Soru 1)
- **Outlier trim:** `Ay × Şehir × Kategori` bazında **p01–p99**; düşük hacimde `Şehir × Kategori → Kategori → Global` fallback.
- **İş kuralları (guard rails):** Satılık/Kiralık için m², TL, TL/m² aralıkları + DQ bayrakları (kur şüphesi, aşırı küçük/büyük m², vb.).
- **Strict görünüm:** KPI’ları bozabilecek uç değerleri dışarıda bırakır.
- **Geo katmanı:** İl/ilçe/mahalle kırılımında fiyat/TL-m²/adet.

### 3.2 Retention – Mevcut Durum (Aşama 1)
- **Gözlem:** Annual alanlar (örn. fee) **tüm periodlarda tekrar** ediyor; aylık performans ise değişiyor.
- **Çözüm (simple):** Kontrat-level’e indirgendi:
  - Annual alan **tekil**, aylık metrikler **yıl toplamı**: `sum_pv, sum_listings, sum_conv`
  - Türetilen KPI’lar: `conv_rate_year`, `pv_per_listing_year`,
    `cost_per_view_year`, `cost_per_listing_year`, `cost_per_conversion_year`
  - **Label:** Bitiş ayındaki durum → `1=Yeniledi, 0=Yenilemedi`
- **View:** `vw_dash_contract_list_simple`

### 3.3 Retention – ML (Aşama 2)
- **Model:** BigQuery ML **Logistic Regression** (`AUTO_CLASS_WEIGHTS=TRUE`)
- **Train/Test:** Zaman temelli; **TEST** = “son **iki sınıflı** ay”, diğer etiketliler TRAIN
- **Eşik Tarama (F1):** 0.01 adımlı tarama → **en iyi eşik = 0.43**
- **Sonuç (örnek):**
  - **F1 ≈ 0.80**, **Precision ≈ 0.707**, **Recall ≈ 0.922**
  - (Varsayılan 0.50 eşiğinde `ML.EVALUATE`: F1 ≈ 0.749, ROC-AUC ≈ 0.764)
- **Skorlama & Operasyon:**
  - Decile dağılımı: `vw_ml_decile_dist_simple`
  - Özet (end_dt × paket × risk band): `vw_ml_summary_simple`
  - **Ops Queue (High Risk):** `Expected Fee at Risk = (1 − renew_prob) × annual_fee` → `vw_ml_ops_queue_simple`

---

## 4) Dashboard

- **Retention & KPI’s by Package** — Paket bazında renewal ve maliyet/performans KPI’ları  
- **Package × Period Trend** — Aylık trendler (pv, listings, conv, oranlar)  
- **ML Summary / Distribution / Ops Queue (High Risk)** — Skor dağılımı, özetler ve aksiyon listesi

Link: https://lookerstudio.google.com/u/0/reporting/2bec2839-99ce-4cb6-9bf8-779b0b6dfa72/page/1fIWF

---

## 5) Reprodüksiyon (Kısaca)

1. SQL dosyalarını BigQuery’de oluşturun (dataset: `hepsiemlak_case` benzeri).  
2. `vw_listings_reporting_clean_strict` → `vw_geo_district` → `vw_dash_*_simple` → `vw_ml_*_simple` sırasıyla build edin.  
3. BigQuery ML modeli: `retention_lr_simple` (Logistic Regression).  
4. Looker Studio’ya BigQuery view’larını bağlayın ve sayfaları oluşturun.

> Not: Proje/dataset adlarını kendi GCP ortamınıza göre düzenleyin.

---

## 6) Sonuç

- **Strict** katmanla güvenilir KPI, **simple** (kontrat-level) ile adil ve açıklanabilir retention analizi sağlandı.  
- Eşik optimizasyonu (0.43) ile **yüksek recall** ve operasyonel fayda elde edildi; **Ops Queue** sahaya indirilebilir bir çıktı sağlıyor.

---


## İletişim

- **Ad Soyad:** Oğuzhan Gündüz  
- **E-posta:** oguzhangundzz@gmail.com  
- **LinkedIn/GitHub:** https://www.linkedin.com/in/oguzgn/
