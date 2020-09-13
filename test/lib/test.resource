*** Settings ***
Library    OperatingSystem
Library    Process

*** Variables ***
${TEST_BED}    ${/}test
# Home directory of docker container is default target.
${TARGET}    ${/}root

*** Keywords ***
Command Should Succeed
    [Arguments]    ${result}
    Should Be Empty    ${result.stderr}
    Should Be Equal As Strings    ${result.rc}    0

Link Should Exist
    [Arguments]    ${dest}    ${link}
    File Should Exist    ${dest}
    File Should Exist    ${link}
    ${result} =    Run Process    readlink    ${link}
    Command Should Succeed    ${result}
    Should Be Equal    ${result.stdout}    ${dest}
