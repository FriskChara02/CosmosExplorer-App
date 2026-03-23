# 🌌 Cosmos Explorer

<div align="center">
  
  ![Swift](https://img.shields.io/badge/Swift-6.2.3-orange?style=for-the-badge&logo=swift)
  ![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2018+-blue?style=for-the-badge&logo=swift)
  ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-336791?style=for-the-badge&logo=postgresql)
  
  **Explore the universe in a vivid, interactive, and educational way**
  
  [Features](#-features) • [Installation](#-installation) • [Technologies](#️-technologies) • [Contributing](#-contributing)
  
</div>

---

## 📖 Introduction

**Cosmos Explorer** is an iOS app that delivers a comprehensive universe exploration experience, blending **education**, **discovery**, and **entertainment**. The app not only provides rich astronomical knowledge but also builds a community of astronomy enthusiasts who can learn, share, and interact with one another.

### 🎯 Goals

- 🌟 Build a modern, engaging, and accessible astronomy learning environment
- 🚀 Provide an interactive and visual universe exploration experience
- 👥 Connect communities of astronomy lovers
- 📚 Support learning through an interactive quiz system

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

## ✨ Features

### 🔐 Authentication & User Management
- Sign in / Sign up via **Google**, **Apple ID**, **Facebook**
- Manage personal profiles and customize your experience

### 🌠 Universe Exploration
Explore diverse astronomy topics:
- **Solar System** – Detailed information on every planet
- **Stars & Constellations** – Learn about stars and constellations
- **12 Zodiac Signs** – Discover their astronomical significance
- **Galaxies & Nebulae** – The beauty of the deep universe
- **Black Holes** – The universe's most mysterious phenomenon
- **Sky Live** – Real-time sky observation

#### 🪐 Detailed Planet Information
- Radius, distance from the Sun
- Number of moons, gravity
- Temperature, planet age
- Photo & video gallery
- Wikipedia links
- Community view statistics

### 📰 Astronomy News
- Latest news from the **NASA API**
- Explore notable astronomical events

### 📊 Data Visualization
- Visual charts and percentage indicators

### 💬 Social Interaction
- ✅ Add other users as friends
- 👥 Create and join groups
- 💭 Personal and group chat
- 📝 Comment on individual planets

### 🎵 Entertainment
- Space-themed background music
- Curated playlists
- Read stories about the universe

### 🎓 Quiz & Learning
- Interactive multiple-choice quiz system
- Learn astronomical knowledge through real questions
- Track your learning progress

---

## 🛠️ Technologies

### Language & Framework
- **Swift 6.2.3**
- **SwiftUI** – Modern UI framework
- **SwiftData** – Local data management

### Database
- **PostgreSQL** (pgAdmin4) – Primary database
- **SwiftData** – Cache & offline support

### APIs & Services
- **NASA API** – Astronomy news & data

### Authentication
- **Google Sign-In SDK**
- **Apple AuthenticationServices**
- **Facebook Login SDK**

### IDE & Tools
- **Xcode 26.2+**
- **pgAdmin4** – PostgreSQL management

---

## 📥 Installation

### Requirements
- macOS 13.0+
- Xcode 15.0+
- iOS 17.0+
- PostgreSQL 17+

### Setup Steps

1. **Clone the repository**
```bash
git clone https://github.com/FriskChara02/CosmosExplorer-App.git
cd CosmosExplorer-App
```

2. **Install dependencies**
```bash
# Use Swift Package Manager in Xcode
# File > Add Packages...
# Add the required packages (GoogleSignIn, FacebookLogin, etc.)
```

3. **Configure the database**
```bash
# Create a PostgreSQL database
createdb cosmos_explorer
```

4. **Configure API Keys**

Create a `Config.swift` file in the project:

```swift
struct APIConfig {
    // NASA API Key – Register at: https://api.nasa.gov/
    static let nasaAPIKey = "YOUR_NASA_API_KEY_HERE"
    
    // Database Configuration
    static let databaseHost = "localhost"
    static let databasePort = 5432
    static let databaseName = "cosmos_explorer"
    static let databaseUser = "your_db_user"
    static let databasePassword = "your_db_password"
}
```

5. **Configure OAuth**

#### Google Sign-In
- Create a project at [Google Cloud Console](https://console.cloud.google.com/)
- Create an OAuth 2.0 Client ID for iOS
- Add `GoogleService-Info.plist` to the project
- Update URL Schemes in Xcode

#### Facebook Login
- Create an app at [Facebook Developers](https://developers.facebook.com/)
- Get your App ID and Client Token
- Add to `Info.plist`:
```xml
<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>
<key>FacebookClientToken</key>
<string>YOUR_FACEBOOK_CLIENT_TOKEN</string>
<key>FacebookDisplayName</key>
<string>Cosmos Explorer</string>
```

#### Apple Sign-In
- Built into the iOS SDK
- Enable the "Sign in with Apple" capability in Xcode

6. **Build & Run**
- Open the project in Xcode
- Select a target device or simulator
- Press `Cmd + R` to build and run

---

## 🤝 Contributing

We welcome all contributions! If you'd like to contribute to the project:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👨‍💻 Author

**FriskChara**
- GitHub: [@FriskChara02](https://github.com/FriskChara02)
- Email: loi.nguyenbao02@gmail.com

---

## 🙏 Acknowledgements

- [NASA API](https://api.nasa.gov/) – Providing astronomical data
- [Swift Community](https://swift.org/community/) – Support and resources

---

<div align="center">
  
**⭐ If you like this project, please give it a star! ⭐**

Made with ❤️ and ☕ for space enthusiasts

</div>
