#!/usr/bin/env python3
"""Interactive Azure login utility."""

from azure.identity import InteractiveBrowserCredential
from azure.mgmt.resource import SubscriptionClient
from rich import print


def main():
    print("[bold green]Opening browser for Azure authentication...[/bold green]")
    credential = InteractiveBrowserCredential()
    sub_client = SubscriptionClient(credential)
    print("[bold blue]Available Azure subscriptions:[/bold blue]")
    for sub in sub_client.subscriptions.list():
        print(f"- {sub.display_name} ({sub.subscription_id})")


if __name__ == "__main__":
    main()
