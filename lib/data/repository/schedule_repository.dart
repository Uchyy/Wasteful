// data/repositories/schedule_repository.dart
import 'dart:core';

import 'package:sqflite/sqflite.dart';
import 'package:wasteful/data/db/app_db.dart';
import 'package:wasteful/data/model/address.dart';
import 'package:wasteful/data/model/schedule.dart';

class ScheduleRepository {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<void> addAddress(Address address) async {
    final db = await _db;

    try {
      await db.insert('addresses', address.toMap());
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('An address with that name already exists');
      }
      rethrow;
    }
  }

  Future<void> updateAddress(Address address) async {
    final db = await _db;
    await db.update('addresses', address.toMap(), where: 'id = ?', whereArgs: [address.id]);
  }

  Future<void> deleteAddress(String id) async {
    final db = await _db;
    await db.delete('addresses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Address>> getAddresses() async {
    final db = await _db;
    final addressMaps = await db.query('addresses');

    final addresses = <Address>[];
    for (final map in addressMaps) {
      final schedules = await getSchedulesForAddress(map['id'] as String);
      addresses.add(Address.fromMap(map, schedules));
    }
    return addresses;
  }

  Future<void> addSchedule(String addressId, Schedule schedule) async {
    final db = await _db;
    await db.insert('schedules', schedule.toMap()); // no transaction needed — single insert
  }

  Future<void> updateSchedule(String addressId, Schedule schedule) async {
    final db = await _db;
    await db.update('schedules', schedule.toMap(), where: 'id = ?', whereArgs: [schedule.id]);
  }

  Future<void> deleteSchedule(String id) async {
    final db = await _db;
    await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> archiveSchedule(String id) async {
    final db = await _db;
    await db.update(
      'schedules',
      {'is_archived': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Schedule>> getSchedulesForAddress(String addressId) async {
    final db = await _db;
    final scheduleMaps = await db.query(
      'schedules',
      where: 'address_id = ?',
      whereArgs: [addressId],
    );

    return scheduleMaps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<String> getAddressLabel(String addressId) async {
    final db = await _db;
    final results = await db.query(
      'addresses',
      columns: ['label'],
      where: 'id = ?',
      whereArgs: [addressId],
      limit: 1,
    );

    if (results.isEmpty) {
      return '';
    }

    final label = results.first['label'];
    return label is String ? label : '';
  }

  Future<Schedule?> getSchedule(String id) async {
    final db = await _db;

    final results = await db.query(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return Schedule.fromMap(results.first);
  }

  Future<List<Schedule>> getActiveSchedules() async {
    final db = await _db;

    final scheduleMaps = await db.query(
      'schedules',
      where: 'is_archived = ?',
      whereArgs: [0],
    );

    return scheduleMaps
        .map((map) => Schedule.fromMap(map))
        .toList();
  }
}