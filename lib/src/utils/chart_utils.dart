// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../api/api.dart';
import 'day_helpers.dart';

/// The total value of one or more [Entry]s on a given day.
class EntryTotal {
  EntryTotal(this.day, this.value);

  final DateTime day;
  int value;
}

/// Returns a list of [EntryTotal] objects. Each [EntryTotal] is the sum of
/// the values of all the entries on a given day.
List<EntryTotal> entryTotalsByDay(List<Entry> entries, int daysAgo,
    {DateTime today}) {
  today ??= DateTime.now();
  return _entryTotalsByDay(entries, daysAgo, today).toList();
}

Iterable<EntryTotal> _entryTotalsByDay(
    List<Entry> entries, int daysAgo, DateTime today) sync* {
  final start = today.subtract(Duration(days: daysAgo));
  final entriesByDay = _entriesInRange(start, today, entries);

  for (var i = 0; i < entriesByDay.length; i++) {
    final list = entriesByDay[i];
    final entryTotal = EntryTotal(start.add(Duration(days: i)), 0);

    for (final entry in list) {
      entryTotal.value += entry.value;
    }

    yield entryTotal;
  }
}

/// Groups entries by day between [start] and [end]. The result is a list of
/// lists. The outer list represents the number of days since [start], and the
/// inner list is the group of entries on that day.
List<List<Entry>> _entriesInRange(
        DateTime start, DateTime end, List<Entry> entries) =>
    _entriesInRangeImpl(start, end, entries).toList();

Iterable<List<Entry>> _entriesInRangeImpl(
    DateTime start, DateTime end, List<Entry> entries) sync* {
  start = start.atMidnight;
  end = end.atMidnight;
  var d = start;

  while (d.compareTo(end) <= 0) {
    final es = <Entry>[];
    for (final entry in entries) {
      if (d.isSameDay(entry.time.atMidnight)) {
        es.add(entry);
      }
    }

    yield es;
    d = d.add(const Duration(days: 1));
  }
}
