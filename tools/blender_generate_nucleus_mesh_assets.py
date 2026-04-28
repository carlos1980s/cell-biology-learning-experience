#!/usr/bin/env python3
"""Generate organic nucleus OBJ assets using Blender's Python runtime.

Run with:

    blender --background --python tools/blender_generate_nucleus_mesh_assets.py
"""

from __future__ import annotations

import math
from pathlib import Path

import bpy


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "organelle_projects" / "04_nucleus" / "assets" / "mesh"


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()


def organic_radius(angle: float, y_t: float, base: float, phase: float) -> float:
    return base * (
        1.0
        + 0.11 * math.sin(angle * 2.0 + phase)
        + 0.075 * math.cos(angle * 5.0 - y_t * 3.5)
        + 0.045 * math.sin(angle * 9.0 + y_t * 5.0 + phase)
    )


def create_shell(name: str, scale: float) -> bpy.types.Object:
    segments = 48
    rings = 20
    height = 112.0
    rx = 90.0
    rz = 72.0
    vertices: list[tuple[float, float, float]] = [(0.0, -height * 0.5 * scale, 0.0)]
    faces: list[tuple[int, int, int]] = []
    index_map: dict[tuple[int, int], int] = {}

    for yi in range(1, rings):
        y_t = yi / rings
        y = -height * 0.5 + y_t * height
        crown = math.sin(y_t * math.pi) ** 0.42
        vertical_taper = crown

        for si in range(segments):
            angle = (si / segments) * math.tau
            local_rx = organic_radius(angle, y_t, rx * vertical_taper * scale, 0.35)
            local_rz = organic_radius(angle, y_t, rz * vertical_taper * scale, 1.55)
            ripple_y = math.sin(angle * 4.0 + y_t * 7.0) * 2.2
            vertices.append((math.cos(angle) * local_rx, (y + ripple_y) * scale, math.sin(angle) * local_rz))
            index_map[(yi, si)] = len(vertices) - 1

    top_index = len(vertices)
    vertices.append((0.0, height * 0.5 * scale, 0.0))

    for si in range(segments):
        sj = (si + 1) % segments
        faces.append((0, index_map[(1, sj)], index_map[(1, si)]))

    for yi in range(1, rings - 1):
        for si in range(segments):
            sj = (si + 1) % segments
            keys = ((yi, si), (yi + 1, si), (yi + 1, sj), (yi, sj))
            if all(key in index_map for key in keys):
                a, b, c, d = (index_map[key] for key in keys)
                faces.append((a, c, b))
                faces.append((a, d, c))

    for si in range(segments):
        sj = (si + 1) % segments
        faces.append((top_index, index_map[(rings - 1, si)], index_map[(rings - 1, sj)]))

    mesh = bpy.data.meshes.new(name + "_mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    return obj


def create_front_patch(name: str, scale: float) -> bpy.types.Object:
    rings = 14
    segments = 64
    rx = 128.0
    ry = 82.0
    normal_angle = math.radians(45)
    normal = (math.cos(normal_angle), math.sin(normal_angle))
    tangent = (-math.sin(normal_angle), math.cos(normal_angle))

    vertices: list[tuple[float, float, float]] = [(normal[0] * 70.0, 0.0, normal[1] * 70.0)]
    faces: list[tuple[int, int, int]] = []

    def idx(ring: int, segment: int) -> int:
        return 1 + (ring - 1) * segments + (segment % segments)

    for ri in range(1, rings + 1):
        r = ri / rings
        for si in range(segments):
            theta = (si / segments) * math.tau
            edge_noise = (
                1.0
                + 0.08 * math.sin(theta * 3.0 + 0.4)
                + 0.045 * math.cos(theta * 7.0 - 1.2)
            )
            lateral = math.cos(theta) * rx * r * edge_noise * scale
            vertical = math.sin(theta) * ry * r * edge_noise * scale
            dome = (1.0 - r * r) * 16.0
            x = normal[0] * (54.0 + dome) + tangent[0] * lateral
            z = normal[1] * (54.0 + dome) + tangent[1] * lateral
            y = vertical
            vertices.append((x, y, z))

    for si in range(segments):
        faces.append((0, idx(1, si), idx(1, si + 1)))

    for ri in range(1, rings):
        for si in range(segments):
            a = idx(ri, si)
            b = idx(ri + 1, si)
            c = idx(ri + 1, si + 1)
            d = idx(ri, si + 1)
            faces.append((a, b, c))
            faces.append((a, c, d))

    mesh = bpy.data.meshes.new(name + "_mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    return obj


def create_blob(name: str, rx: float, ry: float, rz: float, phase: float) -> bpy.types.Object:
    lon = 56
    lat = 28
    vertices: list[tuple[float, float, float]] = []
    faces: list[tuple[int, int, int]] = []

    def idx(y: int, x: int) -> int:
        return y * lon + (x % lon)

    for yi in range(lat + 1):
        v = yi / lat
        phi = -math.pi * 0.5 + v * math.pi
        for xi in range(lon):
            u = xi / lon
            theta = u * math.tau
            noise = 1.0 + 0.14 * math.sin(theta * 3.0 + phi * 2.0 + phase) + 0.08 * math.cos(theta * 6.0 - phi * 4.0)
            x = math.cos(phi) * math.cos(theta) * rx * noise
            y = math.sin(phi) * ry * (1.0 + 0.05 * math.sin(theta * 2.0 + phase))
            z = math.cos(phi) * math.sin(theta) * rz * noise
            vertices.append((x, y, z))

    for yi in range(lat):
        for xi in range(lon):
            a = idx(yi, xi)
            b = idx(yi + 1, xi)
            c = idx(yi + 1, xi + 1)
            d = idx(yi, xi + 1)
            faces.append((a, b, c))
            faces.append((a, c, d))

    mesh = bpy.data.meshes.new(name + "_mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    return obj


def create_torus() -> bpy.types.Object:
    bpy.ops.mesh.primitive_torus_add(major_segments=56, minor_segments=16, major_radius=22.0, minor_radius=3.4)
    obj = bpy.context.object
    obj.name = "nuclear_pore_gate_ring_v1"
    obj.data.name = "nuclear_pore_gate_ring_v1_mesh"
    obj.rotation_euler[1] = math.radians(90)
    return obj


def shade_smooth(obj: bpy.types.Object) -> None:
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.shade_smooth()
    obj.select_set(False)


def export_obj(obj: bpy.types.Object, path: Path) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.wm.obj_export(filepath=str(path), export_selected_objects=True, export_materials=False)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    clear_scene()

    assets = [
        (create_shell("nucleus_organic_shell_v1", 1.0), OUT_DIR / "nucleus_organic_shell_v1.obj"),
        (create_front_patch("nucleus_front_membrane_patch_v1", 1.0), OUT_DIR / "nucleus_front_membrane_patch_v1.obj"),
        (create_shell("nucleus_inner_lining_v1", 0.9), OUT_DIR / "nucleus_inner_lining_v1.obj"),
        (create_blob("nucleolus_core_v1", 24.0, 24.0, 22.0, 0.2), OUT_DIR / "nucleolus_core_v1.obj"),
        (create_torus(), OUT_DIR / "nuclear_pore_gate_ring_v1.obj"),
    ]

    for obj, path in assets:
        shade_smooth(obj)
        export_obj(obj, path)
        print(f"exported {path}")


if __name__ == "__main__":
    main()
