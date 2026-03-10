import requests
from datetime import datetime, timezone, timedelta

API_URL    = "https://api.exchangerate-api.com/v4/latest/USD"
BANGKOK_TZ = timezone(timedelta(hours=7))

def fetch_exchange_rates(api_url):
    # funtion 1 ดึงข้อมูล exchange rate จาก API โดยใช้ requests library
    try:
        response = requests.get(api_url, timeout=10)
        response.raise_for_status()
        print("Exchange rate data fetched successfully")
        return response.json()
    # จับข้อผิดพลาดที่อาจเกิดขึ้น เช่น network error, timeout, หรือ response ไม่ถูกต้อง
    except Exception as e:
        print(f"ERROR: Failed to fetch exchange rate data: {e}")
        raise

def transform_rates(api_data):
    # funtion 2 แปลงข้อมูลที่ได้จาก API ให้อยู่ในรูปแบบที่ต้องการ
    rates      = api_data["rates"]
    fetch_date = datetime.now(BANGKOK_TZ).strftime("%Y-%m-%d")

    usd_to_thb = rates.get("THB")
    usd_to_eur = rates.get("EUR")

    # เช็คว่าได้ค่ามาครบหรือไม่ ถ้าไม่ครบให้แจ้ง error และหยุดการทำงาน
    if not usd_to_thb or not usd_to_eur:
        print("ERROR: Not Found required exchange rates in API response")
        raise ValueError("Missing required rates")

    # คำนวณ EUR to THB จาก USD to THB หารด้วย USD to EUR
    eur_to_thb = round(usd_to_thb / usd_to_eur, 4)

    rows = [
        {
            "date":          fetch_date,
            "from_currency": "USD",
            "to_currency":   "THB",
            "exchange_rate": usd_to_thb,
        },
        {
            "date":          fetch_date,
            "from_currency": "EUR",
            "to_currency":   "THB",
            "exchange_rate": eur_to_thb,
        },
    ]

    # แสดงผลลัพธ์ที่ได้จากการแปลงข้อมูล เพื่อให้เห็นว่าข้อมูลถูกต้องและพร้อมใช้งาน
    print(f"Transform data successfully: USD/THB={usd_to_thb}, EUR/THB={eur_to_thb}")
    return rows

    # เริ่มต้น ETL process โดยเรียกใช้ Funtion 1 และ Funtion 2 ตามลำดับ
    # และจัดการกับข้อผิดพลาดที่อาจเกิดขึ้นในแต่ละขั้นตอน
def main():
    print("Start ETL")

    try:
        # Step 1: ดึงข้อมูลจาก API
        api_data = fetch_exchange_rates(API_URL)

        # Step 2: แปลงข้อมูล
        rows = transform_rates(api_data)

        # Step 3: แสดงผล
        print("\nExchange Rates Today")
        for row in rows:
            print(f"{row['from_currency']} → {row['to_currency']}: {row['exchange_rate']} THB")

        print("\nOutput for Schema Table")
        # format for reporting.=
        print(rows)

    except Exception as e:
        print(f"ERROR: ETL failed: {e}")

if __name__ == "__main__":
    main()