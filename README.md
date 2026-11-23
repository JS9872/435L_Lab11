# EECE 435L — Lab 11: Configuration and Deployment Tools

**Joey Saade · 202305993 · jhs15@mail.aub.edu**  
American University of Beirut · Fall 2026–2027

Windows C# and Linux C console applications print:

```text
Hello, World from Joey_Saade!
```

## Submission

- `deliverables/helloworld_joey_saade.msi` — Windows x64, per-user installer.
- `deliverables/helloworld_joey_saade.deb` — Debian amd64 package.
- `deliverables/helloworld_joey_saade.rpm` — optional Linux x86-64 RPM.
- `deliverables/helloworld_joey_saade.src.rpm` — optional source RPM.
- `deliverables/source.zip` — application sources, packaging and build instructions.
- `deliverables/Lab11_Report_Joey_Saade.docx` — illustrated laboratory report.
- `deliverables/SHA256SUMS.txt` — checksums of the submission files.
- `packaging/debian/control`, `packaging/windows/Product.wxs`, and
  `packaging/rpm/helloworld.spec` — complete installer metadata.
- `evidence/` — real execution transcripts and screenshots.

## Build Windows

Prerequisites: Windows x64, .NET Framework 4 C# compiler, WiX Toolset **3.14.1**
binary distribution. WiX 4+ uses different commands and is not interchangeable.
The compiler is normally included at
`C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe`.

```powershell
.\scripts\build-windows.ps1 -WixBin C:\tools\wix314
.\scripts\verify-windows.ps1
```

The MSI build runs WiX's normal validation (not `-sval`). Verification installs,
checks the personalized greeting and all document hashes, checks the uninstall
uninstall registration, removes and reinstalls the application. It leaves the
application installed at `%LOCALAPPDATA%\Programs\JoeySaadeHelloWorld`.
No elevation or PATH modification is needed.

```powershell
& "$env:LOCALAPPDATA\Programs\JoeySaadeHelloWorld\helloworld.exe"
msiexec /x .\deliverables\helloworld_joey_saade.msi /qb
```

## Build Linux (DEB and optional RPM)

Prerequisites: Debian 12 x86-64 with GCC, dpkg-deb and rpmbuild. Docker can supply
an isolated environment on Windows without installing a WSL distribution.
Run from the repository root, using PowerShell:

```powershell
docker run --name 435l-lab11-debian --mount "type=bind,source=$($PWD.Path),target=/work" -w /work -d debian:bookworm-slim sleep infinity
docker exec 435l-lab11-debian sh -c "apt-get update && apt-get install -y --no-install-recommends gcc libc6-dev rpm file"
docker exec 435l-lab11-debian sh scripts/build-linux.sh
docker exec 435l-lab11-debian sh scripts/verify-debian.sh
```

Native Linux: install the same prerequisites and run `sh scripts/build-linux.sh`.
The verifier scripts use `/work` as the repository mount point. For native
verification, mount or symlink the repository there first. Installation requires
root on Linux; the Docker containers run as root by default.

Validate the RPM with its real dependencies in a separate Fedora container:

```powershell
docker run --name 435l-lab11-fedora --mount "type=bind,source=$($PWD.Path),target=/work" -w /work -d fedora:43 sleep infinity
docker exec 435l-lab11-fedora sh scripts/verify-fedora.sh
```

Both Linux verifiers check installation, exact output, packaged documentation,
package integrity, removal and reinstallation. They leave the application
installed inside their containers. Run `docker stop 435l-lab11-debian
435l-lab11-fedora` when finished; no Linux packages are installed on Windows.

## Packaging decisions

MSI contains one feature and four explicitly identified components, using HKCU
registry key paths for reliable per-user installation. DEB contains `DEBIAN/control`
and a filesystem payload. RPM uses a SPEC file and a source tarball, and retains
the actual `x86_64` architecture rather than the handout's unsuitable `noarch`.
The Linux executable is installed under `/usr/local/bin` to follow the handout;
production distribution packages normally use `/usr/bin`.

The lab handout's wrapped command examples are formatted into separate valid
lines. The RPM source tarball and `%setup` layout agree; metadata dependency
checks are never bypassed with `--nodeps`. Windows and Linux packages are unsigned
educational artifacts, not production installers.

## Source archive and report

`scripts/finalize.ps1` creates `source.zip` and updates SHA-256 checksums.
`report/build_report.py` recreates the Word report from screenshots and verified
logs (Python packages: python-docx and Pillow). Report rendering uses the
document runtime's `render_docx.py`, LibreOffice and Poppler. These report tools
are not needed to compile or run either application.

Evidence screenshots are captures of actual command windows and Windows
Programs and Features, not fabricated terminal illustrations. The report
identifies Docker/container testing explicitly rather than claiming native
Debian or Fedora desktop testing.
### Container prerequisites

Include `file` in the Debian tool installation above: RPM's build-root processing
uses it. Debian slim images exclude most documentation by default; the DEB
verification script supplies targeted `--path-include` overrides so the actual
README, help and user guide are installed and hash-checked.

The WiX linker excludes only ICE91 (`-sice:ICE91`), the warning about per-user
file locations, because this package deliberately supports per-user installation
only. All other MSI validation checks run, and install/removal is independently
verified. Registry key paths are in HKCU; Windows Installer may register the
Programs and Features entry under HKCU or HKLM depending on its execution context.
