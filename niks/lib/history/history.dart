import 'package:rebloc/rebloc.dart' as rebloc;

import 'package:niks/state/state.dart';

import '../niks.dart';
import 'actions.dart';
import 'core.dart';

export 'core.dart' show NiksHistoryState, NiksHistoryItem;

class NiksHistory {
  rebloc.Store<NiksHistoryState> _store;
  Niks skin;

  NiksHistory(this.skin, {int bufferSize = 10, String initialHistoryName}) {
    DateTime now = DateTime.now();
    String _name = initialHistoryName ?? now.toIso8601String();
    NiksStateSnapshot snapshot = skin.state.createSnapshot();
    final NiksHistoryItem historyItem = NiksHistoryItem(_name, snapshot, now);
    _store = rebloc.Store<NiksHistoryState>(
        initialState: NiksHistoryState([historyItem], 0, true),
        blocs: [NiksHistoryBloc(bufferSize)]);

    _addSkinSync();
  }

  Stream<NiksHistoryState> get stream => _store.states.stream;

  void _addSkinSync() {
    _store.states
        .where((NiksHistoryState state) => !state.updated)
        .listen((NiksHistoryState state) {
      skin.state.restoreFromSnapshot(state.activeSnapshot.snapshot);
    });
  }

  void dispose() {
    _store.states.close();
  }

  NiksStateSnapshot addHistory([String name]) {
    DateTime now = DateTime.now();
    String _name = name ?? now.toIso8601String();
    NiksStateSnapshot snapshot = skin.state.createSnapshot();
    final NiksHistoryItem historyItem = NiksHistoryItem(_name, snapshot, now);
    final AddHistoryAction action = AddHistoryAction(historyItem);
    _store.dispatch(action);
    return snapshot;
  }

  void undo([int n = 1]) {
    assert(n >= 0);
    final UndoAction action = UndoAction(n);
    _store.dispatch(action);
  }

  void redo([int n = 1]) {
    assert(n >= 0);
    final RedoAction action = RedoAction(n);
    _store.dispatch(action);
  }
}
