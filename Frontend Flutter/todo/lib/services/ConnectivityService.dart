// Importation connectivity_plus
import 'package:connectivity_plus/connectivity_plus.dart';

// Classe ConnectivityService pour vérifier online/offline
class ConnectivityService {
  // Méthode pour vérifier si online
  Future<bool> isOnline() async {
    // Récupération du statut de connexion
    final connectivityResult = await Connectivity().checkConnectivity();
    // Retourne true si wifi ou mobile
    return connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile;
  }

  // Stream pour écouter les changements de connexion
  Stream<List<ConnectivityResult>> get connectivityStream =>
      Connectivity().onConnectivityChanged;
}
