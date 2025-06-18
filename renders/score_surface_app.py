
""" 
🚀 To Run It:
	1.	Make sure you have Python and Streamlit installed:

pip install streamlit plotly


	2.	Run the app:

streamlit run score_surface_app.py


	3.	A browser window will open with:
	•	A 3D rotatable score surface
	•	A live slider to adjust the penalty factor
 """
import streamlit as st
import numpy as np
import plotly.graph_objects as go

# Constants
MIN_BEAM_RADIUS = 20
MAX_BEAM_RADIUS = 75
MIN_SCORE = 1
MAX_SCORE = 250
BASE_SCORE = 250

# Streamlit UI
st.title("Score Surface Visualizer")
penalty_factor = st.slider("Oversize Penalty Factor", min_value=0.1, max_value=5.0, value=2.0, step=0.1)

# Calculate score surface
beam_radii = np.linspace(MIN_BEAM_RADIUS, MAX_BEAM_RADIUS, 100)
obj_radii = np.linspace(MIN_BEAM_RADIUS, MAX_BEAM_RADIUS, 100)
beam_grid, obj_grid = np.meshgrid(beam_radii, obj_radii)

beam_percent = (beam_grid - MIN_BEAM_RADIUS) / (MAX_BEAM_RADIUS - MIN_BEAM_RADIUS)
obj_percent = (obj_grid - MIN_BEAM_RADIUS) / (MAX_BEAM_RADIUS - MIN_BEAM_RADIUS)
diff = beam_percent - obj_percent

penalty = np.where(diff > 0, np.exp(penalty_factor * diff) - 1, np.abs(diff))
match = np.maximum(0, 1 - penalty)
early_bonus = 1 - obj_percent
score = np.floor(BASE_SCORE * match * early_bonus + MIN_SCORE)
final_score = np.clip(score, MIN_SCORE, MAX_SCORE)

# Plotly surface
fig = go.Figure(data=[go.Surface(z=final_score, x=beam_grid, y=obj_grid, colorscale='Viridis')])
fig.update_layout(
    title=f"Score Surface (Penalty Factor = {penalty_factor})",
    scene=dict(
        xaxis_title='Beam Radius',
        yaxis_title='Object Radius',
        zaxis_title='Score'
    )
)

st.plotly_chart(fig)
