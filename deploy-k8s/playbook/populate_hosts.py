import sys
import subprocess

vm = sys.argv[1]

proc=subprocess.Popen(["virsh", "domifaddr", vm],stdout=subprocess.PIPE,stderr=subprocess.PIPE)
stdout,stderr=proc.communicate()
if not stderr:
        ip_addr = stdout.decode("utf-8").split()[-1].split("/")[0]
        print(ip_addr)
