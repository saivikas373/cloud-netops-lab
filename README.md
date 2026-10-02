# cloud-netops-lab

A hub-and-spoke AWS network built entirely in Terraform, by a data-center network engineer moving his BGP/EVPN experience into cloud networking.

The goal is to design cloud networks the same way I design on-prem fabrics: a clear addressing plan, segmentation by tier, explicit routing, and everything reproducible from code instead of console clicks.

## What it builds

```
                 ┌──────────── us-east-1 ────────────┐
                 │                                   │
   hub  10.0.0.0/16      app  10.1.0.0/16      data  10.2.0.0/16
   ├─ public-a/b         ├─ public-a/b         ├─ public-a/b
   └─ private-a/b        └─ private-a/b        └─ private-a/b
                         + app-sg (443 from VPC only)
                         + private NACL (VPC-local traffic only)
```

| Piece | Details |
|---|---|
| **Reusable VPC module** (`modules/vpc`) | One module stamps out a VPC, its subnets, an internet gateway, and public/private route tables. Each subnet is placed by a single `public = true/false` flag. |
| **Three VPCs** (`envs/dev`) | `hub`, `app`, and `data`, each with non-overlapping /16s and two AZs (us-east-1a/b), ready for Transit Gateway peering. |
| **Security** | Security group allowing HTTPS only from inside the app VPC. A stateless NACL on the private subnets restricting traffic to the VPC CIDR. |
| **Remote state** (`bootstrap`) | S3 backend with versioning and `prevent_destroy`, so state is shared and protected like a config archive. |

## Network-engineer translation

| On-prem concept | What I used in AWS |
|---|---|
| VRF / tenant separation | Separate VPCs per tier |
| Routing table per VRF | Public vs private route tables |
| Default route to the edge | `0.0.0.0/0 → Internet Gateway` (public tier only) |
| Interface ACL (stateful-ish) | Security group |
| Stateless ACL on an SVI | Network ACL |
| Golden config template | Terraform module |

## Layout

```
bootstrap/        S3 bucket for Terraform state (run once)
modules/vpc/      Reusable VPC module (inputs: name, cidr, subnets map)
envs/dev/         hub, app, and data VPCs + SG + NACL using the module
```

## How to run

```bash
# 1. One-time: create the state bucket
cd bootstrap && terraform init && terraform apply

# 2. Build the network
cd ../envs/dev
terraform init        # connects to the S3 backend
terraform plan        # preview: like 'show | compare' before commit
terraform apply
```

Requires the Terraform CLI and AWS credentials configured (`aws configure`).

## Roadmap

- [x] VPC, subnets, IGW, and route tables
- [x] S3 remote state
- [x] Security groups and NACLs
- [x] Reusable module, three VPCs
- [ ] Transit Gateway connecting hub ↔ app ↔ data
- [ ] NAT gateway for private-subnet egress
- [ ] VPC Flow Logs and a reachability test
- [ ] Site-to-site VPN with BGP to a simulated on-prem router

## About

**Saivikas Bedudhuri**, Network Engineer with 7 years in multi-vendor data-center networking (Cisco NX-OS/IOS-XR, Juniper, Arista), VXLAN/EVPN, BGP, and Python automation.
