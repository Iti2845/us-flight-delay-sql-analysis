# us-flight-delay-sql-analysis
SQL analysis of 500K US domestic flights (2015) revealing counterintuitive findings — Spirit Airlines ranks last overall yet has the industry's second-lowest controllable delay. Built with Python for data preprocessing and MySQL for multi-table analysis using window functions, joins, and aggregations.

## Business Problem

Flight delays cost the US airline industry and economy between $30 and $34 billion annually. Airlines' operations and planning teams urgently need data-driven insights to distinguish between controllable delays—which they can address through scheduling and resource allocation—and structural delays driven by weather and airport congestion. This project analyzes 500,000 US domestic flights from 2015 using SQL to decompose delay patterns by airline, revealing which carriers truly manage their operations effectively versus those that simply benefit from favorable circumstances. The most striking discovery: Spirit Airlines, widely perceived as the industry's worst performer overall, actually has the second-lowest controllable delay rate—suggesting that reputation and operational reality may diverge when delays are properly categorized.

## Dataset 
**Source:** Kaggle — 2015 Flight Delays and Cancellations Volume: Original 5.8M rows, sampled 500K for analysis 

**Tables: 3 —** airlines (14 rows), airports (322 rows), flights (500K rows)
Sampling enabled faster SQL iteration and query optimization during development while preserving statistical representativeness across all carriers, routes, and seasons.
Analysis focuses on departure and arrival delays, airline-controllable vs. weather-driven delays, route performance, seasonal patterns, and cancellation root causes.

![Schema Diagram](schema-diagram.png)

## 10 Business Questions & Findings

### Q1: Which airline has the highest average departure delay?
**Finding:** Spirit Airlines leads with 15 minutes average departure delay, 
followed by Frontier at 12 minutes. However, Query 10 reveals Spirit's 
controllable delay is second-lowest in the industry — cascading network 
effects, not internal mismanagement, drive their overall numbers.

### Q2: Which day of week has worst on-time performance?
**Finding:** Monday has the highest average departure delay at 11 minutes, 
suggesting operational pressure at the start of the week due to high 
morning traffic volume. Thursday ranks second at 10 minutes.

### Q3: Which month has the highest average departure delay?
**Finding:** June is worst at 14 minutes, followed by July and December 
both at 12 minutes. Two distinct peak delay seasons emerge — summer 
thunderstorms and winter holidays — with September and October being 
the best months to fly at just 5 minutes average delay.

### Q4: Which origin airports have the highest cancellation rates?
**Finding:** LaGuardia (LGA) has the highest cancellation rate at 5%, 
followed by Dallas/Fort Worth and Newark both at 3%. LaGuardia's 
constrained single-runway layout, extreme traffic density, and New York 
winter weather create a system with no operational buffer — one weather 
event cascades into mass cancellations.

### Q5: What is the on-time performance rank of each airline?
**Finding:** Alaska Airlines ranks 1st with a remarkable -1 minute average 
arrival delay — meaning they arrive early on average. Spirit Airlines ranks 
last at 14 minutes. Mid-tier carriers show extreme parity, suggesting 
macro-level FAA congestion acts as an operational equalizer across 
standard networks.

### Q6: Which cancellation reason dominates?
**Finding:** Weather causes 54% of cancellations — expected and 
uncontrollable. However, a combined 46% stems from airline operations 
(28%) and National Aviation System inefficiencies (18%), representing 
thousands of potentially preventable cancellations annually. Security 
cancellations are virtually nonexistent at 0.04%.

### Q7: Which top 10 routes have the highest average arrival delay?
**Finding:** Miami→Denver leads at 24 minutes, followed by 
Chicago→Philadelphia at 22 minutes. Chicago appears repeatedly as a 
high-delay origin, confirming its status as a congested mega-hub. 
Sacramento→San Francisco shows 20-minute delays despite being an 
80-mile route — short distances offer zero buffer to recover ground delays 
in the air.

### Q8: What is the month-over-month delay trend using LAG()?
**Finding:** December shows the largest single month-over-month jump 
at +5 minutes from November, driven by compounding holiday volume and 
winter weather. September shows the largest drop at -5 minutes — 
confirming September/October as the system's natural recovery period 
between summer and winter peak seasons.

### Q9: Worst performing route per origin airport using ROW_NUMBER()
**Finding:** Arcata/Eureka→San Francisco shows 18-minute average delay 
despite short distance, while Anchorage→Seattle arrives early on average. 
This likely reflects Alaska Airlines' operational dominance on West Coast 
routes rather than schedule padding, which cannot be confirmed from this 
dataset alone.

### Q10: Delay type breakdown per airline
**Finding:** Delta has the highest airline-controlled delay at 24 minutes — 
contradicting their premium brand positioning. Spirit's controllable delay 
is just 14 minutes, second-lowest in the industry. Spirit's overall poor 
performance stems from AIR_SYSTEM_DELAY (26 min) and 
LATE_AIRCRAFT_DELAY (20 min) — structural vulnerabilities from their 
point-to-point route strategy through congested secondary airports, not 
internal operational failures.

## Business Recommendations
### 1. **Investigate Chicago as a Systemic Delay Origin**
**Finding from Query 7:** Chicago appears repeatedly as a high-delay origin across multiple routes (Chicago→Philadelphia at 22 minutes). Combined with Query 4 showing Dallas/Fort Worth and LaGuardia as cancellation hotspots, Chicago warrants deeper analysis.

**Recommendation:** Conduct a targeted analysis of Chicago-origin flights to isolate whether delays are weather-driven, air-traffic-system-driven, or airline-operational. Query your data to separate WEATHER_DELAY, AIR_SYSTEM_DELAY, and AIRLINE_DELAY for Chicago origins specifically. Once the root cause is identified, develop a mitigation strategy.
**Why this matters:** If Chicago delays are weather-related, schedule padding is appropriate. If systemic, coordination with ATC is needed. If airline-operational, process changes apply. The data doesn't yet tell you which.

### 2. **Examine Spirit Airlines' Air System vs. Controllable Delay Breakdown**
**Finding from Query 10:** Spirit has a 14-minute average AIRLINE_DELAY (second-lowest in industry) but ranks last overall with a 14-minute average ARRIVAL_DELAY. This means Spirit's poor performance is driven by AIR_SYSTEM_DELAY (26 min) and LATE_AIRCRAFT_DELAY (20 min), not internal operations.

**Recommendation:** Compare Spirit's AIR_SYSTEM_DELAY and LATE_AIRCRAFT_DELAY against industry median for these categories. If Spirit is a statistical outlier, investigate route network, aircraft positioning, and turnaround times. If Spirit's numbers match the industry, the brand perception problem isn't operational — it's a network strategy consequence.

**Why this matters:** This directly informs whether Spirit needs operational redesign or should adjust customer expectations via transparent delay messaging.

### 3. **Prioritize September/October Operations Over June/July**
**Finding from Query 3:** September and October average just 5 minutes departure delay, while June averages 14 minutes — nearly three times higher. Query 8 shows December→November has a +5 minute jump (seasonal weather impact).
**Recommendation:** Allocate premium crews, maintenance slots, and new service launches to September/October when the system naturally has a 9-minute operational buffer. Reserve June/July for status-quo operations and maintenance deferrals. Avoid introducing operational complexity (new routes, fleet transitions) during peak seasons.
**Why this matters:** You have quantified seasonal capacity. Use it to optimize fleet deployment and crew scheduling, not to fight the system during known peak periods.
