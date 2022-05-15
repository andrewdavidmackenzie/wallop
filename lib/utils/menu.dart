import 'dart:io';
//import 'package:preference_list/preference_list.dart';
import 'package:flutter/foundation.dart' hide MenuItem, Menu;
import 'package:flutter/services.dart';
import 'package:tray_manager/tray_manager.dart';

class WallopMenu with TrayListener {
  String getIcon() {
    return Platform.isWindows
        ? 'images/tray_icon_original.ico'
        : 'images/tray_icon_original.png';
  }

  Menu _getMenuItems() {
    return Menu(
      items:
       [
        MenuItem(key: "preferences", label: 'Preferences...', toolTip: 'Open Preferences'),
        MenuItem(key: "quit", label: 'Quit', toolTip: 'Quit'),
    ]);
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
    switch (menuItem.key) {
      case 'preferences':
        break;

      case 'quit':
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