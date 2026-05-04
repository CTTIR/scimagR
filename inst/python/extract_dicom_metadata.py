#!/usr/bin/env python3
"""Extract DICOM header metadata from a directory tree.

Usage:
    python extract_dicom_metadata.py <dicom_root> <output_csv>

Expects directory structure: <dicom_root>/<pat_id>/<session>/<*.dcm>
Extracts metadata from the first DICOM file found per session.

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


FIELDS = [
    ("PatientID", "pat_id"),
    ("StudyDate", "study_date"),
    ("Modality", "modality"),
    ("SeriesDescription", "series_description"),
    ("MagneticFieldStrength", "field_strength"),
    ("Manufacturer", "manufacturer"),
    ("ManufacturerModelName", "scanner_model"),
    ("SliceThickness", "slice_thickness"),
    ("PixelSpacing", "pixel_spacing"),
    ("Rows", "rows"),
    ("Columns", "columns"),
    ("InstitutionName", "institution"),
]


def find_first_dcm(directory):
    """Find the first DICOM file in a directory."""
    for root, _dirs, files in os.walk(directory):
        for f in sorted(files):
            if f.lower().endswith(".dcm") or not os.path.splitext(f)[1]:
                filepath = os.path.join(root, f)
                try:
                    pydicom.dcmread(filepath, stop_before_pixels=True)
                    return filepath
                except Exception:
                    continue
    return None


def extract_metadata(dcm_path, pat_id, session):
    """Extract metadata fields from a DICOM file."""
    ds = pydicom.dcmread(dcm_path, stop_before_pixels=True)
    row = {"pat_id": pat_id, "session": session, "dcm_path": dcm_path}

    for dcm_field, csv_field in FIELDS:
        value = getattr(ds, dcm_field, None)
        if value is not None:
            if dcm_field == "PixelSpacing" and hasattr(value, "__iter__"):
                value = "x".join(str(v) for v in value)
            elif dcm_field == "StudyDate" and len(str(value)) == 8:
                d = str(value)
                value = f"{d[:4]}-{d[4:6]}-{d[6:8]}"
            row[csv_field] = str(value)
        else:
            row[csv_field] = ""

    return row


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <dicom_root> <output_csv>", file=sys.stderr)
        sys.exit(1)

    dicom_root = Path(sys.argv[1])
    output_csv = Path(sys.argv[2])

    if not dicom_root.is_dir():
        print(f"Error: Directory not found: {dicom_root}", file=sys.stderr)
        sys.exit(1)

    output_csv.parent.mkdir(parents=True, exist_ok=True)

    rows = []
    for pat_dir in sorted(dicom_root.iterdir()):
        if not pat_dir.is_dir():
            continue
        pat_id = pat_dir.name

        for ses_dir in sorted(pat_dir.iterdir()):
            if not ses_dir.is_dir():
                continue
            session = ses_dir.name

            dcm_path = find_first_dcm(str(ses_dir))
            if dcm_path is None:
                print(f"Warning: No DICOM found in {ses_dir}", file=sys.stderr)
                continue

            try:
                row = extract_metadata(dcm_path, pat_id, session)
                rows.append(row)
                print(f"  Extracted: {pat_id}/{session}")
            except Exception as e:
                print(f"  Error processing {pat_id}/{session}: {e}", file=sys.stderr)

    if not rows:
        print("Warning: No DICOM metadata extracted.", file=sys.stderr)
        sys.exit(0)

    fieldnames = ["pat_id", "session", "dcm_path"] + [f[1] for f in FIELDS if f[1] not in ("pat_id",)]
    # Deduplicate while preserving order
    seen = set()
    unique_fields = []
    for f in fieldnames:
        if f not in seen:
            seen.add(f)
            unique_fields.append(f)

    with open(output_csv, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=unique_fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)

    print(f"Metadata saved to {output_csv} ({len(rows)} sessions)")


if __name__ == "__main__":
    main()
