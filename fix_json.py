import re
import json

with open('assets/data/surat.json', 'r', encoding='utf-8') as f:
    text = f.read()

# This is a bit tricky, but let's try to add quotes around keys.
# We look for \s+([a-zA-Z0-9_]+):
text = re.sub(r'^\s*([a-zA-Z0-9_]+):', r'"\1":', text, flags=re.MULTILINE)

# Also fix audioFull keys like 01: to "01":
text = re.sub(r'^\s*([0-9]+):', r'"\1":', text, flags=re.MULTILINE)

try:
    data = json.loads(text)
    with open('assets/data/surat.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
    print("Success")
except Exception as e:
    print("Error:", e)

