import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Dio get dio => _dio;

  Future<Response> getProfile() async {
    return await _dio.get('/profile');
  }

  Future<Response> getOrders() async {
    return await _dio.get('/orders');
  }

  Future<Response> getSubscriptions() async {
    return await _dio.get('/subscriptions');
  }

  Future<Response> subscribe(int packageId) async {
    return await _dio.post('/subscriptions/$packageId/subscribe');
  }

  Future<Response> checkTicket(String barcode) async {
    return await _dio.get('/tickets/check', queryParameters: {'barcode': barcode});
  }

  Future<Response> createOrder(List<Map<String, dynamic>> items, {int? tableId, String? ticketBarcode}) async {
    return await _dio.post('/orders', data: {
      'items': items,
      if (tableId != null) 'table_id': tableId,
      if (ticketBarcode != null && ticketBarcode.isNotEmpty) 'ticket_barcode': ticketBarcode,
    });
  }

  Future<Response> getLoyaltyDetails() async {
    return await _dio.get('/loyalty/details');
  }

  Future<Response> getLoyaltyOffers() async {
    return await _dio.get('/loyalty/offers');
  }

  Future<Response> subscribeToLoyaltyOffer(int offerId) async {
    return await _dio.post('/loyalty/offers/$offerId/subscribe');
  }

  Future<Response> getNotifications() async {
    return await _dio.get('/notifications');
  }

  Future<Response> getUnreadNotificationCount() async {
    return await _dio.get('/notifications/unread-count');
  }

  Future<Response> getMessages() async {
    return await _dio.get('/messages');
  }
}
