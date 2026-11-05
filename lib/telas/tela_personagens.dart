import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../modelos/personagem.dart';
import 'tela_detalhe_personagem.dart';

class TelaPersonagens extends StatefulWidget {
  const TelaPersonagens({super.key});

  @override
  State<TelaPersonagens> createState() => _TelaPersonagensState();
}

class _TelaPersonagensState extends State<TelaPersonagens> {
  late Future<List<Personagem>> _futuro;
  // Exercício 8: filtro de status ('' = todos, 'alive' = vivos, 'dead' = mortos)
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _futuro = buscarPersonagens(); // pede os dados UMA vez, ao abrir a tela
  }

  Future<List<Personagem>> buscarPersonagens() async {
    // Exercício 8: só acrescenta &status=... quando há um filtro escolhido
    final parteStatus = _filtro.isEmpty ? '' : '&status=$_filtro';
    final resposta = await http.get(Uri.parse(
      'https://rickandmortyapi.com/api/character?page=1$parteStatus'));
    if (resposta.statusCode != 200) {
      throw Exception('Falha na consulta: ${resposta.statusCode}');
    }
    final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
    final lista = dados['results'] as List<dynamic>;
    return lista
        .map((item) => Personagem.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  void _recarregar() {
    setState(() { _futuro = buscarPersonagens(); });
  }

  // Exercício 8: troca o filtro e busca de novo (o Future muda DENTRO do setState)
  void _trocarFiltro(String novoFiltro) {
    setState(() {
      _filtro = novoFiltro;
      _futuro = buscarPersonagens();
    });
  }

  // Exercício 8: um ChoiceChip para cada opção do filtro
  Widget _opcaoFiltro(String texto, String valor) => ChoiceChip(
    label: Text(texto),
    selected: _filtro == valor,
    onSelected: (_) => _trocarFiltro(valor),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personagens')),
      body: Column(children: [
        // Exercício 8: opções de filtro acima da lista
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(spacing: 8, children: [
            _opcaoFiltro('Todos', ''),
            _opcaoFiltro('Vivos', 'alive'),
            _opcaoFiltro('Mortos', 'dead'),
          ]),
        ),
        Expanded(child: FutureBuilder<List<Personagem>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar os personagens.'),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _recarregar,
                  child: const Text('Tentar de novo')),
              ]),
            );
          }
          final personagens = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: personagens.length,
            itemBuilder: (context, i) {
              final p = personagens[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(p.imagem)),
                  title: Text(p.nome),
                  subtitle: Text('${p.especie} · ${p.status}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                      TelaDetalhePersonagem(personagem: p))),
                ),
              );
            },
          );
        },
      )),
      ]),
    );
  }
}
