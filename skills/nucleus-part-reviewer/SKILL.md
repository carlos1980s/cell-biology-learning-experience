---
name: nucleus-part-reviewer
description: Review one nucleus part for visual quality, biology accuracy, Roblox export readiness, and code structure against the local part manifest and nucleus pipeline.
---

# Nucleus Part Reviewer

Use this skill when reviewing one nucleus part.

## Read First

- `STYLE_BIBLE.md`
- `REFERENCE_IMAGE_DESIGN_PRINCIPLES.md`
- `reference_images/reference_manifest.json`
- `BIOLOGY_RULES.md`
- `ROBLOX_EXPORT_RULES.md`
- `REVIEW_PROTOCOL.md`
- `organelles/nucleus/AGENTS.md`
- `organelles/nucleus/NUCLEUS_PIPELINE.md`
- `organelles/nucleus/parts/[part_slug]/AGENTS.md`
- `organelles/nucleus/parts/[part_slug]/component_manifest.json`
- `organelles/nucleus/parts/[part_slug]/review_renders/`
- `organelles/nucleus/parts/[part_slug]/review_reports/`

## Review Focus

- Does the part satisfy its narrow biological role?
- Does it avoid nucleus-specific misconceptions?
- Does it look organic, layered, rounded, textured, and premium?
- Does it align with available reference images without becoming a flat copy?
- Are exact manifest names used?
- Are export candidates, transform status, and budgets reported?
- Does the part avoid building unrelated nucleus systems?
- Does the review cite the matching baseline reference image when one exists?
- Does the part define a clean future Roblox package group, pivot, material
  fallback, transparency policy, and collision policy?
- If Roblox screenshots exist, does the part remain readable and correctly
  placed in both edit mode and play mode?

## Output

Write JSON reports under:

```text
organelles/nucleus/parts/[part_slug]/review_reports/
```
