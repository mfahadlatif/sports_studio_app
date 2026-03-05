import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';

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

  // Nominatim endpoint — same as web
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
    if (query.length < 3) {
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
          'format': 'json',
          'q': query,
          'addressdetails': 1,
          'limit': 5,
        },
        options: Options(
          headers: {
            // Nominatim requires a descriptive User-Agent
            'User-Agent': 'SportsStudioApp/1.0',
            'Accept-Language': 'en',
          },
        ),
      );

      if (mounted) {
        final data = res.data;
        setState(() {
          if (data is List && data.isNotEmpty) {
            _suggestions
              ..clear()
              ..addAll(data);
            _showSuggestions = true;
          } else {
            _suggestions.clear();
            _showSuggestions = false;
          }
          _isLoading = false;
        });
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
    if (value.length < 3) {
      setState(() {
        _suggestions.clear();
        _showSuggestions = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(value);
    });
  }

  void _onSuggestionTap(dynamic item) {
    // Nominatim returns display_name, lat, lon
    final address = item['display_name']?.toString() ?? '';
    final lat = double.tryParse(item['lat']?.toString() ?? '');
    final lng = double.tryParse(item['lon']?.toString() ?? '');

    widget.controller.text = address;

    if (widget.latController != null && lat != null) {
      widget.latController!.text = lat.toStringAsFixed(7);
    }
    if (widget.lngController != null && lng != null) {
      widget.lngController!.text = lng.toStringAsFixed(7);
    }

    setState(() {
      _suggestions.clear();
      _showSuggestions = false;
    });

    _focusNode.unfocus();
    widget.onSelect?.call(address, lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          onTap: () {
            if (widget.controller.text.length >= 3 && _suggestions.isNotEmpty) {
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
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.search,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
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

        if (_showSuggestions && _suggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            shadowColor: Colors.black.withOpacity(0.12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 240),
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
                  final title = displayName.split(',').first.trim();
                  final subtitle = displayName;

                  return InkWell(
                    onTap: () => _onSuggestionTap(item),
                    borderRadius: index == 0
                        ? const BorderRadius.vertical(top: Radius.circular(12))
                        : index == _suggestions.length - 1
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          )
                        : BorderRadius.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
