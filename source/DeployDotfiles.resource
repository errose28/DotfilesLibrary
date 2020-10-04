*** Settings ***
Library    OperatingSystem
Library    Process
Library    Dialogs
# Variables can be set on robot invocation to configure.
Library    LinkDotfiles.py    ${SUITE SOURCE}    target=${TARGET}    mode=${MODE}    ignore=${IGNORE}    verbose=${VERBOSE}

*** Variables ***
${TARGET} =    ${NONE}
${MODE} =    skip
${IGNORE} =    Create List
${VERBOSE} =     False

*** Keywords ***
Run
    [Arguments]    @{command}
    ${command str} =    Evaluate    ' '.join(@{command})
    Log    ${command str}    console=True
    Evaluate    subprocess.call(@{command})

Enable Systemd Services
    [Arguments]    @{services}    ${now}=True

    # Check if services are enabled first so user is not unnecessary prompted for password.
    FOR    ${service}    IN    @{services}
        ${result} =    Run Process    systemctl    --quiet    is-enabled    ${service}
        Run Keyword If    ${result.rc} != 0 and ${now}
        ...    Run    systemctl    enable    --now    ${service}
        Run Keyword If    ${result.rc} != 0 and not ${now}
        ...    Run    systemctl    enable    ${service}
    END

Arch Install
    [Arguments]    @{packages}

    # Check if packages are installed first so user is not unnecessary prompted for password.
    FOR    ${package}    IN    @{packages}
        ${result} =    Run Process    pacman    -Q    ${package}
        Run Keyword If    ${result.rc} != 0
        ...    Run    sudo    pacman    --noconfirm    -S    ${package}
    END

Aur Install
    [Arguments]    @{packages}

    # Check if packages are installed first so user is not unnecessary prompted for password.
    FOR    ${package}    IN    @{packages}
        ${result} =    Run Process    yay    -Q    ${package}
        Run Keyword If    ${result.rc} != 0
        ...    Run    yay    --noconfirm    -S    ${package}
    END

Pip Install
    [Arguments]    @{packages}
    # Pip will not reinstall packages already present.
    # Defaults to user level install.
    Run    pip    install    @{packages}

Brew Install
    [Arguments]    @{packages}
    # Homebrew will not reinstll packages already present.
    Run    brew    install    @{packages}

Brew Cask Install
    [Arguments]    @{packages}
    # Homebrew will not reinstll packages already present.
    Run    brew    cask    install    @{packages}

