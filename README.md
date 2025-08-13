# Sigma Rule Writing Cheatsheet & Docker Toolchain for SOC
Author: Aung Myat Thu (w01f)  
Date: 2025-08-13

This repository is a **starter kit** for writing, validating, and converting Sigma rules across **Windows**, **Linux**, and **macOS**.  
It includes:

- Example rules
- Makefile for local and containerized builds
- Docker environment for Sigma CLI with all required backends and pipelines

---

## Repository Contents

```

rules/
windows/   # Sysmon and Security-based behaviors
linux/     # auditd behavior examples
macos/     # macOS/EDR behavior examples
scripts/
setup.sh   # Environment bootstrap (local Python)
Dockerfile   # Containerized Sigma CLI environment
Makefile     # One-command builds for common backends
requirements.txt

````

---

## Quick Start (Local Environment)

```bash
# 1) Create a Python virtualenv (recommended) and install tooling
python -m venv .venv && source .venv/bin/activate
make init

# 2) Build everything
make build-all

# Outputs stored in ./out/
ls -R out
````

---

## Quick Start (Docker Environment)

The included Dockerfile allows running Sigma CLI without installing dependencies locally.

### Build the Docker Image

```bash
docker build -t sigma-toolchain:latest .
```

### Run Sigma Commands with Docker

**Validate all rules**

```bash
docker run --rm -v "$PWD:/workspace" sigma-toolchain:latest \
  check rules/
```

**Convert Windows rules to Splunk SPL**

```bash
docker run --rm -v "$PWD:/workspace" sigma-toolchain:latest \
  convert -t splunk -p splunk_windows -p splunk_sysmon_acceleration \
  rules/windows/*.yml -o out/splunk_windows.spl
```

**Convert Windows rules to Microsoft Defender Advanced Hunting (KQL)**

```bash
docker run --rm -v "$PWD:/workspace" sigma-toolchain:latest \
  convert -t kusto -p windows -p sysmon \
  rules/windows/*.yml -o out/mde_windows.kql
```

**Convert Linux rules to Elastic**

```bash
docker run --rm -v "$PWD:/workspace" sigma-toolchain:latest \
  convert -t elasticsearch \
  rules/linux/*.yml -o out/elastic_linux.ndjson
```

**Convert macOS rules to Elastic**

```bash
docker run --rm -v "$PWD:/workspace" sigma-toolchain:latest \
  convert -t elasticsearch \
  rules/macos/*.yml -o out/elastic_macos.ndjson
```
---
## Using sigma-cli directly

You can also bypass the Makefile and run `sigma-cli` manually for ad-hoc conversions.

### Example: Windows Sysmon rule → Splunk SPL
```bash
sigma convert -t splunk \
  -p splunk_windows \
  -p splunk_sysmon_acceleration \
  rules/windows/example_rule.yml \
  -o out/splunk_rule.spl
````

### Example: Windows Sysmon rule → Microsoft Defender KQL

```bash
sigma convert -t kusto \
  -p windows \
  -p sysmon \
  rules/windows/example_rule.yml \
  -o out/mde_rule.kql
```

### Example: Linux auditd rule → Elastic

```bash
sigma convert -t es-qs \
  rules/linux/example_rule.yml \
  -o out/elastic_rule.ndjson
```
---

## Makefile Targets

### Local Builds

* `make build-splunk-windows` — Windows → Splunk SPL
* `make build-kusto-windows` — Windows → MDE Advanced Hunting KQL
* `make build-elastic-linux` — Linux → Elastic
* `make build-elastic-macos` — macOS → Elastic
* `make build-all` — Run all builds
* `make clean` — Remove `out/` directory

### Docker Builds

* `make docker-build` — Build Docker image
* `make docker-build-all` — Run all containerized builds

---

## Writing Sigma Rules (SOC Cheatsheet)

1. **Define a behavioral hypothesis** — What technique or activity are you detecting?
2. **Select the correct logsource** — `product`, `service`, `category` (ensure telemetry is enabled).
3. **Write `selection_*` blocks** — Positive indicators for your detection.
4. **Write `filter_*` blocks** — Remove noise and false positives.
5. **Set the `condition`** — Combine selections and filters logically.
6. **Add metadata** — `level`, `falsepositives`, MITRE ATT\&CK tags.
7. **Validate** — Run `sigma check` or Docker equivalent.
8. **Convert** — Use Makefile or Docker to output backend queries.
9. **Test** — Generate safe test events and tune rules.

---

## Field Mapping & Pipelines

* **Splunk Windows**: `splunk_windows` + `splunk_sysmon_acceleration`
* **MDE Advanced Hunting (KQL)**: `windows` + `sysmon`
* **Elastic**: No Windows/Sysmon-specific pipeline required

---

## Example Commands

```bash
# Validate rules locally
sigma check rules/

# Convert Windows rules to Splunk
make build-splunk-windows

# Convert Windows rules to MDE KQL
make build-kusto-windows

# Convert Linux rules to Elastic
make build-elastic-linux

# Convert macOS rules to Elastic
make build-elastic-macos
```

---

## References & Learning Resources

* [SigmaHQ Documentation](https://sigmahq.io/docs/) — Rule format, log sources, pipelines
* [pySigma Documentation](https://sigmahq-pysigma.readthedocs.io/) — Backends and processing pipelines
* [Microsoft Sysmon Documentation](https://learn.microsoft.com/sysinternals/downloads/sysmon) — Event IDs, schema
* [Windows Security Event 4688](https://learn.microsoft.com/windows/security/threat-protection/auditing/event-4688) — Process creation logging
* [Linux auditd Documentation](https://linux.die.net/man/8/auditd) — Field references
* [Elastic Common Schema (ECS)](https://www.elastic.co/guide/en/ecs/current/index.html)

---

## License

MIT License
© 2025 Aung Myat Thu (w01f)
