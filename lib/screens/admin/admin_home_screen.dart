import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/train_service.dart';
import '../../services/booking_service.dart';
import '../auth/login_screen.dart';
import 'train_management_screen.dart';
import 'schedule_management_screen.dart';
import 'booking_management_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrainService>(context, listen: false).loadData();
      Provider.of<BookingService>(context, listen: false).loadAllBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<AuthService>(
                              builder: (context, auth, _) => Text(
                                'Halo, ${auth.currentUser?.name ?? 'Admin'}!',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white),
                              onPressed: () async {
                                await Provider.of<AuthService>(context, listen: false).logout();
                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const Text(
                          'Admin Dashboard',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: AppColors.primary,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  const Text('Menu Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildMenuGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Consumer2<TrainService, BookingService>(
      builder: (context, trainService, bookingService, _) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.7,
          children: [
            _StatCard(
              title: 'Total Kereta',
              value: '${trainService.trains.length}',
              icon: Icons.train,
              color: AppColors.primary,
            ),
            _StatCard(
              title: 'Total Stasiun',
              value: '${trainService.stations.length}',
              icon: Icons.location_on,
              color: AppColors.accent,
            ),
            _StatCard(
              title: 'Total Booking',
              value: '${bookingService.totalBookings}',
              icon: Icons.confirmation_number,
              color: AppColors.success,
            ),
            _StatCard(
              title: 'Pending',
              value: '${bookingService.pendingBookings}',
              icon: Icons.pending_actions,
              color: AppColors.warning,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _MenuCard(
          title: 'Kelola Kereta',
          icon: Icons.train,
          color: AppColors.primary,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainManagementScreen())),
        ),
        _MenuCard(
          title: 'Kelola Jadwal',
          icon: Icons.schedule,
          color: AppColors.accent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleManagementScreen())),
        ),
        _MenuCard(
          title: 'Kelola Booking',
          icon: Icons.book_online,
          color: AppColors.success,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingManagementScreen())),
        ),
        _MenuCard(
          title: 'Laporan',
          icon: Icons.bar_chart,
          color: AppColors.info,
          onTap: () {},
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
