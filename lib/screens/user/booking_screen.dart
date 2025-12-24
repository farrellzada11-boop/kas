import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/schedule_model.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class BookingScreen extends StatefulWidget {
  final Schedule schedule;
  final int passengerCount;

  const BookingScreen({
    super.key,
    required this.schedule,
    required this.passengerCount,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<_PassengerForm> _passengerForms;

  @override
  void initState() {
    super.initState();
    _passengerForms = List.generate(
      widget.passengerCount,
      (index) => _PassengerForm(index: index),
    );
  }

  double get _totalPrice => widget.schedule.price * widget.passengerCount;

  String get _formattedTotalPrice {
    return 'Rp ${_totalPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final bookingService = Provider.of<BookingService>(context, listen: false);

    if (authService.currentUser == null) return;

    final passengers = _passengerForms.map((form) {
      return Passenger(
        name: form.nameController.text,
        idNumber: form.idController.text,
        seatNumber: 'A${form.index + 1}',
      );
    }).toList();

    final booking = await bookingService.createBooking(
      user: authService.currentUser!,
      schedule: widget.schedule,
      passengers: passengers,
    );

    if (!mounted) return;

    if (booking != null) {
      _showSuccessDialog(booking);
    }
  }

  void _showSuccessDialog(Booking booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 60, color: AppColors.success),
            const SizedBox(height: 24),
            const Text('Booking Berhasil!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(booking.bookingCode,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
        actions: [
          CustomButton(
            text: 'Kembali',
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemesanan Tiket'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildScheduleSummary(),
            const SizedBox(height: 24),
            const Text('Data Penumpang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._passengerForms.map(_buildPassengerCard),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildScheduleSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(widget.schedule.train.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('HH:mm').format(widget.schedule.departureTime)),
              const Icon(Icons.arrow_forward, color: AppColors.primary),
              Text(DateFormat('HH:mm').format(widget.schedule.arrivalTime)),
            ],
          ),
          Text('${widget.schedule.origin.name} → ${widget.schedule.destination.name}'),
        ],
      ),
    );
  }

  Widget _buildPassengerCard(_PassengerForm form) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Penumpang ${form.index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Nama Lengkap',
            controller: form.nameController,
            validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'No. Identitas',
            controller: form.idController,
            validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(
        children: [
          Expanded(child: Text(_formattedTotalPrice, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accent))),
          Consumer<BookingService>(
            builder: (context, svc, _) => CustomButton(text: 'Pesan', isLoading: svc.isLoading, onPressed: _confirmBooking, width: 120),
          ),
        ],
      ),
    );
  }
}

class _PassengerForm {
  final int index;
  final nameController = TextEditingController();
  final idController = TextEditingController();
  _PassengerForm({required this.index});
}
