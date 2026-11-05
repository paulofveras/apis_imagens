import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Exercício 10
import '../modelos/personagem.dart';
import 'tela_detalhe_personagem.dart';

// Exercício 9: a API devolve a lista E o total de páginas (info.pages).
// Escolhi uma classe pequena que guarda os dois juntos: assim o mesmo Future
// entrega tudo o que a tela precisa, sem criar variáveis soltas no estado.
class PaginaPersonagens {
  final List<Personagem> lista;
  final int totalPaginas;
  PaginaPersonagens({required this.lista, required this.totalPaginas});
}

class TelaPersonagens extends StatefulWidget {
  const TelaPersonagens({super.key});

  @override
  State<TelaPersonagens> createState() => _TelaPersonagensState();
}

class _TelaPersonagensState extends State<TelaPersonagens> {
  late Future<PaginaPersonagens> _futuro;
  // Exercício 8: filtro de status ('' = todos, 'alive' = vivos, 'dead' = mortos)
  String _filtro = '';
  // Exercício 9: página atual guardada no estado
  int _pagina = 1;
  // Exercício 10: id do personagem favorito (null = nenhum)
  int? _favoritoId;

  @override
  void initState() {
    super.initState();
    _lerFavorito(); // Exercício 10: lê o favorito salvo ao abrir a tela
    _futuro = buscarPersonagens(); // pede os dados UMA vez, ao abrir a tela
  }

  // Exercício 10: lê o id salvo no aparelho (se não existir, volta null)
  Future<void> _lerFavorito() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { _favoritoId = prefs.getInt('favorito_id'); });
  }

  Future<PaginaPersonagens> buscarPersonagens() async {
    // Exercício 8: só acrescenta &status=... quando há um filtro escolhido
    final parteStatus = _filtro.isEmpty ? '' : '&status=$_filtro';
    final resposta = await http.get(Uri.parse(
      'https://rickandmortyapi.com/api/character?page=$_pagina$parteStatus'));
    if (resposta.statusCode != 200) {
      throw Exception('Falha na consulta: ${resposta.statusCode}');
    }
    final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
    final lista = (dados['results'] as List<dynamic>)
        .map((item) => Personagem.fromMap(item as Map<String, dynamic>))
        .toList();
    // Exercício 9: info.pages diz quantas páginas existem no total
    final totalPaginas = dados['info']['pages'] as int;
    return PaginaPersonagens(lista: lista, totalPaginas: totalPaginas);
  }

  void _recarregar() {
    setState(() { _futuro = buscarPersonagens(); });
  }

  // Exercício 8: troca o filtro e busca de novo (o Future muda DENTRO do setState)
  void _trocarFiltro(String novoFiltro) {
    setState(() {
      _filtro = novoFiltro;
      _pagina = 1; // Exercício 9: ao trocar o filtro, volta para a página 1
      _futuro = buscarPersonagens();
    });
  }

  // Exercício 9: muda de página mantendo o filtro atual
  void _irParaPagina(int novaPagina) {
    setState(() {
      _pagina = novaPagina;
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
        Expanded(child: FutureBuilder<PaginaPersonagens>(
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
          final pagina = snapshot.data!;
          final personagens = pagina.lista;
          // Exercício 9: lista + barra de páginas embaixo
          return Column(children: [
            Expanded(child: ListView.builder(
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
                  // Exercício 10: estrela no personagem favorito
                  trailing: p.id == _favoritoId
                      ? const Icon(Icons.star, color: Colors.amber)
                      : const Icon(Icons.chevron_right),
                  onTap: () async {
                    // Exercício 10: espera voltar do detalhe e atualiza a estrela
                    await Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>
                        TelaDetalhePersonagem(personagem: p)));
                    _lerFavorito();
                  },
                ),
              );
            },
          )),
            // Exercício 9: botões Anterior/Próxima e "Página X de Y"
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    // desabilitado na primeira página
                    onPressed: _pagina > 1
                        ? () => _irParaPagina(_pagina - 1) : null,
                    child: const Text('Anterior')),
                  Text('Página $_pagina de ${pagina.totalPaginas}'),
                  ElevatedButton(
                    // desabilitado na última página
                    onPressed: _pagina < pagina.totalPaginas
                        ? () => _irParaPagina(_pagina + 1) : null,
                    child: const Text('Próxima')),
                ]),
            ),
          ]);
        },
      )),
      ]),
    );
  }
}
