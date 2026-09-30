#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
entrypoint="$repo_root/rootfilesystem/entrypoint.sh"
temporary_directory=$(mktemp -d)
manager_pid=

cleanup() {
    trap - EXIT HUP INT TERM
    if [ -n "$manager_pid" ]; then
        kill -TERM "$manager_pid" 2>/dev/null || true
        wait "$manager_pid" 2>/dev/null || true
    fi
    rm -rf "$temporary_directory"
}
trap cleanup EXIT HUP INT TERM

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

if ENABLE_SERVER=0 ENABLE_WORKER=0 ENABLE_AUTORELOAD=0 sh "$entrypoint" app; then
    :
else
    fail 'app mode with all services disabled should exit successfully'
fi

if sh "$entrypoint" sh -c 'exit 7'; then
    fail 'custom command should preserve its exit code'
else
    command_exit_code=$?
    [ "$command_exit_code" -eq 7 ] || fail 'custom command exit code was not preserved'
fi

mkdir "$temporary_directory/bin"
cat > "$temporary_directory/bin/su-exec" <<'EOF'
#!/bin/sh
shift
exec "$@"
EOF
cat > "$temporary_directory/bin/php" <<'EOF'
#!/bin/sh
printf 'start\n' >> "$ENTRYPOINT_TEST_LOG"
run_count=$(wc -l < "$ENTRYPOINT_TEST_LOG")
if [ "$run_count" -eq 1 ]; then
    exit 1
fi

stop_service() {
    kill -TERM "$child_pid" 2>/dev/null || true
    wait "$child_pid" 2>/dev/null || true
    printf 'stopped\n' > "$ENTRYPOINT_TEST_STOPPED"
    exit 0
}
trap stop_service TERM INT
sleep 30 &
child_pid=$!
wait "$child_pid"
EOF
chmod +x "$temporary_directory/bin/su-exec" "$temporary_directory/bin/php"

export ENTRYPOINT_TEST_LOG="$temporary_directory/service.log"
export ENTRYPOINT_TEST_STOPPED="$temporary_directory/stopped"
: > "$ENTRYPOINT_TEST_LOG"
PATH="$temporary_directory/bin:$PATH" ENABLE_SERVER=1 ENABLE_WORKER=0 ENABLE_AUTORELOAD=0 sh "$entrypoint" app &
manager_pid=$!

attempt=0
while [ "$(wc -l < "$ENTRYPOINT_TEST_LOG" 2>/dev/null || printf '0')" -lt 2 ]; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 50 ]; then
        fail 'server did not restart after its first exit'
    fi
    sleep 0.1
done

kill -TERM "$manager_pid"
if wait "$manager_pid"; then
    manager_pid=
else
    fail 'entrypoint did not exit cleanly after SIGTERM'
fi
[ -f "$ENTRYPOINT_TEST_STOPPED" ] || fail 'server process did not handle SIGTERM'

printf 'PASS: entrypoint lifecycle tests\n'
