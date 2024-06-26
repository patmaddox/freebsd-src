#!/usr/local/bin/ksh93 -p
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright 2007 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.

. $STF_SUITE/include/libtest.kshlib

###############################################################################
#
# __stc_assertion_start
#
# ID: zfs_share_010_neg
#
# DESCRIPTION:
# Verify that zfs share should fail with bad parameters
#
# STRATEGY:
# 1. Make an array of bad parameters
# 2. Use zfs share to share the filesystem
# 3. Verify that zfs share returns error
#
# TESTABILITY: explicit
#
# TEST_AUTOMATION_LEVEL: automated
#
# CODING_STATUS: COMPLETED (2007-07-9)
#
# __stc_assertion_end
#
################################################################################

verify_runnable "both"

log_assert "zfs share fails with bad parameters"

fs=$TESTPOOL/$TESTFS
set -A badargs "A" "-A" "-" "-x" "-?" "=" "-a *" "-a" 

for arg in "${badargs[@]}"; do
	log_mustnot eval "$ZFS share $arg $fs >/dev/null 2>&1" 
done 

#zfs share failed when missing arguments or invalid datasetname
for obj in "" "/$fs"; do
	log_mustnot eval "$ZFS share $obj >/dev/null 2>&1" 
done

log_pass "zfs share fails with bad parameters as expected."
