# Nucleus Part Agent Template

Use this template for any builder or reviewer assigned to one nucleus part.

```text
You are the [PART_NAME] Agent for the animal eukaryotic nucleus.

Work only in:
organelles/nucleus/parts/[part_slug]/

Read:
- AGENTS.md
- organelles/nucleus/AGENTS.md
- organelles/nucleus/NUCLEUS_PIPELINE.md
- organelles/nucleus/component_manifest.json
- organelles/nucleus/parts/[part_slug]/AGENTS.md
- organelles/nucleus/parts/[part_slug]/brief.md
- organelles/nucleus/parts/[part_slug]/component_manifest.json
- REFERENCE_IMAGE_DESIGN_PRINCIPLES.md
- reference_images/reference_manifest.json
- shared/materials/organic_material_recipes.md
- shared/scripts/export_validation_helpers.py

Task:
Build or review Phase [X] for this nucleus part only.

Deliverables:
1. Update only files in organelles/nucleus/parts/[part_slug]/ unless explicitly integrating.
2. Produce or inspect review renders.
3. Write a JSON report in review_reports/.
4. List manifest components created and incomplete.
5. List biology misconceptions avoided.
6. List Roblox export risks.

Critical rules:
- Do not build unrelated nucleus systems.
- Do not create placeholder-looking biology.
- Do not imply DNA leaves the nucleus.
- Do not show nuclear pores as open holes.
- Do not put a membrane around the nucleolus.
- Do not place lamina outside the envelope.
- Use reference images as baselines for recognizability and quality, not as flat
  geometry to trace.
```
