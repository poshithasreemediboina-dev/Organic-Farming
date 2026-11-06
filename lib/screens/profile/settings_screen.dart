import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _weatherAlerts = true;
  bool _offlineSync = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Application Settings'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Preferences
              _buildSectionHeader('Alerts & Notifications'),
              _buildCard([
                SwitchListTile(
                  value: _pushNotifications,
                  activeColor: AppColors.forestGreen,
                  title: const Text('Grievance Status Push Notifications', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Receive instant alerts when complaints change status', style: TextStyle(fontSize: 11.5)),
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _weatherAlerts,
                  activeColor: AppColors.forestGreen,
                  title: const Text('Daily Agro-Weather Advisory', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Smart organic recommendations based on rainfall and humidity', style: TextStyle(fontSize: 11.5)),
                  onChanged: (val) => setState(() => _weatherAlerts = val),
                ),
              ]),

              const SizedBox(height: 18),

              // Language & Regional Settings
              _buildSectionHeader('Regional Settings'),
              _buildCard([
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.forestGreen),
                  title: const Text('Primary Language', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  subtitle: Text(_selectedLanguage, style: const TextStyle(fontSize: 12)),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    underline: const SizedBox(),
                    items: ['English', 'Hindi', 'Marathi'].map((lang) {
                      return DropdownMenuItem(value: lang, child: Text(lang, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLanguage = val);
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _offlineSync,
                  activeColor: AppColors.forestGreen,
                  title: const Text('Offline Local Caching', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Store grievance forms & marketplace cache for offline access', style: TextStyle(fontSize: 11.5)),
                  onChanged: (val) => setState(() => _offlineSync = val),
                ),
              ]),

              const SizedBox(height: 18),

              // Database & Academic Project Info
              _buildSectionHeader('Architecture & Database'),
              _buildCard([
                const ListTile(
                  leading: Icon(Icons.cloud_done_rounded, color: AppColors.skyBlue),
                  title: Text('Backend Architecture', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  subtitle: Text('Cloud Firestore & Local Storage Engine with realtime in-app notifications', style: TextStyle(fontSize: 11.5)),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.webhook_rounded, color: AppColors.sunriseOrange),
                  title: Text('REST API Service', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  subtitle: Text('Open-Meteo Public API Integration with dynamic agronomic advisories', style: TextStyle(fontSize: 11.5)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.refresh_rounded, color: AppColors.forestGreen),
                  title: const Text('Re-seed Demo Database', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Reset mock complaints, users, and market products to initial state', style: TextStyle(fontSize: 11.5)),
                  trailing: TextButton(
                    onPressed: () async {
                      await DatabaseService().initialize();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Database reset and seed data loaded successfully!'),
                            backgroundColor: AppColors.statusResolved,
                          ),
                        );
                      }
                    },
                    child: const Text('Reset', style: TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),

              const SizedBox(height: 18),

              // About Card
              _buildCard([
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.forestGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.eco_rounded, color: AppColors.forestGreen, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                AppStrings.appName,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Text('Version 1.0.0 (Academic Build)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'GreenConnect is an academic mobile application built with Flutter, Provider state management, and Clean Architecture for sustainable agriculture and community grievance redressal.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.forestGreen),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(children: children),
    );
  }
}
