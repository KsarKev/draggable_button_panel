# Draggable Button Panel

## Description
The DraggableButtonPanel is a widget that displays a panel with a button that can be moved around the screen.
When the button is clicked, it triggers an animation that brings up a side panel containing a list of options.

The panel is initially closed and appears with a reduced opacity.
When the button is clicked, the panel opens with a fade-in animation. The panel is displayed to the left or right of the button, depending on its initial position on the screen.

The panel contains a list of options in the form of icons, which can be customized by the user.
The icons are arranged horizontally in the panel. When an option is selected, a corresponding action can be triggered.

The panel and button are customizable in terms of color, size and opacity.
Properties such as options, buttonSize, panelColor, buttonColor and collapseOpacity allow you to customize the appearance and behavior of the DraggableButtonPanel.

The DraggableButtonPanel is implemented using Flutter features such as StatefulWidget, AnimationController, AnimatedOpacity, Stack and Positioned, to manage the state of the panel, perform animations and properly arrange the elements on the screen.

In summary, the DraggableButtonPanel is a handy widget for displaying a draggable button with a side panel of options in a Flutter application.

## Short Demo

![](https://github.com/KsarKev/draggable_button_panel/blob/main/lib/assets/gifs/demo.gif?raw=true)

## Installation

To use this package, add `draggable_button_panel` as a dependency in your `pubspec.yaml` file. You can download it from pub.dev.

1. Open the "pubspec.yaml" file of your Flutter project.

2. Add the following line under the "dependencies" section:
   `draggable_button_panel: ^1.0.0-dev.1`

3. In your terminal, run the following command:
   `flutter pub get`

4. Import the package into your Dart file by adding this line:
   `import 'package:draggable_button_panel/draggable_button_panel.dart';`

## Usage

To use the DraggableButtonPanel, simply import it and use it in your widget. You can customize the buttons, colors, sizes and positions of the panel.

When using the `DraggableButtonPanel`, it is recommended to use a `GlobalKey` to keep the position of the widget even when the parent widget rebuilds.

You can also retrieve the `top` position of the `currentState` to update the panel position according to your application needs.

Here is an example code:

```dart
import 'package:draggable_button_panel/draggable_button_panel.dart';

final GlobalKey<DraggableButtonPanelState> _draggableButtonPanelKey =
    GlobalKey<DraggableButtonPanelState>();

DraggableButtonPanel(
  key: _draggableButtonPanelKey,
  children: [
    IconButton(
      icon: Icon(Icons.favorite),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(Icons.access_alarm),
      onPressed: () {},
    ),
  ],
  top: _draggableButtonPanelKey.currentState?.top ?? 50,
)
```

## Customization options
- **options** : The list of buttons to display in the panel.
- **buttonSize**: The size of the buttons in the panel (default: 55).
- **panelColor**: The background color of the panel (default: Colors.white).
- **buttonColor**: The color of the main button that opens and closes the panel (default: Colors.blue).
- **collapseOpacity**: The opacity of the panel when it is closed (default: 0.8).
- **top**: The top position of the panel (default: 50).
- **left**: The left position of the panel (default : 10).

## License
This package is distributed under the BSD 3-Clause license:

BSD 3-Clause License

Copyright (c) 2023, KSɅRKΞV
All rights reserved.

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.
