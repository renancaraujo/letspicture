import 'package:mobx/mobx.dart';

part 'loading.g.dart';

class LoadingObservable = _LoadingObservable with _$LoadingObservable;

abstract class _LoadingObservable with Store {
  @observable
  ObservableList<bool> loadingSummaryAppbar = ObservableList();

  @action
  void updateLoadingInsertProject(bool value) {
    if (value) {
      loadingSummaryAppbar.add(true);
    } else {
      loadingSummaryAppbar.removeLast();
    }
  }
}

final LoadingObservable loadingObservable = LoadingObservable();
