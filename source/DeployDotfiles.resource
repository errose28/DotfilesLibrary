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

*** Keywords ***
Run
    [Arguments]    @{command}
    ${result} =    Run Process    @{command}    shell=True
    Log to Console    ${result.stdout}
    Log to Console    ${result.stderr}
    Should Be Equal As Strings    ${result.rc}    0
    Should Be Empty    ${result.stderr}

Run Sudo
    [Arguments]    @{command}

    # Returns None if PASSWORD is not set.
    ${PASSWORD} =    Get Variable Value    \${PASSWORD}
    Run Keyword If    ${PASSWORD} is ${NONE}
    ...    Set Password

   ${result} =    Run    printf    '%s\n'    ${PASSWORD}    |    sudo    -p    ''    -S    @{command}

Set Password
    ${password} =    Get Value From User    Enter Password For Sudo    hidden=True
    # Make sure user is only prompted for password once per run.
    Set Global Variable    ${PASSWORD}    ${password}

Enable Systemd Services
    [Arguments]    @{services}    ${now}=True

    FOR    ${service}    IN    @{services}
        ${result} =    Run Process    systemctl    --quiet    is-enabled    ${service}
        Run Keyword If    ${result.rc} != 0 and ${now}
        ...    Run Sudo    systemctl    enable    --now    ${service}
        Run Keyword If    ${result.rc} != 0 and not ${now}
        ...    Run Sudo    systemctl    enable    ${service}
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

Pip Install
    [Arguments]    @{packages}
    # Pip will not reinstall packages already present.
    Run    pip    install    @{packages}

Brew Install
    [Arguments]    @{packages}
    Run    brew    install    @{packages}

Brew Cask Install
    [Arguments]    @{packages}
    Run    brew    cask    install    @{packages}

