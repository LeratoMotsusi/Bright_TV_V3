-- Databricks notebook source
SELECT *
FROM bright_tv.data.user_profiles;

SELECT *
FROM bright_tv.data.viewerships;

SELECT *
FROM bright_tv.data.user_profiles;

SELECT *
FROM bright_tv.data.viewerships;




WITH USER_PROFILES_CTE AS (

SELECT
    USERID,

    CASE
        WHEN PROVINCE IN ('', 'None') THEN 'Uncategorized'
        ELSE PROVINCE
    END AS REGION,

    AGE,

    CASE
        WHEN AGE = 0 THEN 'Infants'
        WHEN AGE BETWEEN 1 AND 12 THEN 'Kids'
        WHEN AGE BETWEEN 13 AND 19 THEN 'Teenager'
        WHEN AGE BETWEEN 20 AND 35 THEN 'Youth'
        WHEN AGE BETWEEN 36 AND 50 THEN 'Adult'
        WHEN AGE BETWEEN 51 AND 65 THEN 'Elder'
        WHEN AGE > 65 THEN 'Pensioner'
    END AS AGE_GROUPS,

    CASE
        WHEN EMAIL IS NOT NULL
             AND EMAIL <> ''
             AND EMAIL <> 'None'
        THEN 1
        ELSE 0
    END AS EMAIL_FLAG,

    CASE
        WHEN `Social Media Handle` IS NOT NULL
             AND `Social Media Handle` <> ''
             AND `Social Media Handle` <> 'None'
        THEN 1
        ELSE 0
    END AS SM_FLAG,

    CASE
        WHEN RACE IN ('', 'other') THEN 'None'
        ELSE RACE
    END AS RACE,

    CASE
        WHEN GENDER = '' THEN 'None'
        ELSE GENDER
    END AS GENDER

FROM bright_tv.data.user_profiles

),

VIEWERSHIP_CTE AS (

SELECT

    "UserID" AS USERID,

    TRY_TO_TIMESTAMP(RECORDDATE2,'YYYY/MM/DD HH24:MI') AS WATCH_TS,

    CHANNEL2,
    `Duration 2`

FROM bright_tv.data.viewerships

)

SELECT

    A.USERID AS SUB_ID,

    TO_CHAR(A.WATCH_TS,'YYYYMM') AS MONTH_ID,

    CAST(A.WATCH_TS AS DATE) AS WATCH_DATE,

    DAYOFWEEK(A.WATCH_TS) AS DAY_OF_WEEK,

    DAYNAME(A.WATCH_TS) AS DAY_NAME,

    CASE
        WHEN DAYNAME(A.WATCH_TS) IN ('Sat','Sun')
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS DAY_CLASSIFICATION,

    MONTHNAME(A.WATCH_TS) AS MONTH_NAME,

    CASE
        WHEN A.CHANNEL2 IN ('SawSee','Sawsee')
        THEN 'SawSee'

        WHEN A.CHANNEL2 IN (
            'SuperSport Live Events',
            'Live on SuperSport',
            'Supersport Live Events',
            'DStv Events 1'
        )
        THEN 'Live Events'

        ELSE A.CHANNEL2
    END AS TV_CHANNEL,

    CASE
        WHEN HOUR(A.WATCH_TS) BETWEEN 0 AND 5
        THEN '01. Midnight'

        WHEN HOUR(A.WATCH_TS) BETWEEN 6 AND 11
        THEN '02. Morning'

        WHEN HOUR(A.WATCH_TS) BETWEEN 12 AND 16
        THEN '03. Afternoon'

        ELSE '04. Evening'
    END AS TIME_OF_DAY,

    HOUR(A.WATCH_TS) AS HOUR_OF_DAY,

    TO_CHAR(A.`Duration 2`,'HH24:MI:SS') AS DURATION,
    

    CASE
        WHEN CAST(A.`Duration 2` as TIME) BETWEEN TIME '00:05:00' AND TIME '00:30:00'
        THEN '01. Low Usage: <30 min'

        WHEN CAST(A.`Duration 2` as TIME) '00:30:01' AND TIME '00:59:59'
        THEN '02. Med Usage: <60 min'

        WHEN CAST(A.`Duration 2` as TIME) > TIME '00:59:59'
        THEN '03. High Usage: >60 min'

        ELSE '04. No Usage'
    END AS SCREEN_TIME_BUCKET,

    B.REGION,
    B.AGE_GROUPS,
    B.EMAIL_FLAG,
    B.SM_FLAG,
    B.RACE,
    B.GENDER

FROM VIEWERSHIP_CTE A
LEFT JOIN USER_PROFILES_CTE B
ON A.USERID = B.USERID;







WITH user_profiles AS (
SELECT UserID,
CASE
WHEN Province=' ' THEN 'Uncategorized'
WHEN Province='None' THEN 'Uncategorized'
WHEN Province IS NULL THEN 'Uncategorized'
ELSE Province
END AS Region,
--------------------------------------------------------------------
age,
CASE
WHEN age = 0 THEN 'Infants'
WHEN age BETWEEN 1 AND 12 THEN 'Kids'
WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
WHEN age BETWEEN 20 AND 35 THEN 'Youth'WHEN age BETWEEN 36 AND 50 THEN 'Adult'
WHEN age BETWEEN 51 AND 65 THEN 'Elder'
WHEN age >65 THEN 'Pensioner'
END AS age_groups,
CASE
WHEN Email IS NOT NULL OR Email=' ' OR Email NOT IN ('None')THEN 1
ELSE 0
END AS email_flag,
CASE
WHEN (Social Media Handle IS NOT NULL) OR (Social Media Handle=' ') OR (Social Media Handle NOT IN ('None')) THEN 1 
        ELSE 0 
    END AS sm_flag,
CASE
WHEN Race='other' THEN 'None'
WHEN Race=' ' THEN 'None'
ELSE Race
END AS Race,
CASE
WHEN gender =' ' THEN 'None'
ELSE gender
END AS Gender
FROM bright_tv.bright_tv_schema.user_profile
),
viewership AS (
SELECT
COALESCE(UserID0,userid4) AS userid,
TO_CHAR(RecordDate2, 'yyyyMM') AS month_id,
TO_DATE(RecordDate2) AS watch_date,
--TIME(RecordDate2) AS watch_time,
TO_CHAR(RecordDate2, 'DD') AS day_of_week,
DAYNAME(RecordDate2) AS day_name,
CASE
WHEN day_name IN ('Sat', 'Sun') THEN 'weekend'
ELSE 'weekday'
END AS day_classification,
MONTHNAME(RecordDate2) AS month_name,
CASE
WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport', 'Supersport Live Events',
'DStv Events 1') THEN 'Live Events'
ELSE Channel2
END AS Tv_channel,date_format(RecordDate2, 'HH:mm:ss') AS watch_time,
CASE
WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight'
WHEN watch_time BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning'
WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening'
END AS time_of_day,
DATE_FORMAT(Duration 2, 'HH:mm:ss') AS duration,
CASE
WHEN Duration 2 BETWEEN '00:05:00' AND '00:30:00' THEN '01. Low Usage: <30 min'
WHEN Duration 2 BETWEEN '00:30:01' AND '00:59:59' THEN '02. Med Usage: <60 min'
WHEN Duration 2 > '00:59:59' THEN '03. High Usage: >60 min'
ELSE '04. No Usage'
END AS screen_time_bucket,
HOUR(RecordDate2) AS hour_of_day
FROM bright_tv.bright_tv_schema.viewership
)
SELECT Coalesce(A.userid,B.userid) AS sub_id,
month_id,
watch_date,
day_of_week,
day_name,
day_classification,month_name,
Tv_channel,
time_of_day,
hour_of_day,
screen_time_bucket,
--user_flag,
duration,
Region,
age_groups,
email_flag,
sm_flag,
Race,
Gender
FROM viewership AS A
LEFT JOIN user_profiles AS B
ON A.userid=B.userid;



SELECT
`Social Media Handle`,
CASE
        WHEN `Social Media Handle` IS NOT NULL
             AND `Social Media Handle` <> ''
             AND `Social Media Handle` <> 'None'
        THEN 1
        ELSE 0
    END AS SM_FLAG
    FROM bright_tv.data.user_profiles;





SELECT `Duration 2`












