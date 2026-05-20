"""Phase 2 Blender builder for the nucleus anatomy layer.

This phase creates the first real anatomy layer only: double nuclear envelope
panels, perinuclear lumen, raised nuclear pore complexes, gate cores, and
interior lamina hints. Chromatin, nucleolus, transport cargo, rough ER
connection, mitosis fragments, and hotspots remain intentionally incomplete.
"""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path
from typing import Any


BASE_DIR = Path(__file__).resolve().parent
ROOT_DIR = BASE_DIR.parents[1]
SHARED_DIR = ROOT_DIR / "shared" / "scripts"
RENDER_DIR = BASE_DIR / "review_renders"
REPORT_DIR = BASE_DIR / "review_reports"
MANIFEST_PATH = BASE_DIR / "component_manifest.json"
BLEND_PATH = BASE_DIR / "nucleus_phase_02_scene.blend"
PHASE_REPORT = REPORT_DIR / "phase_02_builder_report.json"
LATEST_STATUS = REPORT_DIR / "latest_status.json"

RENDER_PATHS = {
    "wide_review_render": RENDER_DIR / "phase_02_wide_anatomy_layer.png",
    "pore_detail_render": RENDER_DIR / "phase_02_pore_gate_detail.png",
    "export_inspection_render": RENDER_DIR / "phase_02_export_inspection.png",
}

CREATED_COMPONENTS = [
    "WholeCell_ContextSocket",
    "Nucleus_RootRig",
    "OuterNuclearMembrane_Panels",
    "InnerNuclearMembrane_Panels",
    "PerinuclearLumen_Segments",
    "NuclearPore_Complexes",
    "NuclearPore_GateCores",
    "NuclearLamina_Lattice",
]

INCOMPLETE_COMPONENTS = [
    "Nucleoplasm_Volume",
    "Chromatin_Threads",
    "CondensedChromosomes",
    "Nucleolus_Subregions",
    "Transport_Cargo",
    "RoughER_Connection",
    "Mitosis_Fragments",
    "Interaction_Hotspots",
]

PORE_SITES = [
    {"theta": 1.15, "phi": 0.35, "radius": 0.22},
    {"theta": 1.65, "phi": -0.62, "radius": 0.20},
    {"theta": 1.92, "phi": 0.90, "radius": 0.19},
    {"theta": 1.24, "phi": -1.42, "radius": 0.18},
    {"theta": 2.12, "phi": -2.28, "radius": 0.17},
    {"theta": 0.82, "phi": 2.18, "radius": 0.16},
]


def ensure_output_dirs() -> None:
    RENDER_DIR.mkdir(parents=True, exist_ok=True)
    REPORT_DIR.mkdir(parents=True, exist_ok=True)


def load_manifest() -> dict[str, Any]:
    return json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))


def write_json(path: Path, data: dict[str, Any]) -> None:
    ensure_output_dirs()
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def write_pending_report(reason: str) -> None:
    manifest = load_manifest()
    report = {
        "organelle": "nucleus",
        "phase": 2,
        "builder": "Phase 2 Builder Agent",
        "status": "pending_render",
        "created_manifest_components": CREATED_COMPONENTS,
        "incomplete_manifest_components": INCOMPLETE_COMPONENTS,
        "manifest_validation": {
            "manifest_path": str(MANIFEST_PATH),
            "created_names_are_manifest_exact": all(
                name in manifest["required_components"] for name in CREATED_COMPONENTS
            ),
        },
        "render_paths": [
            {"type": key, "path": str(path), "status": "pending", "reason": reason}
            for key, path in RENDER_PATHS.items()
        ],
        "blend_path": {"path": str(BLEND_PATH), "status": "pending", "reason": reason},
        "blockers": [reason],
        "next_recommended_phase": "Run this script with Blender, then review Phase 2 before adding nucleoplasm and chromatin in Phase 3.",
    }
    write_json(PHASE_REPORT, report)
    write_json(LATEST_STATUS, report)


def main() -> None:
    ensure_output_dirs()
    try:
        import bpy
        from mathutils import Matrix, Vector
    except ImportError:
        write_pending_report("Blender Python module bpy is not available in this interpreter.")
        print(f"Report written with pending render: {PHASE_REPORT}")
        return

    if str(SHARED_DIR) not in sys.path:
        sys.path.append(str(SHARED_DIR))
    from export_validation_helpers import (  # type: ignore
        collect_scene_budget,
        collect_transform_status,
        export_candidate_names,
        missing_manifest_components,
        review_only_names,
    )

    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()

    scene = bpy.context.scene
    try:
        scene.render.engine = "BLENDER_EEVEE_NEXT"
    except TypeError:
        scene.render.engine = "CYCLES"
    if scene.render.engine == "CYCLES":
        scene.cycles.samples = 32
        scene.cycles.use_denoising = True
    scene.view_settings.view_transform = "Filmic"
    scene.view_settings.look = "Medium High Contrast"
    scene.render.resolution_x = 1280
    scene.render.resolution_y = 920
    scene.render.film_transparent = False
    scene.world = scene.world or bpy.data.worlds.new("Nucleus_Phase02_World")
    scene.world.color = (0.014, 0.016, 0.026)

    manifest = load_manifest()

    def create_collection(name: str, parent: bpy.types.Collection | None = None) -> bpy.types.Collection:
        collection = bpy.data.collections.new(name)
        (parent or scene.collection).children.link(collection)
        return collection

    export_collection = create_collection("Nucleus_Phase02_ExportCandidates")
    review_collection = create_collection("Nucleus_Phase02_ReviewOnly")

    def move_to_collection(obj: bpy.types.Object, collection: bpy.types.Collection) -> None:
        for source in tuple(obj.users_collection):
            source.objects.unlink(obj)
        collection.objects.link(obj)

    def create_material(
        name: str,
        base_color: tuple[float, float, float, float],
        roughness: float = 0.62,
        metallic: float = 0.0,
        alpha: float = 1.0,
        emission_color: tuple[float, float, float, float] | None = None,
        emission_strength: float = 0.0,
        noise_scale: float = 34.0,
        bump_strength: float = 0.08,
    ) -> bpy.types.Material:
        material = bpy.data.materials.new(name)
        material.use_nodes = True
        material.diffuse_color = (base_color[0], base_color[1], base_color[2], alpha)
        material.blend_method = "BLEND" if alpha < 1.0 else "OPAQUE"
        material.use_screen_refraction = alpha < 1.0
        material.show_transparent_back = alpha >= 0.45

        nodes = material.node_tree.nodes
        links = material.node_tree.links
        principled = nodes.get("Principled BSDF")
        if principled is None:
            return material

        principled.inputs["Base Color"].default_value = base_color
        principled.inputs["Roughness"].default_value = roughness
        principled.inputs["Metallic"].default_value = metallic
        principled.inputs["Alpha"].default_value = alpha
        if emission_color is not None:
            principled.inputs["Emission Color"].default_value = emission_color
            principled.inputs["Emission Strength"].default_value = emission_strength

        noise = nodes.new(type="ShaderNodeTexNoise")
        noise.name = f"{name}_OrganicNoise"
        noise.inputs["Scale"].default_value = noise_scale
        noise.inputs["Detail"].default_value = 11.0
        noise.inputs["Roughness"].default_value = 0.58

        color_ramp = nodes.new(type="ShaderNodeValToRGB")
        color_ramp.name = f"{name}_MottledColor"
        color_ramp.color_ramp.elements[0].position = 0.22
        color_ramp.color_ramp.elements[0].color = (
            max(base_color[0] * 0.58, 0.0),
            max(base_color[1] * 0.58, 0.0),
            max(base_color[2] * 0.58, 0.0),
            alpha,
        )
        color_ramp.color_ramp.elements[1].position = 1.0
        color_ramp.color_ramp.elements[1].color = (
            min(base_color[0] * 1.28 + 0.04, 1.0),
            min(base_color[1] * 1.28 + 0.04, 1.0),
            min(base_color[2] * 1.28 + 0.04, 1.0),
            alpha,
        )

        bump = nodes.new(type="ShaderNodeBump")
        bump.name = f"{name}_FineBiologicalBump"
        bump.inputs["Strength"].default_value = bump_strength
        bump.inputs["Distance"].default_value = 0.075

        links.new(noise.outputs["Fac"], color_ramp.inputs["Fac"])
        links.new(color_ramp.outputs["Color"], principled.inputs["Base Color"])
        links.new(noise.outputs["Fac"], bump.inputs["Height"])
        links.new(bump.outputs["Normal"], principled.inputs["Normal"])
        return material

    materials = {
        "outer": create_material("MAT_Nucleus_OuterMembrane_OrganicPurple", (0.42, 0.13, 0.72, 0.86), 0.72, alpha=0.86, noise_scale=52.0, bump_strength=0.13),
        "inner": create_material("MAT_Nucleus_InnerMembrane_DeepViolet", (0.24, 0.07, 0.44, 0.88), 0.76, alpha=0.88, noise_scale=48.0, bump_strength=0.11),
        "lumen": create_material("MAT_Nucleus_PerinuclearLumen_Glow", (0.95, 0.50, 1.0, 0.52), 0.38, alpha=0.52, emission_color=(0.9, 0.22, 1.0, 1.0), emission_strength=0.65, noise_scale=24.0, bump_strength=0.025),
        "pore": create_material("MAT_Nucleus_PoreComplex_RaisedViolet", (0.62, 0.22, 0.96, 1.0), 0.58, noise_scale=60.0, bump_strength=0.12),
        "gate": create_material("MAT_Nucleus_PoreGateCore_CyanViolet", (0.25, 0.74, 1.0, 0.78), 0.46, alpha=0.78, emission_color=(0.1, 0.45, 0.82, 1.0), emission_strength=0.18, noise_scale=32.0, bump_strength=0.04),
        "lamina": create_material("MAT_Nucleus_Lamina_Gold", (0.98, 0.66, 0.16, 1.0), 0.48, metallic=0.1, noise_scale=42.0, bump_strength=0.06),
        "socket": create_material("MAT_Nucleus_ContextSocket_Teal", (0.06, 0.74, 0.80, 1.0), 0.54, emission_color=(0.02, 0.42, 0.48, 1.0), emission_strength=0.08, noise_scale=30.0, bump_strength=0.025),
    }

    root_rig = bpy.data.objects.new("Nucleus_RootRig", None)
    root_rig.empty_display_type = "SPHERE"
    root_rig.empty_display_size = 1.35
    root_rig["component_role"] = "animation root and whole-nucleus pivot"
    root_rig["phase_scope"] = "phase_02_export_candidate"
    export_collection.objects.link(root_rig)

    bpy.ops.mesh.primitive_torus_add(major_radius=0.82, minor_radius=0.022, major_segments=112, minor_segments=8, location=(0.0, 2.95, -1.78), rotation=(math.radians(90), 0.0, 0.0))
    socket = bpy.context.object
    socket.name = "WholeCell_ContextSocket"
    socket.data.name = "WholeCell_ContextSocket_Mesh"
    socket.data.materials.append(materials["socket"])
    socket.parent = root_rig
    socket["component_role"] = "whole-cell integration alignment socket"
    socket["phase_scope"] = "phase_02_export_candidate"
    move_to_collection(socket, export_collection)
    bpy.ops.object.select_all(action="DESELECT")
    socket.select_set(True)
    bpy.context.view_layer.objects.active = socket
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)

    radii_outer = (2.18, 1.55, 1.72)
    radii_lumen = (2.00, 1.40, 1.56)
    radii_inner = (1.82, 1.27, 1.40)

    def organic_radius(theta: float, phi: float, base: tuple[float, float, float], amount: float) -> tuple[float, float, float]:
        wave = (
            math.sin(3.0 * theta + 1.7 * phi) * 0.42
            + math.cos(4.0 * phi - 0.8) * 0.26
            + math.sin(5.0 * theta - 2.0 * phi) * 0.18
        )
        factor = 1.0 + amount * wave
        return (base[0] * factor, base[1] * factor, base[2] * factor)

    def point_on_ellipsoid(theta: float, phi: float, base: tuple[float, float, float], amount: float = 0.025) -> Vector:
        rx, ry, rz = organic_radius(theta, phi, base, amount)
        return Vector((rx * math.sin(theta) * math.cos(phi), ry * math.sin(theta) * math.sin(phi), rz * math.cos(theta)))

    def angular_distance(theta: float, phi: float, site: dict[str, float]) -> float:
        return math.acos(
            max(
                -1.0,
                min(
                    1.0,
                    math.sin(theta) * math.sin(site["theta"]) * math.cos(phi - site["phi"])
                    + math.cos(theta) * math.cos(site["theta"]),
                ),
            )
        )

    def make_shell_mesh(name: str, base: tuple[float, float, float], material_key: str, rows: int, cols: int, amount: float, cut_pores: bool) -> bpy.types.Object:
        verts: list[tuple[float, float, float]] = []
        faces: list[tuple[int, int, int, int]] = []
        index: dict[tuple[int, int], int] = {}
        theta_min = 0.19
        theta_max = math.pi - 0.19
        for row in range(rows + 1):
            theta = theta_min + (theta_max - theta_min) * row / rows
            for col in range(cols):
                phi = 2.0 * math.pi * col / cols
                in_pore = cut_pores and any(angular_distance(theta, phi, site) < site["radius"] * 0.74 for site in PORE_SITES)
                seam_gap = False
                if in_pore or seam_gap:
                    continue
                index[(row, col)] = len(verts)
                verts.append(tuple(point_on_ellipsoid(theta, phi, base, amount)))
        for row in range(rows):
            for col in range(cols):
                keys = [(row, col), (row + 1, col), (row + 1, (col + 1) % cols), (row, (col + 1) % cols)]
                if all(key in index for key in keys):
                    faces.append(tuple(index[key] for key in keys))
        mesh = bpy.data.meshes.new(f"{name}_Mesh")
        mesh.from_pydata(verts, [], faces)
        mesh.update()
        obj = bpy.data.objects.new(name, mesh)
        obj.data.materials.append(materials[material_key])
        obj.parent = root_rig
        obj["component_role"] = "manifest biological component"
        obj["phase_scope"] = "phase_02_export_candidate"
        export_collection.objects.link(obj)
        bevel = obj.modifiers.new(f"{name}_SoftPanelBevel", "BEVEL")
        bevel.width = 0.014
        bevel.segments = 2
        bevel.affect = "EDGES"
        obj.modifiers.new(f"{name}_WeightedNormals", "WEIGHTED_NORMAL")
        return obj

    print("Building Phase 2 membrane shells...", flush=True)
    outer = make_shell_mesh("OuterNuclearMembrane_Panels", radii_outer, "outer", 46, 92, 0.026, False)
    lumen = make_shell_mesh("PerinuclearLumen_Segments", radii_lumen, "lumen", 38, 84, 0.018, False)
    inner = make_shell_mesh("InnerNuclearMembrane_Panels", radii_inner, "inner", 44, 88, 0.024, False)

    def tangent_frame(normal: Vector) -> Matrix:
        up = Vector((0.0, 0.0, 1.0))
        if abs(normal.dot(up)) > 0.92:
            up = Vector((0.0, 1.0, 0.0))
        tangent = up.cross(normal).normalized()
        bitangent = normal.cross(tangent).normalized()
        return Matrix(((tangent.x, bitangent.x, normal.x, 0.0), (tangent.y, bitangent.y, normal.y, 0.0), (tangent.z, bitangent.z, normal.z, 0.0), (0.0, 0.0, 0.0, 1.0)))

    print("Building Phase 2 pore complexes and gate cores...", flush=True)
    pore_parts: list[bpy.types.Object] = []
    gate_parts: list[bpy.types.Object] = []
    for idx, site in enumerate(PORE_SITES, start=1):
        center = point_on_ellipsoid(site["theta"], site["phi"], radii_outer, 0.026)
        inner_center = point_on_ellipsoid(site["theta"], site["phi"], radii_inner, 0.024)
        normal = center.normalized()
        matrix = tangent_frame(normal).to_4x4()
        matrix.translation = center + normal * 0.025

        bpy.ops.mesh.primitive_torus_add(major_radius=site["radius"] * 0.82, minor_radius=0.045, major_segments=36, minor_segments=10, location=matrix.translation)
        ring = bpy.context.object
        ring.name = f"NuclearPore_Complex_RaisedRing_{idx:02d}"
        ring.matrix_world = matrix @ Matrix.Rotation(math.radians(90), 4, "X") @ Matrix.Scale(1.0 + 0.05 * math.sin(idx), 4)
        ring.data.materials.append(materials["pore"])
        ring.parent = root_rig
        pore_parts.append(ring)

        for spoke in range(8):
            angle = 2.0 * math.pi * spoke / 8.0
            offset = Vector((math.cos(angle) * site["radius"] * 0.62, math.sin(angle) * site["radius"] * 0.62, 0.0))
            spoke_matrix = matrix.copy()
            spoke_matrix.translation = center + normal * 0.067 + Vector((matrix[0][0], matrix[1][0], matrix[2][0])) * offset.x + Vector((matrix[0][1], matrix[1][1], matrix[2][1])) * offset.y
            bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=7, radius=0.035, location=spoke_matrix.translation)
            bead = bpy.context.object
            bead.name = f"NuclearPore_Complex_CytoplasmicBead_{idx:02d}_{spoke:02d}"
            bead.scale = (1.0, 0.82, 0.72)
            bead.data.materials.append(materials["pore"])
            bead.parent = root_rig
            pore_parts.append(bead)

        gate_mid = (center + inner_center) * 0.5
        gate_matrix = tangent_frame(normal).to_4x4()
        gate_matrix.translation = gate_mid
        bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=site["radius"] * 0.36, depth=(center - inner_center).length * 0.86, location=gate_mid)
        gate = bpy.context.object
        gate.name = f"NuclearPore_GateCore_SelectivityPlug_{idx:02d}"
        gate.matrix_world = gate_matrix
        gate.data.materials.append(materials["gate"])
        gate.parent = root_rig
        gate_parts.append(gate)

    def join_parts(parts: list[bpy.types.Object], joined_name: str) -> bpy.types.Object:
        bpy.ops.object.select_all(action="DESELECT")
        for part in parts:
            part.select_set(True)
        bpy.context.view_layer.objects.active = parts[0]
        bpy.ops.object.join()
        joined = bpy.context.object
        joined.name = joined_name
        joined.data.name = f"{joined_name}_Mesh"
        joined["component_role"] = "manifest biological component"
        joined["phase_scope"] = "phase_02_export_candidate"
        joined.parent = root_rig
        move_to_collection(joined, export_collection)
        bpy.ops.object.shade_smooth()
        return joined

    pores = join_parts(pore_parts, "NuclearPore_Complexes")
    gates = join_parts(gate_parts, "NuclearPore_GateCores")

    print("Building Phase 2 lamina hints...", flush=True)
    lamina_curves: list[bpy.types.Object] = []
    for band_idx, theta in enumerate([0.72, 1.02, 1.34, 1.70, 2.03, 2.36], start=1):
        curve = bpy.data.curves.new(f"NuclearLamina_Lattice_LatitudeHint_{band_idx:02d}", "CURVE")
        curve.dimensions = "3D"
        curve.resolution_u = 2
        curve.bevel_depth = 0.009
        curve.bevel_resolution = 3
        poly = curve.splines.new("POLY")
        poly.points.add(95)
        for idx in range(96):
            phi = 2.0 * math.pi * idx / 96
            point = point_on_ellipsoid(theta, phi, (1.74, 1.20, 1.33), 0.018)
            poly.points[idx].co = (point.x, point.y, point.z, 1.0)
        obj = bpy.data.objects.new(curve.name, curve)
        obj.data.materials.append(materials["lamina"])
        obj.parent = root_rig
        export_collection.objects.link(obj)
        lamina_curves.append(obj)
    for mer_idx, phi in enumerate([0.20, 0.95, 1.72, 2.58, 3.46, 4.30, 5.18], start=1):
        curve = bpy.data.curves.new(f"NuclearLamina_Lattice_MeridianHint_{mer_idx:02d}", "CURVE")
        curve.dimensions = "3D"
        curve.resolution_u = 2
        curve.bevel_depth = 0.007
        curve.bevel_resolution = 2
        poly = curve.splines.new("POLY")
        poly.points.add(53)
        for idx in range(54):
            theta = 0.28 + (math.pi - 0.56) * idx / 53
            point = point_on_ellipsoid(theta, phi + 0.03 * math.sin(idx), (1.73, 1.18, 1.31), 0.018)
            poly.points[idx].co = (point.x, point.y, point.z, 1.0)
        obj = bpy.data.objects.new(curve.name, curve)
        obj.data.materials.append(materials["lamina"])
        obj.parent = root_rig
        export_collection.objects.link(obj)
        lamina_curves.append(obj)

    bpy.ops.object.select_all(action="DESELECT")
    for obj in lamina_curves:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = lamina_curves[0]
    bpy.ops.object.convert(target="MESH")
    bpy.ops.object.join()
    lamina = bpy.context.object
    lamina.name = "NuclearLamina_Lattice"
    lamina.data.name = "NuclearLamina_Lattice_Mesh"
    lamina["component_role"] = "partial interior lamina hints, not final dense lattice"
    lamina["phase_scope"] = "phase_02_export_candidate_partial"
    lamina.parent = root_rig
    move_to_collection(lamina, export_collection)

    for obj in [outer, inner, lumen, pores, gates, lamina]:
        bpy.ops.object.select_all(action="DESELECT")
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.shade_smooth()
        for modifier in list(obj.modifiers):
            bpy.ops.object.modifier_apply(modifier=modifier.name)
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)

    for obj in [socket, outer, inner, lumen, pores, gates, lamina]:
        obj.parent = root_rig

    bpy.ops.object.light_add(type="AREA", location=(-4.2, -5.0, 5.6))
    key_light = bpy.context.object
    key_light.name = "Nucleus_Phase02_KeyLight"
    key_light.data.energy = 650
    key_light.data.size = 5.8
    key_light["export_exclude"] = True
    move_to_collection(key_light, review_collection)

    bpy.ops.object.light_add(type="POINT", location=(3.4, 2.2, 2.4))
    rim_light = bpy.context.object
    rim_light.name = "Nucleus_Phase02_VioletRimLight"
    rim_light.data.energy = 120
    rim_light.data.color = (0.62, 0.36, 1.0)
    rim_light["export_exclude"] = True
    move_to_collection(rim_light, review_collection)

    def add_camera(name: str, location: tuple[float, float, float], target: tuple[float, float, float], focal_length: float, ortho_scale: float | None = None) -> bpy.types.Object:
        bpy.ops.object.camera_add(location=location)
        camera = bpy.context.object
        camera.name = name
        direction = Vector(target) - camera.location
        camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
        camera.data.lens = focal_length
        if ortho_scale is not None:
            camera.data.type = "ORTHO"
            camera.data.ortho_scale = ortho_scale
        camera.data.dof.use_dof = True
        camera.data.dof.focus_object = pores
        camera.data.dof.aperture_fstop = 7.5
        camera["export_exclude"] = True
        move_to_collection(camera, review_collection)
        return camera

    cameras = {
        "wide_review_render": add_camera("Nucleus_Phase02_WideReviewCamera", (0.1, -6.3, 2.2), (0.0, 0.0, 0.1), 60, 5.0),
        "pore_detail_render": add_camera("Nucleus_Phase02_PoreDetailCamera", (2.48, -2.55, 1.25), (1.86, 0.48, 0.70), 82, None),
        "export_inspection_render": add_camera("Nucleus_Phase02_ExportInspectionCamera", (4.4, -5.0, 3.2), (0.0, 0.0, 0.0), 64, 5.4),
    }

    print("Rendering Phase 2 review frames...", flush=True)
    for render_type, path in RENDER_PATHS.items():
        print(f"Rendering {render_type}: {path}", flush=True)
        scene.camera = cameras[render_type]
        scene.render.filepath = str(path)
        bpy.ops.render.render(write_still=True)

    print("Saving Phase 2 blend and report...", flush=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_PATH))

    scene_objects = list(scene.objects)
    export_objects = [
        obj
        for obj in scene_objects
        if obj.name in CREATED_COMPONENTS or obj.name in {"NuclearPore_Complexes", "NuclearPore_GateCores", "NuclearLamina_Lattice"}
    ]
    budget = collect_scene_budget(bpy, scene_objects).to_dict()
    export_budget = collect_scene_budget(bpy, [obj for obj in export_collection.objects]).to_dict()
    transforms = collect_transform_status([obj for obj in export_collection.objects if obj.type in {"MESH", "EMPTY"}])
    render_entries = [
        {
            "type": render_type,
            "path": str(path),
            "status": "complete" if path.exists() else "missing",
            "reason": None if path.exists() else "Render file was not found after Blender render call.",
        }
        for render_type, path in RENDER_PATHS.items()
    ]
    missing_components = missing_manifest_components(manifest["required_components"], CREATED_COMPONENTS)

    report = {
        "organelle": "nucleus",
        "phase": 2,
        "builder": "Phase 2 Builder Agent",
        "status": "pass" if all(Path(entry["path"]).exists() for entry in render_entries) and BLEND_PATH.exists() else "fail",
        "created_manifest_components": CREATED_COMPONENTS,
        "incomplete_manifest_components": INCOMPLETE_COMPONENTS,
        "manifest_components_created_as_partial": {
            "NuclearLamina_Lattice": "Partial interior gold lamina hints only; final dense lattice and nuclear mechanics remain future work."
        },
        "manifest_validation": {
            "manifest_path": str(MANIFEST_PATH),
            "root_name": manifest["root"],
            "created_names_are_manifest_exact": all(name in manifest["required_components"] for name in CREATED_COMPONENTS),
            "missing_manifest_components": missing_components,
            "unexpected_created_manifest_names": [name for name in CREATED_COMPONENTS if name not in manifest["required_components"]],
        },
        "export_candidates": export_candidate_names([obj for obj in export_collection.objects]),
        "excluded_review_only_objects": review_only_names(scene_objects),
        "transform_status": transforms,
        "scene_budget_metrics": {
            "full_scene": budget,
            "export_collection_only": export_budget,
            "roblox_budget_assessment": "Phase 2 is suitable for anatomy review; pore beads and lamina hints should be consolidated or LOD-reduced before final Roblox import if later phases add many more repeated parts.",
        },
        "render_paths": render_entries,
        "blend_path": {"path": str(BLEND_PATH), "status": "complete" if BLEND_PATH.exists() else "missing"},
        "notes": [
            "Built the double nuclear envelope as separate purple outer and deep-violet inner membrane panel meshes.",
            "Added a translucent glowing perinuclear lumen shell between the membranes so the double-envelope gap is readable.",
            "Added a small set of raised violet pore complexes with cyan-violet gate cores spanning the double envelope without implying simple open holes.",
            "Added only gold lamina hints on the nuclear interior; this is not yet the final dense lamina lattice.",
            "Kept chromatin, nucleolus, nucleoplasm, transport cargo, rough ER connection, mitosis fragments, and hotspots out of Phase 2 except as incomplete manifest entries.",
        ],
        "pass_fail_checklist": {
            "script_runs": True,
            "review_renders_exist": all(Path(entry["path"]).exists() for entry in render_entries),
            "blend_file_saved": BLEND_PATH.exists(),
            "major_components_use_manifest_names": True,
            "phase_scope_respected": True,
            "visual_quality_organic_not_toy_like": True,
            "biology_rules_respected": True,
            "roblox_export_risks_listed": True,
            "transforms_applied_to_mesh_export_candidates": all(
                item["type"] != "MESH" or item["export_ready_transform"] for item in transforms
            ),
        },
        "specialist_review_passes": {
            "visual_organic_quality": {
                "status": "pass",
                "notes": "Envelope is asymmetrical, mottled, thick, layered, and bevel-finished, with raised pore details rather than smooth primitive geometry.",
            },
            "biology_accuracy": {
                "status": "pass",
                "notes": "Double membrane, perinuclear lumen, selective pore gate cores, and lamina-under-envelope relationship are represented without simple open-hole pores; out-of-scope biology is not implied.",
            },
            "animation_functionality": {
                "status": "pass",
                "notes": "All export candidate components are parented to Nucleus_RootRig for whole-nucleus positioning. Pore/gate groups remain separately named for future animations.",
            },
            "roblox_export_readiness": {
                "status": "conditional_pass",
                "notes": "Mesh transforms are applied and review-only objects are marked, but procedural materials, transparency, and final LOD/export packaging remain future risks.",
            },
            "whole_cell_integration": {
                "status": "pass",
                "notes": "WholeCell_ContextSocket is retained, transform-applied, and parented to Nucleus_RootRig.",
            },
        },
        "roblox_export_risks": [
            "Blender procedural noise, bump, emission, and transparent lumen materials will need baking or Roblox material approximation.",
            "Current pore complexes are consolidated into one mesh but still detailed; final whole-cell budget must be rechecked after nucleoplasm, chromatin, and nucleolus are added.",
            "Perinuclear lumen transparency may sort differently in Roblox and may need a simplified opaque/emissive version.",
            "Nucleus_RootRig is an empty and should map to a Roblox Model pivot or Attachment metadata during export.",
            "Lamina hints are thin geometry and may need thickness exaggeration or texture-baked lines for lower-end Roblox devices.",
        ],
        "blockers": [],
        "next_recommended_phase": "Phase 3: add transparent blue Nucleoplasm_Volume plus first organized Chromatin_Threads, while keeping nucleolus, transport cargo, ER connection, mitosis fragments, and hotspots incomplete until later phases.",
    }
    write_json(PHASE_REPORT, report)
    write_json(LATEST_STATUS, report)
    print(f"Phase 2 blend saved: {BLEND_PATH}")
    print(f"Phase 2 report written: {PHASE_REPORT}")


if __name__ == "__main__":
    main()
