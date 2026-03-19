import os
import sys
import requests
import json
import urllib3

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

VC_HOST = os.environ.get("VC_HOST", "192.168.0.57")
VC_USER = os.environ.get("VC_USER")
VC_PASS = os.environ.get("VC_PASS")
TARGET_HOST_IP = os.environ.get("TARGET_HOST_IP", "192.168.0.47")

if not VC_USER or not VC_PASS:
    print("Error: VC_USER and VC_PASS environment variables must be set.")
    sys.exit(1)

BASE_URL = f"https://{VC_HOST}/rest"

def login():
    url = f"{BASE_URL}/com/vmware/cis/session"
    try:
        resp = requests.post(url, auth=(VC_USER, VC_PASS), verify=False)
        resp.raise_for_status()
        return resp.json()['value']
    except Exception as e:
        print(f"Login failed: {e}")
        sys.exit(1)

def get_host_id(session_id, host_ip):
    url = f"{BASE_URL}/vcenter/host"
    headers = {"vmware-api-session-id": session_id}
    params = {"filter.names": host_ip}
    resp = requests.get(url, headers=headers, params=params, verify=False)
    resp.raise_for_status()
    data = resp.json()['value']
    if not data:
        print(f"Host {host_ip} not found.")
        sys.exit(1)
    return data[0]['host']

def get_vms(session_id, host_id):
    url = f"{BASE_URL}/vcenter/vm"
    headers = {"vmware-api-session-id": session_id}
    params = {"filter.hosts": host_id}
    resp = requests.get(url, headers=headers, params=params, verify=False)
    resp.raise_for_status()
    return resp.json()['value']

def get_vm_details(session_id, vm_id):
    url = f"{BASE_URL}/vcenter/vm/{vm_id}"
    headers = {"vmware-api-session-id": session_id}
    resp = requests.get(url, headers=headers, verify=False)
    if resp.status_code != 200:
        return None
    return resp.json()['value']

def format_bytes(size):
    power = 2**10
    n = 0
    power_labels = {0 : '', 1: 'K', 2: 'M', 3: 'G', 4: 'T'}
    while size > power:
        size /= power
        n += 1
    return f"{size:.2f} {power_labels[n]}B"

def main():
    print(f"Connecting to {VC_HOST}...")
    session_id = login()
    print("Authenticated.")

    try:
        print(f"Finding host {TARGET_HOST_IP}...")
        host_id = get_host_id(session_id, TARGET_HOST_IP)
        print(f"Host ID: {host_id}")

        print("Listing VMs...")
        vms = get_vms(session_id, host_id)
        print(f"Found {len(vms)} VMs. Fetching details...")

        results = []
        
        for i, vm_summary in enumerate(vms):
            vm_id = vm_summary['vm']
            name = vm_summary['name']
            power = vm_summary['power_state']
            
            details = get_vm_details(session_id, vm_id)
            if not details:
                print(f"Could not get details for {name}")
                continue

            # Extract info
            guest_os = details.get('guest_OS', 'Unknown')
            disks = details.get('disks', [])
            
            # Calculate Provisioned Size
            total_capacity = sum(d['value']['capacity'] for d in disks)
            
            # Heuristics
            assessment = "Normal"
            
            if not disks:
                assessment = "EMPTY SHELL (No Disks)"
            elif power == "POWERED_ON":
                assessment = "Active (OS likely installed)"
            else:
                # Powered Off
                if total_capacity < 100 * 1024 * 1024: # < 100MB
                     assessment = "EMPTY SHELL (Tiny Disk)"
                elif "OTHER" in guest_os.upper() or "UNKNOWN" in guest_os.upper():
                     assessment = "POTENTIAL EMPTY SHELL (Generic Guest OS)"
                else:
                     assessment = f"Inactive (Configured: {guest_os})"

            results.append({
                "name": name,
                "power": power,
                "guest_os": guest_os,
                "provisioned_bytes": total_capacity,
                "provisioned_fmt": format_bytes(total_capacity),
                "assessment": assessment
            })

        print("\n\nVM Inventory Report:")
        print(f"{'Name':<50} | {'Power':<12} | {'Prov. Size':<10} | {'Assessment'}")
        print("-" * 120)
        
        for r in sorted(results, key=lambda x: x['name']):
            print(f"{r['name']:<50} | {r['power']:<12} | {r['provisioned_fmt']:<10} | {r['assessment']}")

        # Save to JSON
        with open("artifacts/vm_inventory.json", "w") as f:
            json.dump(results, f, indent=2)
        print("\nSaved inventory to artifacts/vm_inventory.json")

    finally:
        # Logout
        requests.delete(f"{BASE_URL}/com/vmware/cis/session", headers={"vmware-api-session-id": session_id}, verify=False)

if __name__ == "__main__":
    main()
