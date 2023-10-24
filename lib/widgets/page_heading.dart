import 'package:flutter/material.dart';

class PageHeading extends StatefulWidget {
  final String title;
  final String subtitle;

  const PageHeading({Key? key, required this.title, required this.subtitle})
      : super(key: key);

  @override
  State<PageHeading> createState() => _PageHeadingState();
}

class _PageHeadingState extends State<PageHeading> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontFamily: 'Rubik Medium',
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  height: screenWidth * 0.015,
                ),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontFamily: 'Rubik Regular',
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
      ],
    );
  }
}
