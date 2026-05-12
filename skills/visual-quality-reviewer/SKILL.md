---
name: visual-quality-reviewer
description: Review the latest organelle phase for organic visual quality only, reading rendered evidence and writing a phase visual review JSON without changing code.
---

# Visual Organic Quality Reviewer

Use this skill when checking look and feel only.

## Work Only On Review

Do not change code unless explicitly asked.

## Read First

- `STYLE_BIBLE.md`
- `REFERENCE_IMAGE_DESIGN_PRINCIPLES.md`
- `reference_images/reference_manifest.json`
- `shared/materials/organic_material_recipes.md`
- `shared/review_checklists/visual_quality_checklist.csv`
- `organelles/[organelle_slug]/visual_addendum.md`
- `organelles/[organelle_slug]/review_renders/`

## Review The Latest Phase

Check:

1. Does it look organic, not geometric?
2. Are surfaces textured and varied?
3. Are membranes thick and rounded?
4. Are biological parts asymmetrical enough?
5. Does lighting show 3D depth?
6. Are default primitives still visible?
7. Does it match the reference image style?
8. Did the builder translate reference cues into organic 3D form rather than a
   flat copy?

## Baseline Evidence Rule

Use reference images as baselines whenever they exist. A visual pass must cite
the exact reference image paths used and compare the latest render against:

- silhouette and component relationships
- color hierarchy
- organic surface quality
- 3D depth and biological thickness
- visible mismatch from the intended teaching image

If reference images exist but were not used, mark the review as failed. If the
latest render is missing, mark the review as failed. If the model only looks
acceptable in Blender but the available Roblox edit/play screenshots show scale,
placement, transparency, or readability issues, mark the visual decision as
changes required.

## Output

Write:

```text
organelles/[organelle_slug]/review_reports/phase_[X]_visual_review.json
```

Use this format:

```json
{
  "visual_pass": false,
  "score_0_to_100": 0,
  "reference_images_used": [],
  "reference_alignment": {
    "silhouette": "pass/fail",
    "color_language": "pass/fail",
    "component_relationships": "pass/fail",
    "organic_3d_translation": "pass/fail",
    "biology_conflicts": []
  },
  "major_failures": [],
  "minor_issues": [],
  "required_fixes": [],
  "approved_to_continue": false
}
```
