import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:draggable_button_panel/draggable_button_panel.dart';

void main() {
  testWidgets('DraggableButtonPanel changes position when dragged',
          (WidgetTester tester) async {
        final widget = DraggableButtonPanel(
          top: 50,
          left: 10,
          buttonSize: 55,
          panelColor: Colors.white,
          buttonColor: Colors.blue,
          collapseOpacity: 0.8,
          options: [
            IconButton(
              icon: const Icon(Icons.ac_unit),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.beach_access),
              onPressed: () {},
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byIcon(Icons.menu_open_rounded), findsOneWidget);

        // Drag the widget to a new position
        final gesture = await tester.startGesture(const Offset(100, 100));
        await tester.pump();
        await gesture.moveTo(const Offset(150, 150));
        await tester.pumpAndSettle();

        // Check that the position has changed
        expect(widget.top, 200);
        expect(widget.left, 60);
      });
}