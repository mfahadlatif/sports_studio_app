import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/widgets/map_location_picker_screen.dart';

/// Address autocomplete using OpenStreetMap Nominatim — no API key required.
/// Matches the web app's LocationAutocomplete behaviour exactly.
class AddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final void Function(String address, double? lat, double? lng)? onSelect;
  final TextEditingController? latController;
  final TextEditingController? lngController;

  const AddressAutocompleteField({
    super.key,
    required this.controller,
    this.hintText = 'Search for a location...',
    this.prefixIcon = Icons.location_on_outlined,
    this.onSelect,
    this.latController,
    this.lngController,
  });

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  final List<dynamic> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  Timer? _debounce;
  final _focusNode = FocusNode();

  static const _nominatimUrl = 'https://nominatim.openstreetmap.org/search';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          setState(() => _showSuggestions = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions.clear();
        _showSuggestions = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await Dio().get(
        _nominatimUrl,
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': 1,
          'limit': 5,
        },
      );

      if (mounted) {
        final data = res.data;
        if (data is List) {
          setState(() {
            _suggestions
              ..clear()
              ..addAll(data);
            _showSuggestions = true;
          });
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions.clear();
          _showSuggestions = false;
          _isLoading = false;
        });
      }
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      setState(() {
        _suggestions.clear();
        _showSuggestions = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _fetchSuggestions(value);
    });
  }

  void _onSuggestionTap(dynamic item) {
    final String description = item['display_name'] ?? '';
    final String latStr = item['lat']?.toString() ?? '';
    final String lonStr = item['lon']?.toString() ?? '';

    widget.controller.text = description;
    
    if (widget.latController != null) {
      widget.latController!.text = latStr;
    }
    if (widget.lngController != null) {
      widget.lngController!.text = lonStr;
    }

    widget.onSelect?.call(
      description,
      double.tryParse(latStr),
      double.tryParse(lonStr),
    );

    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: _onChanged,
                onTap: () {
                  if (widget.controller.text.isNotEmpty && _suggestions.isNotEmpty) {
                    setState(() => _showSuggestions = true);
                  }
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  prefixIcon: Icon(
                    widget.prefixIcon ?? Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 52, // Match TextField height
              width: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1.5),
              ),
              child: IconButton(
                icon: const Icon(Icons.map_outlined, color: AppColors.primary, size: 24),
                onPressed: () => _openMapPicker(context),
                tooltip: 'Select on Map',
              ),
            ),
          ],
        ),
        if (_showSuggestions && _suggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            shadowColor: Colors.black.withOpacity(0.12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final item = _suggestions[index];
                  final displayName = item['display_name']?.toString() ?? '';
                  final parts = displayName.split(',');
                  final mainText = parts.isNotEmpty ? parts[0] : '';
                  
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                    title: Text(mainText, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(displayName, style: AppTextStyles.label.copyWith(fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () => _onSuggestionTap(item),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _openMapPicker(BuildContext context) async {
    final double? curLat = double.tryParse(widget.latController?.text ?? '');
    final double? curLng = double.tryParse(widget.lngController?.text ?? '');

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerScreen(
          initialLat: curLat,
          initialLng: curLng,
        ),
      ),
    );

    if (result != null && result is Map) {
      final String address = result['address'] ?? '';
      final double lat = result['lat'] ?? 0.0;
      final double lng = result['lng'] ?? 0.0;

      widget.controller.text = address;
      if (widget.latController != null) {
        widget.latController!.text = lat.toString();
      }
      if (widget.lngController != null) {
        widget.lngController!.text = lng.toString();
      }

      widget.onSelect?.call(address, lat, lng);
    }
  }
}
