# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# OpenOCD script for Cheshire on qmtech_kintex7.

adapter driver jlink
adapter speed 2000
set irlen 5

source [file dirname [info script]]/openocd.common.tcl
