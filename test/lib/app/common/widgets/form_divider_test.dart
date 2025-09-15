// test/lib/app/common/widgets/form_divider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:list_firebase/app/core/common/widgets/form_divider.dart';
import 'package:list_firebase/app/core/utils/constants/colors.dart';


void main() {
  testWidgets('TFormDivider renderiza corretamente com texto', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TFormDivider(dividerText: 'OU'),
        ),
      ),
    );

    // Verifica se o texto aparece
    expect(find.text('OU'), findsOneWidget);

    // Verifica se existem dois Divider
    expect(find.byType(Divider), findsNWidgets(2));
  });

  testWidgets('TFormDivider muda cor no dark mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: TFormDivider(dividerText: 'OU'),
        ),
      ),
    );

    final Iterable<Divider> dividers = tester.widgetList<Divider>(find.byType(Divider));
    for (final Divider divider in dividers) {
      expect(divider.color, TColors.darkGrey);
    }
  });

  testWidgets('TFormDivider usa cor padrão no light mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: TFormDivider(dividerText: 'OU'),
        ),
      ),
    );

    final Iterable<Divider> dividers = tester.widgetList<Divider>(find.byType(Divider));
    for (final Divider divider in dividers) {
      expect(divider.color, TColors.grey);
    }
  });
}
