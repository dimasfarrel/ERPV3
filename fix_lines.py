import re

log_lines = """
lib/screens/dashboard/dashboard_screen.dart:58:25:
lib/screens/dashboard/dashboard_screen.dart:151:25:
lib/screens/dashboard/sidebar_widget.dart:16:25:
lib/screens/dashboard/overview_module.dart:82:17:
lib/screens/sales/sales_form_screen.dart:230:39:
lib/screens/sales/sales_form_screen.dart:457:25:
lib/screens/purchasing/purchasing_form_screen.dart:230:39:
lib/screens/purchasing/purchasing_form_screen.dart:457:25:
lib/screens/reports/reports_module.dart:29:21:
lib/screens/settings/settings_module.dart:449:68:
"""

updates = {}
for line in log_lines.strip().split('\n'):
    if ':' in line:
        parts = line.split(':')
        file = parts[0]
        line_num = int(parts[1])
        if file not in updates:
            updates[file] = []
        updates[file].append(line_num)

for file, lines in updates.items():
    with open(file, 'r') as f:
        content = f.readlines()
    
    for l in lines:
        idx = l - 1
        content[idx] = content[idx].replace('const ', '')
    
    with open(file, 'w') as f:
        f.writelines(content)
    print(f"Fixed {file}")
