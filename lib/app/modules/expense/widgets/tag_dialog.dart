import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_autocomplete_input.dart';
import '../../../widgets/neo_button.dart';
import '../controllers/autocomplete_controller.dart';

class TagDialog extends StatefulWidget {
  final bool isDark;

  const TagDialog({
    super.key,
    required this.isDark,
  });

  @override
  State<TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<TagDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AutocompleteController autocompleteController = Get.find();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: NeoBrutalismTheme.neoBoxRounded(
          color: widget.isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(),
              const SizedBox(height: 16),
              _buildTagInput(),
              const SizedBox(height: 24),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'ADD TAG',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: widget.isDark
            ? NeoBrutalismTheme.darkText
            : NeoBrutalismTheme.primaryBlack,
      ),
    );
  }

  Widget _buildTagInput() {
    return NeoAutocompleteInput(
      controller: _controller,
      label: 'TAG NAME',
      hint: 'e.g., Business, Personal',
      suggestions: autocompleteController.tags,
      onSuggestionSelected: (value) {
        _controller.text = value;
      },
      isDark: widget.isDark,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a tag name';
        }
        if (value.trim().length > 20) {
          return 'Tag must be less than 20 characters';
        }
        return null;
      },
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: NeoButton(
            text: 'CANCEL',
            onPressed: () => Get.back(),
            color: widget.isDark
                ? NeoBrutalismTheme.darkBackground
                : NeoBrutalismTheme.primaryWhite,
            textColor: widget.isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: NeoButton(
            text: 'ADD',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Get.back(result: _controller.text.trim());
              }
            },
            color: NeoBrutalismTheme.accentGreen,
          ),
        ),
      ],
    );
  }
}