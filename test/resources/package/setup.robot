*** Settings ***
Resource    /test/lib/test.resource
Resource    /test/lib/DeployDotfiles.resource
Suite Setup    Suite Setup
Test Teardown     Test Teardown

*** Keywords ***
Suite Setup
    Set Cwd    ${CURDIR}
    Set Ignore    ${SUITE SOURCE}
    Set Target    ${TARGET}

Test Teardown
    # Log to Console    Tearing down
    # Cannot empty the target, since that fails on symbolic link contents.
    Remove Directory   ${TARGET}    recursive=True

*** Test Cases ***
Test Deep Link All
    Deep Link

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file
    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}

Test Shallow Link All
    Shallow Link

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir    ${TARGET}${/}dir
    Link Should Exist    ${CURDIR}${/}.hidden_dir    ${TARGET}${/}.hidden_dir
    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}
