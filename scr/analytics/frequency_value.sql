
WITH tb_freq_value

AS

(SELECT
    idCliente,
    count(DISTINCT substr(DtCriacao,0,11)) AS frequency,
    SUM(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS SumOfPointsPos
FROM transacoes
WHERE DtCriacao < '2026-01-01'
AND DtCriacao > date('2026-01-01','-28 day')
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
SELECT * 
FROM tb_cluster
