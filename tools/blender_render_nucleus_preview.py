#!/usr/bin/env python3
"""Render a local Blender preview of the nucleus mesh assets."""

from __future__ import annotations

import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[1]
TOOLS_DIR = ROOT / "tools"
if str(TOOLS_DIR) not in sys.path:
    sys.path.insert(0, str(TOOLS_DIR))

import blender_generate_nucleus_mesh_assets as nucleus_assets


OUT_DIR = ROOT / "organelle_projects" / "04_nucleus" / "assets" / "preview"


def material(name: str, color: tuple[float, float, float, float], roughness: float = 0.68) -> bpy.types.Material:
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = color
        bsdf.inputs["Roughness"].default_value = roughness
        bsdf.inputs["Metallic"].default_value = 0.0
        if "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = (color[0] * 0.32, color[1] * 0.32, color[2] * 0.32, 1.0)
        if "Emission Strength" in bsdf.inputs:
            bsdf.inputs["Emission Strength"].default_value = 0.42
    return mat


def shell_point(angle: float, y_t: float, scale: float = 1.0) -> Vector:
    height = 112.0
    rx = 90.0
    rz = 72.0
    y = -height * 0.5 + y_t * height
    crown = math.sin(y_t * math.pi) ** 0.42
    vertical_taper = crown
    local_rx = nucleus_assets.organic_radius(angle, y_t, rx * vertical_taper * scale, 0.35)
    local_rz = nucleus_assets.organic_radius(angle, y_t, rz * vertical_taper * scale, 1.55)
    ripple_y = math.sin(angle * 4.0 + y_t * 7.0) * 2.2
    return Vector((math.cos(angle) * local_rx, y + ripple_y, math.sin(angle) * local_rz))


def add_pore(parent: bpy.types.Object, angle: float, y_t: float, scale: float, ring_mat: bpy.types.Material, center_mat: bpy.types.Material) -> None:
    position = shell_point(angle, y_t) * 1.018
    normal = Vector((position.x / 90.0, 0.15, position.z / 72.0)).normalized()
    rotation = normal.to_track_quat("Z", "Y").to_euler()

    bpy.ops.mesh.primitive_torus_add(
        major_radius=scale,
        minor_radius=max(0.5, scale * 0.16),
        major_segments=36,
        minor_segments=8,
        location=position + normal * 2.2,
        rotation=rotation,
    )
    ring = bpy.context.object
    ring.name = "PreviewNuclearPoreRing"
    ring.data.materials.append(ring_mat)
    ring.parent = parent
    bpy.ops.object.shade_smooth()

    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=24,
        ring_count=12,
        radius=scale * 0.62,
        location=position + normal * 2.5,
        rotation=rotation,
    )
    center = bpy.context.object
    center.name = "PreviewNuclearPoreDarkCenter"
    center.scale.z = 0.16
    center.data.materials.append(center_mat)
    center.parent = parent
    bpy.ops.object.shade_smooth()


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    nucleus_assets.clear_scene()

    shell_mat = material("Matte orange-red nuclear envelope", (1.0, 0.38, 0.16, 1.0))
    rim_mat = material("Pale pore protein rings", (1.0, 0.84, 0.56, 1.0))
    dark_mat = material("Dark pore openings", (0.11, 0.06, 0.16, 1.0))

    shell = nucleus_assets.create_shell("RenderedClosedNuclearEnvelope", 1.0)
    shell.data.materials.append(shell_mat)
    nucleus_assets.shade_smooth(shell)

    pore_specs = [
        (math.radians(38), 0.34, 5.2),
        (math.radians(52), 0.52, 4.8),
        (math.radians(70), 0.68, 4.2),
        (math.radians(18), 0.60, 3.8),
        (math.radians(92), 0.42, 4.4),
        (math.radians(128), 0.56, 3.8),
        (math.radians(-12), 0.44, 3.9),
        (math.radians(-42), 0.62, 3.7),
        (math.radians(182), 0.48, 3.9),
        (math.radians(242), 0.38, 3.6),
        (math.radians(292), 0.63, 3.8),
    ]
    for angle, y_t, pore_scale in pore_specs:
        add_pore(shell, angle, y_t, pore_scale, rim_mat, dark_mat)

    bpy.ops.object.light_add(type="AREA", location=(250, 150, 260))
    key = bpy.context.object
    key.name = "LargeSoftbox"
    key.data.energy = 3600
    key.data.size = 14

    bpy.ops.object.light_add(type="POINT", location=(-140, 100, 120))
    fill = bpy.context.object
    fill.name = "WarmFill"
    fill.data.energy = 760

    bpy.ops.object.camera_add(location=(220, 120, 220), rotation=(math.radians(62), 0, math.radians(42)))
    camera = bpy.context.object
    direction = Vector((0, 0, 0)) - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    camera.data.type = "ORTHO"
    camera.data.ortho_scale = 310
    bpy.context.scene.camera = camera

    bpy.context.scene.render.engine = "CYCLES"
    bpy.context.scene.cycles.samples = 80
    bpy.context.scene.view_settings.view_transform = "Standard"
    bpy.context.scene.view_settings.look = "Medium High Contrast"
    bpy.context.scene.view_settings.exposure = 0
    bpy.context.scene.view_settings.gamma = 1
    bpy.context.scene.render.resolution_x = 1600
    bpy.context.scene.render.resolution_y = 1000
    bpy.context.scene.world.color = (0.96, 0.98, 1.0)
    bpy.context.scene.render.filepath = str(OUT_DIR / "nucleus_closed_pores_preview.png")
    bpy.ops.render.render(write_still=True)
    print(bpy.context.scene.render.filepath)


if __name__ == "__main__":
    main()
