extends Node

## SoundManager — Sintetik placeholder ses efektleri.
## Autoload: SoundManager.play("ses_adi")
## Gercek ses dosyalari ile degistirilebilir.

const RATE: int = 22050
const POOL_SIZE: int = 8

var sfx_enabled: bool = true
var sfx_volume: float = 0.7

var _sounds: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	_generate_sounds()
	print("[SoundManager] Initialized — %d sounds" % _sounds.size())


## Ses cal. pitch ile ton degistirilebilir (1.0 = normal).
func play(snd: String, pitch: float = 1.0) -> void:
	if not sfx_enabled:
		return
	var stream: AudioStreamWAV = _sounds.get(snd)
	if stream == null:
		return
	# Bos player bul
	for p in _players:
		if not p.playing:
			p.stream = stream
			p.volume_db = linear_to_db(sfx_volume)
			p.pitch_scale = pitch
			p.play()
			return
	# Hepsi dolu — ilkini yeniden kullan
	_players[0].stop()
	_players[0].stream = stream
	_players[0].volume_db = linear_to_db(sfx_volume)
	_players[0].pitch_scale = pitch
	_players[0].play()


# ─── Ses Uretimi ────────────────────────────────────────

## Verilen sure ve dalga fonksiyonundan AudioStreamWAV olustur
func _wav(dur: float, fn: Callable) -> AudioStreamWAV:
	var count := int(RATE * dur)
	var buf := PackedByteArray()
	buf.resize(count * 2)
	for i in count:
		var t := float(i) / RATE
		var val: float = fn.call(t)
		var v := int(clampf(val, -1.0, 1.0) * 32767.0)
		buf[i * 2] = v & 0xFF
		buf[i * 2 + 1] = (v >> 8) & 0xFF
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = RATE
	s.stereo = false
	s.data = buf
	return s


## Nota dizisi (arpeggio) olustur
func _arp(freqs: Array, note_dur: float, sustain: float, vol: float) -> AudioStreamWAV:
	var total := note_dur * freqs.size() + sustain
	var count := int(RATE * total)
	var buf := PackedByteArray()
	buf.resize(count * 2)
	var last: int = freqs.size() - 1
	for i in count:
		var t := float(i) / RATE
		var ni: int
		var nt: float
		if t < note_dur * freqs.size():
			ni = mini(int(t / note_dur), last)
			nt = fmod(t, note_dur)
		else:
			ni = last
			nt = t - note_dur * freqs.size()
		var freq: float = freqs[ni]
		var env: float = exp(-nt * 12.0) if (ni < last or sustain <= 0) else exp(-nt * 5.0)
		var val := (sin(TAU * freq * t) * 0.5 + sin(TAU * freq * 2.0 * t) * 0.15) * env * vol
		var v := int(clampf(val, -1.0, 1.0) * 32767.0)
		buf[i * 2] = v & 0xFF
		buf[i * 2 + 1] = (v >> 8) & 0xFF
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = RATE
	s.stereo = false
	s.data = buf
	return s


func _generate_sounds() -> void:
	# ── UI Sesler ──
	# Hafif tik sesi (buton tiklamasi)
	_sounds["ui_tap"] = _wav(0.06, func(t: float) -> float:
		return sin(TAU * 1200.0 * t) * exp(-t * 50.0) * 0.5)

	# Geri donme sesi (alcalan ton)
	_sounds["ui_back"] = _wav(0.09, func(t: float) -> float:
		var freq := lerpf(600.0, 380.0, t / 0.09)
		return sin(TAU * freq * t) * exp(-t * 25.0) * 0.45)

	# Popup acilis (yukselen ding)
	_sounds["popup_open"] = _wav(0.14, func(t: float) -> float:
		var freq := lerpf(480.0, 880.0, t / 0.14)
		return sin(TAU * freq * t) * minf(t / 0.01, 1.0) * exp(-t * 12.0) * 0.4)

	# Popup kapanis (alçalan ton)
	_sounds["popup_close"] = _wav(0.11, func(t: float) -> float:
		var freq := lerpf(700.0, 380.0, t / 0.11)
		return sin(TAU * freq * t) * exp(-t * 20.0) * 0.4)

	# ── Kazima ──
	# Yumusak kazima tiki (kisa sine + hafif noise)
	_sounds["scratch"] = _wav(0.04, func(t: float) -> float:
		var env := exp(-t * 90.0)
		return (sin(TAU * 700.0 * t) * 0.25 + randf_range(-0.05, 0.05)) * env * 0.2)

	# ── Eslesme Sesleri ──
	# Sembol patlama vurusu (dusuk baslangic — pitch ile buildup hissi verir)
	_sounds["match_pop"] = _wav(0.15, func(t: float) -> float:
		return (sin(TAU * 300.0 * t) * 0.7 + sin(TAU * 600.0 * t) * 0.2) * exp(-t * 25.0) * 0.5)

	# Joker/Bomba ozel pop (parlak, metalik, belirgin farkli)
	_sounds["match_special"] = _wav(0.2, func(t: float) -> float:
		var freq := lerpf(500.0, 1000.0, t / 0.2)
		return (sin(TAU * freq * t) * 0.5 + sin(TAU * freq * 1.5 * t) * 0.3) * minf(t / 0.003, 1.0) * exp(-t * 12.0) * 0.45)

	# Eslesme yok (uzgun alcalan ton)
	_sounds["no_match"] = _wav(0.2, func(t: float) -> float:
		var freq := lerpf(280.0, 160.0, t / 0.2)
		return sin(TAU * freq * t) * exp(-t * 10.0) * 0.35)

	# ── Coin Sesleri ──
	# Para kazanma (iki yukselen ping)
	_sounds["coin_gain"] = _wav(0.2, func(t: float) -> float:
		var freq := 1000.0 if t < 0.1 else 1300.0
		return sin(TAU * freq * t) * exp(-fmod(t, 0.1) * 30.0) * 0.4)

	# Para harcama (kisa alcalan ton)
	_sounds["coin_spend"] = _wav(0.1, func(t: float) -> float:
		var freq := lerpf(700.0, 480.0, t / 0.1)
		return sin(TAU * freq * t) * exp(-t * 25.0) * 0.35)

	# ── Buyuk Kazanc ──
	# C5-E5-G5 yukselen arpeggio
	_sounds["big_win"] = _arp([523.0, 659.0, 784.0], 0.12, 0.0, 0.45)

	# C5-E5-G5-C6 fanfar (sustain ile)
	_sounds["jackpot"] = _arp([523.0, 659.0, 784.0, 1047.0], 0.12, 0.2, 0.45)

	# ── Basarim ──
	# Cift parlak ping
	_sounds["achievement"] = _wav(0.22, func(t: float) -> float:
		return sin(TAU * 1100.0 * t) * exp(-fmod(t, 0.11) * 30.0) * 0.4)

	# ── Olaylar ──
	# Yukselen alarm tonu
	_sounds["event_trigger"] = _wav(0.22, func(t: float) -> float:
		var freq := lerpf(600.0, 1100.0, t / 0.22)
		return sin(TAU * freq * t) * minf(t / 0.01, 1.0) * maxf(1.0 - t / 0.22, 0.0) * 0.45)

	# ── Uyarilar ──
	# Dusuk ton square buzz
	_sounds["energy_warn"] = _wav(0.14, func(t: float) -> float:
		var sq := 1.0 if fmod(t * 200.0, 1.0) < 0.5 else -1.0
		return sq * minf(t / 0.01, 1.0) * maxf(1.0 - t / 0.14, 0.0) * 0.25)

	# ── Bilet ──
	# Hizli yukselen sweep
	_sounds["ticket_complete"] = _wav(0.15, func(t: float) -> float:
		var freq := lerpf(500.0, 1400.0, t / 0.15)
		return sin(TAU * freq * t) * minf(t / 0.005, 1.0) * maxf(1.0 - t / 0.15, 0.0) * 0.4)

	# ── Gecis ──
	# Yumusak noise swoosh
	_sounds["scene_swoosh"] = _wav(0.18, func(t: float) -> float:
		return randf_range(-1.0, 1.0) * sin(PI * t / 0.18) * 0.25)

	# ── Charm ──
	# Parlak yukselen harmonik
	_sounds["charm_buy"] = _wav(0.2, func(t: float) -> float:
		var freq := lerpf(700.0, 1100.0, t / 0.2)
		return (sin(TAU * freq * t) * 0.5 + sin(TAU * freq * 1.5 * t) * 0.2) * minf(t / 0.01, 1.0) * exp(-t * 8.0) * 0.4)

	# ── Tur Sonu ──
	# G5-E5-C5 inen arpeggio
	_sounds["round_end"] = _arp([784.0, 659.0, 523.0], 0.12, 0.0, 0.4)
