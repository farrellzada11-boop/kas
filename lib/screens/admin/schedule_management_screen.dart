import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/schedule_model.dart';
import '../../models/train_model.dart';
import '../../models/station_model.dart';
import '../../services/train_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class ScheduleManagementScreen extends StatelessWidget {
  const ScheduleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Jadwal', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
        elevation: 0,
      ),
      body: Consumer<TrainService>(
        builder: (context, trainService, _) {
          if (trainService.isLoading) {
            return const LoadingWidget(message: 'Memuat jadwal...');
          }

          if (trainService.schedules.isEmpty) {
            return EmptyState(
              icon: Icons.schedule,
              title: 'Belum ada jadwal',
              subtitle: 'Tap tombol + untuk menambah jadwal baru',
              action: ElevatedButton.icon(
                onPressed: () => _showScheduleForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Jadwal'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => trainService.loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trainService.schedules.length,
              itemBuilder: (context, index) {
                final schedule = trainService.schedules[index];
                return _ScheduleListItem(
                  schedule: schedule,
                  onEdit: () => _showScheduleForm(context, schedule),
                  onDelete: () => _confirmDelete(context, schedule),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showScheduleForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showScheduleForm(BuildContext context, [Schedule? schedule]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ScheduleForm(schedule: schedule),
    );
  }

  void _confirmDelete(BuildContext context, Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Hapus Jadwal'),
          ],
        ),
        content: Text('Apakah Anda yakin ingin menghapus jadwal ${schedule.train.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<TrainService>(context, listen: false).deleteSchedule(schedule.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jadwal berhasil dihapus'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleListItem extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleListItem({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with train info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.1), AppColors.accent.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.train, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.train.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getTypeColor(schedule.train.type).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          schedule.train.type,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getTypeColor(schedule.train.type),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20, color: AppColors.primary),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppColors.error),
                          SizedBox(width: 12),
                          Text('Hapus', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Route info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(schedule.departureTime),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            schedule.origin.name,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            schedule.origin.city,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            schedule.formattedDuration,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.primary, AppColors.accent],
                                    ),
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_forward, color: AppColors.accent, size: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(schedule.arrivalTime),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            schedule.destination.name,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.end,
                          ),
                          Text(
                            schedule.destination.city,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today,
                        label: DateFormat('dd MMM yyyy').format(schedule.departureTime),
                      ),
                      Container(width: 1, height: 30, color: AppColors.divider),
                      _InfoChip(
                        icon: Icons.event_seat,
                        label: '${schedule.availableSeats} kursi',
                      ),
                      Container(width: 1, height: 30, color: AppColors.divider),
                      _InfoChip(
                        icon: Icons.attach_money,
                        label: schedule.formattedPrice,
                        isPrimary: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'eksekutif':
        return Colors.purple;
      case 'bisnis':
        return Colors.blue;
      case 'ekonomi':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: isPrimary ? AppColors.accent : AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
            color: isPrimary ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ScheduleForm extends StatefulWidget {
  final Schedule? schedule;

  const _ScheduleForm({this.schedule});

  @override
  State<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<_ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();
  
  Train? _selectedTrain;
  Station? _selectedOrigin;
  Station? _selectedDestination;
  DateTime _departureDate = DateTime.now();
  TimeOfDay _departureTime = TimeOfDay.now();
  TimeOfDay _arrivalTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 2);
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _departureDate = widget.schedule!.departureTime;
      _departureTime = TimeOfDay.fromDateTime(widget.schedule!.departureTime);
      _arrivalTime = TimeOfDay.fromDateTime(widget.schedule!.arrivalTime);
      _priceController.text = widget.schedule!.price.toStringAsFixed(0);
      _seatsController.text = widget.schedule!.availableSeats.toString();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.schedule != null) {
      final trainService = Provider.of<TrainService>(context, listen: false);
      // Find matching objects from the service list by ID
      _selectedTrain = trainService.trains.firstWhere(
        (t) => t.id == widget.schedule!.train.id,
        orElse: () => trainService.trains.isNotEmpty ? trainService.trains.first : widget.schedule!.train,
      );
      _selectedOrigin = trainService.stations.firstWhere(
        (s) => s.id == widget.schedule!.origin.id,
        orElse: () => trainService.stations.isNotEmpty ? trainService.stations.first : widget.schedule!.origin,
      );
      _selectedDestination = trainService.stations.firstWhere(
        (s) => s.id == widget.schedule!.destination.id,
        orElse: () => trainService.stations.isNotEmpty ? trainService.stations.first : widget.schedule!.destination,
      );
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trainService = Provider.of<TrainService>(context);
    
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.schedule == null ? Icons.add_circle : Icons.edit,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.schedule == null ? 'Tambah Jadwal Baru' : 'Edit Jadwal',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Train dropdown
              DropdownButtonFormField<Train>(
                value: _selectedTrain,
                decoration: InputDecoration(
                  labelText: 'Pilih Kereta',
                  prefixIcon: const Icon(Icons.train),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.background,
                ),
                items: trainService.trains.map((train) => DropdownMenuItem(
                  value: train,
                  child: Text('${train.name} (${train.type})'),
                )).toList(),
                onChanged: (v) => setState(() => _selectedTrain = v),
                validator: (v) => v == null ? 'Pilih kereta' : null,
              ),
              const SizedBox(height: 16),
              
              // Origin & Destination
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Station>(
                      value: _selectedOrigin,
                      decoration: InputDecoration(
                        labelText: 'Stasiun Asal',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                      items: trainService.stations.map((station) => DropdownMenuItem(
                        value: station,
                        child: Text(station.name, overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedOrigin = v),
                      validator: (v) => v == null ? 'Pilih stasiun' : null,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, color: AppColors.primary),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<Station>(
                      value: _selectedDestination,
                      decoration: InputDecoration(
                        labelText: 'Stasiun Tujuan',
                        prefixIcon: const Icon(Icons.flag),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                      items: trainService.stations.map((station) => DropdownMenuItem(
                        value: station,
                        child: Text(station.name, overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedDestination = v),
                      validator: (v) {
                        if (v == null) return 'Pilih stasiun';
                        if (v.id == _selectedOrigin?.id) return 'Harus berbeda';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal Keberangkatan',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  child: Text(DateFormat('EEEE, dd MMMM yyyy').format(_departureDate)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Jam Berangkat',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                        child: Text(_departureTime.format(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Jam Tiba',
                          prefixIcon: const Icon(Icons.access_time_filled),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                        child: Text(_arrivalTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Price & Seats
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Harga (Rp)',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Jumlah Kursi',
                      controller: _seatsController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.event_seat,
                      validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Submit button
              CustomButton(
                text: _isLoading ? 'Menyimpan...' : 'Simpan Jadwal',
                onPressed: _isLoading ? null : _submitForm,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _departureDate = date);
    }
  }

  Future<void> _selectTime(bool isDeparture) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isDeparture ? _departureTime : _arrivalTime,
    );
    if (time != null) {
      setState(() {
        if (isDeparture) {
          _departureTime = time;
        } else {
          _arrivalTime = time;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final departureDateTime = DateTime(
      _departureDate.year,
      _departureDate.month,
      _departureDate.day,
      _departureTime.hour,
      _departureTime.minute,
    );
    
    final arrivalDateTime = DateTime(
      _departureDate.year,
      _departureDate.month,
      _departureDate.day,
      _arrivalTime.hour,
      _arrivalTime.minute,
    );
    
    final schedule = Schedule(
      id: widget.schedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      train: _selectedTrain!,
      origin: _selectedOrigin!,
      destination: _selectedDestination!,
      departureTime: departureDateTime,
      arrivalTime: arrivalDateTime,
      price: double.parse(_priceController.text),
      availableSeats: int.parse(_seatsController.text),
    );
    
    final service = Provider.of<TrainService>(context, listen: false);
    bool success;
    
    if (widget.schedule == null) {
      success = await service.addSchedule(schedule);
    } else {
      success = await service.updateSchedule(schedule);
    }
    
    setState(() => _isLoading = false);
    
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.schedule == null ? 'Jadwal berhasil ditambahkan' : 'Jadwal berhasil diupdate'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
