# Roblox V1 Depth Hold Controller Notes

This pass keeps native Roblox water swimming for horizontal movement and adds a small vertical stabilizer. The player should no longer drift upward or downward when they stop pressing vertical controls.

The installed LocalScript creates one attachment and one `VectorForce` on `HumanoidRootPart`. During active rise/dive input it assists vertical movement. After release it captures the current Y position and applies a damped hold around that point. V2 removes the constant upward gravity-canceling lift term, which was likely fighting Roblox water buoyancy and pushing the player toward the surface.

Mobile only gets small `UP` and `DOWN` buttons on the right side. There is no custom movement pad, so it should not overlap or compete with the native Roblox joystick.

Runtime verification still needs Play mode: check that the avatar can hover, rise with `UP`/`Space`/gamepad A, dive with `DOWN`/`Ctrl`/gamepad B, and still steer normally with native controls.
