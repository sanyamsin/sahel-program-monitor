-- =============================================================
-- sahel-program-monitor | LuxDev
-- Requêtes SQL : Suivi et analyse des programmes
-- Auteur : Serge-alain NYAMSIN | github.com/sanyamsin
-- Date : Avril 2026
-- =============================================================

-- -------------------------------------------------------------
-- 1. TABLEAU DE BORD GLOBAL DES PROGRAMMES
-- -------------------------------------------------------------
SELECT
    p.code,
    p.pays,
    p.secteur,
    p.budget_eur,
    p.statut,
    COUNT(DISTINCT i.id)           AS nb_indicateurs,
    COUNT(DISTINCT m.id)           AS nb_mesures,
    ROUND(AVG(m.valeur_reelle /
        NULLIF(m.valeur_cible, 0) * 100), 1) AS taux_realisation_moy
FROM programmes p
LEFT JOIN indicateurs i ON i.programme_id = p.id
LEFT JOIN mesures m     ON m.indicateur_id = i.id
GROUP BY p.id, p.code, p.pays, p.secteur, p.budget_eur, p.statut
ORDER BY taux_realisation_moy DESC;

-- -------------------------------------------------------------
-- 2. PROGRESSION DES INDICATEURS PAR PROGRAMME
-- -------------------------------------------------------------
SELECT
    p.code,
    p.pays,
    i.nom                          AS indicateur,
    i.valeur_baseline,
    i.valeur_cible,
    MAX(m.valeur_reelle)           AS derniere_valeur,
    i.unite,
    ROUND(MAX(m.valeur_reelle) /
        NULLIF(i.valeur_cible, 0) * 100, 1) AS pct_realisation,
    CASE
        WHEN MAX(m.valeur_reelle) /
             NULLIF(i.valeur_cible, 0) >= 0.9
             THEN '🟢 Sur la bonne voie'
        WHEN MAX(m.valeur_reelle) /
             NULLIF(i.valeur_cible, 0) >= 0.7
             THEN '🟡 Attention requise'
        ELSE '🔴 Retard critique'
    END AS statut
FROM programmes p
JOIN indicateurs i ON i.programme_id = p.id
JOIN mesures m     ON m.indicateur_id = i.id
GROUP BY p.code, p.pays, i.nom, i.valeur_baseline,
         i.valeur_cible, i.unite
ORDER BY p.code, pct_realisation DESC;

-- -------------------------------------------------------------
-- 3. ÉVOLUTION TEMPORELLE PAR INDICATEUR
-- -------------------------------------------------------------
SELECT
    p.code,
    i.nom                          AS indicateur,
    m.date_mesure,
    m.valeur_reelle,
    m.valeur_cible,
    ROUND(m.valeur_reelle /
        NULLIF(m.valeur_cible, 0) * 100, 1) AS pct_realisation,
    LAG(m.valeur_reelle) OVER (
        PARTITION BY i.id
        ORDER BY m.date_mesure)    AS valeur_precedente,
    ROUND(m.valeur_reelle -
        LAG(m.valeur_reelle) OVER (
            PARTITION BY i.id
            ORDER BY m.date_mesure), 1) AS progression
FROM programmes p
JOIN indicateurs i ON i.programme_id = p.id
JOIN mesures m     ON m.indicateur_id = i.id
ORDER BY p.code, i.nom, m.date_mesure;

-- -------------------------------------------------------------
-- 4. ALERTES ACTIVES
-- -------------------------------------------------------------
SELECT
    p.code,
    p.pays,
    p.secteur,
    a.date_alerte,
    a.type_alerte,
    a.message,
    a.statut
FROM alertes a
JOIN programmes p ON p.id = a.programme_id
WHERE a.statut = 'ouverte'
ORDER BY a.date_alerte DESC;

-- -------------------------------------------------------------
-- 5. ANALYSE BUDGÉTAIRE PAR SECTEUR
-- -------------------------------------------------------------
SELECT
    secteur,
    COUNT(*)                       AS nb_programmes,
    SUM(budget_eur)                AS budget_total,
    ROUND(AVG(budget_eur), 0)      AS budget_moyen,
    MIN(budget_eur)                AS budget_min,
    MAX(budget_eur)                AS budget_max
FROM programmes
GROUP BY secteur
ORDER BY budget_total DESC;

-- -------------------------------------------------------------
-- 6. PROGRAMMES À RISQUE
-- (taux de réalisation < 70% sur dernière mesure)
-- -------------------------------------------------------------
WITH derniere_mesure AS (
    SELECT
        i.programme_id,
        i.nom,
        m.valeur_reelle,
        m.valeur_cible,
        ROUND(m.valeur_reelle /
            NULLIF(m.valeur_cible, 0) * 100, 1) AS pct,
        ROW_NUMBER() OVER (
            PARTITION BY i.id
            ORDER BY m.date_mesure DESC)         AS rn
    FROM indicateurs i
    JOIN mesures m ON m.indicateur_id = i.id
)
SELECT
    p.code,
    p.pays,
    p.secteur,
    d.nom                          AS indicateur,
    d.pct                          AS taux_realisation,
    '[!] Intervention requise'     AS recommandation
FROM derniere_mesure d
JOIN programmes p ON p.id = d.programme_id
WHERE d.rn = 1
  AND d.pct < 70
ORDER BY d.pct ASC;

-- -------------------------------------------------------------
-- 7. RAPPORT DE PERFORMANCE GLOBALE
-- -------------------------------------------------------------
SELECT
    COUNT(DISTINCT p.id)           AS nb_programmes_total,
    COUNT(DISTINCT i.id)           AS nb_indicateurs_total,
    COUNT(DISTINCT m.id)           AS nb_mesures_total,
    SUM(p.budget_eur)              AS budget_total_eur,
    ROUND(AVG(m.valeur_reelle /
        NULLIF(m.valeur_cible, 0) * 100), 1) AS performance_globale_pct,
    COUNT(DISTINCT a.id)
        FILTER (WHERE a.statut = 'ouverte') AS alertes_actives
FROM programmes p
LEFT JOIN indicateurs i ON i.programme_id = p.id
LEFT JOIN mesures m     ON m.indicateur_id = i.id
LEFT JOIN alertes a     ON a.programme_id  = p.id;