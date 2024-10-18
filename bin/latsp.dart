import 'dart:io';

void main() {
  // Mendefinisikan jarak antar titik
  Map<String, Map<String, int>> graph = {
    'A': {'B': 8, 'E': 10, 'C': 3, 'D': 4},
    'B': {'A': 8, 'C': 5, 'D': 2, 'E': 7},
    'C': {'B': 5, 'D': 1, 'A': 2, 'E': 6},
    'D': {'C': 1, 'E': 3, 'A': 4, 'B': 6},
    'E': {'A': 10, 'D': 3, 'B': 7, 'C': 4},
  };

  while (true) {
    print('Masukkan titik awal (misal: A): ');
    String? start = stdin.readLineSync();
    if (start == null || !graph.containsKey(start)) {
      print('Titik awal tidak valid.');
      continue; // Kembali ke awal loop jika input tidak valid
    }

    print('Masukkan titik akhir (misal: A): ');
    String? end = stdin.readLineSync();
    if (end == null || !graph.containsKey(end)) {
      print('Titik akhir tidak valid.');
      continue; // Kembali ke awal loop jika input tidak valid
    }

    List<List<String>> allRoutes = [];
    List<String> currentRoute = [start!];
    findRoutes(graph, start, end, currentRoute, allRoutes);

    // Menampilkan semua rute dan jaraknya
    if (allRoutes.isEmpty) {
      print('Rute $start ke $end tidak ditemukan.');
    } else {
      for (var route in allRoutes) {
        int totalDistance = calculateDistance(route, graph);
        print('Rute: ${route.join(' -> ')} | Total Jarak: $totalDistance');
      }
    }

    // Menanyakan apakah pengguna ingin mencari rute lagi
    print('\nApakah Anda ingin memindai rute lagi?');
    print('1. Ya');
    print('2. Tidak');
    String? choice = stdin.readLineSync();

    if (choice == '2') {
      print('Terima kasih!');
      break; // Keluar dari loop jika pengguna memilih untuk tidak melanjutkan
    }
  }
}

void findRoutes(Map<String, Map<String, int>> graph, String currentNode,
    String endNode, List<String> currentRoute, List<List<String>> allRoutes) {
  // Jika sudah mencapai titik akhir, simpan rute
  if (currentNode == endNode && currentRoute.length > 1) {
    allRoutes.add(List.from(currentRoute));
    return;
  }

  // Menelusuri tetangga dari node saat ini
  for (var neighbor in graph[currentNode]!.keys) {
    if (!currentRoute.contains(neighbor)) {
      currentRoute.add(neighbor);
      findRoutes(graph, neighbor, endNode, currentRoute, allRoutes);
      currentRoute.removeLast(); // Menghapus node terakhir setelah kembali
    }
  }
}

int calculateDistance(List<String> route, Map<String, Map<String, int>> graph) {
  int totalDistance = 0;
  for (int i = 0; i < route.length - 1; i++) {
    totalDistance += graph[route[i]]![route[i + 1]]!;
  }
  return totalDistance;
}
