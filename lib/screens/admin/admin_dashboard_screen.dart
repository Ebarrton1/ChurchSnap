import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChurchSnapScreen(
      title: 'Admin',
      subtitle: 'Preview dashboard for church leaders.',
      children: [
        AppCard(
          child: ListTile(
            leading: Icon(Icons.favorite_rounded),
            title: Text('Prayer requests'),
            trailing: Text('12'),
          ),
        ),
        AppCard(
          child: ListTile(
            leading: Icon(Icons.event_available_rounded),
            title: Text('Event RSVPs'),
            trailing: Text('48'),
          ),
        ),
        AppCard(
          child: ListTile(
            leading: Icon(Icons.groups_rounded),
            title: Text('Volunteers'),
            trailing: Text('23'),
          ),
        ),
      ],
    );
  }
}
