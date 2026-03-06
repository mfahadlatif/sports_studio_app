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
  final _focusNode = FocusNode();  // Google Places URLs
  static const _autocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const _detailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

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
        _autocompleteUrl,
        queryParameters: {
          'input': query,
          'key': AppConstants.googlePlacesApiKey,
          'language': 'en',
          'types': 'geocode|establishment', // Mixed for best coverage
        },
      );

      if (mounted) {
        final data = res.data;
        if (data is Map && data['status'] == 'OK') {
          setState(() {
            _suggestions
              ..clear()
              ..addAll(data['predictions']);
            _showSuggestions = true;
          });
        } else {
          setState(() {
            _suggestions.clear();
            _showSuggestions = false;
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

  Future<void> _onSuggestionTap(dynamic item) async {
    final String description = item['description'] ?? '';
    final String placeId = item['place_id'] ?? '';

    // Set address immediately (UI feels faster)
    widget.controller.text = description;
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);

    if (placeId.isEmpty) return;

    // Fetch details to get lat/lng
    setState(() => _isLoading = true);
    try {
      final res = await Dio().get(
        _detailsUrl,
        queryParameters: {
          'place_id': placeId,
          'key': AppConstants.googlePlacesApiKey,
          'fields': 'geometry,formatted_address',
        },
      );

      if (mounted) {
        final details = res.data;
        if (details is Map && details['status'] == 'OK') {
          final result = details['result'];
          final lat = result['geometry']['location']['lat'];
          final lng = result['geometry']['location']['lng'];

          if (widget.latController != null) {
            widget.latController!.text = lat.toString();
          }
          if (widget.lngController != null) {
            widget.lngController!.text = lng.toString();
          }

          widget.onSelect?.call(description, lat, lng);
        }
      }
    } catch (e) {
      debugPrint('❌ [GooglePlaces] Error fetching details: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length + 1, // Add Google branding
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  // Branding at the bottom
                  if (index == _suggestions.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Opacity(
                            opacity: 0.6,
                            child: Image.asset(
                              'assets/google-logo.png',
                              height: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Powered by Google',
                            style: AppTextStyles.label.copyWith(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final item = _suggestions[index];
                  final mainText =
                      item['structured_formatting']?['main_text'] ?? '';
                  final secondaryText =
                      item['structured_formatting']?['secondary_text'] ?? '';

                  return InkWell(
                    onTap: () => _onSuggestionTap(item),
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
                                  mainText,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  secondaryText,
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
