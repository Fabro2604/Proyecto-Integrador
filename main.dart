import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(DietaApp());
}

class DietaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Predicción de Dietas con IA',
      theme: ThemeData(primarySwatch: Colors.green),
      home: DietFormScreen(),
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

  // Enfermedades seleccionadas
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

        print("\u2705 Datos enviados a Flask:\n" + jsonEncode(datos));

        var url = Uri.parse("http://192.168.100.174:5000/api/predecir");
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
            String dieta = resultado["dieta"].toString();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultadoScreen(dieta: dieta),
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
      value == null || value.isEmpty ? 'Ingrese $label' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recomendación de Dieta con IA')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(activityController, "Nivel de Actividad (numérico)"),
                _buildTextField(sodiumController, "Sodio (mg)"),
                _buildTextField(sugarController, "Azúcar (g)"),
                _buildTextField(severityController, "Severidad (numérica)"),
                Divider(),
                CheckboxListTile(
                    title: Text("Kidney Disease"),
                    value: kidneyDisease,
                    onChanged: (v) => setState(() => kidneyDisease = v!)),
                CheckboxListTile(
                    title: Text("Hypertension"),
                    value: hypertension,
                    onChanged: (v) => setState(() => hypertension = v!)),
                CheckboxListTile(
                    title: Text("Heart Disease"),
                    value: heartDisease,
                    onChanged: (v) => setState(() => heartDisease = v!)),
                CheckboxListTile(
                    title: Text("Diabetes"),
                    value: diabetes,
                    onChanged: (v) => setState(() => diabetes = v!)),
                CheckboxListTile(
                    title: Text("Obesity"),
                    value: obesity,
                    onChanged: (v) => setState(() => obesity = v!)),
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

class ResultadoScreen extends StatelessWidget {
  final String dieta;
  ResultadoScreen({required this.dieta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resultado de Dieta')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Dieta recomendada: $dieta',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Regresar')),
            ],
          ),
        ),
      ),
    );
  }
}

