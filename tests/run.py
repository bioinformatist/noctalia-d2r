#!/usr/bin/env python3
"""Exercise the shipped Luau in one VM with native host stubs."""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
URL = "https://d2runewizard.com/api/trackers/terror-zone"
HEADERS = {
    "User-Agent": "Noctalia-D2R-TZ/0.1.0",
    "D2R-Contact": "ysun@sctmes.com",
    "D2R-Platform": "Noctalia",
    "D2R-Repo": "https://github.com/bioinformatist/noctalia-d2r",
}


def literal(value):
    if value is None:
        return "nil"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return repr(value)
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, list):
        return "{" + ",".join(literal(x) for x in value) + "}"
    return "{" + ",".join("[" + literal(k) + "]=" + literal(v) for k, v in value.items()) + "}"


def source(path):
    return (ROOT / path).read_text()


def bundle(body):
    legacy = source("d2r-tz/lib/legacy.luau")
    zones = source("d2r-tz/lib/zones.luau").replace('require("./legacy.luau")', "__legacy")
    response = source("d2r-tz/lib/response.luau")
    tracker = source("d2r-tz/tracker.luau").replace('require("./lib/response.luau")', "__response")
    widget = source("d2r-tz/widget.luau").replace('require("./lib/zones.luau")', "__zones")
    modules = ("local __legacy = (function()\n" + legacy + "\nend)()\n"
               + "local __zones = (function()\n" + zones + "\nend)()\n"
               + "local __response = (function()\n" + response + "\nend)()\n")
    body = body.replace('require("../d2r-tz/lib/zones")', "__zones")
    body = body.replace('require("../d2r-tz/lib/legacy")', "__legacy")
    body = body.replace('require("../d2r-tz/lib/response")', "__response")
    body = body.replace('require("../d2r-tz/tracker")', "do\n" + tracker + "\nend")
    body = body.replace('require("../d2r-tz/widget_copy")', "do\n" + widget + "\nend")
    body = body.replace('require("../d2r-tz/widget")', "do\n" + widget + "\nend")
    assert 'require("../d2r-tz/' not in body
    return modules + body


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--live", action="store_true")
    args = parser.parse_args()
    body = source("tests/live.luau" if args.live else "tests/harness.luau")
    if not args.live:
        original = json.loads(source("tests/legacy.json"))
        body = body.replace("__LEGACY_FIXTURE__", literal(original))
    if args.live:
        request = urllib.request.Request(URL, headers=HEADERS)
        with urllib.request.urlopen(request, timeout=15) as response:
            assert response.status == 200
            raw = response.read().decode("utf-8")
        payload = json.loads(raw)
        body = body.replace('require("./fixture")', literal(payload))
    with tempfile.TemporaryDirectory(prefix="d2r-tests-") as tmp:
        script = Path(tmp) / "bundle.luau"
        script.write_text(bundle(body))
        subprocess.run(["luau", str(script)], check=True)


if __name__ == "__main__":
    main()
