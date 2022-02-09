import 'package:flutter/material.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class AlertView {
  showAlertView(BuildContext context, String message, Function onPressed,
      {String title = LabelStr.lblTotem, String action = LabelStr.lblOkay}) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(
        title,
        style: AppTheme.semiBoldSFTextStyle()
            .copyWith(fontSize: 18, color: buttonPrimary),
      ),
      content: Text(
        message,
        style: AppTheme.regularSFTextStyle()
            .copyWith(fontSize: 14, color: buttonPrimary),
      ),
      actions: [
        TextButton(
            onPressed: onPressed,
            child: Text(action,
                style: AppTheme.semiBoldSFTextStyle()
                    .copyWith(fontSize: 16, color: buttonPrimary)))
      ],
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }

  showAlertViewWithTwoButton(
      BuildContext context,
      String message,
      String action1,
      String action2,
      Function onPressedAction1,
      Function onPressedAction2,
      {String title = LabelStr.lblTotemApp}) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onPressedAction1,
          child: Text(action1,
              style: AppTheme.regularSFTextStyle()
                  .copyWith(fontSize: 16, color: buttonPrimary)),
        ),
        TextButton(
            onPressed: onPressedAction2,
            child: Text(action2,
                style: AppTheme.regularSFTextStyle().copyWith(
                  fontSize: 16,
                  color: buttonPrimary,
                )))
      ],
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }

  showAlert(String message, BuildContext context) {
    AlertView()
        .showAlertView(context, message, () => {Navigator.of(context).pop()});
  }
}
