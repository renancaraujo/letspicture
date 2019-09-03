// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_collection.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars

mixin _$_ProjectCollectionObservable on __ProjectCollectionObservable, Store {
  Computed<List<ProjectObservable>> _$listProjectsComputed;

  @override
  List<ProjectObservable> get listProjects => (_$listProjectsComputed ??=
          Computed<List<ProjectObservable>>(() => super.listProjects))
      .value;
  Computed<bool> _$hasProjectsComputed;

  @override
  bool get hasProjects =>
      (_$hasProjectsComputed ??= Computed<bool>(() => super.hasProjects)).value;

  final _$stateAtom = Atom(name: '__ProjectCollectionObservable.state');

  @override
  ProjectCollectionObservableState get state {
    _$stateAtom.context.enforceReadPolicy(_$stateAtom);
    _$stateAtom.reportObserved();
    return super.state;
  }

  @override
  set state(ProjectCollectionObservableState value) {
    _$stateAtom.context.conditionallyRunInAction(() {
      super.state = value;
      _$stateAtom.reportChanged();
    }, _$stateAtom, name: '${_$stateAtom.name}_set');
  }

  final _$projectsAtom = Atom(name: '__ProjectCollectionObservable.projects');

  @override
  ObservableMap<int, ProjectObservable> get projects {
    _$projectsAtom.context.enforceReadPolicy(_$projectsAtom);
    _$projectsAtom.reportObserved();
    return super.projects;
  }

  @override
  set projects(ObservableMap<int, ProjectObservable> value) {
    _$projectsAtom.context.conditionallyRunInAction(() {
      super.projects = value;
      _$projectsAtom.reportChanged();
    }, _$projectsAtom, name: '${_$projectsAtom.name}_set');
  }

  final _$__ProjectCollectionObservableActionController =
      ActionController(name: '__ProjectCollectionObservable');

  @override
  void _initProjects(List<Project> rawProjects) {
    final _$actionInfo =
        _$__ProjectCollectionObservableActionController.startAction();
    try {
      return super._initProjects(rawProjects);
    } finally {
      _$__ProjectCollectionObservableActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateState(ProjectCollectionObservableState newState) {
    final _$actionInfo =
        _$__ProjectCollectionObservableActionController.startAction();
    try {
      return super.updateState(newState);
    } finally {
      _$__ProjectCollectionObservableActionController.endAction(_$actionInfo);
    }
  }

  @override
  void insertProject(Project project) {
    final _$actionInfo =
        _$__ProjectCollectionObservableActionController.startAction();
    try {
      return super.insertProject(project);
    } finally {
      _$__ProjectCollectionObservableActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeProject(Project project) {
    final _$actionInfo =
        _$__ProjectCollectionObservableActionController.startAction();
    try {
      return super.removeProject(project);
    } finally {
      _$__ProjectCollectionObservableActionController.endAction(_$actionInfo);
    }
  }
}
