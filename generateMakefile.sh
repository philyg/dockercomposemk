#! /bin/bash

# SPDX-FileCopyrightText: 2025 Philipp Grassl <philyg@linandot.net>
# SPDX-License-Identifier: MIT

VERSION=0.1.0
COMPOSEFLAGS="--progress plain"

TAB=$'\t'
LF=$'\n'

IMPLTGTS=""
IMPLHELP=""
IMPLCODE=""
IMPLHOOK=""
CUSTTGTS=""
CUSTHELP=""
CUSTHOOK=""

TGTPAD=15

DC="\${DC}"
SVC="\${SVC}"

function addImplTarget() {
	IMPLTGTS+=" $1"
}

function addImplHelp() {
	IMPLHELP+="$(printf "%-${TGTPAD}s %s" "$1:" "$2")$LF"
}

function addImplCode() {
	local CMD
	IMPLCODE+="real-$1-default:$LF"
	shift
	for CMD in "$@"; do
		IMPLCODE+="$TAB$CMD$LF"
	done
	IMPLCODE+="$LF"
}

function addImplHook() {
	IMPLHOOK+="pre-$1:$LF"
	IMPLHOOK+="post-$1:$LF"
	IMPLHOOK+="$1: pre-$1 real-$1 post-$1$LF"
	IMPLHOOK+=".PHONY: $1 pre-$1 real-$1-default post-$1$LF"
	IMPLHOOK+="$LF"
}

function addCustTarget() {
	CUSTTGTS+=" $1"
}

function addCustHelp() {
	CUSTHELP+="$(printf "%-15s %s" "$1:" "$2")$LF"
}

function addCustHook() {
	CUSTHOOK+="pre-$1:$LF"
	CUSTHOOK+="real-$1:$LF"
	CUSTHOOK+="post-$1:$LF"
	CUSTHOOK+="$1: pre-$1 real-$1 post-$1$LF"
	CUSTHOOK+=".PHONY: $1 pre-$1 real-$1 post-$1$LF"
	CUSTHOOK+="$LF"
}

function impl() {
	local TARGET
	TARGET=$1
	addImplTarget "$TARGET"
	addImplHook "$TARGET"
	addImplHelp "$TARGET" "$2"
	shift 2
	addImplCode "$TARGET" "$@"
}

function implSep() {
	IMPLHELP+="$LF"
}

function cust() {
	addCustTarget "$1"
	addCustHook "$1"
	addCustHelp "$1" "$2"
}

. targets.inc.sh


cat <<EOF

DC := @docker compose $COMPOSEFLAGS

define MAKEFILEUSAGE

This is a dockercomposemk v$VERSION Makefile. For more information see:
https://github.com/philyg/dockercomposemk

dockercomposemk is Copyright (c) 2025 Philipp Grassl
and released under the MIT license.


Available implemented targets:

$IMPLHELP

Targets to be implemented by overriding in Makefile-custom as real-[NAME]:

$CUSTHELP

All targets call pre-[NAME] and post-[NAME] targets for additional hooks in overriding
Makefile-custom files. The actual actions can also be changed by overriding real-[NAME].

Additionally, the following veriables can be defined in Makefile-custom:

SVC          The service to interact with when using the run and shell
             targets (uses first one in docker-compose.y*ml if undefined)

endef
export MAKEFILEUSAGE


all:
	@echo "\$\$MAKEFILEUSAGE"
.PHONY: all

EOF

echo '-include Makefile-custom'
echo ''
echo 'ifeq ($(SVC),)'
echo 'SVCPAT := "^[ \t]*(services:)?$$"'
echo 'SVC := $(shell cat docker-compose.y*ml | grep -Ev ${SVCPAT} | head -n 1 | cut -d ":" -f 1 | awk '"'"'{ print $1 }'"'"')'
echo 'endif'

cat <<EOF
real-%: phony real-%-default
	@true

phony: ;
.PHONY: phony

# Implemented targets
$IMPLCODE

# Hooks for implemented targets
$IMPLHOOK
# Forward-define targets for custom actions
$CUSTHOOK
EOF

