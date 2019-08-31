// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loading.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars

mixin _$LoadingObservable on _LoadingObservable, Store {
  final _$loadingSummaryAppbarAtom =
      Atom(name: '_LoadingObservable.loadingSummaryAppbar');

  @override
  ObservableList<bool> get loadingSummaryAppbar {
    _$loadingSummaryAppbarAtom.context
        .enforceReadPolicy(_$loadingSummaryAppbarAtom);
    _$loadingSummaryAppbarAtom.reportObserved();
    return super.loadingSummaryAppbar;
  }

  @override
  set loadingSummaryAppbar(ObservableList<bool> value) {
    _$loadingSummaryAppbarAtom.context.conditionallyRunInAction(() {
      super.loadingSummaryAppbar = value;
      _$loadingSummaryAppbarAtom.reportChanged();
    }, _$loadingSummaryAppbarAtom,
        name: '${_$loadingSummaryAppbarAtom.name}_set');
  }

  final _$_LoadingObservableActionController =
      ActionController(name: '_LoadingObservable');

  @override
  void updateLoadingInsertProject(bool value) {
    final _$actionInfo = _$_LoadingObservableActionController.startAction();
    try {
      return super.updateLoadingInsertProject(value);
    } finally {
      _$_LoadingObservableActionController.endAction(_$actionInfo);
    }
  }
}
