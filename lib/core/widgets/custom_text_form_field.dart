import 'package:flutter/material.dart';

import '../res/color_manager.dart';

class CustomTextFormFiled extends StatefulWidget {
  CustomTextFormFiled({
    super.key,
    required this.hintText,
    required this.type,
    required this.errorEmpty,
    required this.controller,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.showPassword = false,
    this.showError = true,
    this.maxLength = 0,
    this.maxLines = 1,
    this.showCounter = true,
    this.wrong = false,
    this.errorWrong,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.onTap,
    this.isAddress = false,
    this.showInvalidError = false,
    this.invalidError = "",
    this.isEmail = false,
    this.isSearch = false,
    this.isFilter = false,
  });
  final bool showInvalidError;
  final String invalidError;
  final bool isEmail;
  final bool showCounter;
  final bool showError;
  final String hintText;
  final TextInputType type;
  final String errorEmpty;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool showPassword;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final int maxLength;
  final int maxLines;
  final bool? wrong;
  final String? errorWrong;
  final TextInputAction textInputAction;
  final bool isAddress;
  final bool isSearch;
  final bool isFilter;

  @override
  State<CustomTextFormFiled> createState() => _CustomTextFormFiledState();
}

class _CustomTextFormFiledState extends State<CustomTextFormFiled> {
  bool showEmptyText = false;
  bool showInvalidError = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus == false) {
      if (widget.controller.text.isEmpty) {
        setState(() {
          showEmptyText = true;
        });
      } else {
        setState(() {
          showEmptyText = false;
        });
      }
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              TextFormField(
                style: const TextStyle(
                  color: ColorManager.mainColor,
                ),
                onTap: widget.onTap,
                textInputAction: widget.textInputAction,
                onFieldSubmitted: widget.onFieldSubmitted,
                onTapOutside: (event) {
                  _focusNode.unfocus();
                },
                cursorColor: ColorManager.blackColor,
                maxLength: widget.maxLength == 0 ? null : widget.maxLength,
                maxLines: widget.maxLines,
                onChanged: (value) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  }
                  if (showEmptyText) {
                    if (widget.controller.text.isNotEmpty) {
                      setState(() {
                        showEmptyText = false;
                      });
                    }
                  } else {
                    if (widget.controller.text.isEmpty) {
                      setState(() {
                        showEmptyText = true;
                      });
                    }
                  }
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    setState(() {
                      showEmptyText = true;
                    });
                    return null;
                  }
                  return null;
                },
                obscureText: widget.showPassword,
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.type,
                textAlignVertical:
                    widget.suffixIcon == null && widget.prefixIcon == null
                        ? null
                        : TextAlignVertical.center,
                decoration: InputDecoration(
                  counterText: widget.showCounter ? null : "",
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  filled: true,
                  fillColor: widget.isSearch || widget.isFilter
                      ? Colors.transparent
                      : ColorManager.whiteColor,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.isSearch || widget.isFilter
                          ? Colors.transparent
                          : ColorManager.textFormFieldColor,
                      width: 1,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.isSearch || widget.isFilter
                          ? Colors.transparent
                          : ColorManager.mainColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                      color:
                          ColorManager.hintColor), // Changed to main color
                  alignLabelWithHint: widget.maxLines == 1 ? null : true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
