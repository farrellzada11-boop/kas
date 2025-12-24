<?php

namespace App\Controllers\Api;

use App\Controllers\BaseController;
use App\Models\BookingModel;
use App\Models\PassengerModel;
use App\Models\ScheduleModel;
use CodeIgniter\HTTP\ResponseInterface;

class BookingController extends BaseController
{
    protected BookingModel $bookingModel;
    protected PassengerModel $passengerModel;
    protected ScheduleModel $scheduleModel;

    public function __construct()
    {
        $this->bookingModel = new BookingModel();
        $this->passengerModel = new PassengerModel();
        $this->scheduleModel = new ScheduleModel();
    }

    public function index(): ResponseInterface
    {
        $userId = session()->get('user_id');
        $bookings = $this->bookingModel->getWithRelations(null, $userId);
        
        foreach ($bookings as &$booking) {
            $booking['passengers'] = $this->bookingModel->getPassengers($booking['id']);
        }

        return $this->response->setJSON([
            'status' => true,
            'data' => $bookings
        ]);
    }

    public function all(): ResponseInterface
    {
        // Admin only - get all bookings
        $bookings = $this->bookingModel->getWithRelations();
        
        foreach ($bookings as &$booking) {
            $booking['passengers'] = $this->bookingModel->getPassengers($booking['id']);
        }

        return $this->response->setJSON([
            'status' => true,
            'data' => $bookings
        ]);
    }

    public function show(int $id): ResponseInterface
    {
        $booking = $this->bookingModel->getWithRelations($id);

        if (!$booking) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Booking tidak ditemukan'
            ])->setStatusCode(404);
        }

        $booking['passengers'] = $this->bookingModel->getPassengers($id);

        return $this->response->setJSON([
            'status' => true,
            'data' => $booking
        ]);
    }

    public function create(): ResponseInterface
    {
        $userId = session()->get('user_id');
        
        if (!$userId) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Unauthorized'
            ])->setStatusCode(401);
        }

        $json = $this->request->getJSON(true);
        $scheduleId = $json['schedule_id'] ?? 0;
        $passengers = $json['passengers'] ?? [];

        // Get schedule
        $schedule = $this->scheduleModel->find($scheduleId);
        if (!$schedule) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Jadwal tidak ditemukan'
            ])->setStatusCode(404);
        }

        // Check available seats
        if ($schedule['available_seats'] < count($passengers)) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Kursi tidak mencukupi'
            ])->setStatusCode(400);
        }

        // Calculate total price
        $totalPrice = $schedule['price'] * count($passengers);

        // Create booking
        $bookingData = [
            'booking_code' => $this->bookingModel->generateBookingCode(),
            'user_id' => $userId,
            'schedule_id' => $scheduleId,
            'total_price' => $totalPrice,
            'status' => 'pending',
            'booking_date' => date('Y-m-d H:i:s'),
        ];

        $bookingId = $this->bookingModel->insert($bookingData);

        // Create passengers
        foreach ($passengers as $index => $passenger) {
            $this->passengerModel->insert([
                'booking_id' => $bookingId,
                'name' => $passenger['name'],
                'id_number' => $passenger['id_number'],
                'seat_number' => $passenger['seat_number'] ?? 'A' . ($index + 1),
            ]);
        }

        // Update available seats
        $this->scheduleModel->update($scheduleId, [
            'available_seats' => $schedule['available_seats'] - count($passengers)
        ]);

        $booking = $this->bookingModel->getWithRelations($bookingId);
        $booking['passengers'] = $this->bookingModel->getPassengers($bookingId);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Booking berhasil dibuat',
            'data' => $booking
        ])->setStatusCode(201);
    }

    public function confirm(int $id): ResponseInterface
    {
        $booking = $this->bookingModel->find($id);

        if (!$booking) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Booking tidak ditemukan'
            ])->setStatusCode(404);
        }

        $this->bookingModel->update($id, [
            'status' => 'confirmed',
            'payment_date' => date('Y-m-d H:i:s')
        ]);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Booking berhasil dikonfirmasi',
            'data' => $this->bookingModel->getWithRelations($id)
        ]);
    }

    public function cancel(int $id): ResponseInterface
    {
        $booking = $this->bookingModel->find($id);

        if (!$booking) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Booking tidak ditemukan'
            ])->setStatusCode(404);
        }

        // Restore seats
        $passengers = $this->bookingModel->getPassengers($id);
        $schedule = $this->scheduleModel->find($booking['schedule_id']);
        
        $this->scheduleModel->update($booking['schedule_id'], [
            'available_seats' => $schedule['available_seats'] + count($passengers)
        ]);

        $this->bookingModel->update($id, ['status' => 'cancelled']);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Booking berhasil dibatalkan',
            'data' => $this->bookingModel->getWithRelations($id)
        ]);
    }
}
