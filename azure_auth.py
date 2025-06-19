"""Azure authentication utilities."""

from __future__ import annotations

import os
import subprocess
from typing import Dict, Tuple

from azure.identity import AzureCliCredential, ClientSecretCredential
from azure.identity import CredentialUnavailableError
from azure.mgmt.costmanagement import CostManagementClient
from azure.mgmt.consumption import ConsumptionManagementClient
from azure.mgmt.monitor import MonitorManagementClient
from azure.mgmt.resource import ResourceManagementClient, SubscriptionClient
import logging
from rich.logging import RichHandler


_handler = RichHandler(markup=True)
_handler.setFormatter(logging.Formatter('%(message)s'))
logger = logging.getLogger(__name__)
if not logger.handlers:
    logger.addHandler(_handler)
    logger.setLevel(logging.INFO)


_MANAGEMENT_SCOPE = "https://management.azure.com/.default"


def _try_cli_credential(scope: str) -> Tuple[object, str]:
    """Attempt Azure CLI authentication."""
    try:
        credential = AzureCliCredential()
        # Validate the credential
        credential.get_token(scope)
        return credential, "CLI"
    except Exception:
        return None, ""


def _try_sp_credential(scope: str) -> Tuple[object, str]:
    """Attempt service principal authentication from environment variables."""
    tenant_id = os.getenv("AZURE_TENANT_ID")
    client_id = os.getenv("AZURE_CLIENT_ID")
    client_secret = os.getenv("AZURE_CLIENT_SECRET")
    missing = [
        name
        for name, value in [
            ("AZURE_TENANT_ID", tenant_id),
            ("AZURE_CLIENT_ID", client_id),
            ("AZURE_CLIENT_SECRET", client_secret),
        ]
        if not value
    ]
    if missing:
        raise RuntimeError(
            "Missing required environment variables: " + ", ".join(missing)
        )

    credential = ClientSecretCredential(
        tenant_id=tenant_id,
        client_id=client_id,
        client_secret=client_secret,
    )
    credential.get_token(scope)
    return credential, "service principal"


def get_credential(scope: str = _MANAGEMENT_SCOPE) -> object:
    """Return an authenticated Azure credential.

    Tries Azure CLI authentication first and falls back to service principal.
    Raises RuntimeError if both methods fail.
    """

    credential, source = _try_cli_credential(scope)
    if credential:
        logger.info("[bold green]✅ Azure authentication succeeded using %s[/bold green]", source)
        return credential

    try:
        credential, source = _try_sp_credential(scope)
        logger.info("[bold green]✅ Azure authentication succeeded using %s[/bold green]", source)
        return credential
    except Exception as exc:
        raise RuntimeError(f"Azure authentication failed: {exc}") from exc


def get_subscription_id(credential: object | None = None) -> str:
    """Return the subscription ID from env or Azure CLI context."""

    sub_id = os.getenv("AZURE_SUBSCRIPTION_ID")
    if sub_id:
        return sub_id

    # Try Azure CLI if available
    try:
        result = subprocess.run(
            ["az", "account", "show", "--query", "id", "-o", "tsv"],
            capture_output=True,
            text=True,
            check=True,
        )
        cli_sub = result.stdout.strip()
        if cli_sub:
            return cli_sub
    except Exception:
        pass

    if credential is None:
        try:
            credential = get_credential()
        except RuntimeError:
            pass

    if credential is not None:
        try:
            client = SubscriptionClient(credential)
            subs = list(client.subscriptions.list())
            enabled = [s for s in subs if getattr(s, "state", "").lower() == "enabled"]
            if not enabled:
                raise RuntimeError("No enabled Azure subscriptions found")
            if len(enabled) > 1:
                logger.warning(
                    "[yellow]\u26A0\uFE0F Multiple subscriptions found. Set AZURE_SUBSCRIPTION_ID"
                )
            return enabled[0].subscription_id
        except Exception as exc:
            logger.debug("Failed to query subscriptions: %s", exc)

    raise RuntimeError(
        "Could not determine Azure subscription ID. Set AZURE_SUBSCRIPTION_ID"
    )


def get_azure_clients() -> Dict[str, object]:
    """Return initialized Azure SDK clients."""

    credential = get_credential()
    subscription_id = get_subscription_id(credential)

    clients = {
        "cost": CostManagementClient(credential),
        "consumption": ConsumptionManagementClient(credential, subscription_id),
        "monitor": MonitorManagementClient(credential, subscription_id),
        "resource": ResourceManagementClient(credential, subscription_id),
    }
    return clients

