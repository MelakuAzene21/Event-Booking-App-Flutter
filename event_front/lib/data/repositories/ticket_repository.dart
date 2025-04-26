import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:event_booking_app/core/config/api_config.dart';
import 'package:event_booking_app/core/utils/secure_storage.dart';
import 'package:event_booking_app/data/models/ticket_model.dart';

class TicketRepository {
  Future<List<TicketModel>> getUserTickets() async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userTicketsEndpoint}'),
      headers: {'Cookie': 'token=$token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TicketModel.fromJson(json)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> deleteTicket(String ticketId) async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.deleteTicketEndpoint}/$ticketId'),
      headers: {'Cookie': 'token=$token'},
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}