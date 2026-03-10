-- Task 1.1: Customer Segmentation
-- แบ่งลูกค้าออกเป็น 4 กลุ่ม ตามยอดซื้อใน 90 วันที่ผ่านมา
WITH customer_active_90d AS (
    SELECT customer_id, order_id, total_amount
    FROM ecommerce.orders
    WHERE status = 'completed'
      AND order_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
),

-- CTE ที่ 2: รวมยอดเงินและจำนวน orders ของแต่ละ customer
customer_summary AS (
    SELECT  customer_id,
            SUM(total_amount) AS total_spend_90d,
            COUNT(order_id)   AS num_orders_90d
    FROM customer_active_90d
    GROUP BY customer_id
),

-- CTE ที่ 3: ดึง customers ทั้งหมด
all_customers AS (
    SELECT DISTINCT customer_id
    FROM ecommerce.orders
),

-- CTE ที่ 4: แปะ segment label ให้แต่ละ customer
customer_segments AS (
    SELECT  ac.customer_id,
            COALESCE(cs.total_spend_90d, 0) AS total_spend_90d,
            COALESCE(cs.num_orders_90d,  0) AS num_orders_90d,
            CASE
                WHEN cs.customer_id IS NULL      THEN 'Dormant'
                WHEN cs.total_spend_90d >= 50000 THEN 'VIP'
                WHEN cs.total_spend_90d >= 10000 THEN 'Regular'
                ELSE 'Light'
            END AS segment
    FROM all_customers ac
    LEFT JOIN customer_summary cs ON ac.customer_id = cs.customer_id
)

-- สรุปผลแต่ละ segment
SELECT  segment,
        COUNT(customer_id)          AS num_customers,
        SUM(total_spend_90d)        AS total_revenue,
        ROUND(AVG(num_orders_90d), 2) AS avg_orders_per_customer
FROM customer_segments
GROUP BY segment