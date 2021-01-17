*** Settings ***
Resource    test.resource
Library     DotfilesLibrary

*** Test Cases ***
Test ~ In Target
    Set Target    ~
    Shallow Link    file

    Link Should Exist    ${CURDIR}${/}file    %{HOME}${/}file

