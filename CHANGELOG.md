## Changelog
All significant changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0-dev.9] - 2025-10-20

### Changed
- BREAKING: `onPositionChanged` now emits `PanelPosition` instead of `Offset`.
- Updated example app and README accordingly.

---

## [1.0.0-dev.8] - 2025-10-20

### Changed
- Introduced `PanelPosition` value object and `panelPosition` getter/setter on `DraggableButtonPanelState` to set/get position and docking in one call. Backward-compatible with `setPanelPosition`.

### Docs
- README updated: examples now use `panelPosition = PanelPosition(...)`; clarified that `left` is deprecated for layout and docking determines horizontal position.

---

## [1.0.0-dev.7] - 2025-10-15

### Added
- DraggableButtonPanel.onMenuExpand: émission de l'index et de l'id (si fourni) lorsqu'un menu d'options s'étend.

---

## [1.0.0-dev.6] - 2025-10-15

### Added
- PanelButton.tooltip: possibilité d'afficher une info-bulle (Tooltip) sur le bouton principal (PanelButton).

---

## [1.0.0-dev.5] - 2025-10-15

### Added
- OptionButton.tooltip: possibilité d'afficher une info-bulle (Tooltip) sur les options.

---

## [1.0.0-dev.4] - 2025-10-14

### Added
- PanelButton with per-row expansion animations; OptionButtons slide out from behind the row.
- Toggleable mode for rows without options, with single or multiple selection.
- Emission of toggle changes via onTogglesChanged with indices and optional ids (ToggleEntry).
- Dock-aware border radii on parent container and precise rounding for first/last main buttons and far-end option.
- Drag feedback mirrors the current visual state (colors, options, orientation, expansion).

### Changed
- Fixed layout overflows and prevented panel width shifts when rows expand.
- Refactored and documented public API for package readiness.

### Deprecated
- None.

### Fixed
- RenderFlex overflow in certain collapsed states.

---

## [1.0.0-dev.2] - 08-05-2023

### Added
1. Package description
2. Gif demo

### Changed
No changes.

### Deleted
No items deleted.

## [1.0.0-dev.1] - 08-05-2023

### Added
1. Customizable and moveable button panel functionality.
2. Customization options for buttons, colors and panel positions.

### Changed
No changes.

### Deleted
No items deleted.