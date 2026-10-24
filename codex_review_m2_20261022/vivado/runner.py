"""Run a Tcl script with Vivado in batch mode."""

from __future__ import annotations

import os
import shutil
import subprocess
import time
from pathlib import Path

from config import find_vivado


def _kill_tree(proc: subprocess.Popen) -> None:
    """Kill Vivado and its helper children, including on Windows."""
    if proc.poll() is not None:
        return
    if os.name == "nt":
        subprocess.run(
            ["taskkill", "/F", "/T", "/PID", str(proc.pid)],
            capture_output=True,
            check=False,
        )
    else:
        proc.kill()
    try:
        proc.wait(timeout=10)
    except subprocess.TimeoutExpired:
        pass


def run_tcl(
    script: str | Path,
    workdir: str | Path,
    timeout: int | None = 900,
    retries: int = 2,
    startup_timeout: int = 180,
) -> subprocess.CompletedProcess:
    """Execute `vivado -mode batch -source <script>` in *workdir*.

    Two 2017.2 quirks are handled here:

    * a per-run TEMP directory avoids collisions in the realtime synthesis
      helper (``rt-undefined`` / ``couldn't read .../realtime/top.tcl``);
    * occasionally the launcher sits at ~10 MB RSS without ever creating
      ``vivado.log``; that is treated as a startup hang, killed, and retried.

    The retry also clears a stale ``temp`` directory left by the killed run.
    """
    script = Path(script)
    workdir = Path(workdir)
    workdir.mkdir(parents=True, exist_ok=True)

    log = workdir / "vivado.log"
    cmd = [
        find_vivado(),
        "-mode",
        "batch",
        "-source",
        str(script),
        "-nojournal",
        "-log",
        str(log),
    ]

    temp_dir = workdir / "temp"

    last_error: Exception | None = None
    for attempt in range(retries + 1):
        # Let the previous Vivado release temp files / launcher locks.
        time.sleep(12)

        shutil.rmtree(temp_dir, ignore_errors=True)
        temp_dir.mkdir(parents=True, exist_ok=True)
        env = os.environ.copy()
        env["TEMP"] = str(temp_dir)
        env["TMP"] = str(temp_dir)

        try:
            log.unlink()
        except OSError:
            pass

        proc = subprocess.Popen(cmd, cwd=str(workdir), env=env)
        deadline = time.monotonic() + timeout if timeout else None
        startup_deadline = time.monotonic() + startup_timeout
        rc: int | None = None
        try:
            while True:
                rc = proc.poll()
                if rc is not None:
                    break
                now = time.monotonic()
                if not log.exists() and now > startup_deadline:
                    _kill_tree(proc)
                    raise TimeoutError(
                        f"Vivado startup hung for {startup_timeout}s "
                        f"(no {log.name}): {script}"
                    )
                if deadline is not None and now > deadline:
                    _kill_tree(proc)
                    raise subprocess.TimeoutExpired(cmd, timeout)
                time.sleep(0.5)
        except (TimeoutError, subprocess.TimeoutExpired) as exc:
            last_error = exc
            if attempt >= retries:
                raise
            print(f"[run_tcl] {type(exc).__name__}, retry {attempt + 1}/{retries}: {script}")
            continue

        if rc != 0:
            last_error = subprocess.CalledProcessError(rc, cmd)
            if attempt >= retries:
                raise last_error
            print(f"[run_tcl] exit {rc}, retry {attempt + 1}/{retries}: {script}")
            continue
        return subprocess.CompletedProcess(cmd, rc)

    assert last_error is not None
    raise last_error
