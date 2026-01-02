import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _selectedMinutes = 30;
  final List<int> _timeOptions = [15, 30, 45, 60, 90, 120];
  int? _customMinutes;
  bool _isCustom = false;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setInt('daily_super_time', _isCustom ? (_customMinutes ?? 30) : _selectedMinutes);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              
              // Title
              Text(
                'Welcome to\nEnjoy Super Time',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: const Color(0xFF2D2D2D),
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Subtitle
              Text(
                'How much time per day do you want to give yourself?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF666666),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Time options
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _timeOptions.map((minutes) {
                  final isSelected = !_isCustom && _selectedMinutes == minutes;
                  return _TimeChip(
                    label: _formatTime(minutes),
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedMinutes = minutes;
                        _isCustom = false;
                      });
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Custom time option
              _TimeChip(
                label: _isCustom && _customMinutes != null 
                    ? _formatTime(_customMinutes!) 
                    : 'Custom',
                isSelected: _isCustom,
                onTap: () async {
                  final result = await showDialog<int>(
                    context: context,
                    builder: (context) => _CustomTimeDialog(
                      initialMinutes: _customMinutes ?? 30,
                    ),
                  );
                  
                  if (result != null) {
                    setState(() {
                      _customMinutes = result;
                      _isCustom = true;
                    });
                  }
                },
              ),
              
              const Spacer(flex: 3),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C89B8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '$hours hr';
      } else {
        return '$hours hr $mins min';
      }
    }
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF9C89B8) 
              : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF9C89B8) 
                : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF2D2D2D),
          ),
        ),
      ),
    );
  }
}

class _CustomTimeDialog extends StatefulWidget {
  final int initialMinutes;

  const _CustomTimeDialog({required this.initialMinutes});

  @override
  State<_CustomTimeDialog> createState() => _CustomTimeDialogState();
}

class _CustomTimeDialogState extends State<_CustomTimeDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMinutes.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom time',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Minutes per day',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF9C89B8),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final minutes = int.tryParse(_controller.text);
                    if (minutes != null && minutes > 0) {
                      Navigator.pop(context, minutes);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C89B8),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Set'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
