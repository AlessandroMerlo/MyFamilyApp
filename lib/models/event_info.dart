import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@immutable
class EventInfo {
  final String uid;
  final String title;
  final String author;
  final bool isFullDayEvent;

  EventInfo({
    required this.title,
    required this.author,
    required this.isFullDayEvent,
  }) : uid = _uuid.v4();

  const EventInfo.withId({
    required this.uid,
    required this.title,
    required this.author,
    required this.isFullDayEvent,
  });

  factory EventInfo.fromJson(Map<dynamic, dynamic> json) {
    return EventInfo.withId(
        uid: json['uid'],
        title: json['title'],
        author: json['author'],
        isFullDayEvent: json['isFullDayEvent']);
  }

  Map<String, Object> toJson() => {
        'uid': uid,
        'title': title,
        'author': author,
        'isFullDayEvent': isFullDayEvent,
      };

  @override
  bool operator ==(Object other) => other is EventInfo && title == other.title;

  @override
  String toString() => title;
}
