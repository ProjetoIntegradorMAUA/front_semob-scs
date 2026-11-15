import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navbar/main.dart';

void main() {
  testWidgets('App abre na tela Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Dashboard de Operação'), findsOneWidget);
    expect(find.text('Base demonstrativa validada'), findsWidgets);
  });

  testWidgets('Menu mobile navega para Financeiro', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-3')));
    await tester.pumpAndSettle();

    expect(find.text('Indicadores Financeiros'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Todas as páginas renderizam sem overflow no celular',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    const pageTitles = <int, String>{
      0: 'Dashboard de Operação',
      1: 'Operação da Frota',
      2: 'Análise de Passageiros',
      3: 'Indicadores Financeiros',
      4: 'Alertas Operacionais',
      5: 'Relatórios Gerenciais',
      6: 'Configurações',
    };

    for (final entry in pageTitles.entries) {
      if (entry.key != 0) {
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey('nav-${entry.key}')));
        await tester.pumpAndSettle();
      }

      expect(find.text(entry.value), findsOneWidget,
          reason: 'Página ${entry.key} não foi exibida.');
    }
  });
}
