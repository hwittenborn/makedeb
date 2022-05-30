#!/usr/bin/env bash
set -e

# Handy env vars.
makedeb_url='makedeb.org'
color_normal="$(tput sgr0)"
color_bold="$(tput bold)"
color_green="$(tput setaf 77)"
color_orange="$(tput setaf 214)"
color_blue="$(tput setaf 14)"
color_red="$(tput setaf 202)"
color_purple="$(tput setaf 135)"

# Answer vars.
MAKEDEB_PKG='makedeb'

# Handy functions.
msg() {
    echo "${color_blue}[>]${color_normal} ${1}"
}

error() {
    echo "${color_red}[!]${color_normal} ${1}"
}

question() {
    echo "${color_purple}[?]${color_normal} ${1}"
}

die_cmd() {
    error "${1}"
    exit 1
}

answered_yes() {
    if [[ "${1}" == "" || "${1,,}" == "y" ]]; then
        return 0
    else
        return 1
    fi
}

# Pre-checks.
if [[ "${UID}" == "0" ]]; then
    die_cmd "This script is not allowed to be run under the root user. Please run as a normal user and try again."
fi

# Program start.
echo "-------------------------"
echo "${color_green}[#]${color_normal} ${color_orange}makedeb Installer${color_normal} ${color_green}[#]${color_normal}"
echo "-------------------------"

echo
msg "Ensuring needed packages are installed..."
if ! sudo apt-get update; then
    die_cmd "Failed to update APT cache."
fi

if ! sudo apt-get install gpg wget; then
    die_cmd "Failed to check if needed packages are installed."
fi

echo
msg "Multiple releases of makedeb are available for installation."
msg "Currently, you can install one of 'makedeb', 'makedeb-beta', or"
msg "'makedeb-alpha'."
msg "If you're not sure which one to choose, pick 'makedeb'."

while true; do
    read -p "$(question "Which release would you like? ")" response

    if [[ "${response}" != 'makedeb' && "${response}" != 'makedeb-beta' && "${response}" != 'makedeb-alpha' ]]; then
        error "Invalid response: ${response}"
        continue
    fi

    break
done

MAKEDEB_PKG="${response}"

msg "Setting up makedeb APT repository..."
if ! wget -qO - "https://proget.${makedeb_url}/debian-feeds/makedeb.pub" | gpg --dearmor | sudo tee /usr/share/keyrings/makedeb-archive-keyring.gpg 1> /dev/null; then
    die_cmd "Failed to set up makedeb APT repository."
fi
echo "deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://proget.${makedeb_url} makedeb main" | sudo tee /etc/apt/sources.list.d/makedeb.list 1> /dev/null

msg "Updating APT cache..."
if ! sudo apt-get update; then
    die_cmd "Failed to update APT cache."
fi

msg "Installing '${MAKEDEB_PKG}'..."
if ! sudo apt-get install -- "${MAKEDEB_PKG}"; then
    die_cmd "Failed to install package."
fi

msg "Finished! If you need help of any kind, feel free to reach out:"
echo
msg "${color_bold}makedeb Homepage:${color_normal}            https://${makedeb_url}"
msg "${color_bold}makedeb Package Repository:${color_normal}  https://mpr.${makedeb_url}"
msg "${color_bold}makedeb Documentation:${color_normal}       https://docs.${makedeb_url}"
msg "${color_bold}makedeb Support:${color_normal}             https://docs.${makedeb_url}/support/obtaining-support"
echo
msg "Enjoy makedeb!"

# vim: set sw=4 expandtab:
