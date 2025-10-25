import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/segmented_control_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';

/// A custom sliding segmented control that can work with or without Provider
///
/// **Mode 1: With Auto-Provider (Recommended for sharing state across components)**
/// ```dart
/// CustomSlidingSegmentedControl<String>.withProvider(
///   segments: {'option1': 'Option 1', 'option2': 'Option 2'},
///   initialValue: 'option1',
///   builder: (context, child) {
///     // This builder and all its children can access the provider
///     return Column(
///       children: [
///         child!, // The segmented control
///         // Any other widget that needs to access the selected value
///         Consumer<SegmentedControlProvider<String>>(
///           builder: (context, provider, _) => Text('Selected: ${provider.selectedValue}'),
///         ),
///       ],
///     );
///   },
/// )
/// ```
///
/// **Mode 2: With External Provider (for module-wide state)**
/// ```dart
/// // 1. Wrap your module with ChangeNotifierProvider
/// ChangeNotifierProvider(
///   create: (_) => SegmentedControlProvider<String>(
///     initialValue: 'option1',
///     segments: {'option1': 'Option 1', 'option2': 'Option 2'},
///   ),
///   child: YourModuleScreen(),
/// )
///
/// // 2. Use the widget with useExternalProvider flag
/// CustomSlidingSegmentedControl<String>(
///   segments: {'option1': 'Option 1', 'option2': 'Option 2'},
///   useExternalProvider: true,
/// )
/// ```
///
/// **Mode 3: Without Provider (local state only)**
/// ```dart
/// CustomSlidingSegmentedControl<String>(
///   segments: {'option1': 'Option 1', 'option2': 'Option 2'},
///   initialValue: 'option1',
///   onValueChanged: (value) => print('Selected: $value'),
/// )
/// ```
class CustomSlidingSegmentedControl<T extends Object> extends StatelessWidget {
  const CustomSlidingSegmentedControl({
    required this.segments,
    super.key,
    this.onValueChanged,
    this.initialValue,
    this.useExternalProvider = false,
  }) : _builder = null;

  /// Creates a segmented control with its own provider scoped to the builder
  /// This is the recommended approach for sharing state across multiple components
  const CustomSlidingSegmentedControl.withProvider({
    required this.segments,
    required Widget Function(BuildContext context, Widget? child) builder,
    super.key,
    this.onValueChanged,
    this.initialValue,
  })  : useExternalProvider = true,
        _builder = builder;

  final Map<T, String> segments;
  final ValueChanged<T>? onValueChanged;
  final T? initialValue;
  final bool useExternalProvider;
  final Widget Function(BuildContext context, Widget? child)? _builder;

  @override
  Widget build(BuildContext context) {
    // Mode 1: With auto-scoped provider using builder
    if (_builder != null) {
      return ChangeNotifierProvider(
        create: (_) => SegmentedControlProvider<T>(
          initialValue: initialValue ?? segments.keys.first,
          segments: segments,
        ),
        child: Builder(
          builder: (context) => _builder(
            context,
            Consumer<SegmentedControlProvider<T>>(
              builder: (context, provider, child) => _buildSegmentedControl(
                context,
                provider.selectedValue,
                (value) {
                  provider.updateSelectedValue(value);
                  onValueChanged?.call(value);
                },
              ),
            ),
          ),
        ),
      );
    }

    // Mode 2: Using external provider
    if (useExternalProvider) {
      return Consumer<SegmentedControlProvider<T>>(
        builder: (context, provider, child) => _buildSegmentedControl(
          context,
          provider.selectedValue,
          (value) {
            provider.updateSelectedValue(value);
            onValueChanged?.call(value);
          },
        ),
      );
    }

    // Mode 3: Local state without provider
    return _StatefulSegmentedControl<T>(
      segments: segments,
      initialValue: initialValue,
      onValueChanged: onValueChanged,
    );
  }

  Widget _buildSegmentedControl(
    BuildContext context,
    T selectedValue,
    ValueChanged<T> onChanged,
  ) {
    final segmentKeys = segments.keys.toList();
    final segmentCount = segmentKeys.length;

    return Container(
      height: 44,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / segmentCount;
          final selectedIndex = segmentKeys.indexOf(selectedValue);

          return Stack(
            children: [
              // Sliding thumb
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: selectedIndex * segmentWidth,
                child: Container(
                  width: segmentWidth,
                  height: constraints.maxHeight - 12,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CustomAppColors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: CustomAppColors.black01.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),

              // Labels
              Row(
                children: segmentKeys.map((key) {
                  final label = segments[key]!;
                  final isSelected = selectedValue == key;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(key),
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: context.textTheme.bodyBase.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isSelected
                                ? CustomAppColors.primary
                                : CustomAppColors.slate600,
                          ),
                          child: Text(label),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Private StatefulWidget wrapper for local state management
class _StatefulSegmentedControl<T extends Object> extends StatefulWidget {
  const _StatefulSegmentedControl({
    required this.segments,
    this.initialValue,
    this.onValueChanged,
  });

  final Map<T, String> segments;
  final T? initialValue;
  final ValueChanged<T>? onValueChanged;

  @override
  State<_StatefulSegmentedControl<T>> createState() =>
      _StatefulSegmentedControlState<T>();
}

class _StatefulSegmentedControlState<T extends Object>
    extends State<_StatefulSegmentedControl<T>> {
  late T selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue ?? widget.segments.keys.first;
  }

  @override
  Widget build(BuildContext context) => CustomSlidingSegmentedControl<T>(
        segments: widget.segments,
      )._buildSegmentedControl(
        context,
        selectedValue,
        (value) {
          setState(() => selectedValue = value);
          widget.onValueChanged?.call(value);
        },
      );
}
