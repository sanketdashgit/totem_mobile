import 'package:flutter/material.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class CommentSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      highlightColor: Colors.white,
      builder: Container(
        padding: EdgeInsets.only(
            left: dimen.paddingExtraLarge,
            right: dimen.paddingExtraLarge,
            bottom: dimen.paddingSmall,
            top: dimen.paddingSmall),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                CircleAvatar(
                  backgroundColor: screenBgColor.withAlpha(50),
                  radius: 15,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Container(
                        width: double.infinity,
                        height: 70,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16.0),
                            ),
                            color: screenBgColor.withAlpha(50),
                        ),
                        child : Container()
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
