*** Settings ***
Resource    /test/lib/test.resource
Library    /test/lib/DotfilesLibrary
Test Setup    Setup

*** Keywords ***
Setup
    # Set a custom target for each test.
    ${target} =    Get Target
    Log    Target is ${target}    console=True
    Set Target    ${target}

Get Target
    # Generates a target directory for the current test.
    # This allows results to be examined after the test without colliding with other tests.
    [return]    ${TARGET BASE}${/}${TEST NAME}

*** Test Cases ***
Test Deep Link *
    ${TARGET} =    Get Target
    Deep Link    *

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file
    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}

Test Deep Link Some
    ${TARGET} =    Get Target
    Deep Link    file    dir

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    2    ${item_count}

Test Shallow Link *
    ${TARGET} =    Get Target
    Shallow Link    *

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir    ${TARGET}${/}dir
    Link Should Exist    ${CURDIR}${/}.hidden_dir    ${TARGET}${/}.hidden_dir
    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}

Test Shallow Link Some
    ${TARGET} =    Get Target
    Shallow Link    file    dir

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}dir    ${TARGET}${/}dir
    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    2    ${item_count}

Test Skip Mode Deep Link
    ${TARGET} =    Get Target
    Set Mode    skip

    # Create A top level file and a top level directory with a file in the target.
    Create File    ${TARGET}${/}file    content=file_content
    Create File    ${TARGET}${/}dir${/}dir_file    content=dir_file_content

    Deep Link    *

    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file

    # Check that existing files were not replaced with symlinks.
    ${file content} =    Get File    ${TARGET}${/}file
    Should Be Equal As Strings    file_content    ${file content}
    ${dir file content} =    Get File    ${TARGET}${/}dir${/}dir_file
    Should Be Equal As Strings    dir_file_content    ${dir file content}

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}

Test Replace Mode Deep Link
    ${TARGET} =    Get Target
    Set Mode    replace

    # Create A top level file and a top level directory with a file in the target.
    Create File    ${TARGET}${/}file    content=file_content
    Create File    ${TARGET}${/}dir${/}dir_file    content=dir_file_content

    Deep Link    *

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file
    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}

Test Backup Mode Deep Link
    ${TARGET} =    Get Target
    Set Mode    backup

    # Create A top level file and a top level directory with a file in the target.
    Create File    ${TARGET}${/}file    content=file_content
    Create File    ${TARGET}${/}dir${/}dir_file    content=dir_file_content

    Deep Link    *

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file

    # Check that backup files exist with the original contents.
    ${file content} =    Get File    ${TARGET}${/}file~1~
    Should Be Equal As Strings    file_content    ${file content}
    ${dir file content} =    Get File    ${TARGET}${/}dir${/}dir_file~1~
    Should Be Equal As Strings    dir_file_content    ${dir file content}

    ${item_count} =    Count Items In Directory    ${TARGET}
    # Extra backup file in top level directory was added.
    Should Be Equal As Integers    5    ${item_count}
