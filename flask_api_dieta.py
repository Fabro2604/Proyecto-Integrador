import pandas as pd
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib

# ============================
#       CONFIGURACIÓN
# ============================

app = Flask(__name__)
CORS(app)

# Cargar modelo entrenado
model = joblib.load("rf_feature_selection.pkl")

# Lista de características seleccionadas
selected_features = [
    'Disease_Type',
    'Preferred_Cuisine',
    'Glucose_mg/dL',
    'BMI',
    'Cholesterol_mg/dL',
    'Adherence_to_Diet_Plan',
    'Height_cm'
]

# ============================
#       API
# ============================

@app.route('/api/predecir', methods=['POST'])
def predecir():
    try:
        data = request.json

        print("✅ Datos recibidos desde Flutter:", data)
        print(f"Total características recibidas: {len(data)}")

        if len(data) != 7:
            return jsonify({
                "error": f"Se esperaban 7 características pero se recibieron {len(data)}",
                "datos_recibidos": data
            })

        # Mapeo de variables categóricas
        cuisine_map = {"Mexican": 0, "Italian": 1, "Chinese": 2, "Indian": 3}
        disease_map = {"None": 0, "Diabetes": 1, "Obesity": 2, "Hypertension": 3}

        # Vector de entrada
        processed_data = [
            disease_map.get(data["Disease_Type"], 0),
            cuisine_map.get(data["Preferred_Cuisine"], 0),
            float(data["Glucose_mg/dL"]),
            float(data["BMI"]),
            float(data["Cholesterol_mg/dL"]),
            float(data["Adherence_to_Diet_Plan"]),
            float(data["Height_cm"])
        ]

        df_input = pd.DataFrame([processed_data], columns=selected_features)

        # ============================
        #       Predicción
        # ============================

        prediction = model.predict(df_input)

        return jsonify({
            "dieta": int(prediction[0]),    # Predicción
            "recetas": []                    # Opcional, puedes llenarlo luego
        })

    except Exception as e:
        return jsonify({"error": str(e)})


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5000)
