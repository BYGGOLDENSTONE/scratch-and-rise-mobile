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
- **Autoload:** GameState (oyun durumu), SaveManager (kayit), AdManager (reklam), SoundManager (ses efektleri)
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
| M9 | Save & Polish | Save/Load, enerji yenilenme, temel animasyonlar, UI duzeni | `tamamlandi` `427df58` |

### Faz 3: Monetizasyon & Yayinlama
| Faz | Isim | Kapsam | Durum |
|-----|------|--------|-------|
| M10 | Reklam | AdMob entegrasyonu, rewarded video, interstitial, banner | `bekliyor` |
| M11 | IAP | Google Play Billing, enerji paketleri, reklam kaldirma | `bekliyor` |
| M12 | Gorsel Polish | Neon casino tema, kazima shader, ekran efektleri, bilet/sembol gorselleri | `tamamlandi` |
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
- **Basarimlar:** 10 erken + 15 orta + 22 gec + 13 gizli = 60 basarim
- **Oduller:** 2-30 CP arasi
- **Nadir seviyeleri (rarity):** common (gri), uncommon (yesil), rare (mavi), epic (mor), legendary (altin)
- **Kontrol:** Her bilet sonrasi + tur sonu + charm satin alma sonrasi
- **State:** `GameState.unlocked_achievements`, `GameState.stats`, `GameState.round_stats`
- **UI:** Basarim ekrani (`scenes/screens/AchievementScreen.tscn`), Basarim toast (`scenes/ui/AchievementToast.tscn`)
- **Toast efektleri:** Slide-in bounce animasyonu, rarity-renk seridi, ekran flash, mini konfeti, CP ucma efekti, epic+ icin screen shake, legendary icin tam konfeti + kenar flash
- **Basarim ekrani:** Kategori ilerleme cubuklari, rarity renk seridi her kartta, acilmis/kilitli gorsel ayrimi
- **Gizli basarimlar (13):** Joker Ustasi (3x), Seri Eslesme (5 ardisik), Cift Sinerji (2 sinerji), Sifirdan Zirveye (0→500), Joker Cilginligi (4x), Bomba Zinciri, Sanssiz Sansli, Mukemmel Tur, Joker Festivali (5x), Uclu Sinerji (3 sinerji), Durdurulamaz (10 ardisik), Kral Midas (10K/tur), Yeni Baslayanin Sansi (ilk bilet jackpot)
- **Yeni check type'lar:** sets_complete_gte, hidden_joker_count (target destekli), hidden_triple_synergy, hidden_rich_round, hidden_first_ticket_jackpot

## Gorsel Polish (M12) Notlari
- **ThemeHelper:** `scripts/ui/theme_helper.gd` (preload ile referans, static fonksiyonlar)
- **ScreenEffects:** `scripts/effects/screen_effects.gd` (autoload: ScreenEffects)
- **Shader:** `assets/shaders/scratch_cover.gdshader` (metalik kapak + dissolve + edge_glow_color uniform)
- **Tema sistemi:** Dual palet (Dark + Light), `ThemeHelper.p("key")` ile renk erisimi
  - Dark: Koyu lacivert-siyah arka plan, yumusak mavi/mor/yesil/amber aksanlar (Stripe/Linear tarzi)
  - Light: Acik gri-beyaz arka plan, daha koyu aksanlar
  - Palet anahtarlari: bg_main, bg_panel, bg_card, primary, secondary, success, warning, danger, info, text_primary, text_secondary, text_muted, topbar_bg, tier_bg_*
- **Tema degistirme:** GameState.set_user_theme(0=dark/1=light), SaveManager'da saklanir, Ayarlar popup'inda toggle
- **Viewport sync:** `RenderingServer.set_default_clear_color()` ile viewport arka plani tema ile senkron
- **Bilet tier renkleri:** paper=gri, bronze=bakir, silver=gumus, gold=altin, platinum=mor (tema-bagimsiz)
- **Efektler:** Ekran flash, screen shake, konfeti (GPUParticles2D), coin ucma, YOLO x50 efekti, sinerji efekti
- **Animasyonlar:** Kapak dissolve, bilet tier border/gradient
- **Eslesme kutlamasi:** BAM BAM BAM slam pop (bilet uzerinde, popup yok), carpan gosterimi, odul bilgisi
- **Tum ekranlar:** `_apply_theme()` fonksiyonu ile runtime'da stillendirilir, `theme_changed` sinyali ile canli guncelleme
- **Stil fonksiyonlari:** make_button, make_panel, make_card, style_title, style_label, style_warning, style_top_bar, style_background

## Test Harness Sistemi
- **Dosya:** `scripts/autoload/test_harness.gd` (autoload: TestHarness, en son sirada)
- **Protokol:** Dosya-bazli iletisim, proje kokunde 3 dosya:
  - `_test_command.json` — Claude yazar, Godot okur ve siler
  - `_test_state.json` — Godot yazar, Claude okur
  - `_test_screenshot.png` — Godot viewport'tan kaydeder
- **Polling:** 0.5 sn aralikla `_test_command.json` kontrol eder
- **Release guard:** `OS.has_feature("release")` ise devre disi
- **Komutlar:** `state`, `click`, `click_button`, `scratch_all`, `screenshot`, `wait`, `drag`, `change_scene`, `set_theme`, `set_coins`, `set_energy`, `list_buttons`
- **click_button:** `emit_signal("pressed")` ile dogrudan sinyal gonderir (sim_click yerine) + 0.8s sahne gecis beklemesi
- **change_scene:** Alias destegi: menu, game, charm, synergy, collection, achievement
- **set_theme:** 0=dark, 1=light — `GameState.set_user_theme()` cagirir
- **set_coins/set_energy:** Dogrudan deger ata
- **State export:** scene, game_state (coins/energy/charms/stats/ticket bilgisi), ui_elements (Button/Label), result

### Test Akisi
1. Oyunu pencereli baslat: `"D:/godot/Godot_v4.6-stable_win64_console.exe" --path "D:/godotproject/scratch-mobil"` (background)
2. 7 sn bekle (yukleme)
3. Komut gonder: `_test_command.json` dosyasina JSON yaz (`{"command": "state", "id": "1"}`)
4. 2 sn bekle (polling + islem + sahne gecis)
5. Cevap oku: `_test_state.json` oku, `id` eslesmesini kontrol et
6. Tekrarla

### Ornek Komutlar
```json
{"command": "state", "id": "1"}
{"command": "click_button", "text": "OYNA", "id": "2"}
{"command": "click_button", "text": "Kagit", "id": "3"}
{"command": "scratch_all", "delay": 0.15, "id": "4"}
{"command": "screenshot", "id": "6"}
{"command": "wait", "seconds": 1, "id": "7"}
{"command": "click", "x": 360, "y": 640, "id": "8"}
{"command": "change_scene", "path": "charm", "id": "9"}
{"command": "set_theme", "theme": 0, "id": "10"}
{"command": "set_coins", "amount": 1000, "id": "11"}
{"command": "set_energy", "amount": 5, "id": "12"}
{"command": "list_buttons", "id": "13"}
```

### Otomatik Test (Subagent ile)
- Sonnet model subagent ile coklu tur test yapilabilir
- Agent komut gonder → state oku → veri topla dongusunu calistirir
- Sonuc `_test_report.json` dosyasina yazilir
- **Kisitlama:** Tek Godot instance, tek dosya seti — paralel agent calismaz
- **Debug panel:** 5 hizli tiklamayla acilir ama test harness polling (0.5sn) ile zamanlama zor, save dosyasi dogrudan silinebilir

### Son Test Sonuclari (2026-02-23, balans duzeltmesi sonrasi, 89 bilet)
- Paper eslesme orani: %44.9 (GDD hedefi: %55) — **DUZELTILDI** (onceki: %92.3)
- Paper ROI (normal turlar): x0.80-1.00 — **DUZELTILDI** (onceki: x19.7)
- Paper ROI (jackpotlu turlar): x1.74 — jackpot varyansı yüksek ama kabul edilebilir
- Carpanlar: %72 x1, %16 x2, %12 x3-5 — istenen dagılım
- Detayli rapor: `_test_report.json`

## Balans Sistemi Notlari
- **base_reward sistemi:** Odul = base_reward x carpan (base_reward << fiyat = dogal kayip)
- **Fiyatlar:** Paper=5, Bronze=25, Silver=100, Gold=500, Platinum=2500
- **Base reward:** Paper=5, Bronze=10, Silver=20, Gold=40, Platinum=80
- **Kayip orani (normal eslesme):** Paper=%0, Bronze=%60, Silver=%80, Gold=%92, Platinum=%97
- **Carpan tablosu:** `match_system.gd` MULTIPLIER_RANGES
  - Paper: normal x1, big x2-3, jackpot x5-10
  - Bronze: normal x1-2, big x3-5, jackpot x8-15
  - Silver: normal x1-2, big x4-8, jackpot x12-25
  - Gold: normal x1-3, big x5-12, jackpot x15-40
  - Platinum: normal x1-3, big x8-20, jackpot x30-80
- **Sembol havuzlari:** Paper=5, Bronze=7, Silver=9, Gold=12, Platinum=15
- **Yeni semboller:** clover (Yonca), bell (Zil), horseshoe (Nal), dice (Zar)
- **Sinerji carpanlari:** Meyve x2, Gece x2, Lucky7 x5, Kraliyet x3, Ejderha x4, Full House x10, Gokkusagi x2, Festivali x5, JokerPartisi x3, BombaFirtinasi x4, TasKoleksiyonu x3, KozmikGuc x4, KriptoMadenci x5, CicekBahcesi x3, Efsane x6
- **Mega Bilet:** Bilet bazli jackpot araligini kullaniyor

## Balans Durumu (2026-02-24, matematik analizi sonrasi)
- **ROI egrisi:** Paper x1.15, Bronze x0.95, Silver x0.65, Gold x0.35, Platinum x0.20, Diamond x0.15, Emerald x0.12, Ruby x0.10, Obsidian x0.08, Legendary x0.06
- **Hedef akis:** Paper buildup → Bronze eglence → Silver drain baslangici → Gold/Platinum hizli drain → Diamond+ ultra-risk → tur biter → tekrar oyna
- **base_reward degerleri:** Paper=5, Bronze=12, Silver=45, Gold=105, Platinum=200, Diamond=450, Emerald=1K, Ruby=2K, Obsidian=4K, Legendary=7.5K
- **Fiyatlar:** Paper=5, Bronze=25, Silver=100, Gold=500, Platinum=2.5K, Diamond=7.5K, Emerald=20K, Ruby=50K, Obsidian=125K, Legendary=300K
- **Paper normal carpan:** [1,3] (buildup icin hafif pozitif)
- **Baslangic parasi:** 20 coin (Paper ile buildup zorunlu)

## Ses Efekti Sistemi Notlari
- **Dosya:** `scripts/autoload/sound_manager.gd` (autoload: SoundManager)
- **Sintetik sesler:** 19 placeholder ses, AudioStreamWAV ile runtime'da uretilir
- **Ses turleri:** ui_tap, ui_back, popup_open, popup_close, scratch, match_pop, match_special, no_match, coin_gain, coin_spend, big_win, jackpot, achievement, event_trigger, energy_warn, ticket_complete, scene_swoosh, charm_buy, round_end
- **Kullanim:** `SoundManager.play("ses_adi")` veya `SoundManager.play("ses_adi", pitch)`
- **Ayarlar:** sfx_enabled (bool), sfx_volume (float 0-1), SaveManager'da saklanir
- **Entegrasyon:** 14 dosyada ses cagrilari: main.gd, main_menu.gd, ticket.gd, scratch_area.gd, screen_effects.gd, scene_transition.gd, settings_popup.gd, charm_screen.gd, collection_screen.gd, achievement_screen.gd, synergy_album.gd, round_end.gd, save_manager.gd
- **Pitch escalation:** match_pop sesinde intensity ile pitch artar (0.9 + intensity * 0.15)
- **Degistirme:** Gercek ses dosyalari ile degistirilebilir (_sounds dictionary'sine AudioStreamWAV yerine dosyadan yuklenen stream atanabilir)

## SONRAKI SESSION GOREVLERI
(Tum gorevler tamamlandi)

---

## Tamamlanan Gorevler

### Ses Efekti Sistemi (2026-02-25)
- **SoundManager autoload:** Sintetik placeholder sesler (19 adet), AudioStreamWAV ile runtime uretimi
- **UI sesleri:** Buton tiklama (ui_tap), geri donme (ui_back), popup acilis/kapanis
- **Oyun sesleri:** Kazima, sembol patlama (pitch escalation), ozel sembol, eslesme yok, bilet tamamlanma
- **Odul sesleri:** Coin kazanma/harcama, buyuk kazanc, jackpot fanfar, charm satin alma
- **Olay sesleri:** Basarim, olay tetikleme, enerji uyarisi, tur sonu, sahne gecisi
- **Ayarlar:** Ses toggle (Acik/Kapali), SettingsPopup'a eklendi, SaveManager'da saklanir
- **Entegrasyon:** 14 dosyada ~35 ses tetikleme noktasi
- **Dosyalar:** `scripts/autoload/sound_manager.gd`, `scenes/ui/SettingsPopup.tscn` guncellendi

### Basarim Sistemi Buyuk Guncelleme (2026-02-24)
- **60 basarim:** 28→60 (10 erken + 15 orta + 22 gec + 13 gizli)
- **Rarity sistemi:** common/uncommon/rare/epic/legendary — her basarima nadir seviyesi
- **Yeni basarimlar:** Bilet tier eslesmeleri (Diamond→Legendary), milestone'lar (100/500/1000 bilet, 5K/100K coin), set ilerlemesi (2/4 set), charm ilerlemesi, jackpot sayaclari
- **Yeni gizli basarimlar:** Joker Festivali (5x), Uclu Sinerji (3 sinerji/bilet), Durdurulamaz (10 ardisik), Kral Midas (10K/tur), Yeni Baslayanin Sansi (ilk bilet jackpot)
- **Toast yenilendi:** Slide-in bounce (TRANS_BACK), rarity-renk seridi, scale pulse (TRANS_ELASTIC), shimmer animasyonu, CP ucma efekti
- **Toast efektleri:** Mini konfeti (tum), screen shake (epic+), tam konfeti + kenar flash (legendary)
- **Basarim ekrani yenilendi:** Kategori ilerleme cubuklari, rarity renk seridi, acilmis basarimlarda rarity etiketi
- **Bugfix:** `ticket.gd` is_special tip cikarim hatasi duzeltildi (`:=` → `: bool =`, Godot 4.6 uyumluluk)

### Session Gorevleri Duzeltme (2026-02-24)
- **Baslangic parasi 20 coin:** `game_state.gd` base 50→20 (Paper ile buildup zorunlu)
- **5 yeni bilet turu:** Diamond(7.5K), Emerald(20K), Ruby(50K), Obsidian(125K), Legendary(300K)
  - 10 yeni sembol: Yakut, Safir, Zumrut, Inci, Ates, Kurukafa, Tekboynuz, Yildirim, Capa, Kristal
  - Her tier: artan alan sayisi (12→18), artan sembol havuzu (17→25), artan ozel sembol sanslari
  - Carpan aralikları: Diamond jackpot x40-100, Legendary jackpot x100-300
  - Koleksiyon dusme sanslari: Diamond %22, Legendary %40
  - Tema renkleri: tier_bg + tier_color 5 yeni tier icin (dark+light)
  - Bilet butonlari: ScrollContainer ile yatay kaydirma (10 buton)
  - Fiyat gosterimi: format_number ile (7.5K, 20K, vb.)
- **Altin bilet duzeltmesi:** Yakalandiginda mevcut bilet ucreti iade ediliyor (onceden sonraki bilet bedavaydi)
- **Bilet gecis hizi:** 0.75s bekleme kaldirildi, aninda yeni bilet geliyor
- **Ozel sembol kutlama gorseli:** Joker/Bomba eslesmeye katildiginda farkli gosteriliyor
  - Joker: mor "JOKER!" popup, mor glow, double-bounce animasyonu, 3px kalin border
  - Bomba: turuncu "BOMBA +1!" popup, turuncu glow, ayni ozel animasyon
  - Siralama: once normal semboller patlar, sonra ozel semboller sonda parlak giris yapar
  - Yeni fonksiyonlar: `scratch_area.gd` → `play_special_slam_pop()`, `ticket.gd` → `_show_special_pop()`

### Eslesme Gorselligi Iyilestirme (2026-02-24) `b446c48`
- MatchResult popup kaldirildi (`match_result.gd`, `MatchResult.tscn` silindi)
- Eslesme sonucu bilet uzerinde gosteriliyor (kutlama orkestratoru: `ticket.gd`)
- Eslesen semboller tek tek patliyor (staggered slam pop, escalating screen shake)
- Her pop'ta carpan degeri gosteriliyor (x1, x1, x1!! kumar tarzi)
- Eslesmeyenler soluklasiyor (%30 alpha), eslesenler parlak border + shadow glow
- 4+ eslesmelerde final slam (ekstra shake + ekran flash)
- Odul bilgisi: tier basligi (JACKPOT/BUYUK ESLESME/ESLESME), detay, coin animasyonu, otomatik gecis (1.5-2.5s)
- Eslesme yoksa: tum semboller soluk + "Eslesme yok..." + 1.5s otomatik devam
- Yeni fonksiyonlar: `scratch_area.gd` → `play_slam_pop()`, `dim()`, `reset_celebration()`
- Yeni sinyal: `ticket.gd` → `celebration_finished`

### Gorsel Tema Yenileme (2026-02-23)
- Neon casino temasi kaldirildi, dual palet sistemi (Dark + Light) eklendi
- 19 dosya guncellendi: ThemeHelper, GameState, SaveManager, SettingsPopup, 11 ekran/UI scripti, shader, scratch_area
- Ayarlar popup'ina tema toggle butonu eklendi
- Viewport clear color tema ile senkronize edildi
- Tum ekranlar her iki temada test edildi ve onaylandi

### Gorsel Efekt + Surukle Kazima + Otomatik Bilet (2026-02-24)
- Surukleyerek kazima: `_gui_input` kaldirildi, `ticket.gd:_input()` ile drag koordinatoru eklendi
- Radial glow: Slam pop sirasinda sembol arkasinda shader-bazli isik patlamasi
- Mini-konfeti: 4+ eslesmede kucuk konfeti (25 parcacik)
- Screen punch: Yonlu itme efekti (sol/sag/yukari/asagi dongusel)
- Scratch parcaciklari guclendi: 20 parcacik, sicak altin-metalik renk, genis yayilma
- Otomatik bilet: Son secilen tur hatirlanir, bilet bitince otomatik ayni turden yeni bilet gelir
- Kazimadan degistirme: Ilk kazimaya kadar bilet ucretsiz degistirilebilir (coin ilk kazimada cekilir)
- Coin delta gostergesi: Kirmizi `-tutar` (para cekildiginde), yesil `+tutar` (kazanildiginda) coin altinda overlay (28px, 2.5s kalicilik)

### UX Hiz + Buyuk Panel Iyilestirmesi (2026-02-24) `95fdb5f`
- DEVAM butonu kaldirildi, otomatik timer ile gecis (jackpot: 2.5s, big: 2.0s, normal: 1.5s)
- Dokunmayla hizli gecis: kutlama sirasinda dokunma → aninda yeni bilete gec
- Bilet boyutu viewport oranli dinamik hesaplama (ekranin %42'si bilete)
- TopBar: 60→160px, coin fontu 32px, bilet/enerji fontu 28px, padding 16/20
- BottomPanel: 200→300px, buton fontlari 22-24px
- Coin delta: overlay pozisyon (coin altinda), 28px font, 2.5s kalicilik, parlak renkler
- Konfeti: 60→100 parcacik, 85 derece spread, 4-8 boyut
- Kenar isigi efekti: jackpot/YOLO'da sol/sag kenar flash
- Jackpot: ikinci mini konfeti dalgasi (0.4s sonra)
- Big win: mini konfeti eklendi
- Glow scale artisi: 1.2+0.3i (buyuk bilette daha genis)
- Sembol font boyutu alan boyutuna oranli (14-32px)
- Yeni bilet gecikme: 0.75s (kutlama sonrasi)

### Gorsel Readability + Test Harness Iyilestirmesi (2026-02-24)
- **Tema renkleri yenilendi:** Her iki modda goz dostu, soft renkler
  - Dark: bg (0.08,0.08,0.11) → daha belirgin panel ayrimlari, soft aksanlar (neon yerine yumusak tonlar)
  - Light: Kontrast artirildi — buton bg tint x2 guclendirildi, border kalinligi 2px, border alpha artirildi
- **Buton stilleri:** 2px border, 12px radius, daha belirgin arka plan (light modda accent*0.18+0.78)
- **Panel/kart stilleri:** 2px border, shadow eklendi (top bar golge efekti)
- **Efektler yumusatildi:** Flash alpha 0.7→0.35, shake intensity %40 azaltildi, konfeti 100→60 parcacik
- **Kenar isigi:** 40→24px genislik, alpha 0.6→0.4
- **Slam pop:** Shadow 8+5i→5+3i, glow alpha 0.85→0.55, slam scale 1.5→1.3, rotation ±10→±6
- **Font boyutlari artirildi:** Alt butonlar 13→15px, enerji/charm 20→22px, kart isimleri 15→16px, aciklamalar 12→13px
- **Test Harness v2:** click_button artik `emit_signal("pressed")` kullanir (sim_click yerine)
  - Yeni komutlar: `change_scene` (alias destegi), `set_theme`, `set_coins`, `set_energy`, `list_buttons`
  - click_button sonrasi 0.8s bekleme (sahne gecis animasyonu icin)

---

## PC Versiyonu Notu
- PC versiyonu ayri proje: `D:\godotproject\incremental`
- PC'de: Buildings, oto-kazima, prestige, yatay layout, $4.99 premium
- Mobilde: Enerji, charm, session-based, dikey layout, F2P
- Ortak: Kazima mekanigi, eslesme sistemi, sembol havuzu, sinerji
