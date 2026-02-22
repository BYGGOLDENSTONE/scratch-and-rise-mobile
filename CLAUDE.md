# Scratch & Rise Mobile

## Proje Bilgisi
- **Tur:** 2D Kazi Kazan (Session-based, Roguelite progression)
- **Motor:** Godot 4.x (GDScript)
- **Platform:** Android (oncelikli), sonra iOS
- **Fiyat:** Ucretsiz (F2P)
- **Monetizasyon:** Reklam (AdMob) + IAP (Enerji paketleri)
- **Tema:** Kazi kazan + kripto/kumar meme kulturu
- **Oryantasyon:** Dikey (Portrait)
- **Godot Yolu:** D:\godot\Godot_v4.6-stable_win64_console.exe

## Tasarim Referansi
- `docs/GDD.md` -- Tum mekanikler, sayilar, formuller burada

## Mimari Kararlar
- **Component-based structure:** Her sistem bagimsiz sahne/script
- **2D Objeler (Node2D):** Bilet, kazima alanlari, semboller, efektler
- **UI (Control):** Ust bar, bilet secimi, charm ekrani, popup'lar
- **Autoload:** GameState (oyun durumu), SaveManager (kayit), AdManager (reklam)
- **Portrait mode:** 720x1280 base, touch input
- **Sayi formati:** 1K, 1M, 1B, 1T, 1Qa, 1Qi...

## Proje Yapisi
```
scratch-mobil/
+-- docs/GDD.md
+-- scenes/
|   +-- main/          # Ana sahne, ana menu
|   +-- ticket/        # Bilet & kazima componentleri
|   +-- ui/            # UI panelleri (her biri ayri sahne)
|   +-- effects/       # Efekt sahneleri
|   +-- screens/       # Ekranlar (tur bitti, charm, koleksiyon)
+-- scripts/
|   +-- autoload/      # GameState, SaveManager, AdManager
|   +-- ticket/        # Bilet, alan, sembol mantigi
|   +-- systems/       # Eslesme, charm, koleksiyon, enerji
|   +-- ui/            # UI script'leri
+-- assets/
|   +-- sprites/       # Sembol gorselleri, bilet gorselleri
|   +-- audio/         # Ses efektleri, muzik
|   +-- fonts/         # Fontlar
|   +-- shaders/       # Kazima shader'i vb.
+-- .gitignore
+-- CLAUDE.md
+-- project.godot
```

---

## Faz Plani

### Faz 1: Temel Mekanik
| Faz | Isim | Kapsam | Durum |
|-----|------|--------|-------|
| M1 | Proje Altyapisi | Godot ayarlari, klasor yapisi, autoload iskeletleri, portrait layout, placeholder UI | `bekliyor` |
| M2 | Bilet & Kazima | Bilet sahnesi, dokunma ile kazima, sembol atama, bilet tamamlanma | `bekliyor` |
| M3 | Eslesme & Coin | Eslesme kontrolu, coin hesaplama, ust bar, eslesme sonuc ekrani | `bekliyor` |
| M4 | Enerji & Tur | Enerji sistemi, tur baslangic/bitis, baslangic parasi, bilet satin alma | `bekliyor` |
| M5 | Charm Sistemi | Charm puani kazanma, charm listesi, charm satin alma, seviye artirma | `bekliyor` |

### Faz 2: Icerik & Derinlik
| Faz | Isim | Kapsam | Durum |
|-----|------|--------|-------|
| M6 | Bilet Turleri | Bronz/Gumus/Altin/Platin biletler, anahtar charm'lar, farkli alan+sembol havuzlari | `bekliyor` |
| M7 | Sinerji & Koleksiyon | Sinerjiler, sinerji albumu, koleksiyon sistemi, koleksiyon UI | `bekliyor` |
| M8 | Olaylar & Basarimlar | Altin bilet, Bull Run, basarim sistemi, istatistikler | `bekliyor` |
| M9 | Save & Polish | Save/Load, enerji yenilenme, temel animasyonlar, UI duzeni | `bekliyor` |

### Faz 3: Monetizasyon & Yayinlama
| Faz | Isim | Kapsam | Durum |
|-----|------|--------|-------|
| M10 | Reklam | AdMob entegrasyonu, rewarded video, interstitial, banner | `bekliyor` |
| M11 | IAP | Google Play Billing, enerji paketleri, reklam kaldirma | `bekliyor` |
| M12 | Gorsel & Ses | Kazima shader'i, animasyonlar, ses efektleri, muzik, neon casino stili | `bekliyor` |
| M13 | Test & Yayin | Balans, beta test, Play Store yayin, ASO | `bekliyor` |

---

## Commit Kurallari
- Her faz sonrasi kullanici test eder -> onaylarsa commit+push
- Commit mesaji formati: `[M1] Proje altyapisi: autoload, ana sahne, klasor yapisi`
- Tamamlanan fazlar tabloda `commit_hash` ile referanslanir

## PC Versiyonu Notu
- PC versiyonu ayri proje: `D:\godotproject\incremental`
- PC'de: Buildings, oto-kazima, prestige, yatay layout, $4.99 premium
- Mobilde: Enerji, charm, session-based, dikey layout, F2P
- Ortak: Kazima mekanigi, eslesme sistemi, sembol havuzu, sinerji
