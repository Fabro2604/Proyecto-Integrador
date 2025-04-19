# Flask Backend actualizado para trabajar con el modelo RF + Feature Selection
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import joblib

app = Flask(__name__)
CORS(app)

# Cargar modelo actualizado y columnas seleccionadas
model = joblib.load("rf_mutual_info_model.pkl")
selected_features = joblib.load("selected_features_mutual_info.pkl")
le_target = joblib.load("label_encoder_target.pkl")

@app.route('/api/predecir', methods=['POST'])
def predecir():
    try:
        data = request.json
        print("✅ Datos recibidos desde el frontend:", data)
        print("🎯 Features requeridas por el modelo:", selected_features)

        # Enfermedades relevantes para No_Condition
        enfermedades = ["Diabetes", "Obesity", "Heart Disease", "Hypertension", "Kidney Disease"]

        # Crear input dict con todos los valores requeridos
        input_dict = {}
        for feature in selected_features:
            if feature == "No_Condition":
                input_dict[feature] = int(all(data.get(cond, 0) == 0 for cond in enfermedades))
            else:
                input_dict[feature] = float(data.get(feature, 0))

        df_input = pd.DataFrame([input_dict], columns=selected_features)
        print("📦 Input al modelo:\n", df_input)

        pred = model.predict(df_input)[0]
        dieta = le_target.inverse_transform([pred])[0]
        print("🥗 Dieta predicha:", dieta)

        return jsonify({"dieta": dieta})

    except Exception as e:
        print("❌ Error interno:", str(e))
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5000)









