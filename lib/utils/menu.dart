import 'dart:io';
//import 'package:preference_list/preference_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tray_manager/tray_manager.dart';

class Menu with TrayListener {
  String getIcon() {
    return Platform.isWindows
        ? 'images/tray_icon_original.ico'
        : 'images/tray_icon_original.png';
  }

  List<MenuItem> _getMenuItems() {
    return [
      MenuItem(title: 'Preferences...', toolTip: 'Open Preferences'),
      MenuItem(title: 'Quit', toolTip: 'Quit'),
      // MenuItem(
      //   title: 'Copy As',
      //   items: [
      //     MenuItem(title: 'Copy Remote File Url'),
      //     MenuItem(title: 'Copy Remote File Url From...'),
      //   ],
      // ),
    ];
  }

  void init() {
    trayManager.addListener(this);
    trayManager.setIcon(getIcon());
    trayManager.setContextMenu(_getMenuItems());
  }

  void dispose() {
    trayManager.removeListener(this);
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.title) {
      case 'Preferences':
        break;

      case 'Quit':
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      break;

      default:
        if (kDebugMode) {
          print(menuItem.toJson());
        }
      break;
    }
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }
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