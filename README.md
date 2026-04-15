# Manufacturing Process Analysis using SQL

## Project Overview
In this project, I analyzed manufacturing data using SQL to understand how consistent the production process is and to identify any unusual patterns.

The goal was to apply basic Statistical Process Control (SPC) techniques to monitor product measurements and detect when the process might be going out of control.

---

## Objectives
- Monitor production quality using data
- Identify inconsistencies in product dimensions
- Detect outliers using statistical methods
- Apply control limits to evaluate process stability

---

## Dataset
The dataset contains measurements of manufactured parts, including:

- item_no (unique item ID)
- length, width, height (dimensions)
- operator (machine/operator used)

---

## Key SQL Concepts Used
- Window Functions (RANK, AVG, STDEV)
- PARTITION BY
- Common Table Expressions (CTEs)
- Nested Queries
- Aggregations

---

## Analysis Performed

Some of the key analysis steps include:

- Ranked items by volume for each operator
- Identified top 3 largest items per operator
- Compared operator performance based on average volume
- Calculated deviations from average dimensions
- Detected outliers using Z-score
- Calculated rolling averages
- Measured contribution of each operator to total production

---

## SPC (Statistical Process Control)

To monitor the process, I calculated:

- Average height
- Standard deviation
- Upper Control Limit (UCL)
- Lower Control Limit (LCL)

Items falling outside these limits were flagged as potential issues.

---

## Challenges Faced
One challenge was working with window functions for multiple calculations at once, especially when combining rolling averages, standard deviation, and ranking.

Understanding how PARTITION BY affects each calculation took some trial and error.

---

## What I Learned
- How to use SQL for real-world analytical problems
- Applying statistical concepts like Z-score and control limits
- Writing efficient queries using window functions
- Breaking down complex problems into smaller steps

---

## Insights
- Different operators show variation in production patterns
- Some items fall outside expected measurement ranges
- Not all variation is problematic, but extreme values need attention
- Using SPC helps identify when intervention is actually required

---

## How to Use
1. Import the dataset into SQL Server
2. Run the queries from the `/sql` folder
3. Review results for each analysis step
