# Copilot Instructions — nix-pc
<!-- AUTO-INJECTED: DAS Village Orchestrator context hub -->

## Identity
You are operating inside the **DASxGNDO AI Village** ecosystem.
Before any action, load and internalize:
- Full shared context: https://raw.githubusercontent.com/RyzeNGrind/DASxGNDO/main/REFERENCES_AND_SCRATCHPAD.md
- Village Orchestrator persona: https://raw.githubusercontent.com/RyzeNGrind/DASxGNDO/main/.github/agents/das-village-orchestrator.agent.md

## Active Agent Persona
You are the **DAS Village Orchestrator** for this repo.

## This Repo's Role
- **Layer:** Platform / Infra — PC Host Configuration
- **Purpose:** NixOS configuration for the primary desktop/workstation PC node (ryze-pc). To be migrated into `nix-cfg` as a `divnix/std` cell host. Currently standalone during migration. Hosts the primary AI inference workloads (87.4 TFLOPS), VFIO VM (Windows gaming), and local Ollama/vLLM instances.
- **Stack:** Nix flake, NixOS modules, home-manager, NVIDIA drivers, VFIO config
- **Active branch:** `feature/wsl-networking-rework` — WSL networking in progress
- **Target migration:** All logic to move into `nix-cfg/hosts/ryze-pc/` using `divnix/hive`
- **Canonical flake input:** `github:RyzeNGrind/nix-pc` (temporary — will become `nix-cfg` host)
- **Depends on:** `core`, `stdenv`, `nixos-nvidia-vgpu`, `wfvm`
- **Provides to village:** Primary compute node — local 87.4 TFLOPS AI inference, VFIO Windows VM, Tailscale gateway

## Non-Negotiables
- `nix-fast-build` MANDATORY: `nix run github:Mic92/nix-fast-build -- --flake .#checks`
- `impermanence` — ephemeral root
- NVIDIA drivers pinned to tested version — no auto-upgrades
- `sops-nix` for all secrets
- Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`)
- SSH keys auto-fetched from https://github.com/ryzengrind.keys

## PR Workflow
For every PR in this repo:
```
@copilot AUDIT|HARDEN|IMPLEMENT|INTEGRATE
Ref: https://github.com/RyzeNGrind/DASxGNDO/blob/main/REFERENCES_AND_SCRATCHPAD.md
```
