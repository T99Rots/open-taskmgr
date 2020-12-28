import 'dart:io';

class Memory {
  final File _memInfoFile = new File('/proc/meminfo');
  final List<MemoryInfoEntry> usageHistory = [];
  final int historyLength;
  int totalMemory;
  int totalSwap;

  Memory({
    this.historyLength
  });

  Future update () async {
    final String memoryInfo = await _memInfoFile.readAsString();

    final Map<String, String> memoryInfoMap = Map.fromEntries(memoryInfo
      .split(RegExp(r"\n", multiLine: true))
      .where((element) => element.length > 0)
      .map((string) => string.split(RegExp(r":\s*")))
      .map((List<String> list) => MapEntry(list[0], list[1].replaceFirst(' kB', ''))).toList()
    );

    totalMemory = int.parse(memoryInfoMap['MemTotal']);
    totalSwap = int.parse(memoryInfoMap['SwapTotal']);

    usageHistory.add(MemoryInfoEntry(memoryInfoMap));
    if(usageHistory.length > historyLength) {
      usageHistory.removeAt(0);
    }
  }
}

class MemoryInfoEntry {
  int memFree;
  int memAvailable;
  // int buffers;
  int cached;
  int swapCached;
  // int active;
  // int inactive;
  // int activeAnon;
  // int inactiveAnon;
  // int activeFile;
  // int inactiveFile;
  // int unevictable;
  // int mlocked;
  int swapTotal;
  int swapFree;
  int dirty;
  int writeback;
  // int anonPages;
  // int mapped;
  // int shmem;
  // int kReclaimable;
  // int slab;
  // int sReclaimable;
  // int sUnreclaim;
  // int kernelStack;
  // int pageTables;
  // int nfsUnstable;
  // int bounce;
  // int writebackTmp;
  int commitLimit;
  int committedAs;
  // int vmallocTotal;
  // int vmallocUsed;
  // int vmallocChunk;
  // int percpu;
  // int hardwareCorrupted;
  // int anonHugePages;
  // int shmemHugePages;
  // int shmemPmdMapped;
  // int fileHugePages;
  // int filePmdMapped;
  // int hugepagesize;
  // int hugetlb;
  // int directMap4k;
  // int directMap2M;
  // int directMap1G;
  // int hugePagesTotal;
  // int hugePagesFree;
  // int hugePagesRsvd;
  // int hugePagesSurp;

  MemoryInfoEntry(Map<String, String> memoryInfoMap) {
    memFree = int.parse(memoryInfoMap['MemFree']);
    memAvailable = int.parse(memoryInfoMap['MemAvailable']);
    // buffers = int.parse(memoryInfoMap['Buffers']);
    cached = int.parse(memoryInfoMap['Cached']);
    swapCached = int.parse(memoryInfoMap['SwapCached']);
    // active = int.parse(memoryInfoMap['Active']);
    // inactive = int.parse(memoryInfoMap['Inactive']);
    // activeAnon = int.parse(memoryInfoMap['Active(anon)']);
    // inactiveAnon = int.parse(memoryInfoMap['Inactive(anon)']);
    // activeFile = int.parse(memoryInfoMap['Active(file)']);
    // inactiveFile = int.parse(memoryInfoMap['Inactive(file)']);
    // unevictable = int.parse(memoryInfoMap['Unevictable']);
    // mlocked = int.parse(memoryInfoMap['Mlocked']);
    swapFree = int.parse(memoryInfoMap['SwapFree']);
    dirty = int.parse(memoryInfoMap['Dirty']);
    writeback = int.parse(memoryInfoMap['Writeback']);
    // anonPages = int.parse(memoryInfoMap['AnonPages']);
    // mapped = int.parse(memoryInfoMap['Mapped']);
    // shmem = int.parse(memoryInfoMap['Shmem']);
    // kReclaimable = int.parse(memoryInfoMap['KReclaimable']);
    // slab = int.parse(memoryInfoMap['Slab']);
    // sReclaimable = int.parse(memoryInfoMap['SReclaimable']);
    // sUnreclaim = int.parse(memoryInfoMap['SUnreclaim']);
    // kernelStack = int.parse(memoryInfoMap['KernelStack']);
    // pageTables = int.parse(memoryInfoMap['PageTables']);
    // nfsUnstable = int.parse(memoryInfoMap['NFS_Unstable']);
    // bounce = int.parse(memoryInfoMap['Bounce']);
    // writebackTmp = int.parse(memoryInfoMap['WritebackTmp']);
    commitLimit = int.parse(memoryInfoMap['CommitLimit']);
    committedAs = int.parse(memoryInfoMap['Committed_AS']);
    // vmallocTotal = int.parse(memoryInfoMap['VmallocTotal']);
    // vmallocUsed = int.parse(memoryInfoMap['VmallocUsed']);
    // vmallocChunk = int.parse(memoryInfoMap['VmallocChunk']);
    // percpu = int.parse(memoryInfoMap['Percpu']);
    // hardwareCorrupted = int.parse(memoryInfoMap['HardwareCorrupted']);
    // anonHugePages = int.parse(memoryInfoMap['AnonHugePages']);
    // shmemHugePages = int.parse(memoryInfoMap['ShmemHugePages']);
    // shmemPmdMapped = int.parse(memoryInfoMap['ShmemPmdMapped']);
    // fileHugePages = int.parse(memoryInfoMap['FileHugePages']);
    // filePmdMapped = int.parse(memoryInfoMap['FilePmdMapped']);
    // hugepagesize = int.parse(memoryInfoMap['Hugepagesize']);
    // hugetlb = int.parse(memoryInfoMap['Hugetlb']);
    // directMap4k = int.parse(memoryInfoMap['DirectMap4k']);
    // directMap2M = int.parse(memoryInfoMap['DirectMap2M']);
    // directMap1G = int.parse(memoryInfoMap['DirectMap1G']);
    // hugePagesTotal = int.parse(memoryInfoMap['HugePages_Total']);
    // hugePagesFree = int.parse(memoryInfoMap['HugePages_Free']);
    // hugePagesRsvd = int.parse(memoryInfoMap['HugePages_Rsvd']);
    // hugePagesSurp = int.parse(memoryInfoMap['HugePages_Surp']);
  }
}