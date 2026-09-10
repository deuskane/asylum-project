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

COMPONENT        = $(CURDIR)/asylum-utils-generators/scripts/component.py

DIR_IP           = $(CURDIR)
DIR_CORES        = $(CURDIR)/../lib/asylum-cores

#=============================================================================
# Rules
#=============================================================================

.PHONY : component
component :
	(cd ./asylum-infrastructure_icn/hdl/            ; python $(COMPONENT) icn_pkg             --vhdl_path .)
	(cd ./asylum-communication-spi/hdl/             ; python $(COMPONENT) spi_pkg             --vhdl_path .)
	(cd ./asylum-component-stack/hdl/               ; python $(COMPONENT) stack_pkg           --vhdl_path .)
	(cd ./asylum-component-fifo/hdl/                ; python $(COMPONENT) fifo_pkg            --vhdl_path .)
	(cd ./asylum-component-ram/hdl/                 ; python $(COMPONENT) ram_pkg             --vhdl_path .)
	(cd ./asylum-soc-picosoc/hdl/                   ; python $(COMPONENT) PicoSoC_pkg         --vhdl_path .)
	(cd ./asylum-communication-uart/hdl/            ; python $(COMPONENT) uart_pkg            --vhdl_path .)
	(cd ./asylum-component-crc/hdl/                 ; python $(COMPONENT) crc_pkg             --vhdl_path .)
	(cd ./asylum-system-gic/hdl/                    ; python $(COMPONENT) GIC_pkg             --vhdl_path .)
	(cd ./asylum-processor-OpenBlaze8/hdl/          ; python $(COMPONENT) OpenBlaze8_pkg      --vhdl_path .)
	(cd ./asylum-component-timer/hdl/               ; python $(COMPONENT) timer_pkg           --vhdl_path .)
	(cd ./asylum-component-clock_divider/hdl/       ; python $(COMPONENT) clock_divider_pkg   --vhdl_path .)
	(cd ./asylum-component-gpio/hdl/                ; python $(COMPONENT) gpio_pkg            --vhdl_path . --vhdl_path legacy)
	(cd ./asylum-system-spinlock/hdl/               ; python $(COMPONENT) spinlock_pkg        --vhdl_path .)
	(cd ./asylum-system-mailbox/hdl/                ; python $(COMPONENT) mailbox_pkg         --vhdl_path .)
	(cd ./asylum-utils-generators/tools/regtool/hdl ; python $(COMPONENT) csr_pkg             --vhdl_path .)
	(cd ./asylum-utils-pkg/hdl                      ; python $(COMPONENT) ft_pkg              --vhdl_path . --file_filter "ft_*")
	(cd ./asylum-target-techmap/hdl/generic         ; python $(COMPONENT) techmap_pkg         --vhdl_path .)

.PHONY : import_dry_run
import_dry_run:
	$(DIR_CORES)/import.sh -s $(DIR_IP) -d $(DIR_CORES)

.PHONY : import
import :
	$(DIR_CORES)/import.sh -s $(DIR_IP) -d $(DIR_CORES) -r
	cd $(DIR_CORES) && ./dump.sh)
	cd $(DIR_CORES) && git add *)
	cd $(DIR_CORES) && git commit -am "Update Cores");

