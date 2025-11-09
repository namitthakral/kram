import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/segmented_control_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';
import '../../utils/responsive_utils.dart';

class CustomSlidingSegmentedControl<T extends Object> extends StatelessWidget {
  const CustomSlidingSegmentedControl({
    required this.segments,
    super.key,
    this.onValueChanged,
    this.initialValue,
    this.useExternalProvider = false,
  }) : _builder = null;

  /// Creates a segmented control with its own provider scoped to the builder
  const CustomSlidingSegmentedControl.withProvider({
    required this.segments,
    required Widget Function(BuildContext context, Widget? child) builder,
    super.key,
    this.onValueChanged,
    this.initialValue,
  }) : useExternalProvider = true,
       _builder = builder;

  final Map<T, String> segments;
  final ValueChanged<T>? onValueChanged;
  final T? initialValue;
  final bool useExternalProvider;
  final Widget Function(BuildContext context, Widget? child)? _builder;

  @override
  Widget build(BuildContext context) {
    // Mode 1: Scoped provider (recommended)
    if (_builder != null) {
      return ChangeNotifierProvider(
        create:
            (_) => SegmentedControlProvider<T>(
              initialValue: initialValue ?? segments.keys.first,
              segments: segments,
            ),
        child: Builder(
          builder:
              (context) => _builder(
                context,
                Consumer<SegmentedControlProvider<T>>(
                  builder:
                      (context, provider, child) => _buildSegmentedControl(
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

    // Mode 2: External provider
    if (useExternalProvider) {
      return Consumer<SegmentedControlProvider<T>>(
        builder:
            (context, provider, child) => _buildSegmentedControl(
              context,
              provider.selectedValue,
              (value) {
                provider.updateSelectedValue(value);
                onValueChanged?.call(value);
              },
            ),
      );
    }

    // Mode 3: Local state
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
    final isMobile = context.isMobile;

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final segmentWidth = constraints.maxWidth / segmentCount;
            final selectedIndex = segmentKeys.indexOf(selectedValue);

            // Add padding for edges and vertical breathing space
            const verticalPadding = 5.0;
            const horizontalPadding = 6.0;

            var leftOffset = selectedIndex * segmentWidth;
            var thumbWidth = segmentWidth;

            // Add extra padding at left/right edges
            if (selectedIndex == 0) {
              leftOffset += horizontalPadding;
              thumbWidth -= horizontalPadding;
            } else if (selectedIndex == segmentCount - 1) {
              thumbWidth -= horizontalPadding;
            }

            return Stack(
              children: [
                // Sliding thumb
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: leftOffset,
                  top: verticalPadding,
                  bottom: verticalPadding,
                  child: Container(
                    width: thumbWidth,
                    decoration: BoxDecoration(
                      color: CustomAppColors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // Segment labels
                Row(
                  children:
                      segmentKeys.map((key) {
                        final label = segments[key]!;
                        final isSelected = selectedValue == key;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onChanged(key),
                            behavior: HitTestBehavior.translucent,
                            child: Container(
                              alignment: Alignment.center,
                              height: double.infinity,
                              padding: EdgeInsets.fromLTRB(
                                isMobile ? 2 : 8,
                                0,
                                isMobile ? 2 : 8,
                                0,
                              ),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: context.textTheme.bodyBase.copyWith(
                                  height: 0,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isMobile ? 11 : 14,
                                  color:
                                      isSelected
                                          ? CustomAppColors.primary
                                          : CustomAppColors.slate600,
                                ),
                                child: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
      ),
    );
  }
}

/// Local state fallback (no Provider)
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
  )._buildSegmentedControl(context, selectedValue, (value) {
    setState(() => selectedValue = value);
    widget.onValueChanged?.call(value);
  });
}
