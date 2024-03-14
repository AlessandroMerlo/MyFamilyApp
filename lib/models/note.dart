import 'package:flutter/material.dart';
import 'package:my_family_app/services/user_service.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

enum NoteState {
  noState,
  done,
  inProgress,
}

List<NoteState> getNoteStateValues() => NoteState.values;

const Map<NoteState, String> noteStateInItalian = {
  NoteState.noState: 'Nessuno',
  NoteState.done: 'Fatto',
  NoteState.inProgress: 'In corso'
};

String getItalianStringFromNoteState(NoteState noteState) =>
    noteStateInItalian[noteState]!;

Map<NoteState, Widget> _noteStateWidgetMap = {
  NoteState.noState: _stateIcon(
    const Color(0xFFF9A825),
    Icons.horizontal_rule_rounded,
    20,
  ),
  NoteState.done: _stateIcon(
    const Color(0xFF2E7D32),
    Icons.done,
    20,
  ),
  NoteState.inProgress: _stateIcon(
    const Color(0xFF1976D2),
    Icons.timer_outlined,
    18,
  ),
};

Widget getWidgetStateFromMap(NoteState state) => _noteStateWidgetMap[state]!;

class NoteData {
  NoteData({
    required this.key,
    required this.note,
  });

  final String key;
  final Note note;
}

class Note {
  Note({
    required this.id,
    required this.author,
    required this.creationDate,
    required this.state,
    required this.title,
    required this.body,
  });

  Note.withoutId({
    required this.author,
    creationDate,
    required this.state,
    required this.title,
    required this.body,
  }) : creationDate = creationDate ?? DateTime.now();

  Note copyWith({
    String? id,
    String? author,
    DateTime? creationDate,
    NoteState? state,
    String? title,
    String? body,
  }) =>
      Note(
        id: id ?? this.id,
        author: author ?? this.author,
        creationDate: creationDate ?? this.creationDate,
        state: state ?? this.state,
        title: title ?? this.title,
        body: body ?? this.body,
      );

  String? id;
  final String author;
  final DateTime creationDate;
  NoteState? state;
  final String title;
  final String body;

  Widget getWidgetFromState() => getWidgetStateFromMap(state!);

  Map<String, Object> toJson() => {
        'author': author,
        'creationDate': creationDate.toUtc().toIso8601String(),
        'state': state!.name,
        'title': title,
        'body': body,
      };

  Note.fromJson(Map<dynamic, dynamic> json)
      : author = json['author'],
        creationDate = DateTime.parse(json['creationDate'] as String).toLocal(),
        state = NoteState.values.byName(json['state']),
        title = json['title'],
        body = json['body'];

  String getAuthorNameFromId() {
    return myUsersList.firstWhere((user) => user.id == author).name;
  }
}

Widget _stateIcon(
  Color shapeColor,
  IconData icon,
  double iconSize,
) =>
    Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: shapeColor,
            boxShadow: const [BoxShadow(blurRadius: 2, offset: Offset(-1, 1))],
          ),
        ),
        Icon(
          icon,
          size: iconSize,
          color: Colors.white,
        )
      ],
    );
