import 'package:flutter_riverpod/flutter_riverpod.dart';

class StepListNotifier extends StateNotifier<List<String>> {
  StepListNotifier() : super([]);

  void addStep(String step) {
    state = [...state, step];
  }

  void removeStep(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i]
    ];
  }

  void updateStep(String step, int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i] else step
    ];
  }

  void addAllStep(List<String> stepList) {
    state = stepList;
  }

  void drainList() {
    state = [];
  }
}

final stepListProvider = StateNotifierProvider<StepListNotifier, List<String>>(
    (ref) => StepListNotifier());
