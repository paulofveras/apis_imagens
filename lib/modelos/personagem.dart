class Personagem {
  final int id;
  final String nome;
  final String status;
  final String especie;
  final String origem;
  final String imagem;
  final String genero; // Exercício 7: campo 'gender' do JSON
  final String localizacao; // Exercício 7: campo 'location.name' do JSON

  Personagem({
    required this.id,
    required this.nome,
    required this.status,
    required this.especie,
    required this.origem,
    required this.imagem,
    required this.genero, // Exercício 7
    required this.localizacao, // Exercício 7
  });

  // Converte um item do JSON (Map) em objeto Personagem
  factory Personagem.fromMap(Map<String, dynamic> m) => Personagem(
    id: m['id'],
    nome: m['name'],
    status: m['status'],
    especie: m['species'],
    origem: m['origin']['name'],
    imagem: m['image'],
    genero: m['gender'], // Exercício 7
    localizacao: m['location']['name'], // Exercício 7
  );
}
