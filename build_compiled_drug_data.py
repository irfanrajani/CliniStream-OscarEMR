import requests
import json
import os
import time
import re
from collections import defaultdict

# --- Configuration ---
HC_API_BASE_URI       = 'https://health-products.canada.ca/api/drug'
OUTPUT_FILENAME       = 'compiled_drug_data.json'
RESTRICTED_JSON       = 'restricted_drugs.json'
REQUEST_TIMEOUT       = 30  # seconds

ENDPOINTS = {
    "schedule":         "/schedule/?lang=en&type=json",
    "drugproduct":      "/drugproduct/?lang=en&type=json",
    "activeingredient": "/activeingredient/?lang=en&type=json",
    "form":             "/form/?lang=en&type=json",
}

# Only these schedules count as CDSA I–V
CDSA_PREFIXES = [
    "schedule i", "schedule ii", "schedule iii",
    "schedule iv", "schedule v"
]

def fetch_data(name, path):
    url = HC_API_BASE_URI + path
    print(f"\n🔗 Fetching {name} from {url}")
    try:
        r = requests.get(url, timeout=REQUEST_TIMEOUT)
        r.raise_for_status()
        data = r.json() or []
        print(f"  ✓ Retrieved {len(data) if isinstance(data, list) else 1} records for {name}")
        return data
    except Exception as e:
        print(f"  ❌ Error fetching {name}: {e}")
        return []

def normalize_text(txt):
    return txt.strip().lower() if isinstance(txt, str) else ""

def build_compiled_data():
    script_dir = os.path.dirname(__file__) or '.'

    # 1) Fetch all endpoints
    all_data = { name: fetch_data(name, path) for name, path in ENDPOINTS.items() }
    time.sleep(0.5)

    # 2) Load external restricted names & aliases
    restricted_aliases = set()
    try:
        print(f"\n🔍 Loading restricted list from {RESTRICTED_JSON}")
        with open(os.path.join(script_dir, RESTRICTED_JSON), 'r', encoding='utf-8') as f:
            schedules = json.load(f)
        for entries in schedules.values():
            for entry in entries:
                nm = normalize_text(entry.get('name',''))
                if nm: restricted_aliases.add(nm)
                for alias in entry.get('aliases', []):
                    a = normalize_text(alias)
                    if a: restricted_aliases.add(a)
        print(f"  ✓ Loaded {len(restricted_aliases)} restricted names/aliases")
    except Exception as e:
        print(f"  ⚠️ Could not load {RESTRICTED_JSON}: {e}")

    # 3) Index API schedule → drug_code → [schedule_name, ...]
    schedules_by_code = defaultdict(list)
    for item in all_data['schedule']:
        code = item.get('drug_code')
        name = normalize_text(item.get('schedule_name',''))
        if code and name:
            schedules_by_code[code].append(name)
    print(f"\n🔗 Indexed schedules for {len(schedules_by_code)} drug codes")

    # 4) Index products
    products = {}
    for p in all_data['drugproduct']:
        code = p.get('drug_code')
        if code and code not in products:
            products[code] = p
    print(f"📦 Indexed {len(products)} unique drug products")

    # 5) Index ingredients
    ingredients_by_code = defaultdict(list)
    for ing in all_data['activeingredient']:
        code = ing.get('drug_code')
        if not code: continue
        cleaned = re.sub(r'\s*\(.*?\)\s*', '', ing.get('ingredient_name','')).strip()
        ing['cleaned_name'] = cleaned
        ingredients_by_code[code].append(ing)
    print(f"🧪 Indexed ingredients for {len(ingredients_by_code)} codes")

    # 6) Index forms
    forms_by_code = defaultdict(list)
    for frm in all_data['form']:
        code = frm.get('drug_code')
        if not code: continue
        frm['normalized_form'] = normalize_text(frm.get('pharmaceutical_form_name',''))
        forms_by_code[code].append(frm)
    print(f"💊 Indexed forms for {len(forms_by_code)} codes")

    # 7) Combine & flag restrictions
    print("\n⚙️  Combining data…")
    compiled = []
    for code, prod in products.items():
        ings = ingredients_by_code.get(code, [])
        forms = forms_by_code.get(code, [])
        if not ings or not forms:
            continue

        # Schedule‑based restriction: any CDSA I–V schedule match
        sched_names = schedules_by_code.get(code, [])
        is_restricted_schedule = any(
            any(s.startswith(prefix) for prefix in CDSA_PREFIXES)
            for s in sched_names
        )

        # Name‑based restriction: any ingredient name contains a restricted alias
        is_restricted_name = False
        for i in ings:
            lower = normalize_text(i['cleaned_name'])
            if any(alias in lower for alias in restricted_aliases):
                is_restricted_name = True
                break

        restricted_flag = is_restricted_schedule or is_restricted_name

        # Build display & search strings
        ings.sort(key=lambda x: x['cleaned_name'])
        display_list = []
        search_terms  = []
        for i in ings:
            nm   = i['cleaned_name']
            if not nm: continue
            strg = i.get('strength','').strip()
            unt  = i.get('strength_unit','').strip()
            disp = nm + (f" {strg}{unt}" if strg else "")
            display_list.append(disp)
            search_terms.append(nm.lower())

        form0 = forms[0]
        entry = {
            "drug_code":             code,
            "brand_name":            prod.get('brand_name','').strip(),
            "ingredients":           display_list,
            "dosage_form":           form0.get('pharmaceutical_form_name','').strip(),
            "normalized_dosage_form": form0.get('normalized_form',''),
            "is_restricted":         restricted_flag,
            "_search_brand":         prod.get('brand_name','').lower(),
            "_search_ingredients":   " ".join(search_terms),
            "first_ingredient_name": ings[0].get('ingredient_name','').strip(),
            "first_strength":        ings[0].get('strength','').strip(),
            "first_strength_unit":   ings[0].get('strength_unit','').strip(),
        }
        compiled.append(entry)

    print(f"✔️  Built {len(compiled)} compiled entries")

    # 8) Save JSON
    out_path = os.path.join(script_dir, OUTPUT_FILENAME)
    print(f"\n💾 Saving to {out_path}")
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(compiled, f, ensure_ascii=False, separators=(',',':'))
    print("✅ Save complete.")

if __name__ == "__main__":
    start = time.time()
    build_compiled_data()
    print(f"\n🏁 Finished in {time.time()-start:.2f}s")