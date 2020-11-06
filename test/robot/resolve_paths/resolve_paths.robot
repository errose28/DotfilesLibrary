*** Settings ***
Resource    /test/lib/test.resource
Library    /test/lib/DotfilesLibrary

*** Test Cases ***
Test ~ In Target
    Set Target    ~
    Shallow Link    file

    Link Should Exist    ${CURDIR}${/}file    %{HOME}${/}file

