import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TelaCaes extends StatefulWidget {
  const TelaCaes({super.key});

  @override
  State<TelaCaes> createState() => _TelaCaesState();
}

class _TelaCaesState extends State<TelaCaes> {
  String? imagem;
  String? erro;
  bool carregando = false;

  Future<void> buscarCao() async {
    setState(() { carregando = true; erro = null; });
    try {
      final resposta = await http.get(
        Uri.parse('https://dog.ceo/api/breeds/image/random'));
      if (resposta.statusCode != 200) throw Exception('Falha na consulta');
      final dados = jsonDecode(resposta.body);
      if (!mounted) return;
      setState(() { imagem = dados['message']; });
    } catch (e) {
      if (!mounted) return;
      setState(() { erro = 'Não foi possível carregar a foto.'; });
    } finally {
      if (mounted) setState(() { carregando = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    // Exercício 1: cor de fundo do Scaffold personalizada
    backgroundColor: Colors.amber.shade50,
    // Exercício 1: título da AppBar personalizado
    appBar: AppBar(title: const Text('Meus Amigos de Quatro Patas')),
    body: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Toque para descobrir um cachorro!'),
        const SizedBox(height: 16),
        // Exercício 1: frase acima da imagem
        const Text('Cada foto é uma surpresa fofa!',
          style: TextStyle(fontStyle: FontStyle.italic)),
        const SizedBox(height: 16),
        if (carregando) const CircularProgressIndicator(),
        if (erro != null) Text(erro!),
        if (imagem != null) ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(imagem!, height: 260, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Text('Imagem indisponível'))),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: carregando ? null : buscarCao,
          // Exercício 1: texto do botão alterado
          child: const Text('Quero ver outro cão!')),
      ]),
    )),
  );
}
