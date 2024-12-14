// auth_service.dart
import 'api_services.dart';

class AuthService {
  final ApiService apiService;

  AuthService(this.apiService);



  Future<void> sendOtp({

    required String phone,

  }) async {
    await apiService.post('/send-otp', {

      'phone': phone,

    });
  }

  Future<void> verifyOtp({

    required String phone,

    required String otp,
  }) async {
    await apiService.post('/verify-otp', {

      'phone': phone,
     'otp':otp,

    });
  }





}
