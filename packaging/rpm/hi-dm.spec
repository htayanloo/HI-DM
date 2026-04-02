Name:           hi-dm
Version:        1.0.0
Release:        1%{?dist}
Summary:        HI-DM - Internet Download Manager

License:        MIT
URL:            https://github.com/htayanloo/Hi-DM
Source0:        %{name}-%{version}.tar.gz

Requires:       gtk3
Requires:       sqlite

%description
HI-DM is a full-featured Internet Download Manager built with Flutter.
Features include multi-threaded downloading, resume capability,
queue management, site grabber, and clipboard monitoring.

%prep
%setup -q

%install
mkdir -p %{buildroot}/usr/lib/hi-dm
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/applications

cp -r usr/lib/hi-dm/* %{buildroot}/usr/lib/hi-dm/
cp usr/bin/hi-dm %{buildroot}/usr/bin/
cp usr/share/applications/hi-dm.desktop %{buildroot}/usr/share/applications/

%files
/usr/lib/hi-dm/
/usr/bin/hi-dm
/usr/share/applications/hi-dm.desktop

%changelog
* Wed Apr 02 2026 HI-DM Team <hi-dm@example.com> - 1.0.0-1
- Initial release
