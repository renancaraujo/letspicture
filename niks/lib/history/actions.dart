import 'package:rebloc/rebloc.dart';

import 'core.dart';

mixin NiksHistoryAction implements Action {
  NiksHistoryState execute(NiksHistoryState state);
}

class AddHistoryAction with NiksHistoryAction implements Action {
  final NiksHistoryItem historyItem;

  const AddHistoryAction(this.historyItem);

  @override
  NiksHistoryState execute(NiksHistoryState state) {
    final historyBuffer = [
      ...state.historyBuffer.sublist(0, state.activeIndex + 1),
      this.historyItem
    ];

    final int newActiveIndex = historyBuffer.length - 1;

    return NiksHistoryState(historyBuffer, newActiveIndex, true);
  }
}

class UndoAction with NiksHistoryAction implements Action {
  final int backwards;

  const UndoAction(this.backwards);

  @override
  NiksHistoryState execute(NiksHistoryState state) {
    final int newActiveIndex = state.activeIndex - backwards;
    return NiksHistoryState(state.historyBuffer,
        newActiveIndex.clamp(0, state.historyBuffer.length - 1), false);
  }
}

class RedoAction with NiksHistoryAction implements Action {
  final int forwards;

  const RedoAction(this.forwards);

  @override
  NiksHistoryState execute(NiksHistoryState state) {
    final int newActiveIndex = state.activeIndex + forwards;
    return NiksHistoryState(state.historyBuffer,
        newActiveIndex.clamp(0, state.historyBuffer.length - 1), false);
  }
}
