load ../util/util

@test "correct license - all valid characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array license "custom: It's a % whaccky : what is this ? mess#!"
    pkgbuild clean
    makedeb -d
}
