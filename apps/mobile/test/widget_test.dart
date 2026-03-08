import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tms_mobile/app/app.dart';
import 'package:tms_mobile/widgets/tms_ui.dart';

void main() {
  testWidgets('renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TmsApp());
    await tester.pumpAndSettle();

    expect(find.byType(TmsLogo), findsWidgets);
    expect(find.widgetWithText(FilledButton, '대시보드 입장'), findsOneWidget);
  });
}
