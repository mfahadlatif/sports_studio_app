import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_studio/domain/providers/event_provider.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/presentation/widgets/event_card.dart';
import 'package:sports_studio/presentation/screens/events/event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch events if not loaded
    Future.microtask(() => context.read<EventProvider>().fetchEvents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Happening Now')),
      body: Consumer<EventProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.events.isEmpty) {
            return const Center(
              child: Text('No upcoming events. Check back later!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: provider.events.length,
            itemBuilder: (context, index) {
              final event = provider.events[index];
              return EventCard(
                event: event,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(event: event),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
