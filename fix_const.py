import os
import re

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # We need to find `const ` that precedes something that contains AppColors.
    # Actually, simpler: if a line contains AppColors, replace `const ` with `` (but be careful about multiple consts).
    # Since dart formatting usually puts things on one line or multiple, let's just replace `const ` with `` 
    # anywhere on a line that contains `AppColors`. Wait, what if it's `const SizedBox(width: 10)`? That's safe to remove const, it just becomes a normal SizedBox.
    # Let's just remove ALL `const ` and `const\n` on lines/statements that have AppColors.
    
    lines = content.split('\n')
    changed = False
    for i in range(len(lines)):
        if 'AppColors' in lines[i]:
            if 'const ' in lines[i]:
                lines[i] = lines[i].replace('const ', '')
                changed = True
            
    if changed:
        with open(filepath, 'w') as f:
            f.write('\n'.join(lines))
        print(f"Fixed {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            fix_file(os.path.join(root, file))

