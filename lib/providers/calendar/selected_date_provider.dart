

// class SelectedDateNotifier extends StateNotifier<DateTime> {
//   SelectedDateNotifier() : super(DateTime.now());

//   Future<void> changeParameter(DateTime newDate) async {
//     state = newDate;

//     await Future.delayed(const Duration(milliseconds: 500));
//   }
// }

// final selectedDateProvider =
//     StateNotifierProvider<SelectedDateNotifier, DateTime>(
//         (ref) => SelectedDateNotifier());
