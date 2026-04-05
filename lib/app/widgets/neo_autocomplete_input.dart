import 'package:flutter/material.dart';
import '../theme/neo_brutalism_theme.dart';

class NeoAutocompleteInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final List<String> suggestions;
  final Function(String) onSuggestionSelected;
  final String? Function(String?)? validator;
  final bool isDark;
  final IconData? suffixIcon;
  final int maxLines;

  const NeoAutocompleteInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.suggestions,
    required this.onSuggestionSelected,
    this.validator,
    this.isDark = false,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  State<NeoAutocompleteInput> createState() => _NeoAutocompleteInputState();
}

class _NeoAutocompleteInputState extends State<NeoAutocompleteInput> {
  bool _listenerAttached = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          initialValue: widget.controller.value,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return widget.suggestions.where((String option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            }).take(5);
          },
          onSelected: widget.onSuggestionSelected,
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            // Attach listener ONCE to sync back to main controller
            if (!_listenerAttached) {
              _listenerAttached = true;
              textEditingController.addListener(() {
                if (widget.controller.text != textEditingController.text) {
                  widget.controller.text = textEditingController.text;
                }
              });
            }

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              maxLines: widget.maxLines,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                suffixIcon: widget.suffixIcon != null
                    ? Icon(widget.suffixIcon, color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)
                    : null,
                filled: true,
                fillColor: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 4),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 3),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: widget.validator,
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 0,
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: NeoBrutalismTheme.neoBox(
                    color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                    borderColor: NeoBrutalismTheme.primaryBlack,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: NeoBrutalismTheme.primaryBlack.withOpacity(0.2),
                                width: index < options.length - 1 ? 1 : 0,
                              ),
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}