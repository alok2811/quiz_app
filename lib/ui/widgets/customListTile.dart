import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Widget leadingChild;
  final String? title;
  final String? subtitle;
  final Function? trailingButtonOnTap;
  final double opacity;
  const CustomListTile({Key? key, required this.leadingChild, required this.subtitle, required this.title, required this.trailingButtonOnTap, required this.opacity}) : super(key: key);

  Widget _buildVerticalLine(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      color: Theme.of(context).primaryColor,
      width: 5.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 25.0),
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 5.0,
              color: Theme.of(context).primaryColor.withOpacity(0.5), //confirm shadow color
            )
          ],
          borderRadius: BorderRadius.circular(5.0)),
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      width: MediaQuery.of(context).size.width * (0.85),
      height: MediaQuery.of(context).size.height * (0.14),
      child: Opacity(
        opacity: opacity,
        child: Row(
          children: [
            _buildVerticalLine(context),
            SizedBox(
              width: 7.5,
            ),
            CircleAvatar(
              radius: 15.5,
              backgroundColor: Theme.of(context).primaryColor,
              child: leadingChild,
            ),
            SizedBox(
              width: 7.5,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * (0.535),
                  child: Text(
                    "$title",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0, color: Theme.of(context).colorScheme.secondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * (0.55),
                  child: Text(
                    "$subtitle",
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Spacer(),
            //when data comes from notification close button not show
            trailingButtonOnTap != null
                ? InkWell(
                    onTap: trailingButtonOnTap as void Function()?,
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  )
                : Container(),
            SizedBox(
              width: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
