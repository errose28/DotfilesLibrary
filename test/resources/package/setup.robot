*** Settings ***
Resource    /test/lib/test.resource
Resource    /test/lib/DeployDotfiles.resource
Suite Setup    Set Cwd    ${CURDIR}

*** Test Cases ***
Test Deep Link
    Deep Link

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
