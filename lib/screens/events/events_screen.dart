import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/data_controller.dart';
import '../../core/constants.dart';
import '../../theme/app_colors.dart';
import 'event_tables_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  String? _getEventImageUrl(Map<String, dynamic> event) {
    String? rawUrl = event['artist_image_url'] ?? event['artist_image'];
    if (rawUrl == null || rawUrl.toString().trim().isEmpty) return null;

    String url = rawUrl.toString().trim();

    if (url.startsWith('http://') || url.startsWith('https://')) {
      // If server returned http://localhost without port 8001
      if (url.contains('localhost') && !url.contains(':8001')) {
        url = url.replaceFirst('http://localhost', 'http://127.0.0.1:8001');
      }
      return url;
    }

    // Relative path handling
    final storageBase = AppConstants.storageUrl; // http://127.0.0.1:8001/storage/
    final cleanPath = url.startsWith('/') ? url.substring(1) : url;
    if (cleanPath.startsWith('storage/')) {
      return '${AppConstants.baseUrl.replaceFirst('/api', '')}/$cleanPath';
    }
    return '$storageBase$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final DataController dataController = Get.find<DataController>();

    return Scaffold(
      body: Obx(() {
        if (dataController.isLoading.value && dataController.events.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (dataController.events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_busy, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text('لا توجد حفلات قادمة حالياً', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: dataController.fetchEvents,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: dataController.events.length,
            itemBuilder: (context, index) {
              final event = dataController.events[index];
              final imageUrl = _getEventImageUrl(Map<String, dynamic>.from(event));

              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // Dark background matching admin card
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.2), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (imageUrl != null)
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 2)),
                        ),
                        child: Image.network(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            color: AppColors.surface,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.music_note, size: 50, color: AppColors.primary),
                                SizedBox(height: 8),
                                Text('صورة الحفلة', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 180,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1a1a2e), Color(0xFF2e1a2e)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 2)),
                        ),
                        child: const Icon(Icons.star, size: 60, color: AppColors.primary),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['title'] ?? 'حفلة',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF0F0F0),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            event['description'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Color(0xFFD4AF37)),
                              const SizedBox(width: 6),
                              Text('${event['event_date']}', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13)),
                              const Spacer(),
                              const Icon(Icons.access_time, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text('${event['event_time']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                Get.to(() => EventTablesScreen(
                                  eventId: event['id'], 
                                  eventTitle: event['title'] ?? 'حفلة'
                                ));
                              },
                              child: const Text('حجز الحفلة', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
