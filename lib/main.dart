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
  String? lastPressedMessage = 'No button pressed yet';
  String? toggledMessage = 'No toggles selected';

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
                color: Colors.black.withValues(alpha: 0.25),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Test area',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                // Placeholder for message
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 + 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lastPressedMessage ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        toggledMessage ?? '',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: ElevatedButton.icon(
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
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reset Panel Position'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // The actual draggable panel
          DraggableButtonPanel(
            key: panelKey,
            width: 50,
            buttonColor: Colors.blue,
            collapseOpacity: 0.5,
            toggleMode: ToggleSelectionMode.multiple,
            onMenuExpand: (toggleEntry) {
              setState(() {
                lastPressedMessage =
                    'Menu expanded for button index ${toggleEntry.index}, id: ${toggleEntry.id}';
              });
            },
            onTogglesChanged: (entries) {
              // Print both indices and optional ids for easy debugging
              setState(() {
                toggledMessage = entries.isEmpty
                    ? 'No toggles selected'
                    : 'Toggled: ' +
                        entries
                            .map((e) => '(${e.index}, id: ${e.id})')
                            .join(', ');
              });
            },
            onPositionChanged: (offset) {
              // Optionally save the last position for testing
              savedOffset = offset;
              savedDockLeft =
                  panelKey.currentState?.isDockedLeft ?? savedDockLeft;
            },
            children: [
              // Row 0: expandable with two options
              PanelButton(
                tooltip: 'Menu',
                id: PanelBtnId.menu,
                icon: const Icon(Icons.menu_open_rounded, color: Colors.white),
                backgroundColor: Colors.redAccent,
                options: [
                  OptionButton(
                      tooltip: 'Checklist',
                      icon: Icon(Icons.checklist, color: Colors.white),
                      backgroundColor: Colors.redAccent,
                      onPressed: () {
                        setState(() {
                          lastPressedMessage = 'Checklist pressed';
                        });
                      }),
                  OptionButton(
                      tooltip: 'Add',
                      icon: Icon(Icons.add, color: Colors.white),
                      backgroundColor: Colors.redAccent,
                      onPressed: () {
                        setState(() {
                          lastPressedMessage = 'Add pressed';
                        });
                      }),
                ],
              ),

              // Row 1: expandable with three options and custom widths
              PanelButton(
                tooltip: 'Favorites',
                id: 42,
                // int id example
                icon: const Icon(Icons.favorite, color: Colors.white),
                backgroundColor: Colors.pinkAccent,
                options: [
                  OptionButton(
                      tooltip: 'Like',
                      icon: Icon(Icons.favorite_border, color: Colors.white),
                      backgroundColor: Colors.pinkAccent,
                      width: 50,
                      onPressed: () {
                        setState(() {
                          lastPressedMessage = 'Heart pressed';
                        });
                      }),
                  OptionButton(
                      icon: Icon(Icons.comment, color: Colors.white),
                      tooltip: 'Comment',
                      backgroundColor: Colors.pinkAccent,
                      width: 70,
                      onPressed: () {
                        setState(() {
                          lastPressedMessage = 'Comment pressed';
                        });
                      }),
                  OptionButton(
                      tooltip: 'Share',
                      icon: Icon(Icons.share, color: Colors.white),
                      backgroundColor: Colors.pinkAccent,
                      width: 50,
                      onPressed: () {
                        setState(() {
                          lastPressedMessage = 'Share pressed';
                        });
                      }),
                  OptionButton(
                      tooltip: 'Delete',
                      icon: Icon(Icons.delete_outline, color: Colors.white),
                      backgroundColor: Colors.pinkAccent,
                      width: 50,
                      onPressed: () {
                        setState(() {
                          lastPressedMessage = 'Delete pressed';
                        });
                      }),
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
    );
  }
}
