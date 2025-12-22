import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/item.dart';

class ApiService {
  // Platform-aware localhost configuration
  static String get _localhost {
    if (kIsWeb) {
      return 'localhost';
    } else if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine
      return '10.0.2.2';
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost directly
      return 'localhost';
    } else {
      // Default fallback
      return 'localhost';
    }
  }

  static String get baseUrl => 'http://$_localhost:8000/api/items.php';

  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  Future<List<Item>> fetchItems() async {
    try {
      log('Attempting to connect to: $baseUrl');

      final client = http.Client();

      final request = http.Request('GET', Uri.parse(baseUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      final response = await client.send(request).timeout(connectionTimeout);

      log('Response status: ${response.statusCode}');
      log('Response headers: ${response.headers}');

      final responseBody = await response.stream.bytesToString();
      log('Response body: $responseBody');

      client.close();

      if (response.statusCode == 200) {
        final body = json.decode(responseBody);

        if (body['data'] == null) {
          throw Exception(
            'Invalid API response structure: missing "data" field',
          );
        }

        log('Successfully fetched items from: $baseUrl');
        return (body['data'] as List).map((e) => Item.fromJson(e)).toList();
      } else {
        throw Exception('API Error ${response.statusCode}: $responseBody');
      }
    } on TimeoutException {
      final error = Exception(
        'Connection timeout after ${connectionTimeout.inSeconds} seconds',
      );
      log('Timeout error for $baseUrl: $error');
      throw error;
    } on SocketException catch (e) {
      final error = Exception('Network error: ${e.message}');
      log('Socket error for $baseUrl: $e');
      throw error;
    } on HttpException catch (e) {
      final error = Exception('HTTP error: ${e.message}');
      log('HTTP error for $baseUrl: $e');
      throw error;
    } catch (e, stack) {
      final error = Exception('Unexpected error: $e');
      log('Unexpected error for $baseUrl', error: e, stackTrace: stack);
      throw error;
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      log('Starting deleteItem request for id: $id using $baseUrl');

      final client = http.Client();

      final request = http.Request('DELETE', Uri.parse('$baseUrl?id=$id'));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      final response = await client.send(request).timeout(connectionTimeout);

      log('Delete response status: ${response.statusCode}');

      final responseBody = await response.stream.bytesToString();
      log('Delete response body: $responseBody');

      client.close();

      if (response.statusCode == 200) {
        log('Successfully deleted item $id from: $baseUrl');
        return;
      } else {
        throw Exception('Delete failed: $responseBody');
      }
    } on TimeoutException {
      final error = Exception(
        'Delete timeout after ${connectionTimeout.inSeconds} seconds',
      );
      log('Delete timeout error for $baseUrl: $error');
      throw error;
    } on SocketException catch (e) {
      final error = Exception('Delete network error: ${e.message}');
      log('Delete socket error for $baseUrl: $e');
      throw error;
    } catch (e, stack) {
      final error = Exception('Delete unexpected error: $e');
      log('Delete unexpected error for $baseUrl', error: e, stackTrace: stack);
      throw error;
    }
  }

  Future<Item> createItem(String name, double price) async {
    try {
      log(
        'Starting createItem request for name: $name, price: $price using $baseUrl',
      );

      final client = http.Client();

      final request = http.Request('POST', Uri.parse(baseUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      final body = json.encode({'name': name, 'price': price.toString()});
      request.body = body;

      final response = await client.send(request).timeout(connectionTimeout);

      log('Create response status: ${response.statusCode}');

      final responseBody = await response.stream.bytesToString();
      log('Create response body: $responseBody');

      client.close();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(responseBody);
        if (responseData['status'] == 'success') {
          // Refresh items list by fetching again
          log('Successfully created item from: $baseUrl');
          // Return a temporary item - the UI will refresh the list
          // NOTE: This item is missing id, description, and quantity.
          return Item(id: -1, name: name, price: price);
        } else {
          throw Exception(
            'Create failed: ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Create failed with status ${response.statusCode}: $responseBody',
        );
      }
    } on TimeoutException {
      final error = Exception(
        'Create timeout after ${connectionTimeout.inSeconds} seconds',
      );
      log('Create timeout error for $baseUrl: $error');
      throw error;
    } on SocketException catch (e) {
      final error = Exception('Create network error: ${e.message}');
      log('Create socket error for $baseUrl: $e');
      throw error;
    } catch (e, stack) {
      final error = Exception('Create unexpected error: $e');
      log('Create unexpected error for $baseUrl', error: e, stackTrace: stack);
      throw error;
    }
  }

  Future<Item> updateItem(int id, String name, double price) async {
    try {
      log(
        'Starting updateItem request for id: $id, name: $name, price: $price using $baseUrl',
      );

      final client = http.Client();

      // Try using POST with action parameter for update
      final request = http.Request('POST', Uri.parse(baseUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      final body = json.encode({
        'id': id,
        'name': name,
        'price': price.toString(),
        'action': 'update',
      });
      request.body = body;

      final response = await client.send(request).timeout(connectionTimeout);

      log('Update response status: ${response.statusCode}');

      final responseBody = await response.stream.bytesToString();
      log('Update response body: $responseBody');

      client.close();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        if (responseData['status'] == 'success') {
          log('Successfully updated item $id from: $baseUrl');
          // NOTE: This item is missing description and quantity.
          return Item(id: id, name: name, price: price);
        } else {
          throw Exception(
            'Update failed: ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Update failed with status ${response.statusCode}: $responseBody',
        );
      }
    } on TimeoutException {
      final error = Exception(
        'Update timeout after ${connectionTimeout.inSeconds} seconds',
      );
      log('Update timeout error for $baseUrl: $error');
      throw error;
    } on SocketException catch (e) {
      final error = Exception('Update network error: ${e.message}');
      log('Update socket error for $baseUrl: $e');
      throw error;
    } catch (e, stack) {
      final error = Exception('Update unexpected error: $e');
      log('Update unexpected error for $baseUrl', error: e, stackTrace: stack);
      throw error;
    }
  }
}
