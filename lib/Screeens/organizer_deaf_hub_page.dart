import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'create_event_page.dart';
import 'edit_event_page.dart'; // ← you will create this (file provided below)

class OrganizerDeafHubPage extends StatefulWidget {
  const OrganizerDeafHubPage({super.key});

  @override
  State<OrganizerDeafHubPage> createState() => _OrganizerDeafHubPageState();
}

class _OrganizerDeafHubPageState extends State<OrganizerDeafHubPage> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    final events = await AuthService.getEvents();
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  // ── Delete with confirmation dialog ──
  Future<void> _deleteEvent(Map<String, dynamic> event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Event',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete "${event['title']}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF757575))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final eventId = event['id']?.toString() ?? event['_id']?.toString();
    if (eventId == null) {
      _showSnackBar('Cannot delete: event ID not found', isError: true);
      return;
    }

    final result = await AuthService.deleteEvent(eventId);
    if (result['success']) {
      _showSnackBar('Event deleted successfully');
      _fetchEvents();
    } else {
      _showSnackBar(result['message'] ?? 'Delete failed', isError: true);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : const Color(0xFF355E3B),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Deaf Hub',
          style: TextStyle(
            color: Color(0xFF355E3B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateEventPage()),
                );
                _fetchEvents();
              },
              icon: const Icon(Icons.add, color: Color(0xFF355E3B)),
              label: const Text(
                'New Event',
                style: TextStyle(
                  color: Color(0xFF355E3B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEvents,
        color: const Color(0xFF355E3B),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF355E3B)))
            : _events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_note,
                            color: Colors.grey, size: 60),
                        const SizedBox(height: 12),
                        const Text('No events yet',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 16)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateEventPage()),
                            );
                            _fetchEvents();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF355E3B),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Create Event',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _events.length,
                    itemBuilder: (context, index) =>
                        _buildCard(_events[index]),
                  ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + action buttons ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                // ✅ Edit button
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditEventPage(event: event),
                      ),
                    );
                    _fetchEvents();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF355E3B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        size: 16, color: Color(0xFF355E3B)),
                  ),
                ),
                const SizedBox(width: 8),
                // ✅ Delete button
                GestureDetector(
                  onTap: () => _deleteEvent(event),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline,
                        size: 16, color: Colors.red),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              event['description'] ?? '',
              style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event['location'] ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9E9E9E)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF355E3B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    event['date']?.toString().length != null &&
                            event['date'].toString().length >= 10
                        ? event['date'].toString().substring(0, 10)
                        : event['date']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF355E3B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}