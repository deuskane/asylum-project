#-----------------------------------------------------------------------------
# Title      : Makefile
# Project    : Asylum
#-----------------------------------------------------------------------------
# File       : Makefile
# Author     : Mathieu Rosiere
#-----------------------------------------------------------------------------
# Description: Makefile to manage ips
#-----------------------------------------------------------------------------
# Copyright (c) 2024
#-----------------------------------------------------------------------------
# Revisions  :
# Date        Version  Author   Description
# 2026-09-10  1.0      mrosiere	Created
#-----------------------------------------------------------------------------

#=============================================================================
# Variables
#=============================================================================
SHELL            = /bin/bash

DIR_IP           = $(CURDIR)/ip
DIR_LIB          = $(CURDIR)/lib/asylum-cores

GEN_COMPONENT    = python $(DIR_IP)/asylum-utils-generators/scripts/component.py
CORE_IMPORT      = $(DIR_LIB)/import.sh

NONREG_EXCLUDE   :=
NONREG_EXCLUDE   += asylum-soc-picosoc
NONREG_EXCLUDE   += asylum-processor-OpenBlaze8
NONREG_EXCLUDE   += asylum-processor-WardRV

# NONREG_LISTS contains the directories with a Makefile that are included in the non-regression pass.
NONREG_LISTS_ALL := $(patsubst %/,%,$(patsubst $(DIR_IP)/%,%,$(sort $(dir $(wildcard $(DIR_IP)/*/Makefile)))))
NONREG_LISTS     := $(filter-out $(NONREG_EXCLUDE), $(NONREG_LISTS_ALL))
#=============================================================================
# Rules
#=============================================================================

#--------------------------------------------------------
# help
# Display list of target
#--------------------------------------------------------
.PHONY : help
help :
	@echo "================| Variables"
	@echo "NONREG_EXCLUDE  : Elements excluded in the non-regression pass"
	@for item in $(NONREG_EXCLUDE); do \
	 echo "                  - $${item}"; \
	 done
	@echo "NONREG_LISTS_ALL: Elements included in the non-regression pass"
	@echo "                  (Only elements prefixed with + are in NONREG_LISTS)"
	@for item in $(NONREG_LISTS_ALL); do \
	 if echo "$(NONREG_LISTS)" | grep -qw "$$item"; then \
	 	 echo "                  + $${item}"; \
	 else \
	 	 echo "                  - $${item}"; \
	 fi; \
	 done
	@echo ""
	@echo "================| Rules"
	@echo "help            : Print this message"
	@echo "component       : Generate VHDL component packages for all IPs"
	@echo "import_dry_run  : Dry-run the FuseSoC library import"
	@echo "import          : Import / refresh FuseSoC cores into the local library"
	@echo "nonreg          : Run non regression campaign depending the NONREG_LIST variable"
	@echo "clean           : Run clean depending the NONREG_LIST_ALL variable"

#--------------------------------------------------------
# component
#--------------------------------------------------------
.PHONY : component
component :
	(cd $(DIR_IP)/asylum-infrastructure_icn/hdl/            ; $(GEN_COMPONENT) icn_pkg             --vhdl_path .)
	(cd $(DIR_IP)/asylum-communication-spi/hdl/             ; $(GEN_COMPONENT) spi_pkg             --vhdl_path .)
	(cd $(DIR_IP)/asylum-component-stack/hdl/               ; $(GEN_COMPONENT) stack_pkg           --vhdl_path .)
	(cd $(DIR_IP)/asylum-component-fifo/hdl/                ; $(GEN_COMPONENT) fifo_pkg            --vhdl_path .)
	(cd $(DIR_IP)/asylum-component-ram/hdl/                 ; $(GEN_COMPONENT) ram_pkg             --vhdl_path .)
	(cd $(DIR_IP)/asylum-soc-picosoc/hdl/                   ; $(GEN_COMPONENT) PicoSoC_pkg         --vhdl_path .)
	(cd $(DIR_IP)/asylum-communication-uart/hdl/            ; $(GEN_COMPONENT) uart_pkg            --vhdl_path .)
	(cd $(DIR_IP)/asylum-component-crc/hdl/                 ; $(GEN_COMPONENT) crc_pkg             --vhdl_path .)
	(cd $(DIR_IP)/asylum-system-gic/hdl/                    ; $(GEN_COMPONENT) GIC_pkg             --vhdl_path .)
	(cd $(DIR_IP)/asylum-processor-OpenBlaze8/hdl/          ; $(GEN_COMPONENT) OpenBlaze8_pkg      --vhdl_path .)
	(cd $(DIR_IP)/asylum-component-timer/hdl/               ; $(GEN_COMPONENT) timer_pkg           --vhdl_path .)
	(cd $(DIR_IP)/asylum-component-clock_divider/hdl/       ; $(GEN_COMPONENT) clock_divider_pkg   --vhdl_path .)
	(cd $(DIR_IP)/asylum-component-gpio/hdl/                ; $(GEN_COMPONENT) gpio_pkg            --vhdl_path . --vhdl_path legacy)
	(cd $(DIR_IP)/asylum-system-spinlock/hdl/               ; $(GEN_COMPONENT) spinlock_pkg        --vhdl_path .)
	(cd $(DIR_IP)/asylum-system-mailbox/hdl/                ; $(GEN_COMPONENT) mailbox_pkg         --vhdl_path .)
	(cd $(DIR_IP)/asylum-utils-generators/tools/regtool/hdl ; $(GEN_COMPONENT) csr_pkg             --vhdl_path .)
	(cd $(DIR_IP)/asylum-utils-pkg/hdl                      ; $(GEN_COMPONENT) ft_pkg              --vhdl_path . --file_filter "ft_*")
	(cd $(DIR_IP)/asylum-target-techmap/hdl/generic         ; $(GEN_COMPONENT) techmap_pkg         --vhdl_path .)

#--------------------------------------------------------
# import_dry_run
#--------------------------------------------------------
.PHONY : import_dry_run
import_dry_run:
	$(CORE_IMPORT) -s $(DIR_IP) -d $(DIR_LIB)

#--------------------------------------------------------
# import
#--------------------------------------------------------
.PHONY : import
import :
	$(CORE_IMPORT) -s $(DIR_IP) -d $(DIR_LIB) -r
	cd $(DIR_LIB) && ./dump.sh)
	cd $(DIR_LIB) && git add *)
	cd $(DIR_LIB) && git commit -am "Update Cores");

#--------------------------------------------------------
# nonreg
#--------------------------------------------------------
.PHONY : nonreg
nonreg : $(addprefix nonreg_,$(NONREG_LISTS))

$(addprefix nonreg_,$(NONREG_LISTS)) :
	@\
	cd "$(subst nonreg_,$(DIR_IP)/,$@)"; \
	echo "--------------------------------------------------------"; \
	echo "Remove previous fusesoc.conf"; \
	echo "--------------------------------------------------------"; \
	rm -f fusesoc.conf; \
	echo "--------------------------------------------------------"; \
	echo "Add fusesoc library $(DIR_LIB)"; \
	echo "--------------------------------------------------------"; \
	fusesoc library add lib $(DIR_LIB); \
	echo "--------------------------------------------------------"; \
	echo "Add fusesoc library $(DIR_IP)"; \
	echo "--------------------------------------------------------"; \
    fusesoc library add ip  $(DIR_IP); \
	echo "--------------------------------------------------------"; \
	echo "Run regression"; \
	echo "--------------------------------------------------------"; \
	$(MAKE) nonreg

#--------------------------------------------------------
# clean
#--------------------------------------------------------
.PHONY : clean
clean : $(addprefix clean_,$(NONREG_LISTS_ALL))

$(addprefix clean_,$(NONREG_LISTS_ALL)) :
	@\
	cd "$(subst clean_,$(DIR_IP)/,$@)"; \
	$(MAKE) clean