import 'package:flutter_test/flutter_test.dart';

import 'package:tv_stream/main.dart';

void main() {
  testWidgets('renders the TV Stream shell', (WidgetTester tester) async {
    await tester.pumpWidget(const TvStreamApp());
    await tester.pump();

    expect(find.text('TV STREAM'), findsOneWidget);
    expect(find.text('شاهد مصادرك الرسمية'), findsOneWidget);
  });
}
