import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../utils/extensions.dart';

/// Custom search bar widget following the project's design system
class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.autofocus = false,
    this.showClearButton = true,
  });

  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final bool autofocus;
  final bool showClearButton;

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onSubmitted?.call('');
  }

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.slate100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.slate100,
          ),
        ),
        child: TextField(
          controller: _controller,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: context.textTheme.bodySm.copyWith(
            color: AppTheme.slate800,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText ?? context.translate('search'),
            hintStyle: context.textTheme.bodySm.copyWith(
              color: AppTheme.slate500,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppTheme.slate500,
              size: 20,
            ),
            suffixIcon: widget.showClearButton && _hasText
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppTheme.slate500,
                      size: 20,
                    ),
                    onPressed: _clearSearch,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      );
}