*** Settings ***
Resource    /test/lib/test.resource
Library    Process
Library    /test/lib/DotfilesLibrary

*** Test Cases ***
Test Pacman Install
    Pacman Install    jq

    ${result} =    Run Process    pacman   -Q    jq
    Should Be Equal As Strings    ${result.rc}    0

    # Clean slate for future tests.
    Run    sudo    pacman    -Rs    --noconfirm    jq

Test Skip Pacman Install
    ${SKIP_INSTALL} =    Set Variable    ${TRUE}
    Pacman Install    jq

    ${result} =    Run Process    pacman   -Q    jq
    Should Be Equal As Strings    ${result.rc}    1

Test Pip Install
    Pip Install    jq
    ${result} =    Run Process    pip    show    jq
    Should Be Equal As Strings    ${result.rc}    0

    # Clean slate for future tests.
    Run    pip    uninstall    --yes    jq

Test Skip Pip Install
    ${SKIP_INSTALL} =    Set Variable    ${TRUE}
    Pip Install    jq

    ${result} =    Run Process    pip    show    jq
    Should Be Equal As Strings    ${result.rc}    1
