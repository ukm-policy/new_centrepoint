/// Inisial nama (maks. [max] huruf), aman untuk spasi ganda/kosong.
String initialsOf(String name, {int max = 2, String fallback = '?'}) {
  final initials = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(max)
      .map((part) => part[0])
      .join()
      .toUpperCase();
  return initials.isEmpty ? fallback : initials;
}
