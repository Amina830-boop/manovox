import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EditEventPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _locationController;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ✅ Pre-fill all fields with existing event data
    _titleController =
        TextEditingController(text: widget.event['title'] ?? '');
    _descController =
        TextEditingController(text: widget.event['description'] ?? '');
    _locationController =
        TextEditingController(text: widget.event['location'] ?? '');

    // Parse existing date
    final rawDate = widget.event['date']?.toString();
    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(rawDate).toLocal();
      } catch (_) {
        _selectedDate = null;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF355E3B)),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedDate != null
          ? TimeOfDay.fromDateTime(_selectedDate!)
          : TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _updateEvent() async {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _selectedDate == null) {
      _showSnackBar('Please fill all fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final eventId =
        widget.event['id']?.toString() ?? widget.event['_id']?.toString();

    if (eventId == null) {
      _showSnackBar('Cannot update: event ID not found', isError: true);
      setState(() => _isLoading = false);
      return;
    }

    final result = await AuthService.updateEvent(
      id: eventId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      date: _selectedDate!.toUtc().toIso8601String(),
      location: _locationController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        _showSnackBar('Event updated successfully!');
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        _showSnackBar(result['message'] ?? 'Update failed', isError: true);
      }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Event',
          style: TextStyle(
            color: Color(0xFF355E3B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(_titleController, 'Event Title',
                'Enter event title', Icons.title),
            const SizedBox(height: 20),

            const Text('Description',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe your event...',
                hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                filled: true,
                fillColor: const Color(0xFFECF5EC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide:
                      const BorderSide(color: Color(0xFF355E3B), width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildField(_locationController, 'Location',
                'Enter location', Icons.location_on_outlined),
            const SizedBox(height: 20),

            const Text('Date & Time',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECF5EC),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Color(0xFF424242), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null
                          ? 'Select date and time'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}  ${_selectedDate!.hour}:${_selectedDate!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _selectedDate == null
                            ? const Color(0xFFBDBDBD)
                            : const Color(0xFF1A1A1A),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF355E3B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
            prefixIcon: Icon(icon, color: const Color(0xFF424242)),
            filled: true,
            fillColor: const Color(0xFFECF5EC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide:
                  const BorderSide(color: Color(0xFF355E3B), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}