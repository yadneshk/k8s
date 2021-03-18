import sys
import subprocess
import ipaddress
import time

vm = sys.argv[1]

def try_fetching_ip(vm):
    proc=subprocess.Popen(["virsh", "domifaddr", vm],stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    stdout,stderr=proc.communicate()
    if not stderr:
        ip_addr = stdout.decode("utf-8").split()[-1].split("/")[0]
        return ip_addr

while True:
    out = try_fetching_ip(vm)
    try:
        ipaddress.ip_address(out)
        print(out)
        break
    except ValueError:
        continue
    time.sleep(2)

