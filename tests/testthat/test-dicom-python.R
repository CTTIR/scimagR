# Tests that run the bundled Python scripts on the bundled synthetic DICOM
# files. They need Python 3 with 'pydicom' (set PYTHON_BIN to choose the
# interpreter) and are skipped otherwise.

skip_without_pydicom <- function() {
  skip_on_cran()
  skip_if_not(check_pydicom(verbose = FALSE)$available, "pydicom not available")
}

copy_example_dicom <- function(envir = parent.frame()) {
  work <- withr::local_tempdir(.local_envir = envir)
  file.copy(system.file("extdata", "dicom", package = "scimagR"), work,
            recursive = TRUE)
  file.path(work, "dicom")
}

test_that("the bundled DICOM fixture has the documented layout", {
  root <- system.file("extdata", "dicom", package = "scimagR")
  files <- list.files(root, recursive = TRUE)
  expect_equal(files, c("SCI001/ses-01/IM0001.dcm", "SCI001/ses-02/IM0001.dcm"))
})

test_that("extract_dicom_metadata takes pat_id from the folder name", {
  skip_without_pydicom()
  root <- system.file("extdata", "dicom", package = "scimagR")
  csv <- file.path(withr::local_tempdir(), "meta.csv")
  expect_invisible(suppressMessages(extract_dicom_metadata(root, csv)))
  meta <- utils::read.csv(csv, stringsAsFactors = FALSE)
  expect_equal(meta$pat_id, c("SCI001", "SCI001"))
  expect_equal(meta$session, c("ses-01", "ses-02"))
  expect_equal(meta$study_date, c("2024-01-20", "2024-03-15"))
  expect_equal(meta$modality, c("MR", "MR"))
  # The PatientID header of the fixture must not leak into the CSV
  expect_false(any(grepl("SYNTH-0001", readLines(csv))))
})

test_that("metadata from extract_dicom_metadata() gives a valid registry", {
  skip_without_pydicom()
  root <- system.file("extdata", "dicom", package = "scimagR")
  csv <- file.path(withr::local_tempdir(), "meta.csv")
  suppressMessages(extract_dicom_metadata(root, csv))
  reg <- suppressMessages(create_registry(csv, c(SCI001 = "2024-01-15")))
  expect_equal(reg$modality, c("MRT", "MRT"))
  expect_equal(reg$days_post_trauma, c(5L, 60L))
  expect_no_error(suppressMessages(validate_registry(reg)))
})

test_that("anonymize_dicom empties identifying tags and writes the mapping", {
  skip_without_pydicom()
  root <- copy_example_dicom()
  mapping <- file.path(withr::local_tempdir(), "secure", "map.csv")
  suppressMessages(anonymize_dicom(root, mapping, prefix = "ANON"))
  map <- utils::read.csv(mapping, stringsAsFactors = FALSE)
  expect_equal(map, data.frame(original_id = "SCI001", anon_id = "ANON001"))

  py <- check_pydicom(verbose = FALSE)$path
  dcm <- file.path(root, "SCI001", "ses-01", "IM0001.dcm")
  code <- paste(
    "import sys, pydicom",
    "ds = pydicom.dcmread(sys.argv[1])",
    "print(ds.PatientID)",
    "print(repr(str(ds.PatientName)))",
    "print(repr(str(ds.InstitutionName)))",
    "print(ds.PatientBirthDate == '')",
    sep = "\n"
  )
  out <- system2(py, c("-c", shQuote(code), shQuote(dcm)), stdout = TRUE)
  expect_equal(out, c("ANON001", "''", "''", "True"))
})
