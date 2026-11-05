import 'package:flutter_test/flutter_test.dart';
import 'package:apis_imagens/main.dart';

void main() {
  // Teste simples: abre o app e confere os botões da Home (sem usar a rede)
  testWidgets('Home mostra os botões', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());

    expect(find.text('Galeria de cães'), findsOneWidget);
    expect(find.text('Pokédex'), findsOneWidget);
  });
}
