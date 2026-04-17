class NicknameFilter {
  NicknameFilter._();

  static const _blocklist = [
    // 한국어 욕설
    '씨발', '시발', '씨팔', '시팔', '쉬발', '쉬팔',
    '개새끼', '개새', '새끼', '새키',
    '병신', '벙신', '븅신',
    '미친', '미친놈', '미친년',
    '존나', '존내', '졸나',
    '개년', '개놈', '개쓰레기',
    '보지', '자지', '보짓', '자짓',
    '창녀', '창년', '걸레',
    '꺼져', '뒤져', '뒤지',
    'ㅅㅂ', 'ㅂㅅ', 'ㅈㄹ', 'ㅁㅊ', 'ㅈㄴ',
    // 영어 욕설
    'fuck', 'fck', 'f*ck',
    'shit', 'sh*t',
    'bitch', 'b*tch',
    'asshole', 'ass',
    'bastard',
    'cunt',
    'dick', 'cock',
    'pussy',
    'nigger', 'nigga',
    'retard',
    'whore',
    'damn', 'hell',
  ];

  /// 닉네임 유효성 검사. null 반환 시 통과, String 반환 시 에러 메시지.
  static String? validate(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) return 'Nickname cannot be empty.';

    // 특수문자만 있는 경우
    final alphanumericPattern = RegExp(r'[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ]');
    if (!alphanumericPattern.hasMatch(trimmed)) {
      return 'Please include letters or numbers.';
    }

    // 금지어 포함 여부 (대소문자 무시)
    final lower = trimmed.toLowerCase();
    for (final word in _blocklist) {
      if (lower.contains(word.toLowerCase())) {
        return 'This nickname is not allowed.';
      }
    }

    return null;
  }
}
