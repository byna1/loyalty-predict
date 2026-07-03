WITH 

tb_current_life_cycle

AS

(SELECT
    dtRef,
    IdCliente, 
    frequency,
    DescLifeCycle AS descLifeCycleAtual
      
FROM life_cycle
WHERE dtRef = date('{date}','-1 day')),

tb_life_cycle_D28 AS

(SELECT
    dtRef,
    IdCliente, 
    DescLifeCycle AS descLifeCycleAtual_D28
FROM life_cycle
WHERE dtRef = date('{date}','-29 day')),

tb_share_cycles

AS 

(SELECT
       IdCliente,
       1.* SUM(CASE WHEN DescLifeCycle = '05 - CHURN' THEN 1 ELSE 0 END) / count (*) AS 'pct_CHURN',
       1.* SUM(CASE WHEN DescLifeCycle = '04 - DISENGAGED' THEN 1 ELSE 0 END) / count (*) AS 'pct_DISENGAGED',
       1.* SUM(CASE WHEN DescLifeCycle = '03 - TOURIST' THEN 1 ELSE 0 END) / count (*) AS 'pct_TOURIST',
       1.* SUM(CASE WHEN DescLifeCycle = '02 - FAITHFUL' THEN 1 ELSE 0 END) / count (*) AS 'pct_FAITHFUL',
       1.* SUM(CASE WHEN DescLifeCycle = '01 - CURIOUS' THEN 1 ELSE 0 END) / count (*) AS 'pct_CURIOUS',
       1.* SUM(CASE WHEN DescLifeCycle = '02 - REBORN' THEN 1 ELSE 0 END) / count (*) AS 'pct_REBORN',
       1.* SUM(CASE WHEN DescLifeCycle = '02 - RECONQUERED' THEN 1 ELSE 0 END) / count (*) AS 'pct_RECONQUERED'
FROM life_cycle
WHERE dtRef = date('{date}','-1 day')
GROUP BY IdCliente),

tb_avg_cycle

AS

(SELECT 
    descLifeCycleAtual,
    AVG(frequency) AS avg_Group_frequency
FROM tb_current_life_cycle
GROUP BY descLifeCycleAtual),

tb_join

AS

(SELECT t1.*,
       t2.descLifeCycleAtual_D28,
       t3.pct_CHURN,
       t3.pct_DISENGAGED,
       t3.pct_TOURIST,
       t3.pct_FAITHFUL,
       t3.pct_CURIOUS,
       t3.pct_REBORN,
       t3.pct_RECONQUERED,
       t4.avg_Group_frequency,
       1. * t1.frequency / t4.avg_Group_frequency AS ratio_Freq_Group
FROM tb_current_life_cycle AS t1
LEFT JOIN tb_life_cycle_D28 AS t2
ON t1.IdCliente = t2.IdCliente
LEFT JOIN tb_share_cycles AS t3
ON t1.IdCliente = t3.IdCliente
LEFT JOIN tb_avg_cycle AS t4
ON t1.descLifeCycleAtual = t4.descLifeCycleAtual)

SELECT * 
FROM tb_join