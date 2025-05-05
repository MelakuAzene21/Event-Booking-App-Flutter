import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:event_booking_app/core/config/api_config.dart';
import 'package:event_booking_app/data/models/event_model.dart';
import 'package:event_booking_app/core/utils/secure_storage.dart';

class EventRepository {
  Future<List<EventModel>> getEvents() async {
    final token = await SecureStorage.getToken();
    final Map<String, String> headers = token != null ? {'Authorization': 'Bearer $token'} : {};
    print('Get events headers: $headers'); // Debug: Log headers
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.eventsEndpoint}'),
      headers: headers,
    );

    print('Raw response body: ${response.body}'); // Debug: Log raw response

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      final List<dynamic> eventList = data is List ? data : data['events'] ?? [];
      if (eventList.isNotEmpty) {
        return eventList.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw Exception('No events found in response');
      }
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch events');
    }
  }

  Future<EventModel> getEventDetails(String id) async {
    final token = await SecureStorage.getToken();
    final Map<String, String> headers = token != null ? {'Authorization': 'Bearer $token'} : {};
    print('Get event details headers: $headers'); // Debug: Log headers
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.eventDetailsEndpoint}/$id'),
      headers: headers,
    );

    print('Raw event details response: ${response.body}'); // Debug: Log raw response

    if (response.statusCode == 200) {
      return EventModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch event details');
    }
  }

  Future<void> toggleBookmark(String eventId) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found. Please log in.');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    print('Toggle bookmark headers: $headers'); // Debug: Log headers
    print('Toggle bookmark URL: ${ApiConfig.baseUrl}/bookmarks/event/$eventId/toggle'); // Debug: Log URL

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/bookmarks/event/$eventId/toggle'),
      headers: headers,
    );

    print('Toggle bookmark response: ${response.statusCode} - ${response.body}'); // Debug: Log response

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please log in again.');
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to toggle bookmark');
    }
  }

  Future<List<EventModel>> getBookmarkedEvents() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found. Please log in.');
    }

    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    print('Get bookmarked events headers: $headers'); // Debug: Log headers
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/bookmarks/bookmarkedEvents'),
      headers: headers,
    );

    print('Get bookmarked events response: ${response.statusCode} - ${response.body}'); // Debug: Log response

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      if (data is List) {
        return data.map((json) => EventModel.fromJson(json)).toList();
      } else if (data is Map && data['events'] != null) {
        return (data['events'] as List).map((json) => EventModel.fromJson(json)).toList();
      } else {
        return []; // Return empty list if no events found
      }
    } else {
      final dynamic errorData = jsonDecode(response.body);
      final errorMessage = errorData is Map
          ? errorData['message'] ?? errorData['error'] ?? 'Failed to fetch bookmarked events'
          : errorData.toString();
      if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 404) {
        return []; // Handle "No bookmarks found" gracefully
      }
      throw Exception(errorMessage);
    }
  }
}