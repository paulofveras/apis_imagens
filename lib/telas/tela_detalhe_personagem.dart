import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Exercício 10
import '../modelos/personagem.dart';

// Exercício 10: virou StatefulWidget para guardar se é favorito
class TelaDetalhePersonagem extends StatefulWidget {
  final Personagem personagem;
  const TelaDetalhePersonagem({super.key, required this.personagem});

  @override
  State<TelaDetalhePersonagem> createState() => _TelaDetalhePersonagemState();
}

class _TelaDetalhePersonagemState extends State<TelaDetalhePersonagem> {
  bool _favorito = false;

  // Atalho: assim o resto do código continua usando "personagem"
  Personagem get personagem => widget.personagem;

  @override
  void initState() {
    super.initState();
    _lerFavorito();
  }

  // Exercício 10: este personagem é o favorito salvo?
  Future<void> _lerFavorito() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { _favorito = prefs.getInt('favorito_id') == personagem.id; });
  }

  // Exercício 10: marca (salva só o id) ou desmarca (remove)
  Future<void> _alternarFavorito() async {
    final prefs = await SharedPreferences.getInstance();
    if (_favorito) {
      await prefs.remove('favorito_id');
    } else {
      await prefs.setInt('favorito_id', personagem.id);
    }
    if (!mounted) return;
    setState(() { _favorito = !_favorito; });
  }

  Color _corStatus() {
    switch (personagem.status) {
      case 'Alive': return Colors.green;
      case 'Dead': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(personagem.nome)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(personagem.imagem,
              width: 240, height: 240, fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                const Icon(Icons.broken_image, size: 120)),
          ),
          const SizedBox(height: 16),
          Text(personagem.nome,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Chip(
            avatar: Icon(Icons.circle, size: 12, color: _corStatus()),
            label: Text(personagem.status),
          ),
          const SizedBox(height: 8),
          // Exercício 10: botão de favorito
          ElevatedButton.icon(
            onPressed: _alternarFavorito,
            icon: Icon(_favorito ? Icons.star : Icons.star_border),
            label: Text(_favorito ? 'Desmarcar favorito' : 'Marcar favorito')),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Espécie'),
            subtitle: Text(personagem.especie)),
          ListTile(
            leading: const Icon(Icons.public),
            title: const Text('Origem'),
            subtitle: Text(personagem.origem)),
          // Exercício 7: gênero e localização no detalhe
          ListTile(
            leading: const Icon(Icons.wc),
            title: const Text('Gênero'),
            subtitle: Text(personagem.genero)),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Localização'),
            subtitle: Text(personagem.localizacao)),
          ListTile(
            leading: const Icon(Icons.tag),
            title: const Text('ID'),
            subtitle: Text('${personagem.id}')),
        ]),
      ),
    );
  }
}
