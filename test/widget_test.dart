import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:erp_malang/main.dart';
import 'package:erp_malang/data/providers/app_provider.dart';

void main() {
  testWidgets('ERP Malang app loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const ErpMalangApp(),
      ),
    );
    expect(find.text('ERP MALANG'), findsOneWidget);
  });
}
