import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:my_family_app/utils/network_connectivity.dart';

class ExtendedAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ExtendedAppBar(
      {super.key, required this.mainTitle, required this.backgroundColor})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  final String mainTitle;
  final Color backgroundColor;
  @override
  final Size preferredSize;

  @override
  State<ExtendedAppBar> createState() => _ExtendedAppBarState();
}

class _ExtendedAppBarState extends State<ExtendedAppBar>
    with SingleTickerProviderStateMixin {
  final _connectivity = Connectivity();

  late final TabController nestedTabBarctrl;

  NetworkStatus? initialValue;

  Future getConnectivity() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    setState(() {
      initialValue = connectivityResult == ConnectivityResult.none
          ? NetworkStatus.Offline
          : NetworkStatus.Online;
    });
  }

  @override
  void initState() {
    getConnectivity();
    super.initState();
    nestedTabBarctrl = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.mainTitle,
        style: const TextStyle(
          color: Colors.teal,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      bottom: TabBar(
        labelColor: Colors.purple,
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelColor: Colors.teal[200],
        onTap: (value) {
          setState(() {
            nestedTabBarctrl.animateTo(value);
          });
        },
        controller: nestedTabBarctrl,
        tabs: const [
          Tab(
              child: Text(
            'Tutte',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          )),
          Tab(
            child: Text(
              'Muu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Tab(
            child: Text(
              'Mek',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      backgroundColor: widget.backgroundColor,
      foregroundColor: Colors.white,
    );
  }
}

class OfflineWidget extends StatefulWidget {
  const OfflineWidget({super.key});

  @override
  State<OfflineWidget> createState() => _OfflineWidgetState();
}

class _OfflineWidgetState extends State<OfflineWidget> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = Colors.white;
    _changeColor();
  }

  Future _changeColor() async {
    Color newColor;
    while (true) {
      await Future.delayed(const Duration(seconds: 1), () {
        if (_selectedColor == Colors.white) {
          newColor = Colors.red;
        } else {
          newColor = Colors.white;
        }
        if (!mounted) {
          return;
        } else {
          setState(() {
            _selectedColor = newColor;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Padding(
          padding: const EdgeInsets.only(left: 50),
          child: Icon(
            Icons.wifi_off_sharp,
            color: _selectedColor,
          )),
    );
  }
}
