import 'package:flutter/material.dart';

class AuthScreenHeading extends StatefulWidget {
  final String heading;
  final String subHeading;

  const AuthScreenHeading(
      {Key? key, required this.heading, required this.subHeading})
      : super(key: key);

  @override
  State<AuthScreenHeading> createState() => _AuthScreenHeadingState();
}

class _AuthScreenHeadingState extends State<AuthScreenHeading> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final logoSize = screenWidth * 0.1;
    final headingFontSize = screenWidth * 0.06;
    final tagLineFontSize = screenWidth * 0.02;
    final subHeadingFontSize = screenWidth * 0.03;

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FlutterLogo(size: 40),
              SizedBox(width: screenWidth * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tech Swivel',
                    style: TextStyle(
                      fontSize: headingFontSize,
                      fontFamily: 'Rubik Medium',
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Trainee Flutter Developer',
                    style: TextStyle(
                      fontSize: tagLineFontSize,
                      fontFamily: 'Rubik Regular',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.04),
          Center(
            child: Text(
              widget.heading,
              style: TextStyle(
                fontSize: headingFontSize,
                fontFamily: 'Rubik Medium',
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Center(
            child: Text(
              widget.subHeading,
              style: TextStyle(
                fontSize: subHeadingFontSize,
                fontFamily: 'Rubik Regular',
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.04),
        ]);
  }
}
