WITH

tb_user_course

AS

(SELECT  
    idUsuario,
    descSlugCurso,
    COUNT(idCursoEpisodioCompleto) AS completed_by_user
FROM cursos_episodios_completos
WHERE dtCriacao < '{date}'
GROUP BY idUsuario,descSlugCurso),

tb_course_eps

AS

(SELECT
    descSlugCurso,
    COUNT(descEpisodio) AS qtdeTotalEps
FROM cursos_episodios
GROUP BY descSlugCurso),

tb_pct_courses

AS

(SELECT 

    t1.idUsuario,
    t1.descSlugCurso,
    1.* t1.completed_by_user/t2.qtdeTotalEps AS pct_completion
FROM tb_user_course AS t1
LEFT JOIN tb_course_eps AS t2
ON t1.descSlugCurso = t2.descSlugCurso),

tb_pct_courses_pivot

AS
(
SELECT *,
    SUM((CASE WHEN pct_completion = 1 THEN 1 ELSE 0 END)) AS TotalOfCompletedCourses,
    SUM((CASE WHEN pct_completion < 1 AND  pct_completion > 0 THEN 1 ELSE 0 END)) AS TotalOfIncompletedCourses,
    SUM((CASE WHEN descSlugCurso = "descSlugCurso" THEN pct_completion ELSE 0 END)) AS SlugCourse,
    SUM((CASE WHEN descSlugCurso = "github-2025" THEN pct_completion ELSE 0 END)) AS github2025,
    SUM((CASE WHEN descSlugCurso = "python-2025" THEN pct_completion ELSE 0 END)) AS python2025,
    SUM((CASE WHEN descSlugCurso = "github-2024" THEN pct_completion ELSE 0 END)) AS github2024,
    SUM((CASE WHEN descSlugCurso = "pandas-2024" THEN pct_completion ELSE 0 END)) AS pandas2024,
    SUM((CASE WHEN descSlugCurso = "coleta-dados-2024" THEN pct_completion ELSE 0 END)) AS coletaDados2024,
    SUM((CASE WHEN descSlugCurso = "ml-2024" THEN pct_completion ELSE 0 END)) AS ml2024,
    SUM((CASE WHEN descSlugCurso = "python-2024" THEN pct_completion ELSE 0 END)) AS python2024,
    SUM((CASE WHEN descSlugCurso = "estatistica-2024" THEN pct_completion ELSE 0 END)) AS estatistica2024,
    SUM((CASE WHEN descSlugCurso = "ds-databricks-2024" THEN pct_completion ELSE 0 END)) AS dsDatabricks2024,
    SUM((CASE WHEN descSlugCurso = "mlflow-2025" THEN pct_completion ELSE 0 END)) AS mlflow2025,
    SUM((CASE WHEN descSlugCurso = "lago-mago-2024" THEN pct_completion ELSE 0 END)) AS lagoMago2024,
    SUM((CASE WHEN descSlugCurso = "sql-2020" THEN pct_completion ELSE 0 END)) AS sql2020,
    SUM((CASE WHEN descSlugCurso = "ds-pontos-2024" THEN pct_completion ELSE 0 END)) AS dsPontos2024,
    SUM((CASE WHEN descSlugCurso = "ia-canal-2025" THEN pct_completion ELSE 0 END)) AS iaCanal2025,
    SUM((CASE WHEN descSlugCurso = "pandas-2025" THEN pct_completion ELSE 0 END)) AS pandas2025,
    SUM((CASE WHEN descSlugCurso = "tse-analytics-2024" THEN pct_completion ELSE 0 END)) AS tseAnalytics2024,
    SUM((CASE WHEN descSlugCurso = "estatistica-2025" THEN pct_completion ELSE 0 END)) AS estatistica2025,
    SUM((CASE WHEN descSlugCurso = "machine-learning-2025" THEN pct_completion ELSE 0 END)) AS machineLearning2025,
    SUM((CASE WHEN descSlugCurso = "trampar-lakehouse-2024" THEN pct_completion ELSE 0 END)) AS tramparLakehouse2024,
    SUM((CASE WHEN descSlugCurso = "streamlit-2025" THEN pct_completion ELSE 0 END)) AS streamlit2025,
    SUM((CASE WHEN descSlugCurso = "sql-2025" THEN pct_completion ELSE 0 END)) AS sql2025,
    SUM((CASE WHEN descSlugCurso = "carreira" THEN pct_completion ELSE 0 END)) AS carreira,
    SUM((CASE WHEN descSlugCurso = "loyalty-predict-2025" THEN pct_completion ELSE 0 END)) AS loyaltyPredict2025,
    SUM((CASE WHEN descSlugCurso = "speed-f1" THEN pct_completion ELSE 0 END)) AS speedF1,
    SUM((CASE WHEN descSlugCurso = "matchmaking-trampar-de-casa-2024" THEN pct_completion ELSE 0 END)) AS matchmakingTramparDeCasa2024,
    SUM((CASE WHEN descSlugCurso = "nekt-2025" THEN pct_completion ELSE 0 END)) AS nekt2025,
    SUM((CASE WHEN descSlugCurso = "go-2026" THEN pct_completion ELSE 0 END)) AS go2026,
    SUM((CASE WHEN descSlugCurso = "f1-lake" THEN pct_completion ELSE 0 END)) AS f1Lake,
    SUM((CASE WHEN descSlugCurso = "plataforma-ml-2026" THEN pct_completion ELSE 0 END)) AS plataformaMl2026,
    SUM((CASE WHEN descSlugCurso = "ragia" THEN pct_completion ELSE 0 END)) AS ragia

FROM tb_pct_courses
GROUP BY idUsuario
),

tb_activity

AS


(    SELECT
    
            idUsuario,
            MAX(dtCriacao) AS dtCreation
    
    FROM habilidades_usuarios
    WHERE dtCriacao < '{date}'
    GROUP  BY idUsuario 

UNION ALL 

        SELECT
            idUsuario,
            MAX(dtCriacao) AS dtCreation
        FROM cursos_episodios_completos
        WHERE dtCriacao < '{date}'
        GROUP BY idUsuario
UNION ALL 

        SELECT
            idUsuario,
            MAX(dtRecompensa) AS dtCreation
        FROM recompensas_usuarios
        WHERE dtRecompensa < '{date}'
        GROUP  BY idUsuario),
        
tb_last_activity

AS

(SELECT 
    idUsuario,
    MIN(julianday('{date}')) - (julianday(dtCreation)) AS qtd_days_last_activity
FROM tb_activity
GROUP  BY idUsuario),

tb_join

AS



(SELECT
    t3.idTMWCliente AS IdCliente,
    t1.pct_completion,
    t1.TotalOfCompletedCourses,
    t1.TotalOfIncompletedCourses,
    t1.SlugCourse,
    t1.github2025,
    t1.python2025,
    t1.github2024,
    t1.pandas2024,
    t1.coletaDados2024,
    t1.ml2024,
    t1.python2024,
    t1.estatistica2024,
    t1.dsDatabricks2024,
    t1.mlflow2025,
    t1.lagoMago2024,
    t1.sql2020,
    t1.dsPontos2024,
    t1.iaCanal2025,
    t1.pandas2025,
    t1.tseAnalytics2024,
    t1.estatistica2025,
    t1.machineLearning2025,
    t1.tramparLakehouse2024,
    t1.streamlit2025,
    t1.sql2025,
    t1.carreira,
    t1.loyaltyPredict2025,
    t1.speedF1,
    t1.matchmakingTramparDeCasa2024,
    t1.nekt2025,
    t1.go2026,
    t1.f1Lake,
    t1.plataformaMl2026,
    t1.ragia,
    t2.qtd_days_last_activity
FROM tb_pct_courses_pivot AS t1
LEFT JOIN tb_last_activity AS t2
ON t1.idUsuario = t2.idUsuario
INNER JOIN usuarios_tmw AS t3
ON t1.idUsuario = t3.idUsuario


)

SELECT date('{date}', '-1 day') AS dtRef,
*
FROM tb_join