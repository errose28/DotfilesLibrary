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

### TEST TARGET ###

Test Target Global Config
    # Set target to something other than the default.
    ${new_target} =    Get Target
    Set Global Variable    ${TARGET}    ${new_target}
    Deep Link    file
    Link Should Exist    ${CURDIR}${/}file    ${new_target}${/}file
    File Should Not Exist    %{HOME}${/}file
    # Cleanup for following tests.
    Set Global Variable    ${TARGET}    ${EMPTY}

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

### TEST MODE ###

Test Mode Global Config
    # Set mode to something other than the default.
    Set Global Variable    ${MODE}    replace
    Create File    %{HOME}${/}file    content=file_content
    Deep Link    file
    File Should Exist    %{HOME}${/}file
    # File should have been replaced with an empty file.
    File Should Be Empty    %{HOME}${/}file
    # Cleanup for following tests.
    Set Global Variable    ${MODE}    ${EMPTY}

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
