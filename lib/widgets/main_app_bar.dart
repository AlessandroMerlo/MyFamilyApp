import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:my_family_app/utils/network_connectivity.dart';
import 'package:my_family_app/widgets/network_widget.dart';
import 'package:provider/provider.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MainAppBar({
    super.key,
    required this.mainTitle,
    required this.backgroundColor,
    this.mustCenter = false,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  final String mainTitle;
  final Color backgroundColor;
  final bool? mustCenter;

  @override
  final Size preferredSize;

  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  final _connectivity = Connectivity();
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
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: widget.mustCenter == true ? 55 : 0,
          ),
          Image.asset('assets/pngegg2.png', height: 30),
          const SizedBox(
            width: 8,
          ),
          Text(
            widget.mainTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Image.asset('assets/pngegg2.png', height: 30),
          initialValue == null
              ? const SizedBox(
                  width: 55,
                )
              : StreamProvider<NetworkStatus>(
                  create: (context) =>
                      NetworkStatusService().networkStatusController.stream,
                  initialData: initialValue!,
                  child: const NetworkAwareWidget(
                    onlineChild: SizedBox(width: 55),
                    offlineChild: OfflineWidget(),
                  ),
                )
        ],
      ),
      centerTitle: true,
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
