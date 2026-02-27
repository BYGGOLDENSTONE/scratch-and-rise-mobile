# Scratch & Rise Mobile - Game Design Document

## Genel Bakis
- **Tur:** 2D Kazi Kazan (Session-based, Roguelite progression)
- **Motor:** Godot 4.x (GDScript)
- **Platform:** Android (oncelikli), sonra iOS
- **Fiyat:** Ucretsiz (F2P)
- **Monetizasyon:** Reklam (AdMob) + IAP (Enerji paketleri)
- **Tema:** Kazi kazan + kripto/kumar meme kulturu
- **Oryantasyon:** Dikey (Portrait)
- **Hedef Kitle:** Casual mobil oyuncular, kazi kazan severler

## Konsept
Gercek bir kazi kazan deneyimi. Oyuncu enerji harcayarak tura baslar, baslangic parasiyla biletler satin alir, kazir ve eslesme arar. Eslesme varsa kazanir, yoksa o bilet bosa gider. Para bitince tur biter. Her bilet acilisinda Gem kazanilir, Gem'ler ile Luck Charm'lar alinarak kalici guc kazanilir. Kripto ve kumar dunyasinin meme kulturuyle sarmalanmis esprili bir ton.

---

## Para Birimleri

| Para Birimi | Rolu | Kalici mi? | Harcanir mi? |
|---|---|---|---|
| **Coin** | Tur ici bilet alma, risk yonetimi | Gecici (tur sonunda sifir) | Evet |
| **Gem** | Charm acma, upgrade | Kalici | Evet |

### Gem Kazanma
Her bilet acilisinda (eslesme olsun olmasin) bilet tier'ina gore gem kazanilir:

| Bilet | Fiyat | Gem |
|---|---|---|
| Kagit | 5 | 0 |
| Bronz | 25 | 1 |
| Gumus | 100 | 1 |
| Altin | 500 | 2 |
| Platin | 2,500 | 3 |
| Elmas | 7,500 | 4 |
| Zumrut | 20,000 | 5 |
| Yakut | 50,000 | 6 |
| Obsidyen | 125,000 | 7 |
| Efsane | 300,000 | 8 |

- Kagit ile gem kazanilmaz → yuksek tier'e gecmeye tesvik
- Bir turda 5-6 bilet acan oyuncu ~5-15 gem kazanir
- Ek kaynaklar: Gunluk giris odulu, gunluk gorevler, basarimlar

---

## Temel Oyun Dongusu

### Ana Hedef
**En az bilette en yuksek coin'e ulasmak.** Coin = tur ici performans. Gem = kalici ilerleme.

### Tur Dongusu (Session)
```
ENERJI HARCA (1) --> 20 COIN AL --> BILET SATIN AL --> KAZI
                                          |
                                     ESLESME VAR?
                                     /          \
                                  EVET          HAYIR
                                  /                \
                            COIN KAZAN        HICBIR SEY
                            + GEM KAZAN       (parayi zaten verdin)
                            (bilet acilisi)   (ama gem yine kazanilir!)
                                 |
                           STRATEJIK KARAR:
                     Ucuz bilet (coin biriktir, dusuk gem)
                        veya
                     Pahali bilet (coin harca, yuksek gem)
                                 |
                       PARA BITTI --> TUR BITER
                                 |
                          GEM ILE CHARM AL
                         (meta progression)
```

### Strateji
```
Kagit bilet (5 coin):  ROI x1.20 (karli!) ama 0 gem
Bronz bilet (25 coin): ROI x0.96 (basabas) ama 1 gem
Altin (500 coin):      ROI x0.35 (zarar!) ama 2 gem
Platin (2.5K coin):    ROI x0.19 (buyuk zarar!) ama 3 gem

Akilli oyuncu: Paper ile coin biriktir → yuksek tier'a gec → gem topla → drain ol → Paper'a don
Aceleci oyuncu: Hemen pahali bilet → hizli batar, az gem
Sabirli oyuncu: Hep Paper → asla batmaz, ama 0 gem (hic ilerleme yok!)
```

### Meta Dongusu
```
TUR OYNA --> GEM KAZAN --> CHARM AL --> DAHA GUCLU BASLA --> DAHA VERIMLI TUR --> DAHA COK GEM
```

### Onemli Kurallar
- Kazima para vermez. Kazima **sembolleri acar**. Eslesme **para kazandirir**.
- Bilet satin almak = o parayi riske etmek. Eslesme yoksa hicbir sey donmez.
- Paper her zaman karli ama gem vermez — sonsuz grind ilerleme saglamaz.
- Gem her bilet acilisinda kazanilir (eslesme sarti yok) — risk alan odullendirilir.
- Oyunun ozi: Coin yonetimi ile gem toplama verimliligi.

---

## Enerji Sistemi

| Ozellik | Deger |
|---------|-------|
| Max enerji | 5 (Charm ile artirilabilir) |
| Yenilenme | 10 dakikada 1 enerji |
| Full dolma | ~50 dakika |
| 1 enerji | = 1 tur = 20 coin baslangic |

### Enerji Kazanma Yollari
- **Zamanla:** 10 dakikada 1, otomatik
- **Reklam:** Video reklam izle = +1 enerji (gunluk limit: 10)
- **IAP:** Enerji paketi satin al (gercek para ile)
- **Charm:** "Enerji Deposu" charm'i max enerjiyi artirir

### Tur Baslangici
1. Oyuncu "OYNA" butonuna basar
2. 1 enerji harcanir
3. 20 coin verilir (Charm ile arttirilabilir)
4. Bilet secim ekrani acilir
5. Oyuncu bilet satin alir, kazir, kazanir veya kaybeder
6. Para bitince "TUR BITTI" ekrani gelir

---

## Kazima Mekanigi

### Bilet Yapisi
Her bilette **kazinacak alanlar** var. Her alanin altinda gizli bir sembol.

```
Kagit Bilet (6 alan):
+---------------------------+
|  [###]  [###]  [###]      |
|  [###]  [###]  [###]      |
|                           |
|  Kazi ve eslesmeleri bul! |
+---------------------------+
```

### Kazima Islemi
1. Oyuncu biletteki alanlara **dokunur** veya **parmak surukler**
2. Dokunulan alan kazinir, altindaki sembol ortaya cikar
3. Tum alanlar kazinininca **eslesme kontrolu** yapilir
4. Eslesme sonucuna gore coin kazanilir veya kazanilmaz
5. Oyuncu yeni bilet alabilir (parasi yetiyorsa)

### Kazima Sonrasi
```
Eslesme varsa:
+---------------------------+
|  [K]  [L]  [K]            |
|  [U]  [K]  [L]            |
|                           |
|  K x3 = ESLESME!          |
|  +75 Coin!                |
+---------------------------+

Eslesme yoksa:
+---------------------------+
|  [K]  [L]  [U]            |
|  [L]  [U]  [K]            |
|                           |
|  Eslesme yok...           |
|  0 Coin                   |
+---------------------------+
```

---

## Bilet Sistemi

### Bilet Turleri
| Bilet | Fiyat | Alan | Sembol | base_reward | ROI | Gem | Acilma |
|-------|-------|------|--------|-------------|-----|-----|--------|
| Kagit | 5 | 6 | 5 | 5 | x1.20 | 0 | Baslangic |
| Bronz | 25 | 8 | 7 | 12 | x0.96 | 1 | Baslangic |
| Gumus | 100 | 9 | 11 | 38 | x0.67 | 1 | Baslangic |
| Altin | 500 | 9 | 12 | 65 | x0.35 | 2 | Baslangic |
| Platin | 2,500 | 9 | 15 | 100 | x0.19 | 3 | Baslangic |
| Elmas | 7,500 | 9 | 17 | 225 | x0.17 | 4 | Baslangic |
| Zumrut | 20,000 | 9 | 19 | 430 | x0.15 | 5 | Baslangic |
| Yakut | 50,000 | 9 | 21 | 750 | x0.12 | 6 | Baslangic |
| Obsidyen | 125,000 | 9 | 23 | 1,000 | x0.09 | 7 | Baslangic |
| Efsane | 300,000 | 9 | 25 | 1,800 | x0.07 | 8 | Baslangic |

### Bilet Mantigi
- Tum biletler max 9 alan (Paper=6, Bronze=8, Silver+=9) — 3x3 grid
- Daha pahali bilet = daha genis sembol havuzu = eslesme **zorlasir**
- Dusuk ROI = coin kaybedersin AMA gem/bilet **cok yuksek**
- Oyuncu stratejik secim yapar: coin biriktir mi (Paper), gem icin risk al mi (yuksek tier)?

### Risk / Odul Ornekleri
```
Kagit Bilet (5 coin) — "Guvenli liman"
- Eslesme yok (%53): 0 coin (5 coin kaybettin)
- Normal eslesme (%39): 5-10 coin (kucuk kar)
- Buyuk eslesme (%7): 15-25 coin (guzel!)
- Jackpot (%1): 40-75 coin (harika!)
- ROI x1.20 = uzun vadede karli, ama 0 gem

Altin Bilet (500 coin) — "Buyuk risk, buyuk gem"
- Eslesme yok (%41): 0 coin (500 coin kaybettin!) ama 2 gem kazandin
- Normal eslesme (%47): 65-195 coin (yine zarar) + 2 gem
- Buyuk eslesme (%11): 195-520 coin (basabas veya kucuk kar) + 2 gem
- Jackpot (%1): 975-2600 coin (buyuk kar!) + 2 gem
- ROI x0.35 = cogu zaman zarar, ama gem kazanimi Paper'in sonsuz kati
```

---

## Eslesme Sistemi

### Eslesme Kurallari
- **2 ayni sembol** = eslesme sayilmaz
- **3 ayni sembol** = eslesme odulu (bilet fiyati x 1-5)
- **4 ayni sembol** = buyuk eslesme (bilet fiyati x 5-20)
- **5+ ayni sembol** = JACKPOT (bilet fiyati x 20-100)
- **Eslesme yok** = 0 coin. Hicbir sey donmez.

### Odul Hesaplama
```
Odul = bilet_baz_odulu x eslesme_carpani x charm_bonusu
```

### Beklenen Deger (ROI Egrisi)
Her tier'in farkli ROI'si var — bu oyunun stratejik omurgasi:
- **Paper (x1.20):** Hafif karli — coin biriktirme araci, 0 gem
- **Bronze (x0.96):** Basabas — eglenceli, 1 gem
- **Silver-Gold (x0.35-0.67):** Zarar — ama 1-2 gem
- **Platinum+ (x0.06-0.19):** Buyuk zarar — ama 3-8 gem
Oyuncu stratejisi: Paper ile buildup → yuksek tier'da gem icin harca → drain ol → Paper'a don

### Ozel Semboller (Nadir cikar)
| Sembol | Efekt | Cikma Sansi |
|--------|-------|-------------|
| Joker | Her sembolle eslesir | %5 |
| Carpan x2 | Bilet toplam odulunu x2 | %3 |
| Bomba | Tum alanlari aninda kazir | %2 |
| Altin Yildiz | Bilet odulu x5 | %1 |

### Seffaf Matematik
Bilet tamamlaninca hesaplama canli gosterilir:
```
K x3 = ESLESME! --> 5 x5 = 25 Coin
Carpan sembolu --> x2!
-------------------
Toplam: 25 x 2 = 50 Coin!
```
Oyuncu her zaman neden kazandigini ve nasil daha fazla kazanacagini bilir.

---

## Sinerji Sistemi

Ayni bilette belirli semboller bir arada cikarsa ozel bonus tetiklenir.

### Sinerjiler
| Sinerji | Kosul | Bonus | Ilk Mumkun |
|---------|-------|-------|-----------|
| Meyve Kokteyli | Kiraz + Limon + Uzum (3 farkli meyve) | Odul x3 | Kagit |
| Gece Gokyuzu | Yildiz + Ay (ikisi birden) | Odul x4 | Bronz |
| Lucky Seven | 7 + 7 + 7 (3 adet 7) | Odul x10 | Altin |
| Kraliyet | Tac + Elmas (ikisi birden) | Odul x5 | Altin |
| Ejderha Atesi | Ejderha + Anka (ikisi birden) | Odul x8 | Platin |
| Full House | Tum alanlar ayni sembol | Odul x25 | Herhangi |
| Gokkusagi | 5+ farkli sembol ayni bilette | Odul x5 | Gumus |
| ??? | Gizli | ??? | ??? |

### Sinerji Kesif Sistemi
- Kesfedilmemis sinerjiler albumde "???" olarak gorunur
- Ilk kesiftte: Buyuk animasyon + "YENI SINERJI KESFEDILDI!" + bonus odul
- Kesfetme motivasyonu = uzun vadeli hedef
- Charm ile sinerji sansi artirilabilir

---

## Luck Charm Sistemi (Meta Progression)

Oyunun kalbi. Turlar arasi kalici bonuslar. Oyuncunun "bir daha oynayacagim cunku daha gucluyum" hissi.
Charm'lar **Gem** ile satin alinir ve seviye atlatilir.

### Charm Listesi

#### Temel Charm'lar (Ucuz, erken oyun)
| Charm | Gem | Etki | Max Lv | Full Maliyet |
|-------|-----|------|--------|--------------|
| Sans Tokasi | 1 | Eslesme odulu +%10 | 20 | 20 gem |
| Zengin Baslangic | 2 | Baslangic parasi +10 coin | 10 | 20 gem |
| Keskin Goz | 1 | 3'lu eslesme sansi +%5 | 15 | 15 gem |
| Hizli Parmak | 1 | Kazima animasyonu hizlanir | 10 | 10 gem |

#### Orta Charm'lar (Biraz biriktir)
| Charm | Gem | Etki | Max Lv | Full Maliyet |
|-------|-----|------|--------|--------------|
| Sansli Yildiz | 3 | Ozel sembol sansi +%4 | 5 | 15 gem |
| Ikinci Sans | 5 | Eslesme yoksa tekrar cekme %10 | 5 | 25 gem |
| Hazine Avcisi | 4 | Koleksiyon dusme sansi +%20 | 5 | 20 gem |
| Cifte Sans | 3 | 4+ eslesmede ekstra +%8 coin | 5 | 15 gem |
| Miknatis | 5 | Sinerji sansi +%6 | 5 | 25 gem |
| Erken Kus | 3 | Ilk bilet %15 indirimli | 10 | 30 gem |
| Sans Carki | 7 | Her 5. bilette bonus olay +%10 | 3 | 21 gem |
| Koleksiyoncu Ruhu | 4 | Koleksiyon dusunce +1 gem | 5 | 20 gem |
| Combo Ustasi | 7 | Ardisik eslesme bonusu +%5 | 5 | 35 gem |
| Dayaniklilik | 4 | Enerji yenilenme hizi +%15 | 3 | 12 gem |
| Son Hamle | 8 | Coin < 20 ise bedava Paper, tur basi 1x | 3 | 24 gem |

#### Guclu Charm'lar (Pahali, gec oyun)
| Charm | Gem | Etki | Max Lv | Full Maliyet |
|-------|-----|------|--------|--------------|
| Joker Miknatisi | 4 | Joker sembol sansi +%3 | 5 | 20 gem |
| Carpan Gucu | 7 | Carpan sembol sansi +%2 | 5 | 35 gem |
| Enerji Deposu | 10 | Max enerji +1 | 3 | 30 gem |
| Sinerji Radari | 4 | Sinerji sansi +%5 | 10 | 40 gem |
| Altinparmak | 12 | Tum oduller +%15 | 10 | 120 gem |
| Kral Dokunusu | 25 | 4+ eslesme odulu x2 | 3 | 75 gem |
| YOLO | 18 | %1 sansla bilet odulu x50 | 1 | 18 gem |
| Mega Baslangic | 14 | Baslangic parasi +50 coin | 5 | 70 gem |

### Charm Ozet
- **Tum charmlari fullemek:** ~645 gem
- **Tur basi kazanim:** ~5-15 gem
- **Full charm:** ~45-130 tur

### Charm Sifirlama (Opsiyonel Gec Oyun)
- Tum charm'lari sifirla = gem'leri geri al + %10 bonus
- "Rebirth" hissi, yeniden dagitma ozgurlugu
- Sadece cok ileri oyuncular icin

---

## Rastgele Olaylar (Tur Ici)

Tur sirasinda beklenmedik anlarda dopamin patlamasi.

### Altin Bilet
- Tur icinde rastgele beliren parlak bilet (her 5-8 bilette bir sans)
- Dokunursan: Ucretsiz bir bilet kazirsin (para gitmez!)
- 5 saniye icinde dokunmazsan kaybolur (FOMO)

### Sansli Anlar
| Olay | Sart | Etki |
|------|------|------|
| Bull Run | Rastgele | "BULL RUN! Sonraki 3 bilet odulleri x2!" |
| Bedava Bilet | Her 10. bilette %20 sans | Sonraki bilet ucretsiz |
| Joker Yagmuru | Cok nadir (%1) | Sonraki bilette tum semboller Joker |
| Mega Bilet | Cok nadir (%0.5) | Normal bilet yerine garanti jackpot |

---

## Koleksiyon Sistemi

Biletlerden rastgele koleksiyon parcalari duser. Set tamamlama = kalici bonus (charm gibi, hic sifirlanmaz).

| Set | Parcalar | Bonus |
|-----|----------|-------|
| Meyve Seti | Kiraz + Limon + Uzum + Karpuz | Eslesme odulu +%15 |
| Degerli Taslar | Yakut + Zumrut + Safir + Elmas | Ozel sembol sansi +%20 |
| Sansli 7'ler | 7 (Kirmizi, Mavi, Yesil, Altin) | Jackpot odulu +%25 |
| Kripto Set | Bitcoin + Ethereum + Doge + Rocket | Baslangic parasi +25 |
| Kozmik | Yildiz + Ay + Gunes + Galaksi | Tum oduller +%20 |
| Meme Lords | Doge + Pepe + Moon + Lambo | Altin bilet belirme sansi +%25 |

Koleksiyon parcalari nadir duser. Daha pahali biletlerden daha yuksek sans.

---

## Basarim Sistemi

### Erken Oyun
| Basarim | Kosul | Odul |
|---------|-------|------|
| Ilk Kazima | 1 bilet tamamla | 1 gem |
| Ilk Eslesme | Ilk eslesme | 2 gem |
| Kucuk Adimlar | 100 toplam coin kazan | 3 gem |
| Sinerji Avcisi | Ilk sinerji kesfet | 3 gem |
| Seri Kazici | Bir turda 10 bilet kazi | 2 gem |

### Orta Oyun
| Basarim | Kosul | Odul |
|---------|-------|------|
| Gumus Kazici | Gumus bilet ac | 3 gem |
| Altin Avci | Altin bilet ac | 5 gem |
| Jackpot! | Ilk jackpot vur | 5 gem |
| Koleksiyoncu | Ilk seti tamamla | 5 gem |
| Zengin Tur | Bir turda 500+ coin kazan | 4 gem |

### Gec Oyun
| Basarim | Kosul | Odul |
|---------|-------|------|
| Platin Seri | Platin bilet ac | 8 gem |
| Combo Master | 5 farkli sinerji kesfet | 8 gem |
| Milyoner | Bir turda 1000+ coin kazan | 10 gem |
| Tam Set | Tum koleksiyonlari tamamla | 15 gem |
| Charm Ustasi | 50 charm seviyesi topla | 10 gem |

### Gizli Basarimlar
| Basarim | Kosul | Odul |
|---------|-------|------|
| ??? | 3x Joker ayni bilette | 8 gem |
| ??? | Ardisik 5 bilet eslesme | 5 gem |
| ??? | Tek bilette 2 sinerji | 10 gem |
| ??? | 0 coin ile tura basla (charm'siz) ve 500+ coin bitir | 12 gem |

---

## Leaderboard Sistemi

Google Play Games Services (Android) / Game Center (iOS) uzerinden.

### Skor Metrigi
- **Siralama:** Max coin ÷ bilet sayisi (verimlilik)
- **Gosterim:** Hem turda ulasilan max coin hem bilet sayisi ayri ayri gorunur
- **Minimum esik:** Yok (balans sistemi bunu dogal olarak cozuyor — 20 coin baslangic, ilk bilet Kagit, yuksek coin icin yuksek tier bilet + buyuk eslesme sart)

### Leaderboard Turleri
| Leaderboard | Reset | Motivasyon |
|---|---|---|
| Gunluk | Her gece sifirlanir | "Bugun 1. olayim" — kisa vadeli heyecan, her gun geri getirme |
| Haftalik | Her pazartesi sifirlanir | "Bu hafta formumu koruyayim" — orta vadeli hedef, ciddi rekabet |

### Neden Bu Metrik?
Oyunun temel amaci "en az bilette en yuksek coin'e ulasmak". Leaderboard bunu dogrudan odullendirir:
- Yuksek coin icin pahali biletlerde buyuk eslesmeler lazim (risk)
- Az bilet icin verimli coin yonetimi lazim (strateji)
- Kagit bilette jackpot bile vursan max coin dusuk kalir (sistem kendini koruyor)

### Ornek Gorunum
```
+------------------------------------------+
|  GUNUN EN IYILERI                        |
+------------------------------------------+
|  1. Gamer42    12,400 coin   4 bilet     |
|  2. Ahmet       8,900 coin   7 bilet     |
|  3. Zeynep      5,200 coin  12 bilet     |
|  ...                                      |
|  524. Sen        320 coin   18 bilet     |
+------------------------------------------+
|         [ Gunluk | Haftalik ]            |
+------------------------------------------+
```

### Teknik
- Google Play Games Services (ucretsiz, sunucu gereksiz)
- 2 ayri leaderboard tanimlanir (gunluk + haftalik)
- Tur sonunda skor otomatik gonderilir
- Godot eklentisi ile entegrasyon

---

## Monetizasyon

### Reklam (AdMob)
| Yer | Tur | Zorunlu mu? |
|-----|-----|-------------|
| Tur sonu | Rewarded Video (gem x2) | Hayir, opsiyonel |
| Enerji | Rewarded Video (+1 enerji) | Hayir, opsiyonel |
| Tur arasi | Interstitial (her 3 turda 1) | Evet, ama kapatilabilir (IAP) |
| Banner | Alt kisimda kucuk banner | Evet, ama kapatilabilir (IAP) |

### IAP (In-App Purchase)
| Urun | Fiyat | Icerik |
|------|-------|--------|
| 5 Enerji | $0.99 | 5 enerji |
| 15 Enerji | $1.99 | 15 enerji (%25 bonus) |
| 50 Enerji | $4.99 | 50 enerji (%40 bonus) |
| Reklam Kaldirma | $2.99 | Interstitial ve banner kaldirilir (kalici) |
| Baslangic Paketi | $3.99 | 20 enerji + 20 gem + Reklam kaldirma |

### Monetizasyon Felsefesi
- **Asla pay-to-win degil.** Reklam/IAP sadece enerji (daha cok oynama hakki) verir.
- Charm'lar, biletler, eslesme oranlari SATIN ALINAMAZ.
- Reklam izlemek opsiyonel ama odullendirici (gem x2, +1 enerji).
- Sabir gosterirsen bedava oynayabilirsin.

---

## Ilerleme Asamalari

### ASAMA 1: Ilk Turlar (0-10 gem)
*"Ilk adim... WAGMI"*
- Kagit biletlerle ogren (gem yok ama coin biriktir)
- Bronz bilete gec = ilk gem'ler
- Ilk eslesme heyecani
- Sans Tokasi, Keskin Goz charm'lari (1 gem)
- Hedef: Sistemi ogren, ilk charm'lari al

### ASAMA 2: Bronz Donem (10-50 gem)
*"Bronza gectik, artik ciddiyiz"*
- Bronz/Gumus biletlerle gem biriktir
- Gece Gokyuzu sinerjisi kesfedilebilir
- Zengin Baslangic charm'i ile daha uzun turlar
- Hedef: Orta charm'lara yatirim

### ASAMA 3: Stratejik Donem (50-200 gem)
*"Artik hesap yapiyoruz"*
- Altin + Platin biletlere ulasmak = 2-3 gem/bilet
- Buyuk risk, buyuk odul
- Turda bilet cesidi secimi onemli: ucuz ile mi basla, pahali ile mi riske gir?
- Sinerjiler ve ozel semboller devreye girer
- Hedef: Guclu charm'lar

### ASAMA 4: Usta Donem (200+ gem)
*"Kazi kazan imparatoru"*
- Elmas+ biletler = dev oduller veya dev kayiplar, 4-8 gem/bilet
- Tum sinerjiler ve koleksiyonlar pesinde
- Charm optimizasyonu (hangisini max'layim?)
- Gizli basarimlar avinda
- Leaderboard rekabeti
- Sonsuz replayability

---

## Ekran Tasarimi (Dikey / Portrait)

### Ana Menu
```
+---------------------------+
|     SCRATCH & RISE        |
|        [logo]             |
|                           |
|    Enerji: ### 3/5        |
|    10:00'da +1            |
|                           |
|      [ OYNA! ]            |
|                           |
|  [Charm] [Koleksiyon]     |
|  [Basarim] [Ayarlar]      |
+---------------------------+
```

### Oyun Ekrani (Tur Ici)
```
+---------------------------+
|  Coin: 35   Bilet: Kagit  |
+---------------------------+
|                           |
|    +---+ +---+ +---+     |
|    |###| |###| | K |     |
|    +---+ +---+ +---+     |
|    +---+ +---+ +---+     |
|    |###| | L | |###|     |
|    +---+ +---+ +---+     |
|                           |
|    [AKTIF BILET ALANI]    |
|                           |
+---------------------------+
|  Bilet Sec:               |
|  [Kagit 5] [Bronz 15]    |
|  [Gumus 40] [Altin 100]  |
+---------------------------+
|         [banner]          |
+---------------------------+
```

### Eslesme Sonuc Ekrani
```
+---------------------------+
|                           |
|     K x3 = ESLESME!       |
|                           |
|     5 x 5 = 25 Coin!     |
|     Carpan x2!            |
|     ----------------      |
|     TOPLAM: 50 Coin!      |
|                           |
|     [ DEVAM ]             |
|                           |
+---------------------------+
```

### Tur Bitti Ekrani
```
+---------------------------+
|       TUR BITTI!          |
|                           |
|  Toplam bilet: 8          |
|  Eslesme: 4               |
|  Max coin: 1,240          |
|                           |
|  Kazanilan: +7 gem        |
|                           |
|  [Reklam izle: gem x2]   |
|  [ ANA MENU ]            |
+---------------------------+
```

### Charm Ekrani
```
+---------------------------+
|  LUCK CHARM'LAR  42 gem   |
+---------------------------+
|                           |
| Sans Tokasi     Lv.3  [+]|
| +%30 eslesme odulu  1 gem |
|                           |
| Zengin Baslangic Lv.1 [+]|
| +10 coin baslangic  2 gem |
|                           |
| Keskin Goz      Lv.5  [+]|
| +%25 eslesme sansi  1 gem |
|                           |
+---------------------------+
```

---

## Gunluk Sistemler

### Gunluk Giris Odulu
7 gunluk dongu, her gun artan odul. Sifir efor, sadece oyunu acmak yeterli.

| Gun | Odul |
|-----|------|
| 1 | +1 enerji |
| 2 | +2 gem |
| 3 | Rastgele koleksiyon parcasi |
| 4 | +2 enerji |
| 5 | +5 gem |
| 6 | +3 enerji |
| 7 | +15 gem + Rastgele koleksiyon parcasi |

7. gunden sonra tekrar 1. gune doner.
Ardisik giris zorunlu — 1 gun atlarsan sayac sifirlanir.

### Gunluk Gorevler
Her gun 3 rastgele gorev verilir. Tamamlayinca bonus odul.

```
Gunluk Gorevler:
☐ 5 bilet kazi           → +1 enerji
☐ 1 sinerji bul          → +2 gem
☐ Gold+ bilet ac         → +3 gem
━━━━━━━━━━━━━━━━━━━━━━━━
Hepsini tamamla           → +5 gem bonus
```

Gorev havuzu (rastgele secilir):
| Gorev | Odul |
|-------|------|
| X bilet kazi | +1 enerji |
| 1 sinerji bul | +2 gem |
| Gold+ bilet ac | +3 gem |
| 3 eslesme yap | +2 gem |
| 1 koleksiyon parcasi bul | +3 gem |
| Jackpot vur | +5 gem |
| X coin kazan (tek tur) | +2 gem |

---

## Lokalizasyon

Godot'un dahili CSV-tabanli ceviri sistemi kullanilir. Kodda `tr("KEY")` ile erisim.

### Desteklenen Diller
| Dil | Kod | Pazar | Oncelik |
|-----|-----|-------|---------|
| Ingilizce | en | Global | Zorunlu |
| Turkce | tr | Turkiye | Zorunlu |
| Ispanyolca | es | Latin Amerika + Ispanya | Yuksek |
| Portekizce | pt_BR | Brezilya | Yuksek |
| Almanca | de | Almanya/Avusturya | Orta |
| Fransizca | fr | Fransa/Afrika | Orta |
| Japonca | ja | Japonya | Orta |

### Teknik
- `assets/translations/translations.csv` dosyasinda tum metinler
- Godot Project Settings → Localization → CSV eklenir
- Dil secimi: Ayarlar popup'inda veya cihaz diline gore otomatik
- Sayi formati: locale'e gore (1,000 vs 1.000)
- Sembol/charm isimleri de cevrilir

---

## Gorsel Stil
- Parlak, canli renkler (neon yesil, altin, mor)
- Neon casino estetigi + kripto meme ikonlari
- Kazima efekti: Metalik gri alan, dokunununca shader ile "kazinma" animasyonu
- Sembol acilma: Sprite animasyonu + Tween ile buyume/parilt
- Eslesme bulundu: Eslesen semboller parlar + coin sayisi havada ucar
- Sinerji kesffi: Ekran titremesi + parlama efekti + ses
- Jackpot: Konfeti yagmuru + "JACKPOT!" yazisi + ekran flas
- Buyuk sayilarda ekran sallantisi (juice!)

---

## Save Sistemi

### Kaydedilen Veriler
- Charm seviyeleri ve gem miktari
- Koleksiyon parcalari
- Kesfedilen sinerjiler
- Basarimlar
- Istatistikler (toplam bilet, toplam coin, en buyuk kazanc vs.)
- Enerji durumu + son cikis zamani (yenilenme hesabi icin)
- Ayarlar (ses, reklam tercihi)

### Kayit Yontemi
- **Lokal:** `user://save.json`
- **Bulut:** Google Play Games (Android), Game Center (iOS) - ileri asamada

### Enerji Yenilenme Hesabi
Oyuna geri donulugunde:
```
gecen_sure = simdi - son_cikis
yenilenen = floor(gecen_sure / 600) // 600 saniye = 10 dakika
enerji = min(enerji + yenilenen, max_enerji)
```

---

## Teknik Notlar

### Motor & Ayarlar
- Godot 4.x, GDScript
- 2D render (Mobile renderer)
- Hedef FPS: 60
- Oryantasyon: Portrait (dikey)
- Hedef cozunurluk: 720x1280 (scale)
- Touch input

### Mimari
- **2D Objeler (Node2D):** Bilet, kazima alanlari, semboller, efektler
- **UI (Control):** Ust bar, bilet secimi, charm ekrani, popup'lar
- **Autoload:** GameState (oyun durumu), SaveManager (kayit), AdManager (reklam)

### Gerekli Eklentiler
- **AdMob:** Reklam entegrasyonu (godot-admob-plugin)
- **IAP:** Google Play Billing (godot-google-play-billing)
- **Ileride:** iOS StoreKit, Google Play Games

### Kod ile Yapilacaklar
- Tum oyun mekanigi ve matematik
- Tween animasyonlari
- Kazima shader'i
- Ses sistemi
- Buyuk sayi formati: 1K, 1M, 1B...
- Olasilik sistemi (seffaf, hesaplama oyuncuya gosterilir)
- Save/load sistemi (JSON)
- Enerji yenilenme hesabi

### Disaridan Gerekli Asset'ler
- **Sembol gorselleri:** Kiraz, limon, uzum vb. (AI image generation)
- **Ses efektleri:** Kazima, coin, jackpot, sinerji sesleri
- **Muzik:** Arka plan muzigi
- **Font:** Casino/meme tarzi font
