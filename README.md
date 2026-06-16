# Veilwatch

Anime streaming app built with Flutter. Dark premium UI, source dari Animasu/sankavollerei.com.

## Stack

- **Flutter** 3.22+
- **State Management**: Riverpod
- **Navigation**: go_router
- **HTTP**: Dio
- **Video Player**: better_player (HLS support)
- **Local Storage**: SharedPreferences
- **UI**: Iconsax, CachedNetworkImage, Shimmer, CarouselSlider

## Struktur Project

```
lib/
├── core/
│   ├── constants/       # App constants & endpoints
│   ├── theme/           # Dark theme & colors
│   ├── providers.dart   # Riverpod providers
│   └── router.dart      # go_router config
├── data/
│   ├── models/          # Anime, Episode, StreamSource, WatchHistory
│   └── services/        # API service (Dio), LocalStorage
└── presentation/
    ├── screens/
    │   ├── home/        # Home + hero carousel
    │   ├── search/      # Search anime
    │   ├── detail/      # Anime detail + episodes
    │   ├── player/      # Video player
    │   └── library/     # Saved + history
    └── widgets/
        └── common/      # AnimeCard, MainScaffold, SectionHeader
```

## Setup & Build

### Local
```bash
flutter pub get
flutter run
```

### Build APK via GitHub Actions
Push ke branch `main` atau `dev` → Actions otomatis build APK.
Download dari tab **Actions > Artifacts**.

### Build manual
```bash
flutter build apk --release --target-platform android-arm64
```

## API Endpoints

Base URL: `https://sankavollerei.com/api`

| Endpoint | Keterangan |
|----------|-----------|
| `GET /anime/trending` | Trending anime |
| `GET /anime/popular` | Popular anime |
| `GET /anime/recent` | Recent episodes |
| `GET /anime/:id` | Detail anime |
| `GET /anime/:id/episodes` | List episode |
| `GET /episode/:id/stream` | Stream sources |
| `GET /anime/search?q=` | Search |

> Sesuaikan endpoint di `lib/core/constants/app_constants.dart` kalau struktur API berbeda.

## Fitur

- [x] Home dengan hero carousel (trending)
- [x] Popular & recent episodes section
- [x] Continue watching (local)
- [x] Search anime
- [x] Detail anime (banner, synopsis, genres, episodes)
- [x] Video player dengan quality selector
- [x] Save ke library (bookmark)
- [x] Watch history + progress bar
- [x] Dark premium UI (violet accent)
- [x] GitHub Actions build workflow
