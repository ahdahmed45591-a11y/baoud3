import 'package:d3tv_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('affiche les 4 onglets et navigue vers Direct depuis le hero',
      (tester) async {
    await tester.pumpWidget(const D3tvApp());

    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.text('La chaîne malienne du cœur'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Voir le Direct'));
    await tester.pump();

    expect(find.byType(LiveTab), findsOneWidget);
  });

  testWidgets('le tiroir donne acces au calendrier et a la presentation',
      (tester) async {
    await tester.pumpWidget(const D3tvApp());

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Calendrier des programmes'), findsOneWidget);

    await tester.tap(find.text('Présentation & contact'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutTab), findsOneWidget);
  });

  testWidgets('programme groupe les emissions par categorie',
      (tester) async {
    await tester.pumpWidget(const D3tvApp());

    await tester.tap(find.widgetWithText(NavigationDestination, 'Programmes'));
    await tester.pumpAndSettle();

    expect(find.text('Émissions'), findsOneWidget);
    expect(find.text('Concerts'), findsOneWidget);
    expect(find.text('Journal du matin'), findsOneWidget);
  });
}
