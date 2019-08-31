import 'package:letspicture_app/storage/config/file_manager.dart';
import 'package:letspicture_app/storage/observables/project.dart'
    show ProjectObservable;
import 'package:letspicture_app/storage/project/project_model.dart'
    show Project, ProjectRepository;
import 'package:mobx/mobx.dart';

part 'project_collection.g.dart';

enum ProjectCollectionObservableState { ready, loading, error }

class _ProjectCollectionObservable = __ProjectCollectionObservable
    with _$_ProjectCollectionObservable;

abstract class __ProjectCollectionObservable with Store {
  @observable
  ProjectCollectionObservableState state;

  @observable
  ObservableMap<int, ProjectObservable> projects;

  Future init() async {
    List<Project> rawProjects = await ProjectRepository.allProjects();
    _initProjects(rawProjects);
    for (Project project in rawProjects) {
      await FileUtils.instance.openProjectThumbnailFile(project);
      await FileUtils.instance.openProjectNiksFile(project);
    }
    updateState(ProjectCollectionObservableState.ready);
  }

  int _keySerializer(dynamic project) {
    return project.value.id;
  }

  ProjectObservable _valueSerializer(dynamic project) => project;

  @action
  void _initProjects(List<Project> rawProjects) {
    List<ProjectObservable> projectObservables =
        rawProjects.map((Project project) {
      return ProjectObservable.fromProject(project);
    }).toList();
    Map<int, ProjectObservable> map = Map<int, ProjectObservable>.fromIterable(
        projectObservables,
        key: _keySerializer,
        value: _valueSerializer);
    projects = ObservableMap.of(map);

    state = ProjectCollectionObservableState.loading;
  }

  @action
  void updateState(ProjectCollectionObservableState newState) {
    state = newState;
  }

  @action
  void insertProject(Project project) {
    projects.putIfAbsent(
        project.id, () => ProjectObservable.fromProject(project));
  }

  @action
  void removeProject(Project project) {
    projects.remove(project.id);
  }

  @computed
  ProjectObservable getById(int id) {
    return projects[id];
  }

  @computed
  List<ProjectObservable> get listProjects {
    return projects.values.toList().reversed.toList();
  }

  @computed
  bool get hasProjects {
    return listProjects.length > 0;
  }
}

final _ProjectCollectionObservable projectCollectionObservable =
    _ProjectCollectionObservable();
