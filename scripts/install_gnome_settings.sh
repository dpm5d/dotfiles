#!/bin/bash


GSETTINGS=$(which gsettings 2>/dev/null)

if [ -z "$GSETTINGS" ]; then
    echo "gsettings not found! exiting ..."
    exit
else
    echo "gsettings detected: $GSETTINGS"
fi

function has_value
{
    local schema=$1
    local key=$2

    $GSETTINGS get $schema $key >/dev/null 2>&1

    return $?
}

function set_value
{
    local schema=$1
    local key=$2
    local value=$3

    echo "set [$schema] $key => $value"
    $GSETTINGS set $schema $key "$value"
}

function set_desktop_background
{
    set_value "org.gnome.desktop.background" "primary-color" "#656565"
    set_value "org.gnome.desktop.background" "secondary-color" "#000000"
    set_value "org.gnome.desktop.background" "color-shading-type" "solid"
    set_value "org.gnome.desktop.background" "picture-uri" ""
}

function set_desktop_interface_clock_show_date
{
    set_value "org.gnome.desktop.interface" "clock-show-date" true
}

function set_center_new_windows
{
    set_value "org.gnome.mutter" "center-new-windows" false
}

function set_use_alt_drag
{
    set_value "org.gnome.desktop.wm.preferences" "mouse-button-modifier" "<Alt>"
}

function set_dash_to_dock_defaults
{
    set_value "org.gnome.shell.extensions.dash-to-dock" "click-action" "minimize"
    set_value "org.gnome.shell.extensions.dash-to-dock" "dock-fixed" "false"

    # https://linuxconfig.org/how-to-customize-dock-panel-on-ubuntu-20-04-focal-fossa-linux
    set_value "org.gnome.shell.extensions.dash-to-dock" "extend-height" "false"
    set_value "org.gnome.shell.extensions.dash-to-dock" "dock-position" "BOTTOM"      # LEFT
    set_value "org.gnome.shell.extensions.dash-to-dock" "transparency-mode" "FIXED"   # FIXED
    set_value "org.gnome.shell.extensions.dash-to-dock" "dash-max-icon-size" "32"     # 48
    set_value "org.gnome.shell.extensions.dash-to-dock" "unity-backlit-items" "true"  # false
}

function set_desktop_interface_disable_animation
{
    set_value "org.gnome.desktop.interface" "enable-animations" false
}

function set_terminal_defaults
{
    echo "Setting terminal profile values"
    profiles=$(gsettings get org.gnome.Terminal.ProfilesList list \
                   | tr -d "[],'")

    for profile in $profiles
    do
        schema="org.gnome.Terminal.Legacy.Profile"
        profile_path="/org/gnome/terminal/legacy/profiles:/:$profile/"
        profile_name=$(gsettings get $schema:$profile_path visible-name)

        echo "$profile: $profile_name"

        set_value "$schema:$profile_path" "default-size-rows" 43
        set_value "$schema:$profile_path" "default-size-columns" 80

    done
}

function set_epiphany_defaults
{
    schema="org.gnome.Epiphany.web"
    profile="/org/gnome/epiphany/web/"

    has_value "$schema:$profile" "enable-smooth-scrolling"

    if [ ! $? -eq 0 ]; then
        echo "Epiphany not available"
    else
        set_value "$schema:$profile" "enable-smooth-scrolling" "false"
    fi
}

set_desktop_background
set_desktop_interface_clock_show_date
set_desktop_interface_disable_animation
set_use_alt_drag
set_center_new_windows
set_dash_to_dock_defaults
set_terminal_defaults
set_epiphany_defaults
