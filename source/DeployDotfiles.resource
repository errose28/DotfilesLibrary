*** Settings ***
Library    OperatingSystem
Library    LinkDotfiles.py

*** Variables ***
# Modes: skip, repace, backup
# ${MODE} =    skip
# Interactive not yet implemented.
# ${INTERACTIVE} =    False
# ${VERBOSE} =     False

*** Keywords ***
Run
    [Arguments]    @{command}
    # Only print output to console in verbose mode.
    ${result} =    Run Process    @{command}    console=${VERBOSE}
    Should Be Equal As Strings    ${result.rc}    0
    Should Be Empty    ${result.stderr}

Enable Systemd Services
    [Arguments]    @{services}
    Run    Systemctl    enable   --now   @{services}

Arch Install
    [Arguments]    @{packages}
    Run    sudo    yay    --repo    -Syu    @{packages}

Aur Install
    [Arguments]    @{packages}
    Run    sudo    yay    --aur    -Syu    @{packages}

Brew Install
    [Arguments]    @{packages}
    Run    brew    install    @{packages}

Brew Cask Install
    [Arguments]    @{packages}
    Run    brew    cask    install    @{packages}
