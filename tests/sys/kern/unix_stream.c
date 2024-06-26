/*-
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Copyright (c) 2018 Alan Somers
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <sys/cdefs.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <signal.h>
#include <sys/socket.h>
#include <sys/un.h>

#include <stdio.h>

#include <atf-c.h>

static void
do_socketpair(int *sv)
{
	int s;

	s = socketpair(PF_LOCAL, SOCK_STREAM, 0, sv);
	ATF_REQUIRE_EQ(0, s);
	ATF_REQUIRE(sv[0] >= 0);
	ATF_REQUIRE(sv[1] >= 0);
	ATF_REQUIRE(sv[0] != sv[1]);
}

/* getpeereid(3) should work with stream sockets created via socketpair(2) */
ATF_TC_WITHOUT_HEAD(getpeereid);
ATF_TC_BODY(getpeereid, tc)
{
	int sv[2];
	uid_t real_euid, euid;
	gid_t real_egid, egid;

	real_euid = geteuid();
	real_egid = getegid();

	do_socketpair(sv);

	ATF_REQUIRE_EQ(0, getpeereid(sv[0], &euid, &egid));
	ATF_CHECK_EQ(real_euid, euid);
	ATF_CHECK_EQ(real_egid, egid);

	ATF_REQUIRE_EQ(0, getpeereid(sv[1], &euid, &egid));
	ATF_CHECK_EQ(real_euid, euid);
	ATF_CHECK_EQ(real_egid, egid);

	close(sv[0]);
	close(sv[1]);
}

/* Sending zero bytes should succeed (once regressed in aba79b0f4a3f). */
ATF_TC_WITHOUT_HEAD(send_0);
ATF_TC_BODY(send_0, tc)
{
	int sv[2];

	do_socketpair(sv);
	ATF_REQUIRE(send(sv[0], sv, 0, 0) == 0);
	close(sv[0]);
	close(sv[1]);
}


ATF_TP_ADD_TCS(tp)
{
	ATF_TP_ADD_TC(tp, getpeereid);
	ATF_TP_ADD_TC(tp, send_0);

	return atf_no_error();
}
