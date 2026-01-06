import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/train_model.dart';
import '../../services/train_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class TrainManagementScreen extends StatelessWidget {
  const TrainManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kereta', style: TextStyle(fontWeight: FontWeight.bold)),
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
            return const LoadingWidget(message: 'Memuat data kereta...');
          }

          if (trainService.trains.isEmpty) {
            return EmptyState(
              icon: Icons.train,
              title: 'Belum ada kereta',
              subtitle: 'Tap tombol + untuk menambah kereta baru',
              action: ElevatedButton.icon(
                onPressed: () => _showTrainForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Kereta'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => trainService.loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trainService.trains.length,
              itemBuilder: (context, index) {
                final train = trainService.trains[index];
                return _TrainListItem(
                  train: train,
                  onEdit: () => _showTrainForm(context, train),
                  onDelete: () => _confirmDelete(context, train),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTrainForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showTrainForm(BuildContext context, [Train? train]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TrainForm(train: train),
    );
  }

  void _confirmDelete(BuildContext context, Train train) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Hapus Kereta'),
          ],
        ),
        content: Text('Apakah Anda yakin ingin menghapus kereta ${train.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<TrainService>(context, listen: false).deleteTrain(train.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kereta berhasil dihapus'),
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

class _TrainListItem extends StatelessWidget {
  final Train train;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TrainListItem({
    required this.train,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Train icon with gradient
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getTypeColor(train.type),
                        _getTypeColor(train.type).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _getTypeColor(train.type).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.train, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        train.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getTypeColor(train.type).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              train.type,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(train.type),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            train.code,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.event_seat, size: 14, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Text(
                            '${train.totalSeats} kursi',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.wifi, size: 14, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              train.facilities.join(', '),
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
                  ),
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
        ),
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

class _TrainForm extends StatefulWidget {
  final Train? train;

  const _TrainForm({this.train});

  @override
  State<_TrainForm> createState() => _TrainFormState();
}

class _TrainFormState extends State<_TrainForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _seatsController = TextEditingController();
  String _selectedType = 'Eksekutif';
  List<String> _selectedFacilities = ['AC', 'Toilet'];
  bool _isLoading = false;

  final List<String> _availableFacilities = [
    'AC', 'Toilet', 'WiFi', 'Power Outlet', 'Restoranting', 'TV', 'Selimut', 'Bantal'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.train != null) {
      _nameController.text = widget.train!.name;
      _codeController.text = widget.train!.code;
      _seatsController.text = widget.train!.totalSeats.toString();
      _selectedType = widget.train!.type;
      _selectedFacilities = List.from(widget.train!.facilities);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      widget.train == null ? Icons.add_circle : Icons.edit,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.train == null ? 'Tambah Kereta Baru' : 'Edit Kereta',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              CustomTextField(
                label: 'Nama Kereta',
                controller: _nameController,
                prefixIcon: Icons.train,
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                label: 'Kode Kereta',
                controller: _codeController,
                prefixIcon: Icons.confirmation_number,
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Tipe Kereta',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.background,
                ),
                items: ['Eksekutif', 'Bisnis', 'Ekonomi'].map((t) => DropdownMenuItem(
                  value: t,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getTypeColor(t),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(t),
                    ],
                  ),
                )).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                label: 'Total Kursi',
                controller: _seatsController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.event_seat,
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              // Facilities selection
              const Text(
                'Fasilitas',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableFacilities.map((facility) {
                  final isSelected = _selectedFacilities.contains(facility);
                  return FilterChip(
                    label: Text(facility),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFacilities.add(facility);
                        } else {
                          _selectedFacilities.remove(facility);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              CustomButton(
                text: _isLoading ? 'Menyimpan...' : 'Simpan Kereta',
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final train = Train(
      id: widget.train?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      code: _codeController.text,
      type: _selectedType,
      facilities: _selectedFacilities,
      totalSeats: int.parse(_seatsController.text),
    );
    
    final service = Provider.of<TrainService>(context, listen: false);
    bool success;
    
    if (widget.train == null) {
      success = await service.addTrain(train);
    } else {
      success = await service.updateTrain(train);
    }
    
    setState(() => _isLoading = false);
    
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.train == null ? 'Kereta berhasil ditambahkan' : 'Kereta berhasil diupdate'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
