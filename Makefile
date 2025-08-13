PYTHON ?= python
SIGMA ?= sigma
OUTDIR ?= out

WIN_RULES := $(shell find rules/windows -name "*.yml")
LIN_RULES := $(shell find rules/linux -name "*.yml")
MAC_RULES := $(shell find rules/macos -name "*.yml")

.PHONY: init clean build-all build-splunk-windows build-kusto-windows build-elastic-linux build-elastic-macos

init:
	@./scripts/setup.sh

clean:
	@rm -rf $(OUTDIR)

build-splunk-windows:
	@mkdir -p $(OUTDIR)
	$(SIGMA) convert -t splunk -p splunk_windows -p splunk_sysmon_acceleration \
		$(WIN_RULES) -o $(OUTDIR)/splunk_windows.spl

build-kusto-windows:
	@mkdir -p $(OUTDIR)
	$(SIGMA) convert -t kusto -p windows -p sysmon \
		$(WIN_RULES) -o $(OUTDIR)/mde_windows.kql

build-elastic-linux:
	@mkdir -p $(OUTDIR)
	$(SIGMA) convert -t elasticsearch \
		$(LIN_RULES) -o $(OUTDIR)/elastic_linux.ndjson

build-elastic-macos:
	@mkdir -p $(OUTDIR)
	$(SIGMA) convert -t elasticsearch \
		$(MAC_RULES) -o $(OUTDIR)/elastic_macos.ndjson

build-all: build-splunk-windows build-kusto-windows build-elastic-linux build-elastic-macos
	@echo "Build complete. See $(OUTDIR)/"