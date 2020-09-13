*** Settings ***
Resource    /test/lib/test.resource
Resource    /test/lib/DeployDotfiles.resource
Test Setup    Setup

*** Keywords ***
Setup
    Set Cwd    ${CURDIR}
    Set Ignore    ${SUITE SOURCE}
    ${target} =    Get Target
    Log    Target is ${target}    console=True
    Set Target    ${target}

Get Target
    # Generates a target directory for the current test.
    # This allows results to be examined after the test without colliding with other tests.
    [return]    ${TARGET BASE}${/}${TEST NAME}

*** Test Cases ***
Test Deep Link All
    ${TARGET} =    Get Target
    Deep Link

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file
    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}

Test Shallow Link All
    ${TARGET} =    Get Target
    Shallow Link

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir    ${TARGET}${/}dir
    Link Should Exist    ${CURDIR}${/}.hidden_dir    ${TARGET}${/}.hidden_dir
    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}
