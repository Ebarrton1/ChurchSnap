class PrayerRequest {
  final String name;
  final String request;
  final bool isPrivate;

  const PrayerRequest({
    required this.name,
    required this.request,
    this.isPrivate = false,
  });
}
