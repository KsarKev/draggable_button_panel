# Draggable Button Panel

Panneau vertical draggable et “dockable” (gauche/droite) composé de lignes de boutons.
Chaque ligne (PanelButton) peut soit s’agrandir pour afficher des options horizontales,
soit fonctionner en mode toggle (marche/arrêt) si elle n’a pas d’options.

## Aperçu

![](https://github.com/KsarKev/draggable_button_panel/blob/main/lib/assets/gifs/demo.gif?raw=true)

## Fonctionnalités clés
- Drag vertical avec auto-dock sur le bord gauche ou droit de l’écran.
- Animation par bouton: seule la ligne cliquée s’étend (les autres ne bougent pas).
- Options (OptionButton) qui glissent depuis l’arrière du PanelButton.
- Mode toggle pour les lignes sans options, avec sélection simple ou multiple.
- Événement onTogglesChanged qui émet la liste des éléments actifs (index + id optionnel).
- Bords arrondis contextuels: parent arrondi côté libre; seul le premier/dernier PanelButton a des coins arrondis; sur les options, uniquement l’élément le plus éloigné est arrondi verticalement.
- Le feedback visuel pendant le drag reflète fidèlement l’état actuel (orientation, couleurs, expansions, toggles).

## Installation

Ajoutez `draggable_button_panel` à votre `pubspec.yaml` puis faites un `flutter pub get`.

```yaml
dependencies:
  draggable_button_panel: ^1.0.0-dev.3
```

Importez ensuite le package:

```dart
import 'package:draggable_button_panel/draggable_button_panel.dart';
```

## API rapide

### ToggleSelectionMode
- `single`: un seul bouton toggleable actif à la fois.
- `multiple`: plusieurs peuvent être actifs.

### OptionButton
Représente une option qui se déplie horizontalement.
- `icon` (Icon) requis
- `label` (String?) optionnel (informel)
- `onPressed` (VoidCallback?)
- `color`, `backgroundColor` (Color?)
- `width` (double?) taille horizontale (par défaut 50)

### PanelButton
Ligne principale du panneau; deux usages:
- avec `options`: la ligne s’étend pour afficher les `OptionButton`.
- sans `options` + `toggleable: true`: agit comme un bouton on/off.

Propriétés principales:
- `icon`, `label`, `onPressed`, `color`, `backgroundColor`
- `width`, `height` (par défaut 50)
- `options` (List<OptionButton>)
- `toggleable` (bool, défaut false)
- `initiallyToggled` (bool, défaut false)
- `id` (Object?) identifiant libre (int/String recommandé) utilisé dans les événements.

### DraggableButtonPanel
- `children` (List<PanelButton>)
- `width` (double) taille carrée d’une ligne (sert aussi de défaut pour les options)
- `buttonColor` (Color) couleur par défaut des boutons
- `collapseOpacity` (double) opacité des lignes inactives (0–1)
- `toggleMode` (ToggleSelectionMode)
- `onTogglesChanged` (ValueChanged<List<ToggleEntry>>?) émet les états actifs
- `onPositionChanged` (ValueChanged<Offset>?) notifie la position (left, top) après drag ou changement programmatique
- `top` (double) position verticale du panneau (mutable pour persister la position)
- `left` (double) [DEPRECATED] la position horizontale n’est plus utilisée pour le layout; le côté est déterminé par le docking (gauche/droite)

### ToggleEntry
Structure émise dans `onTogglesChanged`:
- `index` (int): position de la ligne dans `children`.
- `id` (Object?): identifiant optionnel fourni sur le `PanelButton`.

## Exemple d’utilisation

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
            // entries: liste de ToggleEntry (index + id optionnel)
            debugPrint(entries.toString());
          },
          children: [
            // 1) Ligne avec options qui se déplient
            PanelButton(
              id: PanelBtnId.menu,
              icon: const Icon(Icons.menu_open_rounded, color: Colors.white),
              backgroundColor: Colors.redAccent,
              options: const [
                OptionButton(icon: Icon(Icons.checklist)),
                OptionButton(icon: Icon(Icons.add)),
              ],
            ),
            // 2) Ligne toggleable (pas d’options)
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

## Conseils d’intégration
- Si vous souhaitez conserver la position entre des rebuilds fréquents, utilisez un `GlobalKey<DraggableButtonPanelState>` pour lire/écrire `top`/`left` depuis l’état courant.
- La largeur visuelle du panneau est fixe (basée sur la largeur max des options) pour éviter les décalages quand une ligne s’étend; seule la ligne cliquée est animée.
- Les angles arrondis s’ajustent automatiquement selon le côté d’ancrage.

## Persister et restaurer la position
Vous pouvez écouter la position via `onPositionChanged` et la réappliquer plus tard grâce aux méthodes publiques de l’état:

```dart
class MyPageState extends State<MyPage> {
  final panelKey = GlobalKey<DraggableButtonPanelState>();
  Offset? savedOffset;
  bool savedDockLeft = true; // par défaut à gauche

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DraggableButtonPanel(
          key: panelKey,
          onPositionChanged: (offset) {
            // Enregistrez (par ex. dans votre state, provider, prefs...)
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
              // Restaure la dernière position/docking connue
              state.setPanelPosition(
                top: savedOffset?.dy,
                dockLeft: savedDockLeft,
              );
            },
            child: const Text('Restaurer position'),
          ),
        ),
      ],
    );
  }
}
```

API utile dans l’état:
- `panelOffset` -> Offset(left, top) courant
- `isDockedLeft` -> bool indiquant le côté
- `setPanelPosition({double? top, bool? dockLeft, bool clampToScreen = true})` -> pour appliquer une position côté parent.

## Licence
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
