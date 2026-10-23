#!/usr/bin/env python3
"""Run integration tests and capture named checkpoints from an iOS simulator."""
import json
import pathlib
import re
import subprocess
import sys
import time

root = pathlib.Path(__file__).resolve().parents[1]
output = root / 'docs/screenshots'
output.mkdir(parents=True, exist_ok=True)
if len(sys.argv) > 1:
    device = sys.argv[1]
else:
    inventory = json.loads(subprocess.check_output(
        ['xcrun', 'simctl', 'list', 'devices', 'booted', '-j']))
    booted = [d for devices in inventory['devices'].values() for d in devices
              if d['state'] == 'Booted']
    preferred = next((d for d in booted if d['name'] == 'Elexto QA'), None)
    selected = preferred or next(iter(booted), None)
    if selected is None:
        sys.exit('Start an iOS simulator, then rerun with its UUID.')
    device = selected['udid']
command = ['flutter', 'test', 'integration_test/app_flow_test.dart',
           '-d', device, '--reporter', 'expanded']
with (root / 'docs/simulator-test.log').open('w') as log:
    process = subprocess.Popen(command, cwd=root, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, text=True, bufsize=1)
    for line in process.stdout:
        log.write(line)
        log.flush()
        print(line, end='', flush=True)
        match = re.search(r'CAPTURE:([a-z0-9-]+)', line)
        if match:
            time.sleep(0.25)
            destination = output / (match.group(1) + '.png')
            subprocess.run(['xcrun', 'simctl', 'io', device,
                            'screenshot', str(destination)],
                           check=True, capture_output=True)
    sys.exit(process.wait())
