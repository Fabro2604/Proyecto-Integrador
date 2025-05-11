import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Permitir certificados autofirmados (solo para desarrollo)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides(); // Activar override SSL
  runApp(DietaApp());
}

class DietaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Predicción de Dietas con IA',
      theme: ThemeData(primarySwatch: Colors.green),
      home: InicioScreen(),
    );
  }
}

class InicioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fastfood, size: 100, color: Colors.green.shade700),
              SizedBox(height: 30),
              Text(
                'Bienvenido a la App de Recomendación de Dietas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Recibe recomendaciones de dietas terapéuticas usando inteligencia artificial. ¡Empieza ahora!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DietFormScreen()),
                  );
                },
                icon: Icon(Icons.arrow_forward),
                label: Text('Comenzar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white70,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DietFormScreen extends StatefulWidget {
  @override
  _DietFormScreenState createState() => _DietFormScreenState();
}

class _DietFormScreenState extends State<DietFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController activityController = TextEditingController();
  final TextEditingController sodiumController = TextEditingController();
  final TextEditingController sugarController = TextEditingController();
  final TextEditingController severityController = TextEditingController();

  bool kidneyDisease = false;
  bool hypertension = false;
  bool heartDisease = false;
  bool diabetes = false;
  bool obesity = false;

  Future<void> predecirDieta() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, dynamic> datos = {
          "Activity_Level": double.tryParse(activityController.text) ?? 0,
          "Sodium_mg": double.tryParse(sodiumController.text) ?? 0,
          "Sugar_g": double.tryParse(sugarController.text) ?? 0,
          "Severity": double.tryParse(severityController.text) ?? 0,
          "Kidney Disease": kidneyDisease ? 1 : 0,
          "Hypertension": hypertension ? 1 : 0,
          "Heart Disease": heartDisease ? 1 : 0,
          "Diabetes": diabetes ? 1 : 0,
          "Obesity": obesity ? 1 : 0
        };

        final prettyJson = const JsonEncoder.withIndent('  ').convert(datos);
        print('JSON enviado al servidor:\n$prettyJson');

        var url = Uri.parse("https://192.168.100.146:5000/api/recomendar");
        var respuesta = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(datos),
        );

        if (respuesta.statusCode == 200) {
          var resultado = jsonDecode(respuesta.body);
          if (resultado.containsKey("error")) {
            _mostrarError(resultado["error"]);
          } else {
            String dieta = resultado["dieta"];
            Map<String, dynamic> menu = resultado["menu"];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultadoScreen(
                  dieta: dieta,
                  menuCompleto: menu,
                ),
              ),
            );
          }
        } else {
          _mostrarError("Error HTTP: ${respuesta.statusCode}");
        }
      } catch (e) {
        _mostrarError("Error: $e");
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  String? validarNumero(String? value, String label) {
    if (value == null || value.isEmpty) {
      return 'Ingrese $label';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Ingrese un número válido para $label';
    }
    if(number<=0){
      return 'ingrese un numero valido para $label';
    }
    return null;
  }

  Widget dropdownConAyuda<T>({
    required String label,
    required List<T> opciones,
    required T? valorActual,
    required void Function(T?) onChanged,
    required String ayuda,
    String? Function(T?)? validator,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: DropdownButtonFormField<T>(
            decoration: InputDecoration(labelText: label),
            value: valorActual,
            items: opciones
                .map((opcion) => DropdownMenuItem(
              value: opcion,
              child: Text(opcion.toString()),
            ))
                .toList(),
            onChanged: onChanged,
            validator: validator,
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.help_outline, color: Colors.grey),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('¿Qué significa "$label"?'),
                content: Text(ayuda),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Entendido'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextFieldConAyuda({
    required TextEditingController controller,
    required String label,
    required String ayuda,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: label),
            validator: (value) => validarNumero(value, label),
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.help_outline, color: Colors.grey),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('¿Qué significa "$label"?'),
                content: Text(ayuda),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Entendido'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recomendación de Dieta'), backgroundColor: Colors.green.shade100),
      body: Container(
        decoration: BoxDecoration(color: Colors.green.shade50),
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                dropdownConAyuda<int>(
                  label: "Nivel de Actividad (1 a 5)",
                  opciones: List.generate(5, (i) => i + 1),
                  valorActual: int.tryParse(activityController.text),
                  onChanged: (valor) {
                    if (valor != null) {
                      setState(() {
                        activityController.text = valor.toString();
                      });
                    }
                  },
                  ayuda: "Indica tu nivel diario de actividad física:\n"
                      "1 = sedentario\n2 = ligero\n3 = moderado\n4 = activo\n5 = atleta o entrenamiento intenso",
                  validator: (v) => v == null ? "Seleccione un nivel de actividad" : null,
                ),
                _buildTextFieldConAyuda(controller: sodiumController, label: "Sodio (mg)", ayuda: "Consumo diario de Sodio/Sal recomendado: <2000 mg maximo 2300 mg."),
                _buildTextFieldConAyuda(controller: sugarController, label: "Azúcar (g)", ayuda: "Consumo diario de azucar recomendado: <25 g maximo 34 g."),
                dropdownConAyuda<int>(
                  label: "Severidad de las Enfermedades ",
                  opciones: [0, 1, 2],
                  valorActual: int.tryParse(severityController.text),
                  onChanged: (valor) {
                    if (valor != null) {
                      setState(() {
                        severityController.text = valor.toString();
                      });
                    }
                  },
                  ayuda: "0 = Ninguna\n1 = Leve\n2 = Avanzada",
                  validator: (v) => v == null ? "Seleccione severidad" : null,
                ),
                Divider(),
                CheckboxListTile(title: Text("Kidney Disease"), value: kidneyDisease, onChanged: (v) => setState(() => kidneyDisease = v!)),
                CheckboxListTile(title: Text("Hypertension"), value: hypertension, onChanged: (v) => setState(() => hypertension = v!)),
                CheckboxListTile(title: Text("Heart Disease"), value: heartDisease, onChanged: (v) => setState(() => heartDisease = v!)),
                CheckboxListTile(title: Text("Diabetes"), value: diabetes, onChanged: (v) => setState(() => diabetes = v!)),
                CheckboxListTile(title: Text("Obesity"), value: obesity, onChanged: (v) => setState(() => obesity = v!)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: predecirDieta,
                  child: Text('Predecir Dieta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultadoScreen extends StatefulWidget {
  final String dieta;
  final Map<String, dynamic> menuCompleto;

  ResultadoScreen({required this.dieta, required this.menuCompleto});

  @override
  _ResultadoScreenState createState() => _ResultadoScreenState();
}

class _ResultadoScreenState extends State<ResultadoScreen> {
  Map<String, dynamic>? diaSeleccionado;
  String? nombreDia;

  @override
  void initState() {
    super.initState();
    seleccionarDiaAleatorio();
  }

  void seleccionarDiaAleatorio() {
    var dias = widget.menuCompleto.keys.toList();
    dias.shuffle();
    var dia = dias.first;
    setState(() {
      nombreDia = dia;
      diaSeleccionado = widget.menuCompleto[dia];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dieta: ${widget.dieta}'),
        backgroundColor: Colors.green.shade100,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.green.shade50),
        child: diaSeleccionado == null
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Menú del día: $nombreDia',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text("🥣 Desayuno: ${diaSeleccionado!['Desayuno']}"),
                  Text("🍽 Comida: ${diaSeleccionado!['Comida']}"),
                  Text("🌙 Cena: ${diaSeleccionado!['Cena']}"),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: seleccionarDiaAleatorio,
                    icon: Icon(Icons.refresh),
                    label: Text("Ver otro día"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
