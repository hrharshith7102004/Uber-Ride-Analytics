# Uber-Ride-Analytics

🚖 Uber Ride Analytics – SQL Capstone Project

📌 Project Overview
This project demonstrates end‑to‑end SQL skills applied to a ride‑sharing dataset. It covers data cleaning, business analysis, performance optimization, and auditing. The goal is to showcase how SQL can be used to solve real business problems such as driver recruitment, revenue leakage, cancellation trends, and seasonal fare variations.

🗂️ Datasets Used
- rides_dataset1 – Ride details (ride_id, start_city, start_time, end_time, fare, ride_status, driver_id, ride_date).
- city_dataset2 – City information (city_id, city_name, population).
- driver_dataset3 – Driver details (driver_id, driver_name, avg_driver_rating, vehicle_type, total_rides, total_earnings, ride_acceptance_rate, city_id).
- payment_dataset4 – Payment transactions (ride_id, fare, payment_method, transaction_status).

🛠️ Project Sections
1. Data Cleaning
- Handled missing values (fare, population).
- Removed duplicate rides using ROW_NUMBER().
- Ensured driver consistency across datasets.
2. City‑Level Performance Optimization
- Identified top 3 cities where Uber should focus driver recruitment based on:
- High demand
- High cancellation rates
- Low driver ratings
3. Revenue Leakage Analysis
- Detected rides marked as Completed but missing payments or with failed transactions.
4. Cancellation Analysis
- Studied cancellation patterns by:
- City
- Vehicle type
- Time of day
- Correlated cancellations with completed ride revenue.
5. Seasonal Fare Variations
- Grouped rides by Spring, Summer, Autumn, Winter.
- Analyzed average fare trends across seasons.
6. Average Ride Duration
- Calculated average ride duration (minutes) per city.
- Linked duration insights to potential customer satisfaction.
7. Performance Optimization
- Created indexes on ride_date and payment_method for faster queries.
8. Views for Quick Reporting
- avg_fare_by_city → Average fare per city.
- driver_performance → Driver ratings, earnings, acceptance rate.
9. Auditing with Triggers
- trg_ride_status_change → Logs ride status changes into ride_status_log for auditing.

📊 Key Business Insights
- Cities with high cancellations and low ratings need urgent driver recruitment.
- Revenue leakage occurs when rides are completed but payments fail or are missing.
- Peak cancellation hours highlight operational inefficiencies.
- Seasonal fare variations can guide pricing strategies.
- Average ride duration by city can be linked to customer satisfaction metrics.

🧰 Skills Demonstrated
- SQL Data Cleaning (NULL handling, duplicates, consistency checks).
- Analytical Queries (aggregations, joins, CASE statements).
- Optimization (indexes, views).
- Auditing & Automation (triggers).
- Business Problem Solving with SQL.

🚀 How to Run
- Import datasets into your SQL Server database (HAPPY).
- Run the script Uber-SQl-Analytics.sql (organized by sections).
- Use the views (avg_fare_by_city, driver_performance) for quick reporting.
- Check ride_status_log for auditing ride status changes.


