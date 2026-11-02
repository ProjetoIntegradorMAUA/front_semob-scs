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
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Financeiro'));
    await tester.pumpAndSettle();

    expect(find.text('Indicadores Financeiros'), findsOneWidget);
  });
}
