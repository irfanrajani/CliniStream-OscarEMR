# -*- coding: utf-8 -*-
import requests
import json
import os
import time
import gzip
from collections import defaultdict
import sys

# Enable debugging based on environment variable
DEBUG = os.getenv("DEBUG") == "true"

def log_debug(message):
    if DEBUG:
        print(f"[DEBUG] {message}")
        
# --- Configuration ---
HC_API_BASE_URI = 'https://health-products.canada.ca/api/drug'
OUTPUT_FILENAME = 'compiled_drug_data.json'
COMPRESSED_OUTPUT_FILENAME = 'compiled_drug_data.json.gz'
RESTRICTED_JSON = 'restricted_drugs.json'
REQUEST_TIMEOUT = 60 # Slightly increased timeout for potentially larger datasets
ENDPOINTS = {
    "schedule": "/schedule/?lang=en&type=json",
    "drugproduct": "/drugproduct/?lang=en&type=json",
    "activeingredient": "/activeingredient/?lang=en&type=json",
    "form": "/form/?lang=en&type=json",
    # Add other endpoints if needed (e.g., company, packaging)
}

# Update controlled schedule prefixes to be more comprehensive
CONTROLLED_SCHEDULE_PREFIXES = [
    "schedule f", 
    "schedule g",
    "schedule i",
    "schedule ii",
    "schedule iii",
    "schedule iv",
    "schedule v",
    "narcotic",
    "controlled",  # More general to catch any controlled designation
    "targeted substance",
    "benzodiazepine",
    "cdsa",        # To catch any CDSA references
]

# List of known controlled substances that should always be flagged
ALWAYS_RESTRICTED_INGREDIENTS = {
    "methylphenidate", "apomorphine", "codeine", "morphine", "oxycodone", 
    "hydrocodone", "fentanyl", "amphetamine", "dextroamphetamine", 
    "buprenorphine", "methadone", "tramadol", "tapentadol", "opium",
    "alprazolam", "diazepam", "lorazepam", "clonazepam", "temazepam", 
    "zolpidem", "zopiclone", "eszopiclone", "modafinil", "armodafinil",
    "lisdexamfetamine", "phentermine", "ketamine", "ghb", "cannabis",
    "marijuana", "thc", "cbd", "cocaine", "hydromorphone", "oxymorphone",
    "meperidine", "pentazocine", "butorphanol", "levorphanol", "carisoprodol", 
    "pentobarbital", "phenobarbital", "secobarbital", "glutethimide",
    "midazolam", "triazolam", "estazolam", "flurazepam", "quazepam",
    "bromazepam", "chlordiazepoxide", "prazepam", "flunitrazepam"
}

# --- Helper Functions ---
def fetch_data(name, path):
    """Fetches data from the Health Canada API endpoint."""
    url = HC_API_BASE_URI + path
    print(f"\n🔗 Fetching {name} from {url}")
    # Use a more descriptive user agent if possible
    headers = {'User-Agent': 'DrugDataCompiler/1.1 (Python Script; +https://github.com/YourRepo/YourProject)'}
    try:
        response = requests.get(url, timeout=REQUEST_TIMEOUT, headers=headers)
        response.raise_for_status()
        # Handle empty response body before JSON decoding
        if not response.content:
            print(f"  ✓ Retrieved 0 records for {name} (API returned empty response)")
            return []
        data = response.json()
        if isinstance(data, list):
            print(f"  ✓ Retrieved {len(data):,} records for {name}")
            return data
        elif data is None: # Explicitly check for null returned by API
            print(f"  ✓ Retrieved 0 records for {name} (API returned null)")
            return []
        else:
            # Log unexpected types, return empty list for consistency
            print(f"  ⚠️ API returned non-list data for {name}: {type(data)}. Treating as empty.")
            return []
    except requests.exceptions.Timeout:
        print(f"  ❌ Timeout Error fetching {name} after {REQUEST_TIMEOUT} seconds.")
        return None # Indicate critical failure vs. empty list
    except requests.exceptions.HTTPError as e:
        print(f"  ❌ HTTP Error fetching {name}: {e.response.status_code} {e.response.reason}")
        print(f"     URL: {url}")
        return None # Indicate critical failure
    except requests.exceptions.RequestException as e:
        print(f"  ❌ Network/Request Error fetching {name}: {e}")
        return None # Indicate critical failure
    except json.JSONDecodeError as e:
        print(f"  ❌ JSON Decode Error fetching {name}: {e}")
        print(f"     Response status: {response.status_code}")
        # Avoid printing large non-JSON responses fully
        print(f"     Response text (first 200 chars): {response.text[:200]}...")
        return None # Indicate critical failure
    except Exception as e:
        # Catch any other unexpected exceptions during fetch/processing
        print(f"  ❌ Unexpected Error during fetch/decode for {name}: {type(e).__name__} - {e}")
        return None # Indicate critical failure

def normalize_text(txt):
    """Converts text to lowercase and strips whitespace."""
    return str(txt).strip().lower() if txt is not None else ""

def save_compressed_json(data, output_file):
    """Save JSON data to a compressed .gz file."""
    try:
        with gzip.open(output_file, 'wt', encoding='utf-8') as gz_file:
            # Use indent=None and separators for smallest file size
            json.dump(data, gz_file, ensure_ascii=False, separators=(',', ':'))
        print(f"✅ Compressed JSON saved to {output_file} ({os.path.getsize(output_file)/1024/1024:.2f} MB)")
    except IOError as e:
        print(f"  ❌ ERROR: Could not write compressed file '{output_file}'. Error: {e}")
    except Exception as e:
        print(f"  ❌ ERROR: Unexpected error saving compressed file '{output_file}'. Error: {e}")


# --- Main Data Building Function ---
def build_compiled_data():
    """Fetches, processes, and combines Health Canada drug data."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    print(f"Script running in directory: {script_dir}")
    print(f"Python version: {sys.version}")

    # --- Fetch data ---
    print("\n--- Starting Data Fetch ---")
    all_data = {}
    fetch_failed = False
    start_fetch = time.time()
    for name, path in ENDPOINTS.items():
        data = fetch_data(name, path)
        if data is None: # Check for critical fetch failure indicated by None
            print(f"  ❌ CRITICAL FAILURE fetching '{name}'. Cannot proceed reliably.")
            fetch_failed = True
            # Decide whether to stop immediately or try fetching others
            # For this script, let's assume we need all core parts, especially drugproduct
            if name == 'drugproduct':
                 print("  🛑 Aborting due to failure fetching essential 'drugproduct' data.")
                 sys.exit(1) # Exit if primary data fails
            all_data[name] = [] # Store empty list to avoid KeyError later, but note failure
        else:
            all_data[name] = data
        time.sleep(0.2) # Keep small delay between requests

    print(f"--- Data Fetch finished in {time.time() - start_fetch:.2f}s ---")

    if fetch_failed:
        print("\n⚠️ WARNING: One or more data fetches failed. Output data may be incomplete.")

    # --- Load restricted drug list ---
    print("\n--- Loading Restricted Drug List ---")
    restricted_names = set()
    restricted_aliases = set()
    restricted_json_path = os.path.join(script_dir, RESTRICTED_JSON)
    
    try:
        with open(restricted_json_path, 'r', encoding='utf-8') as f:
            restricted_data = json.load(f)
            
            # Handle the structure where each drug has a name and aliases array
            if isinstance(restricted_data, list) and all(isinstance(item, dict) for item in restricted_data):
                for drug in restricted_data:
                    # Add the main name
                    if drug.get('name'):
                        restricted_names.add(normalize_text(drug['name']))
                    
                    # Add all aliases
                    for alias in drug.get('aliases', []):
                        if alias:
                            restricted_aliases.add(normalize_text(alias))
                
                print(f"  ✓ Loaded {len(restricted_data)} restricted drugs with {len(restricted_names)} names and {len(restricted_aliases)} aliases")
            
            # Handle simple list format (backward compatibility)
            elif isinstance(restricted_data, list):
                for item in restricted_data:
                    if isinstance(item, str):
                        restricted_names.add(normalize_text(item))
                print(f"  ✓ Loaded {len(restricted_names)} restricted drug names (simple list format)")
            
            # Handle dictionary format 
            elif isinstance(restricted_data, dict):
                product_names = restricted_data.get('products', [])
                ingredient_names = restricted_data.get('ingredients', [])
                for item in product_names:
                    restricted_names.add(normalize_text(item))
                for item in ingredient_names:
                    restricted_names.add(normalize_text(item))
                print(f"  ✓ Loaded {len(restricted_names)} restricted drug names from products/ingredients dict")
            
            else:
                print(f"  ⚠️ Unexpected format in {RESTRICTED_JSON}. Expected list of drugs with names/aliases or simple list.")

    except FileNotFoundError:
        print(f"  ⚠️ WARNING: Restricted drug file not found: {restricted_json_path}. Restriction checks will be limited.")
    except json.JSONDecodeError as e:
        print(f"  ❌ ERROR: Could not parse JSON from {restricted_json_path}: {e}")
        print(f"      The JSON file appears to be malformed. Please fix the errors and try again.")
        print(f"      Common issues: missing commas, unclosed quotes, or invalid escape characters.")
    except Exception as e:
        print(f"  ❌ ERROR: Unexpected error loading restricted drugs: {e}")

    # --- Pre-process supporting data for efficient lookup ---
    print("\n--- Pre-processing Supporting Data ---")
    start_preprocess = time.time()

    ingredients_by_code = defaultdict(list)
    if all_data.get('activeingredient'):
        for item in all_data['activeingredient']:
            drug_code = item.get('drug_code')
            if drug_code:
                ingredients_by_code[drug_code].append({
                    "name": item.get('ingredient_name', '').strip(),
                    "strength": item.get('strength', '').strip(),
                    "unit": item.get('strength_unit', '').strip()
                })
    print(f"  ✓ Processed {len(all_data.get('activeingredient', []))} active ingredients into lookup table.")

    forms_by_code = defaultdict(list)
    if all_data.get('form'):
        for item in all_data['form']:
            drug_code = item.get('drug_code')
            if drug_code:
                form_name = item.get('pharmaceutical_form_name', '').strip()
                if form_name:
                    forms_by_code[drug_code].append(form_name)
    print(f"  ✓ Processed {len(all_data.get('form', []))} forms into lookup table.")

    schedule_by_code = {}
    if all_data.get('schedule'):
        for item in all_data['schedule']:
            drug_code = item.get('drug_code')
            if drug_code:
                # Assuming one primary schedule per drug code from this endpoint
                schedule_name = item.get('schedule_name', '').strip()
                if schedule_name:
                     schedule_by_code[drug_code] = schedule_name
    print(f"  ✓ Processed {len(all_data.get('schedule', []))} schedules into lookup table.")

    print(f"--- Pre-processing finished in {time.time() - start_preprocess:.2f}s ---")

    # --- Combine data ---
    print("\n--- Combining Data ---")
    start_combine = time.time()
    compiled = []
    drug_products = all_data.get('drugproduct', [])

    if not drug_products:
        print("  ⚠️ No drug products found or fetched. Output will be empty.")
    else:
        print(f"  Processing {len(drug_products):,} drug products...")
        processed_count = 0
        restricted_count = 0
        
        for product in drug_products:
            drug_code = product.get('drug_code')
            if not drug_code:
                continue # Skip products without a drug code

            brand_name = product.get('brand_name', '').strip()
            normalized_brand_name = normalize_text(brand_name)

            # Get related data using pre-processed lookups
            active_ingredients = ingredients_by_code.get(drug_code, [])
            forms = forms_by_code.get(drug_code, [])
            schedule = schedule_by_code.get(drug_code, '')
            normalized_schedule = normalize_text(schedule)

            # Determine if restricted
            is_restricted = False
            restriction_reason = []

            # 1. Check schedule against controlled prefixes
            if schedule:
                for prefix in CONTROLLED_SCHEDULE_PREFIXES:
                    if prefix in normalized_schedule:  # Use 'in' instead of 'startswith'
                        is_restricted = True
                        restriction_reason.append(f"Schedule ({schedule})")
                        break

            # 2. Check product name against restricted names and aliases
            if not is_restricted:
                if normalized_brand_name in restricted_names or normalized_brand_name in restricted_aliases:
                    is_restricted = True
                    restriction_reason.append("Restricted Product Name")

            # 3. Check each active ingredient name against restricted lists
            if not is_restricted:
                for ingredient_info in active_ingredients:
                    ingredient_name = normalize_text(ingredient_info.get("name", ""))
                    if ingredient_name in restricted_names or ingredient_name in restricted_aliases:
                        is_restricted = True
                        restriction_reason.append(f"Restricted Ingredient ({ingredient_info.get('name')})")
                        break

            # 4. Check for specific known controlled ingredients that might be missed
            if not is_restricted:
                for ingredient_info in active_ingredients:
                    ingredient_name = normalize_text(ingredient_info.get("name", ""))
                    # Check if any of the always-restricted ingredients appear in the name
                    for restricted_ingredient in ALWAYS_RESTRICTED_INGREDIENTS:
                        if restricted_ingredient in ingredient_name:
                            is_restricted = True
                            restriction_reason.append(f"Common Controlled Ingredient ({ingredient_info.get('name')})")
                            break
                    if is_restricted:
                        break

            # Add debugging output for schedules that aren't being detected properly
            if DEBUG:
                if normalized_schedule and any(term in normalized_schedule for term in ["cdsa", "controlled", "narcotic"]) and not is_restricted:
                    log_debug(f"Potential missed controlled substance: '{brand_name}' with schedule '{schedule}'")

            entry = {
                "drug_code": drug_code,
                "brand_name": brand_name,
                "descriptor": product.get('descriptor', '').strip(),
                "active_ingredients": active_ingredients,
                "forms": forms,
                "schedule": schedule,
                "is_restricted": is_restricted,
                "restriction_reason": ", ".join(restriction_reason) if restriction_reason else "",  # Include for debugging
                "status": product.get('status', '').strip(),
                "history_date": product.get('history_date', '').strip(),
            }
            
            compiled.append(entry)
            processed_count += 1
            if is_restricted:
                restricted_count += 1
                
            # Print progress periodically for large datasets
            if processed_count % 10000 == 0:
                print(f"    Processed {processed_count:,}/{len(drug_products):,} products...")

        print(f"\n  ✓ Processed {processed_count:,} product entries.")
        print(f"  ✓ Identified {restricted_count:,} restricted medications.")
        print(f"  ✓ Built {len(compiled):,} final entries for JSON output.")
    
    print(f"--- Combining finished in {time.time() - start_combine:.2f}s ---")

    # --- Save uncompressed JSON ---
    print("\n--- Saving Output Files ---")
    out_path = os.path.join(script_dir, OUTPUT_FILENAME)
    try:
        with open(out_path, 'w', encoding='utf-8') as f:
            # Use separators for smaller file, indent=None for no pretty-printing
            json.dump(compiled, f, ensure_ascii=False, separators=(',', ':'))
        print(f"✅ Uncompressed JSON saved to {out_path} ({os.path.getsize(out_path)/1024/1024:.2f} MB)")
    except IOError as e:
        print(f"  ❌ ERROR: Could not write uncompressed file '{out_path}'. Error: {e}")
    except Exception as e:
        print(f"  ❌ ERROR: Unexpected error saving uncompressed file '{out_path}'. Error: {e}")

    # --- Save compressed JSON ---
    compressed_out_path = os.path.join(script_dir, COMPRESSED_OUTPUT_FILENAME)
    save_compressed_json(compiled, compressed_out_path)


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
