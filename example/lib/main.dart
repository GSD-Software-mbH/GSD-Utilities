import 'package:flutter/material.dart';
import 'package:gsd_utilities_example/upload_example.dart';
import 'config_example.dart';
import 'storage_example.dart';
import 'uri_example.dart';
import 'multilanguage_example.dart';
import 'notification_example.dart';

void main() {
  runApp(const GSDUtilitiesExampleApp());
}

/// Hauptklasse der Example-App für GSD Utilities
/// Demonstriert alle wichtigen Features der Library
class GSDUtilitiesExampleApp extends StatelessWidget {
  const GSDUtilitiesExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GSD Utilities Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

/// Hauptbildschirm mit Navigation zu den verschiedenen Examples
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GSD Utilities Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Willkommen zu den GSD Utilities Examples!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Diese App demonstriert alle wichtigen Features der GSD Utilities Library.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Konfigurationsmanagement
            _buildFeatureCard(
              context,
              title: 'Konfigurationsmanagement',
              description:
                  'Plattformübergreifende Konfigurationsverwaltung mit automatischer Persistierung',
              icon: Icons.settings,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ConfigExampleScreen()),
              ),
            ),

            const SizedBox(height: 16),

            // LocalStorage mit Events
            _buildFeatureCard(
              context,
              title: 'LocalStorage mit Events (Web)',
              description:
                  'Cross-Tab-Kommunikation und Storage-Event-Überwachung',
              icon: Icons.storage,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const StorageExampleScreen()),
              ),
            ),

            const SizedBox(height: 16),

            // DOCUframe Upload System
            _buildFeatureCard(
              context,
              title: 'DOCUframe Upload Manager',
              description:
                  'Enterprise Upload-System für DOCUframe mit Stream-basiertem Progress-Tracking',
              icon: Icons.cloud_upload,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UploadExampleScreen()),
              ),
            ),

            const SizedBox(height: 16),

            // URI Manager
            _buildFeatureCard(
              context,
              title: 'URI Manager (Web)',
              description: 'Browser URI-Manipulation',
              icon: Icons.link,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UriExample()),
              ),
            ),

            const SizedBox(height: 16),

            // Multi-Language System
            _buildFeatureCard(
              context,
              title: 'Multi-Language System',
              description: 'Internationalisierung mit Dependency Injection',
              icon: Icons.language,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MultiLanguageExampleScreen()),
              ),
            ),

            const SizedBox(height: 16),

            // Notification System
            _buildFeatureCard(
              context,
              title: 'Notification Helper (Web)',
              description:
                  'Browser-Benachrichtigungsberechtigungen und Browser-Erkennung',
              icon: Icons.notifications,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationExampleScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Erstellt eine Feature-Karte für die Navigation
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
