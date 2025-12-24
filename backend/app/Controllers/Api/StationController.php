<?php

namespace App\Controllers\Api;

use App\Controllers\BaseController;
use App\Models\StationModel;
use CodeIgniter\HTTP\ResponseInterface;

class StationController extends BaseController
{
    protected StationModel $stationModel;

    public function __construct()
    {
        $this->stationModel = new StationModel();
    }

    public function index(): ResponseInterface
    {
        $stations = $this->stationModel->findAll();

        return $this->response->setJSON([
            'status' => true,
            'data' => $stations
        ]);
    }

    public function show(int $id): ResponseInterface
    {
        $station = $this->stationModel->find($id);

        if (!$station) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Stasiun tidak ditemukan'
            ])->setStatusCode(404);
        }

        return $this->response->setJSON([
            'status' => true,
            'data' => $station
        ]);
    }

    public function create(): ResponseInterface
    {
        $json = $this->request->getJSON(true);

        $data = [
            'name' => $json['name'] ?? '',
            'code' => $json['code'] ?? '',
            'city' => $json['city'] ?? '',
            'address' => $json['address'] ?? null,
        ];

        if (!$this->stationModel->validate($data)) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Validasi gagal',
                'errors' => $this->stationModel->errors()
            ])->setStatusCode(400);
        }

        $id = $this->stationModel->insert($data);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Stasiun berhasil ditambahkan',
            'data' => $this->stationModel->find($id)
        ])->setStatusCode(201);
    }

    public function update(int $id): ResponseInterface
    {
        $station = $this->stationModel->find($id);

        if (!$station) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Stasiun tidak ditemukan'
            ])->setStatusCode(404);
        }

        $json = $this->request->getJSON(true);

        $data = [
            'name' => $json['name'] ?? $station['name'],
            'code' => $json['code'] ?? $station['code'],
            'city' => $json['city'] ?? $station['city'],
            'address' => $json['address'] ?? $station['address'],
        ];

        $this->stationModel->update($id, $data);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Stasiun berhasil diupdate',
            'data' => $this->stationModel->find($id)
        ]);
    }

    public function delete(int $id): ResponseInterface
    {
        $station = $this->stationModel->find($id);

        if (!$station) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Stasiun tidak ditemukan'
            ])->setStatusCode(404);
        }

        $this->stationModel->delete($id);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Stasiun berhasil dihapus'
        ]);
    }
}
