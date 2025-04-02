# SPDX-FileCopyrightText: 2025 Philipp Grassl <philyg@linandot.net>
# SPDX-License-Identifier: MIT

all:
	./generateMakefile.sh > docker-compose.mk

clean:
	rm -f docker-compose.mk

reformat:
	cat targets.inc.sh  \
		| awk 'BEGIN {FPAT = "([^ ]+)|(\"[^\"]+\")"}{printf "%-10s %-15s %-50s", $$1, $$2, $$3; for(i=4;i<=NF;i++){ printf " %s", $$i }; printf "\n" }' \
		| sed 's/[ ]\+$$//g' > targets.inc.tmp
	rm targets.inc.sh
	mv targets.inc.tmp targets.inc.sh

.PHONY: all clean
