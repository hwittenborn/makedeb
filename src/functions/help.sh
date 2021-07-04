help() {
    if [[ "${target_os}" == "debian" ]]; then
        echo "makedeb (${makedeb_package_version}) - Create Debian archives from PKGBUILDs"
        echo "Usage: makedeb [options]"
        echo
        echo "makedeb takes PKGBUILD files and builds archives installable with APT"
        echo
        echo "Options:"
        echo "  -d, --nodeps             Skip all dependency checks"
        echo "  -F, --file, -p           Specify a build file other than 'PKGBUILD'"
        echo "  -h, --help               Show this help menu and exit"
        echo "  -H, --field              Append the resulting control file with custom fields"
        echo "  -i, --install            Automatically install package(s) after building"
        echo "  -v, --distro-packages    Source package relationships from distro-specific variables when they exist"
        echo "  -V, --version            Print version information and exit"
        echo "  -s, --syncdeps           Install missing dependencies with APT"
        echo "  --verbose                Print (very) detailed logging"
        echo
        echo "The following options can be passed to makepkg:"
        echo "  --printsrcinfo           Print a generated .SRCINFO file and exit"
        echo "  --skippgpcheck           Do not verify source files against PGP signatures"
        echo
        echo "Report bugs at https://github.com/hwittenborn/makedeb"

    elif [[ "${target_os}" == "arch" ]]; then
        echo "makedeb (${makedeb_package_version}) - Create Debian archives from PKGBUILDs"
        echo "Usage: makedeb [options]"
        echo
        echo "makedeb takes PKGBUILD files and builds archives installable with APT"
        echo
        echo "Options:"
        echo "  -F, --file, -p    Specify a build file other than 'PKGBUILD'"
        echo "  -h, --help        Show this help menu and exit"
        echo "  -H, --field       Append the resulting control file with custom fields"
        echo "  -V, --version     Print version info and exit"
        echo "  --verbose         Print (very) detailed logging"
        echo
        echo "The following options can be passed to makepkg:"
        echo "  -d, --nodeps      Skip all dependency checks"
        echo "  -s, --syncdeps    Install missing dependencies with pacman"
        echo "  --printsrcinfo    Print a generated .SRCINFO file and exit"
        echo "  --skippgpcheck    Do not verify source files against PGP signatures"
        echo
        echo "Report bugs at https://github.com/hwittenborn/makedeb"
    fi
}
