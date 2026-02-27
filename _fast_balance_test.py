#!/usr/bin/env python3
"""
Fast Balance Test for Scratch & Rise.
Uses sim_tickets command — no UI, thousands of tickets in seconds.
"""

import json
import time
import os
import sys
import subprocess

PROJECT_DIR = "D:/godotproject/scratch-mobil"
CMD_FILE = os.path.join(PROJECT_DIR, "_test_command.json")
STATE_FILE = os.path.join(PROJECT_DIR, "_test_state.json")
GODOT_EXE = "D:/godot/Godot_v4.6-stable_win64_console.exe"

TIERS = ["paper", "bronze", "silver", "gold", "platinum",
         "diamond_tier", "emerald_tier", "ruby_tier", "obsidian", "legendary"]

TIER_DISPLAY = {
    "paper": "Paper", "bronze": "Bronze", "silver": "Silver",
    "gold": "Gold", "platinum": "Platinum", "diamond_tier": "Diamond",
    "emerald_tier": "Emerald", "ruby_tier": "Ruby",
    "obsidian": "Obsidian", "legendary": "Legendary",
}

_cmd_id = 0

def next_id():
    global _cmd_id
    _cmd_id += 1
    return f"sim_{_cmd_id}"


def send_command(cmd_dict, wait=3.0):
    """Send command to Godot test harness."""
    # Remove stale state
    if os.path.exists(STATE_FILE):
        os.remove(STATE_FILE)
    with open(CMD_FILE, 'w', encoding='utf-8') as f:
        json.dump(cmd_dict, f)
    # Wait for response
    deadline = time.time() + wait + 15  # generous timeout for sim
    while time.time() < deadline:
        time.sleep(0.5)
        if os.path.exists(STATE_FILE):
            try:
                with open(STATE_FILE, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                if data.get("id") == cmd_dict.get("id"):
                    return data
            except (json.JSONDecodeError, IOError):
                pass
    print(f"  [TIMEOUT] No response for command {cmd_dict.get('id')}")
    return None


def format_number(n):
    """Format large numbers: 1K, 1M, etc."""
    if n >= 1_000_000_000:
        return f"{n/1_000_000_000:.1f}B"
    if n >= 1_000_000:
        return f"{n/1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n/1_000:.1f}K"
    return str(n)


def run_all_tiers(count=500, starting_coins=100_000_000):
    """Simulate all tiers with enough coins (pure stats, no coin limit)."""
    cid = next_id()
    print(f"\n--- Simulating {count} tickets per tier (unlimited coins) ---")
    state = send_command({
        "command": "sim_tickets",
        "id": cid,
        "count": count,
        "ticket_type": "all",
        "starting_coins": starting_coins,
    })
    if not state:
        print("ERROR: No response from Godot")
        return None
    result = state.get("result", {})
    if "error" in result:
        print(f"ERROR: {result['error']}")
        return None
    return result.get("sim_results", {})


def run_full_round(starting_coins=20):
    """Simulate a full round: start with 20 coins, auto tier-up like a real player."""
    cid = next_id()
    print(f"\n--- Full Round Simulation (starting coins: {starting_coins}) ---")
    # Use paper with a high count — it will stop when coins run out
    state = send_command({
        "command": "sim_tickets",
        "id": cid,
        "count": 10000,
        "ticket_type": "paper",
        "starting_coins": starting_coins,
    })
    if not state:
        print("ERROR: No response")
        return None
    result = state.get("result", {})
    return result.get("sim_results", {})


def run_smart_round(starting_coins=20):
    """
    Simulate a realistic round: start Paper, tier up when affordable.
    Each tier simulated separately with coin carry-over.
    """
    print(f"\n--- Smart Round Simulation (starting: {starting_coins} coins) ---")
    coins = starting_coins
    round_results = {}
    total_tickets = 0
    total_cp = 0.0

    # Tier prices for reference
    tier_prices = {}

    for tier in TIERS:
        if coins <= 0:
            break
        # Get price from first sim (1 ticket)
        cid = next_id()
        state = send_command({
            "command": "sim_tickets",
            "id": cid,
            "count": 10000,  # will stop when coins run out
            "ticket_type": tier,
            "starting_coins": coins,
        })
        if not state:
            break
        result = state.get("result", {}).get("sim_results", {}).get(tier, {})
        if not result or result.get("tickets_played", 0) == 0:
            continue

        round_results[tier] = result
        coins = result["final_coins"]
        total_tickets += result["tickets_played"]
        total_cp += result["total_cp"]
        tier_prices[tier] = result.get("price", 0)

        display = TIER_DISPLAY.get(tier, tier)
        print(f"  {display:10s} | {result['tickets_played']:4d} bilet | "
              f"Coins: {format_number(result['final_coins']):>8s}")

        # Check if we can afford next tier
        next_idx = TIERS.index(tier) + 1
        if next_idx < len(TIERS):
            # We'll try next tier — if can't afford, loop will get 0 tickets
            pass

    print(f"\n  TOPLAM: {total_tickets} bilet | CP: {total_cp:.1f} | "
          f"Son coins: {coins}")
    return round_results, total_tickets, total_cp


def print_tier_report(sim_results):
    """Print formatted analysis table."""
    print("\n" + "=" * 95)
    print("  SCRATCH & RISE — FAST BALANCE TEST")
    print("=" * 95)
    print(f"  {'Tier':10s} | {'Bilet':>6s} | {'Fiyat':>7s} | {'Base':>5s} | "
          f"{'Eslesme':>7s} | {'ROI':>6s} | {'CP/bilet':>8s} | "
          f"{'Normal':>6s} | {'Big':>5s} | {'Jack':>5s}")
    print("-" * 95)

    total_tickets = 0
    total_cp = 0.0

    for tier in TIERS:
        if tier not in sim_results:
            continue
        r = sim_results[tier]
        display = TIER_DISPLAY.get(tier, tier)
        played = r["tickets_played"]
        total_tickets += played
        total_cp += r["total_cp"]

        tc = r["tier_counts"]
        normal_pct = tc["normal"] / played * 100 if played else 0
        big_pct = tc["big"] / played * 100 if played else 0
        jack_pct = tc["jackpot"] / played * 100 if played else 0

        roi_str = f"x{r['avg_roi']:.2f}"
        if r['avg_roi'] >= 1.0:
            roi_str = f"\033[92m{roi_str}\033[0m"  # green
        elif r['avg_roi'] < 0.5:
            roi_str = f"\033[91m{roi_str}\033[0m"  # red

        print(f"  {display:10s} | {played:6d} | {format_number(r.get('price', 0)):>7s} | "
              f"{format_number(r.get('base_reward', 0)):>5s} | "
              f"{r['match_rate']*100:6.1f}% | {roi_str:>15s} | "
              f"{r['cp_per_ticket']:8.3f} | "
              f"{normal_pct:5.1f}% | {big_pct:4.1f}% | {jack_pct:4.1f}%")

    print("-" * 95)
    print(f"  Toplam: {total_tickets} bilet | Toplam CP: {total_cp:.1f}")
    print("=" * 95)


def print_multiplier_stats(sim_results):
    """Print multiplier distribution for each tier."""
    print("\n--- Carpan Dagilimlari ---")
    for tier in TIERS:
        if tier not in sim_results:
            continue
        r = sim_results[tier]
        mults = [m for m in r.get("multipliers", []) if m > 0]
        if not mults:
            continue
        display = TIER_DISPLAY.get(tier, tier)
        avg_m = sum(mults) / len(mults)
        max_m = max(mults)
        print(f"  {display:10s} | Ort: x{avg_m:.1f} | Max: x{max_m} | "
              f"Eslesme sayisi: {len(mults)}")


def wait_for_godot():
    """Check if Godot is running by sending a state command."""
    print("Godot'a baglaniliyor...")
    for attempt in range(3):
        cid = next_id()
        state = send_command({"command": "state", "id": cid}, wait=5)
        if state and state.get("id") == cid:
            print("Godot baglantisi OK!")
            return True
        print(f"  Deneme {attempt+1}/3 basarisiz, tekrar deneniyor...")
    return False


def start_godot():
    """Start Godot in background."""
    print("Godot baslatiliyor...")
    proc = subprocess.Popen(
        [GODOT_EXE, "--path", PROJECT_DIR],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    print(f"  PID: {proc.pid} — Yukleme bekleniyor (7sn)...")
    time.sleep(7)
    return proc


def main():
    # Parse args
    count = 500
    skip_launch = False
    run_round = False

    for arg in sys.argv[1:]:
        if arg == "--no-launch":
            skip_launch = True
        elif arg == "--round":
            run_round = True
        elif arg.isdigit():
            count = int(arg)

    # Clean stale files
    for f in [CMD_FILE, STATE_FILE]:
        if os.path.exists(f):
            os.remove(f)

    # Start or connect to Godot
    proc = None
    if not skip_launch:
        proc = start_godot()

    if not wait_for_godot():
        print("ERROR: Godot'a baglanilamadi. Oyunu baslatin ve tekrar deneyin.")
        print("  Veya: python _fast_balance_test.py --no-launch")
        if proc:
            proc.terminate()
        sys.exit(1)

    # Run tier analysis
    sim_results = run_all_tiers(count=count)
    if sim_results:
        print_tier_report(sim_results)
        print_multiplier_stats(sim_results)

    # Run smart round simulation
    if run_round:
        run_smart_round(starting_coins=20)

    # Always run a quick round sim
    print("\n--- Hizli Tur Simulasyonu (20 coin, sadece Paper) ---")
    paper_round = run_full_round(starting_coins=20)
    if paper_round and "paper" in paper_round:
        pr = paper_round["paper"]
        print(f"  Paper: {pr['tickets_played']} bilet | "
              f"Max coins: {max(pr['coin_history'])if pr['coin_history'] else 0} | "
              f"Son: {pr['final_coins']} | CP: {pr['total_cp']:.1f}")

    # Cleanup
    if proc:
        print("\nGodot kapatiliyor...")
        proc.terminate()
        proc.wait(timeout=5)

    print("\nTest tamamlandi!")


if __name__ == "__main__":
    main()
