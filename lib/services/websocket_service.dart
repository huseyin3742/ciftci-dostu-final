import 'dart:html';
import 'dart:convert';

class WebSocketService {
  late WebSocket _socket;
  Function(String)? onMessageReceived;

  void connect(String url) {
    _socket = WebSocket(url);

    _socket.onOpen.listen((_) {
      print('✅ WebSocket bağlantısı açıldı');
    });

    _socket.onMessage.listen((event) {
      print('📨 Veri alındı: ${event.data}');
      if (onMessageReceived != null) {
        onMessageReceived!(event.data.toString());
      }
    });

    _socket.onClose.listen((_) {
      print('🔌 WebSocket kapatıldı');
    });

    _socket.onError.listen((_) {
      print('❌ WebSocket hatası');
    });
  }

 
  void sendCommand(String komut) {
    final jsonMesaj = jsonEncode({"komut": komut});
    _socket.sendString(jsonMesaj);
  }

  void disconnect() {
    _socket.close();
  }
}
