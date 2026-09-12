import 'package:d3tv_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('affiche les 4 onglets et navigue vers Direct',
      (tester) async {
    await tester.pumpWidget(const D3tvApp());

    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.text('Bienvenue sur D3TV'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Direct'));
    await tester.pump();

    expect(find.byType(LiveTab), findsOneWidget);
  });
}
