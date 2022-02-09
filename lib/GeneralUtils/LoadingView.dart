import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class LoadingView extends StatelessWidget {
  final String loadingMessage;

  const LoadingView({this.loadingMessage});

  @override
  Widget build(BuildContext context) {
    return loadingViewWithTitle();
  }

  Widget loadingViewWithTitle() {
    return Center(
        child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: 150,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      loadingMessage,
                      style: AppTheme.regularSFTextStyle()
                          .copyWith(fontSize: 14, color: buttonPrimary),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: CircularProgressIndicator(
                      backgroundColor: buttonPrimary,
                    ),
                  )
                ],
              ),
            )));
  }

  Widget loader() {
    return Center(
      child: Container(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            backgroundColor: buttonPrimary,
          )),
    );
  }

  showLoaderWithTitle(bool isShowLoader, BuildContext context,
      {String message = Messages.CProcessing}) {
    if (isShowLoader) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => LoadingView(loadingMessage: message));
    } else {
      Navigator.of(context).pop();
    }
  }

  showLoader(bool isShowLoader, BuildContext context) {
    if (isShowLoader) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => loader());
    } else {
      Navigator.of(context).pop();
    }
  }
}
