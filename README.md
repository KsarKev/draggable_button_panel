# Draggable Button Panel

Vertical draggable and dockable panel (left/right) composed of rows of buttons.
Each row (PanelButton) can either expand to display horizontal options,
or function as a toggle (on/off) if it has no options.

## Overview

![](https://github.com/KsarKev/draggable_button_panel/blob/main/lib/assets/gifs/demo.gif?raw=true)

## Key Features
- Vertical drag with auto-dock to the left or right edge of the screen.
- Per-button animation: only the clicked row expands (others remain unchanged).
- Options (OptionButton) slide out from behind the PanelButton.
- Toggle mode for rows without options, with single or multiple selection.
- onTogglesChanged event emits the list of active items (index + optional id).
- Contextual rounded corners: parent rounded on the free side; only the first/last PanelButton have rounded corners; for options, only the furthest element is vertically rounded.
- Visual feedback during drag accurately reflects the current state (orientation, colors, expansions, toggles).

## Installation

Add `draggable_button_panel` to your `pubspec.yaml` then run `flutter pub get`.

```yaml
dependencies:
  draggable_button_panel: ^1.0.0-dev.3
```

Then import the package:

```dart
import 'package:draggable_button_panel/draggable_button_panel.dart';
```

## Quick API

### ToggleSelectionMode
- `single`: only one toggleable button can be active at a time.
- `multiple`: several can be active.

### OptionButton
Represents an option that unfolds horizontally.
- `icon` (Icon) required
- `label` (String?) optional (informal)
- `tooltip` (String?) tooltip shown on hover (desktop/web) or long press (mobile)
- `onPressed` (VoidCallback?)
- `color`, `backgroundColor` (Color?)
- `width` (double?) horizontal size (default 50)

### PanelButton
Main row of the panel; two uses:
- with `options`: the row expands to show `OptionButton`s.
- without `options` + `toggleable: true`: acts as an on/off button.

Main properties:
- `icon`, `label`, `tooltip`, `onPressed`, `color`, `backgroundColor`
- `width`, `height` (default 50)
- `options` (List<OptionButton>)
- `toggleable` (bool, default false)
- `initiallyToggled` (bool, default false)
- `id` (Object?) free identifier (int/String recommended) used in events.

### DraggableButtonPanel
- `children` (List<PanelButton>)
- `width` (double) square size of a row (also used as default for options)
- `buttonColor` (Color) default color for buttons
- `collapseOpacity` (double) opacity of inactive rows (0–1)
- `toggleMode` (ToggleSelectionMode)
- `onTogglesChanged` (ValueChanged<List<ToggleEntry>>?) emits active states
- `onPositionChanged` (ValueChanged<Offset>?) notifies position (left, top) after drag or programmatic change
- `onMenuExpand` (ValueChanged<ToggleEntry>?) called when a row with options expands (emits index + optional id)
- `top` (double) vertical position of the panel (mutable to persist position)
- `left` (double) [DEPRECATED] horizontal position is no longer used for layout; side is determined by docking (left/right)

### ToggleEntry
Structure emitted in `onTogglesChanged`:
- `index` (int): position of the row in `children`.
- `id` (Object?): optional identifier provided on the `PanelButton`.

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:draggable_button_panel/draggable_button_panel.dart';

enum PanelBtnId { todo, add, menu }

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: Center(
        child: DraggableButtonPanel(
          width: 50,
          buttonColor: Colors.blue,
          collapseOpacity: 0.5,
          toggleMode: ToggleSelectionMode.multiple,
          onTogglesChanged: (entries) {
            // entries: list of ToggleEntry (index + optional id)
            debugPrint(entries.toString());
          },
          children: [
            // 1) Row with options that unfold
            PanelButton(
              id: PanelBtnId.menu,
              icon: const Icon(Icons.menu_open_rounded, color: Colors.white),
              backgroundColor: Colors.redAccent,
              tooltip: 'Menu',
              options: const [
                OptionButton(icon: Icon(Icons.checklist), tooltip: 'My checklist'),
                OptionButton(icon: Icon(Icons.add), tooltip: 'Add'),
              ],
            ),
            // 2) Toggleable row (no options)
            const PanelButton(
              id: PanelBtnId.add,
              toggleable: true,
              initiallyToggled: false,
              icon: Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
```

## Integration Tips
- If you want to maintain the position between frequent rebuilds, use a `GlobalKey<DraggableButtonPanelState>` to read/write `top`/`left` from the current state.
- The visual width of the panel is fixed (based on the max width of the options) to avoid shifts when a row expands; only the clicked row is animated.
- The rounded corners adjust automatically according to the docking side.

## Persisting and Restoring Position
You can listen to the position via `onPositionChanged` and reapply it later using the public methods of the state:

```dart
class MyPageState extends State<MyPage> {
  final panelKey = GlobalKey<DraggableButtonPanelState>();
  Offset? savedOffset;
  bool savedDockLeft = true; // default to left

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DraggableButtonPanel(
          key: panelKey,
          onPositionChanged: (offset) {
            // Save (e.g. in your state, provider, prefs...)
            savedOffset = offset;
            savedDockLeft = panelKey.currentState?.isDockedLeft ?? savedDockLeft;
          },
          children: const [ /* ... */ ],
        ),
        Positioned(
          bottom: 24, left: 24,
          child: FilledButton(
            onPressed: () {
              final state = panelKey.currentState;
              if (state == null) return;
              // Restore the last known position/docking
              state.setPanelPosition(
                top: savedOffset?.dy,
                dockLeft: savedDockLeft,
              );
            },
            child: const Text('Restore position'),
          ),
        ),
      ],
    );
  }
}
```

Useful API in the state:
- `panelOffset` -> Current Offset(left, top)
- `isDockedLeft` -> bool indicating the side
- `setPanelPosition({double? top, bool? dockLeft, bool clampToScreen = true})` -> to apply a position relative to the parent.

## License
BSD 3-Clause License

Copyright (c) 2023–2025, KSɅRKΞV

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.
