import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final Widget child;
  final Function()? onTap;

  const CircularButton({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: TextButton(
        style: TextButton.styleFrom(padding: const EdgeInsets.all(24)),
        onPressed: () {},
        child: child,
      ),
    );
  }
}
