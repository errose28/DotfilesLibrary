*** Settings ***
Resource    test.resource
Library     DotfilesLibrary
Library     OperatingSystem

*** Test Cases ***
# TODO: Figure out way to test by passing in stdin and reading stdout.
Test Return Code
    ${rc} =    Interactive    mkdir    -p    /foo/bar
    Directory Should Exist    /foo/bar
    Should Be Equal As Strings    ${rc}    0

    # Remove directories.
    ${rc} =    Interactive    rmdir    /foo/bar
    Should Be Equal As Strings    ${rc}    0
    Directory Should Not Exist    /foo/bar

    ${rc} =    Interactive    rmdir    /foo
    Should Be Equal As Strings    ${rc}    0
    Directory Should Not Exist    /foo

Test Fail On Return Code
    # By default, Interactive will not fail if the return code is non-zero.
    ${rc} =    Interactive    rmdir    /foo
    Should Not Be Equal As Strings    ${rc}    0

    Run Keyword And Expect Error    ValueError:*    Interactive    rmdir    /foo    fail_on_rc=True

Test Shell
    # Default is to not run commands in shell.
    Run Keyword And Expect Error    FileNotFoundError:*    Interactive    cd    /

    ${rc} =    Interactive    cd    /    shell=True
    Should Be Equal As Strings    ${rc}    0
