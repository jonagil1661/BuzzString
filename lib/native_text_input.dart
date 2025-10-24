import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeTextInput extends StatefulWidget {
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int minLines;
  final bool isRequired;

  const NativeTextInput({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.onChanged,
    this.maxLines = 1,
    this.minLines = 1,
    this.isRequired = false,
  }) : super(key: key);

  @override
  State<NativeTextInput> createState() => _NativeTextInputState();
}

class _NativeTextInputState extends State<NativeTextInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent intent) {
              final currentText = widget.controller.text;
              final selection = widget.controller.selection;
              final newText = currentText.substring(0, selection.start) + 
                            ' ' + 
                            currentText.substring(selection.end);
              widget.controller.text = newText;
              widget.controller.selection = TextSelection.collapsed(
                offset: selection.start + 1,
              );
              if (widget.onChanged != null) {
                widget.onChanged!(newText);
              }
              return null;
            },
          ),
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _isFocused 
                  ? const Color(0xFFB3A369) 
                  : Colors.white.withOpacity(0.3),
              width: _isFocused ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              prefixIcon: Icon(widget.prefixIcon, color: Colors.white),
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(fontSize: 16, color: Colors.white),
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            onChanged: widget.onChanged,
            keyboardType: widget.maxLines > 1 ? TextInputType.multiline : TextInputType.text,
            textInputAction: widget.maxLines > 1 ? TextInputAction.newline : TextInputAction.done,
            enableSuggestions: false,
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            inputFormatters: [],
          ),
        ),
      ),
    );
  }
}
