Name:           helloworld-joey-saade
Version:        1.0.0
Release:        1%{?dist}
Summary:        Personalized Hello World for EECE 435L Lab 11
License:        LicenseRef-Lab-Educational
Source0:        %{name}-%{version}.tar.gz

%description
A compiled x86-64 Linux application by Joey Saade, student ID 202305993.
Prints Hello, World from Joey_Saade! and includes usage documentation.

%prep
%setup -q

%build
test -x helloworld

%install
install -D -m 0755 helloworld %{buildroot}/usr/local/bin/helloworld
install -d %{buildroot}%{_docdir}/%{name}
install -m 0644 README.md help.txt user_guide.txt %{buildroot}%{_docdir}/%{name}/

%files
/usr/local/bin/helloworld
%dir %{_docdir}/%{name}
%doc %{_docdir}/%{name}/README.md
%doc %{_docdir}/%{name}/help.txt
%doc %{_docdir}/%{name}/user_guide.txt

%changelog
* Mon Nov 23 2026 Joey Saade <jhs15@mail.aub.edu> - 1.0.0-1
- Initial laboratory package with executable and documentation.
