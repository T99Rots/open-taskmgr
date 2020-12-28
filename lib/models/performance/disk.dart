import 'dart:io';

class Storage {
  final File _diskStatsFile = new File('/proc/diskstats');
  List<Disk> disks;

  void update () async {
    final String diskStats = await _diskStatsFile.readAsString();
  }
}

class Disk {

}