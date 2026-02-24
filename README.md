# p3bot_gazebo_model

Fuel-ready Gazebo model for P3Bot.

## Contents

- `model.config`: Gazebo Fuel metadata
- `model.sdf`: SDF model definition (Gazebo Harmonic/Jazzy compatible)
- `meshes/`: Visual meshes used by the model
- `worlds/p3bot_test.world.sdf`: Minimal local world to test model loading
- `tools/export_from_xacro.sh`: Regenerates `model.sdf` from `p3bot_description`
- `tools/launch_latest_gazebo.sh`: Regenerates and launches Gazebo in one step

## Local test

```bash
cd <workspace_root>
GZ_SIM_RESOURCE_PATH=$PWD/src gz sim -v 4 ./src/p3bot_gazebo_model/worlds/p3bot_test.world.sdf
```

## Regenerate model.sdf from ROS xacro

```bash
cd <workspace_root>
./src/p3bot_gazebo_model/tools/export_from_xacro.sh
```

## Launch Gazebo with latest robot (recommended)

```bash
cd <workspace_root>
./src/p3bot_gazebo_model/tools/launch_latest_gazebo.sh
```

Headless mode:

```bash
./src/p3bot_gazebo_model/tools/launch_latest_gazebo.sh --headless
```

## Notes

- This model is focused on geometry and kinematics portability for Fuel.
- ROS 2 control plugins and simulated sensors should live in a simulation-specific package/repo layer, not in the Fuel base model.
- `export_from_xacro.sh` auto-detects `p3bot_description` in common layouts (`../p3bot_description` or `<workspace>/src/p3bot_description`).
- You can override model source path with `P3BOT_DESCRIPTION_DIR=/absolute/path/to/p3bot_description`.
