
# Wasteful 🗑️

Wasteful is a simple bin collection reminder app built with Flutter.

It helps you keep track of your household waste collection schedules, manage multiple addresses, and get reminders when your bins need to go out.

## Features

- 📅 Create and manage bin collection schedules
- 🏠 Manage multiple addresses
- 🗑️ Support different waste types
- 🔔 Get notifications for upcoming collections
- ⏰ Choose when to receive reminders
- ✅ Mark a bin as taken out
- 📍 See upcoming collections for each address
- ✏️ Edit and delete existing schedules
- 🔎 Search and manage schedules
- 🌱 Simple, lightweight interface

## How It Works

Add an address and create a collection schedule by selecting:

- Waste type
- Collection day
- Repeat interval
- Start date
- Notification timing

Wasteful then calculates upcoming collection dates and schedules reminders automatically.

## Tech Stack

- **Flutter** — UI and application framework
- **Dart** — Programming language
- **Riverpod** — State management
- **SQLite / sqflite** — Local data storage
- **flutter_local_notifications** — Local notifications
- **Timezone** — Notification scheduling across local timezones
- **GoRouter** — Navigation

## Project Structure

```text
lib/
├── app/
├── core/
├── data/
│   ├── database/
│   ├── model/
│   └── repository/
├── features/
│   ├── home/
│   ├── schedule/
│   ├── settings/
│   └── ...
└── main.dart

## Notifications

Wasteful uses local notifications to remind users about upcoming bin collections.

Reminders can be configured to notify the user:

* The evening before collection
* On the morning of collection

Notifications are scheduled locally on the device, so the app does not need a backend service to send reminders.

## Development

### Requirements

* Flutter SDK
* Dart SDK
* Android Studio or another Flutter-compatible IDE

### Run the app

Clone the repository:

```bash
git clone <repository-url>
cd wasteful
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Status

Wasteful is currently under active development.

The core schedule management, local storage, collection calculations, and notification functionality are being developed and refined.

## Roadmap

* [ ] Council collection data
* [ ] Automatic schedule lookup
* [ ] Improved notification controls
* [ ] Collection history
* [ ] Additional waste types
* [ ] Improved accessibility
* [ ] Production release

## License

This project is currently private and under development.

```
```
