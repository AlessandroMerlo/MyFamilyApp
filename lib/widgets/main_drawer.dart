import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_family_app/auth/fire_auth.dart';
import 'package:my_family_app/screens/calendar/calendar_screen.dart';
import 'package:my_family_app/screens/freezer_item/freezer_screen.dart';
import 'package:my_family_app/screens/note/notes_screen.dart';
import 'package:my_family_app/screens/recipe/recipes_screen.dart';
import 'package:my_family_app/screens/scanner/scanner_screen.dart';
import 'package:my_family_app/screens/shopping_chart/shopping_chart_screen.dart';
import 'package:my_family_app/screens/user/add_name_screen.dart';
import 'package:my_family_app/screens/user/login_screen.dart';
import 'package:my_family_app/screens/what_where/what_where_screen.dart';
import 'package:my_family_app/services/user_service.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key, this.onNavigatorPush});

  final VoidCallback? onNavigatorPush;

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  User? user = FireAuth.getUser();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text('Lista della spesa'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShoppingChartScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: const Text('Ricette'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecipesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_rounded),
              title: const Text('Calendario'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Note'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.ac_unit),
              title: const Text('Freezer'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FreezerScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_mark_sharp),
              title: const Text('Dove Cosa'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WhatWhereScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_outlined),
              title: const Text('Scanner'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScannerScreen(),
                  ),
                );
              },
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/${myUsersList.firstWhere((element) => element.id == user!.uid).iconName}.png',
                        height: 24,
                      ),
                      title: Text(
                        user!.displayName!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.mode_edit,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () {
                          if (mounted) {
                            if (widget.onNavigatorPush != null) {
                              widget.onNavigatorPush!();
                            }

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AddNameScreen(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.mail_outline,
                        color: Colors.deepPurple,
                      ),
                      title: Text(
                        user!.email!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();

                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
