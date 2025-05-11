## 📋 Descripción

Este proyecto consiste en el desarrollo de una solución integral para la **recomendación de dietas personalizadas**. Combina modelos de machine learning, una API REST y una aplicación móvil multiplataforma para proporcionar recomendaciones basadas en las características clínicas y preferencias del usuario.

La aplicación ha sido diseñada principalmente para personas con enfermedades crónicas como **obesidad**, **diabetes** o **hipertensión**, **etc.**, mejorando la accesibilidad a planes alimenticios adaptados.

---

## 🚀 Tecnologías utilizadas

- Python (scikit-learn, pandas, numpy, matplotlib)
- TensorFlow / Keras
- Flask (API REST)
- Flutter (Aplicación Móvil Android / iOS)
- joblib (Persistencia de modelos)

---

## Para crear la app

- Para descargar Flutter, sigue las instrucciones de este video: https://www.youtube.com/watch?v=QG9bw4rWqrg&t=900s

Una vez descargado Flutter, ejecuta este comando para crear la estructura de carpetas:


```bash
flutter create --org com.yourdomain your_app_name
```


Luego, reemplaza los archivos y carpetas con los que se tienen en este repositorio: `lib`, `ios`, `macos`, `android`, y los archivos `pubspec.yaml` y `pubspec.lock`.

---

## Para correr la APP

- Descarga Android Studio e instala Flutter.
- Necesitarás Xcode para ejecutar el simulador de la aplicación.
- Abre la terminal en la carpeta `lib` de tu proyecto, crea un entorno virtual e instala las siguientes dependencias:

```bash
pip install flask joblib scikit-learn pandas numpy tensorflow
```

- Corre el servidor con:

```bash
python flask_api_dieta.py
```

- Abre el simulador en Xcode y conéctalo a tu IDE de Android Studio.
- Conecta el archivo `main.dart` al servidor ejecutando la API de Flask, modificando esta línea:

```dart
var url = Uri.parse("https://TU_IP_LOCAL:5000/api/recomendar");
```

- En la carpeta `lib`, ejecuta este comando para generar un certificado autofirmado:

```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/CN=TU_IP_LOCAL" -addext "subjectAltName=IP:TU_IP_LOCAL"
```

- Copia el archivo `cert.pem` a un archivo `.crt` con:

```bash
cp cert.pem flask_cert.crt
```

- En la carpeta donde creaste `flask_cert.crt`, ejecuta:

```bash
python3 -m http.server 8000
```

- En el simulador, abre Safari y navega a:

```
http://TU_IP_LOCAL:8000/flask_cert.crt
```

Reemplaza `TU_IP_LOCAL` con la IP local obtenida con `ipconfig getifaddr en0`.

- Esto mostrará una pantalla de descarga para el certificado, da clic en "Allow".
- Abre la app de configuración del simulador y navega a:

```
Settings > General > VPN & Device Management > Downloaded Profile > flask_cert.crt
```

e instala el certificado.

- Luego ve a:

```
Settings > General > About > Certificate Trust Settings
```

y activa el interruptor de confianza para `flask_cert.crt`.

- Finalmente, ejecuta el archivo `main.dart` para ver la aplicación en el simulador.
