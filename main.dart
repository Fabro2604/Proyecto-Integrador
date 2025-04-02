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
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController colesterolController = TextEditingController();
  final TextEditingController glucosaController = TextEditingController();
  final TextEditingController adherenceController = TextEditingController();

  String enfermedad = 'None';
  String cocinaPreferida = 'Mexican';

  Future<void> predecirDieta() async {
    if (_formKey.currentState!.validate()) {
      double peso = double.tryParse(pesoController.text) ?? 0;
      double altura = (double.tryParse(alturaController.text) ?? 0) / 100;
      double bmi = peso / (altura * altura);
      double adherence = double.tryParse(adherenceController.text) ?? 0;

      if (peso <= 0 || altura <= 0 || adherence < 0 || adherence > 1) {
        _mostrarError("Peso, altura o adherencia inválidos.");
        return;
      }

      Map<String, dynamic> datos = {
        "Disease_Type": enfermedad,
        "Preferred_Cuisine": cocinaPreferida,
        "Glucose_mg/dL": glucosaController.text,
        "BMI": bmi.toStringAsFixed(2),
        "Cholesterol_mg/dL": colesterolController.text,
        "Adherence_to_Diet_Plan": adherenceController.text,
        "Height_cm": alturaController.text
      };

      print("✅ Datos enviados a Flask:");
      print(jsonEncode(datos));

      try {
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
            List recetas = resultado["recetas"] ?? [];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultadoScreen(
                  dieta: dieta,
                  recetas: recetas,
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

  Widget _buildTextField(TextEditingController controller, String label, {bool isDecimal = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isDecimal ? TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingrese $label';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Predicción de Dieta con IA')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(pesoController, "Peso (kg)", isDecimal: true),
                _buildTextField(alturaController, "Altura (cm)", isDecimal: true),
                _buildTextField(adherenceController, "Adherencia (0-1)", isDecimal: true),
                _buildTextField(edadController, "Edad"),
                _buildTextField(colesterolController, "Colesterol (mg/dL)", isDecimal: true),
                _buildTextField(glucosaController, "Glucosa (mg/dL)", isDecimal: true),

                DropdownButtonFormField<String>(
                  value: enfermedad,
                  decoration: InputDecoration(labelText: "Enfermedad"),
                  items: ["None", "Diabetes", "Obesity", "Hypertension"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => enfermedad = value!),
                ),

                DropdownButtonFormField<String>(
                  value: cocinaPreferida,
                  decoration: InputDecoration(labelText: "Cocina preferida"),
                  items: ["Mexican", "Italian", "Chinese", "Indian"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => cocinaPreferida = value!),
                ),

                SizedBox(height: 20),
                ElevatedButton(onPressed: predecirDieta, child: Text('Predecir Dieta')),
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
  final List recetas;

  ResultadoScreen({required this.dieta, required this.recetas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resultado de Dieta')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Dieta recomendada: $dieta',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }
}








