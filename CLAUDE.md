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
| M1 | Proje Altyapisi | Godot ayarlari, klasor yapisi, autoload iskeletleri, portrait layout, placeholder UI | `tamamlandi` `cddfe39` |
| M2 | Bilet & Kazima | Bilet sahnesi, dokunma ile kazima, sembol atama, bilet tamamlanma | `tamamlandi` `bcdd165` |
| M3 | Eslesme & Coin | Eslesme kontrolu, coin hesaplama, ust bar, eslesme sonuc ekrani | `tamamlandi` |
| M4 | Enerji & Tur | Enerji sistemi, tur baslangic/bitis, baslangic parasi, bilet satin alma | `tamamlandi` `263ace3` |
| M5 | Charm Sistemi | Charm puani kazanma, charm listesi, charm satin alma, seviye artirma, debug araclari | `tamamlandi` `2de28a9` |

### Faz 2: Icerik & Derinlik
| Faz | Isim | Kapsam | Durum |
|-----|------|--------|-------|
| M6 | Bilet Turleri | Bronz/Gumus/Altin/Platin biletler, anahtar charm'lar, farkli alan+sembol havuzlari | `tamamlandi` |
| M7 | Sinerji & Koleksiyon | Sinerjiler, sinerji albumu, koleksiyon sistemi, koleksiyon UI | `tamamlandi` `f7a65e6` |
| M8 | Olaylar & Basarimlar | Altin bilet, Bull Run, basarim sistemi, istatistikler | `tamamlandi` |
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

## Gelistirme Sureci (Her Faz Icin)
1. **Implementasyon** — Kod yazilir
2. **Godot Log Testi** — Godot headless calistirilir, loglar okunur, compile/runtime hatalari kontrol edilir
3. **Kullanici Testi** — Kullanici oyunu acip manuel test eder, onaylarsa commit+push
4. **CLAUDE.md Guncelle** — Faz durumu guncellenir

## Log Kontrol Yaklasimi
- Her implementasyon sonrasi `Godot --headless --quit` ile oyun baslatilir
- Ciktidaki `[GameState]`, `[Main]`, `[Ticket]` gibi prefixli loglar kontrol edilir
- `ERROR`, `WARNING`, `Parse Error`, `Invalid` gibi hata kelimeleri aranir
- Compile hatasi varsa kullaniciya sormadan once duzeltilir
- Her script `print("[ModulAdi] ...")` formatiyla log basar — bu sayede hangi modulun yuklendigi/calismadigi anlasilir

## Debug Araclari
- **Erisim:** Basliga 5 kez tikla (ana menu) veya Enerji labelina 5 kez tikla (oyun ekrani)
- **Ozellikler:** Save sifirlama, enerji doldurma, +10/+100 charm, +100/+1000 coin, tur bitirme, sinerji kesfet, koleksiyon ekle, tum koleksiyonlari tamamla
- **Dosyalar:** `scripts/debug/debug_panel.gd`, `scenes/debug/DebugPanel.tscn`

## Charm Sistemi Notlari
- **Aktif efektler:** Sans Tokasi, Zengin/Mega Baslangic, Altinparmak, Kral Dokunusu, YOLO, Enerji Deposu, Hizli Parmak, Sinerji Radari
- **Ertelenmis efektler:** Keskin Goz (M6-sembol uretimi), Joker Miknatisi (M6-ozel semboller), Carpan Gucu (M6), Anahtar Charm'lar (M6-bilet turleri)
- **CharmData:** `scripts/systems/charm_data.gd` (preload ile referans, class_name cache sorunu nedeniyle)

## Sinerji Sistemi Notlari
- **Dosya:** `scripts/systems/synergy_system.gd` (preload ile referans)
- **Sinerjiler:** Meyve Kokteyli (x3), Gece Gokyuzu (x4), Lucky Seven (x10), Kraliyet (x5), Ejderha Atesi (x8), Full House (x25), Gokkusagi (x5), Gizli Sinerji (x15)
- **Sinerji Radari charm:** Sembol uretiminde sinerji yonlendirme sansi (seviye x %5)
- **Kesfedilen sinerjiler:** GameState.discovered_synergies'de saklanir
- **UI:** Sinerji Albumu ekrani (`scenes/screens/SynergyAlbum.tscn`)

## Koleksiyon Sistemi Notlari
- **Dosya:** `scripts/systems/collection_system.gd` (preload ile referans)
- **Setler:** Meyve, Degerli Taslar, Sansli 7'ler, Kripto, Kozmik, Meme Lords (her biri 4 parca)
- **Dusme sanslari:** Paper %3, Bronze %5, Silver %8, Gold %12, Platinum %18
- **Set bonuslari:** Eslesme odulu, ozel sembol, jackpot, baslangic coin, tum oduller, altin bilet sansi
- **Toplanan parcalar:** GameState.collected_pieces'de saklanir
- **UI:** Koleksiyon ekrani (`scenes/screens/CollectionScreen.tscn`)

## Olay Sistemi Notlari
- **Dosya:** `scripts/systems/event_system.gd` (preload ile referans)
- **Olaylar:** Altin Bilet (%15-50 artan), Bull Run (%3, x2 3 bilet), Bedava Bilet (%20 her 10. bilet), Joker Yagmuru (%1), Mega Bilet (%0.5 garanti jackpot)
- **Tetikleme:** Her bilet sonrasi `_on_match_result_dismissed` icinde roll yapilir
- **State:** `GameState.active_events`, `_tickets_since_golden`, `_joker_rain_active`, `_mega_ticket_active`, `_free_ticket_active`
- **UI:** Olay banner (`scenes/ui/EventBanner.tscn`), Altin bilet popup (`scenes/ui/GoldenTicketPopup.tscn`)

## Basarim Sistemi Notlari
- **Dosya:** `scripts/systems/achievement_system.gd` (preload ile referans)
- **Basarimlar:** 5 erken + 5 orta + 5 gec + 4 gizli = 19 basarim
- **Oduller:** 2-30 CP arasi
- **Kontrol:** Her bilet sonrasi + tur sonu + charm satin alma sonrasi
- **State:** `GameState.unlocked_achievements`, `GameState.stats`, `GameState.round_stats`
- **UI:** Basarim ekrani (`scenes/screens/AchievementScreen.tscn`), Basarim toast (`scenes/ui/AchievementToast.tscn`)
- **Gizli basarimlar:** Joker Ustasi (3x joker), Seri Eslesme (5 ardisik), Cift Sinerji (2 sinerji 1 bilet), Sifirdan Zirveye (0 charm + 500 coin)

## PC Versiyonu Notu
- PC versiyonu ayri proje: `D:\godotproject\incremental`
- PC'de: Buildings, oto-kazima, prestige, yatay layout, $4.99 premium
- Mobilde: Enerji, charm, session-based, dikey layout, F2P
- Ortak: Kazima mekanigi, eslesme sistemi, sembol havuzu, sinerji
