<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');

// API Routes
$routes->group('api', ['namespace' => 'App\Controllers\Api'], function ($routes) {
    // Handle OPTIONS preflight requests
    $routes->options('(:any)', static function () {
        return service('response')
            ->setHeader('Access-Control-Allow-Origin', '*')
            ->setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
            ->setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With')
            ->setStatusCode(200);
    });

    // Auth routes
    $routes->post('auth/login', 'AuthController::login');
    $routes->post('auth/register', 'AuthController::register');
    $routes->get('auth/me', 'AuthController::me');
    $routes->post('auth/logout', 'AuthController::logout');

    // Stations
    $routes->get('stations', 'StationController::index');
    $routes->get('stations/(:num)', 'StationController::show/$1');
    $routes->post('stations', 'StationController::create');
    $routes->put('stations/(:num)', 'StationController::update/$1');
    $routes->delete('stations/(:num)', 'StationController::delete/$1');

    // Trains
    $routes->get('trains', 'TrainController::index');
    $routes->get('trains/(:num)', 'TrainController::show/$1');
    $routes->post('trains', 'TrainController::create');
    $routes->put('trains/(:num)', 'TrainController::update/$1');
    $routes->delete('trains/(:num)', 'TrainController::delete/$1');

    // Schedules
    $routes->get('schedules', 'ScheduleController::index');
    $routes->get('schedules/search', 'ScheduleController::search');
    $routes->get('schedules/(:num)', 'ScheduleController::show/$1');
    $routes->post('schedules', 'ScheduleController::create');
    $routes->put('schedules/(:num)', 'ScheduleController::update/$1');
    $routes->delete('schedules/(:num)', 'ScheduleController::delete/$1');

    // Bookings
    $routes->get('bookings', 'BookingController::index');
    $routes->get('bookings/all', 'BookingController::all');
    $routes->get('bookings/(:num)', 'BookingController::show/$1');
    $routes->post('bookings', 'BookingController::create');
    $routes->put('bookings/(:num)/confirm', 'BookingController::confirm/$1');
    $routes->put('bookings/(:num)/cancel', 'BookingController::cancel/$1');
});
