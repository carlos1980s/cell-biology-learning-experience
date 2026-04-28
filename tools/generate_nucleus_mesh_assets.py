#!/usr/bin/env python3
"""Generate Blender-free OBJ mesh assets for the nucleus prototype.

The files generated here are meant to be imported through Roblox Studio's 3D
Importer, then wired into `src/CellExperience/Data/NucleusMeshAssets.lua`.
"""

from __future__ import annotations

import math
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "organelle_projects" / "04_nucleus" / "assets" / "mesh"


def organic_radius(angle: float, y_t: float, base: float, phase: float = 0.0) -> float:
    return base * (
        1.0
        + 0.065 * math.sin(angle * 3.0 + phase)
        + 0.04 * math.cos(angle * 5.0 - y_t * 2.2)
        + 0.03 * math.sin(angle * 8.0 + y_t * 3.5)
    )


def write_obj(path: Path, vertices: list[tuple[float, float, float]], faces: list[tuple[int, int, int]]) -> None:
    with path.open("w", encoding="utf-8") as handle:
        handle.write("# Generated organic nucleus mesh for Roblox import\n")
        for x, y, z in vertices:
            handle.write(f"v {x:.5f} {y:.5f} {z:.5f}\n")
        for a, b, c in faces:
            handle.write(f"f {a} {b} {c}\n")


def generate_shell() -> None:
    segments = 72
    rings = 22
    height = 108.0
    rx = 88.0
    rz = 70.0
    gate_half_width = 0.28
    gate_y_max = -3.0
    vertices: list[tuple[float, float, float]] = []
    index_map: dict[tuple[int, int], int] = {}

    for yi in range(rings + 1):
        y_t = yi / rings
        y = -height * 0.5 + y_t * height
        crown = math.sin(y_t * math.pi) ** 0.35
        vertical_taper = 0.72 + 0.28 * crown
        for si in range(segments):
            angle = (si / segments) * math.tau
            in_gate = abs(math.atan2(math.sin(angle), math.cos(angle))) < gate_half_width and y < gate_y_max
            if in_gate:
                continue
            local_rx = organic_radius(angle, y_t, rx * vertical_taper, 0.4)
            local_rz = organic_radius(angle, y_t, rz * vertical_taper, 1.7)
            ripple_y = math.sin(angle * 4.0 + y_t * 5.0) * 1.8
            vertices.append((math.cos(angle) * local_rx, y + ripple_y, math.sin(angle) * local_rz))
            index_map[(yi, si)] = len(vertices)

    faces: list[tuple[int, int, int]] = []
    for yi in range(rings):
        for si in range(segments):
            sj = (si + 1) % segments
            keys = ((yi, si), (yi + 1, si), (yi + 1, sj), (yi, sj))
            if all(key in index_map for key in keys):
                a, b, c, d = (index_map[key] for key in keys)
                faces.append((a, b, c))
                faces.append((a, c, d))

    write_obj(OUT_DIR / "nucleus_organic_shell_v1.obj", vertices, faces)


def generate_blob(path: Path, rx: float, ry: float, rz: float, phase: float) -> None:
    lon = 36
    lat = 18
    vertices: list[tuple[float, float, float]] = []
    index_map: dict[tuple[int, int], int] = {}

    for yi in range(lat + 1):
        v = yi / lat
        phi = -math.pi * 0.5 + v * math.pi
        for xi in range(lon):
            u = xi / lon
            theta = u * math.tau
            noise = 1.0 + 0.12 * math.sin(theta * 3.0 + phi * 2.0 + phase) + 0.07 * math.cos(theta * 5.0 - phi * 4.0)
            x = math.cos(phi) * math.cos(theta) * rx * noise
            y = math.sin(phi) * ry * (1.0 + 0.04 * math.sin(theta * 2.0))
            z = math.cos(phi) * math.sin(theta) * rz * noise
            vertices.append((x, y, z))
            index_map[(yi, xi)] = len(vertices)

    faces: list[tuple[int, int, int]] = []
    for yi in range(lat):
        for xi in range(lon):
            xj = (xi + 1) % lon
            a = index_map[(yi, xi)]
            b = index_map[(yi + 1, xi)]
            c = index_map[(yi + 1, xj)]
            d = index_map[(yi, xj)]
            faces.append((a, b, c))
            faces.append((a, c, d))

    write_obj(path, vertices, faces)


def generate_torus(path: Path) -> None:
    major_segments = 32
    minor_segments = 12
    major = 22.0
    minor = 3.2
    vertices: list[tuple[float, float, float]] = []

    for i in range(major_segments):
        theta = (i / major_segments) * math.tau
        for j in range(minor_segments):
            phi = (j / minor_segments) * math.tau
            radius = major + math.cos(phi) * minor * (1.0 + 0.08 * math.sin(theta * 5.0))
            x = math.sin(phi) * minor
            y = math.sin(theta) * radius
            z = math.cos(theta) * radius
            vertices.append((x, y, z))

    def idx(i: int, j: int) -> int:
        return (i % major_segments) * minor_segments + (j % minor_segments) + 1

    faces: list[tuple[int, int, int]] = []
    for i in range(major_segments):
        for j in range(minor_segments):
            a = idx(i, j)
            b = idx(i + 1, j)
            c = idx(i + 1, j + 1)
            d = idx(i, j + 1)
            faces.append((a, b, c))
            faces.append((a, c, d))

    write_obj(path, vertices, faces)


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    generate_shell()
    generate_blob(OUT_DIR / "nucleolus_core_v1.obj", 18.0, 33.0, 18.0, 0.2)
    generate_torus(OUT_DIR / "nuclear_pore_gate_ring_v1.obj")
    print(f"Generated OBJ mesh assets in {OUT_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
