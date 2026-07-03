-- transaction frequency D7, D14, D28, LIFE
WITH 

tb_transactions

AS

(SELECT *,
    substr(DtCriacao,0,11) AS dtDay,
    CAST(substr(DtCriacao,12,2) AS int) AS dtHora    
FROM transacoes
WHERE DtCriacao < '{date}'),

tb_agg_transaction

AS

(SELECT
    IdCliente,

    MAX   (julianday (date('{date}','-1 day')) - julianday(dtCriacao)) AS AgeInBase,
    COUNT (DISTINCT dtDay) AS LIFE,
    COUNT (DISTINCT CASE WHEN dtDay >= date('{date}', '-7 Day')  THEN dtDay END) AS ActFrequencyD7,    
    COUNT (DISTINCT CASE WHEN dtDay >= date('{date}', '-14 Day') THEN dtDay END) AS ActFrequencyD14,
    COUNT (DISTINCT CASE WHEN dtDay >= date('{date}', '-28 Day') THEN dtDay END) AS ActFrequencyD28,
    COUNT (DISTINCT CASE WHEN dtDay >= date('{date}', '-56 Day') THEN dtDay END) AS ActFrequencyD56,
    
    COUNT (DISTINCT IdTransacao) AS QtdTransaction_LIFE,
    COUNT (DISTINCT CASE WHEN dtDay >= date('{date}', '-7 Day')  THEN IdTransacao END) AS QtdTransactions_D7,    
    COUNT (DISTINCT CASE WHEN dtDay >= date('{date}', '-14 Day') THEN IdTransacao END) AS QtdTransactions_D14,
    COUNT (DISTINCT CASE WHEN dtDay >= date('{date}', '-28 Day') THEN IdTransacao END) AS QtdTransactions_D28,
    COUNT (DISTINCT CASE WHEN dtDay >= date('{date}', '-56 Day') THEN IdTransacao END) AS QtdTransactions_D56,
    
    SUM (qtdePontos) AS REVENUE_POINTS_LIFE,
    SUM (DISTINCT CASE WHEN dtDay >= date('{date}', '-7 Day')  THEN qtdePontos ELSE 0 END) AS SUM_OF_POINTS_D7,    
    SUM (DISTINCT CASE WHEN dtDay >= date('{date}', '-14 Day') THEN qtdePontos ELSE 0 END) AS SUM_OF_POINTS_D14,
    SUM (DISTINCT CASE WHEN dtDay >= date('{date}', '-28 Day') THEN qtdePontos ELSE 0 END) AS SUM_OF_POINTS_D28,
    SUM (DISTINCT CASE WHEN dtDay >= date('{date}', '-56 Day') THEN qtdePontos ELSE 0 END) AS SUM_OF_POINTS_D56,

    SUM (CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END ) AS TOTAL_GAINED_POINTS_LIFE,
    SUM (DISTINCT CASE WHEN dtDay >= date('{date}', '-7 Day')  AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS GAINED_POINTS_D7,    
    SUM (DISTINCT CASE WHEN dtDay >= date('{date}', '-14 Day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS GAINED_POINTS_D14,
    SUM (DISTINCT CASE WHEN dtDay >= date('{date}', '-28 Day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS GAINED_POINTS_D28,
    SUM (DISTINCT CASE WHEN dtDay >= date('{date}', '-56 Day') AND qtdePontos > 0  THEN qtdePontos ELSE 0 END) AS GAINED_POINTS_D56,

    SUM (CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END ) AS TOTAL_EXPEND_POINTS_LIFE,
    SUM (DISTINCT CASE WHEN dtDay >= date('{date}', '-7 Day')  AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS SPEND_POINTS_D7,    
    SUM (DISTINCT CASE WHEN dtDay >= date('{date}', '-14 Day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS  SPEND_POINTS_D14,
    SUM (DISTINCT CASE WHEN dtDay >= date('{date}', '-28 Day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS  SPEND_POINTS_D28,
    SUM (DISTINCT CASE WHEN dtDay >= date('{date}', '-56 Day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS SPEND_POINTS_D56,

    COUNT (DISTINCT CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END )   AS QtTransaction_Morning,
    COUNT (DISTINCT CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END )   AS Qtransaction_Afternoon,
    COUNT (DISTINCT CASE WHEN dtHora > 21 AND dtHora < 21 THEN IdTransacao END) AS QtTransaction_Night,

    1. * COUNT (DISTINCT CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END )   / COUNT(IdTransacao) AS pctTransaction_Morning,
    1. * COUNT (DISTINCT CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END )   / COUNT(IdTransacao) AS pctTransaction_Afternoon,
    1. * COUNT (DISTINCT CASE WHEN dtHora > 21 AND dtHora < 21 THEN IdTransacao END) / COUNT(IdTransacao)AS  pcTransaction_Night



FROM tb_transactions
GROUP BY IdCliente),

tb_agg_calculated

AS

(SELECT *,
    QtdTransaction_LIFE/LIFE,
    COALESCE(1. * QtdTransactions_D7/ActFrequencyD7 ,0)  AS transactions_day7,
    COALESCE(1. * QtdTransactions_D14/ActFrequencyD14,0) AS transactions_day14,
    COALESCE(1. * QtdTransactions_D28/ActFrequencyD28,0) AS transactions_day28,
    COALESCE(1. * QtdTransactions_D56/ActFrequencyD56,0) AS transactions_day56,

    COALESCE( 1. * QtdTransaction_LIFE/LIFE,0) AS PCT_ATSIVATION_MAU

FROM tb_agg_transaction),

tb_hours_day

AS

(


SELECT
    IdCliente,
    substr(DtCriacao,0,11) AS dtDay,
    24 * (MAX(julianday(DtCriacao)) - MIN(julianday(DtCriacao))) AS Total_hours_per_day
FROM transacoes
GROUP BY IdCliente, dtDay
),

tb_hour_client

AS

(


SELECT  
    IdCliente,
    SUM (Total_hours_per_day) qtd_hours_life,
    SUM (CASE WHEN dtDay >= date('{date}', '-7 Day') THEN   Total_hours_per_day ELSE 0 END) AS Total_hours_D7,
    SUM (CASE WHEN dtDay >= date('{date}', '-14 Day') THEN   Total_hours_per_day ELSE 0 END) AS Total_hours_D14,
    SUM (CASE WHEN dtDay >= date('{date}', '-28 Day') THEN   Total_hours_per_day ELSE 0 END) AS Total_hours_D28,
    SUM (CASE WHEN dtDay >= date('{date}', '-56 Day') THEN   Total_hours_per_day ELSE 0 END) AS Total_hours_D56
FROM tb_hours_day
GROUP BY IdCliente

),

tb_lag_day

AS

(

SELECT 
    IdCliente,
    dtDay,
    LAG(dtDay) OVER (PARTITION BY idCliente ORDER BY dtDay) AS Lag_day
FROM tb_hours_day),

tb_diff_days

AS

(SELECT
    IdCliente,
    AVG(julianday(dtDay) - julianday(Lag_day)) AS dif_day,
    AVG(CASE WHEN dtDay >= date('{date}', '-28 Day') THEN  julianday(dtDay) - julianday(Lag_day) END) AS dif_day_D28
FROM tb_lag_day
GROUP BY IdCliente),

tb_product_type

AS

(SELECT 

    IdCliente,
    1. * COUNT (CASE WHEN descNomeProduto = 'ChatMessage' THEN t1.idTransacao END) /COUNT(t1.IdTransacao) AS qtdeChatMessage,
    1. * COUNT (CASE WHEN descNomeProduto = 'Airflow Lover' THEN t1.idTransacao END)/COUNT(t1.IdTransacao) AS qtdeAirflowLover,
    1. * COUNT (CASE WHEN descNomeProduto = 'R Lover' THEN t1.idTransacao END) AS qtdeRLover,
    1. * COUNT (CASE WHEN descNomeProduto = 'Resgatar Ponei' THEN t1.idTransacao END) /COUNT(t1.IdTransacao)AS qtdeResgatarPonei,
    1. * COUNT (CASE WHEN descNomeProduto = 'Lista de Presença' THEN t1.idTransacao END)/COUNT(t1.IdTransacao) AS qtdeListadePresenca,
    1. * COUNT (CASE WHEN descNomeProduto = 'Presença Streak' THEN t1.idTransacao END)/COUNT(t1.IdTransacao) AS qtdePresençaStreak,
    1. * COUNT (CASE WHEN descNomeProduto = 'Troca de Pontos StreamElements' THEN t1.idTransacao END) /COUNT(t1.IdTransacao) AS qtdeTrocadePontoStreamElements,
    1. * COUNT (CASE WHEN descNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.idTransacao END) /COUNT(t1.IdTransacao) AS qtdeReembolsoTrocadePontosStreamElements,
    1. * COUNT (CASE WHEN descCategoriaProduto = 'rpg' THEN t1.idTransacao END) /COUNT(t1.IdTransacao) AS qtderpg,
    1. * COUNT (CASE WHEN descCategoriaProduto = 'churn' THEN t1.idTransacao END) /COUNT(t1.IdTransacao) AS qtdechurn

FROM tb_transactions AS t1

LEFT JOIN transacao_produto AS t2
ON t1.IdTransacao = t2.IdTransacao
LEFT JOIN produtos AS t3
ON t2.IdProduto = t3.IdProduto
GROUP BY IdCliente
),


tb_join

AS

(
SELECT  t1.*,
        t2.qtd_hours_life,
        t2.Total_hours_D7,
        t2.Total_hours_D14,
        t2.Total_hours_D28,
        t2.Total_hours_D56,
        t3.dif_day,
        t3.dif_day_D28,
        t4.qtdeChatMessage,
        t4.qtdeAirflowLover,
        t4.qtdeRLover,
        t4.qtdeResgatarPonei,
        t4.qtdeListadePresenca,
        t4.qtdePresençaStreak,
        t4.qtdeTrocadePontoStreamElements,
        t4.qtdeReembolsoTrocadePontosStreamElements,
        t4.qtderpg,
        t4.qtdechurn
         
FROM tb_agg_calculated AS t1

LEFT JOIN tb_hour_client AS t2
ON t1.IdCliente = t2.IdCliente

LEFT JOIN tb_diff_days AS t3
ON t1.IdCliente = t3.IdCliente

LEFT JOIN tb_product_type AS t4
ON t1.IdCliente = t4.IdCliente
)

SELECT 
    date('{date}','-1 day') AS dtRef,
    *

FROM tb_join