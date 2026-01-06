import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../widgets/loading_widget.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load all bookings when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingService>(context, listen: false).loadAllBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Booking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              Provider.of<BookingService>(context, listen: false).loadAllBookings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Memuat ulang data booking...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
      ),
      body: Consumer<BookingService>(
        builder: (context, bookingService, _) {
          if (bookingService.isLoading) {
            return const LoadingWidget(message: 'Memuat booking...');
          }

          if (bookingService.bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EmptyState(icon: Icons.book_online, title: 'Belum ada booking'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => bookingService.loadAllBookings(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => bookingService.loadAllBookings(),
            child: ListView.builder(
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('User belum membayar', style: TextStyle(color: AppColors.warning, fontSize: 12)),
                      ),
                    ],
                    if (booking.status == BookingStatus.waitingConfirmation) ...[
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
                    if (booking.status == BookingStatus.confirmed) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => bookingService.completeBooking(booking.id),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          child: const Text('Selesai'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
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
        text = 'Menunggu Bayar';
        break;
      case BookingStatus.waitingConfirmation:
        bgColor = Colors.purple.withOpacity(0.2);
        textColor = Colors.purple.shade800;
        text = 'Perlu Konfirmasi';
        break;
      case BookingStatus.confirmed:
        bgColor = AppColors.success.withOpacity(0.2);
        textColor = Colors.green.shade800;
        text = 'Dikonfirmasi';
        break;
      case BookingStatus.completed:
        bgColor = AppColors.info.withOpacity(0.2);
        textColor = Colors.blue.shade800;
        text = 'Selesai';
        break;
      case BookingStatus.cancelled:
        bgColor = AppColors.error.withOpacity(0.2);
        textColor = Colors.red.shade800;
        text = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
