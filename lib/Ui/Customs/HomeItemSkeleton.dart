import 'package:flutter/material.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class HomeItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      highlightColor: Colors.white,
      builder: Container(
        padding: EdgeInsets.only(left: dimen.paddingExtraLarge, right: dimen.paddingExtraLarge,top: dimen.paddingSmall, bottom: dimen.paddingMedium),
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
              ],
            ),
            SizedBox(height: dimen.dividerHeightSmall,),
            Container(

              height: 200,
              child:
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  color: screenBgColor.withAlpha(50),
                ),
              ),
            ),
            SizedBox(height: dimen.dividerHeightMedium,),
            Container(
              height: 20,
              // width: 60,
              color: screenBgColor.withAlpha(50),
            ),

          ],
        ),
      ),
    );
  }
}
