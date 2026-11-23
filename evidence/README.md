# Execution evidence

All screenshots capture actual Windows command windows or Control Panel. The
report crops unused window space for legibility; no terminal text is fabricated.
Linux commands execute through Docker on Windows, not a claimed native desktop.

| Screenshot | Evidence |
| --- | --- |
| `01-windows-build.png` | C# / WiX build and MSI file |
| `02-windows-verification.png` | msiexec exit 0, greeting, documents, lifecycle |
| `03-programs-and-features.png` | Actual Control Panel installed-program entry |
| `04-debian-build.png` | GCC, dpkg-deb build, control metadata and payload |
| `05-debian-verification.png` | dpkg installed status, greeting, lifecycle |
| `06-rpm-build.png` | rpmbuild binary/source outputs, metadata and payload |
| `07-rpm-verification.png` | Fedora RPM metadata, greeting, lifecycle |

Matching `logs/WindowsBuild.txt`, `WindowsVerify.txt`, `DebianBuild.txt`,
`DebianVerify.txt`, `RpmBuild.txt`, and `RpmVerify.txt` are PowerShell transcripts
of actual commands. `rpmbuild-detail.txt` retains the complete final RPM build
log. `msi-properties.json` contains properties extracted from the submitted MSI.
The environment logs record tool and Linux release versions.

The Debian uninstall warning that `/usr/local` is not empty is expected: dpkg
preserves an existing shared directory. The application executable is removed
and its absence is explicitly checked.

## Report QA

The Word report contains ten pages and seven embedded screenshots. Its creator
uses the compact_reference_guide preset, an editorial opening, US Letter pages,
1-inch margins, real heading styles, figure captions and running page numbers.
All ten rendered pages were inspected for layout and legibility.

The packaged LibreOffice renderer was attempted but `soffice` is unavailable.
Instead, installed Microsoft Word 16.0 exported the actual DOCX to PDF and the
workspace runtime's native Poppler rendered every page to PNG for visual review.
QA PDFs and page PNGs stay in ignored `report/qa/`, not the submission.
