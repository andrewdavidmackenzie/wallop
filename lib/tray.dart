//import 'dart:async';
import 'dart:io';

//import 'package:flutter/material.dart';
//import 'package:preference_list/preference_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tray_manager/tray_manager.dart';

//const _kIconTypeDefault = 'default';
//const _kIconTypeOriginal = 'original';

class Tray {
//  String _iconType = _kIconTypeOriginal;
  late TrayListener listener;

  getOriginal() {
    return Platform.isWindows
        ? 'images/tray_icon_original.ico'
        : 'images/tray_icon_original.png';
  }

  getAlternative() {
    return Platform.isWindows
        ? 'images/tray_icon.ico'
        : 'images/tray_icon.png';
  }

  getMenuItems() {
    return [
      MenuItem(title: 'Preferences'),
      MenuItem(title: 'Quit'),
      // MenuItem(
      //   title: 'Copy As',
      //   items: [
      //     MenuItem(title: 'Copy Remote File Url'),
      //     MenuItem(title: 'Copy Remote File Url From...'),
      //   ],
      // ),
    ];
  }

  void init(listener) {
    this.listener = listener;
    trayManager.addListener(listener);
    trayManager.setIcon(getOriginal());
    trayManager.setContextMenu(getMenuItems());
  }

  void dispose() {
    trayManager.removeListener(listener);
  }

  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.title) {
      case "Quit":
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      break;

      default:
        if (kDebugMode) {
          print(menuItem.toJson());
        }
      break;
    }
  }

  void popUpContextMenu() {
    trayManager.popUpContextMenu();
  }

  //
  // void _handleSetIcon(String iconType) async {
  //   _iconType = iconType;
  //   String iconPath = getAlternative();
  //
  //   if (_iconType == 'original') {
  //     iconPath = getOriginal();
  //   }
  //
  //   await trayManager.setIcon(iconPath);
  // }
  //
  // void _startIconFlashing() {
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
  //     _handleSetIcon(_iconType == _kIconTypeOriginal
  //         ? _kIconTypeDefault
  //         : _kIconTypeOriginal);
  //   });
  //   setState(() {});
  // }
  //
  // void _stopIconFlashing() {
  //   if (_timer != null && _timer!.isActive) {
  //     _timer!.cancel();
  //   }
  //   setState(() {});
  // }

}


// Widget _buildBody(BuildContext context) {
//   return PreferenceList(
//     children: <Widget>[
//       PreferenceListSection(
//         children: [
//           PreferenceListItem(
//             title: const Text('Some preference'),
//             onTap: () async {
// //                await trayManager.popUpContextMenu();
//             },
//           ),
//         ],
//       ),
//     ],
//   );
// }

//
//   Widget _buildBody(BuildContext context) {
//     return PreferenceList(
//       children: <Widget>[
//         PreferenceListSection(
//           children: [
//             PreferenceListItem(
//               title: const Text('Some preference'),
//               onTap: () async {
// //                await trayManager.popUpContextMenu();
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }