%define name swath
%define version 0.3.1
%define release 1
%define manifest %{_builddir}/%{name}-%{version}-%{release}.manifest

Summary: Thai word segmentation program
Name: %{name}
Version: %{version}
Release: %{release}
License: GPL
Group: Applications/Text
Source: %{name}-%{version}.tar.gz
BuildRoot: /var/tmp/%{name}-%{version}
Vendor: Phaisarn Charoenpornsawat <phaisarn@nectec.or.th>, Theppitak Karoonboonyanan <thep@links.nectec.or.th>, NECTEC
Packager: Theppitak Karoonboonyanan <thep@links.nectec.or.th>
Distribution: Linux TLE, Thai Linux Working Group

%description
SWATH (Smart Word Analysis for THai) is a word segmentation program
which is capable of handling various input formats, such as HTML,
RTF and LaTeX. Algorithm for word segmentation can also be chosen.

%prep
%setup

%build
./configure --prefix=/usr --datadir=/usr/share/swath
make

%install
mkdir -p $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT

# __os_install_post is implicitly expanded after the
# install section... do it now, and then disable it,
# so all work is done before building manifest.

%{?__os_install_post}
%define __os_install_post %{nil}

# build the file list automagically into %{manifest}

cd $RPM_BUILD_ROOT
rm -f %{manifest}
find . -type d \
        | sed '1,2d;s,^\.,\%attr(-\,root\,root) \%dir ,' >> %{manifest}
find . -type f \
        | sed 's,^\.,\%attr(-\,root\,root) ,' >> %{manifest}
find . -type l \
        | sed 's,^\.,\%attr(-\,root\,root) ,' >> %{manifest}

%clean
rm -fr $RPM_BUILD_DIR/%{name}-%{version}
rm -fr $RPM_BUILD_ROOT

%files -f %{manifest}
%defattr(-,root,root)
%doc README AUTHORS COPYING
#%docdir
#%config

%changelog
* Tue Jan 14 2003 Theppitak Karoonboonyanan <thep@linux.thai.net>
  - Fix "%install" mess in comment (rpmbuild oddity)

* Fri Dec 21 2001 Theppitak Karoonboonyanan <thep@links.nectec.or.th>
  - First build RPM package

