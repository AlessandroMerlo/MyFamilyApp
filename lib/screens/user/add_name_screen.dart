import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_family_app/auth/fire_auth.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/models/users.dart';
import 'package:my_family_app/providers/add_name/selected_icon_change_notifier.dart';
import 'package:my_family_app/screens/shopping_chart/shopping_chart_screen.dart';
import 'package:my_family_app/services/user_service.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';

class AddNameScreen extends StatefulWidget {
  const AddNameScreen({super.key});

  @override
  State<AddNameScreen> createState() => _AddNameScreenState();
}

class _AddNameScreenState extends State<AddNameScreen> {
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    return firebaseApp;
  }

  final _formKey = GlobalKey<FormState>();
  final _nameTextController = TextEditingController();
  String? userName;
  String? oldName;
  User? user;
  bool alreadyExist = false;
  late String oldIconName;
  final SelectedIcon selectedIconNotifier = SelectedIcon();

  void _changeIcon(int index) {
    selectedIconNotifier.changeIndex(index);
  }

  @override
  void initState() {
    super.initState();
    user = FireAuth.getUser();

    if (user != null) {
      userName = user!.displayName ?? '';
      alreadyExist = true;

      MyUser userData =
          myUsersList.firstWhere((element) => element.id == user!.uid);

      if (iconsList.contains(userData.iconName)) {
        oldIconName = userData.iconName;
        _changeIcon(iconsList.indexOf(oldIconName));
      } else {
        _changeIcon(iconsList.indexOf(
            iconsList.elementAt(Random().nextInt(iconsList.length - 1))));
      }
    }

    if (userName != null) {
      oldName = userName;
      _nameTextController.value = TextEditingValue(
        text: userName!,
        selection: TextSelection.fromPosition(
          TextPosition(offset: userName!.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.user,
      ),
      body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            String? userName;

            if (user != null) {
              userName = user!.displayName;
            }

            if (userName != null) {
              oldName = userName;
              _nameTextController.value = TextEditingValue(
                text: userName,
                selection: TextSelection.fromPosition(
                  TextPosition(offset: userName.length),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Image.asset(
                                'assets/icons/$oldIconName.png',
                                height: 40,
                              ),
                            ),
                            const WidgetSpan(
                              child: SizedBox(
                                width: 8,
                              ),
                            ),
                            TextSpan(
                              text: oldName,
                            ),
                          ],
                          style: Theme.of(context).textTheme.headlineSmall,
                          text: 'Attuale: '),
                    ),
                    const Divider(
                      color: Colors.lightBlueAccent,
                      height: 48,
                      thickness: 2,
                    ),
                    Text(
                      userName != null ? 'Modifica il nome' : 'Assegna il nome',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameTextController,
                            decoration: const InputDecoration(
                              hintText: 'Nome',
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Container(
                            height: 300,
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Column(
                                children: [
                                  Text('Modifica la tua icona',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall),
                                  Flexible(
                                    child: ListView.builder(
                                      itemCount: iconsList.length,
                                      scrollDirection: Axis.horizontal,
                                      physics: const PageScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        String icon =
                                            iconsList.elementAt(index);

                                        return SelectorIcon(
                                          selectedIconNotifier:
                                              selectedIconNotifier,
                                          icon: icon,
                                          index: index,
                                          onChangeSelection: _changeIcon,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  User? currentUser = FireAuth.getUser();
                                  if (currentUser != null &&
                                      (currentUser.displayName != '' &&
                                          currentUser.displayName != null)) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ShoppingChartScreen(),
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Warning'),
                                        content: const Text(
                                            'Devi inserire un nome valido!!!'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Ok, capito'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                style: ButtonStyle(
                                  fixedSize: const MaterialStatePropertyAll(
                                    Size(120, 20),
                                  ),
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.red.shade100),
                                ),
                                child: const Text('Annulla'),
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    if (_nameTextController.value.text == '') {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Warning'),
                                          content: const Text(
                                              'Devi inserire un nome valido!!!'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Ok, capito'),
                                            ),
                                          ],
                                        ),
                                      );

                                      return;
                                    } else {
                                      await user!.updateDisplayName(
                                          _nameTextController.text);
                                      await user!.reload();
                                      if (user!.displayName != '') {
                                        if (alreadyExist) {
                                          String key = await getUserKey(
                                              userUid: user!.uid);
                                          await updateUser(
                                              myUser: MyUser(
                                                id: user!.uid,
                                                name: _nameTextController
                                                    .value.text,
                                                iconName: iconsList[
                                                    selectedIconNotifier
                                                        .selectedIndex],
                                              ),
                                              key: key);
                                          await reloadUsers();
                                        } else {
                                          await saveUser(
                                            myUser: MyUser(
                                              id: user!.uid,
                                              name: _nameTextController
                                                  .value.text,
                                              iconName: iconsList[
                                                  selectedIconNotifier
                                                      .selectedIndex],
                                            ),
                                          );
                                        }

                                        if (mounted) {
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ShoppingChartScreen(),
                                            ),
                                            (route) => false,
                                          );
                                        }
                                      }
                                    }
                                  },
                                  style: ButtonStyle(
                                    fixedSize: const MaterialStatePropertyAll(
                                      Size(120, 20),
                                    ),
                                    backgroundColor: MaterialStatePropertyAll(
                                        Colors.green.shade100),
                                  ),
                                  child: const Text('Salva')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameTextController.dispose();

    super.dispose();
  }
}

class SelectorIcon extends StatefulWidget {
  const SelectorIcon({
    super.key,
    required this.selectedIconNotifier,
    required this.icon,
    required this.index,
    required this.onChangeSelection,
  });

  final SelectedIcon selectedIconNotifier;
  final String icon;
  final int index;
  final void Function(int tappedIndex) onChangeSelection;

  @override
  State<SelectorIcon> createState() => _SelectorIconState();
}

class _SelectorIconState extends State<SelectorIcon> {
  bool isSelected = false;

  @override
  void initState() {
    isSelected = widget.index == widget.selectedIconNotifier.selectedIndex;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.selectedIconNotifier,
      builder: (BuildContext context, Widget? child) => IconButton(
        key: UniqueKey(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        onPressed: () {
          widget.onChangeSelection(widget.index);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(
            widget.index == widget.selectedIconNotifier.selectedIndex
                ? Colors.lightBlueAccent
                : null,
          ),
          shape: const MaterialStatePropertyAll(CircleBorder()),
        ),
        icon: Image.asset(
          'assets/icons/${widget.icon}.png',
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
