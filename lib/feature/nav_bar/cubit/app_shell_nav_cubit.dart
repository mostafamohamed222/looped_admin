import 'package:flutter_bloc/flutter_bloc.dart';

/// يتحكم في تبويب الشريط السفلي داخل [AppShellPage].
class AppShellNavCubit extends Cubit<int> {
  AppShellNavCubit() : super(dashboardTab);

  static const int settingsTab = 0;
  static const int requestsTab = 1;
  static const int dashboardTab = 2;

  void selectTab(int index) {
    if (index == state) return;
    if (index < settingsTab || index > dashboardTab) return;
    emit(index);
  }
}
