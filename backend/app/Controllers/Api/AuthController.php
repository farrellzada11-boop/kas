<?php

namespace App\Controllers\Api;

use App\Controllers\BaseController;
use App\Models\UserModel;
use CodeIgniter\HTTP\ResponseInterface;

class AuthController extends BaseController
{
    protected UserModel $userModel;

    public function __construct()
    {
        $this->userModel = new UserModel();
    }

    public function login(): ResponseInterface
    {
        $json = $this->request->getJSON(true);
        
        $email = $json['email'] ?? '';
        $password = $json['password'] ?? '';

        if (empty($email) || empty($password)) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Email dan password wajib diisi'
            ])->setStatusCode(400);
        }

        $user = $this->userModel->findByEmail($email);

        if (!$user) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Email tidak ditemukan'
            ])->setStatusCode(401);
        }

        if (!$this->userModel->verifyPassword($password, $user['password'])) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Password salah'
            ])->setStatusCode(401);
        }

        // Generate simple token (in production, use JWT)
        $token = bin2hex(random_bytes(32));
        
        // Store token in session or cache (simplified)
        session()->set('user_id', $user['id']);
        session()->set('auth_token', $token);

        unset($user['password']);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Login berhasil',
            'data' => [
                'user' => $user,
                'token' => $token
            ]
        ]);
    }

    public function register(): ResponseInterface
    {
        $json = $this->request->getJSON(true);

        $data = [
            'name' => $json['name'] ?? '',
            'email' => $json['email'] ?? '',
            'password' => $json['password'] ?? '',
            'phone' => $json['phone'] ?? '',
            'role' => 'user'
        ];

        if (!$this->userModel->validate($data)) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Validasi gagal',
                'errors' => $this->userModel->errors()
            ])->setStatusCode(400);
        }

        $userId = $this->userModel->insert($data);

        if (!$userId) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Registrasi gagal'
            ])->setStatusCode(500);
        }

        $user = $this->userModel->find($userId);
        unset($user['password']);

        $token = bin2hex(random_bytes(32));
        session()->set('user_id', $userId);
        session()->set('auth_token', $token);

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Registrasi berhasil',
            'data' => [
                'user' => $user,
                'token' => $token
            ]
        ])->setStatusCode(201);
    }

    public function me(): ResponseInterface
    {
        $userId = session()->get('user_id');

        if (!$userId) {
            return $this->response->setJSON([
                'status' => false,
                'message' => 'Unauthorized'
            ])->setStatusCode(401);
        }

        $user = $this->userModel->find($userId);
        unset($user['password']);

        return $this->response->setJSON([
            'status' => true,
            'data' => $user
        ]);
    }

    public function logout(): ResponseInterface
    {
        session()->destroy();

        return $this->response->setJSON([
            'status' => true,
            'message' => 'Logout berhasil'
        ]);
    }
}
