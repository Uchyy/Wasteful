// data/repositories/schedule_repository.dart
import 'package:sqflite/sqflite.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/data/db/app_db.dart';
import 'package:wasteful/data/model/address.dart';
import 'package:wasteful/data/model/schedule.dart';


class ScheduleRepository {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<void> addAddress(Address address) async {
    final db = await _db;
    await db.insert('addresses', address.toMap());
  }

  Future<void> updateAddress(Address address) async {
    final db = await _db;
    await db.update('addresses', address.toMap(),
        where: 'id = ?', whereArgs: [address.id]);
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
    await db.transaction((txn) async {
      final map = schedule.toMap()..['address_id'] = addressId;
      await txn.insert('schedules', map);

      for (final bin in schedule.binTypes) {
        await txn.insert('schedule_bin_types', {
          'schedule_id': schedule.id,
          'bin_type': bin.name,
        });
      }
    });
  }

  Future<void> updateSchedule(String addressId, Schedule schedule) async {
    final db = await _db;
    await db.transaction((txn) async {
      final map = schedule.toMap()..['address_id'] = addressId;
      await txn.update('schedules', map, where: 'id = ?', whereArgs: [schedule.id]);

      await txn.delete('schedule_bin_types',
          where: 'schedule_id = ?', whereArgs: [schedule.id]);
      for (final bin in schedule.binTypes) {
        await txn.insert('schedule_bin_types', {
          'schedule_id': schedule.id,
          'bin_type': bin.name,
        });
      }
    });
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

    final schedules = <Schedule>[];
    for (final map in scheduleMaps) {
      final binRows = await db.query(
        'schedule_bin_types',
        where: 'schedule_id = ?',
        whereArgs: [map['id']],
      );
      final binTypes = binRows
          .map((r) => BinType.values.firstWhere((b) => b.name == r['bin_type']))
          .toList();
      schedules.add(Schedule.fromMap(map, binTypes));
    }
    return schedules;
  }
}