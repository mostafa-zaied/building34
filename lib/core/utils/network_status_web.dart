import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

bool isCurrentlyOnline() {
  try {
    final nav = globalContext['navigator'] as JSObject?;
    final onLine = nav?['onLine'] as JSBoolean?;
    return onLine?.toDart ?? true;
  } catch (_) {
    return true;
  }
}

Stream<bool> onlineStatusStream() {
  late StreamController<bool> ctrl;
  JSFunction? onOnlineFn;
  JSFunction? onOfflineFn;

  ctrl = StreamController<bool>.broadcast(
    onListen: () {
      try {
        onOnlineFn = (() {
          if (!ctrl.isClosed) ctrl.add(true);
        }).toJS;
        onOfflineFn = (() {
          if (!ctrl.isClosed) ctrl.add(false);
        }).toJS;
        globalContext.callMethod('addEventListener'.toJS, 'online'.toJS, onOnlineFn);
        globalContext.callMethod('addEventListener'.toJS, 'offline'.toJS, onOfflineFn);
      } catch (_) {}
    },
    onCancel: () {
      try {
        if (onOnlineFn != null) {
          globalContext.callMethod('removeEventListener'.toJS, 'online'.toJS, onOnlineFn);
        }
        if (onOfflineFn != null) {
          globalContext.callMethod('removeEventListener'.toJS, 'offline'.toJS, onOfflineFn);
        }
      } catch (_) {}
    },
  );

  return ctrl.stream;
}
