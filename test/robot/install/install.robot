*** Settings ***
Resource    test.resource
Library    OperatingSystem
Library    DotfilesLibrary

*** Keywords ***
Clear Installers
    Remove Files
    ...    /installer1.out
    ...    /installer2.out
    ...    /installer3.out

*** Test Cases ***
Test With No Installers
    # Should log message, do nothing.
    Install    pkg1
    File Should Not Exist    /installer1.out
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out

Test With One Installer
    Set Suite Variable    ${INSTALLER}    Installers:installer1

Test With Two Installers
    Set Suite Variable    ${INSTALLER}    Installers:installer1:installer2

    # Should use installer1
    Install    pkg1
    ${content} =    Get File    /installer1.out
    Should Be Equal As Strings    pkg1    ${content}
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out
    Clear Installers

    # Should use installer2
    Install    pkg2    installer1=${None}
    ${content} =    Get File    /installer2.out
    Should Be Equal As Strings    pkg2    ${content}
    File Should Not Exist    /installer1.out
    File Should Not Exist    /installer3.out
    Clear Installers

    # Should log warning, do nothing.
    Install    pkg3    installer1=${None}    installer2=${None}
    File Should Not Exist    /installer1.out
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out
    Clear Installers
