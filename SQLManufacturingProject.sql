USE SQL1Bootcamp;
GO

USE SQL1Bootcamp;
GO

SELECT * FROM manufacturing_parts1; 

--1. Calculate volume & rank items per operator

SELECT
    item_no,
    operator,
    length,
    width,
    height,
    (length * width * height) AS volume,
    RANK() OVER (
        PARTITION BY operator
        ORDER BY (length * width * height) DESC
    ) AS volume_rank
FROM manufacturing_parts1
ORDER BY operator, volume_rank

--2. Top 3 largest items (by volume) per operator

SELECT
    item_no,
    operator,
    volume,
    volume_rank
FROM
(
    SELECT
        item_no,
        operator,
        (length * width * height) AS volume,
        RANK() OVER (
            PARTITION BY operator
            ORDER BY (length * width * height) DESC
        ) AS volume_rank
    FROM manufacturing_parts1
) AS ranked_items
WHERE volume_rank <= 3
ORDER BY operator, volume_rank;

--3. Operators whose average volume is above overall average

SELECT
    operator,
    AVG(length * width * height * 1.0) AS avg_operator_volume
FROM manufacturing_parts1
GROUP BY operator
HAVING AVG(length * width * height * 1.0) >
(
    SELECT AVG(length * width * height * 1.0)
    FROM manufacturing_parts1
);

--4. Find average dimensions per operator + deviation from average

SELECT
    item_no,
    operator,
    length,
    width,
    height,

    -- averages
    AVG(length) OVER (PARTITION BY operator) AS avg_length,
    AVG(width) OVER (PARTITION BY operator) AS avg_width,
    AVG(height) OVER (PARTITION BY operator) AS avg_height,

    -- deviations
    length - AVG(length) OVER (PARTITION BY operator) AS length_dev,
    width - AVG(width) OVER (PARTITION BY operator) AS width_dev,
    height - AVG(height) OVER (PARTITION BY operator) AS height_dev

FROM manufacturing_parts1;

--5. Identify outliers using Z-Score

SELECT
    item_no,
    operator,
    height,
    AVG(height * 1.0) OVER (PARTITION BY operator) AS avg_height,
    STDEV(height * 1.0) OVER (PARTITION BY operator) AS stddev_height,
    ROUND(
        (height - AVG(height * 1.0) OVER (PARTITION BY operator)) /
        NULLIF(STDEV(height * 1.0) OVER (PARTITION BY operator), 0),
        2
    ) AS z_score,
    CASE
        WHEN ABS(
            (height - AVG(height * 1.0) OVER (PARTITION BY operator)) /
            NULLIF(STDEV(height * 1.0) OVER (PARTITION BY operator), 0)
        ) > 2 THEN 'Outlier'
        ELSE 'Normal'
    END AS outlier_flag
FROM manufacturing_parts1
ORDER BY operator, item_no;

--6. Rolling average of length (last 3 items)

SELECT
    item_no,
    operator,
    length,
    AVG(length * 1.0) OVER (
        PARTITION BY operator
        ORDER BY item_no
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_avg_length
FROM manufacturing_parts1
ORDER BY operator, item_no;

--7. Percentage contribution of each operator to total volume

SELECT
    operator,
    SUM(length * width * height) AS total_volume,
    ROUND(
        SUM(length * width * height) * 100.0 /
        (SELECT SUM(length * width * height) FROM manufacturing_parts1),
        2
    ) AS percentage_contribution
FROM manufacturing_parts1
GROUP BY operator
ORDER BY percentage_contribution DESC;

--8. Count of items by size category

SELECT
    CASE
        WHEN (length * width * height) < 90000 THEN 'Small'
        WHEN (length * width * height) BETWEEN 90000 AND 110000 THEN 'Medium'
        ELSE 'Large'
    END AS size_category,
    COUNT(*) AS item_count
FROM manufacturing_parts1
GROUP BY
    CASE
        WHEN (length * width * height) < 90000 THEN 'Small'
        WHEN (length * width * height) BETWEEN 90000 AND 110000 THEN 'Medium'
        ELSE 'Large'
    END;

--9.

WITH process_data AS (
    SELECT
        item_no,
        operator,
        height,
        ROW_NUMBER() OVER (
            PARTITION BY operator
            ORDER BY item_no
        ) AS row_number,
        AVG(height * 1.0) OVER (
            PARTITION BY operator
            ORDER BY item_no
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        ) AS avg_height,
        STDEV(height * 1.0) OVER (
            PARTITION BY operator
            ORDER BY item_no
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        ) AS stddev_height
    FROM manufacturing_parts1
),
control_limits AS (
    SELECT
        item_no,
        operator,
        row_number,
        height,
        avg_height,
        stddev_height,
        avg_height + 3 * (stddev_height / SQRT(5.0)) AS ucl,
        avg_height - 3 * (stddev_height / SQRT(5.0)) AS lcl
    FROM process_data
    WHERE row_number >= 5
)
SELECT
    operator,
    row_number,
    height,
    avg_height,
    stddev_height,
    ucl,
    lcl,
    CAST(CASE
        WHEN height BETWEEN lcl AND ucl THEN 1
        ELSE 0
    END AS bit) AS alert
FROM control_limits
ORDER BY item_no;