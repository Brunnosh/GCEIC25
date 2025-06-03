import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MultiplierMarkupPage extends StatefulWidget {
  @override
  _MultiplierMarkupPageState createState() => _MultiplierMarkupPageState();
}

class _MultiplierMarkupPageState extends State<MultiplierMarkupPage> {
  final _formKey = GlobalKey<FormState>();
  final _despesasVariaveisController = TextEditingController();
  final _despesasFixasController = TextEditingController();
  final _margemLucroController = TextEditingController();
  String _resultado = '';
  bool _hovering = false;
  bool _carregando = false;

  Future<void> _calcularMarkup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _carregando = true;
        _resultado = '';
      });

      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/MKP2/calcMultiplierMarkup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'despesasVariaveis': double.parse(_despesasVariaveisController.text),
            'despesasFixas': double.parse(_despesasFixasController.text),
            'margemLucro': double.parse(_margemLucroController.text),
          }),
        );

        setState(() {
          if (response.statusCode == 200) {
            _resultado = 'Multiplicador do Markup: ${response.body}';
          } else {
            _resultado = 'Erro ao calcular o markup';
          }
        });
      } catch (e) {
        setState(() {
          _resultado = 'Erro ao conectar com o servidor';
        });
      }

      setState(() => _carregando = false);
    }
  }

  String? _validarCampo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    final numero = double.tryParse(value);
    if (numero == null || numero < 0 || numero > 100) {
      return 'O valor deve estar entre 0 e 100';
    }
    return null;
  }

  Widget _botaoElegante() {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _hovering
                ? [Colors.indigo.shade700, Colors.deepPurple]
                : [Colors.deepPurple, Colors.indigo.shade400],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: TextButton(
          onPressed: _carregando ? null : _calcularMarkup,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _carregando
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : const Text(
                  'Calcular',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _despesasVariaveisController.dispose();
    _despesasFixasController.dispose();
    _margemLucroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text('Calculadora de Markup'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 4,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return Center(
            child: Container(
              width: isWide ? 600 : double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _despesasVariaveisController,
                      decoration: const InputDecoration(
                        labelText: 'Despesas Variáveis (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validarCampo,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _despesasFixasController,
                      decoration: const InputDecoration(
                        labelText: 'Despesas Fixas (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validarCampo,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _margemLucroController,
                      decoration: const InputDecoration(
                        labelText: 'Margem de Lucro (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validarCampo,
                    ),
                    const SizedBox(height: 24),
                    _botaoElegante(),
                    const SizedBox(height: 24),
                    if (_resultado.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.indigo),
                        ),
                        child: Text(
                          _resultado,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
