#!/usr/bin/env python3
"""Anonymize DICOM files by replacing identifying header fields.

Usage:
    python anonymize_dicom.py <dicom_root> <mapping_csv> [prefix]

WARNING: This modifies DICOM files IN-PLACE. Create a backup first!
The mapping CSV should be stored in a SECURE location outside the project.

Requires: pydicom (pip install pydicom)
"""

import csv
import os
import sys
from pathlib import Path

try:
    import pydicom
except ImportError:
    print("Error: pydicom is required. Install with: pip install pydicom", file=sys.stderr)
    sys.exit(1)


TAGS_TO_REMOVE = [
    "PatientName",
    "PatientBirthDate",
    "PatientAddress",
    "PatientTelephoneNumbers",
    "ReferringPhysicianName",
    "InstitutionName",
    "InstitutionAddress",
    "InstitutionalDepartmentName",
    "PhysiciansOfRecord",
    "PerformingPhysicianName",
    "OperatorsName",
]

TAGS_TO_REPLACE = [
    "PatientID",
]


def anonymize_file(dcm_path, anon_id):
    """Anonymize a single DICOM file."""
    ds = pydicom.dcmread(dcm_path)

    for tag_name in TAGS_TO_REMOVE:
        if hasattr(ds, tag_name):
            setattr(ds, tag_name, "")

    for tag_name in TAGS_TO_REPLACE:
        if hasattr(ds, tag_name):
            setattr(ds, tag_name, anon_id)

    ds.remove_private_tags()
    ds.save_as(dcm_path)


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <dicom_root> <mapping_csv> [prefix]", file=sys.stderr)
        sys.exit(1)

    dicom_root = Path(sys.argv[1])
    mapping_csv = Path(sys.argv[2])
    prefix = sys.argv[3] if len(sys.argv) > 3 else "SCI"

    if not dicom_root.is_dir():
        print(f"Error: Directory not found: {dicom_root}", file=sys.stderr)
        sys.exit(1)

    mapping_csv.parent.mkdir(parents=True, exist_ok=True)

    id_mapping = {}
    counter = 1

    for pat_dir in sorted(dicom_root.iterdir()):
        if not pat_dir.is_dir():
            continue

        original_id = pat_dir.name
        anon_id = f"{prefix}{counter:03d}"
        id_mapping[original_id] = anon_id
        counter += 1

        print(f"Anonymizing {original_id} -> {anon_id}")

        for root, _dirs, files in os.walk(str(pat_dir)):
            for filename in files:
                filepath = os.path.join(root, filename)
                try:
                    anonymize_file(filepath, anon_id)
                except Exception as e:
                    print(f"  Warning: Could not process {filepath}: {e}", file=sys.stderr)

    with open(mapping_csv, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["original_id", "anon_id"])
        for orig, anon in id_mapping.items():
            writer.writerow([orig, anon])

    print(f"\nAnonymization complete. {len(id_mapping)} patients processed.")
    print(f"ID mapping saved to: {mapping_csv}")
    print("WARNING: Store the mapping file securely!")


if __name__ == "__main__":
    main()
