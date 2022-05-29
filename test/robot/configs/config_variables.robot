*** Settings ***
Resource    test.resource
Library     DotfilesLibrary
Test Teardown    Teardown

*** Keywords ***
Teardown
    # These tests operate on the home directory as a target.
    # Remove their testing file after each run.
    Remove File    %{HOME}${/}file

*** Test Cases ***
Test Default Target
    Deep Link    file
    Link Should Exist    ${CURDIR}${/}file    %{HOME}${/}file

Test ~ In Target
    Set Target    ~
    Shallow Link    file
    Link Should Exist    ${CURDIR}${/}file    %{HOME}${/}file

Test Reset Target
    Set Target    nonexistant_directory
    # Passing nothing should restore the default value (home directory).
    Set Target
    Deep Link    file
    Link Should Exist    ${CURDIR}${/}file    %{HOME}${/}file

Test Reset Mode
    Set Mode    Replace
    # Passing nothing should restore the default value (skip).
    Set Mode
    Create File    %{HOME}${/}file    content=file_content
    Deep Link    file
    File Should Exist    %{HOME}${/}file
    # Original contents should be present to indicate the file was not overwritten.
    ${contents} =    Get File     %{HOME}${/}file
    Should Be Equal As Strings    file_content    ${contents}
