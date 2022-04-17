#!/bin/bash
#
#   depends.sh - Check the 'depends' array conforms to requirements.
#
#   Copyright (c) 2014-2021 Pacman Development Team <pacman-dev@archlinux.org>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_DEPENDS_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_DEPENDS_SH=1

LIBRARY=${LIBRARY:-'/usr/share/makepkg'}

source "$LIBRARY/lint_pkgbuild/fullpkgver.sh"
source "$LIBRARY/lint_pkgbuild/pkgname.sh"
source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/pkgbuild.sh"


lint_pkgbuild_functions+=('lint_depends')

lint_depends() {
	lint_deps 'depends' 'p' || return 1
}

lint_deps() {
	local ret=0
	local var="${1}"
	local valid_prefixes
	local depends_var_list
	local depends_list
	local deps
	local prefix
	local name
	local ver
	local i
	local j
	local k

	mapfile -t depends_var_list < <(get_extended_variables "${var}")
	mapfile -t valid_prefixes < <(echo "${2}" | sed 's| |\n|g' | head -c -1)

	for i in "${depends_var_list[@]}"; do
		depends_list="${i}[@]"
		depends_list=("${!depends_list}")

		for j in "${depends_list[@]}"; do
			mapfile -t deps < <(split_dep_by_pipe "${j}")

			for k in "${deps[@]}"; do
				prefix="$(echo "${k}" | grep '!' | grep -o '^[^!]*')"
				name="$(echo "${k}" | grep -o '^[^<>=]*')"
				ver="$(echo "${k}" | grep -o '[<>=].*$' | sed -E 's/<=|>=|=|<|>//')"

				if [[ "${prefix}" != "" ]] && ! in_array "${prefix}" "${valid_prefixes[@]}"; then
					error "$(gettext "Dependency '%s' under '%s' contains an invalid prefix: '%s'")" "${k}" "${i}" "${prefix}"
					ret=1
				fi

				lint_one_pkgname "${name}" || ret=1
				
				if [[ "${ver}"  != "" ]]; then
					check_pkgver "${ver}" || ret=1
				fi
			done
		done
	done

	return $ret
}
