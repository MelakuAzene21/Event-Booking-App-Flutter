import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:event_booking_app/core/config/api_config.dart';
import 'package:event_booking_app/data/models/event_model.dart';

class EventRepository {
  Future<List<EventModel>> getEvents() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.eventsEndpoint}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<EventModel> getEventDetails(String id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.eventDetailsEndpoint}/$id'),
    );

    if (response.statusCode == 200) {
      return EventModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}