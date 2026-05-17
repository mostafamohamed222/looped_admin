import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../res/color_manager.dart';

class DropDownFormFiled extends StatefulWidget {
  DropDownFormFiled({
    super.key,
    required this.hintText,
    required this.type,
    required this.errorEmpty,
    required this.controller,
    required this.items,
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
  final FocusNode focus = FocusNode();
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
  final List<DropdownMenuItem<String>> items;

  @override
  State<DropDownFormFiled> createState() => _DropDownFormFiledState();
}

class _DropDownFormFiledState extends State<DropDownFormFiled> {
  bool showEmptyText = false;
  bool showInvalidError = false;
  @override
  void initState() {
    super.initState();
    widget.focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    widget.focus.removeListener(_onFocusChange);
    widget.focus.dispose();
  }

  void _onFocusChange() {
    if (widget.focus.hasFocus == false) {
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
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              DropdownButtonFormField(
                icon: const Icon(Icons.keyboard_arrow_down),
                items: widget.items,
                onChanged: (value) {},
                style: const TextStyle(
                    color: ColorManager.mainColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                onTap: widget.onTap,
                focusNode: widget.focus,
                decoration: InputDecoration(
                  counterText: widget.showCounter ? null : "",
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  filled: true,
                  fillColor: widget.isSearch || widget.isFilter
                      ? Colors.transparent
                      : ColorManager.whiteColor,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 20,
                  ),
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                      color: ColorManager.noDataColor), // Changed to main color
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
