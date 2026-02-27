extends Node

## SoundManager — Sintetik placeholder ses efektleri.
## Autoload: SoundManager.play("ses_adi")
## Gercek ses dosyalari ile degistirilebilir.

const RATE: int = 44100
const POOL_SIZE: int = 8

var sfx_enabled: bool = true
var sfx_volume: float = 0.5

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
	# Yumusak tik (dusuk frekans, hizli decay)
	_sounds["ui_tap"] = _wav(0.05, func(t: float) -> float:
		return sin(TAU * 440.0 * t) * exp(-t * 80.0) * 0.3)

	# Geri donme (yumusak alcalan)
	_sounds["ui_back"] = _wav(0.08, func(t: float) -> float:
		var freq := lerpf(350.0, 220.0, t / 0.08)
		return sin(TAU * freq * t) * exp(-t * 35.0) * 0.25)

	# Popup acilis (hafif yukselen)
	_sounds["popup_open"] = _wav(0.12, func(t: float) -> float:
		var freq := lerpf(330.0, 520.0, t / 0.12)
		return sin(TAU * freq * t) * minf(t / 0.015, 1.0) * exp(-t * 18.0) * 0.25)

	# Popup kapanis (hafif alcalan)
	_sounds["popup_close"] = _wav(0.09, func(t: float) -> float:
		var freq := lerpf(440.0, 280.0, t / 0.09)
		return sin(TAU * freq * t) * exp(-t * 28.0) * 0.22)

	# ── Kazima ──
	# Cok kisa yumusak tik
	_sounds["scratch"] = _wav(0.03, func(t: float) -> float:
		return sin(TAU * 350.0 * t) * exp(-t * 120.0) * 0.15)

	# ── Eslesme Sesleri ──
	# Yumusak pop (dusuk frekans, sicak ton)
	_sounds["match_pop"] = _wav(0.12, func(t: float) -> float:
		return sin(TAU * 220.0 * t) * exp(-t * 30.0) * 0.3)

	# Ozel sembol (hafif parlak ama sert degil)
	_sounds["match_special"] = _wav(0.15, func(t: float) -> float:
		var freq := lerpf(330.0, 550.0, t / 0.15)
		return sin(TAU * freq * t) * minf(t / 0.01, 1.0) * exp(-t * 18.0) * 0.25)

	# Eslesme yok (kisa, hafif uzgun ton)
	_sounds["no_match"] = _wav(0.15, func(t: float) -> float:
		var freq := lerpf(220.0, 150.0, t / 0.15)
		return sin(TAU * freq * t) * exp(-t * 15.0) * 0.2)

	# ── Coin Sesleri ──
	# Para kazanma (iki yumusak ping)
	_sounds["coin_gain"] = _wav(0.15, func(t: float) -> float:
		var freq := 550.0 if t < 0.075 else 660.0
		return sin(TAU * freq * t) * exp(-fmod(t, 0.075) * 35.0) * 0.25)

	# Para harcama (kisa hafif ton)
	_sounds["coin_spend"] = _wav(0.08, func(t: float) -> float:
		var freq := lerpf(400.0, 300.0, t / 0.08)
		return sin(TAU * freq * t) * exp(-t * 35.0) * 0.2)

	# ── Buyuk Kazanc ──
	# C4-E4-G4 yumusak arpeggio (bir oktav dusuk)
	_sounds["big_win"] = _arp([262.0, 330.0, 392.0], 0.12, 0.0, 0.3)

	# C4-E4-G4-C5 fanfar (yumusak)
	_sounds["jackpot"] = _arp([262.0, 330.0, 392.0, 523.0], 0.12, 0.15, 0.3)

	# ── Basarim ──
	# Cift yumusak ping
	_sounds["achievement"] = _wav(0.2, func(t: float) -> float:
		return sin(TAU * 550.0 * t) * exp(-fmod(t, 0.1) * 35.0) * 0.25)

	# ── Olaylar ──
	# Hafif yukselen ton
	_sounds["event_trigger"] = _wav(0.18, func(t: float) -> float:
		var freq := lerpf(350.0, 550.0, t / 0.18)
		return sin(TAU * freq * t) * minf(t / 0.015, 1.0) * maxf(1.0 - t / 0.18, 0.0) * 0.28)

	# ── Uyarilar ──
	# Dusuk yumusak buzz
	_sounds["energy_warn"] = _wav(0.12, func(t: float) -> float:
		return sin(TAU * 150.0 * t) * minf(t / 0.015, 1.0) * maxf(1.0 - t / 0.12, 0.0) * 0.2)

	# ── Bilet ──
	# Hafif yukselen sweep
	_sounds["ticket_complete"] = _wav(0.12, func(t: float) -> float:
		var freq := lerpf(330.0, 660.0, t / 0.12)
		return sin(TAU * freq * t) * minf(t / 0.01, 1.0) * maxf(1.0 - t / 0.12, 0.0) * 0.25)

	# ── Gecis ──
	# Cok hafif swoosh
	_sounds["scene_swoosh"] = _wav(0.12, func(t: float) -> float:
		return randf_range(-1.0, 1.0) * sin(PI * t / 0.12) * 0.1)

	# ── Charm ──
	# Yumusak yukselen ton
	_sounds["charm_buy"] = _wav(0.15, func(t: float) -> float:
		var freq := lerpf(400.0, 600.0, t / 0.15)
		return sin(TAU * freq * t) * minf(t / 0.015, 1.0) * exp(-t * 12.0) * 0.25)

	# ── Tur Sonu ──
	# G4-E4-C4 yumusak inen arpeggio
	_sounds["round_end"] = _arp([392.0, 330.0, 262.0], 0.12, 0.0, 0.25)
