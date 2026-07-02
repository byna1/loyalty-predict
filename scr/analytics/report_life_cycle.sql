SELECT  dtRef,
        DescLifeCycle,
        Cluster,
        count(*) AS ClientAmount
FROM life_cycle
WHERE descLifeCycle <> '05 - CHURN'
GROUP BY dtRef,DescLifeCycle,Cluster
ORDER BY dtRef,DescLifeCycle,Cluster