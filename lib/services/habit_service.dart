import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/habit.dart';
import '../models/habit_track.dart';
import 'auth_service.dart';

class HabitService {
  final String baseUrl;
  final AuthService authService;
  final http.Client _client = http.Client();

  HabitService({required this.baseUrl, required this.authService});

  // Helper debug function to print request details safely
  void _logRequest(Map<String, dynamic> json, String url) {
    final sanitizedJson = Map<String, dynamic>.from(json);

    // Add field-by-field checks
    print('Debug - habit JSON fields:');
    print(
      '- user_id: ${sanitizedJson['user_id']} (${sanitizedJson['user_id'].runtimeType})',
    );
    print('- name: ${sanitizedJson['name']}');
    print('- type: ${sanitizedJson['type']}');
    print('- created_at: ${sanitizedJson['created_at']}');
    print('- updated_at: ${sanitizedJson['updated_at']}');
    print('- frequency_unit: ${sanitizedJson['frequency_unit']}');

    // Print the full JSON as well
    final jsonString = json.toString();
    print('Full habit JSON: $jsonString');
    print('URL: $url');
  }

  // Get all habits for the current user
  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async {
    final headers = await authService.getAuthHeaders();
    final url = Uri.parse(
      '$baseUrl/habits${includeArchived ? '?include_archived=true' : ''}',
    );

    final response = await _client.get(url, headers: headers);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to get habits');
    }

    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Habit.fromJson(json)).toList();
  }

  // Get a single habit by ID
  Future<Habit> getHabit(int habitId) async {
    final headers = await authService.getAuthHeaders();
    final url = Uri.parse('$baseUrl/habits/$habitId');

    final response = await _client.get(url, headers: headers);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to get habit');
    }

    final data = json.decode(response.body);
    return Habit.fromJson(data);
  }

  // Create a new habit
  Future<Habit> createHabit(Habit habit) async {
    final headers = await authService.getAuthHeaders();
    // Make sure Content-Type header is properly set and overwrite any existing value
    headers['Content-Type'] = 'application/json';

    final url = Uri.parse('$baseUrl/habits'); // Print the request for debugging
    print('Creating habit with URL: $url');
    print('Headers: $headers');

    // Use the detailed logging function
    final habitJson = habit.toJson();
    _logRequest(habitJson, url.toString());
    _logRequest(habit.toJson(), url.toString());

    try {
      final response = await _client.post(
        url,
        headers: headers,
        body: json.encode(habit.toJson()),
      );

      // Print response for debugging
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode != 201) {
        try {
          final error = json.decode(response.body);
          // Log more detailed error information
          print('Server error message: ${error['error']}');
          print('Full server error response: $error');
          throw Exception(
            error['error'] ??
                'Failed to create habit (Status ${response.statusCode})',
          );
        } catch (e) {
          throw Exception(
            'Failed to create habit: Server returned status ${response.statusCode}',
          );
        }
      }

      final data = json.decode(response.body);
      return Habit.fromJson(data);
    } catch (e) {
      print('Error creating habit: $e');
      throw Exception('Failed to create habit: $e');
    }
  }

  // Update an existing habit
  Future<Habit> updateHabit(Habit habit) async {
    if (habit.id == null) {
      throw Exception('Cannot update habit without an ID');
    }
    final headers = await authService.getAuthHeaders();
    final url = Uri.parse('$baseUrl/habits/${habit.id}');

    final response = await _client.put(
      url,
      headers: headers,
      body: json.encode(habit.toJson()),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to update habit');
    }

    final data = json.decode(response.body);
    return Habit.fromJson(data);
  }

  // Delete (archive) a habit
  Future<void> deleteHabit(int habitId) async {
    final headers = await authService.getAuthHeaders();
    final url = Uri.parse('$baseUrl/habits/$habitId');

    final response = await _client.delete(url, headers: headers);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete habit');
    }
  }

  // Track a habit for a specific date
  Future<HabitTrackRecord> trackHabit(HabitTrackRecord record) async {
    final headers = await authService.getAuthHeaders();
    final url = Uri.parse('$baseUrl/habits/${record.habitId}/track');

    final response = await _client.post(
      url,
      headers: headers,
      body: json.encode(record.toJson()),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to track habit');
    }

    final data = json.decode(response.body);
    return HabitTrackRecord.fromJson(data);
  }

  // Get tracking records for a habit
  Future<List<HabitTrackRecord>> getTracking(
    int habitId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final headers = await authService.getAuthHeaders();

    var queryParams = '';
    if (startDate != null) {
      queryParams += '?start_date=${startDate.toIso8601String().split('T')[0]}';
    }
    if (endDate != null) {
      queryParams += queryParams.isEmpty ? '?' : '&';
      queryParams += 'end_date=${endDate.toIso8601String().split('T')[0]}';
    }

    final url = Uri.parse('$baseUrl/habits/$habitId/tracking$queryParams');

    final response = await _client.get(url, headers: headers);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to get tracking data');
    }

    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => HabitTrackRecord.fromJson(json)).toList();
  }

  // Get statistics for a habit
  Future<HabitStat> getStats(int habitId, {String period = 'weekly'}) async {
    final headers = await authService.getAuthHeaders();
    final url = Uri.parse('$baseUrl/habits/$habitId/stats?period=$period');

    final response = await _client.get(url, headers: headers);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to get habit stats');
    }

    final data = json.decode(response.body);
    return HabitStat.fromJson(data);
  }
}
