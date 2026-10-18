"""Run Lua syntax checks and the addon's test suites from any directory."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[1]
for path in sorted((root / 'TerminaClock').glob('*.lua')):
    subprocess.run(['luac', '-p', str(path)], check=True, cwd=root)
for path in sorted((root / 'tests').glob('*.lua')):
    subprocess.run(['lua', str(path)], check=True, cwd=root)
print('All Lua syntax checks and test suites passed.')
