## 📋 Descripción

Este proyecto consiste en el desarrollo de una solución integral para la **recomendación de dietas personalizadas**. Combina modelos de machine learning, una API REST y una aplicación móvil multiplataforma para proporcionar recomendaciones basadas en las características clínicas y preferencias del usuario.

La aplicación ha sido diseñada principalmente para personas con enfermedades crónicas como **obesidad**, **diabetes** o **hipertensión** **etc**, mejorando la accesibilidad a planes alimenticios adaptados.

---

## 🚀 Tecnologías utilizadas

- Python (scikit-learn, pandas, numpy, matplotlib)
- TensorFlow / Keras
- Flask (API REST)
- Flutter (Aplicación Móvil Android / iOS)
- joblib (Persistencia de modelos)


## To create the app

Odescargado Flutter, ejecuta este comando para crear la estructura de carpetas: flutter create —org com.yourdomain your_app_name
Luego, pega el archivo main.dart en la carpeta lib y guarda flask_api_dieta.py y rf_feature_selection.pkl en dicha carpeta.

## To run the app
- Para descargar Flutter, sigue las instrucciones de este video: https://www.youtube.com/watch?v=QG9bw4rWqrg&t=900s
- Descarga Android Studio e instala Flutter.
- Necesitarás Xcode para ejecutar el simulador de la aplicación.
- Abre la terminal en la carpeta lib de tu proyecto, crea un entorno virtual, instala las dependencias para flask_api_dieta.py y ejecútalo.
- Abre el simulador en Xcode y conéctalo a tu IDE de Android Studio.
- Conecta el archivo main.dart al servidor ejecutando la API de Flask, modificando esta línea: var url = Uri.parse("http://192.168.100.174:5000/api/predecir");
- Ejecuta el archivo main.dart para ver la aplicación en el simulador.


