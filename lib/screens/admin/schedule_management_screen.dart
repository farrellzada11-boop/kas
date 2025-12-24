import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../services/train_service.dart';
import '../../widgets/loading_widget.dart';

class ScheduleManagementScreen extends StatelessWidget {
  const ScheduleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Jadwal'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
      ),
      body: Consumer<TrainService>(
        builder: (context, trainService, _) {
          if (trainService.isLoading) {
            return const LoadingWidget(message: 'Memuat jadwal...');
          }

          if (trainService.schedules.isEmpty) {
            return const EmptyState(icon: Icons.schedule, title: 'Belum ada jadwal');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trainService.schedules.length,
            itemBuilder: (context, index) {
              final schedule = trainService.schedules[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(schedule.train.type, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                        ),
                        const SizedBox(width: 8),
                        Text(schedule.train.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('HH:mm').format(schedule.departureTime), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(schedule.origin.name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: AppColors.primary),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(DateFormat('HH:mm').format(schedule.arrivalTime), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(schedule.destination.name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(schedule.formattedPrice, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
                        Text('${schedule.availableSeats} kursi tersedia', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
