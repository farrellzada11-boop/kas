<?php

namespace App\Controllers\Api;

use App\Controllers\BaseController;
use App\Models\TrainModel;
use CodeIgniter\HTTP\ResponseInterface;

class TrainController extends BaseController
{
    protected TrainModel $trainModel;

    public function __construct()
    {
        $this->trainModel = new TrainModel();
    }

    public function index(): ResponseInterface
    {
        $trains = $this->trainModel->findAll();

        return $this->response->setJSON([
            'status' => true,
            'data' => $trains
        ]);
    }

    public function show(int $id): ResponseInterface
    {
        $train = $this->trainModel->find($id);

        if (!$train) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Kereta tidak ditemukan'
            ])->setStatusCode(404);
        }

        return $this->response->setJSON([
            'status' => true,
            'data' => $train
        ]);
    }

    public function create(): ResponseInterface
    {
        $json = $this->request->getJSON(true);

        $data = [
            'name' => $json['name'] ?? '',
            'code' => $json['code'] ?? '',
            'type' => $json['type'] ?? 'Ekonomi',
            'facilities' => json_encode($json['facilities'] ?? []),
            'total_seats' => $json['total_seats'] ?? 0,
        ];

        if (!$this->trainModel->validate($data)) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Validasi gagal',
                'errors' => $this->trainModel->errors()
            ])->setStatusCode(400);
        }

        $id = $this->trainModel->insert($data);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Kereta berhasil ditambahkan',
            'data' => $this->trainModel->find($id)
        ])->setStatusCode(201);
    }

    public function update(int $id): ResponseInterface
    {
        $train = $this->trainModel->find($id);

        if (!$train) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Kereta tidak ditemukan'
            ])->setStatusCode(404);
        }

        $json = $this->request->getJSON(true);

        $data = [];
        if (isset($json['name'])) $data['name'] = $json['name'];
        if (isset($json['code'])) $data['code'] = $json['code'];
        if (isset($json['type'])) $data['type'] = $json['type'];
        if (isset($json['facilities'])) $data['facilities'] = json_encode($json['facilities']);
        if (isset($json['total_seats'])) $data['total_seats'] = $json['total_seats'];

        $this->trainModel->update($id, $data);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Kereta berhasil diupdate',
            'data' => $this->trainModel->find($id)
        ]);
    }

    public function delete(int $id): ResponseInterface
    {
        $train = $this->trainModel->find($id);

        if (!$train) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Kereta tidak ditemukan'
            ])->setStatusCode(404);
        }

        $this->trainModel->delete($id);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Kereta berhasil dihapus'
        ]);
    }
}
