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
Gercek bir kazi kazan deneyimi. Oyuncu enerji harcayarak tura baslar, baslangic parasiyla biletler satin alir, kazir ve eslesme arar. Eslesme varsa kazanir, yoksa o bilet bosa gider. Para bitince tur biter. Her turda kazanilan Luck Charm'lar kalici olarak oyuncuyu guclendirir. Kripto ve kumar dunyasinin meme kulturuyle sarmalanmis esprili bir ton.

---

## Temel Oyun Dongusu

### Ana Hedef
**En az bilette en cok CP (Charm Point) toplamak.** CP = kalici ilerleme. Coin sadece bilet almak icin bir arac.

### Tur Dongusu (Session)
```
ENERJI HARCA (1) --> 20 COIN AL --> BILET SATIN AL --> KAZI
                                          |
                                     ESLESME VAR?
                                     /          \
                                  EVET          HAYIR
                                  /                \
                            COIN KAZAN        HICBIR SEY
                            + CP KAZAN        (parayi zaten verdin)
                                 |
                           STRATEJIK KARAR:
                     Ucuz bilet (coin biriktir, dusuk CP)
                        veya
                     Pahali bilet (coin harca, yuksek CP)
                                 |
                       PARA BITTI --> TUR BITER
                                 |
                          CHARM PUANI (CP) KAZAN
                         (meta progression)
```

### CP Optimizasyon Stratejisi
```
Paper bilet (5 coin):  ROI x1.20 (karli!) ama CP/bilet = 0.07 (cok dusuk)
Gold bilet (500 coin): ROI x0.35 (zarar!) ama CP/bilet = 4.59 (65x daha iyi)
Platinum (2.5K coin):  ROI x0.19 (buyuk zarar!) ama CP/bilet = 11.6 (163x daha iyi)

Akilli oyuncu: Paper ile coin biriktir → yuksek tier'a gec → CP topla → drain ol → Paper'a don
Aceleci oyuncu: Hemen pahali bilet → hizli batar, az CP
Sabirli oyuncu: Hep Paper → asla batmaz, ama anlamsiz CP (163 Paper = 1 Platinum)
```

### Meta Dongusu
```
TUR OYNA --> CP KAZAN --> CHARM AL --> DAHA GUCLU BASLA --> DAHA VERIMLI CP --> DAHA COK CHARM
```

### Onemli Kurallar
- Kazima para vermez. Kazima **sembolleri acar**. Eslesme **para kazandirir**.
- Bilet satin almak = o parayi riske etmek. Eslesme yoksa hicbir sey donmez.
- Paper her zaman karli ama CP vermez — sonsuz grind anlamsiz.
- Oyunun ozi: Coin yonetimi ile CP toplama verimliligi.

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
| Bilet | Fiyat | Alan | Sembol | base_reward | ROI | CP/bilet | Acilma |
|-------|-------|------|--------|-------------|-----|----------|--------|
| Kagit | 5 | 6 | 5 | 5 | x1.20 | 0.07 | Baslangic |
| Bronz | 25 | 8 | 7 | 12 | x0.96 | 0.55 | Baslangic |
| Gumus | 100 | 9 | 11 | 38 | x0.67 | 1.86 | Baslangic |
| Altin | 500 | 9 | 12 | 65 | x0.35 | 4.59 | Baslangic |
| Platin | 2,500 | 9 | 15 | 100 | x0.19 | 11.6 | Baslangic |
| Elmas | 7,500 | 9 | 17 | 225 | x0.17 | 27 | Baslangic |
| Zumrut | 20,000 | 9 | 19 | 430 | x0.15 | 56 | Baslangic |
| Yakut | 50,000 | 9 | 21 | 750 | x0.12 | 140 | Baslangic |
| Obsidyen | 125,000 | 9 | 23 | 1,000 | x0.09 | 354 | Baslangic |
| Efsane | 300,000 | 9 | 25 | 1,800 | x0.07 | 722 | Baslangic |

### Bilet Mantigi
- Tum biletler max 9 alan (Paper=6, Bronze=8, Silver+=9) — 3x3 grid
- Daha pahali bilet = daha genis sembol havuzu = eslesme **zorlasir**
- Dusuk ROI = coin kaybedersin AMA CP/bilet **cok yuksek**
- Oyuncu stratejik secim yapar: coin biriktir mi (Paper), CP icin risk al mi (yuksek tier)?

### Risk / Odul Ornekleri
```
Kagit Bilet (5 coin) — "Guvenli liman"
- Eslesme yok (%53): 0 coin (5 coin kaybettin)
- Normal eslesme (%39): 5-10 coin (kucuk kar)
- Buyuk eslesme (%7): 15-25 coin (guzel!)
- Jackpot (%1): 40-75 coin (harika!)
- ROI x1.20 = uzun vadede karli, ama CP neredeyse sifir

Altin Bilet (500 coin) — "Buyuk risk, buyuk CP"
- Eslesme yok (%41): 0 coin (500 coin kaybettin!)
- Normal eslesme (%47): 65-195 coin (yine zarar)
- Buyuk eslesme (%11): 195-520 coin (basabas veya kucuk kar)
- Jackpot (%1): 975-2600 coin (buyuk kar!)
- ROI x0.35 = cogu zaman zarar, ama CP/bilet 65x Paper
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
- **Paper (x1.20):** Hafif karli — coin biriktirme araci, CP neredeyse sifir
- **Bronze (x0.96):** Basabas — eglenceli, dusuk risk
- **Silver-Gold (x0.35-0.67):** Zarar — ama CP/bilet 26-65x daha iyi
- **Platinum+ (x0.06-0.19):** Buyuk zarar — ama CP/bilet 163-10.000x daha iyi
Oyuncu stratejisi: Paper ile buildup → yuksek tier'da CP icin harca → drain ol → Paper'a don

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

### Charm Kazanma
- **Tur sonu:** Her tur sonunda performansa gore 1-5 Charm Puani
- **Baslarilar:** Belirli milestone'lara ulasinca bonus charm
- **Streak:** Ardisik gunlerde oynama = ekstra charm puani
- **Reklam:** Tur sonu reklamla charm puani x2

### Charm Puani Hesaplama (Tur Sonu)
```
Baz puan = 1
+ Tur sonu coin / 100 (max +3)
+ Jackpot vurduysan +1
+ Sinerji bulduysan +1
= Toplam Charm Puani
```

### Charm Listesi

#### Temel Charm'lar (Ucuz, erken oyun)
| Charm | Maliyet | Etki | Max Seviye |
|-------|---------|------|------------|
| Sans Tokasi | 3 CP | Eslesme odulu +%10 | 20 |
| Zengin Baslangic | 5 CP | Baslangic parasi +10 coin | 10 |
| Keskin Goz | 3 CP | 3'lu eslesme sansi +%5 | 15 |
| Hizli Parmak | 2 CP | Kazima animasyonu hizlanir | 10 |

#### Anahtar Charm'lar (Yeni bilet turleri acar)
| Charm | Maliyet | Etki |
|-------|---------|------|
| Gumus Anahtar | 15 CP | Gumus bilet acilir |
| Altin Anahtar | 30 CP | Altin bilet acilir |
| Platin Anahtar | 60 CP | Platin bilet acilir |

#### Guclu Charm'lar (Pahali, gec oyun)
| Charm | Maliyet | Etki | Max Seviye |
|-------|---------|------|------------|
| Joker Miknatisi | 10 CP | Joker sembol sansi +%3 | 5 |
| Carpan Gucu | 15 CP | Carpan sembol sansi +%2 | 5 |
| Enerji Deposu | 20 CP | Max enerji +1 | 3 (max 8) |
| Sinerji Radari | 10 CP | Sinerji sansi +%5 | 10 |
| Altinparmak | 25 CP | Tum oduller +%15 | 10 |
| Kral Dokunusu | 50 CP | 4+ eslesme odulu x2 | 3 |
| YOLO | 40 CP | %1 sansla bilet odulu x50 | 1 |
| Mega Baslangic | 30 CP | Baslangic parasi +50 coin | 5 |

### Charm Sifirlama (Opsiyonel Gec Oyun)
- Tum charm'lari sifirla = charm puanlarini geri al + %10 bonus
- "Rebirth" hissi, yeniden dagitma ozgurlugu
- Sadece cok ileri oyuncular icin

---

## Kart Destesi Sistemi (Mikro Strateji)

Oyuncunun elinde sembol kartlari bulunur. Bileti kazidiktan sonra, eslesmesi eksik kalan sembolleri tamamlamak icin elindeki kartlari kullanabilir. Bu sistem kazima sansini stratejik kararlarla birlestirerek oyuna derinlik katar.

### Temel Mekanik
- Oyuncunun bir **kart destesi** var (acilmis kartlar havuzu)
- Her tur basinda desteden **slot sayisi kadar kart secer** (2-6 arasi)
- Bilet kazindiktan sonra **Kart Oynama Fazi** baslar
- Oyuncu elindeki kartlari kullanarak eslesmesi eksik sembolleri tamamlar
- Kullanilan kartlar o tur icin harcanir, kullanilmayanlar sonraki bilete tasinir
- Tur bitince tum kartlar geri doner (yeni turda tekrar sec)

### Kart Oynama Fazi
```
Bilet kazindi → Tum semboller gorundu
      ↓
KART OYNAMA FAZI (sure siniri yok, rahat dusun)
      ↓
Ornek durum:
  Bilette: Uzum, Kiraz, Uzum, Limon, Kiraz, Yildiz
  Elde: [Uzum] [Yildiz] [Kiraz]
      ↓
Oyuncu "Uzum" kartini oynar → 2 Uzum + 1 kart = 3'lu eslesme!
Veya "Kiraz" kartini oynar → 2 Kiraz + 1 kart = 3'lu eslesme!
Veya ikisini de oynar → 2 eslesme birden!
Veya hicbirini oynamaz → kartlari sakla, sonraki bilette kullan
      ↓
Sonuc hesaplanir (kart bonuslari dahil)
```

### Strateji Ornekleri
```
Senaryo 1 - Basit karar:
  Bilette 2x Uzum var. Elde Uzum karti var.
  → Kagit bilette mi kullanayim (5 coin odul) yoksa Altin bilette mi saklayayim (100+ coin odul)?

Senaryo 2 - Sinerji plani:
  Sinerji tablosunda "Meyve Kokteyli = Kiraz + Limon + Uzum → x3 bonus"
  → Tura Kiraz, Limon, Uzum kartlariyla gir
  → Bilette 2 meyve denk gelirse kartla tamamla + sinerji bonusu kap

Senaryo 3 - Kaynak yonetimi:
  3 bilet kaldi, elde 2 kart kaldi.
  → Hangi bilete kullanmak daha karli? Ucuz bilette garantici ol mu, pahali bilette risk mi al?
```

### Kart Turleri

#### Sembol Kartlari (Ana Mekanik)
Her sembol icin 1 kart. Biletteki o sembolden +1 ekler.

| Kategori | Kartlar | CP Maliyeti |
|----------|---------|-------------|
| Temel | Kiraz, Limon, Uzum | 5 CP |
| Orta | Yildiz, Ay, Kalp, Elmas | 10 CP |
| Nadir | Tac, 7, Anka, Ejderha | 20 CP |
| Yeni Tier | Yakut, Safir, Zumrut, Inci | 15 CP |
| Ust Tier | Ates, Kurukafa, Tekboynuz, Yildirim | 25 CP |

#### Ozel Kartlar (Gec Oyun, Pahali)
| Kart | CP Maliyeti | Etki |
|------|-------------|------|
| Joker Karti | 50 CP | Herhangi bir sembol olarak sayilir |
| Cift Karti | 40 CP | Oynadigin sembolden +1 yerine +2 ekler |
| Carpan Karti | 60 CP | O biletteki toplam odulu x2 yapar (sembol eklemez) |

### Kart Slot Sistemi
Oyuncu baslangicta 2 kart slotuna sahiptir. CP harcayarak slot acabilir.

| Slot | Maliyet | Toplam Harcanan |
|------|---------|-----------------|
| 2 slot | Baslangic | 0 CP |
| 3. slot | 15 CP | 15 CP |
| 4. slot | 30 CP | 45 CP |
| 5. slot | 60 CP | 105 CP |
| 6. slot | 100 CP | 205 CP |

### CP Harcama Stratejisi
Oyuncu CP'sini uc farkli alana yatirir — bu kararlar oyunun stratejik omurgasini olusturur:

```
CP Kazandin! Ne yapacaksin?
  ├── Charm al → Pasif bonuslar (eslesme sansi, odul artisi)
  ├── Kart ac → Yeni sembol kartlari (sinerji hedefleme)
  └── Slot ac → Daha fazla kart tasi (esneklik)

Ornek: 30 CP'n var.
  A) Sans Tokasi charm Lv.4 → her bilette +%40 odul (pasif, guvenli)
  B) 3 nadir sembol karti ac → sinerji hedefleme imkani (aktif, stratejik)
  C) 4. kart slotu ac → her tur 1 ekstra kart (uzun vadeli yatirim)
```

### Tur Baslangici Kart Secimi
```
TUR BASLIYOR — Kartlarini Sec!

Acilmis kartlarin: [Kiraz] [Uzum] [Limon] [Yildiz] [Ay] [Tac] [Joker]
Slot sayisi: 4

Sinerji tablosuna bak:
  Meyve Kokteyli (Kiraz+Limon+Uzum) = x3
  Gece Gokyuzu (Yildiz+Ay) = x4
  Kraliyet (Tac+Elmas) = x5

Secim: [Kiraz] [Limon] [Uzum] [Yildiz]
  → Meyve Kokteyli sinerjisini hedefliyorsun + yedek Yildiz
```

### Kart Sistemi Ilerleme Asamalari

#### Erken Oyun (0-50 CP)
- 2 slot, 2-3 temel kart (Kiraz, Limon, Uzum)
- Basit eslesmeler tamamlanir
- "Kart ne ise yariyor?" ogrenir

#### Orta Oyun (50-150 CP)
- 3-4 slot, 6-8 kart (temel + orta)
- Sinerji tablosuna bakarak kart secimi baslar
- Slot mu alsam, kart mi alsam kararlari

#### Gec Oyun (150-400 CP)
- 5-6 slot, 12+ kart + ozel kartlar
- Sinerji hedefleme tam devrede
- Joker/Cift/Carpan kartlari ile buyuk kombinasyonlar
- "Bu turda meyve mi hedefleyeyim yoksa kozmik mi?" gibi derin kararlar

### Kart Sistemi Kurallari
1. Kart oynamak **isteğe bağli** — her zaman pas gecebilirsin
2. Bir bilette **birden fazla kart** oynanabilir
3. Kartlar **sadece eslesmesi eksik** sembollere oynanabilir (zaten 3+ eslesme varsa gerek yok, ama 4'e cikarmak icin oynanabilir)
4. Ozel kartlar (Joker, Cift, Carpan) tur basinda **sadece 1 tane** secilebilir
5. Kullanilan kart o turda **harcanir**, tur bitince geri gelir
6. Kart acma **kalici** — bir kez CP harca, sonsuza kadar kullan

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
| Ilk Kazima | 1 bilet tamamla | 2 CP |
| Ilk Eslesme | Ilk eslesme | 3 CP |
| Kucuk Adimlar | 100 toplam coin kazan | 5 CP |
| Sinerji Avcisi | Ilk sinerji kesfet | 5 CP |
| Seri Kazici | Bir turda 10 bilet kazi | 3 CP |

### Orta Oyun
| Basarim | Kosul | Odul |
|---------|-------|------|
| Gumus Kazici | Gumus bilet ac | 5 CP |
| Altin Avci | Altin bilet ac | 10 CP |
| Jackpot! | Ilk jackpot vur | 10 CP |
| Koleksiyoncu | Ilk seti tamamla | 10 CP |
| Zengin Tur | Bir turda 500+ coin kazan | 8 CP |

### Gec Oyun
| Basarim | Kosul | Odul |
|---------|-------|------|
| Platin Seri | Platin bilet ac | 15 CP |
| Combo Master | 5 farkli sinerji kesfet | 15 CP |
| Milyoner | Bir turda 1000+ coin kazan | 20 CP |
| Tam Set | Tum koleksiyonlari tamamla | 30 CP |
| Charm Ustasi | 50 charm seviyesi topla | 20 CP |

### Gizli Basarimlar
| Basarim | Kosul | Odul |
|---------|-------|------|
| ??? | 3x Joker ayni bilette | 15 CP |
| ??? | Ardisik 5 bilet eslesme | 10 CP |
| ??? | Tek bilette 2 sinerji | 20 CP |
| ??? | 0 coin ile tura basla (charm'siz) ve 500+ coin bitir | 25 CP |

---

## Monetizasyon

### Reklam (AdMob)
| Yer | Tur | Zorunlu mu? |
|-----|-----|-------------|
| Tur sonu | Rewarded Video (charm x2) | Hayir, opsiyonel |
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
| Baslangic Paketi | $3.99 | 20 enerji + 10 CP + Reklam kaldirma |

### Monetizasyon Felsefesi
- **Asla pay-to-win degil.** Reklam/IAP sadece enerji (daha cok oynama hakki) verir.
- Charm'lar, biletler, eslesme oranlari SATIN ALINAMAZ.
- Reklam izlemek opsiyonel ama odullendirici (charm x2, +1 enerji).
- Sabir gosterirsen bedava oynayabilirsin.

---

## Ilerleme Asamalari

### ASAMA 1: Ilk Turlar (0-50 CP)
*"Ilk adim... WAGMI"*
- Kagit biletlerle ogren
- 5 coin'lik biletlerle dusuk risk
- Ilk eslesme heyecani
- Sans Tokasi, Keskin Goz charm'lari
- Hedef: Sistemi ogren, ilk charm'lari al

### ASAMA 2: Bronz Donem (50-150 CP)
*"Bronza gectik, artik ciddiyiz"*
- Bronz biletler acilir (daha buyuk oduller, daha buyuk risk)
- Gece Gokyuzu sinerjisi kesfedilebilir
- Zengin Baslangic charm'i ile daha uzun turlar
- Hedef: Gumus Anahtar icin biriktir

### ASAMA 3: Stratejik Donem (150-400 CP)
*"Artik hesap yapiyoruz"*
- Gumus + Altin biletler acilir
- Buyuk risk, buyuk odul
- Turda bilet cesidi secimi onemli: ucuz ile mi basla, pahali ile mi riske gir?
- Sinerjiler ve ozel semboller devreye girer
- Hedef: Platin Anahtar

### ASAMA 4: Usta Donem (400+ CP)
*"Kazi kazan imparatoru"*
- Platin biletler = dev oduller veya dev kayiplar
- Tum sinerjiler ve koleksiyonlar pesinde
- Charm optimizasyonu (hangisini max'layim?)
- Gizli basarimlar avinda
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
|  En buyuk kazanc: 75      |
|                           |
|  Charm Puani: +3 CP       |
|                           |
|  [Reklam izle: CP x2]    |
|  [ ANA MENU ]            |
+---------------------------+
```

### Charm Ekrani
```
+---------------------------+
|  LUCK CHARM'LAR   42 CP  |
+---------------------------+
|                           |
| Sans Tokasi     Lv.3  [+]|
| +%30 eslesme odulu        |
|                           |
| Zengin Baslangic Lv.1 [+]|
| +10 coin baslangic        |
|                           |
| Gumus Anahtar   [AL 15CP]|
| Gumus bileti acar         |
|                           |
| Keskin Goz      Lv.5  [+]|
| +%25 eslesme sansi        |
|                           |
+---------------------------+
```

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
- Charm seviyeleri ve charm puani
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
