--
-- PostgreSQL database dump
--

\restrict ZM9DeY4NjJNgkYbzydtmLMAkzRby6aAhfoDLkCfoCdbnjftw3SKYDV8grwWKgIC

-- Dumped from database version 17.9
-- Dumped by pg_dump version 17.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alertes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alertes (
    id integer NOT NULL,
    programme_id integer,
    date_alerte date DEFAULT CURRENT_DATE,
    type_alerte character varying(50),
    message text,
    statut character varying(20) DEFAULT 'ouverte'::character varying
);


ALTER TABLE public.alertes OWNER TO postgres;

--
-- Name: alertes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.alertes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.alertes_id_seq OWNER TO postgres;

--
-- Name: alertes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.alertes_id_seq OWNED BY public.alertes.id;


--
-- Name: indicateurs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.indicateurs (
    id integer NOT NULL,
    programme_id integer,
    nom character varying(200),
    valeur_cible numeric,
    valeur_baseline numeric,
    unite character varying(50)
);


ALTER TABLE public.indicateurs OWNER TO postgres;

--
-- Name: indicateurs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.indicateurs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.indicateurs_id_seq OWNER TO postgres;

--
-- Name: indicateurs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.indicateurs_id_seq OWNED BY public.indicateurs.id;


--
-- Name: mesures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mesures (
    id integer NOT NULL,
    indicateur_id integer,
    date_mesure date,
    valeur_reelle numeric,
    valeur_cible numeric,
    taux_realisation numeric
);


ALTER TABLE public.mesures OWNER TO postgres;

--
-- Name: mesures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mesures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mesures_id_seq OWNER TO postgres;

--
-- Name: mesures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mesures_id_seq OWNED BY public.mesures.id;


--
-- Name: programmes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.programmes (
    id integer NOT NULL,
    code character varying(20) NOT NULL,
    titre character varying(200) NOT NULL,
    pays character varying(50),
    secteur character varying(50),
    bailleur character varying(50),
    budget_eur numeric,
    date_debut date,
    date_fin date,
    statut character varying(20)
);


ALTER TABLE public.programmes OWNER TO postgres;

--
-- Name: programmes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.programmes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.programmes_id_seq OWNER TO postgres;

--
-- Name: programmes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.programmes_id_seq OWNED BY public.programmes.id;


--
-- Name: alertes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alertes ALTER COLUMN id SET DEFAULT nextval('public.alertes_id_seq'::regclass);


--
-- Name: indicateurs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.indicateurs ALTER COLUMN id SET DEFAULT nextval('public.indicateurs_id_seq'::regclass);


--
-- Name: mesures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mesures ALTER COLUMN id SET DEFAULT nextval('public.mesures_id_seq'::regclass);


--
-- Name: programmes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.programmes ALTER COLUMN id SET DEFAULT nextval('public.programmes_id_seq'::regclass);


--
-- Data for Name: alertes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alertes (id, programme_id, date_alerte, type_alerte, message, statut) FROM stdin;
1	1	2024-06-30	Retard	Taux insertion 58% vs cible 65% - risque de non atteinte en fin de programme	ouverte
2	2	2023-12-31	Performance	Taux acces eau 70% vs cible 80% - acceleration necessaire	ouverte
3	3	2024-03-31	Succes	Taux vaccination 85% atteint - objectif presque realise	fermee
4	4	2024-06-30	Retard	Satisfaction citoyens 52% vs cible 70% - engagement communautaire insuffisant	ouverte
5	5	2024-03-31	Succes	Reboisement 4800 ha sur 5000 ha cibles - excellent progres	fermee
\.


--
-- Data for Name: indicateurs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.indicateurs (id, programme_id, nom, valeur_cible, valeur_baseline, unite) FROM stdin;
1	1	Taux d insertion professionnelle	65	25	%
2	1	Revenu mensuel moyen beneficiaires	75000	45000	FCFA
3	1	Nombre de jeunes formes	500	0	personnes
4	2	Taux acces eau potable	80	35	%
5	2	Nombre points eau construits	50	0	unites
6	3	Taux consultation prenatale	85	45	%
7	3	Taux vaccination enfants moins 5 ans	90	60	%
8	4	Nombre communes appuyees	20	0	communes
9	4	Taux satisfaction citoyens services	70	30	%
10	5	Hectares reboisees	5000	0	hectares
11	5	Nombre menages beneficiaires	2000	0	menages
\.


--
-- Data for Name: mesures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mesures (id, indicateur_id, date_mesure, valeur_reelle, valeur_cible, taux_realisation) FROM stdin;
1	1	2022-06-30	28	65	\N
2	1	2022-12-31	35	65	\N
3	1	2023-06-30	45	65	\N
4	1	2023-12-31	52	65	\N
5	1	2024-06-30	58	65	\N
6	2	2022-12-31	48000	75000	\N
7	2	2023-06-30	55000	75000	\N
8	2	2023-12-31	63000	75000	\N
9	2	2024-06-30	70000	75000	\N
10	4	2021-12-31	40	80	\N
11	4	2022-06-30	48	80	\N
12	4	2022-12-31	55	80	\N
13	4	2023-06-30	62	80	\N
14	4	2023-12-31	70	80	\N
15	6	2022-09-30	52	85	\N
16	6	2023-03-31	61	85	\N
17	6	2023-09-30	70	85	\N
18	6	2024-03-31	78	85	\N
19	7	2022-09-30	65	90	\N
20	7	2023-03-31	72	90	\N
21	7	2023-09-30	79	90	\N
22	7	2024-03-31	85	90	\N
23	9	2023-06-30	38	70	\N
24	9	2023-12-31	45	70	\N
25	9	2024-06-30	52	70	\N
26	10	2022-03-31	800	5000	\N
27	10	2022-09-30	1800	5000	\N
28	10	2023-03-31	2900	5000	\N
29	10	2023-09-30	4100	5000	\N
30	10	2024-03-31	4800	5000	\N
\.


--
-- Data for Name: programmes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.programmes (id, code, titre, pays, secteur, bailleur, budget_eur, date_debut, date_fin, statut) FROM stdin;
1	NIG-EDU-01	Formation professionnelle jeunes Niger	Niger	Education & Emploi	LuxDev	2500000	2022-01-01	2025-12-31	actif
2	MLI-EAU-01	AccŠs eau potable zones rurales Mali	Mali	Eau & Assainissement	LuxDev	1800000	2021-06-01	2024-05-31	actif
3	BFA-SAN-01	Sant‚ maternelle et infantile Burkina	Burkina Faso	Sant‚	LuxDev	3200000	2022-03-01	2026-02-28	actif
4	SEN-GOV-01	Gouvernance locale et d‚centralisation	S‚n‚gal	Gouvernance	LuxDev	1500000	2023-01-01	2025-12-31	actif
5	MRT-ENV-01	R‚silience climatique et reforestation	Mauritanie	Environnement	LuxDev	2100000	2021-09-01	2024-08-31	cl“tur‚
\.


--
-- Name: alertes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.alertes_id_seq', 5, true);


--
-- Name: indicateurs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.indicateurs_id_seq', 11, true);


--
-- Name: mesures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mesures_id_seq', 30, true);


--
-- Name: programmes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.programmes_id_seq', 5, true);


--
-- Name: alertes alertes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alertes
    ADD CONSTRAINT alertes_pkey PRIMARY KEY (id);


--
-- Name: indicateurs indicateurs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.indicateurs
    ADD CONSTRAINT indicateurs_pkey PRIMARY KEY (id);


--
-- Name: mesures mesures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mesures
    ADD CONSTRAINT mesures_pkey PRIMARY KEY (id);


--
-- Name: programmes programmes_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.programmes
    ADD CONSTRAINT programmes_code_key UNIQUE (code);


--
-- Name: programmes programmes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.programmes
    ADD CONSTRAINT programmes_pkey PRIMARY KEY (id);


--
-- Name: alertes alertes_programme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alertes
    ADD CONSTRAINT alertes_programme_id_fkey FOREIGN KEY (programme_id) REFERENCES public.programmes(id);


--
-- Name: indicateurs indicateurs_programme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.indicateurs
    ADD CONSTRAINT indicateurs_programme_id_fkey FOREIGN KEY (programme_id) REFERENCES public.programmes(id);


--
-- Name: mesures mesures_indicateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mesures
    ADD CONSTRAINT mesures_indicateur_id_fkey FOREIGN KEY (indicateur_id) REFERENCES public.indicateurs(id);


--
-- PostgreSQL database dump complete
--

\unrestrict ZM9DeY4NjJNgkYbzydtmLMAkzRby6aAhfoDLkCfoCdbnjftw3SKYDV8grwWKgIC

