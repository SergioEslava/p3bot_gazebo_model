#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL_PARENT_DIR="$(dirname "$ROOT_DIR")"

WORLD_FILE="$ROOT_DIR/worlds/p3bot_test.world.sdf"
VERBOSE="4"
HEADLESS="false"
SKIP_EXPORT="false"
DRY_RUN="false"
EXTRA_ARGS=()

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [-- <extra gz sim args>]

Regenerates model.sdf from p3bot_description and launches Gazebo with the
latest robot model.

Options:
  --world <path>    World file to launch (default: $WORLD_FILE)
  --headless        Run server-only and start unpaused (-s -r)
  --verbose <n>     Gazebo verbosity level (default: $VERBOSE)
  --skip-export     Do not regenerate model.sdf before launching
  --dry-run         Print resolved command and exit
  -h, --help        Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --world)
      WORLD_FILE="$2"
      shift 2
      ;;
    --headless)
      HEADLESS="true"
      shift
      ;;
    --verbose)
      VERBOSE="$2"
      shift 2
      ;;
    --skip-export)
      SKIP_EXPORT="true"
      shift
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        EXTRA_ARGS+=("$1")
        shift
      done
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ ! -f "$WORLD_FILE" ]]; then
  echo "World file not found: $WORLD_FILE" >&2
  exit 1
fi

if [[ "$SKIP_EXPORT" != "true" ]]; then
  "$ROOT_DIR/tools/export_from_xacro.sh"
fi

export GZ_SIM_RESOURCE_PATH="$MODEL_PARENT_DIR${GZ_SIM_RESOURCE_PATH:+:$GZ_SIM_RESOURCE_PATH}"

CMD=(gz sim -v "$VERBOSE" "$WORLD_FILE")
if [[ "$HEADLESS" == "true" ]]; then
  CMD=(gz sim -s -r -v "$VERBOSE" "$WORLD_FILE")
fi

if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  CMD+=("${EXTRA_ARGS[@]}")
fi

echo "Launching: ${CMD[*]}"
echo "GZ_SIM_RESOURCE_PATH=$GZ_SIM_RESOURCE_PATH"

if [[ "$DRY_RUN" == "true" ]]; then
  exit 0
fi

exec "${CMD[@]}"
