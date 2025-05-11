from flask import Flask, request, jsonify
import json
import joblib
import numpy as np
import tensorflow as tf

# ============================
# Cargar todo al iniciar el servidor
# ============================
app = Flask(__name__)

# Cargar menú
with open("menus_por_dieta.json", "r", encoding="utf-8") as f:
    menus = json.load(f)

# Cargar modelo, scaler y label encoder (entrenados con SMOTE)
model = tf.keras.models.load_model("mlp_mutual_info_model.keras")
scaler = joblib.load("scaler_mutual_info.pkl")
selected_features = joblib.load("selected_features_mutual_info.pkl")
label_encoder = joblib.load("label_encoder_target.pkl")

# ============================
# Función de predicción real
# ============================
def predecir_dieta(datos_usuario):
    try:
        # Asegurar que todos los features requeridos estén
        entrada = np.array([datos_usuario.get(f, 0) for f in selected_features]).reshape(1, -1)

        # Escalar entrada
        entrada_scaled = scaler.transform(entrada)

        # Predecir con el modelo
        predicciones = model.predict(entrada_scaled)
        dieta_predicha_idx = np.argmax(predicciones, axis=1)
        dieta_predicha = label_encoder.inverse_transform(dieta_predicha_idx)[0]
        
        return dieta_predicha
    except Exception as e:
        print(f"Error en predicción: {e}")
        return None

# ============================
# Endpoints
# ============================

@app.route("/api/recomendar", methods=["POST"])
def recomendar_dieta_y_menu():
    datos = request.get_json()
    if not datos:
        return jsonify({"error": "No se enviaron datos"}), 400

    dieta = predecir_dieta(datos)
    if not dieta:
        return jsonify({"error": "No se pudo predecir la dieta"}), 500

    menu = menus.get(dieta)
    if not menu:
        return jsonify({"error": "No se encontró un menú para la dieta predicha"}), 404

    return jsonify({
        "dieta": dieta,
        "menu": menu
    })


@app.route("/", methods=["GET"])
def home():
    return "Servidor Flask de Recomendación de Dietas activo."

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True, ssl_context=("cert.pem", "key.pem"))











