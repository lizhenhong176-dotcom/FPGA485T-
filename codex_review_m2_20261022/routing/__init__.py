"""Routing-topology subpackage (step 1 of the V7 database build).

Everything that talks to RapidWright lives here. Public entry point is
``scripts/step1_topology.py``; this package only exposes functions.
"""

from __future__ import annotations

__all__ = ["env", "topology", "connections", "verify", "db", "manifest"]
