import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../models/paginated.dart';
import '../models/user.dart';
import 'dio_provider.dart';

final ghurtejaiApiProvider = Provider<GhurtejaiApi>((ref) {
  return GhurtejaiApi(ref.watch(dioProvider));
});

class GhurtejaiApi {
  GhurtejaiApi(this._dio);
  final Dio _dio;

  /// DRF may return a bare JSON list or a paginated `{"results": [...]}` map.
  static List<Map<String, dynamic>> _parseMapList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (data is Map) {
      final raw = data['results'];
      if (raw is List) {
        return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    }
    return [];
  }

  /// [emailOrUsername] is sent as `email` in the JSON body for API compatibility.
  Future<({AuthUser user, String access, String refresh})> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'auth/login/',
      data: {'email': emailOrUsername, 'password': password},
    );
    final data = res.data!;
    final u = AuthUser.fromJson(data['user'] as Map<String, dynamic>);
    final tokens = data['tokens'] as Map<String, dynamic>;
    return (
      user: u,
      access: tokens['access'] as String,
      refresh: tokens['refresh'] as String,
    );
  }

  Future<({AuthUser user, String access, String refresh})> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'auth/register/',
      data: {
        'email': email,
        'username': username,
        'password': password,
        'password_confirm': passwordConfirm,
        'first_name': firstName,
        'last_name': lastName,
      },
    );
    final data = res.data!;
    final u = AuthUser.fromJson(data['user'] as Map<String, dynamic>);
    final tokens = data['tokens'] as Map<String, dynamic>;
    return (
      user: u,
      access: tokens['access'] as String,
      refresh: tokens['refresh'] as String,
    );
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post<void>(
      'auth/logout/',
      data: {'refresh': refreshToken},
    );
  }

  Future<AuthUser> fetchProfile() async {
    final res = await _dio.get<Map<String, dynamic>>('auth/profile/me/');
    final data = res.data!;
    final user = Map<String, dynamic>.from(data['user'] as Map<String, dynamic>);
    final avatar = data['avatar'];
    if (avatar is String && avatar.trim().isNotEmpty) {
      user['avatar'] = avatar.trim();
    }
    return AuthUser.fromJson(user);
  }

  /// PATCH profile; [avatarFilePath] must be set (multipart upload).
  Future<AuthUser> patchMyProfile({required String avatarFilePath}) async {
    if (avatarFilePath.isEmpty) {
      throw ArgumentError('avatarFilePath must not be empty');
    }
    final formData = FormData();
    formData.files.add(
      MapEntry('avatar', await MultipartFile.fromFile(avatarFilePath)),
    );
    final res = await _dio.patch<Map<String, dynamic>>(
      'auth/profile/me/',
      data: formData,
    );
    final data = res.data!;
    final user = Map<String, dynamic>.from(data['user'] as Map<String, dynamic>);
    final avatar = data['avatar'];
    if (avatar is String && avatar.trim().isNotEmpty) {
      user['avatar'] = avatar.trim();
    }
    return AuthUser.fromJson(user);
  }

  Future<Map<String, dynamic>> fetchPublicProfile(String username) async {
    final res = await _dio.get<Map<String, dynamic>>('auth/profile/$username/');
    return res.data!;
  }

  Future<Paginated<Map<String, dynamic>>> fetchDestinations({
    String? nextUrl,
    String? nameContains,
  }) async {
    if (nextUrl != null) {
      final res = await _dio.getUri<Map<String, dynamic>>(Uri.parse(nextUrl));
      return Paginated.fromJson(res.data!, (m) => m);
    }
    final q = <String, dynamic>{};
    if (nameContains != null && nameContains.trim().isNotEmpty) {
      q['name'] = nameContains.trim();
    }
    final res = await _dio.get<Map<String, dynamic>>(
      'destinations/',
      queryParameters: q.isEmpty ? null : q,
    );
    return Paginated.fromJson(res.data!, (m) => m);
  }

  Future<Map<String, dynamic>> createDestination(Map<String, dynamic> body) async {
    final res = await _dio.post<Map<String, dynamic>>('destinations/', data: body);
    return res.data!;
  }

  Future<Map<String, dynamic>> createAttraction(Map<String, dynamic> body) async {
    final res = await _dio.post<Map<String, dynamic>>('destinations/attractions/', data: body);
    return res.data!;
  }

  Future<Map<String, dynamic>> createTransport(Map<String, dynamic> body) async {
    final res = await _dio.post<Map<String, dynamic>>('destinations/transports/', data: body);
    return res.data!;
  }

  Future<Map<String, dynamic>> fetchDestinationDetail(String slug) async {
    final res = await _dio.get<Map<String, dynamic>>('destinations/$slug/');
    return res.data!;
  }

  Future<Paginated<Map<String, dynamic>>> fetchExperiences({
    String? nextUrl,
    String? ordering,
    String? destinationSlug,
    String? tag,
    String? authorUsername,
    bool publishedOnly = false,
  }) async {
    if (nextUrl != null) {
      final res = await _dio.getUri<Map<String, dynamic>>(Uri.parse(nextUrl));
      return Paginated.fromJson(res.data!, (m) => m);
    }
    final q = <String, dynamic>{};
    if (ordering != null) q['ordering'] = ordering;
    if (destinationSlug != null) q['destination_slug'] = destinationSlug;
    if (tag != null) q['tag'] = tag;
    if (authorUsername != null) q['author'] = authorUsername;
    if (publishedOnly) q['published_only'] = 'true';
    final res = await _dio.get<Map<String, dynamic>>(
      'experiences/',
      queryParameters: q.isEmpty ? null : q,
    );
    return Paginated.fromJson(res.data!, (m) => m);
  }

  Future<Map<String, dynamic>> fetchExperienceDetail(String slug) async {
    final res = await _dio.get<Map<String, dynamic>>('experiences/$slug/');
    return res.data!;
  }

  Future<Paginated<Map<String, dynamic>>> fetchMyExperiences({
    String? nextUrl,
    String? scope,
    String? ordering,
  }) async {
    if (nextUrl != null) {
      final res = await _dio.getUri<Map<String, dynamic>>(Uri.parse(nextUrl));
      return Paginated.fromJson(res.data!, (m) => m);
    }
    final q = <String, dynamic>{};
    if (scope != null && scope.isNotEmpty && scope != 'all') {
      q['scope'] = scope;
    }
    if (ordering != null && ordering.isNotEmpty) {
      q['ordering'] = ordering;
    }
    final res = await _dio.get<Map<String, dynamic>>(
      'experiences/mine/',
      queryParameters: q.isEmpty ? null : q,
    );
    return Paginated.fromJson(res.data!, (m) => m);
  }

  /// Reddit-style: `value` 1 = up, -1 = down. Posting the same value again removes the vote.
  Future<void> voteExperience(int experienceId, int value) async {
    await _dio.post<void>(
      'interactions/vote/$experienceId/',
      data: {'value': value},
    );
  }

  Future<void> toggleExperienceBookmark(int experienceId) async {
    await _dio.post<void>('interactions/bookmarks/experience/$experienceId/');
  }

  Future<void> toggleDestinationBookmark(int destinationId) async {
    await _dio.post<void>('interactions/bookmarks/destination/$destinationId/');
  }

  Future<Paginated<Map<String, dynamic>>> fetchDestinationBookmarks({String? nextUrl}) async {
    if (nextUrl != null) {
      final res = await _dio.getUri<Map<String, dynamic>>(Uri.parse(nextUrl));
      return Paginated.fromJson(res.data!, (m) => m);
    }
    final res = await _dio.get<Map<String, dynamic>>(
      'interactions/bookmarks/destinations/',
    );
    return Paginated.fromJson(res.data!, (m) => m);
  }

  Future<Paginated<Map<String, dynamic>>> fetchExperienceBookmarks({String? nextUrl}) async {
    if (nextUrl != null) {
      final res = await _dio.getUri<Map<String, dynamic>>(Uri.parse(nextUrl));
      return Paginated.fromJson(res.data!, (m) => m);
    }
    final res = await _dio.get<Map<String, dynamic>>(
      'interactions/bookmarks/experiences/',
    );
    return Paginated.fromJson(res.data!, (m) => m);
  }

  Future<List<Map<String, dynamic>>> fetchComments(int experienceId) async {
    final res = await _dio.get<dynamic>(
      'interactions/comments/$experienceId/',
    );
    return _parseMapList(res.data);
  }

  Future<Map<String, dynamic>> postComment(
    int experienceId, {
    required String text,
    int? parentId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'interactions/comments/$experienceId/',
      data: {
        'experience': experienceId,
        'text': text,
        if (parentId != null) 'parent': parentId,
      },
    );
    return res.data!;
  }

  Future<void> voteComment(int commentId, int value) async {
    await _dio.post<void>(
      'interactions/comments/$commentId/vote/',
      data: {'value': value},
    );
  }

  Future<void> reportComment(int commentId, String reason) async {
    await _dio.post<void>(
      'interactions/reports/',
      data: {'comment': commentId, 'reason': reason},
    );
  }

  Future<Map<String, dynamic>> createExperience(Map<String, dynamic> body) async {
    final res = await _dio.post<Map<String, dynamic>>('experiences/', data: body);
    return res.data!;
  }

  Future<Map<String, dynamic>> updateExperience(String slug, Map<String, dynamic> body) async {
    final res = await _dio.patch<Map<String, dynamic>>('experiences/$slug/', data: body);
    return res.data!;
  }

  Future<void> deleteExperience(String slug) async {
    await _dio.delete<void>('experiences/$slug/');
  }

  Future<Map<String, dynamic>> cloneExperienceResult(String slug) async {
    final res = await _dio.post<Map<String, dynamic>>('experiences/$slug/clone/');
    return res.data!;
  }

  Future<Paginated<Map<String, dynamic>>> fetchNotifications({String? nextUrl}) async {
    if (nextUrl != null) {
      final res = await _dio.getUri<Map<String, dynamic>>(Uri.parse(nextUrl));
      return Paginated.fromJson(res.data!, (m) => m);
    }
    final res = await _dio.get<Map<String, dynamic>>('notifications/');
    return Paginated.fromJson(res.data!, (m) => m);
  }

  Future<void> markNotificationRead(int id) async {
    await _dio.post<void>('notifications/$id/read/');
  }

  Future<void> markAllNotificationsRead() async {
    await _dio.post<void>('notifications/read-all/');
  }

  Future<int> unreadNotificationCount() async {
    final res = await _dio.get<Map<String, dynamic>>('notifications/unread-count/');
    return (res.data?['unread_count'] as num?)?.toInt() ?? 0;
  }

  Future<Map<String, dynamic>> search(String q, {String type = 'all'}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'search/',
      queryParameters: {'q': q, 'type': type},
    );
    return res.data!;
  }

  Future<Map<String, dynamic>> searchSuggestions() async {
    final res = await _dio.get<Map<String, dynamic>>('search/suggestions/');
    return res.data!;
  }

  Future<Map<String, dynamic>> moderationQueue({String type = 'all'}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'moderation/queue/',
      queryParameters: {'type': type},
    );
    return res.data!;
  }

  Future<Map<String, dynamic>> moderationStats() async {
    final res = await _dio.get<Map<String, dynamic>>('moderation/stats/');
    return res.data!;
  }

  Future<void> moderateDestination(int pk, String action, {String? rejectionReason}) async {
    await _dio.post<Map<String, dynamic>>(
      'moderation/destination/$pk/',
      data: {
        'action': action,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      },
    );
  }

  Future<void> moderateAttraction(int pk, String action, {String? rejectionReason}) async {
    await _dio.post<Map<String, dynamic>>(
      'moderation/attraction/$pk/',
      data: {
        'action': action,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      },
    );
  }

  Future<void> moderateTransport(int pk, String action, {String? rejectionReason}) async {
    await _dio.post<Map<String, dynamic>>(
      'moderation/transport/$pk/',
      data: {
        'action': action,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      },
    );
  }

  Future<void> moderateExperience(int pk, String action, {String? rejectionReason}) async {
    await _dio.post<Map<String, dynamic>>(
      'moderation/experience/$pk/',
      data: {
        'action': action,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchTags() async {
    final res = await _dio.get<dynamic>('tags/');
    return _parseMapList(res.data);
  }

  Future<List<Map<String, dynamic>>> fetchDivisions() async {
    final res = await _dio.get<dynamic>('destinations/divisions/');
    return _parseMapList(res.data);
  }

  Future<List<Map<String, dynamic>>> fetchDistricts({int? divisionId}) async {
    final res = await _dio.get<dynamic>(
      'destinations/districts/',
      queryParameters: divisionId != null ? {'division': divisionId} : null,
    );
    return _parseMapList(res.data);
  }

  Future<List<Map<String, dynamic>>> fetchAttractions({
    required int destinationId,
    String? search,
  }) async {
    final res = await _dio.get<dynamic>(
      'destinations/attractions/',
      queryParameters: {
        'destination': destinationId,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return _parseMapList(res.data);
  }

  Future<Map<String, dynamic>> uploadImage(String filePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      'destinations/upload/image/',
      data: formData,
    );
    return res.data!;
  }

  static String mediaUrl(String? path) => AppConfig.resolveMediaUrl(path);
}
