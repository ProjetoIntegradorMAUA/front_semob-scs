import 'package:flutter_test/flutter_test.dart';
import 'package:navbar/main.dart';

void main() {
  testWidgets('App abre na tela Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Dashboard de Operação'), findsOneWidget);
  });
}
