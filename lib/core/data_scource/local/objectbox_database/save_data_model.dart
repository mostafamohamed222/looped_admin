import 'package:objectbox/objectbox.dart';

@Entity()
class SaveDataModel {
  @Id()
  int id = 0;

  @Unique()
  String? key;
  String? value;

  SaveDataModel({this.key, this.value});
}
