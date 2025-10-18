%global srcname gtimelog

Name: 		python-%{srcname}
Epoch:          1
Version: 	0.2.3
Release:	6%{?dist}
Summary: 	GTimeLog is a graphical (Gtk+) application for keeping track of time.

Group:		Office
License:	GPL
URL:		https://gitlab.collabora.com/collabora/gtimelog
Source0:	%{srcname}-%{version}.tar.gz
BuildArch:      noarch


%description
GTimeLog is a graphical (Gtk+) application for keeping track of time.

%package -n python3-%{srcname}
Summary:        GTimeLog is a graphical (Gtk+) application for keeping track of time.
BuildRequires:  python3-devel

%description -n python3-%{srcname}
GTimeLog is a graphical (Gtk+) application for keeping track of time.


%prep
%autosetup -n %{srcname}-%{version}

%build
%py3_build

%install
%py3_install
mkdir -p %{buildroot}/usr/share/pixmaps
cp src/%{srcname}/%{srcname}*.png %{buildroot}/usr/share/pixmaps
mkdir -p %{buildroot}/usr/share/applications
cp %{srcname}.desktop %{buildroot}/usr/share/applications

%files -n python3-%{srcname}
%defattr(-,root,root,-)
%doc
%{_bindir}/gtimelog
%{_bindir}/rltimelog
%{python3_sitelib}/%{srcname}-*.egg-info/
%{python3_sitelib}/%{srcname}/
%{_datadir}/applications/gtimelog.desktop
%{_datadir}/pixmaps/gtimelog.png

%changelog

