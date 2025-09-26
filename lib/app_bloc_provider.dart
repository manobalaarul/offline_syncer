import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

import 'di/di_module.dart';
import 'features/presentation/bloc/profile/profile_bloc.dart';

class AppBlocProvider {
  static List<SingleChildWidget> get providers {
    return [
      BlocProvider(
        create: (context) => ProfileBloc(sl(), sl())..add(GetProfileEvent()),
      ),
    ];
  }
}
