import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'Constant.dart';

Widget textFieldFor(String hint, TextEditingController controller,
    {TextInputType keyboardType = TextInputType.text,
    bool autocorrect = true,
    int maxLine = 1,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    bool obscure = false,
    Color fillColor = Colors.transparent,
    maxLength: 200,
    Widget prefixIcon,
    Widget suffixIcon,
    TextInputAction textInputAction,
    bool enabled = true,
    bool readOnly = false,
    var inputFormatter,
    VoidCallback onEditingComplete,
    VoidCallback onTap,
    bool isMobile = false,
      FocusNode focusNode,
    Function onSubmit}) {
  return SizedBox(
    child: TextField(
      autocorrect: autocorrect,
      enabled: enabled,
      maxLines: maxLine,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      textAlignVertical: TextAlignVertical.center,
      readOnly: readOnly,
      textCapitalization: textCapitalization,
      onEditingComplete: onEditingComplete,
      obscureText: obscure,
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      focusNode: focusNode,
      inputFormatters:
          isMobile ? [MaskedInputFormatter('###-###-####')] : inputFormatter,
      style: AppTheme.regularSFTextStyle(),
      cursorColor: Color(0xff007AFF),
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        contentPadding: textFieldPadding(),
        prefixIcon: prefixIcon,
        hintText: hint,
        counterText: "",
        suffixIcon: suffixIcon,
        hintStyle: AppTheme.textFieldHintTextStyle(),
        border: OutlineInputBorder(
          borderSide:
              BorderSide(width: 1.1, color: MyColor.textFieldBorderColor()),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(width: 1, color: MyColor.textFieldBorderColor()),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(width: 1, color: MyColor.textFieldBorderColor()),
        ),
      ),
      //inputFormatters: inputFormatter,
      onTap: onTap,
      onSubmitted: onSubmit,
    ),
  );
}

Widget multilineTextFieldFor(
    String hint, TextEditingController controller, double height,
    {TextInputType keyboardType = TextInputType.text,
    bool autocorrect = true,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    bool obscure = false,
    maxLength: 200,
    Widget perfixIcon,
    bool enabled = true,
    bool readOnly = false,
    VoidCallback onEditingComplete,
    VoidCallback onTap,
    Function onSubmit,
    Function onChange}) {
  return SizedBox(
    height: height,
    child: TextField(
      autocorrect: autocorrect,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: 5,
      textCapitalization: textCapitalization,
      onEditingComplete: onEditingComplete,
      obscureText: obscure,
      controller: controller,
      keyboardType: keyboardType,
      style: AppTheme.regularSFTextStyle(),
      decoration: InputDecoration(
        filled: true,
        contentPadding: textFieldPadding(),
        prefixIcon: perfixIcon,
        hintText: hint,
        fillColor: Colors.white,
        hintStyle: AppTheme.textFieldHintTextStyle(),
        border: OutlineInputBorder(
          borderSide:
              BorderSide(width: 1, color: MyColor.textFieldBorderColor()),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(width: 1, color: MyColor.textFieldBorderColor()),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(width: 1, color: MyColor.textFieldBorderColor()),
        ),
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
      onTap: onTap,
      onSubmitted: onSubmit,
    ),
  );
}

Widget appBar(String text, IconButton iconButton, {Color color}) {
  return AppBar(
    title: Text(
      text,
      style: AppTheme.headerTextStyle(),
    ),
    centerTitle: true,
    leading: IconButton(icon: iconButton, onPressed: () {}),
    backgroundColor: color ?? MyColor.backgroundColor(),
    brightness: Brightness.dark,
    elevation: 1,
  );
}

EdgeInsets textFieldPadding() {
  return EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0);
}
