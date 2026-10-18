"""Run Lua syntax checks and the addon's test suites from any directory."""
from pathlib import Path
import subprocess
import os

root = Path(__file__).resolve().parents[1]
for path in sorted((root / 'TerminaClock').glob('*.lua')):
    subprocess.run(['luac', '-p', str(path)], check=True, cwd=root)
for path in sorted((root / 'tests').glob('*.lua')):
    subprocess.run(['lua', str(path)], check=True, cwd=root)
for zone in ['America/Los_Angeles', 'America/Chicago', 'America/New_York', 'Europe/London', 'Europe/Berlin']:
    for suite in ['clock.lua', 'sounds.lua']:
        subprocess.run(['lua', str(root / 'tests' / suite)], check=True, cwd=root, env={**os.environ, 'TZ': zone})
print('All Lua syntax checks, test suites, and US/EU time zone checks passed.')
