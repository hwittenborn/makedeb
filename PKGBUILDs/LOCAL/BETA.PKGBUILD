# Maintainer: Hunter Wittenborn: <hunter@hunterwittenborn.com>
_release_type=beta

# Used to obtain folder names for local repository
_gitdir=$(git rev-parse --show-toplevel)
_foldername=$(basename "${_gitdir}")

pkgname=makedeb-beta
pkgver={pkgver}
pkgrel=1
pkgdesc="Create Debian archives from PKGBUILDs (beta release)"
arch=('any')
license=('GPL3')
depends=('bash' 'binutils' 'tar' 'file' 'makedeb-makepkg-beta')
optdepends=('apt' 'git')
conflicts=('makedeb' 'makedeb-alpha')
provides=('makedeb')
url="https://github.com/makedeb/makedeb"

source=("git+file://${_gitdir}")
sha256sums=('SKIP')

package() {
    # Create single file for makedeb
    mkdir -p "${pkgdir}/usr/bin"
    cd "${srcdir}/${_foldername}"

    # Add bash shebang
    echo '#!/usr/bin/env bash' > "${pkgdir}/usr/bin/makedeb"

    # Copy functions
    for i in $(find "src/functions/"); do
        if ! [[ -d "${i}" ]]; then
            cat "${i}" >> "${pkgdir}/usr/bin/makedeb"
        fi
    done
    cat "src/makedeb.sh" >> "${pkgdir}/usr/bin/makedeb"

    chmod 555 "${pkgdir}/usr/bin/makedeb"

    # Set package version and build type
    sed -i "s|makedeb_package_version=.*|makedeb_package_version=${pkgver}|" "${pkgdir}/usr/bin/makedeb"
    sed -i "s|makedeb_release_type=.*|makedeb_release_type=${_release_type}|" "${pkgdir}/usr/bin/makedeb"

    # Remove testing commands
    sed -i 's|.*# REMOVE AT PACKAGING||g' "${pkgdir}/usr/bin/makedeb"
}