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
  // Exercício 2: conta quantas fotos já foram sorteadas com sucesso
  int totalFotos = 0;
  // Exercício 3: raças disponíveis e a raça escolhida (null = qualquer uma)
  final racas = ['hound', 'husky', 'pug', 'beagle'];
  String? racaEscolhida;

  Future<void> buscarCao() async {
    setState(() { carregando = true; erro = null; });
    try {
      // Exercício 3: sem raça marcada usa o endpoint geral; com raça, o da raça
      final endereco = racaEscolhida == null
          ? 'https://dog.ceo/api/breeds/image/random'
          : 'https://dog.ceo/api/breed/$racaEscolhida/images/random';
      final resposta = await http.get(Uri.parse(endereco));
      if (resposta.statusCode != 200) throw Exception('Falha na consulta');
      final dados = jsonDecode(resposta.body);
      if (!mounted) return;
      setState(() {
        imagem = dados['message'];
        totalFotos++; // Exercício 2: só soma quando a foto chegou com sucesso
      });
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
        // Exercício 3: escolha da raça com ChoiceChip dentro de um Wrap
        Wrap(
          spacing: 8,
          children: racas.map((raca) => ChoiceChip(
            label: Text(raca),
            selected: racaEscolhida == raca,
            // tocar de novo na raça marcada desmarca (volta ao aleatório)
            onSelected: (marcada) =>
              setState(() { racaEscolhida = marcada ? raca : null; }),
          )).toList(),
        ),
        const SizedBox(height: 16),
        // Exercício 2: mostra o contador na tela
        Text('Fotos sorteadas: $totalFotos'),
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
