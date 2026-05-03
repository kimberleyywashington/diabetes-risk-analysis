--Analysis 1: Diabetes prevalence by age group                 
--Kimberley Washington
--04/23/2026
                                                                       
--Question: Which age groups have the highest percentage of diabetes?                 

--Note: CAST was used to convert the values to numeric data types because the imported CSV columns in 
--SQLiteStudio had no assigned data types, so this ensures the comparisons and calculations work correctly.

--using CTE 
WITH age_groups AS (
    SELECT 
        age,
        diabetes,
    --Create age groups based on age range
        CASE 
            WHEN CAST(age AS REAL) BETWEEN 0  AND 17 THEN '0-17'
            WHEN CAST(age AS REAL) BETWEEN 18 AND 29 THEN '18-29'
            WHEN CAST(age AS REAL) BETWEEN 30 AND 44 THEN '30-44'
            WHEN CAST(age AS REAL) BETWEEN 45 AND 59 THEN '45-59'
            ELSE '60+'
        END AS age_group
    FROM diabetes_prediction
)
--to group by age_group
SELECT 
    age_group,
    COUNT(*) AS total_patients, 
    --SUM()is used because according to the dataset, diabetes = 1 means diabetic and diabetes = 0 means non-diabetic
    SUM(CAST(diabetes AS INTEGER)) AS diabetic_patients, 
    --calculate the diabetes percentage for each age group  
    ROUND(SUM(CAST(diabetes AS INTEGER)) * 100.0/COUNT(*),2) AS diabetes_rate_percent   
FROM age_groups
GROUP BY age_group
ORDER BY diabetes_rate_percent DESC;

--Analysis 2: Compare average BMI, HbA1c, and glucose level by diabetes status
--Kimberley Washington
--04/27/2026

--Question: How do average BMI, HbA1c, and blood glucose levels differ between diabetic and non-diabetic patients?

--Note(Ideas I come up with to understand the question better):
--We have to first find the average bmi, hba1c, and blood glucose for diabetic and non-diabetic patients, then compare which group 
--has the highest level.

--To find the average bmi,HbA1c level, and blood glucose level for diabetic and non-diabetic patients 
SELECT 
    CASE 
        WHEN CAST(diabetes AS INTEGER) = 1 THEN 'Diabetic'
        ELSE 'Non-Diabetic'
    END AS diabetes_status,
    
    ROUND(AVG(bmi),2) AS avg_bmi,
    ROUND(AVG(HbA1c_level),2) AS avg_hba1c_level,
    ROUND(AVG(blood_glucose_level),2)AS avg_blood_glucose_level
FROM diabetes_prediction
GROUP BY diabetes;

--Part 2 Analysis 2(Insight): Compare each clinical metric based on the average values

--Based on the average values for each clinical metric: 
--The average BMI for diabetic patients is higher than the average BMI for non-diabetic patients.
--The average HbA1c level for diabetic patients is higher than the average HbA1c level for non-diabetic patients.
--The average blood glucose level for diabetic patients is higher than the average blood glucose level for non-diabetic patients.

--This comparison shows that diabetic patients have higher average BMI, HbA1c, and blood glucose levels than non-diabetic patients.

--Analysis 3: Comorbidity Analysis: Compare hypertension and heart disease prevalence with diabetes
--Kimberley Washington
--04/28/2026

--Question: Are patients with hypertension or heart disease more likely to have diabetes?

SELECT
    CASE
        WHEN CAST(hypertension AS INTEGER) = 1 THEN 'Has Hypertension'
        ELSE 'No Hypertension'
    END AS hypertension_status,

    CASE
        WHEN CAST(heart_disease AS INTEGER) = 1 THEN 'Has Heart Disease'
        ELSE 'No Heart Disease'
    END AS heart_disease_status,

    COUNT(*) AS total_patients,

    SUM(CAST(diabetes AS INTEGER)) AS diabetic_patients,
    
    ROUND(SUM(CAST(diabetes AS INTEGER)) * 100.0 / COUNT(*), 2) AS diabetes_prevalence_percent

FROM diabetes_prediction

GROUP BY hypertension_status, heart_disease_status

ORDER BY diabetes_prevalence_percent DESC;

--Insight:

--Based on the analysis, patients with both hypertension and heart disease had the highest diabetes prevalence rate at 39.08%.
--Patients with only heart disease had a diabetes prevalence of 30.04%, while patients with only hypertension had a prevalence of 26.34%.
--Patients with neither condition had the lowest prevalence at 6.15%. Therefore, we can conclude that  hypertension and heart disease are 
--strongly associated with an increased diabetes risk.

--Analysis 4: Diabetes Prevalence by smoking history - smoking history risk analysis
--Kimberley Washington
--04/29/2026


--Question: Do patients with a smoking history have a higher diabetes prevalence than those with no smoking history?

--Note:
--What I understand we will be analyzing is, finding the total number of patients who have a smoking history and then finding out if they have diabetes or not. 
--I will be grouping smoking history into 3 groups: Has smoked, No History, and No Info based on the answers from patients.

--This analysis compares the percentage of diabetic patients in each smoking group to determine whether smoking 
--history is associated with higher diabetes prevalence. 

SELECT 
    CASE 
        WHEN smoking_history IN ('ever', 'former', 'not current', 'current') THEN 'Has Smoked'
        WHEN smoking_history IN ('never') THEN 'No History'
        ELSE 'No Info'
    END AS smoking_group,
    
    COUNT(*) AS total_patients,
    SUM(CAST(diabetes AS INTEGER)) AS diabetic_patients,
    ROUND(SUM(CAST(diabetes AS INTEGER))*100.0/COUNT(*),2) AS diabetes_prevalence_percent

FROM diabetes_prediction
GROUP BY smoking_group
ORDER BY diabetes_prevalence_percent DESC;

--Insight:
--Patients with a smoking history have a higher prevalence than patients with no smoking history.
--This suggests that smoking history may be associated with increased diabetes risk.

--Dashboard
--Patients with a smoking history showed higher diabetes prevalence (12.72%) than patients with no smoking 
--history (9.53%), suggesting that smoking history may be associated with increased diabetes risk.

--Analysis 5: Gender and Age-Based Diabetes Risk
--Kimberley Washington
--04/29/2026

--Question: How does diabetes prevalence differ between males and females across age groups?

--using CTE 
WITH age_groups AS (
    SELECT 
        gender,
        age,
        diabetes,
    --Create age groups based on age range
        CASE 
            WHEN CAST(age AS REAL) BETWEEN 0  AND 17 THEN '0-17'
            WHEN CAST(age AS REAL) BETWEEN 18 AND 29 THEN '18-29'
            WHEN CAST(age AS REAL) BETWEEN 30 AND 44 THEN '30-44'
            WHEN CAST(age AS REAL) BETWEEN 45 AND 59 THEN '45-59'
            ELSE '60+'
        END AS age_group
    FROM diabetes_prediction
)
--to group by gender and age_group 
SELECT 
    gender,
    age_group,
    COUNT(*) AS total_patients, 
    --SUM()is used because according to the dataset, diabetes = 1 means diabetic and diabetes = 0 means non-diabetic
    SUM(CAST(diabetes AS INTEGER)) AS diabetic_patients, 
    --calculate the diabetes percentage for each age group  
    ROUND(SUM(CAST(diabetes AS INTEGER)) * 100.0/COUNT(*),2) AS diabetes_prevalence_percent   
FROM age_groups
GROUP BY gender, age_group
ORDER BY diabetes_prevalence_percent DESC;

--Insight:
--Diabetes prevalence increased with age for both males and females.
--Male patients had higher diabetes prevalence than female patients across all age groups, with the highest
--prevalence observed among males aged 60+ (22.22%).
