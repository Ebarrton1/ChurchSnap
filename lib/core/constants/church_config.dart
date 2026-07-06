enum WorshipDay { sabbath, sunday, both, custom }

class ChurchConfig {
  final String churchName;
  final String pastorName;
  final WorshipDay worshipDay;
  final String primaryServiceLabel;
  final String primaryServiceTime;
  final String address;

  const ChurchConfig({
    required this.churchName,
    required this.pastorName,
    required this.worshipDay,
    required this.primaryServiceLabel,
    required this.primaryServiceTime,
    required this.address,
  });

  String get welcomeGreeting {
    switch (worshipDay) {
      case WorshipDay.sabbath:
        return 'Happy Sabbath';
      case WorshipDay.sunday:
        return 'Good morning';
      case WorshipDay.both:
        return 'Welcome to worship';
      case WorshipDay.custom:
        return 'Welcome';
    }
  }

  String get worshipTitle {
    switch (worshipDay) {
      case WorshipDay.sabbath:
        return 'Sabbath Worship';
      case WorshipDay.sunday:
        return 'Sunday Worship';
      case WorshipDay.both:
        return 'Sabbath & Sunday Worship';
      case WorshipDay.custom:
        return primaryServiceLabel;
    }
  }
}

const churchConfig = ChurchConfig(
  churchName: 'ChurchSnap Church',
  pastorName: 'Pastor John',
  worshipDay: WorshipDay.both,
  primaryServiceLabel: 'Weekend Worship',
  primaryServiceTime: 'Sabbath 11:00 AM • Sunday 10:00 AM',
  address: '123 Faith Avenue • Your City',
);
