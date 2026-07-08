CREATE TABLE tb_faithful

AS 

WITH tb_join

AS

(SELECT 
t1.dtRef,
t1.IdCliente,
t1.descLifeCycle,
t2.descLifeCycle,
(CASE WHEN t2.descLifeCycle = '02 - FAITHFUL' THEN 1 ELSE 0 END) AS fl_faithful,
ROW_NUMBER() OVER (PARTITION BY t1.IdCliente ORDER BY RANDOM()) AS random_coln
FROM life_cycle AS t1
LEFT JOIN life_cycle AS t2
ON t1.IdCliente = t2.IdCliente
AND DATE(t1.dtRef, "+28 day") = DATE(t2.dtRef)
WHERE (t1.dtRef >= '2025-03-01' AND t1.dtRef <= '2026-05-01') OR (t1.dtRef = '2026-06-01')
AND t1.descLifeCycle <> '05 - CHURN'),

tb_cohort

AS

(
SELECT 
dtRef,
IdCliente,
fl_faithful
FROM tb_join 
WHERE random_coln <=2
ORDER BY IdCliente,dtRef)

SELECT
	t1.dtRef,
	t1.IdCliente,
	t1.fl_faithful,
	t2.pct_completion ,
	t2.TotalOfCompletedCourses,
	t2.TotalOfIncompletedCourses,
	t2.SlugCourse,
	t2.github2025 ,
	t2.python2025 ,
	t2.github2024 ,
	t2.pandas2024 ,
	t2.coletaDados2024,
	t2.ml2024 ,
	t2.python2024 ,
	t2.estatistica2024 ,
	t2.dsDatabricks2024,
	t2.mlflow2025 ,
	t2.lagoMago2024,
	t2.sql2020 ,
	t2.dsPontos2024,
	t2.iaCanal2025,
	t2.pandas2025 ,
	t2.tseAnalytics2024,
	t2.estatistica2025 ,
	t2.machineLearning2025,
	t2.tramparLakehouse2024,
	t2.streamlit2025 ,
	t2.sql2025 ,
	t2.carreira ,
	t2.loyaltyPredict2025,
	t2.speedF1,
	t2.matchmakingTramparDeCasa2024,
	t2.nekt2025 ,
	t2.go2026 ,
	t2.f1Lake,
	t2.plataformaMl2026,
	t2.ragia ,
	t2.qtd_days_last_activity,
	t3.AgeInBase,
	t3.LIFE,
	t3.ActFrequencyD7,
	t3.ActFrequencyD14,
	t3.ActFrequencyD28,
	t3.ActFrequencyD56,
	t3.QtdTransaction_LIFE,
	t3.QtdTransactions_D7,
	t3.QtdTransactions_D14,
	t3.QtdTransactions_D28,
	t3.QtdTransactions_D56,
	t3.REVENUE_POINTS_LIFE,
	t3.SUM_OF_POINTS_D7,
	t3.SUM_OF_POINTS_D14,
	t3.SUM_OF_POINTS_D28,
	t3.SUM_OF_POINTS_D56,
	t3.TOTAL_GAINED_POINTS_LIFE,
	t3.GAINED_POINTS_D7,
	t3.GAINED_POINTS_D14,
	t3.GAINED_POINTS_D28,
	t3.GAINED_POINTS_D56,
	t3.TOTAL_EXPEND_POINTS_LIFE,
	t3.SPEND_POINTS_D7,
	t3.SPEND_POINTS_D14,
	t3.SPEND_POINTS_D28,
	t3.SPEND_POINTS_D56,
	t3.QtTransaction_Morning,
	t3.Qtransaction_Afternoon,
	t3.QtTransaction_Night,
	t3.pctTransaction_Morning,
	t3.pctTransaction_Afternoon,
	t3.pcTransaction_Night,
	t3.QtdTransaction_LIFE/LIFE,
	t3.transactions_day7,
	t3.transactions_day14,
	t3.transactions_day28,
	t3.transactions_day56,
	t3.PCT_ATSIVATION_MAU,
	t3.qtd_hours_life,
	t3.Total_hours_D7,
	t3.Total_hours_D14,
	t3.Total_hours_D28,
	t3.Total_hours_D56,
	t3.dif_day,
	t3.dif_day_D28,
	t3.qtdeChatMessage,
	t3.qtdeAirflowLover,
	t3.qtdeRLover,
	t3.qtdeResgatarPonei,
	t3.qtdeListadePresenca,
	t3.qtdePresenÃ§aStreak AS presence_Strike,
	t3.qtdeTrocadePontoStreamElements,
	t3.qtdeReembolsoTrocadePontosStreamElements,
	t3.qtderpg,
	t3.qtdechurn,
	t4.frequency,
	t4.descLifeCycleAtual,
	t4.descLifeCycleAtual_D28,
	t4.pct_CHURN,
	t4.pct_DISENGAGED,
	t4.pct_TOURIST,
	t4.pct_FAITHFUL,
	t4.pct_CURIOUS,
	t4.pct_REBORN,
	t4.pct_RECONQUERED,
	t4.avg_Group_frequency,
	t4.ratio_Freq_Group
FROM tb_cohort AS t1
LEFT JOIN fs_education AS t2
ON t1.IdCliente = t2.IdCliente
AND t1.dtRef = t2.dtRef
LEFT JOIN fs_transactions AS t3
ON t1.IdCliente = t3.IdCliente
AND t1.dtRef = t3.dtRef
LEFT JOIN fs_lifecycle AS t4
ON t1.IdCliente = t4.IdCliente
AND t1.dtRef = t4.dtRef