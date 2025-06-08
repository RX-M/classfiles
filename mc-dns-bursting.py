"""
Cloud Bursting Library Demo
"""

import urllib.request
import dns.resolver
import random

PREM_NS="10.220.0.10"     # CoreDNS Service on Prem
PREM_SUFFIX=".default.svc.prem.local"
CLOUD_NS="10.230.0.10"    # CoreDNS Service in Cloud
CLOUD_SUFFIX=".default.svc.cloud.local"
GLOBAL_SUFFIX=".default.svc.global"


def cb_lookup(hostname: str) -> str:
    """Resolve hostname for cloud bursting

    If the suffix is ".default.svc.global" choose Prem unless Prem is at 80% util, then choose Cloud.
    If the suffix is ".default.svc.prem.local" resolve on Prem.
    If the suffix is ".default.svc.cloud.local" resolve in Cloud
    """
    res = dns.resolver.Resolver(configure=False)  # ignore /etc/resolv.conf
    try:
        if len(hostname) > len(GLOBAL_SUFFIX) and hostname[-1*len(GLOBAL_SUFFIX):] == GLOBAL_SUFFIX:
            if random.choice([True, False]):
                hostname = hostname[:len(hostname)-len(GLOBAL_SUFFIX)] + CLOUD_SUFFIX
                res.nameservers = [CLOUD_NS]
            else:
                hostname = hostname[:len(hostname)-len(GLOBAL_SUFFIX)] + PREM_SUFFIX
                res.nameservers = [PREM_NS]
        elif len(hostname) > len(PREM_SUFFIX) and hostname[-1*len(PREM_SUFFIX):] == PREM_SUFFIX:
            res.nameservers = [PREM_NS]
        elif len(hostname) > len(CLOUD_SUFFIX) and hostname[-1*len(CLOUD_SUFFIX):] == CLOUD_SUFFIX:
            res.nameservers = [CLOUD_NS]
        answer = res.resolve(hostname, rdtype='A', tcp=True)
        return answer[0].address
    except (dns.resolver.NXDOMAIN, dns.resolver.NoAnswer):
        print(f"No records found for {hostname}")
    except dns.exception.DNSException as exc:
        print(f"DNS query failed: {exc}")
    return ""

if __name__ == "__main__":
    prem_clusterip = cb_lookup("hi"+PREM_SUFFIX)
    cloud_clusterip = cb_lookup("hi"+CLOUD_SUFFIX)
    global_clusterip = cb_lookup("hi"+GLOBAL_SUFFIX)

    with urllib.request.urlopen(f"http://{prem_clusterip}:9898") as response:
        print(f"Prem CIP {prem_clusterip}, result: {response.read()}")
    with urllib.request.urlopen(f"http://{cloud_clusterip}:9898") as response:
        print(f"Cloud CIP {cloud_clusterip}, result: {response.read()}")
    with urllib.request.urlopen(f"http://{global_clusterip}:9898") as response:
        print(f"Global CIP {global_clusterip}, result: {response.read()}")