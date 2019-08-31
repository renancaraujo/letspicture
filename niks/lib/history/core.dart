import 'package:niks/state/state.dart';
import 'package:rebloc/rebloc.dart';

import 'actions.dart';

class NiksHistoryItem {
  final String name;
  final DateTime timestamp;
  final NiksStateSnapshot snapshot;

  const NiksHistoryItem(this.name, this.snapshot, this.timestamp);
}

class NiksHistoryState {
  const NiksHistoryState(this.historyBuffer, this.activeIndex, this.updated);

  final int activeIndex;
  final List<NiksHistoryItem> historyBuffer;
  final bool updated;

  NiksHistoryItem get activeSnapshot {
    return historyBuffer[activeIndex];
  }
}

class NiksHistoryBloc extends SimpleBloc<NiksHistoryState> {
  NiksHistoryBloc(this.bufferSize);

  final int bufferSize;

  NiksHistoryState reducer(NiksHistoryState state, final Action action) {
    NiksHistoryState actionState = (action as NiksHistoryAction).execute(state);
    int currentBufferSize = actionState.historyBuffer.length;
    int start = currentBufferSize - bufferSize;
    if (start <= 0) {
      return actionState;
    }

    List newHistoryBuffer = actionState.historyBuffer.sublist(start);

    int newActiveIndex =
        actionState.activeIndex.clamp(0, newHistoryBuffer.length - 1);

    NiksHistoryState newState =
        NiksHistoryState(newHistoryBuffer, newActiveIndex, actionState.updated);

    return newState;
  }
}
