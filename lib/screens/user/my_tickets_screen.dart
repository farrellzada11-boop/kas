import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../widgets/ticket_card.dart';
import '../../widgets/loading_widget.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiket Saya'),
        centerTitle: true,
        leading: Navigator.canPop(context) ? IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ) : null,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Selesai'),
            Tab(text: 'Dibatalkan'),
          ],
        ),
      ),
      body: Consumer<BookingService>(
        builder: (context, bookingService, _) {
          if (bookingService.isLoading) {
            return const LoadingWidget(message: 'Memuat tiket...');
          }

          final bookings = bookingService.userBookings;
          final activeBookings = bookings
              .where((b) =>
                  b.status == BookingStatus.pending ||
                  b.status == BookingStatus.waitingConfirmation ||
                  b.status == BookingStatus.confirmed)
              .toList();
          final completedBookings = bookings
              .where((b) => b.status == BookingStatus.completed)
              .toList();
          final cancelledBookings = bookings
              .where((b) => b.status == BookingStatus.cancelled)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTicketList(activeBookings, 'Tidak ada tiket aktif'),
              _buildTicketList(completedBookings, 'Tidak ada riwayat perjalanan'),
              _buildTicketList(cancelledBookings, 'Tidak ada tiket dibatalkan'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketList(List<Booking> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return EmptyState(
        icon: Icons.confirmation_number_outlined,
        title: emptyMessage,
        subtitle: 'Tiket yang Anda pesan akan muncul di sini',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return TicketCard(
          booking: bookings[index],
          onTap: () => _showTicketDetail(bookings[index]),
        );
      },
    );
  }

  void _showTicketDetail(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Kode Booking',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            booking.bookingCode,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildInfoRow('Kereta', booking.schedule.train.name),
                    _buildInfoRow('Kelas', booking.schedule.train.type),
                    _buildInfoRow('Rute',
                        '${booking.schedule.origin.name} → ${booking.schedule.destination.name}'),
                    _buildInfoRow('Penumpang', '${booking.passengerCount} orang'),
                    _buildInfoRow('Total', booking.formattedTotalPrice),
                    _buildInfoRow('Status', booking.statusText),
                    const SizedBox(height: 24),
                    if (booking.status == BookingStatus.pending) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Provider.of<BookingService>(context, listen: false)
                                .payBooking(booking.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pembayaran berhasil! Menunggu konfirmasi admin.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                          child: const Text('Bayar Sekarang'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            await Provider.of<BookingService>(context, listen: false)
                                .cancelBooking(booking.id);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('Batalkan'),
                        ),
                      ),
                    ],
                    if (booking.status == BookingStatus.waitingConfirmation) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.hourglass_empty, color: AppColors.warning, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Menunggu Konfirmasi Admin',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Pembayaran Anda sedang diverifikasi',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
