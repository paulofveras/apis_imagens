# APIs Divertidas em Flutter

- **Aluno:** Paulo Fernando Mourão Veras Filho
- **Disciplina:** Programação para Dispositivos Móveis I (PDM I) – UNITINS – 2026/2
- **Professora:** Madianita Bogo

App Flutter com uma Home e três telas que consomem APIs públicas.

## APIs usadas

| Tela | API |
|------|-----|
| Galeria de cães | https://dog.ceo/api/breeds/image/random (e https://dog.ceo/api/breed/{raca}/images/random) |
| Pokédex | https://pokeapi.co/api/v2/pokemon/{nome ou número} |
| Personagens | https://rickandmortyapi.com/api/character?page=1 |

## Estrutura de pastas

```
apis_imagens/
├── lib/
│   ├── main.dart                          # Home com os três botões
│   ├── modelos/
│   │   └── personagem.dart                # Classe Personagem (fromMap)
│   └── telas/
│       ├── tela_caes.dart                 # Galeria de cães
│       ├── tela_pokemon.dart              # Pokédex
│       ├── tela_personagens.dart          # Lista de personagens
│       └── tela_detalhe_personagem.dart   # Detalhe do personagem
├── test/
│   └── widget_test.dart                   # Confere os botões da Home
├── android/app/src/main/AndroidManifest.xml  # Permissão INTERNET
└── pubspec.yaml                           # Pacotes: http e shared_preferences
```

## Como rodar

```bash
flutter pub get
flutter run
```

## Exercícios

### Galeria de cães
- [x] **1. Personalize:** mudei o título da AppBar, a cor de fundo, o texto do botão e coloquei uma frase acima da imagem.
- [x] **2. Contador:** um contador de fotos sorteadas, que só aumenta (com `setState`) quando a foto chega com sucesso.
- [x] **3. Escolha a raça:** quatro raças em `ChoiceChip` dentro de um `Wrap`; o sorteio usa o endpoint da raça ou o geral se nenhuma estiver marcada.

### Pokédex
- [x] **4. ID e Card:** mostra o ID (ex.: #25) e coloca todo o resultado dentro de um `Card`.
- [x] **5. Pokémon aleatório:** botão que sorteia de 1 a 151, coloca no campo e chama `buscarPokemon()`.
- [x] **6. Tipos:** os tipos aparecem como `Chip` dentro de um `Wrap`.

### Personagens
- [x] **7. Mais dados no detalhe:** a classe `Personagem` ganhou `genero` e `localizacao`, mostrados na tela de detalhe.
- [x] **8. Filtro por status:** opções Todos, Vivos e Mortos acima da lista; a URL recebe `&status=alive` ou `&status=dead` e a página volta para 1.
- [x] **9. Próxima página:** botões Anterior e Próxima, "Página X de Y" usando `info.pages`, funcionando junto com o filtro.
- [x] **10. Favorito que não some:** botão de favorito no detalhe salvo com `shared_preferences` (só o id); a lista mostra uma estrela no favorito.
