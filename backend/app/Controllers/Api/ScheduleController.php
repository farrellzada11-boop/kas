<?php

namespace App\Controllers\Api;

use App\Controllers\BaseController;
use App\Models\ScheduleModel;
use CodeIgniter\HTTP\ResponseInterface;

class ScheduleController extends BaseController
{
    protected ScheduleModel $scheduleModel;

    public function __construct()
    {
        $this->scheduleModel = new ScheduleModel();
    }

    public function index(): ResponseInterface
    {
        $schedules = $this->scheduleModel->getWithRelations();

        return $this->response->setJSON([
            'status' => true,
            'data' => $schedules
        ]);
    }

    public function show(int $id): ResponseInterface
    {
        $schedule = $this->scheduleModel->getWithRelations($id);

        if (!$schedule) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Jadwal tidak ditemukan'
            ])->setStatusCode(404);
        }

        return $this->response->setJSON([
            'status' => true,
            'data' => $schedule
        ]);
    }

    public function search(): ResponseInterface
    {
        $originId = $this->request->getGet('origin_id');
        $destinationId = $this->request->getGet('destination_id');
        $date = $this->request->getGet('date');

        if (!$originId || !$destinationId) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Origin dan destination wajib diisi'
            ])->setStatusCode(400);
        }

        $schedules = $this->scheduleModel->search((int)$originId, (int)$destinationId, $date);

        return $this->response->setJSON([
            'status' => true,
            'data' => $schedules
        ]);
    }

    public function create(): ResponseInterface
    {
        $json = $this->request->getJSON(true);

        $data = [
            'train_id' => $json['train_id'] ?? 0,
            'origin_id' => $json['origin_id'] ?? 0,
            'destination_id' => $json['destination_id'] ?? 0,
            'departure_time' => $json['departure_time'] ?? '',
            'arrival_time' => $json['arrival_time'] ?? '',
            'price' => $json['price'] ?? 0,
            'available_seats' => $json['available_seats'] ?? 0,
            'is_active' => $json['is_active'] ?? true,
        ];

        if (!$this->scheduleModel->validate($data)) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Validasi gagal',
                'errors' => $this->scheduleModel->errors()
            ])->setStatusCode(400);
        }

        $id = $this->scheduleModel->insert($data);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Jadwal berhasil ditambahkan',
            'data' => $this->scheduleModel->getWithRelations($id)
        ])->setStatusCode(201);
    }

    public function update(int $id): ResponseInterface
    {
        $schedule = $this->scheduleModel->find($id);

        if (!$schedule) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Jadwal tidak ditemukan'
            ])->setStatusCode(404);
        }

        $json = $this->request->getJSON(true);

        $data = [];
        if (isset($json['train_id'])) $data['train_id'] = $json['train_id'];
        if (isset($json['origin_id'])) $data['origin_id'] = $json['origin_id'];
        if (isset($json['destination_id'])) $data['destination_id'] = $json['destination_id'];
        if (isset($json['departure_time'])) $data['departure_time'] = $json['departure_time'];
        if (isset($json['arrival_time'])) $data['arrival_time'] = $json['arrival_time'];
        if (isset($json['price'])) $data['price'] = $json['price'];
        if (isset($json['available_seats'])) $data['available_seats'] = $json['available_seats'];
        if (isset($json['is_active'])) $data['is_active'] = $json['is_active'];

        $this->scheduleModel->update($id, $data);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Jadwal berhasil diupdate',
            'data' => $this->scheduleModel->getWithRelations($id)
        ]);
    }

    public function delete(int $id): ResponseInterface
    {
        $schedule = $this->scheduleModel->find($id);

        if (!$schedule) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Jadwal tidak ditemukan'
            ])->setStatusCode(404);
        }

        $this->scheduleModel->delete($id);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Jadwal berhasil dihapus'
        ]);
    }
}
