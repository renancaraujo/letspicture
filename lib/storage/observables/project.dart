import 'package:letspicture/storage/project/project_file.dart';
import 'package:letspicture/storage/project/project_model.dart';
import 'package:mobx/mobx.dart';

part 'project.g.dart';

enum ProjectObservableState { ready, loading, error }

class ProjectObservable = _ProjectObservable with _$ProjectObservable;

abstract class _ProjectObservable with Store {
  _ProjectObservable.fromProject(this.value)
      : state = ProjectObservableState.loading;

  @observable
  ProjectObservableState state = ProjectObservableState.ready;

  @observable
  Project value;

  @action
  void setNewThumbnail(ProjectThumbnailFile thumbnailFile) {
    value = value..thumbnailFile = thumbnailFile;
  }

  @computed
  int get id => value.id;
}
