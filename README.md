
# 🌾 Çiftçi Dostu

**Çiftçi Dostu**, tarım yapan kullanıcılar için hava durumu takibi, sensör verisi izleme ve özel uyarılar sunan Flutter tabanlı bir mobil/web uygulamasıdır. Gerçek zamanlı veri akışı ve kullanıcı dostu arayüzü ile çiftçilerin işlerini kolaylaştırmayı hedefler.

## 🚀 Özellikler

- 📍 Şehre göre 5 günlük hava durumu tahmini
- 🔔 Tahmine dayalı özel tarımsal uyarı sistemi
- 🌐 WebSocket ile gerçek zamanlı veri alışverişi
- 📊 Sensör verilerini grafiksel olarak gösterme (fl_chart ile)
- 🧑‍🌾 Kullanıcı dostu ve sade arayüz

## 🛠️ Kullanılan Teknolojiler

- **Flutter SDK**: ^3.7.2
- **http**: API istekleri için
- **WebSocket**: Cihazlarla anlık iletişim
- **fl_chart**: Grafik gösterimi
- **cupertino_icons**: iOS stil ikonlar

## 📁 Proje Yapısı (Kısaca)

```bash
lib/
├── main.dart               # Uygulama girişi
├── services/
│   └── websocket_service.dart # WebSocket bağlantısı
├── widgets/               # (Varsa) özel widget bileşenleri
assets/
└── images/yesil_tarla.jpg # Görsel varlıklar
```

## 🧪 Nasıl Çalıştırılır?

1. Flutter SDK yüklü olduğundan emin olun.
2. Projeyi klonlayın:
   ```bash
   git clone <repo-url>
   cd ciftci_dostu_1
   ```
3. Gerekli paketleri yükleyin:
   ```bash
   flutter pub get
   ```
4. Uygulamayı başlatın:
   ```bash
   flutter run
   ```

## 📝 Notlar

- API anahtarı `lib/services` altındaki dosyada tanımlanmalıdır.
- WebSocket bağlantısı çalışması için arka uç (backend) WebSocket sunucusu aktif olmalıdır.
- Şu anda uygulama web desteklidir.
