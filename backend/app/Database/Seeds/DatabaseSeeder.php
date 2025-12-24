<?php

namespace App\Database\Seeds;

use CodeIgniter\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        // Seed Users
        $users = [
            [
                'name' => 'Admin KAS',
                'email' => 'admin@mail.com',
                'password' => password_hash('password', PASSWORD_DEFAULT),
                'phone' => '08123456789',
                'role' => 'admin',
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ],
            [
                'name' => 'User Demo',
                'email' => 'user@mail.com',
                'password' => password_hash('password', PASSWORD_DEFAULT),
                'phone' => '08987654321',
                'role' => 'user',
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ],
        ];
        $this->db->table('users')->insertBatch($users);

        // Seed Stations
        $stations = [
            ['name' => 'Gambir', 'code' => 'GMR', 'city' => 'Jakarta', 'address' => 'Jl. Medan Merdeka Timur', 'created_at' => date('Y-m-d H:i:s'), 'updated_at' => date('Y-m-d H:i:s')],
            ['name' => 'Bandung', 'code' => 'BD', 'city' => 'Bandung', 'address' => 'Jl. Stasiun Timur', 'created_at' => date('Y-m-d H:i:s'), 'updated_at' => date('Y-m-d H:i:s')],
            ['name' => 'Surabaya Gubeng', 'code' => 'SGU', 'city' => 'Surabaya', 'address' => 'Jl. Gubeng Masjid', 'created_at' => date('Y-m-d H:i:s'), 'updated_at' => date('Y-m-d H:i:s')],
            ['name' => 'Yogyakarta', 'code' => 'YK', 'city' => 'Yogyakarta', 'address' => 'Jl. Margo Utomo', 'created_at' => date('Y-m-d H:i:s'), 'updated_at' => date('Y-m-d H:i:s')],
            ['name' => 'Semarang Tawang', 'code' => 'SMT', 'city' => 'Semarang', 'address' => 'Jl. Taman Tawang', 'created_at' => date('Y-m-d H:i:s'), 'updated_at' => date('Y-m-d H:i:s')],
        ];
        $this->db->table('stations')->insertBatch($stations);

        // Seed Trains
        $trains = [
            ['name' => 'Argo Bromo Anggrek', 'code' => 'ABA', 'type' => 'Eksekutif', 'facilities' => json_encode(['AC', 'Toilet', 'Restoran', 'WiFi']), 'total_seats' => 50, 'created_at' => date('Y-m-d H:i:s'), 'updated_at' => date('Y-m-d H:i:s')],
            ['name' => 'Argo Parahyangan', 'code' => 'AP', 'type' => 'Eksekutif', 'facilities' => json_encode(['AC', 'Toilet', 'WiFi']), 'total_seats' => 50, 'created_at' => date('Y-m-d H:i:s'), 'updated_at' => date('Y-m-d H:i:s')],
            ['name' => 'Lodaya', 'code' => 'LDY', 'type' => 'Bisnis', 'facilities' => json_encode(['AC', 'Toilet']), 'total_seats' => 80, 'created_at' => date('Y-m-d H:i:s'), 'updated_at' => date('Y-m-d H:i:s')],
            ['name' => 'Mataram', 'code' => 'MTR', 'type' => 'Ekonomi', 'facilities' => json_encode(['Toilet']), 'total_seats' => 100, 'created_at' => date('Y-m-d H:i:s'), 'updated_at' => date('Y-m-d H:i:s')],
        ];
        $this->db->table('trains')->insertBatch($trains);

        // Seed Schedules (tomorrow's schedules)
        $tomorrow = date('Y-m-d', strtotime('+1 day'));
        $schedules = [
            ['train_id' => 1, 'origin_id' => 1, 'destination_id' => 3, 'departure_time' => "$tomorrow 06:00:00", 'arrival_time' => "$tomorrow 14:00:00", 'price' => 450000, 'available_seats' => 45, 'is_active' => 1, 'created_at' => date('Y-m-d H:i:s'), 'updated_at' => date('Y-m-d H:i:s')],
            ['train_id' => 2, 'origin_id' => 1, 'destination_id' => 2, 'departure_time' => "$tomorrow 08:00:00", 'arrival_time' => "$tomorrow 11:00:00", 'price' => 150000, 'available_seats' => 48, 'is_active' => 1, 'created_at' => date('Y-m-d H:i:s'), 'updated_at' => date('Y-m-d H:i:s')],
            ['train_id' => 3, 'origin_id' => 2, 'destination_id' => 4, 'departure_time' => "$tomorrow 09:00:00", 'arrival_time' => "$tomorrow 15:00:00", 'price' => 200000, 'available_seats' => 75, 'is_active' => 1, 'created_at' => date('Y-m-d H:i:s'), 'updated_at' => date('Y-m-d H:i:s')],
            ['train_id' => 4, 'origin_id' => 4, 'destination_id' => 3, 'departure_time' => "$tomorrow 10:00:00", 'arrival_time' => "$tomorrow 16:00:00", 'price' => 120000, 'available_seats' => 90, 'is_active' => 1, 'created_at' => date('Y-m-d H:i:s'), 'updated_at' => date('Y-m-d H:i:s')],
        ];
        $this->db->table('schedules')->insertBatch($schedules);

        echo "Database seeded successfully!\n";
    }
}
