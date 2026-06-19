import 'package:flutter_riverpod/flutter_riverpod.dart';

// 로그인 상태 관리 > Provider
// 지금은 null (로그아웃 상태)로 시작
// Task 2-1에서 Firebase 연동 후 실제 유저 정보로 채울 예정
final authStateProvider = StateProvider<String?>((ref) {
  return null; // null = 로그아웃 상태
});
