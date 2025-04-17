# -*- coding: utf-8 -*-
import requests
import json
import os
import time
import re
from collections import defaultdict
import sys # Import sys for checking Python version if needed

# --- Configuration ---
HC_API_BASE_URI = 'https://health-products.canada.ca/api/drug'
# *** CORRECTED LOCAL FILE PATHS ***
OUTPUT_FILENAME = 'compiled_drug_data.json' # Local filename to WRITE output
RESTRICTED_JSON = 'restricted_drugs.json'  # Local filename to READ restrictions
# **********************************
REQUEST_TIMEOUT = 45  # Increased timeout slightly
ENDPOINTS = {
    "schedule":         "/schedule/?lang=en&type=json",
    "drugproduct":      "/drugproduct/?lang=en&type=json",
    "activeingredient": "/activeingredient/?lang=en&type=json",
    "form":             "/form/?lang=en&type=json",
}

# Only these lowercase schedule prefixes count as CDSA I–V (Narcotic, Controlled I/II/III, Benzodiazepine/Targeted)
CDSA_PREFIXES = [
    "schedule i", "schedule ii", "schedule iii",
    "schedule iv", "schedule v",
    "narcotic", # From Narcotic Control Regulations
    "controlled part i",
    "controlled part ii",
    "controlled part iii",
    "benzodiazepine"
]

# --- Helper Functions ---

def fetch_data(name, path):
    """Fetches data from the Health Canada API endpoint."""
    url = HC_API_BASE_URI + path
    print(f"\n🔗 Fetching {name} from {url}")
    headers = {'User-Agent': 'RefillRequestFormApp/1.0 (GitHub Action)'} # Identify client
    try:
        response = requests.get(url, timeout=REQUEST_TIMEOUT, headers=headers)
        response.raise_for_status()
        data = response.json()

        if isinstance(data, list):
             print(f"  ✓ Retrieved {len(data)} records for {name}")
             return data
        elif data is None:
             print(f"  ✓ Retrieved 0 records for {name} (API returned null)")
             return []
        else: # Includes empty dict {} which API sometimes returns
             print(f"  ⚠️ API returned non-list data for {name}: {type(data)}. Treating as empty.")
             return []

    except requests.exceptions.Timeout:
        print(f"  ❌ Timeout Error fetching {name} after {REQUEST_TIMEOUT} seconds.")
        return [] # Return empty list on timeout
    except requests.exceptions.RequestException as e:
        print(f"  ❌ Network/Request Error fetching {name}: {e}")
        return []
    except json.JSONDecodeError as e:
        print(f"  ❌ JSON Decode Error fetching {name}: {e}")
        print(f"     Response status: {response.status_code}")
        print(f"     Response text: {response.text[:200]}...")
        return []
    except Exception as e:
        print(f"  ❌ Unexpected Error fetching {name}: {type(e).__name__} - {e}")
        return []

def normalize_text(txt):
    """Converts text to lowercase and strips whitespace."""
    return str(txt).strip().lower() if txt is not None else ""

# --- Main Data Building Function ---

def build_compiled_data():
    """Fetches, processes, and combines Health Canada drug data."""
    # Use absolute path for the script directory to resolve local files reliably
    script_dir = os.path.dirname(os.path.abspath(__file__))
    print(f"Script running in directory: {script_dir}")
    print(f"Python version: {sys.version}")

    # 1) Fetch all endpoints
    print("\n--- Starting Data Fetch ---")
    all_data = {}
    fetch_success = True
    start_fetch = time.time()
    for name, path in ENDPOINTS.items():
         data = fetch_data(name, path)
         if not isinstance(data, list):
             print(f"  ❌ ERROR: Fetch for '{name}' did not return a list. Data fetching cannot proceed reliably.")
             fetch_success = False
             # Allow continuing to see if other fetches work, but flag it
             # break # Or uncomment to stop immediately
         all_data[name] = data if isinstance(data, list) else [] # Ensure it's a list
         time.sleep(0.2)
    print(f"--- Data Fetch finished in {time.time()-start_fetch:.2f}s ---")

    # Simple check if ALL fetches returned empty lists
    if all(len(v) == 0 for v in all_data.values()):
         print("\n❌ CRITICAL ERROR: All API fetch attempts returned empty data. Cannot build file.")
         sys.exit(1)
    elif not fetch_success:
         print("\n⚠️ WARNING: One or more API fetches failed or returned unexpected data. Resulting file may be incomplete.")
         # Proceed cautiously

    # 2) Load external restricted names & aliases
    print("\n--- Loading Restricted Drug List ---")
    restricted_aliases = set()
    # Construct absolute path to restricted json
    restricted_json_path = os.path.join(script_dir, RESTRICTED_JSON)
    try:
        print(f"🔍 Loading restricted list from local file: {restricted_json_path}")
        with open(restricted_json_path, 'r', encoding='utf-8') as f:
            schedules_or_drugs = json.load(f)

        entries_to_process = []
        if isinstance(schedules_or_drugs, dict):
             for schedule_name, drugs in schedules_or_drugs.items():
                 if isinstance(drugs, list): entries_to_process.extend(drugs)
                 else: print(f"  ⚠️ Expected list for schedule '{schedule_name}', got {type(drugs)}. Skipping.")
        elif isinstance(schedules_or_drugs, list):
             entries_to_process = schedules_or_drugs
        else:
             print(f"  ⚠️ Expected dict or list in {RESTRICTED_JSON}, got {type(schedules_or_drugs)}. Cannot load restrictions.")

        processed_count = 0
        for entry in entries_to_process:
             if isinstance(entry, dict):
                 nm = normalize_text(entry.get('name'))
                 if nm: restricted_aliases.add(nm); processed_count += 1
                 for alias in entry.get('aliases', []):
                     a = normalize_text(alias)
                     if a: restricted_aliases.add(a); processed_count += 1
             elif isinstance(entry, str):
                  nm = normalize_text(entry)
                  if nm: restricted_aliases.add(nm); processed_count += 1
             else: print(f"  ⚠️ Skipping invalid entry type in restriction list: {type(entry)}")

        if not restricted_aliases:
             print(f"  ⚠️ WARNING: No restricted names/aliases were loaded. Name-based restriction checks will be skipped.")
        else:
             print(f"  ✓ Loaded {len(restricted_aliases)} unique restricted names/aliases from {processed_count} entries.")

    except FileNotFoundError:
         print(f"  ❌ ERROR: Restricted drug file not found: {restricted_json_path}")
         print("     Restricted drug checks based on name will be skipped.")
    except json.JSONDecodeError as e:
         print(f"  ❌ ERROR: Could not parse JSON from {restricted_json_path}: {e}")
         print("     Restricted drug checks based on name will be skipped.")
    except Exception as e:
        print(f"  ❌ Unexpected Error loading {restricted_json_path}: {type(e).__name__} - {e}")

    # 3) Index API schedule -> drug_code -> set of schedule names
    print("\n--- Indexing Schedules ---")
    schedules_by_code = defaultdict(set)
    sched_count = 0
    for item in all_data.get('schedule', []):
        code = item.get('drug_code')
        name = normalize_text(item.get('schedule_name'))
        if code and name: schedules_by_code[code].add(name); sched_count += 1
    print(f"🔗 Indexed {sched_count} schedule entries for {len(schedules_by_code)} unique drug codes")

    # 4) Index products by drug_code
    print("\n--- Indexing Drug Products ---")
    products = {}
    for p in all_data.get('drugproduct', []):
        code = p.get('drug_code')
        if code and code not in products: products[code] = p
    print(f"📦 Indexed {len(products)} unique drug products")

    # 5) Index ingredients by drug_code & normalize strength
    print("\n--- Indexing Active Ingredients ---")
    ingredients_by_code = defaultdict(list)
    ing_count = 0
    for ing in all_data.get('activeingredient', []):
        code = ing.get('drug_code')
        if not code: continue
        raw_name = ing.get('ingredient_name','')
        cleaned_name = normalize_text(re.sub(r'\s*\([^)]*\)\s*', '', raw_name)).strip()
        if not cleaned_name: continue
        ing['cleaned_name'] = cleaned_name

        raw_strength = str(ing.get('strength','')).strip()
        normalized_strength = raw_strength
        try:
            if raw_strength:
                f_strength = float(raw_strength)
                if f_strength.is_integer(): normalized_strength = str(int(f_strength))
                else: normalized_strength = str(f_strength)
        except ValueError: pass # Keep original if not a simple number
        ing['normalized_strength'] = normalized_strength
        ing['normalized_strength_unit'] = normalize_text(ing.get('strength_unit',''))
        ingredients_by_code[code].append(ing)
        ing_count+=1
    print(f"🧪 Indexed {ing_count} ingredient entries for {len(ingredients_by_code)} codes (with strength normalization)")

    # 6) Index forms by drug_code
    print("\n--- Indexing Dosage Forms ---")
    forms_by_code = defaultdict(list)
    form_count = 0
    found_forms = set()
    for frm in all_data.get('form', []):
        code = frm.get('drug_code')
        if not code: continue
        form_name = str(frm.get('pharmaceutical_form_name','')).strip()
        if not form_name: continue
        normalized = normalize_text(form_name)
        frm['normalized_form'] = normalized
        forms_by_code[code].append(frm)
        found_forms.add(form_name)
        form_count += 1
    print(f"💊 Indexed {form_count} form entries for {len(forms_by_code)} codes")
    print(f"  (Found {len(found_forms)} unique form names across all drugs)")

    # 7) Combine data, flag restrictions, create unique entries
    print("\n--- Combining Data & Generating Output ---")
    compiled = []
    processed_keys = set()
    skipped_missing_data = 0
    skipped_duplicates = 0

    for code, prod in products.items():
        ings = ingredients_by_code.get(code, [])
        forms = forms_by_code.get(code, [])
        if not ings or not forms: skipped_missing_data += 1; continue

        form0 = forms[0]
        form_name = form0.get('pharmaceutical_form_name','').strip()
        normalized_form = form0.get('normalized_form','')
        if not form_name or not normalized_form: skipped_missing_data += 1; continue

        # Determine Restriction Status
        api_schedule_names = schedules_by_code.get(code, set())
        is_restricted_schedule = any(any(s.startswith(p) for p in CDSA_PREFIXES) for s in api_schedule_names)
        is_restricted_name = any(i['cleaned_name'] in restricted_aliases for i in ings)
        restricted_flag = is_restricted_schedule or is_restricted_name

        # Build Display and Search Strings
        ings.sort(key=lambda x: x['cleaned_name'])
        display_list = []
        search_terms = set()
        ingredient_names_only = []
        for i in ings:
            nm = i['cleaned_name']
            ingredient_names_only.append(nm)
            strg = i['normalized_strength']
            unt = i['normalized_strength_unit']
            disp = nm + (f" {strg}" if strg else "") + (f"{unt}" if strg and unt else "")
            display_list.append(disp)
            search_terms.add(nm)
            if strg: search_terms.add(strg)

        # Create Unique Key & Deduplicate
        ing_key = "|".join(sorted(display_list))
        entry_key = f"{ing_key}::{normalized_form}"
        if entry_key in processed_keys: skipped_duplicates += 1; continue
        processed_keys.add(entry_key)

        # Prepare final entry
        first_ing = ings[0]
        brand_name = str(prod.get('brand_name', '')).strip()
        entry = {
            "drug_code": code, # Reference
            "brand_name": brand_name,
            "ingredients": display_list,
            "dosage_form": form_name,
            "normalized_dosage_form": normalized_form,
            "is_restricted": restricted_flag,
            "_search_text": f"{brand_name.lower()} {' '.join(search_terms)} {normalized_form}",
            "first_ingredient_name": first_ing['cleaned_name'],
            "first_strength": first_ing['normalized_strength'],
            "first_strength_unit": first_ing['normalized_strength_unit'],
        }
        compiled.append(entry)

    print(f"✓ Processed {len(products)} product codes.")
    print(f"  - Skipped {skipped_missing_data} due to missing ingredient/form data.")
    print(f"  - Skipped {skipped_duplicates} as duplicates (same ingredients/form).")
    print(f"✔️ Built {len(compiled)} final unique entries for JSON output.")

    # 8) Save Compiled Data to JSON
    print("\n--- Saving Compiled Data ---")
    # Construct absolute path for output file
    out_path = os.path.join(script_dir, OUTPUT_FILENAME)
    print(f"💾 Saving to local file: {out_path}")
    try:
        with open(out_path, 'w', encoding='utf-8') as f:
            json.dump(compiled, f, ensure_ascii=False, separators=(',', ':'))
        print("✅ Save complete.")
        if len(compiled) == 0:
             print("⚠️ WARNING: The output file is empty. This might happen if all API calls failed or no valid drug data was processed.")
    except IOError as e:
         print(f"  ❌ ERROR Saving JSON: Could not write to file '{out_path}'. Check permissions. Error: {e}")
         sys.exit(1) # Exit if cannot save output
    except Exception as e:
        print(f"  ❌ Unexpected Error saving JSON: {type(e).__name__} - {e}")
        sys.exit(1) # Exit on other save errors

# --- Main Execution Block ---
if __name__ == "__main__":
    print("=====================================")
    print(" Health Canada Drug Data Compiler ")
    print("=====================================")
    main_start_time = time.time()
    build_compiled_data()
    main_end_time = time.time()
    print("\n=====================================")
    print(f"🏁 Script finished in {main_end_time - main_start_time:.2f} seconds.")
    print("=====================================")
