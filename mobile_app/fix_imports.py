import os

def fix_imports():
    for root, _, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()

                if 'debugPrint' in content and 'package:flutter/foundation.dart' not in content:
                    # Find a good place to insert the import (e.g., after the last import or at the very top)
                    import_line = "import 'package:flutter/foundation.dart';\n"
                    
                    if content.startswith('import '):
                        # Insert at the top
                        new_content = import_line + content
                    else:
                        new_content = import_line + content
                        
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Fixed imports for {path}")

if __name__ == '__main__':
    fix_imports()
