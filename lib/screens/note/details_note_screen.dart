import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/auth/fire_auth.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/extensions/date_time_x.dart';
import 'package:my_family_app/providers/note/note_stream_provider.dart';
import 'package:my_family_app/services/note_service.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';

import '../../models/note.dart';

class DetailsNoteScreen extends StatefulWidget {
  const DetailsNoteScreen({
    super.key,
    required this.noteDataKey,
  });

  final String noteDataKey;

  @override
  State<DetailsNoteScreen> createState() => _DetailsNoteScreenState();
}

class _DetailsNoteScreenState extends State<DetailsNoteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.note,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final noteData = ref
              .watch(noteStreamProvider)
              .value!
              .firstWhereOrNull((element) => element.key == widget.noteDataKey);

          if (noteData != null) {
            final note = noteData.note;

            return PopScope(
              onPopInvoked: (bool) async {
                if (bool) {
                  await updateNote(newNoteData: noteData);
                }
              },
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: InkWell(
                      onTap: note.author == FireAuth.getUser()!.uid
                          ? () {
                              showDialog<void>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Cambia stato nota'),
                                    content: RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text:
                                                'Vuoi modificare lo stato attuale ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                          WidgetSpan(
                                            child: noteData.note
                                                .getWidgetFromState(),
                                            alignment:
                                                PlaceholderAlignment.middle,
                                          ),
                                          const TextSpan(
                                            text: '?',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              overflow: TextOverflow.fade,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: getNoteStateValues()
                                            .map(
                                              (state) => IconButton(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 28),
                                                onPressed: () {
                                                  setState(() {
                                                    note.state = state;
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                icon: getWidgetStateFromMap(
                                                    state),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          : null,
                      child: note.getWidgetFromState(),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 70),
                            child: Text(
                              textAlign: TextAlign.center,
                              note.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.black,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '${note.getAuthorNameFromId()} - ${note.creationDate.formatToItalian()}',
                            ),
                          ),
                          const Divider(height: 30),
                          Flexible(
                            child: CustomScrollView(
                              physics: const BouncingScrollPhysics(),
                              slivers: [
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Column(
                                    children: [
                                      Text(
                                        note.body,
                                        style: const TextStyle(
                                            fontSize: 18, height: 1.5),
                                      ),
                                      Expanded(child: Container()),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Image.asset('assets/cat-3-512.png',
                                              height: 60),
                                          Image.asset(
                                              'assets/kindpng_1052418.png',
                                              height: 40),
                                          Image.asset('assets/cat-3-512.png',
                                              height: 60),
                                          Image.asset(
                                              'assets/kindpng_1052418.png',
                                              height: 40),
                                          Image.asset('assets/cat-3-512.png',
                                              height: 60),
                                          Image.asset(
                                              'assets/kindpng_1052418.png',
                                              height: 40)
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            Future.delayed(Duration.zero, () {
              const snackbar = SnackBar(
                content: Text(
                  'Qualcuno ha cancellato la nota',
                  textScaler: TextScaler.linear(1.3),
                ),
                duration: Duration(seconds: 5),
                padding: EdgeInsets.all(24),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            });
            return const Center(
              child: SingleChildScrollView(
                  child: Center(child: CircularProgressIndicator())),
            );
          }
        },
      ),
    );
  }
}
