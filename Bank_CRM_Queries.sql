CREATE DATABASE BankCRM;

DESCRIBE customerinfo;

USE BankCRM;

------   Objective Question 2: Top 5 customers with highest Estimated Salary in the last quarter.
SELECT * 
FROM 
    CustomerInfo 
WHERE 
    QUARTER(STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y')) = 4
ORDER BY 
    EstimatedSalary DESC
LIMIT 5;

--         Objective Question 3: Calculate the average number of products used by customers who have a credit card.
SELECT 
    AVG(NumOfProducts) AS AverageProducts
FROM 
    Bank_Churn
WHERE 
    HasCrCard = 1;
    
--       Objective Question 5: Compare the average credit score of customers who have exited and those who remain.
SELECT 
    CASE 
        WHEN Exited = 1 THEN 'Exited'
        WHEN Exited = 0 THEN 'Remained'
    END AS CustomerStatus,
    AVG(CreditScore) AS AverageCreditScore
FROM 
    Bank_Churn
GROUP BY 
    Exited;
    
--       Objective Question 6: Average estimated salary by gender and relation to active accounts.
SELECT 
    CASE 
        WHEN ci.GenderID = 1 THEN 'Male'
        WHEN ci.GenderID = 2 THEN 'Female'
    END AS GenderCategory,
    ROUND(AVG(ci.EstimatedSalary), 2) AS AverageSalary,
    SUM(bc.IsActiveMember) AS TotalActiveAccounts
FROM 
    CustomerInfo ci
JOIN 
    Bank_Churn bc ON ci.`ï»¿CustomerId` = bc.`ï»¿CustomerId`
GROUP BY 
    ci.GenderID
ORDER BY 
    AverageSalary DESC;

-- Objective Question 7: Segment customers based on credit score and identify highest exit rate.
SELECT 
    CASE 
        WHEN CreditScore BETWEEN 800 AND 850 THEN '1. Excellent (800-850)'
        WHEN CreditScore BETWEEN 740 AND 799 THEN '2. Very Good (740-799)'
        WHEN CreditScore BETWEEN 670 AND 739 THEN '3. Good (670-739)'
        WHEN CreditScore BETWEEN 580 AND 669 THEN '4. Fair (580-669)'
        WHEN CreditScore BETWEEN 300 AND 579 THEN '5. Poor (300-579)'
        ELSE 'Other'
    END AS CreditScoreSegment,
    COUNT(*) AS TotalCustomers,
    SUM(Exited) AS ExitedCustomers,
    ROUND((SUM(Exited) / COUNT(*)) * 100, 2) AS ExitRatePercentage
FROM 
    Bank_Churn
GROUP BY 
    CreditScoreSegment
ORDER BY 
    ExitRatePercentage DESC;
    
--          Objective Question 8: Geographic region with highest active customers (tenure > 5 years)
SELECT 
    g.GeographyLocation, 
    COUNT(*) AS ActiveLongTermCustomers
FROM 
    CustomerInfo ci
JOIN 
    Bank_Churn bc ON ci.`ï»¿CustomerId` = bc.`ï»¿CustomerId`
JOIN 
    Geography g ON ci.GeographyID = g.`ï»¿GeographyID`
WHERE 
    bc.IsActiveMember = 1 
    AND bc.Tenure > 5
GROUP BY 
    g.GeographyLocation
ORDER BY 
    ActiveLongTermCustomers DESC;
    
--         Objective Question 9: Impact of credit card on customer churn.
SELECT 
    CASE 
        WHEN HasCrCard = 1 THEN 'Has Credit Card'
        WHEN HasCrCard = 0 THEN 'No Credit Card'
    END AS CreditCardStatus,
    COUNT(*) AS TotalCustomers,
    SUM(Exited) AS ExitedCustomers,
    ROUND((SUM(Exited) / COUNT(*)) * 100, 2) AS ChurnRatePercentage
FROM 
    Bank_Churn
GROUP BY 
    HasCrCard;
    
--         Objective Question 10: Most common number of products used by exited customers.
SELECT 
    NumOfProducts,
    COUNT(*) AS ExitedCustomersCount
FROM 
    Bank_Churn
WHERE 
    Exited = 1
GROUP BY 
    NumOfProducts
ORDER BY 
    ExitedCustomersCount DESC;
    
-- Objective Question 11: Trend of customers joining over time (Yearly & Monthly)
SELECT 
    YEAR(STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y')) AS JoinYear,
    MONTHNAME(STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y')) AS JoinMonth,
    COUNT(*) AS TotalCustomersJoined
FROM 
    CustomerInfo
GROUP BY 
    JoinYear, 
    JoinMonth, 
    MONTH(STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y'))
ORDER BY 
    JoinYear ASC, 
    MONTH(STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y')) ASC;
    
-- Objective Question 12: Relationship between number of products and account balance for exited customers.
SELECT 
    NumOfProducts,
    COUNT(*) AS TotalExitedCustomers,
    ROUND(AVG(Balance), 2) AS AverageBalance
FROM 
    Bank_Churn
WHERE 
    Exited = 1
GROUP BY 
    NumOfProducts
ORDER BY 
    NumOfProducts ASC;
    
-- Objective Question 13: Identify potential outliers in balance for retained customers.
SELECT 
    CreditScore,
    Balance,
    NumOfProducts
FROM 
    Bank_Churn
WHERE 
    Exited = 0 
    AND Balance > (
        SELECT AVG(Balance) + (3 * STDDEV(Balance)) 
        FROM Bank_Churn 
        WHERE Exited = 0
    )
ORDER BY 
    Balance DESC;
    
-- Objective Question 14 (Part 1): Total tables in dataset
SHOW TABLES;

-- Objective Question 15: Gender-wise average income in each GeographyID with Rank.
SELECT 
    GeographyID,
    CASE 
        WHEN GenderID = 1 THEN 'Male'
        WHEN GenderID = 2 THEN 'Female'
    END AS GenderCategory,
    ROUND(AVG(EstimatedSalary), 2) AS AverageIncome,
    RANK() OVER(
        PARTITION BY GeographyID 
        ORDER BY AVG(EstimatedSalary) DESC
    ) AS IncomeRank
FROM 
    CustomerInfo
GROUP BY 
    GeographyID, 
    GenderID
ORDER BY 
    GeographyID ASC, 
    IncomeRank ASC;
    
-- Objective Question 16: Average tenure of exited customers by age bracket.
SELECT 
    CASE 
        WHEN ci.Age BETWEEN 18 AND 30 THEN '1. 18-30'
        WHEN ci.Age BETWEEN 31 AND 50 THEN '2. 30-50'
        WHEN ci.Age > 50 THEN '3. 50+'
    END AS AgeBracket,
    COUNT(*) AS ExitedCustomersCount,
    ROUND(AVG(bc.Tenure), 2) AS AverageTenure
FROM 
    CustomerInfo ci
JOIN 
    Bank_Churn bc ON ci.`ï»¿CustomerId` = bc.`ï»¿CustomerId`
WHERE 
    bc.Exited = 1
GROUP BY 
    AgeBracket
ORDER BY 
    AgeBracket ASC;
    
-- Objective Question 17: Correlation between Salary and Balance (Split by Exit Status)
SELECT 
    CASE 
        WHEN bc.Exited = 1 THEN 'Exited'
        WHEN bc.Exited = 0 THEN 'Retained'
    END AS CustomerStatus,
    
    -- Ye Pearson Correlation ka SQL mathematics hai (N*Sum(XY) - Sum(X)*Sum(Y)) / ...
    ROUND(
        (COUNT(*) * SUM(ci.EstimatedSalary * bc.Balance) - SUM(ci.EstimatedSalary) * SUM(bc.Balance)) 
        / 
        (SQRT(COUNT(*) * SUM(ci.EstimatedSalary * ci.EstimatedSalary) - SUM(ci.EstimatedSalary) * SUM(ci.EstimatedSalary)) 
        * SQRT(COUNT(*) * SUM(bc.Balance * bc.Balance) - SUM(bc.Balance) * SUM(bc.Balance)))
    , 4) AS Correlation_Coefficient
FROM 
    CustomerInfo ci
JOIN 
    Bank_Churn bc ON ci.`ï»¿CustomerId` = bc.`ï»¿CustomerId`
GROUP BY 
    bc.Exited;
    
-- Objective Question 18: Correlation between Salary and Credit Score
SELECT 
    ROUND(
        (COUNT(*) * SUM(ci.EstimatedSalary * bc.CreditScore) - SUM(ci.EstimatedSalary) * SUM(bc.CreditScore)) 
        / 
        (SQRT(COUNT(*) * SUM(ci.EstimatedSalary * ci.EstimatedSalary) - SUM(ci.EstimatedSalary) * SUM(ci.EstimatedSalary)) 
        * SQRT(COUNT(*) * SUM(bc.CreditScore * bc.CreditScore) - SUM(bc.CreditScore) * SUM(bc.CreditScore)))
    , 4) AS Correlation_Salary_CreditScore
FROM 
    CustomerInfo ci
JOIN 
    Bank_Churn bc ON ci.`ï»¿CustomerId` = bc.`ï»¿CustomerId`;
    
-- Objective Question 19: Rank credit score buckets by number of churned customers.
SELECT 
    CASE 
        WHEN CreditScore BETWEEN 800 AND 850 THEN '1. Excellent (800-850)'
        WHEN CreditScore BETWEEN 740 AND 799 THEN '2. Very Good (740-799)'
        WHEN CreditScore BETWEEN 670 AND 739 THEN '3. Good (670-739)'
        WHEN CreditScore BETWEEN 580 AND 669 THEN '4. Fair (580-669)'
        WHEN CreditScore BETWEEN 300 AND 579 THEN '5. Poor (300-579)'
        ELSE 'Other'
    END AS CreditScoreBucket,
    COUNT(*) AS ChurnedCustomersCount,
    RANK() OVER(
        ORDER BY COUNT(*) DESC
    ) AS ChurnRank
FROM 
    Bank_Churn
WHERE 
    Exited = 1
GROUP BY 
    CreditScoreBucket
ORDER BY 
    ChurnRank ASC;
    
-- Objective Question 20: Age buckets with credit cards lesser than the average.
WITH AgeBucketData AS (
    SELECT 
        CASE 
            WHEN ci.Age BETWEEN 18 AND 30 THEN '1. 18-30'
            WHEN ci.Age BETWEEN 31 AND 50 THEN '2. 31-50'
            WHEN ci.Age > 50 THEN '3. 50+'
        END AS AgeBucket,
        COUNT(*) AS TotalCreditCards
    FROM 
        CustomerInfo ci
    JOIN 
        Bank_Churn bc ON ci.`ï»¿CustomerId` = bc.`ï»¿CustomerId`
    WHERE 
        bc.HasCrCard = 1
    GROUP BY 
        AgeBucket
)
SELECT 
    AgeBucket,
    TotalCreditCards
FROM 
    AgeBucketData
WHERE 
    TotalCreditCards < (SELECT AVG(TotalCreditCards) FROM AgeBucketData)
ORDER BY 
    AgeBucket ASC;
    
-- Objective Question 21: Rank locations by churned customers and average balance.
SELECT 
    g.GeographyLocation,
    COUNT(bc.`ï»¿CustomerId`) AS ChurnedCustomersCount,
    ROUND(AVG(bc.Balance), 2) AS AverageBalance,
    RANK() OVER(
        ORDER BY COUNT(bc.`ï»¿CustomerId`) DESC, AVG(bc.Balance) DESC
    ) AS LocationRank
FROM 
    CustomerInfo ci
JOIN 
    Bank_Churn bc ON ci.`ï»¿CustomerId` = bc.`ï»¿CustomerId`
JOIN 
    Geography g ON ci.GeographyID = g.`ï»¿GeographyID`
WHERE 
    bc.Exited = 1
GROUP BY 
    g.GeographyLocation
ORDER BY 
    LocationRank ASC;
    
-- Objective Question 22: Create a combined column with format "CustomerID_Surname"
SELECT 
    `ï»¿CustomerId` AS CustomerID,
    Surname,
    CONCAT(`ï»¿CustomerId`, '_', Surname) AS CustomerID_Surname
FROM 
    CustomerInfo;
   
   DESCRIBE exitcustomer;
   
-- Objective Question 23: Get ExitCategory from exitcastomer table without JOIN
SELECT 
    `ï»¿CustomerId`,
    Exited,
    CASE 
        WHEN Exited = 1 THEN 'Exit'
        WHEN Exited = 0 THEN 'Retain'
    END AS ExitCategory
FROM 
    Bank_Churn;
    
-- Objective Question 25: Customers whose surname ends with "on" and their active status
SELECT 
    ci.`ï»¿CustomerId` AS CustomerID,
    ci.Surname,
    CASE 
        WHEN bc.IsActiveMember = 1 THEN 'Active'
        WHEN bc.IsActiveMember = 0 THEN 'Inactive'
    END AS ActiveStatus
FROM 
    CustomerInfo ci
JOIN 
    Bank_Churn bc ON ci.`ï»¿CustomerId` = bc.`ï»¿CustomerId`
WHERE 
    ci.Surname LIKE '%on';
    
-- Objective Question 26: Data discrepancy check (Active Members who have already Exited)

SELECT 
    `ï»¿CustomerId`,
    IsActiveMember,
    Exited,
    'Data Discrepancy!' AS Observation
FROM 
    Bank_Churn
WHERE 
    IsActiveMember = 1 
    AND Exited = 1;
    
--                                                                SUBJECTIVE QUESTIONS

--        Subjective Question 1: Spending habits & loyalty of New vs Long-term customers
SELECT 
    CASE 
        WHEN Tenure BETWEEN 0 AND 3 THEN '1. New (0-3 Years)'
        WHEN Tenure BETWEEN 4 AND 7 THEN '2. Mid-Term (4-7 Years)'
        WHEN Tenure >= 8 THEN '3. Long-Term (8-10 Years)'
    END AS CustomerTenure,
    COUNT(*) AS TotalCustomers,
    ROUND(AVG(Balance), 2) AS AverageBalance,
    ROUND(AVG(NumOfProducts), 2) AS AvgProducts,
    ROUND((SUM(IsActiveMember) / COUNT(*)) * 100, 2) AS ActivePercentage
FROM 
    Bank_Churn
GROUP BY 
    CustomerTenure
ORDER BY 
    CustomerTenure;
    
--         Subjective Question 2: Product Affinity (Number of Products & Credit Card)
SELECT 
    NumOfProducts,
    CASE 
        WHEN HasCrCard = 1 THEN 'Yes'
        WHEN HasCrCard = 0 THEN 'No'
    END AS HasCreditCard,
    COUNT(*) AS TotalCustomers
FROM 
    Bank_Churn
GROUP BY 
    NumOfProducts, 
    HasCrCard
ORDER BY 
    TotalCustomers DESC;
    
--        Subjective Question 3: Geographic correlation with economic indicators and churn
SELECT 
    g.GeographyLocation,
    ROUND(AVG(ci.EstimatedSalary), 2) AS AvgSalary,
    ROUND(AVG(bc.Balance), 2) AS AvgBalance,
    ROUND((SUM(bc.IsActiveMember) / COUNT(*)) * 100, 2) AS ActiveAccountsPercentage,
    ROUND((SUM(bc.Exited) / COUNT(*)) * 100, 2) AS ChurnRatePercentage
FROM 
    CustomerInfo ci
JOIN 
    Bank_Churn bc ON ci.`ï»¿CustomerId` = bc.`ï»¿CustomerId`
JOIN 
    Geography g ON ci.GeographyID = g.`ï»¿GeographyID`
GROUP BY 
    g.GeographyLocation
ORDER BY 
    ChurnRatePercentage DESC;
    
--     Subjective Question 4: Demographic segments posing the highest financial risk
SELECT 
    CASE 
        WHEN ci.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN ci.Age BETWEEN 31 AND 50 THEN '31-50'
        WHEN ci.Age > 50 THEN '50+'
    END AS AgeGroup,
    g.GeographyLocation,
    ROUND(AVG(bc.CreditScore), 2) AS AvgCreditScore,
    ROUND((SUM(bc.Exited) / COUNT(*)) * 100, 2) AS ChurnRatePercentage,
    ROUND(AVG(bc.Balance), 2) AS AvgBalance
FROM 
    CustomerInfo ci
JOIN 
    Bank_Churn bc ON ci.`ï»¿CustomerId` = bc.`ï»¿CustomerId`
JOIN 
    Geography g ON ci.GeographyID = g.`ï»¿GeographyID`
GROUP BY 
    AgeGroup, 
    g.GeographyLocation
ORDER BY 
    ChurnRatePercentage DESC;
    
--       Subjective Question 7: Characteristics of Exited vs Retained Customers
SELECT 
    CASE 
        WHEN bc.Exited = 1 THEN 'Exited (Left Bank)'
        WHEN bc.Exited = 0 THEN 'Retained (Stayed)'
    END AS CustomerStatus,
    COUNT(*) AS TotalCustomers,
    ROUND(AVG(ci.Age), 0) AS AvgAge,
    ROUND(AVG(bc.Balance), 2) AS AvgBalance,
    ROUND(AVG(bc.CreditScore), 0) AS AvgCreditScore,
    ROUND((SUM(bc.IsActiveMember) / COUNT(*)) * 100, 2) AS ActivePercentage
FROM 
    Bank_Churn bc
JOIN 
    CustomerInfo ci ON bc.`ï»¿CustomerId` = ci.`ï»¿CustomerId`
GROUP BY 
    bc.Exited;
    
-- Subjective Question 8: Importance of specific features for predicting churn (Corrected)
SELECT 
    CASE 
        WHEN bc.Exited = 1 THEN 'Left Bank (Churned)'
        WHEN bc.Exited = 0 THEN 'Stayed (Retained)'
    END AS CustomerStatus,
    COUNT(*) AS CustomerCount,
    ROUND(AVG(bc.Tenure), 2) AS AvgTenure,
    ROUND(AVG(bc.NumOfProducts), 2) AS AvgProducts,
    ROUND((SUM(bc.IsActiveMember) / COUNT(*)) * 100, 2) AS ActivePercentage,
    ROUND(AVG(ci.EstimatedSalary), 2) AS AvgSalary
FROM 
    Bank_Churn bc
JOIN 
    CustomerInfo ci ON bc.`ï»¿CustomerId` = ci.`ï»¿CustomerId`
GROUP BY 
    bc.Exited;
    
--       Subjective Question 9: Customer Segmentation based on Age and Balance
SELECT 
    CASE 
        WHEN ci.Age BETWEEN 18 AND 30 THEN 'Young Adult (18-30)'
        WHEN ci.Age BETWEEN 31 AND 50 THEN 'Adult (31-50)'
        WHEN ci.Age > 50 THEN 'Senior (50+)'
    END AS AgeSegment,
    CASE 
        WHEN bc.Balance = 0 THEN 'Zero Balance'
        WHEN bc.Balance > 0 AND bc.Balance <= 100000 THEN 'Low-Medium Balance'
        WHEN bc.Balance > 100000 THEN 'High Balance'
    END AS BalanceSegment,
    COUNT(*) AS CustomerCount,
    ROUND((SUM(bc.Exited) / COUNT(*)) * 100, 2) AS ChurnRatePercentage
FROM 
    CustomerInfo ci
JOIN 
    Bank_Churn bc ON ci.`ï»¿CustomerId` = bc.`ï»¿CustomerId`
GROUP BY 
    AgeSegment, 
    BalanceSegment
ORDER BY 
    AgeSegment, 
    BalanceSegment;
    
-- Subjective Question 11 (Part A): Overall Churn Rate of the Bank

SELECT 
    COUNT(*) AS TotalCustomers,
    SUM(Exited) AS TotalChurnedCustomers,
    ROUND((SUM(Exited) / COUNT(*)) * 100, 2) AS OverallChurnRatePercentage
FROM 
    Bank_Churn;

--     Subjective Question 11 (Part B): Churn Rate Per Year (Based on Tenure)
SELECT 
    Tenure AS YearsWithBank,
    COUNT(*) AS TotalCustomers,
    ROUND((SUM(Exited) / COUNT(*)) * 100, 2) AS ChurnRatePercentage
FROM 
    Bank_Churn
GROUP BY 
    Tenure
ORDER BY 
    Tenure ASC;
    
--     Subjective Question 14: Rename column HasCrCard to Has_creditcard

ALTER TABLE Bank_Churn 
RENAME COLUMN HasCrCard TO Has_creditcard;
