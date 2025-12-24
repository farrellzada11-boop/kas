import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../widgets/loading_widget.dart';

class BookingManagementScreen extends StatelessWidget {
  const BookingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Booking'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
      ),
      body: Consumer<BookingService>(
        builder: (context, bookingService, _) {
          if (bookingService.isLoading) {
            return const LoadingWidget(message: 'Memuat booking...');
          }

          if (bookingService.bookings.isEmpty) {
            return const EmptyState(icon: Icons.book_online, title: 'Belum ada booking');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookingService.bookings.length,
            itemBuilder: (context, index) {
              final booking = bookingService.bookings[index];
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(booking.bookingCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        _buildStatusBadge(booking.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(booking.user.name, style: const TextStyle(color: AppColors.textSecondary)),
                    Text('${booking.schedule.origin.name} → ${booking.schedule.destination.name}'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${booking.passengerCount} penumpang'),
                        Text(booking.formattedTotalPrice, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
                      ],
                    ),
                    if (booking.status == BookingStatus.pending) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => bookingService.cancelBooking(booking.id),
                              child: const Text('Tolak'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => bookingService.confirmBooking(booking.id),
                              child: const Text('Konfirmasi'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case BookingStatus.pending:
        bgColor = AppColors.warning.withOpacity(0.2);
        textColor = Colors.orange.shade800;
        text = 'Pending';
        break;
      case BookingStatus.confirmed:
        bgColor = AppColors.success.withOpacity(0.2);
        textColor = Colors.green.shade800;
        text = 'Confirmed';
        break;
      case BookingStatus.completed:
        bgColor = AppColors.info.withOpacity(0.2);
        textColor = Colors.blue.shade800;
        text = 'Completed';
        break;
      case BookingStatus.cancelled:
        bgColor = AppColors.error.withOpacity(0.2);
        textColor = Colors.red.shade800;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
