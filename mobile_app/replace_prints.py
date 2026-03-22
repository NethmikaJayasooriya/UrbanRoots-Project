import os

def process_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'print(' in content:
        # replace print( with debugPrint(
        new_content = content.replace('print(', 'debugPrint(')
        
        # add import if needed
        import_stmt = "import 'package:flutter/foundation.dart';\n"
        if 'debugPrint(' in new_content and 'package:flutter/foundation.dart' not in new_content and 'package:flutter/material.dart' not in new_content:
            new_content = import_stmt + new_content

        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {path}")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Done.")
