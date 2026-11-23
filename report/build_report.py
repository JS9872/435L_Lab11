from pathlib import Path
import json

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor
from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'deliverables' / 'Lab11_Report_Joey_Saade.docx'
QA = ROOT / 'report' / 'qa'
QA.mkdir(parents=True, exist_ok=True)
document = Document()
section = document.sections[0]
section.page_width = Inches(8.5)
section.page_height = Inches(11)
section.top_margin = section.bottom_margin = Inches(1)
section.left_margin = section.right_margin = Inches(1)
section.header_distance = section.footer_distance = Inches(0.492)

TOKENS = {
    'Normal': (11, '202124', 0, 6, 1.25),
    'Title': (28, '0B2545', 0, 12, 1.1),
    'Subtitle': (13, '555555', 0, 8, 1.25),
    'Heading 1': (16, '2E74B5', 18, 10, 1.25),
    'Heading 2': (13, '2E74B5', 14, 7, 1.25),
    'Heading 3': (12, '1F4D78', 10, 5, 1.25),
    'Caption': (9, '555555', 4, 6, 1.1),
}
for name, (size, color, before, after, spacing) in TOKENS.items():
    style = document.styles[name]
    style.font.name = 'Calibri'
    style.font.size = Pt(size)
    style.font.color.rgb = RGBColor.from_string(color)
    style.paragraph_format.space_before = Pt(before)
    style.paragraph_format.space_after = Pt(after)
    style.paragraph_format.line_spacing = spacing
    if name.startswith('Heading'):
        style.font.bold = True
        style.paragraph_format.keep_with_next = True

code_style = document.styles.add_style('Lab Code', 1)
code_style.font.name = 'Consolas'
code_style.font.size = Pt(9)
code_style.paragraph_format.space_before = Pt(0)
code_style.paragraph_format.space_after = Pt(5)
code_style.paragraph_format.line_spacing = 1

header = section.header.paragraphs[0]
header.text = 'EECE 435L  |  LAB 11                                      JOEY SAADE'
header.style = document.styles['Caption']
footer = section.footer.paragraphs[0]
footer.alignment = WD_ALIGN_PARAGRAPH.RIGHT
footer.style = document.styles['Caption']
footer.add_run('Configuration and Deployment Tools  |  ')
field = OxmlElement('w:fldSimple')
field.set(qn('w:instr'), 'PAGE')
footer._p.append(field)


def paragraph(text, style=None):
    return document.add_paragraph(text, style)


def page(title):
    document.add_page_break()
    document.add_heading(title, 1)


def code(text):
    paragraph(text, 'Lab Code')


def figure(filename, caption, graphical=False):
    source = ROOT / 'evidence' / 'screenshots' / filename
    image = Image.open(source).convert('RGB')
    if graphical:
        image = image.crop((0, 0, image.width, min(image.height, 460)))
    else:
        content = image.crop((8, 38, image.width - 35, image.height - 15))
        background = Image.new('RGB', content.size, (12, 12, 12))
        difference = ImageChops.difference(content, background).convert('L')
        box = difference.point(lambda value: 255 if value > 65 else 0).getbbox()
        if box:
            right = max(650, box[2] + 35)
            bottom = box[3] + 65
            image = image.crop((0, 0, min(image.width, right), min(image.height, bottom)))
    target = QA / filename
    image.save(target)
    width = min(6.5, 5.1 * image.width / image.height)
    picture = paragraph('')
    picture.paragraph_format.space_after = Pt(0)
    picture.paragraph_format.keep_with_next = True
    shape = picture.add_run().add_picture(str(target), width=Inches(width))
    shape._inline.docPr.set('descr', caption)
    paragraph(caption, 'Caption')


properties = json.loads((ROOT / 'evidence/logs/msi-properties.json').read_text(encoding='utf-8-sig'))
document.core_properties.author = 'Joey Saade'
document.core_properties.last_modified_by = 'Joey Saade'
document.core_properties.title = 'EECE 435L Lab 11 - Configuration and Deployment Tools'
document.core_properties.subject = 'MSI, DEB and optional RPM packaging with installation evidence'

title = paragraph('LAB 11\nConfiguration and\nDeployment Tools', 'Title')
title.paragraph_format.space_before = Pt(25)
paragraph('MSI, DEB and RPM packaging', 'Subtitle')
paragraph('American University of Beirut\nFaculty of Engineering and Architecture\nSoftware Tools Lab | Fall 2026–2027')
paragraph('Joey Saade\nStudent ID: 202305993\njhs15@mail.aub.edu\n23 November 2026')
document.add_heading('Objective and scope', 1)
paragraph('Prepare a personalized Hello World application, package its executable and documentation, '
          'and verify deployment and removal. Both graded formats (MSI and DEB) are included, '
          'together with the optional RPM and source RPM.')
document.add_heading('Execution environment', 2)
paragraph('Windows x64: .NET Framework C# compiler and portable WiX Toolset 3.14.1. '
          'Linux: Debian 12 (bookworm), GCC 12.2.0, dpkg-deb 1.21.23 and rpmbuild 4.18.0. '
          'RPM installation is checked separately in Fedora 43. Debian and Fedora run in '
          'isolated Docker containers; the MSI is installed on the actual Windows host.')
paragraph('Repository: https://github.com/JS9872/435L_Lab11')

page('1. Application and package design')
paragraph('Both programs print the exact greeting below and return exit status 0. They require '
          'no arguments, configuration, network access, or user input.')
code('Hello, World from Joey_Saade!')
document.add_heading('Windows implementation (C#)', 2)
code((ROOT / 'src/windows/HelloWorld.cs').read_text().strip())
document.add_heading('Linux implementation (C)', 2)
code((ROOT / 'src/linux/helloworld.c').read_text().strip())
document.add_heading('Common package contents', 2)
paragraph('Each installer includes the compiled executable, README.md, help.txt and user_guide.txt. '
          'The README describes runtime requirements; help gives invocation and expected output; '
          'the user guide explains installation, verification, removal and file locations.')
paragraph('MSI uses Windows Installer database tables and an embedded cabinet. DEB is an ar archive '
          'containing a format marker, control archive and payload archive. RPM combines a header '
          'with a compressed payload, guided by the SPEC file. None of these educational packages is signed.')

page('2. Windows MSI creation')
paragraph('The C# compiler builds an x64 executable. WiX candle compiles Product.wxs into an object; '
          'light links the object and embedded payload into the MSI. Figure 1 captures the actual build.')
figure('01-windows-build.png', 'Figure 1. Actual C# and WiX build; final MSI artifact and successful validation.')
document.add_heading('Features, components and directories', 2)
paragraph('The Complete feature selects four components: Application, Readme, Help and UserGuide. '
          'Each component has a stable GUID and an HKCU registry key path. Components are the '
          'atomic installation units; features group components for installation selection.')
paragraph('The directory hierarchy is LocalAppDataFolder / Programs / JoeySaadeHelloWorld. '
          'The MSI requests a limited, per-user installation. RemoveFolder entries remove only '
          'empty installer-created directories during uninstall, not unrelated user files.')
paragraph('ICE91 alone is excluded because its warning concerns the deliberately chosen per-user '
          'file locations. All other MSI validation checks remain enabled; validation is not '
          'globally disabled with -sval. Install and uninstall are checked independently.')

page('3. MSI installation and execution')
paragraph('The verifier reads MSI properties using Windows Installer COM, invokes msiexec, checks '
          'exit code 0, executes the installed program, and compares all three installed documents '
          'against the originals using SHA-256.')
figure('02-windows-verification.png', 'Figure 2. MSI installation, personalized output, installed files and lifecycle checks.')
paragraph('Product: ' + properties['ProductName'] + ' | Version: ' + properties['ProductVersion'])
code('ProductCode: ' + properties['ProductCode'])
paragraph('The ProductCode identifies this MSI build. The UpgradeCode stays constant across product '
          'versions. Publisher is Joey Saade. ARPHELPLINK supplies the maintainer email, while '
          'ARPCOMMENTS records the course and student ID.')
paragraph('The verification removes the application and checks that its executable and uninstall '
          'registration disappear, then reinstalls the same final MSI. The application is left installed.')

page('4. Windows installed-program evidence')
paragraph('Programs and Features provides independent graphical evidence that the installed MSI '
          'registers the application with Windows, using the intended display name, publisher and version.')
figure('03-programs-and-features.png', 'Figure 3. Windows Control Panel, filtered to the installed Hello World package.', graphical=True)
document.add_heading('Installed locations and use', 2)
code('%LOCALAPPDATA%\\Programs\\JoeySaadeHelloWorld\\\n  helloworld.exe\n  README.md\n  help.txt\n  user_guide.txt')
code('& "$env:LOCALAPPDATA\\Programs\\JoeySaadeHelloWorld\\helloworld.exe"')
paragraph('Windows Installer maintains the installed-program registration; the verifier accepts '
          'the actual HKCU or HKLM uninstall entry according to installer execution context. '
          'Application component key paths remain in HKCU. No global PATH setting is changed.')

page('5. Debian package creation and metadata')
paragraph('GCC compiles the C source with -Wall -Wextra -Werror. A staging tree contains DEBIAN/control, '
          'DEBIAN/md5sums, the executable and documentation. dpkg-deb builds the final amd64 package '
          'with root-owned payload entries.')
figure('04-debian-build.png', 'Figure 4. Actual GCC/dpkg-deb commands, control metadata and packaged file listing.')
paragraph('The control file defines Package, Version, Section, Priority, Architecture, Maintainer, '
          'Depends and Description. Architecture is amd64; libc6 >= 2.34 reflects the executable’s '
          'glibc requirement. The complete control file is submitted in packaging/debian/control.')
paragraph('DEBIAN is build-time package metadata, not an installed application directory. The payload '
          'places helloworld in /usr/local/bin and documents in /usr/share/doc/helloworld-joey-saade. '
          'The /usr/local/bin choice follows the handout; production distribution packages normally use /usr/bin.')

page('6. Debian installation and execution')
paragraph('The final DEB is installed with dpkg in the Debian container. dpkg -l shows the ii '
          '(installed) status, and dpkg -s confirms metadata. The installed executable prints '
          'the exact greeting. Document comparisons and dpkg -V check payload integrity.')
figure('05-debian-verification.png', 'Figure 5. DEB installation, installed-package status, output and remove/reinstall verification.')
paragraph('Debian slim images normally exclude most /usr/share/doc content. Targeted --path-include '
          'options in the verifier preserve this package’s documentation during installation; '
          'all three files are checked rather than merely assuming installation succeeded.')
paragraph('After removal, /usr/local/bin/helloworld must no longer exist. The package is then '
          'reinstalled. All these checks pass inside Debian 12; this is not a claim of testing '
          'on a separate native Linux desktop or VM.')

page('7. Optional RPM creation')
paragraph('The same compiled Linux application is placed with its documentation into a matching '
          'helloworld-joey-saade-1.0.0 source directory and tarball. rpmbuild -ba creates both '
          'the binary RPM and source RPM.')
figure('06-rpm-build.png', 'Figure 6. Actual rpmbuild result, x86_64 RPM metadata and payload file listing.')
document.add_heading('Role of the SPEC file', 2)
paragraph('Name, Version, Release, Summary, License and Source0 describe the package. %description '
          'supplies its long description. %prep unpacks the source archive; %build checks the '
          'prepared binary; %install stages files under buildroot; %files declares installed '
          'payload paths and documentation; %changelog records the initial release.')
paragraph('The handout’s noarch example is unsuitable for a compiled x86-64 executable, so the '
          'package retains x86_64 architecture. Source0 and %setup use the same tarball layout, '
          'and RPM automatically records the executable’s actual glibc dependencies.')

page('8. Optional RPM installation and execution')
paragraph('The final binary RPM is installed in Fedora 43 using rpm -ivh, without --nodeps or '
          'other dependency bypasses. rpm -qi and rpm -ql verify the installed package and files.')
figure('07-rpm-verification.png', 'Figure 7. Fedora RPM installation, metadata, personalized output and lifecycle verification.')
paragraph('The verifier checks the greeting, compares document SHA-256 hashes, runs rpm -V, removes '
          'the package and confirms executable removal, then reinstalls it. All checks pass. '
          'The unsigned package is suitable for this lab, not a trusted production repository.')

page('9. Results and submission checklist')
document.add_heading('Verified results', 2)
paragraph('MSI: build and validation pass; install returns 0; personalized execution and document '
          'hashes pass; installed-program registration is present; uninstall and reinstall pass.')
paragraph('DEB: build and metadata inspection pass; Debian installation, ii status, greeting, '
          'document comparisons, dpkg integrity verification, removal and reinstall pass.')
paragraph('RPM: binary and source packages build; Fedora resolves the generated dependencies; '
          'installation, greeting, document hashes, rpm integrity verification, removal and reinstall pass.')
document.add_heading('Submitted artifacts', 2)
for name in ('helloworld_joey_saade.msi', 'helloworld_joey_saade.deb', 'helloworld_joey_saade.rpm', 'helloworld_joey_saade.src.rpm'):
    artifact = ROOT / 'deliverables' / name
    paragraph(f'{name} — {artifact.stat().st_size:,} bytes', 'Lab Code')
paragraph('Also submitted: source.zip, this Word report, SHA256SUMS.txt, README compilation and '
          'execution instructions, all packaging metadata, raw command transcripts and seven '
          'actual-window screenshots. SHA256SUMS.txt is the authoritative checksum manifest.')
document.add_heading('Conclusion', 2)
paragraph('Installation packages combine application payloads with machine-readable metadata and '
          'defined filesystem destinations. MSI expresses features and components; DEB separates '
          'control information from the payload; RPM uses its SPEC to define preparation, staging '
          'and ownership. Successful deployment is demonstrated by installed-package queries, '
          'execution and file-integrity checks—not by package creation alone.')
document.add_heading('Reference', 2)
paragraph('Course handout: Lab 11-Configurations.docx, “Configuration and Deployment Tools,” '
          'EECE 435L Software Tools Lab, Fall 2026–2027. The handout’s wrapped commands and RPM '
          'architecture/source-layout issues are corrected in the submitted build scripts.')

document.save(OUTPUT)
assert len(document.inline_shapes) == 7
assert section.page_width.twips == 12240 and section.left_margin.twips == 1440
print(f'Created {OUTPUT}; 7 embedded screenshots; compact_reference_guide preset, editorial_cover header.')
