-- Task 1.2: Marketing Channel Performance
-- วิเคราะห์ประสิทธิภาพของแต่ละ channel ใน 30 วันที่ผ่านมา

-- CTE ที่ 1: รวม ad spend 30 วัน
WITH spend_summary AS (
    SELECT
        channel,
        SUM(spend_amount) AS total_spend
    FROM ecommerce.marketing_spend
    WHERE spend_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
    GROUP BY channel
),

-- CTE ที่ 2: รวม revenue และจำนวน orders 30 วัน
orders_summary AS (
    SELECT
        acquisition_channel AS channel,
        SUM(total_amount)   AS total_revenue,
        COUNT(order_id)     AS num_orders
    FROM ecommerce.orders
    WHERE status = 'completed'
      AND order_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
    GROUP BY acquisition_channel
)

-- สรุปผลแต่ละ Channel
SELECT
    s.channel,
    ROUND(s.total_spend, 2)                                            AS total_ad_spend,
    ROUND(COALESCE(o.total_revenue, 0), 2)                             AS total_revenue,
    COALESCE(o.num_orders, 0)                                          AS num_orders,
    ROUND(SAFE_DIVIDE(COALESCE(o.total_revenue, 0), s.total_spend), 2) AS roas,
    ROUND(SAFE_DIVIDE(s.total_spend, NULLIF(o.num_orders, 0)), 2)      AS cost_per_order
FROM spend_summary s
LEFT JOIN orders_summary o ON s.channel = o.channel
ORDER BY roas DESC;