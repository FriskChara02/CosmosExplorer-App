# 🌌 Cosmos Explorer

<div align="center">
  
  ![Swift](https://img.shields.io/badge/Swift-6.2.3-orange?style=for-the-badge&logo=swift)
  ![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2018+-blue?style=for-the-badge&logo=swift)
  ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-336791?style=for-the-badge&logo=postgresql)
  
  **Khám phá vũ trụ một cách sinh động, tương tác và đầy giáo dục**
  
  [Tính năng](#-tính-năng) • [Cài đặt](#-cài-đặt) • [Công nghệ](#️-công-nghệ) • [Đóng góp](#-đóng-góp)
  
</div>

---

## 📖 Giới thiệu

**Cosmos Explorer** là ứng dụng iOS mang đến trải nghiệm khám phá vũ trụ toàn diện, kết hợp giữa **giáo dục**, **khám phá** và **giải trí**. Ứng dụng không chỉ cung cấp kiến thức thiên văn học phong phú mà còn tạo ra một cộng đồng người yêu thiên văn có thể học hỏi, chia sẻ và tương tác với nhau.

### 🎯 Mục tiêu

- 🌟 Xây dựng môi trường học tập thiên văn hiện đại, sinh động và dễ hiểu
- 🚀 Cung cấp trải nghiệm khám phá vũ trụ tương tác và trực quan
- 👥 Kết nối cộng đồng người yêu thích thiên văn học
- 📚 Hỗ trợ học tập qua hệ thống quiz tương tác

---

## 📱 Screenshots

<div align="center">
  
| **Login** |
|:---:|
| <img width="1576" height="1079" alt="Image" src="https://github.com/user-attachments/assets/d63a544f-f87f-4ef2-8f85-6bacff50cd53" /> |

| **Home** |
|:---:|
| <img width="1898" height="963" alt="Image" src="https://github.com/user-attachments/assets/f90ac603-1f1b-460f-95e8-e03ca3d5f0f2" /> |

</div>

---

## ✨ Tính năng

### 🔐 Xác thực & Quản lý Người dùng
- Đăng nhập/Đăng ký qua **Google**, **Apple ID**, **Facebook**
- Quản lý hồ sơ cá nhân và tùy chỉnh trải nghiệm

### 🌠 Khám phá Vũ trụ
Khám phá các chủ đề thiên văn đa dạng:
- **Hệ Mặt Trời** - Chi tiết từng hành tinh với thông tin đầy đủ
- **Sao & Chòm sao** - Tìm hiểu về các ngôi sao và chòm sao
- **12 Cung Hoàng đạo** - Khám phá ý nghĩa thiên văn
- **Thiên hà & Tinh vân** - Vẻ đẹp của vũ trụ sâu thẳm
- **Lỗ đen** - Hiện tượng bí ẩn nhất vũ trụ
- **Sky Live** - Quan sát bầu trời thời gian thực

#### 🪐 Thông tin Hành tinh Chi tiết
- Bán kính, khoảng cách từ Mặt Trời
- Số lượng vệ tinh, trọng lực
- Nhiệt độ, tuổi của hành tinh
- Thư viện ảnh & video
- Liên kết Wikipedia
- Thống kê lượt xem từ cộng đồng

### 📰 Tin tức Thiên văn
- Cập nhật tin tức mới nhất từ **NASA API**
- Khám phá các sự kiện thiên văn đáng chú ý

### 📊 Trực quan hóa Dữ liệu
- Biểu đồ và chỉ số phần trăm trực quan

### 💬 Tương tác Xã hội
- ✅ Kết bạn với người dùng khác
- 👥 Tạo và tham gia nhóm
- 💭 Chat cá nhân và nhóm
- 📝 Bình luận trên từng hành tinh

### 🎵 Giải trí
- Nhạc nền chủ đề vũ trụ
- Danh sách phát được tuyển chọn
- Đọc câu chuyện về vũ trụ

### 🎓 Quiz & Học tập
- Hệ thống quiz trắc nghiệm tương tác
- Học kiến thức thiên văn qua câu hỏi thực tế
- Theo dõi tiến độ học tập

---

## 🛠️ Công nghệ

### Ngôn ngữ & Framework
- **Swift 6.2.3**
- **SwiftUI** - UI Framework hiện đại
- **SwiftData** - Quản lý dữ liệu local

### Cơ sở Dữ liệu
- **PostgreSQL** (pgAdmin4) - Database chính
- **SwiftData** - Cache & offline support

### API & Dịch vụ
- **NASA API** - Tin tức & dữ liệu thiên văn

### Xác thực
- **Google Sign-In SDK**
- **Apple AuthenticationServices**
- **Facebook Login SDK**

### IDE & Tools
- **Xcode 26.2+**
- **pgAdmin4** - PostgreSQL management

---

## 📥 Cài đặt

### Yêu cầu
- macOS 13.0+
- Xcode 15.0+
- iOS 17.0+
- PostgreSQL 17+

### Các bước cài đặt

1. **Clone repository**
```bash
git clone https://github.com/FriskChara02/CosmosExplorer-App.git
cd CosmosExplorer-App
```

2. **Cài đặt dependencies**
```bash
# Sử dụng Swift Package Manager trong Xcode
# File > Add Packages...
# Thêm các package cần thiết (GoogleSignIn, FacebookLogin, etc.)
```

3. **Cấu hình Database**
```bash
# Tạo database PostgreSQL
createdb cosmos_explorer
```

4. **Cấu hình API Keys**

Tạo file `Config.swift` trong project:

```swift
struct APIConfig {
    // NASA API Key - Đăng ký tại: https://api.nasa.gov/
    static let nasaAPIKey = "YOUR_NASA_API_KEY_HERE"
    
    // Database Configuration
    static let databaseHost = "localhost"
    static let databasePort = 5432
    static let databaseName = "cosmos_explorer"
    static let databaseUser = "your_db_user"
    static let databasePassword = "your_db_password"
}
```

5. **Cấu hình OAuth**

#### Google Sign-In
- Tạo project tại [Google Cloud Console](https://console.cloud.google.com/)
- Tạo OAuth 2.0 Client ID cho iOS
- Thêm `GoogleService-Info.plist` vào project
- Cập nhật URL Schemes trong Xcode

#### Facebook Login
- Tạo app tại [Facebook Developers](https://developers.facebook.com/)
- Lấy App ID và Client Token
- Thêm vào `Info.plist`:
```xml
<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>
<key>FacebookClientToken</key>
<string>YOUR_FACEBOOK_CLIENT_TOKEN</string>
<key>FacebookDisplayName</key>
<string>Cosmos Explorer</string>
```

#### Apple Sign-In
- Đã được tích hợp sẵn trong iOS SDK
- Bật capability "Sign in with Apple" trong Xcode

6. **Build & Run**
- Mở project trong Xcode
- Chọn target device hoặc simulator
- Nhấn `Cmd + R` để build và chạy

---

## 🤝 Đóng góp

Chúng tôi luôn chào đón mọi đóng góp! Nếu bạn muốn đóng góp cho dự án:

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

---

## 👨‍💻 Tác giả

**FriskChara**
- GitHub: [@FriskChara02](https://github.com/FriskChara02)
- Email: loi.nguyenbao02@gmail.com

---

## 🙏 Cảm ơn

- [NASA API](https://api.nasa.gov/) - Cung cấp dữ liệu thiên văn
- [Swift Community](https://swift.org/community/) - Support và resources

---

<div align="center">
  
**⭐ Nếu bạn thích dự án này, hãy cho một ngôi sao nhé! ⭐**

Made with ❤️ and ☕ for space enthusiasts

</div>
