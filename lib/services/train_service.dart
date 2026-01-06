import 'package:flutter/foundation.dart';
import '../models/train_model.dart';
import '../models/station_model.dart';
import '../models/schedule_model.dart';
import '../config/app_constants.dart';
import 'mock_data.dart';
import 'api_service.dart';

class TrainService extends ChangeNotifier {
  List<Train> _trains = [];
  List<Station> _stations = [];
  List<Schedule> _schedules = [];
  List<Schedule> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  final ApiService _apiService = ApiService();

  List<Train> get trains => _trains;
  List<Station> get stations => _stations;
  List<Schedule> get schedules => _schedules;
  List<Schedule> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TrainService() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        _trains = MockData.trains;
        _stations = MockData.stations;
        _schedules = MockData.schedules;
      } else {
        // Load from API
        final trainsRes = await _apiService.get(AppConstants.trainsEndpoint);
        final stationsRes = await _apiService.get(AppConstants.stationsEndpoint);
        final schedulesRes = await _apiService.get(AppConstants.schedulesEndpoint);

        _trains = (trainsRes['data'] as List).map((e) => Train.fromJson(e)).toList();
        _stations = (stationsRes['data'] as List).map((e) => Station.fromJson(e)).toList();
        _schedules = (schedulesRes['data'] as List).map((e) => Schedule.fromJson(e)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchSchedules({
    required Station origin,
    required Station destination,
    required DateTime date,
  }) async {
    _isLoading = true;
    _searchResults = [];
    notifyListeners();

    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        _searchResults = MockData.searchSchedules(
          originId: origin.id,
          destinationId: destination.id,
          date: date,
        );
        if (_searchResults.isEmpty) {
          _searchResults = MockData.searchSchedules(
            originId: origin.id,
            destinationId: destination.id,
          );
        }
      } else {
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final response = await _apiService.get(
          '${AppConstants.schedulesEndpoint}/search?origin_id=${origin.id}&destination_id=${destination.id}&date=$dateStr',
        );
        _searchResults = (response['data'] as List).map((e) => Schedule.fromJson(e)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal mencari jadwal: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  // Admin CRUD
  Future<bool> addTrain(Train train) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        _trains.add(train);
      } else {
        await _apiService.post(AppConstants.trainsEndpoint, train.toJson());
        await loadData();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menambah kereta: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTrain(Train train) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        final index = _trains.indexWhere((t) => t.id == train.id);
        if (index != -1) _trains[index] = train;
      } else {
        await _apiService.put('${AppConstants.trainsEndpoint}/${train.id}', train.toJson());
        await loadData();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal mengupdate kereta: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTrain(String trainId) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        _trains.removeWhere((t) => t.id == trainId);
      } else {
        await _apiService.delete('${AppConstants.trainsEndpoint}/$trainId');
        await loadData();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menghapus kereta: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addStation(Station station) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        _stations.add(station);
      } else {
        await _apiService.post(AppConstants.stationsEndpoint, station.toJson());
        await loadData();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menambah stasiun: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addSchedule(Schedule schedule) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        _schedules.add(schedule);
      } else {
        await _apiService.post(AppConstants.schedulesEndpoint, schedule.toJson());
        await loadData();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menambah jadwal: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSchedule(Schedule schedule) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        final index = _schedules.indexWhere((s) => s.id == schedule.id);
        if (index != -1) _schedules[index] = schedule;
      } else {
        await _apiService.put('${AppConstants.schedulesEndpoint}/${schedule.id}', schedule.toJson());
        await loadData();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal mengupdate jadwal: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        _schedules.removeWhere((s) => s.id == scheduleId);
      } else {
        await _apiService.delete('${AppConstants.schedulesEndpoint}/$scheduleId');
        await loadData();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menghapus jadwal: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
