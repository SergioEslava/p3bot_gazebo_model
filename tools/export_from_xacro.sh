#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL_PARENT_DIR="$(dirname "$ROOT_DIR")"

find_p3bot_description_dir() {
  local candidate=""

  if [[ -n "${P3BOT_DESCRIPTION_DIR:-}" && -d "${P3BOT_DESCRIPTION_DIR}" ]]; then
    echo "${P3BOT_DESCRIPTION_DIR}"
    return 0
  fi

  candidate="${MODEL_PARENT_DIR}/p3bot_description"
  if [[ -d "$candidate" ]]; then
    echo "$candidate"
    return 0
  fi

  local probe="$ROOT_DIR"
  while [[ "$probe" != "/" ]]; do
    candidate="$probe/src/p3bot_description"
    if [[ -d "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
    probe="$(dirname "$probe")"
  done

  return 1
}

setup_ros_env_if_needed() {
  if command -v xacro >/dev/null 2>&1; then
    return 0
  fi

  local ros_setup=""
  if [[ -n "${ROS_DISTRO:-}" && -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]]; then
    ros_setup="/opt/ros/${ROS_DISTRO}/setup.bash"
  else
    ros_setup="$(ls -1 /opt/ros/*/setup.bash 2>/dev/null | head -n 1 || true)"
  fi

  if [[ -z "$ros_setup" ]]; then
    echo "xacro not found and no ROS setup.bash found under /opt/ros" >&2
    return 1
  fi

  # ROS setup scripts may reference unset vars; temporarily relax nounset.
  set +u
  source "$ros_setup"
  set -u
}

P3BOT_DESCRIPTION_DIR="$(find_p3bot_description_dir)" || {
  echo "p3bot_description not found. Set P3BOT_DESCRIPTION_DIR or place it nearby." >&2
  exit 1
}

setup_ros_env_if_needed

TMP_URDF="$(mktemp /tmp/p3bot_XXXXXX.urdf)"
TMP_XACRO="$(mktemp /tmp/p3bot_XXXXXX.urdf.xacro)"
trap 'rm -f "$TMP_URDF" "$TMP_XACRO"' EXIT

P3BOT_DESCRIPTION_ESCAPED="$(printf '%s\n' "$P3BOT_DESCRIPTION_DIR" | sed 's/[\/&]/\\&/g')"
sed "s#\$(find p3bot_description)#$P3BOT_DESCRIPTION_ESCAPED#g" \
  "$P3BOT_DESCRIPTION_DIR/urdf/P3Bot.urdf.xacro" > "$TMP_XACRO"

xacro "$TMP_XACRO" use_meshes:=true > "$TMP_URDF"
gz sdf -p "$TMP_URDF" | sed 's#model://p3bot_description/meshes/#meshes/#g' > "$ROOT_DIR/model.sdf"

echo "model.sdf regenerated at $ROOT_DIR/model.sdf"
