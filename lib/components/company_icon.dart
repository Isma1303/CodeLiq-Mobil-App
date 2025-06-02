import 'package:flutter/material.dart';

class CompanyIcon extends StatelessWidget {
  final double size;
  const CompanyIcon({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
