"""Write the synthetic DICOM files in inst/extdata/dicom/.

Each file is one 8 x 8 pixel MR slice of a made-up patient ("SYNTHETIC^EXAMPLE",
no real person, site or measurement). The folder layout
<pat_id>/<session>/ matches what extract_dicom_metadata() and convert_batch()
expect. Run from the package root with Python 3, numpy and pydicom:

    python3 data-raw/make_example_dicom.py inst/extdata/dicom/SCI001/ses-01/IM0001.dcm ses-01 20240120
    python3 data-raw/make_example_dicom.py inst/extdata/dicom/SCI001/ses-02/IM0001.dcm ses-02 20240315
"""
import sys, numpy as np, pydicom
from pydicom.dataset import Dataset, FileMetaDataset
from pydicom.uid import ExplicitVRLittleEndian, MRImageStorage, generate_uid

out = sys.argv[1]
session = sys.argv[2]
study_date = sys.argv[3]
seed = "scimagR synthetic example " + session
meta = FileMetaDataset()
meta.MediaStorageSOPClassUID = MRImageStorage
meta.MediaStorageSOPInstanceUID = generate_uid(entropy_srcs=[seed, "sop"])
meta.TransferSyntaxUID = ExplicitVRLittleEndian
ds = Dataset()
ds.file_meta = meta
ds.SOPClassUID = MRImageStorage
ds.SOPInstanceUID = meta.MediaStorageSOPInstanceUID
ds.StudyInstanceUID = generate_uid(entropy_srcs=[seed, "study"])
ds.SeriesInstanceUID = generate_uid(entropy_srcs=[seed, "series"])
ds.FrameOfReferenceUID = generate_uid(entropy_srcs=[seed, "for"])
ds.PatientName = "SYNTHETIC^EXAMPLE"
ds.PatientID = "SYNTH-0001"
ds.PatientBirthDate = "19000101"
ds.PatientSex = "O"
ds.InstitutionName = "Synthetic Example Site"
ds.ReferringPhysicianName = "SYNTHETIC^REFERRER"
ds.StudyDate = study_date
ds.SeriesDate = study_date
ds.StudyTime = "120000"
ds.Modality = "MR"
ds.PatientPosition = "HFS"
ds.Manufacturer = "SYNTHETIC"
ds.ManufacturerModelName = "SYNTHETIC"
ds.SeriesDescription = "T2w_sag"
ds.MagneticFieldStrength = 3
ds.StudyID = "1"
ds.SeriesNumber = 1
ds.InstanceNumber = 1
ds.ImagePositionPatient = [0, 0, 0]
ds.ImageOrientationPatient = [1, 0, 0, 0, 1, 0]
ds.PixelSpacing = [1, 1]
ds.SliceThickness = 3
ds.SamplesPerPixel = 1
ds.PhotometricInterpretation = "MONOCHROME2"
ds.Rows = 8
ds.Columns = 8
ds.BitsAllocated = 16
ds.BitsStored = 12
ds.HighBit = 11
ds.PixelRepresentation = 0
y, x = np.mgrid[0:8, 0:8]
img = ((np.abs(x - 3.5) < 1.5) * 800 + 100 + y * 10).astype(np.uint16)
ds.PixelData = img.tobytes()
ds.save_as(out, enforce_file_format=True)
print(out)
