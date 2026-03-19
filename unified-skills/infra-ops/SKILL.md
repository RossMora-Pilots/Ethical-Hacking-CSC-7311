# Skill: Infrastructure Operations (Infra-Ops)

## Description
Provides tools for managing infrastructure, including SSH connections, ESXi/Proxmox virtualization, and network diagnostics.

## Usage
Use this skill when you need to:
- Assess an ESXi host's status.
- Inventory VMs on a virtualization host.
- Test SSH connectivity to a server.

## Tools
### `assess_host.sh`
Checks the health and configuration of an ESXi host.
```bash
./assess_host.sh <host>
```

### `inventory_vms.py`
Lists virtual machines and their states.
```bash
python3 inventory_vms.py --host <host> --user <user> --password <pass>
```

### `test_connectivity.sh`
Tests SSH connectivity and key authentication.
```bash
./test_connectivity.sh <host> <user> <key_path>
```

## Examples
**Check ESXi Host:**
```bash
./assess_host.sh 192.168.0.100
```

**Test SSH:**
```bash
./test_connectivity.sh 192.168.0.100 root ~/.ssh/id_rsa
```
