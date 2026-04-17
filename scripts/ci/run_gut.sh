#!/usr/bin/env bash
# Runs the gut test suite and prints only the summary highlights on success.
# On failure, prints full output so the breaking test is visible.

set -eu

output=$(godot --headless -s addons/gut/gut_cmdln.gd 2>&1) && status=0 || status=$?

if [ $status -ne 0 ]; then
	printf '%s\n' "$output"
	exit $status
fi

printf '%s\n' "$output" | grep -E \
	'Total Coverage|Run Summary|^Scripts|^Tests|Passing Tests|Failing Tests|^Asserts|^Time|All tests passed|failing tests|ERROR|Orphans' \
	|| true
