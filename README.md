# BI Assignment

This repository contains my submission for the BI technical assignment, covering SQL analysis, Python API extraction

## Project Structure

```bash
bi-assignment/
├── sql/
│   ├── task1-1.sql      # Customer Segmentation
│   └── task1-2.sql      # Marketing Channel Performance
├── python/
│   └── exchange_rate.py # Exchange Rate ETL Script
└── README.md
```

## Task Overview

### SQL Tasks

* **Task 1.1:** Customer segmentation based on purchase activity in the last 90 days
* **Task 1.2:** Marketing channel performance analysis over the last 30 days

### Python Task

* **Task 2.1:** Extract exchange rate data from API and prepare for loading into database / spreadsheet

## How to Run Python Script

### 1. Install dependencies

```bash
pip install requests
```

### 2. Run the script

```bash
cd python
python exchange_rate.py
```

## Notes

The Python script demonstrates a simple ETL flow:

* Extract exchange rate data from API
* Transform response into structured output
* Prepare for loading into downstream systems

