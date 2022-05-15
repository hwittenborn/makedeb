load ../util/util

@test "correct makedepends - all valid characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array makedepends 'bats>0' 'bash'
    pkgbuild clean
    makedeb -d
}

@test "correct makedepends - install missing dependencies" {
    skip "THIS IS CURRENTLY FAILING DUE TO A BUG IN MAKEDEB."
    sudo_check
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array makedepends 'zsh' 'yash>=0.0.1'
    pkgbuild clean
    makedeb -s --no-confirm --allow-downgrades
}

@test "correct makedepends - don't add to 'Depends' in control file" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array makedepends 'zsh' 'yash>=0.0.1'
    pkgbuild clean
    makedeb -d
    [[ "$(cat pkg/testpkg/DEBIAN/control | grep 'Depends:')" == "" ]]
}

@test "correct makedepends - remove installed build dependencies" {
    skip "Awaiting packaging of Bats and Bats libraries on the MPR"
    sudo_check
    sudo apt-get purge restic -y
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array makedepends restic
    pkgbuild clean
    makedeb -sr --no-confirm --allow-downgrades

    run dpkg -s restic
    [[ "${lines[0]}" == "dpkg-query: package 'restic' is not installed and no information is available" ]]
}

@test "incorrect makedepends - invalid dependency prefix" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array makedepends 'z!bats'
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] Dependency 'z!bats' under 'makedepends' contains an invalid prefix: 'z'" ]]
}
