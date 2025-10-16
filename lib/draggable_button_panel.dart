/// Draggable Button Panel: a draggable, dockable vertical panel of buttons.
///
/// Each main button (PanelButton) can either:
/// - expand to reveal horizontal OptionButtons that slide out from behind it,
/// - or behave as a toggle button (when toggleable is true and no options).
///
/// The panel can be dragged vertically and docks itself to the left or right
/// edges of the screen. Border radii adapt to the docking side, and only the
/// per-row expansion animates.
///
/// Example:
///
///   DraggableButtonPanel(
///     toggleMode: ToggleSelectionMode.multiple,
///     onTogglesChanged: (entries) => debugPrint(entries.toString()),
///     children: const [
///       PanelButton(
///         options: [
///           OptionButton(icon: Icon(Icons.check)),
///           OptionButton(icon: Icon(Icons.add)),
///         ],
///       ),
///       // Toggleable row without options
///       PanelButton(toggleable: true, initiallyToggled: false),
///     ],
///   )
import 'package:flutter/material.dart';

/// Defines how toggleable PanelButton selections are handled.
///
/// - [single]: Only one toggleable button can be active at a time. Activating
///   another deactivates the previous one.
/// - [multiple]: Multiple toggleable buttons can be active simultaneously.
enum ToggleSelectionMode { single, multiple }

/// Defines where dragging the panel is allowed to start from.
/// - firstButton: Only the first PanelButton (main button area) starts a drag.
/// - allButtons: Any PanelButton (main button area) starts a drag.
enum DragHandleScope { firstButton, allButtons }

/// Emitted item describing a toggleable row state.
///
/// [index] is the position of the PanelButton in the panel.
/// [id] is an optional identifier provided on the PanelButton (int or String recommended).
class ToggleEntry {
  final int index;
  final Object? id;
  const ToggleEntry({required this.index, this.id});

  @override
  String toString() => 'ToggleEntry(index: $index, id: $id)';
}

/// Represents an option button that can slide out from behind a main
/// [PanelButton] when that row is expanded.
///
/// Typically rendered as a square icon button with optional colors and a
/// fixed width. The [onPressed] callback is triggered when the option is
/// tapped.
class OptionButton {
  final Icon icon;
  final String? label;
  final String? tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double? width;

  /// Creates an [OptionButton].
  ///
  /// The [icon] is required. If [width] is provided it must be positive.
  const OptionButton({
    required this.icon,
    this.width = 50,
    this.label,
    this.tooltip,
    this.onPressed,
    this.color,
    this.backgroundColor,
  }) : assert(width == null || width > 0, 'width must be > 0');
}

/// Represents a main button (row) inside [DraggableButtonPanel].
///
/// A [PanelButton] can either:
/// - provide a list of [options] that will slide out when the row is expanded; or
/// - be [toggleable] (and have no options), in which case it behaves like an
///   on/off button whose active state can be controlled via
///   [DraggableButtonPanel.toggleMode].
class PanelButton {
  final Icon icon;
  final String? label;
  final String? tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final bool toggleable; // when true and no options, acts as a toggle button
  final bool initiallyToggled; // initial active state
  /// Optional list of action buttons that slide out when this row is expanded.
  final List<OptionButton> options;
  /// Optional identifier for this PanelButton (recommended: int or String).
  final Object? id;

  /// Creates a [PanelButton].
  ///
  /// If [toggleable] is true, [options] should be empty for a clear UX. The
  /// [width] and [height] must be positive when provided.
  const PanelButton({
    this.icon = const Icon(
      Icons.menu_open_rounded,
      color: Colors.white,
    ),
    this.label,
    this.tooltip,
    this.onPressed, 
    this.options = const [],
    this.color,
    this.backgroundColor,
    this.width = 50,
    this.height = 50,
    this.toggleable = false,
    this.initiallyToggled = false,
    this.id,
  })  : assert(width == null || width > 0, 'width must be > 0'),
        assert(height == null || height > 0, 'height must be > 0');
}

/// Internal widget used by the panel to render a single row (main button +
/// its optional sliding options). Not intended for public consumption.
class PanelButtonWidget extends StatelessWidget {
  final Widget Function(Widget child)? mainButtonWrapper;
  final PanelButton panelButton;
  final bool isExpanded;
  final bool isLeftPositioned;
  final double baseButtonSize;
  final void Function() onExpand;
  final Widget? separator;
  final bool isFirst;
  final bool isLast;
  final double inactiveOpacity;
  final bool isActive;

  const PanelButtonWidget({
    required this.panelButton,
    required this.isExpanded,
    required this.isLeftPositioned,
    required this.baseButtonSize,
    required this.onExpand,
    required this.isFirst,
    required this.isLast,
    required this.inactiveOpacity,
    required this.isActive,
    this.separator,
    this.mainButtonWrapper,
    Key? key,
  }) : super(key: key);

  // Helpers
  static const _kOptionsAnim = Duration(milliseconds: 250);
  static const _kOpacityAnim = Duration(milliseconds: 300);

  Radius get _corner => const Radius.circular(8);

  double _sumOptionsWidth() {
    double total = 0;
    for (final opt in panelButton.options) {
      total += (opt.width ?? 50);
    }
    return total;
  }

  BorderRadius? _mainButtonBorderRadius() {
    if (isExpanded) return null; // while expanded, options side owns the rounding
    final r = _corner;
    if (isLeftPositioned) {
      if (isFirst && !isLast) return BorderRadius.only(topRight: r);
      if (isLast && !isFirst) return BorderRadius.only(bottomRight: r);
      if (isFirst && isLast) return BorderRadius.only(topRight: r, bottomRight: r);
    } else {
      if (isFirst && !isLast) return BorderRadius.only(topLeft: r);
      if (isLast && !isFirst) return BorderRadius.only(bottomLeft: r);
      if (isFirst && isLast) return BorderRadius.only(topLeft: r, bottomLeft: r);
    }
    return null;
  }

  Widget _withTooltip({required String? tooltip, required Widget child}) {
    if (tooltip == null) return child;
    return Tooltip(message: tooltip, child: child);
  }

  Widget _iconButton({
    required Icon icon,
    required Color? color,
    required VoidCallback? onPressed,
    required VoidCallback onAfterPress,
  }) {
    return IconButton(
      color: color,
      icon: icon,
      onPressed: () {
        if (onPressed != null) onPressed();
        onAfterPress();
      },
    );
  }

  Widget _buildMainButton(double width, double height) {
    final button = _withTooltip(
      tooltip: panelButton.tooltip,
      child: _iconButton(
        icon: panelButton.icon,
        color: panelButton.color,
        onPressed: panelButton.onPressed,
        onAfterPress: onExpand,
      ),
    );

    final content = Transform.scale(
      scaleX: (isLeftPositioned || isExpanded) ? -1.0 : 1.0,
      child: button,
    );

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: panelButton.backgroundColor ?? Colors.white,
        borderRadius: _mainButtonBorderRadius(),
      ),
      child: content,
    );

    final clippedBorder = _mainButtonBorderRadius();
    final child = clippedBorder != null
        ? ClipRRect(borderRadius: clippedBorder, child: decorated)
        : decorated;

    return SizedBox(width: width, height: height, child: child);
  }

  Widget _buildOptionTile(OptionButton opt, bool isLast, double height) {
    final r = _corner;
    BorderRadius? br;
    if (isExpanded && isLast) {
      br = isLeftPositioned
          ? BorderRadius.only(topRight: r, bottomRight: r)
          : BorderRadius.only(topLeft: r, bottomLeft: r);
    }

    final tile = SizedBox(
      width: opt.width ?? 50,
      height: height,
      child: IconButton(
        icon: opt.icon,
        color: opt.color,
        onPressed: opt.onPressed,
      ),
    );

    final child = _withTooltip(tooltip: opt.tooltip, child: tile);

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: opt.backgroundColor ?? Colors.white,
        borderRadius: br,
      ),
      child: child,
    );

    return br != null ? ClipRRect(borderRadius: br, child: decorated) : decorated;
  }

  @override
  Widget build(BuildContext context) {
    final double height = panelButton.height ?? baseButtonSize;
    final double buttonSide = panelButton.width ?? baseButtonSize;
    final double optionsWidth = _sumOptionsWidth();

    Widget mainButton = _buildMainButton(buttonSide, height);
    mainButton = mainButtonWrapper?.call(mainButton) ?? mainButton;

    final optionsRow = AnimatedContainer(
      duration: _kOptionsAnim,
      curve: Curves.easeInOut,
      width: isExpanded ? optionsWidth : 0,
      height: height,
      alignment: isLeftPositioned ? Alignment.centerLeft : Alignment.centerRight,
      child: Opacity(
        opacity: isExpanded ? 1 : 0,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          reverse: !isLeftPositioned,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final opt = panelButton.options[index];
            final bool last = index == panelButton.options.length - 1;
            return _buildOptionTile(opt, last, height);
          },
          separatorBuilder: (_, __) => separator ?? const SizedBox(width: 0),
          itemCount: panelButton.options.length,
        ),
      ),
    );

    final rowChildren = isLeftPositioned
        ? <Widget>[mainButton, optionsRow]
        : <Widget>[optionsRow, mainButton];

    return AnimatedOpacity(
      duration: _kOpacityAnim,
      curve: Curves.easeInOut,
      opacity: (isExpanded || isActive) ? 1.0 : inactiveOpacity,
      child: SizedBox(
        height: height,
        child: Row(mainAxisSize: MainAxisSize.min, children: rowChildren),
      ),
    );
  }
}

/// A draggable, dockable vertical panel of [PanelButton] rows.
///
/// Features:
/// - Draggable vertically; docks to left/right based on release position.
/// - Each row can expand to show [OptionButton]s sliding out from behind it.
/// - Rows without options can be toggleable; active state is reflected in
///   opacity and exposed through [onTogglesChanged].
/// - BorderRadius is applied on the free side of the dock, including only the
///   first and last main buttons for a pill-like look.
/// - During drag, the visual feedback mirrors the current panel state.
///
/// See the example in the file header or the README for a complete usage.
class DraggableButtonPanel extends StatefulWidget {
  DraggableButtonPanel({
    required this.children,
    super.key,
    this.top = 50,
    this.left = 10,
    this.width = 50,
    this.buttonColor = Colors.blue,
    this.collapseOpacity = 0.5,
    this.toggleMode = ToggleSelectionMode.multiple,
    this.onTogglesChanged, 
    this.onPositionChanged,
    this.onMenuExpand,
    this.dragHandleScope = DragHandleScope.firstButton,
  });

  /// List of main buttons (rows) displayed by this panel.
  final List<PanelButton> children;

  /// The square size (width == height) of each main button (row height).
  /// Also used as the default size for options when not specified.
  final double width;

  /// Default color for main buttons when not individually specified.
  final Color buttonColor;
 
  /// Opacity applied to non-active, non-expanded rows. Active (toggled) or
  /// expanded rows are rendered at full opacity (1.0). Range: 0.0 - 1.0.
  final double collapseOpacity;

  /// Selection mode for toggleable rows without options.
  final ToggleSelectionMode toggleMode;

  /// Emits the active toggleable rows whenever they change. Each entry contains
  /// the row index and the optional [PanelButton.id] (if provided).
  /// Only relevant for rows with [PanelButton.toggleable] == true.
  final ValueChanged<List<ToggleEntry>>? onTogglesChanged;

  /// Emits the current panel offset as an [Offset] (dx = left, dy = top)
  /// whenever the panel position changes due to dragging or when changed
  /// programmatically via [DraggableButtonPanelState.setPanelPosition]. This is
  /// useful for persisting and restoring the panel position from the parent.
  final ValueChanged<Offset>? onPositionChanged;

  /// Emits the row index and optional id when a row with options gets expanded.
  /// Similar to [onTogglesChanged] but only for expansion of option menus.
  final ValueChanged<ToggleEntry>? onMenuExpand;

  /// Where dragging may start from: only the first main button or all main buttons.
  final DragHandleScope dragHandleScope;

  /// Initial top offset of the panel. The mutable source of truth is kept
  /// internally by the State; this value is only read once in initState.
  final double top;

  /// Deprecated: left offset is ignored for layout; docking determines x-position.
  @Deprecated('Ignored for layout. Use top + dockLeft (via setPanelPosition) instead.')
  final double left;

  @override
  State<DraggableButtonPanel> createState() => DraggableButtonPanelState();
}

class DraggableButtonPanelState extends State<DraggableButtonPanel>
    with SingleTickerProviderStateMixin {
  bool _isDockedLeft = false;
  int? _expandedIndex;
  final Set<int> _toggledIndices = <int>{};
  // Internal source of truth for vertical position to avoid being clobbered by parent rebuilds.
  double _top = 0;

  void _notifyToggles() {
    final callback = widget.onTogglesChanged;
    if (callback != null) {
      final indices = _toggledIndices.toList()..sort();
      final entries = <ToggleEntry>[];
      for (final i in indices) {
        final id = (i >= 0 && i < widget.children.length)
            ? widget.children[i].id
            : null;
        entries.add(ToggleEntry(index: i, id: id));
      }
      callback(entries);
    }
  }

  void _updatePosition(Offset newPosition) {
    // Keep internal vertical position; horizontal (left) is derived from docking.
    if (newPosition.dy != _top) {
      setState(() {
        _top = newPosition.dy;
      });
    }
  }

  /// Current offset of the panel (dx = visual left, dy = top).
  ///
  /// Note: `left` is computed from the docking side and current target width
  /// (0 when docked left, screenWidth - targetWidth when docked right).
  Offset get panelOffset {
    final ctx = context;
    final size = MediaQuery.of(ctx).size;
    final double targetWidth = widget.width + _maxExpandedExtraWidth();
    final double computedLeft = _isDockedLeft ? 0 : (size.width - targetWidth);
    return Offset(computedLeft, _top);
  }

  /// Whether the panel is currently docked to the left side.
  bool get isDockedLeft => _isDockedLeft;

  /// Programmatically set the panel position and/or dock side.
  ///
  /// - Provide [top] to move the panel.
  /// - Provide [dockLeft] to force docking to the left or right.
  /// - When [clampToScreen] is true, the top value will be clamped to
  ///   the safe available height to keep the panel visible.
  void setPanelPosition({
    double? top,
    bool? dockLeft,
    bool clampToScreen = true,
  }) {
    setState(() {
      if (dockLeft != null) {
        _isDockedLeft = dockLeft;
      }
      if (top != null) {
        if (clampToScreen) {
          final size = MediaQuery.of(context).size;
          final padding = MediaQuery.of(context).padding;
          // Height available to the body area (no AppBar subtraction here, since
          // this widget is typically placed inside the Scaffold body already).
          final bodyHeight = size.height - padding.top - padding.bottom;
          // Clamp using the full panel height so the panel stays fully visible.
          final panelHeight = (widget.children.length * widget.width);
          final minTop = 0.0;
          final maxTop = (bodyHeight - panelHeight).clamp(0.0, double.infinity);
          _top = top.clamp(minTop, maxTop);
        } else {
          _top = top;
        }
      }
      // left is intentionally ignored; docking defines x-position.
    });
    final size = MediaQuery.of(context).size;
    final double targetWidth = widget.width + _maxExpandedExtraWidth();
    final double computedLeft = _isDockedLeft ? 0 : (size.width - targetWidth);
    widget.onPositionChanged?.call(Offset(computedLeft, _top));
  }

  @override
  void initState() {
    super.initState();
    // Initialize internal top from the initial widget value once.
    _top = widget.top;
    for (int i = 0; i < widget.children.length; i++) {
      final child = widget.children[i];
      if ((child.options.isEmpty) &&
          child.toggleable &&
          child.initiallyToggled) {
        _toggledIndices.add(i);
      }
    }
    // Enforce single selection mode at init if needed
    if (widget.toggleMode == ToggleSelectionMode.single &&
        _toggledIndices.length > 1) {
      final first = _toggledIndices.toList()..sort();
      _toggledIndices
        ..clear()
        ..add(first.first);
    }
    // Notify initial state after first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _notifyToggles();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPanel(context);
  }

  void _onDragEnd(DraggableDetails draggableDetails) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final padding = MediaQuery.of(context).padding;

    final availableHeight = screenHeight -
        padding.top -
        padding.bottom -
        kToolbarHeight -
        kBottomNavigationBarHeight;
    final availableWidth = screenWidth - padding.left - padding.right;

    final newPosition = Offset(
      draggableDetails.offset.dx,
      draggableDetails.offset.dy,
    );
    _updatePosition(newPosition);

    setState(() {
      final finalPosition = draggableDetails.offset.dy;

      _isDockedLeft = draggableDetails.offset.dx < availableWidth / 2;

      final panelHeight = (widget.children.length * widget.width);
      if (finalPosition < 0) {
        _top = 0;
      } else if (finalPosition + panelHeight > availableHeight) {
        _top = (availableHeight - panelHeight).clamp(0.0, double.infinity);
      } else {
        _top = finalPosition;
      }
    });

    // Notify external listeners of the final position (left, top)
    final double targetWidth = widget.width + _maxExpandedExtraWidth();
    final double computedLeft = _isDockedLeft ? 0 : (size.width - targetWidth);
    widget.onPositionChanged?.call(Offset(computedLeft, _top));
  }

  Widget _buildFeedback() {
    // Use current expanded width to avoid misalignment when docked right.
    final double targetWidth = widget.width + _currentExpandedExtraWidth();

    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: targetWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < widget.children.length; i++) ...[
                SizedBox(
                  height: widget.width,
                  child: Align(
                    alignment: _isDockedLeft
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: PanelButtonWidget(
                      panelButton: widget.children[i],
                      isExpanded: _expandedIndex == i,
                      isLeftPositioned: _isDockedLeft,
                      baseButtonSize: widget.width,
                      onExpand: () {},
                      isFirst: i == 0,
                      isLast: i == widget.children.length - 1,
                      inactiveOpacity: widget.collapseOpacity,
                      isActive: _toggledIndices.contains(i),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Offset _feedbackOffset() {
    // When docked on the right, align the right edge of the feedback with the
    // right edge of the drag handle (main button) so it doesn't overflow off-screen.
    if (_isDockedLeft) return Offset.zero;
    final double feedbackWidth = widget.width + _currentExpandedExtraWidth();
    final double handleWidth = widget.width; // main button width
    final double dx = -(feedbackWidth - handleWidth);
    return Offset(dx, 0);
  }

  double _maxExpandedExtraWidth() {
    double maxExtra = 0;
    for (final child in widget.children) {
      if (child.options.isEmpty) continue;
      double total = 0;
      for (final opt in child.options) {
        total += (opt.width ?? 50);
      }
      // Do not add implicit spacing; separator controls spacing and defaults to 0.
      if (total > maxExtra) maxExtra = total;
    }
    return maxExtra;
  }

  double _currentExpandedExtraWidth() {
    final int? idx = _expandedIndex;
    if (idx == null || idx < 0 || idx >= widget.children.length) return 0;
    final child = widget.children[idx];
    if (child.options.isEmpty) return 0;
    double total = 0;
    for (final opt in child.options) {
      total += (opt.width ?? 50);
    }
    return total;
  }

  double _targetWidth() => widget.width + _maxExpandedExtraWidth();

  Widget _buildPanel(BuildContext context) {
    final double targetWidth = _targetWidth();

    return Stack(children: [
      Positioned(
        top: _top,
        left: _isDockedLeft
            ? 0
            : (MediaQuery.of(context).size.width - targetWidth),
        child: Container(
          width: targetWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < widget.children.length; i++) ...[
                SizedBox(
                  height: widget.width,
                  child: Align(
                    alignment: _isDockedLeft
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: PanelButtonWidget(
                      panelButton: widget.children[i],
                      isExpanded: _expandedIndex == i,
                      isLeftPositioned: _isDockedLeft,
                      baseButtonSize: widget.width,
                      mainButtonWrapper: ((widget.dragHandleScope == DragHandleScope.allButtons) || (widget.dragHandleScope == DragHandleScope.firstButton && i == 0))
                          ? (child) => Draggable<int>(
                                onDragEnd: _onDragEnd,
                                dragAnchorStrategy: pointerDragAnchorStrategy,
                                feedback: _buildFeedback(),
                                feedbackOffset: _feedbackOffset(),
                                child: child,
                              )
                          : null,
                      onExpand: () {
                        bool didExpand = false;
                        Object? expandedId;
                        setState(() {
                          final child = widget.children[i];
                          if (child.toggleable) {
                            // Toggle mode: never expand, only toggle active state
                            final isActive = _toggledIndices.contains(i);
                            if (widget.toggleMode == ToggleSelectionMode.single) {
                              if (isActive) {
                                // deactivate current
                                _toggledIndices.remove(i);
                              } else {
                                // activate only this one
                                _toggledIndices
                                  ..clear()
                                  ..add(i);
                              }
                            } else {
                              // multiple mode
                              if (isActive) {
                                _toggledIndices.remove(i);
                              } else {
                                _toggledIndices.add(i);
                              }
                            }
                            // Ensure no row is considered expanded while toggling
                            _expandedIndex = null;
                            // Notify
                            _notifyToggles();
                          } else if (child.options.isNotEmpty) {
                            // Expand/collapse behavior for buttons with options
                            if (_expandedIndex == i) {
                              _expandedIndex = null;
                            } else {
                              _expandedIndex = i;
                              didExpand = true;
                              expandedId = child.id;
                            }
                          }
                          // else: no options and not toggleable → no panel state change
                        });
                        if (didExpand) {
                          widget.onMenuExpand?.call(ToggleEntry(index: i, id: expandedId));
                        }
                      },
                      isFirst: i == 0,
                      isLast: i == widget.children.length - 1,
                      inactiveOpacity: widget.collapseOpacity,
                      isActive: _toggledIndices.contains(i),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    ]);
  }
}
