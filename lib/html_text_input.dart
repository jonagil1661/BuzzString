import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HtmlTextInput extends StatefulWidget {
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int minLines;
  final bool isRequired;

  const HtmlTextInput({
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
  State<HtmlTextInput> createState() => _HtmlTextInputState();
}

class _HtmlTextInputState extends State<HtmlTextInput> {
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
    return Container(
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
        // Remove all restrictions that might interfere with mobile input
      ),
    );
  }
}
