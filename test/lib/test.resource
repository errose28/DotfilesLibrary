*** Settings ***
Library    OperatingSystem
Library    Process

*** Variables ***
${TEST_BED}    ${/}test
${TARGET} =    ${TEST_BED}${/}target

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
