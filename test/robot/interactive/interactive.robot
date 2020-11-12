*** Settings ***
Resource    /test/lib/test.resource
Library    /test/lib/DotfilesLibrary
Library    OperatingSystem

*** Test Cases ***
# TODO: Figure out way to test by passing in stdin and reading stdout.
# TODO: Figure out way assert that test fails when bad command is run with fail_on_rc=True.
Test Return Code
    ${rc} =    Interactive    mkdir    -p    /foo/bar
    Directory Should Exist    /foo/bar
    Should Be Equal As Strings    ${rc}    0

    # By default, Interactive will not fail if the return code is non-zero.
    ${rc} =    Interactive    rmdir    /foo
    Should Not Be Equal As Strings    ${rc}    0

    # Remove directories.
    ${rc} =    Interactive    rmdir    /foo/bar
    Should Be Equal As Strings    ${rc}    0
    Directory Should Not Exist    /foo/bar

    ${rc} =    Interactive    rmdir    /foo
    Should Be Equal As Strings    ${rc}    0
    Directory Should Not Exist    /foo

