// import 'package:local_auth/local_auth.dart';
//
// class BiometricHelper {
//   final LocalAuthentication _auth = LocalAuthentication();
//   final bool useFakeAuth;
//
//   BiometricHelper({this.useFakeAuth = false});
//
//   Future<bool> isBiometricAvailable() async {
//     if (useFakeAuth) return true;
//     try {
//       return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
//     } catch (e) {
//       print('Biometric availability error: $e');
//       return false;
//     }
//   }
//
//   Future<bool> authenticate() async {
//     if (useFakeAuth) {
//       print('✅ Using fake auth');
//       return Future.delayed(const Duration(seconds: 1), () => true);
//     }
//
//     try {
//       final result = await _auth.authenticate(
//         localizedReason: 'Please authenticate to login',
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: false,
//           useErrorDialogs: true,
//         ),
//       );
//
//       print('✅ Fingerprint Auth Result: $result');
//       return result;
//     } catch (e) {
//       print('Biometric auth error: $e');
//       return false;
//     }
//   }
// }
