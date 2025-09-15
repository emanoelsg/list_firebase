// test/lib/app/utils/helpers/helper_functions_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/core/common/helpers/helper_functions.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  group('THelperFunctions', () {
  testWidgets('showSnackBar exibe snackbar com mensagem correta', (WidgetTester tester) async {
  // Monta a UI
  await tester.pumpWidget(
    GetMaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  THelperFunctions.showSnackBar('Teste de Snackbar');
                },
                child: Text('Mostrar Snackbar'),
              ),
            );
          },
        ),
      ),
    ),
  );

  
  await tester.tap(find.text('Mostrar Snackbar'));
  await tester.pump(); // roda a animação inicial

  await tester.pump(const Duration(milliseconds: 500));

  
  expect(find.text('Teste de Snackbar'), findsOneWidget);
  expect(find.text('Aviso'), findsOneWidget);

  await tester.pumpAndSettle(const Duration(seconds: 5));
});

    testWidgets('navigateToScreen navega para a tela correta', (WidgetTester tester) async {
      // Tela de teste
      final testScreen = Scaffold(body: Text('Tela de Teste'));

      // Widget inicial com GetMaterialApp
      await tester.pumpWidget(GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  THelperFunctions.navigateToScreen(context, testScreen);
                },
                child: Text('Navegar'),
              );
            },
          ),
        ),
      ));

      // Clica no botão
      await tester.tap(find.text('Navegar'));
      await tester.pumpAndSettle();

      // Verifica se a tela foi exibida
      expect(find.text('Tela de Teste'), findsOneWidget);
    });

    testWidgets('isDarkMode retorna corretamente o tema atual', (WidgetTester tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              result = THelperFunctions.isDarkMode(context);
              return Container();
            },
          ),
        ),
      );

      expect(result, false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              result = THelperFunctions.isDarkMode(context);
              return Container();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(result, true);
    });
  });
}
