*** Settings ***
Resource    test.resource
Library    OperatingSystem
Library    DotfilesLibrary

*** Test Cases ***
Do Emit
    Emit    foo    1

Test Emit Listener
    ${content} =    Get File    /file
    Should Be Equal As Strings    foo 1    ${content}
    
