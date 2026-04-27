#!/usr/bin/env python3
"""Generate deterministic Luau geometry specs for the cell experience."""

from __future__ import annotations

import math
import random
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "src" / "CellExperience" / "Data" / "Generated"


def clamp(value: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, value))


def length(vector: tuple[float, float, float]) -> float:
    return math.sqrt(sum(component * component for component in vector))


def normalize(vector: tuple[float, float, float]) -> tuple[float, float, float]:
    mag = length(vector)
    if mag < 1e-6:
        return (0.0, 1.0, 0.0)
    return tuple(component / mag for component in vector)


def add(a: tuple[float, float, float], b: tuple[float, float, float]) -> tuple[float, float, float]:
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def sub(a: tuple[float, float, float], b: tuple[float, float, float]) -> tuple[float, float, float]:
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def mul(vector: tuple[float, float, float], scale: float) -> tuple[float, float, float]:
    return (vector[0] * scale, vector[1] * scale, vector[2] * scale)


def cross(a: tuple[float, float, float], b: tuple[float, float, float]) -> tuple[float, float, float]:
    return (
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    )


def dotted(a: tuple[float, float, float], b: tuple[float, float, float]) -> float:
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def basis_from_normal(normal: tuple[float, float, float], twist: float) -> tuple[tuple[float, float, float], tuple[float, float, float]]:
    up = normalize(normal)
    seed = (0.0, 1.0, 0.0) if abs(up[1]) < 0.94 else (1.0, 0.0, 0.0)
    tangent = normalize(cross(seed, up))
    bitangent = normalize(cross(up, tangent))
    ct = math.cos(twist)
    st = math.sin(twist)
    rotated_tangent = normalize(add(mul(tangent, ct), mul(bitangent, st)))
    rotated_bitangent = normalize(cross(up, rotated_tangent))
    return rotated_tangent, rotated_bitangent


def format_number(value: float) -> str:
    if abs(value) < 1e-9:
        value = 0.0
    text = f"{value:.4f}"
    text = text.rstrip("0").rstrip(".")
    if text == "-0":
        text = "0"
    if "." not in text:
        text += ".0"
    return text


def to_lua(value, indent: int = 0) -> str:
    pad = "    " * indent
    next_pad = "    " * (indent + 1)

    if isinstance(value, dict):
        items = []
        for key, item in value.items():
            if isinstance(key, str) and key.isidentifier():
                rendered_key = key
            else:
                rendered_key = f"[{to_lua(key)}]"
            items.append(f"{next_pad}{rendered_key} = {to_lua(item, indent + 1)}")
        return "{\n" + ",\n".join(items) + f"\n{pad}" + "}"

    if isinstance(value, (list, tuple)):
        if not value:
            return "{}"
        items = [f"{next_pad}{to_lua(item, indent + 1)}" for item in value]
        return "{\n" + ",\n".join(items) + f"\n{pad}" + "}"

    if isinstance(value, float):
        return format_number(value)

    if isinstance(value, int):
        return format_number(float(value))

    if isinstance(value, str):
        return repr(value).replace("'", '"')

    if value is True:
        return "true"

    if value is False:
        return "false"

    if value is None:
        return "nil"

    raise TypeError(f"Unsupported value: {value!r}")


def write_module(path: Path, table_name: str, payload: dict) -> None:
    text = f"local {table_name} = {to_lua(payload)}\n\nreturn {table_name}\n"
    path.write_text(text)


def ellipse_surface(normal: tuple[float, float, float], scale: tuple[float, float, float]) -> tuple[float, float, float]:
    adjusted = (normal[0] * scale[0], normal[1] * scale[1], normal[2] * scale[2])
    return normalize(adjusted)


def generate_membrane() -> dict:
    rng = random.Random(4102)
    golden_angle = math.pi * (3.0 - math.sqrt(5.0))

    lipids = []
    lipid_count = 1800
    scale = (1.0, 0.94, 1.0)
    for index in range(lipid_count):
        y = 1.0 - 2.0 * ((index + 0.5) / lipid_count)
        radius = math.sqrt(max(0.0, 1.0 - y * y))
        theta = index * golden_angle + math.sin(index * 0.19) * 0.18
        normal = ellipse_surface(
            normalize((math.cos(theta) * radius, y, math.sin(theta) * radius)),
            scale,
        )
        lipids.append(
            {
                "n": list(normal),
                "twist": theta % (math.pi * 2.0),
                "head": 1.75 + rng.random() * 0.55,
                "tail": 4.2 + rng.random() * 1.6,
                "spread": 1.3 + rng.random() * 0.7,
                "sway": rng.uniform(-0.38, 0.38),
            }
        )

    proteins = []
    for index in range(92):
        y = -0.92 + 1.84 * ((index + 0.5) / 92.0)
        radius = math.sqrt(max(0.0, 1.0 - y * y))
        theta = index * golden_angle + rng.uniform(-0.14, 0.14)
        normal = ellipse_surface(
            normalize((math.cos(theta) * radius, y, math.sin(theta) * radius)),
            scale,
        )
        proteins.append(
            {
                "n": list(normal),
                "twist": rng.uniform(0.0, math.pi * 2.0),
                "height": 7.5 + rng.random() * 6.0,
                "radius": 2.1 + rng.random() * 1.8,
                "petals": 2 + (index % 3),
                "channelRadius": 1.1 + rng.random() * 0.9,
            }
        )

    receptors = []
    for index in range(60):
        y = -0.82 + 1.64 * ((index + 0.5) / 60.0)
        radius = math.sqrt(max(0.0, 1.0 - y * y))
        theta = index * golden_angle + 0.33
        normal = ellipse_surface(
            normalize((math.cos(theta) * radius, y, math.sin(theta) * radius)),
            scale,
        )
        receptors.append(
            {
                "n": list(normal),
                "twist": rng.uniform(0.0, math.pi * 2.0),
                "stem": 4.8 + rng.random() * 2.6,
                "clusters": 3 + (index % 4),
                "cap": 2.4 + rng.random() * 1.2,
            }
        )

    fibers = []
    for index in range(42):
        start_theta = rng.uniform(0.0, math.pi * 2.0)
        end_theta = start_theta + rng.uniform(1.1, 2.6)
        start_y = rng.uniform(-0.72, 0.72)
        end_y = clamp(start_y + rng.uniform(-0.5, 0.5), -0.82, 0.82)
        radius = 150.0 + rng.uniform(-22.0, 12.0)
        points = []
        for step in range(6):
            alpha = step / 5.0
            theta = start_theta + (end_theta - start_theta) * alpha
            y = start_y + (end_y - start_y) * alpha + math.sin(alpha * math.pi * 2.0 + index * 0.4) * 0.12
            radial = math.sqrt(max(0.0, 1.0 - y * y))
            direction = normalize((math.cos(theta) * radial, y, math.sin(theta) * radial))
            inward = 0.55 + alpha * 0.35
            points.append([direction[0] * radius * inward, direction[1] * radius * inward, direction[2] * radius * inward])
        fibers.append({"points": points, "radius": 0.55 + rng.random() * 0.7})

    floatingParticles = []
    for index in range(120):
        direction = normalize(
            (
                rng.uniform(-1.0, 1.0),
                rng.uniform(-0.9, 0.9),
                rng.uniform(-1.0, 1.0),
            )
        )
        distance = rng.uniform(35.0, 165.0)
        floatingParticles.append(
            {
                "offset": [direction[0] * distance, direction[1] * distance * 0.92, direction[2] * distance],
                "size": 1.4 + rng.random() * 2.4,
                "kind": "vesicle" if index % 5 == 0 else "particle",
            }
        )

    return {
        "lipids": lipids,
        "proteins": proteins,
        "receptors": receptors,
        "cytoskeletonFibers": fibers,
        "floatingParticles": floatingParticles,
    }


def curve_points(rng: random.Random, center: tuple[float, float, float], radius_xy: tuple[float, float], turns: float, amplitude: float, point_count: int, tilt: float) -> list[list[float]]:
    points = []
    base = rng.uniform(0.0, math.pi * 2.0)
    for index in range(point_count):
        t = index / max(1, point_count - 1)
        angle = base + turns * math.pi * 2.0 * t
        x = math.cos(angle) * radius_xy[0] + math.sin(t * math.pi * 4.0 + tilt) * amplitude
        y = math.sin(t * math.pi * 2.0 + tilt) * amplitude * 0.55
        z = math.sin(angle) * radius_xy[1]
        points.append([center[0] + x, center[1] + y, center[2] + z])
    return points


def generate_nucleus() -> dict:
    rng = random.Random(8127)
    nucleus_center = (-10.0, 126.0, 8.0)
    scale = (1.0, 0.86, 0.95)
    golden_angle = math.pi * (3.0 - math.sqrt(5.0))

    pores = []
    for index in range(72):
        y = -0.88 + 1.76 * ((index + 0.5) / 72.0)
        radius = math.sqrt(max(0.0, 1.0 - y * y))
        theta = index * golden_angle + rng.uniform(-0.08, 0.08)
        normal = ellipse_surface(
            normalize((math.cos(theta) * radius, y, math.sin(theta) * radius)),
            scale,
        )
        pores.append({"n": list(normal), "twist": theta % (math.pi * 2.0)})

    chromatin = []
    for index in range(10):
        ring = 18.0 + index * 1.4
        points = curve_points(rng, nucleus_center, (ring, ring * 0.82), 0.85 + index * 0.07, 6.5, 13, index * 0.4)
        chromatin.append(
            {
                "points": points,
                "bead": 1.2 + (index % 3) * 0.35,
                "radius": 0.95 + (index % 4) * 0.18,
            }
        )

    rough_er = []
    for index in range(14):
        ring_center = (
            nucleus_center[0] + math.cos(index * 0.54) * (34.0 + index * 1.8),
            nucleus_center[1] + math.sin(index * 0.61) * 11.0,
            nucleus_center[2] + math.sin(index * 0.52) * (28.0 + index * 1.7),
        )
        rough_er.append(
            {
                "points": curve_points(rng, ring_center, (26.0 + index * 1.5, 14.0 + index * 0.9), 0.65, 6.0, 11, index * 0.3),
                "width": 6.4 + (index % 4) * 0.9,
                "thickness": 1.7 + (index % 3) * 0.3,
                "ribosomeStep": 2 + (index % 3),
            }
        )

    smooth_er = []
    for index in range(11):
        branch_center = (
            nucleus_center[0] - math.cos(index * 0.67) * (38.0 + index * 1.9),
            nucleus_center[1] + math.sin(index * 0.77) * 12.0,
            nucleus_center[2] + math.sin(index * 0.49) * (24.0 + index * 2.0),
        )
        smooth_er.append(
            {
                "points": curve_points(rng, branch_center, (20.0 + index * 1.5, 12.0 + index * 0.9), 0.8, 4.0, 10, index * 0.5),
                "radius": 2.1 + (index % 4) * 0.35,
            }
        )

    free_ribosomes = []
    for _ in range(180):
        direction = normalize(
            (
                rng.uniform(-1.0, 1.0),
                rng.uniform(-0.7, 0.7),
                rng.uniform(-1.0, 1.0),
            )
        )
        distance = rng.uniform(58.0, 108.0)
        offset = [direction[0] * distance, direction[1] * distance * 0.92, direction[2] * distance]
        free_ribosomes.append({"offset": offset, "size": 1.3 + rng.random() * 0.6})

    nucleolus_clusters = []
    nucleolus_center = (-2.0, 122.0, 11.0)
    for _ in range(40):
        direction = normalize(
            (
                rng.uniform(-1.0, 1.0),
                rng.uniform(-1.0, 1.0),
                rng.uniform(-1.0, 1.0),
            )
        )
        distance = rng.uniform(4.0, 10.0)
        nucleolus_clusters.append({"position": [nucleolus_center[0] + direction[0] * distance, nucleolus_center[1] + direction[1] * distance, nucleolus_center[2] + direction[2] * distance], "size": 1.6 + rng.random() * 1.2})

    return {
        "nucleusCenter": list(nucleus_center),
        "pores": pores,
        "chromatin": chromatin,
        "roughER": rough_er,
        "smoothER": smooth_er,
        "freeRibosomes": free_ribosomes,
        "nucleolusCenter": list(nucleolus_center),
        "nucleolusClusters": nucleolus_clusters,
    }


def generate_energy() -> dict:
    rng = random.Random(2468)
    mitochondria = []
    anchors = [
        ((-118.0, 146.0, -70.0), (1.0, 0.1, 0.22), (25.0, 18.0, 56.0)),
        ((82.0, 82.0, 86.0), (-0.72, 0.22, 0.66), (22.0, 17.0, 48.0)),
        ((112.0, 168.0, -58.0), (0.34, -0.12, 0.93), (24.0, 17.0, 50.0)),
        ((-70.0, 102.0, 110.0), (-0.44, 0.18, 0.88), (20.0, 15.0, 42.0)),
    ]
    for center, axis, size in anchors:
        cristae = []
        for index in range(10):
            cristae.append({"offset": -0.42 + index * 0.09 + rng.uniform(-0.01, 0.01), "wave": rng.uniform(-1.0, 1.0), "width": 0.22 + rng.random() * 0.12})
        mitochondria.append({"center": list(center), "axis": list(normalize(axis)), "size": list(size), "cristae": cristae})

    golgi = []
    golgi_center = (48.0, 110.0, -84.0)
    for index in range(8):
        points = []
        base_angle = -0.7 + index * 0.15
        for step in range(12):
            t = step / 11.0
            arc = base_angle + t * 1.5
            x = golgi_center[0] + math.cos(arc) * (18.0 + index * 2.0)
            y = golgi_center[1] + (index - 3.5) * 3.5 + math.sin(t * math.pi) * 1.8
            z = golgi_center[2] + math.sin(arc) * (11.0 + index * 1.3)
            points.append([x, y, z])
        golgi.append({"points": points, "width": 7.0 + index * 0.5})

    lysosomes = []
    for position in [
        (-96.0, 72.0, 82.0),
        (98.0, 54.0, 30.0),
        (118.0, 150.0, 46.0),
        (-60.0, 164.0, 96.0),
        (-136.0, 128.0, -20.0),
        (134.0, 118.0, -18.0),
        (18.0, 60.0, -112.0),
        (-12.0, 174.0, -104.0),
    ]:
        lysosomes.append({"position": list(position), "size": 8.0 + rng.random() * 6.0})

    vesicles = []
    for index in range(26):
        theta = index * 0.58
        radius = 72.0 + (index % 5) * 18.0 + rng.uniform(-7.0, 7.0)
        height = math.sin(index * 0.8) * 42.0
        vesicles.append(
            {
                "position": [
                    math.cos(theta) * radius + 14.0,
                    116.0 + height,
                    math.sin(theta) * radius - 18.0,
                ],
                "size": 4.2 + rng.random() * 5.4,
                "cargo": 1 if index % 3 == 0 else 0,
            }
        )

    return {
        "mitochondria": mitochondria,
        "golgiCisternae": golgi,
        "golgiCenter": list(golgi_center),
        "lysosomes": lysosomes,
        "vesicles": vesicles,
    }


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    membrane = generate_membrane()
    quarter = len(membrane["lipids"]) // 4
    write_module(OUT_DIR / "MembraneLipidsA.lua", "MembraneLipidsA", {"lipids": membrane["lipids"][:quarter]})
    write_module(OUT_DIR / "MembraneLipidsB.lua", "MembraneLipidsB", {"lipids": membrane["lipids"][quarter : quarter * 2]})
    write_module(OUT_DIR / "MembraneLipidsC.lua", "MembraneLipidsC", {"lipids": membrane["lipids"][quarter * 2 : quarter * 3]})
    write_module(OUT_DIR / "MembraneLipidsD.lua", "MembraneLipidsD", {"lipids": membrane["lipids"][quarter * 3 :]})
    write_module(
        OUT_DIR / "MembraneProteins.lua",
        "MembraneProteins",
        {
            "proteins": membrane["proteins"],
            "receptors": membrane["receptors"],
        },
    )
    write_module(
        OUT_DIR / "MembraneInterior.lua",
        "MembraneInterior",
        {
            "cytoskeletonFibers": membrane["cytoskeletonFibers"],
            "floatingParticles": membrane["floatingParticles"],
        },
    )
    write_module(OUT_DIR / "NucleusSpec.lua", "NucleusSpec", generate_nucleus())
    write_module(OUT_DIR / "EnergySpec.lua", "EnergySpec", generate_energy())
    print("Generated membrane, nucleus, and energy spec modules.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
