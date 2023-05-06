# Draggable Button Panel

Un panneau de boutons personnalisable et déplaçable pour Flutter.

## Installation

Pour utiliser ce package, ajoutez `draggable_button_panel` comme dépendance dans votre fichier `pubspec.yaml`. Vous pouvez le télécharger sur pub.dev.

1. Ouvrez le fichier "pubspec.yaml" de votre projet Flutter.

2. Ajoutez la ligne suivante sous la section "dependencies" :
`draggable_button_panel: ^1.0.0`

3. Dans votre terminal, exécutez la commande suivante :
`flutter pub get`

4. Importez le package dans votre fichier Dart en ajoutant cette ligne:
`import 'package:draggable_button_panel/draggable_button_panel.dart';`

## Utilisation

Pour utiliser le DraggableButtonPanel, il suffit de l'importer et de l'utiliser dans votre widget. Vous pouvez personnaliser les boutons, les couleurs, les tailles et les positions du panneau.

Lorsque vous utilisez le `DraggableButtonPanel`, il est recommandé d'utiliser une `GlobalKey` pour conserver la position du widget même lorsque le widget parent se reconstruit.

Vous pouvez également récupérer la position `top` du `currentState` pour mettre à jour la position du panneau en fonction des besoins de votre application.

Voici un exemple de code :

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

## Options de personnalisation
 - **children**: La liste des boutons à afficher dans le panneau.
 - **buttonSize**: La taille des boutons dans le panneau (par défaut : 55).
 - **startingPanelWidth**: La largeur initiale du panneau lorsqu'il est ouvert (par défaut : 200).
 - **panelColor**: La couleur de fond du panneau (par défaut : Colors.white).
 - **buttonColor**: La couleur du bouton principal qui ouvre et ferme le panneau (par défaut : Colors.blue).
 - **collapseOpacity**: L'opacité du panneau lorsqu'il est fermé (par défaut : 0.8).
 - **top**: La position top du panneau (par défaut : 50).
 - **left**: La position left du panneau (par défaut : 10).
 - 

## Licence
Ce package est distribué sous la licence BSD 3-Clause :

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
