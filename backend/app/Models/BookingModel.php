<?php

namespace App\Models;

use CodeIgniter\Model;

class BookingModel extends Model
{
    protected $table = 'bookings';
    protected $primaryKey = 'id';
    protected $useAutoIncrement = true;
    protected $returnType = 'array';
    protected $useSoftDeletes = false;
    protected $protectFields = true;
    protected $allowedFields = [
        'booking_code', 'user_id', 'schedule_id',
        'total_price', 'status', 'booking_date', 'payment_date'
    ];

    protected bool $allowEmptyInserts = false;
    protected bool $updateOnlyChanged = true;

    protected $useTimestamps = true;
    protected $dateFormat = 'datetime';
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';

    protected $validationRules = [
        'booking_code' => 'required|is_unique[bookings.booking_code,id,{id}]',
        'user_id' => 'required|integer',
        'schedule_id' => 'required|integer',
        'total_price' => 'required|decimal',
    ];

    protected $skipValidation = false;

    public function generateBookingCode(): string
    {
        $year = date('Y');
        $random = strtoupper(substr(md5(uniqid()), 0, 6));
        return "KAS-{$year}-{$random}";
    }

    public function getWithRelations(int $id = null, int $userId = null)
    {
        $builder = $this->db->table('bookings b')
            ->select('b.*, u.name as user_name, u.email as user_email,
                      s.departure_time, s.arrival_time, s.price as schedule_price,
                      t.name as train_name, t.code as train_code, t.type as train_type,
                      o.name as origin_name, o.code as origin_code,
                      d.name as destination_name, d.code as destination_code')
            ->join('users u', 'u.id = b.user_id')
            ->join('schedules s', 's.id = b.schedule_id')
            ->join('trains t', 't.id = s.train_id')
            ->join('stations o', 'o.id = s.origin_id')
            ->join('stations d', 'd.id = s.destination_id');
        
        if ($id) {
            return $builder->where('b.id', $id)->get()->getRowArray();
        }
        
        if ($userId) {
            $builder->where('b.user_id', $userId);
        }
        
        return $builder->orderBy('b.created_at', 'DESC')->get()->getResultArray();
    }

    public function getPassengers(int $bookingId): array
    {
        return $this->db->table('passengers')
            ->where('booking_id', $bookingId)
            ->get()->getResultArray();
    }
}
