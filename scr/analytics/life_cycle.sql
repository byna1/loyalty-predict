-- Curious = age > 7 
-- faithful = rescence < 7 , and latest recente < 15 
-- Turist = rescente < 15 
-- desinchanted = rescence < 28 
-- zumbi = recente >= 28
-- reconquered < 7 AND 14 <= anteriour recence <= 28 
-- reborn< 7 AND 14 <= anteriour recence > 28 

WITH tb_daily 
AS
(SELECT 
    DISTINCT IdCliente,
    substr(DtCriacao,0,11) AS DtDia
FROM transacoes
WHERE DtCriacao < '{date}'
),

tb_age AS

(

SELECT 
    IdCliente,
    CAST(MAX(julianday('{date}') - julianday(DtDia)) AS int) daysSinceFirstTrans,
    CAST(MIN(julianday('{date}') - julianday(DtDia)) AS int) daysSinceLastTrans
FROM tb_daily
GROUP BY IdCliente),

tb_rn AS 

(SELECT *, 
    ROW_NUMBER() OVER (PARTITION BY idCliente ORDER BY dtDia DESC) rn_number
FROM tb_daily),

tb_daybeforelast

AS  

(SELECT
    *,
    CAST((julianday('{date}') - julianday(DtDia)) AS int) AS DaysSinceTheDayBeforeTheLast
FROM tb_rn
WHERE rn_number = 2),

tb_life_cycle

AS

(SELECT t1.*,
    t2.DaysSinceTheDayBeforeTheLast,
    CASE 
    
        WHEN  daysSinceFirstTrans <= 7 THEN '01 - CURIOUS'
        WHEN  daysSinceLastTrans <= 7 AND (DaysSinceTheDayBeforeTheLast - daysSinceLastTrans) <= 14 THEN '02 - FAITHFUL'
        WHEN  daysSinceLastTrans BETWEEN 8 AND 14 THEN '03 - TOURIST'
        WHEN  daysSinceLastTrans BETWEEN 15 AND 27 THEN '04 - DISENGAGED'   
        WHEN  daysSinceLastTrans > 28 THEN '05 - CHURN'   
        WHEN  daysSinceLastTrans <= 7 AND (DaysSinceTheDayBeforeTheLast - daysSinceLastTrans) BETWEEN 15 AND 27 THEN '02 - RECONQUERED'   
        WHEN  daysSinceLastTrans <= 7 AND (DaysSinceTheDayBeforeTheLast - daysSinceLastTrans) >= 28 THEN '02 - REBORN'


    END DescLifeCycle
FROM tb_age t1
LEFT JOIN tb_daybeforelast t2
ON t1.IdCliente = t2.IdCliente),

tb_freq_value

AS

(SELECT
    idCliente,
    count(DISTINCT substr(DtCriacao,0,11)) AS frequency,
    SUM(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS SumOfPointsPos
FROM transacoes
WHERE DtCriacao < '{date}'
AND DtCriacao > date('{date}','-28 day')
GROUP BY  idCliente
ORDER BY frequency DESC),

tb_cluster

AS

(SELECT *,
    CASE

        WHEN frequency <= 10 AND SumOfPointsPos >= 1500 THEN "12 - HYPER"
        WHEN frequency > 10 AND SumOfPointsPos >= 1500 THEN "22 - ENGAGED EFFICIENTLY"
        WHEN frequency <= 10 AND SumOfPointsPos >=750 THEN "11 - INDECISIVE"
        WHEN frequency > 10 AND SumOfPointsPos >=750 THEN "21 - POTENCIALLY ENGAGED"
        WHEN frequency < 5 THEN "00 - LURCKERS"
        WHEN frequency <= 10 THEN "01 - NOT ENGAGED"
        WHEN frequency > 10 THEN "20 - POTENCIAL"


    END AS Cluster



FROM tb_freq_value
) 



SELECT
    date('{date}', '-1 day') AS dtRef,
    t1.*,
    t2.frequency,
    t2.SumOfPointsPos,
    t2.Cluster
FROM tb_life_cycle AS t1
LEFT JOIN tb_cluster AS t2
ON t1.IdCliente = t2.idCliente