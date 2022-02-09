import 'package:flutter/material.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class ItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      highlightColor: Colors.white,
      builder: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                CircleAvatar(
                  backgroundColor: screenBgColor.withAlpha(50),
                  radius: 25,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          width: 100,
                          color: screenBgColor.withAlpha(50),
                        ),
                        SizedBox(
                          height: dimen.paddingVerySmall,
                        ),
                        Container(
                          height: 10,
                          width: 150,
                          color: screenBgColor.withAlpha(50),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 20,
                  width: 60,
                  color: screenBgColor.withAlpha(50),
                )
              ],
            ),
            Divider(
              color: screenBgColor.withAlpha(50),
            )
          ],
        ),
      ),
    );
  }
}
