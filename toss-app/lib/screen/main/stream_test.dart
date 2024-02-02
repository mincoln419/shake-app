
import 'dart:async';

import 'package:fast_app_base/common/cli_common.dart';

Stream<int> countStream(int max) async* {
  for(int i = 1; i<=max; i++){
    yield i;
    await sleepAsync(1.seconds);
  }
}

final controller = StreamController<int>();
final stream = controller.stream;


main(){
  countStream(3).map((event) => '$event 초가 지났습니다.').listen((event) {
    print(event);
  });

  // stream.listen((event) {
  //   print(event);
  // });
  //
  // addDataToTheSink(controller);

}

void addDataToTheSink(StreamController<int> controller) async{

  for(int i = 1; i<= 4; i++){
    await sleepAsync(1.seconds);
    print('before add sink');
    controller.sink.add(i);
    print('after add sink');

  }
}