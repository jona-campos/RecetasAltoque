import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<List<ConnectivityResult>> get currentResult async {
    return await _connectivity.checkConnectivity();
  }

  void onConnectivityChanged(Function(ConnectivityResult) callback) {
    connectivityStream.listen((result) {
      debugPrint('Connectivity changed: $result');
      callback(result as ConnectivityResult);
    });
  }
}
