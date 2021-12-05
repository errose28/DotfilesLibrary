*** Settings ***
Resource    test.resource
Library    OperatingSystem
Library    DotfilesLibrary
Test Teardown    Clear Installers

*** Keywords ***
Clear Installers
    Remove Files
    ...    /installer1.out
    ...    /installer2.out
    ...    /installer3.out

Set Module Installers String
    [Arguments]    @{use args}
    Set Test Variable    ${INSTALLER}    Installers
    ${use string} =    Evaluate    ':'.join(@{use args})
    Set Test Variable    ${INSTALL_WITH}    ${use string}

Set Module Installers List
    [Arguments]    @{use args}
    Set Test Variable    ${INSTALLER}    Installers
    Set Test Variable    @{INSTALL_WITH}    @{use args}

Set Script Installers String
    [Arguments]    @{use args}
    Set Test Variable    ${INSTALLER}    ${CURDIR}${/}installers.sh
    ${use string} =    Evaluate    ':'.join(@{use args})
    Set Test Variable    ${INSTALL_WITH}    ${use string}

Set Script Installers List
    [Arguments]    @{use args}
    Set Test Variable    ${INSTALLER}    ${CURDIR}${/}installers.sh
    Set Test Variable    @{INSTALL_WITH}    @{use args}

*** Test Cases ***
Test With No Installers
    # Should log message, do nothing.
    Install    pkg1
    File Should Not Exist    /installer1.out
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out

Test With Installers Without Use
    # Should log warning, do nothing.
    Set Test Variable    ${INSTALLER}    notexist
    Install    pkg1
    File Should Not Exist    /installer1.out
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out

Test Without Installers With Use
    # Should log warning, do nothing.
    Set Test Variable    ${INSTALL_WITH}    notexist
    Install    pkg1
    File Should Not Exist    /installer1.out
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out

Test One Installer With Defaults
    Set Script Installers String    installer1

    Install    pkg1
    ${content} =    Get File    /installer1.out
    Should Be Equal As Strings    pkg1    ${content}
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out

Test One Installer With Alias
    Set Module Installers String    installer1

    # Should Install pkg_alias using installer1.
    ${alias} =    Set Variable    pkg_alias
    Install    pkg    installer1=${alias}
    ${content} =    Get File    /installer1.out
    Should Be Equal As Strings    ${alias}    ${content}
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out

Test One Installer With Multiple Alias Arguments
    Set Module Installers List    installer1

    @{args} =    Create List    arg1    arg2
    Install    pkg    installer1=${args}
    ${content} =    Get File    /installer1.out
    Should Be Equal As Strings    arg1 arg2    ${content}
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out

Test One Installer With Multiple Default Arguments
    Set Module Installers String    installer1

    Install    pkg1    pkg2    unused=foo
    ${content} =    Get File    /installer1.out
    Should Be Equal As Strings    pkg1 pkg2    ${content}
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out

Test One Installer With Alias Arguments Only
    Set Script Installers String    installer1

    Install    installer1=pkg1    installer2=pkg2
    ${content} =    Get File    /installer1.out
    Should Be Equal As Strings    pkg1    ${content}
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out

Test Two Installers Defaults
    Set Module Installers String    installer1    installer2

    # Should use installer1
    Install    pkg1
    ${content} =    Get File    /installer1.out
    Should Be Equal As Strings    pkg1    ${content}
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out

Test Two Installers With Unused Alias
    Set Module Installers List    installer1    installer2

    # Should use installer1
    Install    pkg1    installer2=foo
    ${content} =    Get File    /installer1.out
    Should Be Equal As Strings    pkg1    ${content}
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out

Test Two Installers But Skip The First
    Set Script Installers String    installer1    installer2

    # Should use installer2
    Install    pkg2    installer1=${None}
    ${content} =    Get File    /installer2.out
    Should Be Equal As Strings    pkg2    ${content}
    File Should Not Exist    /installer1.out
    File Should Not Exist    /installer3.out

Test Two Installers With Both Ignored
    Set Script Installers List    installer1    installer2

    # Should log warning, do nothing.
    Install    pkg3    installer1=${NONE}    installer2=${NONE}
    File Should Not Exist    /installer1.out
    File Should Not Exist    /installer2.out
    File Should Not Exist    /installer3.out
