import requests
import json
import os
import time
import re
from collections import defaultdict
import sys # Import sys for checking Python version if needed

# --- Configuration ---
HC_API_BASE_URI = 'https://health-products.canada.ca/api/drug'
OUTPUT_FILENAME = 'https://raw.githubusercontent.com/irfanrajani/CliniStream-OscarEMR/refs/heads/main/compiled_drug_data.json'
RESTRICTED_JSON = 'https://raw.githubusercontent.com/irfanrajani/CliniStream-OscarEMR/refs/heads/main/build_compiled_drug_data.py'  # Ensure this file exists and is correct
REQUEST_TIMEOUT = 45  # Increased timeout slightly
ENDPOINTS = {
    "schedule":         "/schedule/?lang=en&type=json",
    "drugproduct":      "/drugproduct/?lang=en&type=json",
    "activeingredient": "/activeingredient/?lang=en&type=json",
    "form":             "/form/?lang=en&type=json",
}

# Only these lowercase schedule prefixes count as CDSA I–V (Narcotic, Controlled I/II/III, Benzodiazepine/Targeted)
# Refer to https://laws-lois.justice.gc.ca/eng/acts/C-38.8/page-16.html#h-128688 for schedules
# And https://laws-lois.justice.gc.ca/eng/regulations/SOR-2000-217/page-1.html for Benzodiazepines
CDSA_PREFIXES = [
    "schedule i", "schedule ii", "schedule iii",
    "schedule iv", "schedule v",
    "narcotic", # From Narcotic Control Regulations
    "controlled part i", # From CDSA Schedule II precursors or Part G controlled drugs? Be specific if possible
    "controlled part ii",
    "controlled part iii",
    "benzodiazepine" # Specific category often treated as controlled/monitored
]

# --- Helper Functions ---

def fetch_data(name, path):
    """Fetches data from the Health Canada API endpoint."""
    url = HC_API_BASE_URI + path
    print(f"\n🔗 Fetching {name} from {url}")
    headers = {'User-Agent': 'RefillRequestFormApp/1.0'} # Be a good API citizen
    try:
        response = requests.get(url, timeout=REQUEST_TIMEOUT, headers=headers)
        response.raise_for_status()  # Raises HTTPError for bad responses (4XX or 5XX)
        data = response.json()

        # Handle cases where API might return non-list on error/no data
        if isinstance(data, list):
             print(f"  ✓ Retrieved {len(data)} records for {name}")
             return data
        elif data is None:
             print(f"  ✓ Retrieved 0 records for {name} (API returned null)")
             return []
        else:
             print(f"  ⚠️ API returned non-list data for {name}: {type(data)}. Treating as empty.")
             return [] # Return empty list if unexpected type

    except requests.exceptions.RequestException as e:
        print(f"  ❌ Network/Request Error fetching {name}: {e}")
        return []
    except json.JSONDecodeError as e:
        print(f"  ❌ JSON Decode Error fetching {name}: {e}")
        print(f"     Response text: {response.text[:200]}...") # Show start of problematic text
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
    script_dir = os.path.dirname(os.path.abspath(__file__)) or '.'
    print(f"Script running in directory: {script_dir}")
    print(f"Python version: {sys.version}")


    # 1) Fetch all endpoints concurrently (or sequentially if issues arise)
    print("\n--- Starting Data Fetch ---")
    all_data = {}
    fetch_success = True
    start_fetch = time.time()
    for name, path in ENDPOINTS.items():
         data = fetch_data(name, path)
         if not isinstance(data, list): # Double check type after fetch
             print(f"  ❌ ERROR: Fetch for '{name}' did not return a list. Aborting.")
             fetch_success = False
             break # Stop processing if a fetch failed badly
         all_data[name] = data
         time.sleep(0.2) # Small delay between requests
    print(f"--- Data Fetch finished in {time.time()-start_fetch:.2f}s ---")

    if not fetch_success:
         print("\n❌ Critical error during data fetch. Cannot continue.")
         sys.exit(1) # Exit script if fetch failed

    # 2) Load external restricted names & aliases
    print("\n--- Loading Restricted Drug List ---")
    restricted_aliases = set()
    restricted_json_path = os.path.join(script_dir, RESTRICTED_JSON)
    try:
        print(f"🔍 Loading restricted list from {restricted_json_path}")
        with open(restricted_json_path, 'r', encoding='utf-8') as f:
            schedules_or_drugs = json.load(f) # Assume it's a dict {"Schedule Name": [drugs]} or just [drugs]

        # Adapt based on expected structure of restricted_drugs.json
        entries_to_process = []
        if isinstance(schedules_or_drugs, dict):
             for schedule_name, drugs in schedules_or_drugs.items():
                 if isinstance(drugs, list):
                     entries_to_process.extend(drugs)
                 else:
                      print(f"  ⚠️ Expected list for schedule '{schedule_name}', got {type(drugs)}. Skipping.")
        elif isinstance(schedules_or_drugs, list):
             entries_to_process = schedules_or_drugs
        else:
             print(f"  ⚠️ Expected dict or list in {RESTRICTED_JSON}, got {type(schedules_or_drugs)}. Cannot load restrictions.")

        processed_count = 0
        for entry in entries_to_process:
             if isinstance(entry, dict):
                 nm = normalize_text(entry.get('name'))
                 if nm:
                     restricted_aliases.add(nm)
                     processed_count += 1
                 for alias in entry.get('aliases', []):
                     a = normalize_text(alias)
                     if a:
                         restricted_aliases.add(a)
                         processed_count += 1
             elif isinstance(entry, str): # Allow simple list of names
                  nm = normalize_text(entry)
                  if nm:
                      restricted_aliases.add(nm)
                      processed_count += 1
             else:
                  print(f"  ⚠️ Skipping invalid entry type in restriction list: {type(entry)}")


        print(f"  ✓ Loaded {len(restricted_aliases)} unique restricted names/aliases from {processed_count} entries.")
    except FileNotFoundError:
         print(f"  ❌ ERROR: Restricted drug file not found: {restricted_json_path}")
         print("     Restricted drug checks based on name will be skipped.")
         # You might choose to exit here if this file is mandatory: sys.exit(1)
    except json.JSONDecodeError as e:
         print(f"  ❌ ERROR: Could not parse JSON from {restricted_json_path}: {e}")
         print("     Restricted drug checks based on name will be skipped.")
    except Exception as e:
        print(f"  ❌ Unexpected Error loading {restricted_json_path}: {type(e).__name__} - {e}")

    # 3) Index API schedule -> drug_code -> set of schedule names
    print("\n--- Indexing Schedules ---")
    schedules_by_code = defaultdict(set) # Use set for automatic deduplication
    sched_count = 0
    for item in all_data.get('schedule', []):
        code = item.get('drug_code')
        # Sometimes schedule name might be missing or null
        name = normalize_text(item.get('schedule_name'))
        if code and name:
            schedules_by_code[code].add(name)
            sched_count += 1
    print(f"🔗 Indexed {sched_count} schedule entries for {len(schedules_by_code)} unique drug codes")

    # 4) Index products by drug_code
    print("\n--- Indexing Drug Products ---")
    products = {}
    for p in all_data.get('drugproduct', []):
        code = p.get('drug_code')
        # Use first product encountered per code, assuming it's representative enough
        if code and code not in products:
            products[code] = p
    print(f"📦 Indexed {len(products)} unique drug products")

    # 5) Index ingredients by drug_code & normalize strength
    print("\n--- Indexing Active Ingredients ---")
    ingredients_by_code = defaultdict(list)
    ing_count = 0
    for ing in all_data.get('activeingredient', []):
        code = ing.get('drug_code')
        if not code: continue

        # Clean ingredient name (remove text in parentheses like source/salt form)
        raw_name = ing.get('ingredient_name','')
        cleaned_name = normalize_text(re.sub(r'\s*\([^)]*\)\s*', '', raw_name)).strip() # More robust regex
        if not cleaned_name: continue # Skip if name becomes empty after cleaning

        ing['cleaned_name'] = cleaned_name

        # --- Strength Normalization ---
        raw_strength = str(ing.get('strength','')).strip()
        normalized_strength = raw_strength
        try:
            if raw_strength: # Only process if strength exists
                f_strength = float(raw_strength)
                # Convert "5.0" to "5", but keep "2.5" as "2.5"
                if f_strength.is_integer():
                    normalized_strength = str(int(f_strength))
                else:
                    normalized_strength = str(f_strength) # Use float representation
        except ValueError:
            # Keep original if not a simple number (e.g., " യൂണിറ്റ്സ്/mL", "N/A")
            normalized_strength = raw_strength
        ing['normalized_strength'] = normalized_strength
        # --- End Strength Normalization ---

        # Normalize strength unit to lowercase
        ing['normalized_strength_unit'] = normalize_text(ing.get('strength_unit',''))

        ingredients_by_code[code].append(ing)
        ing_count+=1
    print(f"🧪 Indexed {ing_count} ingredient entries for {len(ingredients_by_code)} codes (with strength normalization)")


    # 6) Index forms by drug_code
    print("\n--- Indexing Dosage Forms ---")
    forms_by_code = defaultdict(list)
    form_count = 0
    found_forms = set() # Keep track of all unique form names encountered
    for frm in all_data.get('form', []):
        code = frm.get('drug_code')
        if not code: continue
        form_name = str(frm.get('pharmaceutical_form_name','')).strip()
        if not form_name: continue # Skip if form name is empty

        normalized = normalize_text(form_name)
        frm['normalized_form'] = normalized
        forms_by_code[code].append(frm)
        found_forms.add(form_name) # Add original case name for potential dropdown generation
        form_count += 1
    print(f"💊 Indexed {form_count} form entries for {len(forms_by_code)} codes")
    print(f"  (Found {len(found_forms)} unique form names across all drugs)")
    # Optional: Save unique forms for dynamic dropdown later
    # with open('unique_dosage_forms.json', 'w', encoding='utf-8') as f_forms:
    #     json.dump(sorted(list(found_forms)), f_forms, ensure_ascii=False, indent=2)


    # 7) Combine data, flag restrictions, create unique entries
    print("\n--- Combining Data & Generating Output ---")
    compiled = []
    processed_keys = set() # Track unique ingredient+form combinations
    skipped_missing_data = 0
    skipped_duplicates = 0

    # Iterate through products which have an associated drug_code
    for code, prod in products.items():
        ings = ingredients_by_code.get(code, [])
        forms = forms_by_code.get(code, [])

        # CRITICAL: Ensure both ingredients and forms exist for this product code
        if not ings or not forms:
            skipped_missing_data += 1
            continue

        # Take the first form as representative for this drug_code entry
        # NOTE: A single drug_code can sometimes list multiple forms (e.g., kit with tablet and powder)
        # This simplification takes the first one listed. Handle kits separately if needed.
        form0 = forms[0]
        form_name = form0.get('pharmaceutical_form_name','').strip()
        normalized_form = form0.get('normalized_form','')
        if not form_name or not normalized_form:
            print(f"  ⚠️ Skipping code {code} due to missing form name from first form entry.")
            skipped_missing_data += 1
            continue

        # --- Determine Restriction Status ---
        # a) Schedule-based check
        api_schedule_names = schedules_by_code.get(code, set())
        is_restricted_schedule = False
        for sched_name in api_schedule_names:
            if any(sched_name.startswith(prefix) for prefix in CDSA_PREFIXES):
                is_restricted_schedule = True
                break

        # b) Name-based check (against external list)
        is_restricted_name = False
        for i in ings:
            # Check if the cleaned ingredient NAME (lowercase) is in our restricted list
            if i['cleaned_name'] in restricted_aliases:
                is_restricted_name = True
                break # Found a match, no need to check further ingredients for this product

        restricted_flag = is_restricted_schedule or is_restricted_name
        # --- End Restriction Status ---


        # --- Build Display and Search Strings ---
        ings.sort(key=lambda x: x['cleaned_name']) # Sort for consistent key generation
        display_list = []
        search_terms = set() # Use set for automatic duplicate removal in search
        ingredient_names_only = [] # For restriction check comparison if needed

        for i in ings:
            nm = i['cleaned_name']
            if not nm: continue # Should not happen if filtered above
            ingredient_names_only.append(nm)

            strg = i['normalized_strength']
            unt = i['normalized_strength_unit'] # Use normalized unit

            disp = nm
            if strg: # Only add spacing and strength/unit if strength exists
                 disp += f" {strg}"
                 if unt: # Only add unit if it exists
                     disp += f"{unt}" # Add unit directly after strength

            display_list.append(disp)
            search_terms.add(nm) # Add name to search
            if strg: search_terms.add(strg) # Add normalized strength to search


        # --- Create Unique Key & Deduplicate ---
        # Key based on sorted ingredients (with normalized strength/unit) + normalized form
        ing_key = "|".join(sorted(display_list))
        entry_key = f"{ing_key}::{normalized_form}"

        if entry_key in processed_keys:
            skipped_duplicates += 1
            continue # Skip if we've already added this exact combination
        processed_keys.add(entry_key)
        # --- End Deduplication ---


        # --- Prepare final entry ---
        first_ing = ings[0] # Already checked that ings is not empty
        brand_name = str(prod.get('brand_name', '')).strip()

        entry = {
            "drug_code":             code, # Reference code (might not be unique to the displayed entry)
            "brand_name":            brand_name,
            "ingredients":           display_list, # List of "Ingredient StrengthUnit" strings
            "dosage_form":           form_name, # Original form name for display
            "normalized_dosage_form": normalized_form, # Lowercase form for matching
            "is_restricted":         restricted_flag, # Boolean flag
             # Search fields combined
            "_search_text":         f"{brand_name.lower()} {' '.join(search_terms)} {normalized_form}",
             # Fields for potential auto-fill
            "first_ingredient_name": first_ing['cleaned_name'], # Just the name
            "first_strength":        first_ing['normalized_strength'], # Normalized strength
            "first_strength_unit":   first_ing['normalized_strength_unit'], # Normalized unit
        }
        compiled.append(entry)
    # --- End Combination Loop ---

    print(f"✓ Processed {len(products)} product codes.")
    print(f"  - Skipped {skipped_missing_data} due to missing ingredient/form data.")
    print(f"  - Skipped {skipped_duplicates} as duplicates (same ingredients/form).")
    print(f"✔️ Built {len(compiled)} final unique entries for JSON output.")


    # 8) Save Compiled Data to JSON
    print("\n--- Saving Compiled Data ---")
    out_path = os.path.join(script_dir, OUTPUT_FILENAME)
    print(f"💾 Saving to {out_path}")
    try:
        with open(out_path, 'w', encoding='utf-8') as f:
            # Use separators for minimal file size, ensure_ascii=False for proper characters
            json.dump(compiled, f, ensure_ascii=False, separators=(',', ':'))
        print("✅ Save complete.")
    except IOError as e:
         print(f"  ❌ ERROR Saving JSON: Could not write to file '{out_path}'. Check permissions. Error: {e}")
    except Exception as e:
        print(f"  ❌ Unexpected Error saving JSON: {type(e).__name__} - {e}")

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
