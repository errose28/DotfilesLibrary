*** Settings ***
Library    OperatingSystem
Library    Process
# Variables can be set on robot invocation to configure.
Library    LinkDotfiles.py    ${SUITE SOURCE}    target=${TARGET}    mode=${MODE}    ignore=${IGNORE}    verbose=${VERBOSE}

*** Variables ***
${TARGET} =    ${NONE}
# Modes: skip, repace, backup
${MODE} =    skip
${IGNORE} =    Create List
${VERBOSE} =     False
# Interactive not yet implemented.
# ${INTERACTIVE} =    False

*** Keywords ***
Run
    [Arguments]    @{command}
    # Could optionally specify to run in a shell if need be.
    ${result} =    Run Process    @{command}
    Should Be Equal As Strings    ${result.rc}    0
    Should Be Empty    ${result.stderr}

Enable Systemd Services
    [Arguments]    @{services}
    FOR    ${service}    IN    @{services}
        Run    systemctl    --quiet    is-enabled    ${service}    ||    systemctl    enable    --now    ${service}
    END

Arch Install
    [Arguments]    @{packages}
    FOR    ${package}    IN    @{packages}
        Run    pacman    -Q    ${package}    ||    sudo    pacman    --noconfirm    -Syu    ${package}
    END

Aur Install
    [Arguments]    @{packages}
    FOR    ${package}    IN    @{packages}
        Run    yay    -Q    ${package}    ||    yay    --noconfirm    --aur    -Syu    ${package}
    END

Brew Install
    [Arguments]    @{packages}
    Run    brew    install    @{packages}

Brew Cask Install
    [Arguments]    @{packages}
    Run    brew    cask    install    @{packages}

