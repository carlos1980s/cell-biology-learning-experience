# Blender Build Order — Reverse Componentization

1. G00 Whole-cell context and nucleus socket
2. G01 Root rig, pivots, controllers, LODs
3. G02 Outer/inner membrane panels, perinuclear lumen, cutaway rims
4. G03 NPC master module, then NPC instances
5. G04 Lamina support mesh and anchors
6. G05 Nucleoplasm transparent volume and particles
7. G06 Chromatin, transcription hotspots, condensed chromosomes
8. G07 Nucleolus subregions and rRNA/ribosomal markers
9. G08 Transport cargo, paths, and gate pulse controller
10. G09 Rough ER connection and ER lumen continuity
11. G10 Mitosis breakdown/reassembly fragments and target sockets
12. G11 Interaction hotspots and labels
13. G12 Cameras, lighting, review checkpoints, validation passes

Build from global context to root/pivots, then structural shell, then functional machines, then internal biology, then animations and review controls. This prevents later components from floating or being misaligned.
