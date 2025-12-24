<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class CreateTrainsTable extends Migration
{
    public function up()
    {
        $this->forge->addField([
            'id' => [
                'type' => 'INT',
                'constraint' => 11,
                'unsigned' => true,
                'auto_increment' => true,
            ],
            'name' => [
                'type' => 'VARCHAR',
                'constraint' => 100,
            ],
            'code' => [
                'type' => 'VARCHAR',
                'constraint' => 20,
            ],
            'type' => [
                'type' => 'ENUM',
                'constraint' => ['Eksekutif', 'Bisnis', 'Ekonomi'],
                'default' => 'Ekonomi',
            ],
            'facilities' => [
                'type' => 'JSON',
                'null' => true,
            ],
            'total_seats' => [
                'type' => 'INT',
                'constraint' => 11,
                'default' => 0,
            ],
            'created_at' => [
                'type' => 'DATETIME',
                'null' => true,
            ],
            'updated_at' => [
                'type' => 'DATETIME',
                'null' => true,
            ],
        ]);
        $this->forge->addKey('id', true);
        $this->forge->addUniqueKey('code');
        $this->forge->createTable('trains');
    }

    public function down()
    {
        $this->forge->dropTable('trains');
    }
}
