-- =====================================================
-- KUMPULAN SKRIP SQL SETIAP PERTANYAAN DI DASHBOARD METABASE
-- PROJECT UAS BI: KIRANA HOME & LIVING
-- =====================================================

-- ==========================================
-- TAB 1: EXECUTIVE PERFORMANCE & TARGET ACHIEVEMENT
-- ==========================================

-- 1. Kartu KPI: Total Net Sales
SELECT SUM(net_sales) AS "Total Net Sales" 
FROM vw_sales_performance;

-- 2. Kartu KPI: Gross Margin %
SELECT ROUND((SUM(gross_margin_idr) / NULLIF(SUM(net_sales), 0)) * 100, 2) AS "Avg Gross Margin %" 
FROM vw_sales_performance;

-- 3. Chart: Chart_Monthly_Sales (Tren Penjualan Bulanan)
SELECT 
    DATE_TRUNC('month', transaction_date) AS "bulan",
    SUM(net_sales) AS "total_net_sales"
FROM vw_sales_performance
GROUP BY 1
ORDER BY 1 ASC;

-- 4. Chart: Chart_Channel_Breakdown (Performa Kanal Penjualan)
SELECT 
    channel_type,
    SUM(net_sales) AS "total_net_sales"
FROM vw_sales_performance
GROUP BY channel_type
ORDER BY "total_net_sales" DESC;


-- ==========================================
-- TAB 2: OMNICHANNEL, REGION & STORE DEEP-DIVE
-- ==========================================

-- 5. Chart: Sales_by_Region (Kontribusi Net Sales per Region)
SELECT 
    region,
    SUM(net_sales) AS "total_net_sales"
FROM vw_sales_performance
WHERE region IS NOT NULL
GROUP BY region
ORDER BY "total_net_sales" DESC;

-- 6. Table: Store_Leaderboard (Peringkat Cabang Toko Terbaik)
SELECT 
    store_name AS "Nama Toko",
    region AS "Region",
    SUM(net_sales) AS "Total Net Sales",
    SUM(quantity) AS "Total Qty Terjual",
    ROUND((SUM(gross_margin_idr) / NULLIF(SUM(net_sales), 0)) * 100, 2) AS "Avg Gross Margin %"
FROM vw_sales_performance
WHERE store_name IS NOT NULL
GROUP BY store_name, region
ORDER BY "Total Net Sales" DESC;

-- 7. Chart: Channel_Performance (Analisis Kanal Lengkap)
SELECT 
    channel_type AS "Channel",
    COUNT(DISTINCT transaction_id) AS "Total Transaksi",
    SUM(net_sales) AS "Total Net Sales",
    ROUND(SUM(net_sales) / NULLIF(COUNT(DISTINCT transaction_id), 0), 2) AS "Average Order Value"
FROM vw_sales_performance
GROUP BY channel_type
ORDER BY "Total Net Sales" DESC;

-- 8. Chart: Regional_Monthly_Trend (Tren Bulanan per Region)
SELECT 
    DATE_TRUNC('month', transaction_date) AS "bulan",
    region,
    SUM(net_sales) AS "total_net_sales"
FROM vw_sales_performance
WHERE region IS NOT NULL
GROUP BY 1, 2
ORDER BY 1 ASC;


-- ==========================================
-- TAB 3: MARGIN OPTIMIZATION & PROMOTION EFFECTIVENESS
-- ==========================================

-- 9. Chart: Category_Margin_Performance (Margin per Kategori Produk)
SELECT 
    category AS "Kategori Produk",
    SUM(net_sales) AS "Total Net Sales",
    SUM(gross_margin_idr) AS "Total Gross Margin (IDR)",
    ROUND((SUM(gross_margin_idr) / NULLIF(SUM(net_sales), 0)) * 100, 2) AS "Avg Gross Margin %"
FROM vw_sales_performance
WHERE category IS NOT NULL
GROUP BY category
ORDER BY "Total Net Sales" DESC;

-- 10. Chart: Discount_Impact (Efektivitas Diskon & Voucher)
SELECT 
    CASE 
        WHEN discount_or_voucher_amount = 0 THEN '0. Tanpa Diskon (Rp 0)'
        WHEN discount_or_voucher_amount > 0 AND discount_or_voucher_amount <= 50000 THEN '1. Diskon Ringan (<= 50rb)'
        WHEN discount_or_voucher_amount > 50000 AND discount_or_voucher_amount <= 200000 THEN '2. Diskon Sedang (50rb - 200rb)'
        ELSE '3. Diskon Tinggi (> 200rb)'
    END AS "Tier Diskon",
    COUNT(DISTINCT transaction_id) AS "Total Transaksi",
    SUM(net_sales) AS "Total Net Sales",
    SUM(gross_margin_idr) AS "Total Gross Margin"
FROM vw_sales_performance
GROUP BY 1
ORDER BY 1 ASC;

-- 11. Chart: Top 10 Produk Paling Menguntungkan (Top Profitable SKU)
SELECT 
    sku AS "SKU Produk",
    brand AS "Brand",
    category AS "Kategori",
    SUM(quantity) AS "Total Terjual",
    SUM(gross_margin_idr) AS "Total Gross Margin (IDR)"
FROM vw_sales_performance
WHERE sku IS NOT NULL
GROUP BY sku, brand, category
ORDER BY "Total Gross Margin (IDR)" DESC
LIMIT 10;


-- ==========================================
-- TAB 4: RETURN ANALYTICS (ANALISIS RETUR PRODUK)
-- ==========================================

-- 12. Chart: Returns_by_Reason (Alasan Utama Retur)
SELECT 
    return_reason AS "Alasan Retur",
    COUNT(return_id) AS "Total Frekuensi Retur",
    SUM(return_qty) AS "Total Qty Retur",
    SUM(refund_amount) AS "Total Nilai Refund (IDR)"
FROM vw_returns_analysis
WHERE return_reason IS NOT NULL
GROUP BY return_reason
ORDER BY "Total Frekuensi Retur" DESC;

-- 13. Chart: Top_Returned_SKU (Produk dengan Retur Tertinggi)
SELECT 
    sku AS "SKU Produk",
    category AS "Kategori",
    SUM(return_qty) AS "Total Qty Retur",
    SUM(refund_amount) AS "Total Refund (IDR)"
FROM vw_returns_analysis
WHERE sku IS NOT NULL
GROUP BY sku, category
ORDER BY "Total Qty Retur" DESC
LIMIT 10;

-- 14. Chart: Returns_by_Channel (Analisis Retur Berdasarkan Kanal)
SELECT 
    channel AS "Kanal Penjualan",
    COUNT(return_id) AS "Total Transaksi Retur",
    SUM(refund_amount) AS "Total Nilai Refund"
FROM vw_returns_analysis
GROUP BY channel
ORDER BY "Total Transaksi Retur" DESC;