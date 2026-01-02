import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'timer_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _activities = [];
  int _dailySuperTime = 30;
  int _totalSecondsToday = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    setState(() {
      _activities = prefs.getStringList('activities') ?? [];
      _dailySuperTime = prefs.getInt('daily_super_time') ?? 30;
      _totalSecondsToday = prefs.getInt('total_seconds_$today') ?? 0;
    });
  }

  Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('activities', _activities);
  }

  Future<void> _addActivity() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _AddActivityDialog(),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _activities.add(result);
      });
      await _saveActivities();
    }
  }

  Future<void> _deleteActivity(int index) async {
    setState(() {
      _activities.removeAt(index);
    });
    await _saveActivities();
  }

  void _startActivity(String activity) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          activityName: activity,
          dailySuperTime: _dailySuperTime,
        ),
      ),
    );
  }

  Future<void> _openSettings() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
    
    // Reload data if settings changed
    if (result == true) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Super Time',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      IconButton(
                        onPressed: _openSettings,
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Color(0xFF9C89B8),
                        ),
                        iconSize: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatTime(_dailySuperTime)} for yourself today',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF666666),
                    ),
                  ),
                  if (_totalSecondsToday > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C89B8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Color(0xFF9C89B8),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Today: ${_formatDuration(_totalSecondsToday)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9C89B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Activities list
            Expanded(
              child: _activities.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.spa_outlined,
                              size: 64,
                              color: const Color(0xFF9C89B8).withOpacity(0.3),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No activities yet',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: const Color(0xFF999999),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Add things you enjoy doing\nto start your super time',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFFBBBBBB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        return _ActivityCard(
                          activity: _activities[index],
                          onTap: () => _startActivity(_activities[index]),
                          onDelete: () => _deleteActivity(index),
                        );
                      },
                    ),
            ),

            // Add button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _addActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C89B8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add Activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      if (minutes > 0) {
        return '$hours hr $minutes min';
      } else {
        return '$hours hr';
      }
    } else if (minutes > 0) {
      return '$minutes min';
    } else {
      return '$totalSeconds sec';
    }
  }
}

class _ActivityCard extends StatelessWidget {
  final String activity;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ActivityCard({
    required this.activity,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C89B8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Color(0xFF9C89B8),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    activity,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFFBBBBBB),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddActivityDialog extends StatefulWidget {
  const _AddActivityDialog();

  @override
  State<_AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<_AddActivityDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
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
              'Add activity',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'What do you enjoy?',
                hintText: 'e.g., Yoga, Reading, Walking...',
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
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
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
                    if (_controller.text.isNotEmpty) {
                      Navigator.pop(context, _controller.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C89B8),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
