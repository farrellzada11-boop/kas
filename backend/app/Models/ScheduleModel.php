<?php

namespace App\Models;

use CodeIgniter\Model;

class ScheduleModel extends Model
{
    protected $table = 'schedules';
    protected $primaryKey = 'id';
    protected $useAutoIncrement = true;
    protected $returnType = 'array';
    protected $useSoftDeletes = false;
    protected $protectFields = true;
    protected $allowedFields = [
        'train_id', 'origin_id', 'destination_id',
        'departure_time', 'arrival_time', 'price',
        'available_seats', 'is_active'
    ];

    protected bool $allowEmptyInserts = false;
    protected bool $updateOnlyChanged = true;

    protected $useTimestamps = true;
    protected $dateFormat = 'datetime';
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';

    protected $validationRules = [
        'train_id' => 'required|integer',
        'origin_id' => 'required|integer',
        'destination_id' => 'required|integer',
        'departure_time' => 'required|valid_date',
        'arrival_time' => 'required|valid_date',
        'price' => 'required|decimal',
        'available_seats' => 'required|integer',
    ];

    protected $skipValidation = false;

    public function getWithRelations(int $id = null)
    {
        $builder = $this->db->table('schedules s')
            ->select('s.*, t.name as train_name, t.code as train_code, t.type as train_type, t.facilities,
                      o.name as origin_name, o.code as origin_code, o.city as origin_city,
                      d.name as destination_name, d.code as destination_code, d.city as destination_city')
            ->join('trains t', 't.id = s.train_id')
            ->join('stations o', 'o.id = s.origin_id')
            ->join('stations d', 'd.id = s.destination_id');
        
        if ($id) {
            return $builder->where('s.id', $id)->get()->getRowArray();
        }
        
        return $builder->where('s.is_active', 1)->get()->getResultArray();
    }

    public function search(int $originId, int $destinationId, string $date = null)
    {
        $builder = $this->db->table('schedules s')
            ->select('s.*, t.name as train_name, t.code as train_code, t.type as train_type, t.facilities,
                      o.name as origin_name, o.code as origin_code, o.city as origin_city,
                      d.name as destination_name, d.code as destination_code, d.city as destination_city')
            ->join('trains t', 't.id = s.train_id')
            ->join('stations o', 'o.id = s.origin_id')
            ->join('stations d', 'd.id = s.destination_id')
            ->where('s.origin_id', $originId)
            ->where('s.destination_id', $destinationId)
            ->where('s.is_active', 1)
            ->where('s.available_seats >', 0);
        
        if ($date) {
            $builder->where('DATE(s.departure_time)', $date);
        }
        
        return $builder->orderBy('s.departure_time', 'ASC')->get()->getResultArray();
    }
}
