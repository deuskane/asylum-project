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
DIR_CORES        = $(CURDIR)/lib/asylum-cores

GEN_COMPONENT    = python $(DIR_IP)/asylum-utils-generators/scripts/component.py
CORE_IMPORT      = $(DIR_CORES)/import.sh

#=============================================================================
# Rules
#=============================================================================

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

.PHONY : import_dry_run
import_dry_run:
	$(CORE_IMPORT) -s $(DIR_IP) -d $(DIR_CORES)

.PHONY : import
import :
	$(CORE_IMPORT) -s $(DIR_IP) -d $(DIR_CORES) -r
	cd $(DIR_CORES) && ./dump.sh)
	cd $(DIR_CORES) && git add *)
	cd $(DIR_CORES) && git commit -am "Update Cores");

