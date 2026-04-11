# =============================================================
# sahel-program-monitor | LuxDev
# Script : Tableau de bord de suivi des programmes
# Auteur : Serge-Alain NYAMSIN | github.com/sanyamsin
# Date : Avril 2026
# =============================================================
# Objectif : Dashboard interactif de suivi des indicateurs
# de performance des programmes LuxDev au Sahel
# Technologies : Dash, Plotly, PostgreSQL
# =============================================================

import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from dash import Dash, html, dcc, Input, Output
import psycopg2

# --- Connexion PostgreSQL ------------------------------------
def get_connection():
    return psycopg2.connect(
        dbname   = "sahel_monitor",
        user     = "postgres",
        password = "luxdev2026",
        host     = "localhost",
        port     = 5432
    )

# --- Chargement des données ----------------------------------
def load_data():
    conn = get_connection()

    # Programmes
    df_prog = pd.read_sql("""
        SELECT p.*, COUNT(DISTINCT i.id) AS nb_indicateurs,
               ROUND(AVG(m.valeur_reelle /
                   NULLIF(m.valeur_cible, 0) * 100), 1) AS performance
        FROM programmes p
        LEFT JOIN indicateurs i ON i.programme_id = p.id
        LEFT JOIN mesures m     ON m.indicateur_id = i.id
        GROUP BY p.id
        ORDER BY performance DESC
    """, conn)

    # Évolution temporelle
    df_evolution = pd.read_sql("""
        SELECT p.code, p.pays, p.secteur,
               i.nom AS indicateur, i.unite,
               m.date_mesure, m.valeur_reelle, m.valeur_cible,
               ROUND(m.valeur_reelle /
                   NULLIF(m.valeur_cible, 0) * 100, 1) AS pct
        FROM programmes p
        JOIN indicateurs i ON i.programme_id = p.id
        JOIN mesures m     ON m.indicateur_id = i.id
        ORDER BY p.code, i.nom, m.date_mesure
    """, conn)

    # Alertes
    df_alertes = pd.read_sql("""
        SELECT a.*, p.code, p.pays, p.secteur
        FROM alertes a
        JOIN programmes p ON p.id = a.programme_id
        ORDER BY a.date_alerte DESC
    """, conn)

    conn.close()
    return df_prog, df_evolution, df_alertes

df_prog, df_evolution, df_alertes = load_data()

# --- Initialisation Dash -------------------------------------
app = Dash(__name__)

# Couleurs
BLUE  = "#1F4E79"
LIGHT = "#D6E4F0"

# --- Layout --------------------------------------------------
app.layout = html.Div([

    # Header
    html.Div([
        html.H1("Sahel Program Monitor",
                style={"margin": "0", "fontSize": "2em"}),
        html.P("Tableau de bord de suivi des programmes LuxDev — Sahel & Afrique centrale",
               style={"margin": "8px 0 0", "opacity": "0.85"}),
        html.P("Serge-Alain NYAMSIN | github.com/sanyamsin",
               style={"margin": "4px 0 0", "opacity": "0.7",
                      "fontSize": "0.9em"})
    ], style={
        "background": f"linear-gradient(135deg, {BLUE}, #2E86AB)",
        "color": "white", "padding": "30px 40px"
    }),

    html.Div([

        # KPI Cards
        html.Div([
            html.Div([
                html.Div(str(len(df_prog)),
                         style={"fontSize": "2.5em", "fontWeight": "bold",
                                "color": BLUE}),
                html.Div("Programmes suivis",
                         style={"color": "#7f8c8d", "fontSize": "0.9em"})
            ], style={"background": "white", "borderRadius": "10px",
                      "padding": "20px", "textAlign": "center",
                      "borderTop": f"4px solid {BLUE}",
                      "boxShadow": "0 2px 8px rgba(0,0,0,0.08)"}),

            html.Div([
                html.Div(f"{df_prog['performance'].mean():.1f}%",
                         style={"fontSize": "2.5em", "fontWeight": "bold",
                                "color": "#27ae60"}),
                html.Div("Performance globale",
                         style={"color": "#7f8c8d", "fontSize": "0.9em"})
            ], style={"background": "white", "borderRadius": "10px",
                      "padding": "20px", "textAlign": "center",
                      "borderTop": "4px solid #27ae60",
                      "boxShadow": "0 2px 8px rgba(0,0,0,0.08)"}),

            html.Div([
                html.Div(f"{df_prog['budget_eur'].sum()/1e6:.1f}M€",
                         style={"fontSize": "2.5em", "fontWeight": "bold",
                                "color": "#f39c12"}),
                html.Div("Budget total",
                         style={"color": "#7f8c8d", "fontSize": "0.9em"})
            ], style={"background": "white", "borderRadius": "10px",
                      "padding": "20px", "textAlign": "center",
                      "borderTop": "4px solid #f39c12",
                      "boxShadow": "0 2px 8px rgba(0,0,0,0.08)"}),

            html.Div([
                html.Div(str(len(df_alertes[df_alertes["statut"]=="ouverte"])),
                         style={"fontSize": "2.5em", "fontWeight": "bold",
                                "color": "#e74c3c"}),
                html.Div("Alertes actives",
                         style={"color": "#7f8c8d", "fontSize": "0.9em"})
            ], style={"background": "white", "borderRadius": "10px",
                      "padding": "20px", "textAlign": "center",
                      "borderTop": "4px solid #e74c3c",
                      "boxShadow": "0 2px 8px rgba(0,0,0,0.08)"}),

        ], style={"display": "grid",
                  "gridTemplateColumns": "repeat(4, 1fr)",
                  "gap": "20px", "marginBottom": "24px"}),

        # Graphique 1 : Performance par programme
        html.Div([
            html.H2("Performance par programme (%)",
                    style={"color": BLUE, "marginBottom": "16px",
                           "fontSize": "1.2em"}),
            dcc.Graph(
                figure=px.bar(
                    df_prog.sort_values("performance"),
                    x="performance", y="code",
                    orientation="h",
                    color="performance",
                    color_continuous_scale=["#e74c3c", "#f39c12", "#27ae60"],
                    range_color=[50, 100],
                    labels={"performance": "Taux de réalisation (%)",
                            "code": "Programme"},
                    text="performance"
                ).update_traces(
                    texttemplate="%{text}%", textposition="outside"
                ).update_layout(
                    plot_bgcolor="white", paper_bgcolor="white",
                    coloraxis_showscale=False, margin=dict(l=20, r=40, t=20, b=20)
                )
            )
        ], style={"background": "white", "borderRadius": "10px",
                  "padding": "24px", "marginBottom": "24px",
                  "boxShadow": "0 2px 8px rgba(0,0,0,0.08)"}),

        # Graphique 2 : Évolution temporelle (filtre par programme)
        html.Div([
            html.H2("Évolution des indicateurs",
                    style={"color": BLUE, "marginBottom": "16px",
                           "fontSize": "1.2em"}),
            dcc.Dropdown(
                id="dropdown-programme",
                options=[{"label": f"{row['code']} — {row['pays']}",
                          "value": row["code"]}
                         for _, row in df_prog.iterrows()],
                value=df_prog["code"].iloc[0],
                style={"marginBottom": "16px"}
            ),
            dcc.Graph(id="graph-evolution")
        ], style={"background": "white", "borderRadius": "10px",
                  "padding": "24px", "marginBottom": "24px",
                  "boxShadow": "0 2px 8px rgba(0,0,0,0.08)"}),

        # Alertes
        html.Div([
            html.H2("Alertes actives",
                    style={"color": BLUE, "marginBottom": "16px",
                           "fontSize": "1.2em"}),
            html.Div([
                html.Div([
                    html.Div([
                        html.Strong(f"{row['code']} — {row['pays']}"),
                        html.Span(f" | {row['type_alerte']}",
                                  style={"color": "#e74c3c",
                                         "marginLeft": "8px"}),
                        html.P(row["message"],
                               style={"margin": "6px 0 0",
                                      "fontSize": "0.9em",
                                      "color": "#555"})
                    ], style={"padding": "14px",
                              "background": "#fef9f0",
                              "borderLeft": "4px solid #f39c12",
                              "borderRadius": "0 6px 6px 0",
                              "marginBottom": "10px"})
                ]) for _, row in df_alertes[
                    df_alertes["statut"] == "ouverte"].iterrows()
            ])
        ], style={"background": "white", "borderRadius": "10px",
                  "padding": "24px", "marginBottom": "24px",
                  "boxShadow": "0 2px 8px rgba(0,0,0,0.08)"}),

    ], style={"maxWidth": "1100px", "margin": "0 auto",
              "padding": "30px 20px"})
])

# --- Callback évolution --------------------------------------
@app.callback(
    Output("graph-evolution", "figure"),
    Input("dropdown-programme", "value")
)
def update_evolution(code):
    df_f = df_evolution[df_evolution["code"] == code]
    fig = px.line(
        df_f, x="date_mesure", y="pct",
        color="indicateur", markers=True,
        labels={"pct": "Taux de réalisation (%)",
                "date_mesure": "Date", "indicateur": "Indicateur"},
        title=f"Évolution — {code}"
    )
    fig.add_hline(y=100, line_dash="dash", line_color="green",
                  annotation_text="Cible 100%")
    fig.add_hline(y=70, line_dash="dash", line_color="orange",
                  annotation_text="Seuil alerte 70%")
    fig.update_layout(
        plot_bgcolor="white", paper_bgcolor="white",
        margin=dict(l=20, r=20, t=40, b=20)
    )
    return fig

# --- Lancement -----------------------------------------------
if __name__ == "__main__":
    print("✅ Dashboard lancé sur http://localhost:8050")
    app.run(debug=True)