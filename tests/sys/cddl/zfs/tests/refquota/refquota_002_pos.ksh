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
# Copyright 2008 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.

. $STF_SUITE/include/libtest.kshlib

#################################################################################
#
# __stc_assertion_start
#
# ID: refquota_002_pos
#
# DESCRIPTION:
#	Quotas are enforced using the minimum of the two properties: 
#	quota & refquota
#
# STRATEGY:
#	1. Set value for quota and refquota. Quota less than refquota.
#	2. Creating file which should be limited by quota.
#	3. Switch the value of quota and refquota.
#	4. Verify file should be limited by refquota.
#
# TESTABILITY: explicit
#
# TEST_AUTOMATION_LEVEL: automated
#
# CODING_STATUS: COMPLETED (2007-11-02)
#
# __stc_assertion_end
#
################################################################################

verify_runnable "both"

function cleanup
{
	log_must $ZFS destroy -rf $TESTPOOL/$TESTFS
	log_must $ZFS create $TESTPOOL/$TESTFS
	log_must $ZFS set mountpoint=$TESTDIR $TESTPOOL/$TESTFS
}

log_assert "Quotas are enforced using the minimum of the two properties"
log_onexit cleanup

fs=$TESTPOOL/$TESTFS
log_must $ZFS set quota=15M $fs
log_must $ZFS set refquota=25M $fs

mntpnt=$(get_prop mountpoint $fs)
log_mustnot $MKFILE 20M $mntpnt/$TESTFILE
typeset -i used quota
used=$(get_prop used $fs)
quota=$(get_prop quota $fs)
((used = used / (1024 * 1024)))
((quota = quota / (1024 * 1024)))
if [[ $used -ne $quota ]]; then
	log_fail "ERROR: $used -ne $quota Quotas are not limited by quota"
fi

#
# Switch the value of them and try again
#
[ -f $mntpnt/$TESTFILE ] && log_must $RM $mntpnt/$TESTFILE
log_must $ZFS set quota=25M $fs
log_must $ZFS set refquota=15M $fs

log_mustnot $MKFILE 20M $mntpnt/$TESTFILE
used=$(get_prop used $fs)
refquota=$(get_prop refquota $fs)
((used = used / (1024 * 1024)))
((refquota = refquota / (1024 * 1024)))
if [[ $used -ne $refquota ]]; then
	log_fail "ERROR: $used -ne $refquota Quotas are not limited by refquota"
fi

log_pass "Quotas are enforced using the minimum of the two properties"
