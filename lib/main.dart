import 'package:flutter/material.dart';
import 'draggable_button_panel.dart';

/// Simple debug/demo app for DraggableButtonPanel.
///
/// Run with: flutter run -t lib/main.dart
void main() {
  runApp(const DebugApp());
}

enum PanelBtnId { menu, favorite, add }

class DebugApp extends StatelessWidget {
  const DebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Draggable Button Panel – Debug',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const DebugHomePage(),
    );
  }
}

class DebugHomePage extends StatefulWidget {
  const DebugHomePage({super.key});

  @override
  State<DebugHomePage> createState() => _DebugHomePageState();
}

class _DebugHomePageState extends State<DebugHomePage> {
  // Optionally keep a key to read/adjust top/left from the state during tests
  final panelKey = GlobalKey<DraggableButtonPanelState>();
  Offset? savedOffset;
  bool savedDockLeft = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draggable Button Panel – Debug'),
      ),
      backgroundColor: Colors.deepPurpleAccent,
      body: Stack(
        children: [
          // Hints overlay
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Tip: Drag the panel vertically and release\n'
                  'near an edge to “dock” it left or right.\n'
                  'Tap a row with options to expand them.\n'
                  'Toggleable rows have no options and switch to 1.0 opacity when active.',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Center placeholder content
          const Center(
            child: Text(
              'Test area',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          // The actual draggable panel
          DraggableButtonPanel(
            key: panelKey,
            width: 50,
            buttonColor: Colors.blue,
            collapseOpacity: 0.5,
            toggleMode: ToggleSelectionMode.multiple,
            onTogglesChanged: (entries) {
              // Print both indices and optional ids for easy debugging
              debugPrint('Toggles changed: ' +
                  entries.map((e) => '(${e.index}, id: ${e.id})').join(', '));
            },
            onPositionChanged: (offset) {
              // Optionally save the last position for testing
              savedOffset = offset;
              savedDockLeft = panelKey.currentState?.isDockedLeft ?? savedDockLeft;
            },
            children: [
              // Row 0: expandable with two options
              PanelButton(
                id: PanelBtnId.menu,
                icon: const Icon(Icons.menu_open_rounded, color: Colors.white),
                backgroundColor: Colors.redAccent,
                options: const [
                  OptionButton(icon: Icon(Icons.checklist, color: Colors.white),
                      backgroundColor: Colors.redAccent),
                  OptionButton(icon: Icon(Icons.add, color: Colors.white),
                      backgroundColor: Colors.redAccent),
                ],
              ),

              // Row 1: expandable with three options and custom widths
              PanelButton(
                id: 42, // int id example
                icon: const Icon(Icons.favorite, color: Colors.white),
                backgroundColor: Colors.pinkAccent,
                options: [
                  OptionButton(
                      icon: Icon(Icons.favorite_border, color: Colors.white),
                      backgroundColor: Colors.pinkAccent,
                      width: 44,
                      onPressed: () {
                        print('Heart pressed');
                      }),
                  OptionButton(icon: Icon(Icons.share, color: Colors.white),
                      backgroundColor: Colors.pinkAccent,
                      width: 50),
                  OptionButton(
                      icon: Icon(Icons.delete_outline, color: Colors.white),
                      backgroundColor: Colors.pinkAccent,
                      width: 56),
                ],
              ),

              // Row 2: toggleable (no options), initially inactive
              const PanelButton(
                id: 'add-toggle',
                // String id example
                toggleable: true,
                initiallyToggled: false,
                icon: Icon(Icons.add, color: Colors.white),
                backgroundColor: Colors.green,
              ),

              // Row 3: toggleable and initially active
              const PanelButton(
                id: PanelBtnId.favorite,
                toggleable: true,
                initiallyToggled: true,
                icon: Icon(Icons.star, color: Colors.white),
                backgroundColor: Colors.amber,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final state = panelKey.currentState;
          if (state == null) return;
          setState(() {
            state.setPanelPosition(
              top: 50,
              dockLeft: false,
            );
          });
        },
        icon: const Icon(Icons.vertical_align_bottom),
        label: const Text('Reset Panel Position'),
      ),
    );
  }
}
