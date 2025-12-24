<?php

namespace App\Models;

use CodeIgniter\Model;

class PassengerModel extends Model
{
    protected $table = 'passengers';
    protected $primaryKey = 'id';
    protected $useAutoIncrement = true;
    protected $returnType = 'array';
    protected $useSoftDeletes = false;
    protected $protectFields = true;
    protected $allowedFields = ['booking_id', 'name', 'id_number', 'seat_number'];

    protected bool $allowEmptyInserts = false;
    protected bool $updateOnlyChanged = true;

    protected $useTimestamps = true;
    protected $dateFormat = 'datetime';
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';

    protected $validationRules = [
        'booking_id' => 'required|integer',
        'name' => 'required|min_length[2]|max_length[100]',
        'id_number' => 'required|min_length[5]|max_length[30]',
        'seat_number' => 'required|max_length[10]',
    ];

    protected $skipValidation = false;
}
