extends Node

## Reklam yöneticisi (placeholder).
## Gerçek AdMob entegrasyonu M10'da yapılacak.

var is_ad_free: bool = false


func _ready() -> void:
	print("[AdManager] Initialized — Placeholder mode")


## Ödüllü video göster (tur sonu bonus, ekstra enerji vb.)
func show_rewarded_video(callback: Callable) -> void:
	if is_ad_free:
		print("[AdManager] Ad-free — skipping rewarded video")
		callback.call()
		return
	print("[AdManager] [PLACEHOLDER] Rewarded video shown")
	# Gerçek implementasyonda: reklam izlendi callback
	callback.call()


## Interstitial göster (tur arası)
func show_interstitial() -> void:
	if is_ad_free:
		return
	print("[AdManager] [PLACEHOLDER] Interstitial shown")


## Banner göster
func show_banner() -> void:
	if is_ad_free:
		return
	print("[AdManager] [PLACEHOLDER] Banner shown")


## Banner gizle
func hide_banner() -> void:
	print("[AdManager] [PLACEHOLDER] Banner hidden")
