#!/usr/bin/env python3
"""
Unified Dining Scraper Runner
Runs all university-specific scrapers and combines results
"""

import sys
import os
import json
from datetime import datetime

print(f"[run_all_scrapers] Starting... Python: {sys.executable}", flush=True)
print(f"[run_all_scrapers] CWD: {os.getcwd()}", flush=True)
print(f"[run_all_scrapers] __file__: {__file__}", flush=True)

# Add scrapers directory to path
scrapers_dir = os.path.join(os.path.dirname(__file__), 'scrapers')
sys.path.insert(0, scrapers_dir)
print(f"[run_all_scrapers] Added to path: {scrapers_dir}")
print(f"[run_all_scrapers] Scrapers dir exists: {os.path.exists(scrapers_dir)}")

try:
    print("[run_all_scrapers] Importing columbia.scraper...")
    from columbia.scraper import scrape_all_locations as scrape_columbia
    print("[run_all_scrapers] Importing cornell.scraper...")
    from cornell.scraper import scrape_cornell
    print("[run_all_scrapers] All imports successful!")
except ImportError as e:
    print(f"[run_all_scrapers] IMPORT ERROR: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

def run_all_scrapers():
    """Run all university scrapers and combine results"""
    print("\n" + "=" * 60)
    print("🍽️  ColumbiaCals Unified Dining Scraper")
    print("=" * 60)
    
    all_results = []

    # Load existing data for fallback
    output_file = os.path.join(os.path.dirname(__file__), 'menu_data.json')
    existing_data = []
    if os.path.exists(output_file):
        try:
            with open(output_file, 'r') as f:
                existing_data = json.load(f)
        except Exception as e:
            print(f"[run_all_scrapers] Warning: failed to read existing menu_data.json: {e}")

    def _get_source_tag(item):
        return (item.get('source') or item.get('university') or '').lower()

    def _filter_by_source(data, source):
        return [r for r in data if _get_source_tag(r) == source]

    def _is_scrape_successful(results, source):
        if not results:
            return False
        src_results = _filter_by_source(results, source)
        if not src_results:
            return False
        return any(r.get('status') != 'error' for r in src_results)
    
    # Run Columbia scraper
    try:
        columbia_results = scrape_columbia()
    except Exception as e:
        print(f"\n❌ Columbia scraper failed: {e}")
        columbia_results = []
    
    # Run Cornell scraper
    try:
        cornell_results = scrape_cornell()
    except Exception as e:
        print(f"\n❌ Cornell scraper failed: {e}")
        cornell_results = []

    # Merge with fallback data if needed
    columbia_ok = _is_scrape_successful(columbia_results, 'columbia')
    cornell_ok = _is_scrape_successful(cornell_results, 'cornell')

    if not columbia_ok:
        fallback_columbia = _filter_by_source(existing_data, 'columbia')
        if fallback_columbia:
            print("⚠️ Columbia scrape failed - using existing menu_data.json for Columbia")
            columbia_results = fallback_columbia

    if not cornell_ok:
        fallback_cornell = _filter_by_source(existing_data, 'cornell')
        if fallback_cornell:
            print("⚠️ Cornell scrape failed - using existing menu_data.json for Cornell")
            cornell_results = fallback_cornell

    all_results.extend(columbia_results)
    all_results.extend(cornell_results)
    
    # Check if data has too many errors (scraping failed)
    error_count = sum(1 for r in all_results if r.get('status') == 'error')

    if all_results and error_count > len(all_results) / 2:
        print(f"\n⚠️ Skipping save - too many scraping errors ({error_count}/{len(all_results)} halls)")
        print("   Keeping existing menu_data.json")
    else:
        # Save combined results
        with open(output_file, 'w') as f:
            json.dump(all_results, f, indent=2)
    
    # Print summary
    print("\n" + "=" * 60)
    print("📊 SUMMARY")
    print("=" * 60)
    
    by_university = {}
    total_open = 0
    total_items = 0
    
    for result in all_results:
        uni = (result.get('university') or result.get('source') or 'unknown')
        status = result.get('status', 'unknown')
        
        if uni not in by_university:
            by_university[uni] = {'open': 0, 'closed': 0, 'error': 0, 'items': 0}
        
        if status == 'open':
            by_university[uni]['open'] += 1
            total_open += 1
            for meal in result.get('meals', []):
                for station in meal.get('stations', []):
                    count = len(station.get('items', []))
                    by_university[uni]['items'] += count
                    total_items += count
        elif status == 'closed':
            by_university[uni]['closed'] += 1
        else:
            by_university[uni]['error'] += 1
    
    for uni, stats in by_university.items():
        print(f"\n{uni.upper()}:")
        print(f"  🟢 Open: {stats['open']}")
        print(f"  🔴 Closed: {stats['closed']}")
        print(f"  ❌ Errors: {stats['error']}")
        if stats['items'] > 0:
            print(f"  📝 Items: {stats['items']}")
    
    print(f"\n📌 TOTAL")
    print(f"  Open dining halls: {total_open}")
    print(f"  Total menu items: {total_items}")
    print(f"  Saved to: {output_file}")
    print("=" * 60 + "\n")
    
    return all_results

if __name__ == "__main__":
    run_all_scrapers()
