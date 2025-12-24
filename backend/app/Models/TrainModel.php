<?php

namespace App\Models;

use CodeIgniter\Model;

class TrainModel extends Model
{
    protected $table = 'trains';
    protected $primaryKey = 'id';
    protected $useAutoIncrement = true;
    protected $returnType = 'array';
    protected $useSoftDeletes = false;
    protected $protectFields = true;
    protected $allowedFields = ['name', 'code', 'type', 'facilities', 'total_seats'];

    protected bool $allowEmptyInserts = false;
    protected bool $updateOnlyChanged = true;

    protected $useTimestamps = true;
    protected $dateFormat = 'datetime';
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';

    protected $validationRules = [
        'name' => 'required|min_length[2]|max_length[100]',
        'code' => 'required|min_length[2]|max_length[20]|is_unique[trains.code,id,{id}]',
        'type' => 'required|in_list[Eksekutif,Bisnis,Ekonomi]',
        'total_seats' => 'required|integer|greater_than[0]',
    ];

    protected $skipValidation = false;

    // Handle facilities as JSON - use callbacks instead of casts for compatibility
    protected function beforeInsert(array $data): array
    {
        return $this->handleFacilities($data);
    }

    protected function beforeUpdate(array $data): array
    {
        return $this->handleFacilities($data);
    }

    private function handleFacilities(array $data): array
    {
        if (isset($data['data']['facilities']) && is_array($data['data']['facilities'])) {
            $data['data']['facilities'] = json_encode($data['data']['facilities']);
        }
        return $data;
    }

    public function getAll(): array
    {
        $results = $this->findAll();
        return array_map(function($row) {
            if (isset($row['facilities']) && is_string($row['facilities'])) {
                $row['facilities'] = json_decode($row['facilities'], true) ?? [];
            }
            return $row;
        }, $results);
    }
}
