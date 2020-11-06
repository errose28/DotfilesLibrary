*** Settings ***
Library    OperatingSystem
Library    Process

*** Variables ***
${TEST BED}    ${/}test
${TARGET BASE} =    ${TEST BED}${/}targets

*** Keywords ***
Command Should Succeed
    [Arguments]    ${result}
    Should Be Empty    ${result.stderr}
    Should Be Equal As Strings    ${result.rc}    0

Link Should Exist
    [Arguments]    ${dest}    ${link}
    # Link can be to a file or directory.
    Should Exist    ${dest}
    Should Exist    ${link}
    ${result} =    Run Process    readlink    ${link}
    Command Should Succeed    ${result}
    Should Be Equal    ${result.stdout}    ${dest}

Program Should Be Installed
    [Arguments]    ${program}
    ${result} =    Run Process    command    -v    ${program}    shell=True
    Command Should Succeed    ${result}

Program Should Not Be Installed
    [Arguments]    ${program}
    ${result} =    Run Process    command    -v    ${program}    shell=True
    Should Not Be Equal As Strings    ${result.rc}    0
