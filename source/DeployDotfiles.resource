*** Settings ***
Library    OperatingSystem
Library    Process
Library    Dialogs
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
${PASSWORD} =    ${NONE}

*** Keywords ***
Run
    [Arguments]    @{command}
    ${result} =    Run Process    @{command}    shell=True
    Should Be Equal As Strings    ${result.rc}    0
    Should Be Empty    ${result.stderr}
    Log to Console    ${result.stdout}

Run Sudo
    [Arguments]    @{command}
    Run Keyword If    ${PASSWORD} is None
    ...    Get Password

   ${result} =    Run    printf    '%s\n'    ${PASSWORD}    |    sudo    -p    ''    -S    @{command}

Get Password
    ${password} =    Get Value From User    Enter Password For Sudo    hidden=True
    # Make sure user is only prompted for password once per run.
    Set Global Variable    ${PASSWORD}    ${password}

Enable Systemd Services
    [Arguments]    @{services}

    FOR    ${service}    IN    @{services}
        ${result} =    Run Process    systemctl    --quiet    is-enabled    ${service}
        Run Keyword If    ${result.rc} != 0
        ...    Run Sudo    systemctl    enable    --now    ${service}
    END

Arch Install
    [Arguments]    @{packages}

    FOR    ${package}    IN    @{packages}
        ${result} =    Run Process    pacman    -Q    ${package}
        Run Keyword If    ${result.rc} != 0
        ...    Run Sudo    pacman    --noconfirm    -S    ${package}
    END

Aur Install
    [Arguments]    @{packages}

    FOR    ${package}    IN    @{packages}
        ${result} =    Run Process    yay    -Q    ${package}
        Run Keyword If    ${result.rc} != 0
        ...    Run Sudo    yay    --noconfirm    -S    ${package}
    END

Brew Install
    [Arguments]    @{packages}
    Run    brew    install    @{packages}

Brew Cask Install
    [Arguments]    @{packages}
    Run    brew    cask    install    @{packages}

