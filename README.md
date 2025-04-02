## 📋 Descripción

Este proyecto consiste en el desarrollo de una solución integral para la **recomendación de dietas personalizadas**. Combina modelos de machine learning, una API REST y una aplicación móvil multiplataforma para proporcionar recomendaciones basadas en las características clínicas y preferencias del usuario.

La aplicación ha sido diseñada principalmente para personas con enfermedades crónicas como **obesidad**, **diabetes** o **hipertensión**, mejorando la accesibilidad a planes alimenticios adaptados.

---

## 🚀 Tecnologías utilizadas

- Python (scikit-learn, pandas, numpy, matplotlib)
- TensorFlow / Keras
- Flask (API REST)
- Flutter (Aplicación Móvil Android / iOS)
- joblib (Persistencia de modelos)
- GitHub Actions (opcional para CI/CD)


## To create the app

Once you have downloaded flutter run this comand to create the folder structure: flutter create —org com.yourdomain your_app_name
Then paste the main.dart file into your lib folder in the main.dart file and save both flask_api_dieta.py and rf_feature_selection.pkl in said folder

## To run the app
- Download Android Studio and follow install flutter in it
- You will need Xcode to run the simulator for the app
- Open the terminal in the lib folder of your proyect one create a virtual enviroment and install dependencies for flask_api_dieta.py and run it 
- Open the simulator in Xcode,  conect it to your Android Studio IDE
- Connect the main.dart to the server runing the flask api changing this line var url = Uri.parse("http://192.168.100.174:5000/api/predecir");
- Run the main.dart to see the app in the simulator.


