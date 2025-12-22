Flutter + PHP REST API Assessment

This project demonstrates a full-stack integration between a PHP REST API (with MySQL) and a Flutter mobile application.
It was built as part of a technical assessment to evaluate API development, Flutter networking, UI implementation, and technical communication.

📌 Project Overview

The project consists of:

A PHP RESTful API that performs CRUD operations on items stored in a MySQL database.

A Flutter mobile application that fetches, displays, creates, updates, and deletes data from the API.

Proper error handling, loading states, and a clean UI.

A Loom video walkthrough explaining the implementation and live demo.

🛠️ Technologies Used
Backend

PHP (PDO)

MySQL

Apache (XAMPP)

RESTful API

JSON responses

CORS enabled

Frontend

Flutter

Riverpod (state management)

HTTP package

Material UI

🌐 API Documentation
Base URL
http://localhost/flutter-api/api

Endpoints
Get All Items
GET /items


Response Example

{
"status": "success",
"data": [
{
"id": 1,
"name": "Item One",
"price": "100.00"
}
]
}

Create Item
POST /items


Body

{
"name": "New Item",
"price": 99.99
}

Update Item
PUT /items?id=1


Body

{
"name": "Updated Item",
"price": 149.99
}

Delete Item
DELETE /items?id=1

📱 Flutter Application Features

Fetch data from PHP API

Display items using ListView

Loading indicator during network calls

Error handling with readable messages

Create new items

Delete existing items

Clean and readable UI

Riverpod-based state management

🚀 Setup Instructions
Backend (PHP API)

Install XAMPP

Clone or copy the project into:

/Applications/XAMPP/xamppfiles/htdocs/flutter-api


Create a MySQL database:

CREATE DATABASE flutter_api;


Create table:

CREATE TABLE items (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(255) NOT NULL,
price DECIMAL(10,2) NOT NULL
);


Update database credentials in:

config/database.php


Start Apache & MySQL in XAMPP

Test API:

http://localhost/flutter-api/api/items

Flutter App

Navigate to Flutter project directory

Install dependencies:

flutter pub get


Run the app:

flutter run

📱 Platform Notes
Android Emulator
http://10.0.2.2/flutter-api/api

iOS Simulator
http://localhost/flutter-api/api

Physical Device

Use your computer’s local IP address:

http://192.168.x.x/flutter-api/api


Ensure the device and computer are on the same network.

✅ Assessment Objectives Covered

✔ API development with PHP & MySQL

✔ Flutter networking & UI

✔ Error handling & loading states

✔ Clean code organization

✔ Clear technical explanation

👤 Author

Flutter Developer
Full-stack mobile and API development