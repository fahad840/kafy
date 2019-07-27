import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

PlatformButton({context, padding, color, onPressed, child}) {
  return Theme.of(context).platform == TargetPlatform.iOS
      ? CupertinoButton(
          onPressed: onPressed,
          child: child,
          padding: padding,
          color: color,
        )
      : FlatButton(
          onPressed: onPressed,
          child: child,
          padding: padding,
          color: color,
        );
}

PlatformIcon({context}) {
  return Theme.of(context).platform == TargetPlatform.iOS
      ? Icon(CupertinoIcons.search)
      : Icon(Icons.search);
}
