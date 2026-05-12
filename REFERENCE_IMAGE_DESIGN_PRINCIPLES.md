# Reference Image Design Principles

Use reference images as design baselines, not as flat templates to copy.

## Core Rule

A reference image should guide recognizability, biological relationships, color
language, and quality bar. It should not be traced directly into Blender as a
flat or toy-like object.

The output must be a 3D biological model with:

- thickness
- asymmetry
- layered structure
- material response
- procedural surface variation
- camera-readable depth
- function-driven detail

## What References Control

Reference images are valid baselines for:

- silhouette and overall read
- major component relationships
- color family and contrast hierarchy
- density of detail
- organic vs geometric quality
- visual teaching priorities

For the nucleus, references should help verify:

- thick purple double membrane
- visible inner/outer envelope separation
- raised pore complexes, not open holes
- selective gate structure inside pores
- glowing perinuclear lumen
- lamina positioned inside the envelope
- nucleoplasm/chromatin/nucleolus readability in later phases

## What References Do Not Control

Do not copy:

- exact 2D outlines
- flat diagram spacing
- arbitrary decorative marks
- impossible geometry caused by perspective
- labels baked into the artwork
- biology mistakes in a stylized source image

If a reference conflicts with biology, biology wins.

## Review Baseline Rule

Yes: use images as baselines during review.

Every visual review should compare the latest render against the reference set
and answer:

1. Does the model read as the same biological structure?
2. Did the builder translate the image into real 3D depth?
3. Are reference cues preserved as organic form, not copied as flat decoration?
4. Are scientifically important relationships clearer than in the image?
5. Are any reference-derived details biologically misleading?

## Required Review Evidence

Visual review reports should include:

```json
{
  "reference_images_used": [],
  "reference_alignment": {
    "silhouette": "pass/fail",
    "color_language": "pass/fail",
    "component_relationships": "pass/fail",
    "organic_3d_translation": "pass/fail",
    "biology_conflicts": []
  }
}
```

If no reference images are available, the reviewer must mark
`reference_images_used` as empty and list that as a review limitation.

