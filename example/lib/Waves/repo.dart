import 'package:flutter_bloc/flutter_bloc.dart';
class LoadingBloc extends Bloc<bool,bool>{
  @override
  // TODO: implement initialState
  bool get initialState => false;

  @override
  Stream<bool> mapEventToState(bool event)async* {
    // TODO: implement mapEventToState
    if(event)
      yield true;
else
  yield false ;
  }

}
