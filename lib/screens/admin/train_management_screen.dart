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
        title: const Text('Kelola Kereta'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
      ),
      body: Consumer<TrainService>(
        builder: (context, trainService, _) {
          if (trainService.isLoading) {
            return const LoadingWidget(message: 'Memuat data kereta...');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trainService.trains.length,
            itemBuilder: (context, index) {
              final train = trainService.trains[index];
              return _TrainListItem(train: train);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTrainForm(context),
        child: const Icon(Icons.add),
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
}

class _TrainListItem extends StatelessWidget {
  final Train train;

  const _TrainListItem({required this.train});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.train, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(train.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${train.code} • ${train.type}', style: const TextStyle(color: AppColors.textSecondary)),
                Text('${train.totalSeats} kursi', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                Provider.of<TrainService>(context, listen: false).deleteTrain(train.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
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

  @override
  void initState() {
    super.initState();
    if (widget.train != null) {
      _nameController.text = widget.train!.name;
      _codeController.text = widget.train!.code;
      _seatsController.text = widget.train!.totalSeats.toString();
      _selectedType = widget.train!.type;
    }
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
              Text(
                widget.train == null ? 'Tambah Kereta' : 'Edit Kereta',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              CustomTextField(label: 'Nama Kereta', controller: _nameController, validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              CustomTextField(label: 'Kode Kereta', controller: _codeController, validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Tipe Kereta'),
                items: ['Eksekutif', 'Bisnis', 'Ekonomi'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 16),
              CustomTextField(label: 'Total Kursi', controller: _seatsController, keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Simpan',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final train = Train(
                      id: widget.train?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      code: _codeController.text,
                      type: _selectedType,
                      facilities: widget.train?.facilities ?? ['AC', 'Toilet'],
                      totalSeats: int.parse(_seatsController.text),
                    );
                    final service = Provider.of<TrainService>(context, listen: false);
                    if (widget.train == null) {
                      service.addTrain(train);
                    } else {
                      service.updateTrain(train);
                    }
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
