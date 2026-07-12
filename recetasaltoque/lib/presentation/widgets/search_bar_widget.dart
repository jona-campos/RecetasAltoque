import 'dart:async';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final String hintText;
  final Duration debounceDuration;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.hintText = 'Buscar recetas...',
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _lastSearch = '';
  bool _showClear = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    setState(() {
      _showClear = text.isNotEmpty;
    });

    if (text != _lastSearch && text.trim().isNotEmpty) {
      _lastSearch = text;
      _debounceSearch(text);
    }
  }

  void _debounceSearch(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (_lastSearch == query) {
        widget.onSearch(query);
      }
    });
  }

  void _onSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      widget.onSearch(value);
    }
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _showClear = false;
      _lastSearch = '';
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _showClear
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        onSubmitted: _onSubmitted,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
