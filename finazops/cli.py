# New FinOps CLI using Rich library
import argparse
import csv
import json
from pathlib import Path
from datetime import datetime, timedelta
from jinja2 import Template

try:
    from rich import print
    from rich.console import Console
    from rich.table import Table
    from rich.panel import Panel
    from rich.progress import track
    from rich.bar import Bar
except ImportError as e:
    raise SystemExit('Required dependency missing: {}'.format(e))

console = Console()

MD_TEMPLATE = """\
# FinOps Report

## Cost by Service
{% for svc, cost in cost_by_service %}
- **{{ svc }}**: ${{ cost }}
{% endfor %}

## Budgets
| Subscription | Limit | Actual |
| --- | --- | --- |
{% for b in budgets %}
| {{ b.subscription }} | {{ b.limit }} | {{ b.actual }} |
{% endfor %}

## Azure VMs
{% for inst in instances %}
- {{ inst.id }} ({{ inst.state }} in {{ inst.location }})
{% endfor %}

## FinOps Audit
{% for key, items in audit.items() %}
- **{{ key }}**: {{ ', '.join(items) }}
{% endfor %}
"""

HTML_TEMPLATE = """\
<!DOCTYPE html>
<html>
<head>
  <meta charset='utf-8'>
  <title>FinOps Report</title>
</head>
<body>
<h1>FinOps Report</h1>
<h2>Cost by Service</h2>
<ul>
{% for svc, cost in cost_by_service %}
  <li>{{ svc }}: ${{ cost }}</li>
{% endfor %}
</ul>
<h2>Budgets</h2>
<table>
  <tr><th>Subscription</th><th>Limit</th><th>Actual</th></tr>
{% for b in budgets %}
  <tr><td>{{ b.subscription }}</td><td>{{ b.limit }}</td><td>{{ b.actual }}</td></tr>
{% endfor %}
</table>
<h2>Azure VMs</h2>
<ul>
{% for inst in instances %}
  <li>{{ inst.id }} ({{ inst.state }} in {{ inst.location }})</li>
{% endfor %}
</ul>
<h2>FinOps Audit</h2>
<ul>
{% for key, items in audit.items() %}
  <li><strong>{{ key }}</strong>: {{ ', '.join(items) }}</li>
{% endfor %}
</ul>
</body>
</html>
"""

# Mock data
def get_mock_costs():
    services = {
        'Virtual Machines': 120.0,
        'Storage Accounts': 80.0,
        'SQL Database': 40.0,
        'Functions': 10.0,
    }
    tags = {
        'env:prod': 150.0,
        'env:dev': 70.0,
    }
    return services, tags

def get_mock_budgets():
    return [
        {'subscription': 'sub-01', 'limit': 200, 'actual': 180},
        {'subscription': 'sub-02', 'limit': 150, 'actual': 170},
    ]

def get_mock_vms(locations):
    vms = [
        {'id': 'vm-001', 'state': 'running', 'location': 'eastus'},
        {'id': 'vm-002', 'state': 'stopped', 'location': 'eastus'},
        {'id': 'vm-003', 'state': 'stopped', 'location': 'westus2'},
    ]
    return [v for v in vms if v['location'] in locations]

def get_mock_trend():
    base = datetime.now()
    return {
        (base - timedelta(days=30 * i)).strftime('%b %Y'): 100 + i * 10
        for i in range(6)
    }

def finops_audit():
    return {
        'untagged': ['vm-003', 'disk-001'],
        'unused': ['vm-002'],
        'budget_breaches': ['sub-02'],
    }

def parse_args():
    p = argparse.ArgumentParser(description='FinOps CLI')
    p.add_argument('--time-range', type=int, default=30, help='Days of cost data')
    p.add_argument('--tag', nargs='*', help='Filter by tag')
    p.add_argument('--subscriptions', nargs='*', help='Specific Azure subscriptions')
    p.add_argument('--all', action='store_true', help='Use all subscriptions')
    p.add_argument('--combine', action='store_true', help='Combine subscriptions by account')
    p.add_argument('--locations', nargs='*', default=['eastus'], help='Azure locations to search')
    p.add_argument('--report-name', default='report', help='Base name for export files')
    p.add_argument('--report-type', nargs='*', default=[], choices=['csv', 'json', 'pdf'], help='Export formats')
    p.add_argument('--dir', default='.', help='Output directory')
    p.add_argument('--trend', action='store_true', help='Show 6 month trend (JSON only)')
    p.add_argument('--export', choices=['md', 'html'], help='Export analysis to Markdown or HTML')
    return p.parse_args()

def export(report, args):
    out_dir = Path(args.dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    if args.export:
        if args.export == 'md':
            template = Template(MD_TEMPLATE)
            content = template.render(**report)
            path = out_dir / f"{args.report_name}.md"
            path.write_text(content)
        elif args.export == 'html':
            template = Template(HTML_TEMPLATE)
            content = template.render(**report)
            path = out_dir / f"{args.report_name}.html"
            path.write_text(content)
    if 'json' in args.report_type or args.trend:
        path = out_dir / f"{args.report_name}.json"
        with path.open('w') as f:
            json.dump(report, f, indent=2)
    if 'csv' in args.report_type:
        path = out_dir / f"{args.report_name}.csv"
        with path.open('w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['Service', 'Cost'])
            for svc, cost in report['cost_by_service']:
                writer.writerow([svc, cost])
    if 'pdf' in args.report_type:
        try:
            from fpdf import FPDF
        except ImportError:
            console.print('[red]PDF export requires fpdf package[/red]')
        else:
            path = out_dir / f"{args.report_name}.pdf"
            pdf = FPDF()
            pdf.add_page()
            pdf.set_font('Arial', size=12)
            pdf.cell(200, 10, txt='FinOps Report', ln=1)
            for svc, cost in report['cost_by_service']:
                pdf.cell(200, 10, txt=f'{svc}: ${cost}', ln=1)
            pdf.output(str(path))

def main():
    args = parse_args()
    services, tags = get_mock_costs()
    cost_by_service = sorted(services.items(), key=lambda x: x[1], reverse=True)
    cost_by_tag = {t: tags.get(t, 0) for t in (args.tag or tags.keys())}
    budgets = get_mock_budgets()
    instances = get_mock_vms(args.locations)
    trend = get_mock_trend() if args.trend else None
    audit = finops_audit()

    table = Table(title='Cost by Service')
    table.add_column('Service')
    table.add_column('Cost', justify='right')
    for svc, cost in cost_by_service:
        table.add_row(svc, f"${cost}")
    console.print(table)

    budget_table = Table(title='Budgets')
    budget_table.add_column('Subscription')
    budget_table.add_column('Limit', justify='right')
    budget_table.add_column('Actual', justify='right')
    for b in budgets:
        color = 'red' if b['actual'] > b['limit'] else 'green'
        budget_table.add_row(b['subscription'], str(b['limit']), f"[{color}]{b['actual']}[/{color}]")
    console.print(budget_table)

    inst_table = Table(title='Azure VMs')
    inst_table.add_column('ID')
    inst_table.add_column('State')
    inst_table.add_column('Location')
    for inst in instances:
        inst_table.add_row(inst['id'], inst['state'], inst['location'])
    console.print(inst_table)

    if trend:
        trend_table = Table(title='Cost Trend')
        trend_table.add_column('Month')
        trend_table.add_column('Cost', justify='right')
        for month, cost in trend.items():
            trend_table.add_row(month, f"${cost}")
        console.print(trend_table)

    audit_table = Table(title='FinOps Audit')
    audit_table.add_column('Category')
    audit_table.add_column('Items')
    for k, v in audit.items():
        audit_table.add_row(k, ', '.join(v))
    console.print(audit_table)

    report = {
        'cost_by_service': cost_by_service,
        'cost_by_tag': cost_by_tag,
        'budgets': budgets,
        'instances': instances,
        'audit': audit,
        'trend': trend,
    }
    if args.report_type or args.trend or args.export:
        if args.trend and 'json' not in args.report_type:
            console.print('[yellow]Trend reports only support JSON export. Other formats ignored.[/yellow]')
        export(report, args)

if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        console.print('[red]Error: {}[/red]'.format(e))
