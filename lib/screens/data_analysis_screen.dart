import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DataAnalysisScreen extends StatefulWidget {
  const DataAnalysisScreen({super.key});

  @override
  State<DataAnalysisScreen> createState() => _DataAnalysisScreenState();
}

class _DataAnalysisScreenState extends State<DataAnalysisScreen> {
  Map<String, dynamic> _allData = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    Map<String, dynamic> data = {};
    
    for (String key in keys) {
      final value = prefs.get(key);
      data[key] = value;
    }
    
    setState(() {
      _allData = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Analysis'),
        backgroundColor: const Color(0xFF9C89B8),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Card
                Card(
                  color: const Color(0xFF9C89B8).withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📊 Data Summary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Total keys stored: ${_allData.length}'),
                        Text('Current time: ${DateTime.now()}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Activities
                if (_allData.containsKey('activities')) ...[
                  const Text(
                    '🎯 Your Activities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...((_allData['activities'] as List?) ?? [])
                              .map((activity) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text('• $activity'),
                                  )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Time tracking data
                const Text(
                  '⏱️ Time Tracking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._allData.entries
                    .where((e) => e.key.startsWith('total_seconds_'))
                    .map((entry) {
                  final date = entry.key.replaceAll('total_seconds_', '');
                  final seconds = entry.value as int;
                  final minutes = seconds ~/ 60;
                  final hours = minutes ~/ 60;
                  final remainingMins = minutes % 60;
                  
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today, color: Color(0xFF9C89B8)),
                      title: Text(date),
                      trailing: Text(
                        hours > 0 
                            ? '${hours}h ${remainingMins}m'
                            : '${minutes}m',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text('$seconds seconds total'),
                    ),
                  );
                }),
                
                const SizedBox(height: 16),
                
                // Settings
                const Text(
                  '⚙️ Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_allData.containsKey('daily_super_time'))
                          Text('Daily goal: ${_allData['daily_super_time']} minutes'),
                        if (_allData.containsKey('onboarding_complete'))
                          Text('Onboarding: ${_allData['onboarding_complete']}'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Raw data dump
                ExpansionTile(
                  title: const Text('🔍 Raw Data (Debug)'),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        const JsonEncoder.withIndent('  ').convert(_allData),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
