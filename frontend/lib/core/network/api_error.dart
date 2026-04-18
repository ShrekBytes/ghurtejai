import 'package:dio/dio.dart';

/// Turns API failures into a short user-facing string (DRF `detail`, field errors, Dio).
String formatApiError(Object? error) {
  if (error == null) return 'Something went wrong. Try again.';
  if (error is DioException) {
    final data = error.response?.data;
    final fromData = _messageFromResponseData(data);
    if (fromData != null && fromData.isNotEmpty) return fromData;
    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }
    return 'Network error. Try again.';
  }
  return error.toString();
}

String? _messageFromResponseData(dynamic data) {
  if (data is Map<String, dynamic>) {
    final detail = data['detail'];
    if (detail is String && detail.isNotEmpty) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is String) return first;
    }
    final nonField = data['non_field_errors'];
    if (nonField is List && nonField.isNotEmpty) {
      final first = nonField.first;
      if (first is String) return first;
    }
    final parts = <String>[];
    data.forEach((key, value) {
      if (key == 'detail') return;
      if (value is List) {
        for (final v in value) {
          if (v is String) parts.add('$key: $v');
        }
      } else if (value is String) {
        parts.add('$key: $value');
      }
    });
    if (parts.isNotEmpty) return parts.join(' ');
  }
  if (data is String && data.isNotEmpty) return data;
  return null;
}
