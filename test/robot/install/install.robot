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
    Run Process    sudo    pacman    -Rs    --noconfirm    jq

Test Pip Install
    Pip Install    jq
    ${result} =    Run Process    pip    show    jq
    Should Be Equal As Strings    ${result.rc}    0

    # Clean slate for future tests.
    Run Process    pip    uninstall    --yes    jq

Test Pip User Install
    Pip Install    jq    user=True
    ${result} =    Run Process    pip    show    jq
    Should Be Equal As Strings    ${result.rc}    0

    # Clean slate for future tests.
    Run Process    pip    uninstall    --yes    jq
