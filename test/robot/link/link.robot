*** Settings ***
Resource    test.resource
Library     DotfilesLibrary
Test Setup    Setup

*** Keywords ***
Setup
    # Set a custom target for each test.
    ${target} =    Get Target
    Log    Target is ${target}    console=True
    Set Target    ${target}

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

    # Create a top level file and a top level directory with a file in the target.
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

    # Create a top level file and a top level directory with a file in the target.
    Create File    ${TARGET}${/}file    content=file_content
    Create File    ${TARGET}${/}dir${/}dir_file    content=dir_file_content

    Deep Link    *

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file
    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}

Test Replace Mode Shallow Link
    ${TARGET} =    Get Target
    Set Mode    replace

    # Create a top level file and a top level directory with a file in the target.
    Create File    ${TARGET}${/}file    content=file_content
    Create File    ${TARGET}${/}dir${/}other_file    content=other_file_content

    # Shallow linking dir should replace dir and its contents that exist at the target.
    Shallow Link    dir    file

    File Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}dir    ${TARGET}${/}dir
    File Should Exist    ${CURDIR}${/}dir${/}dir_file
    File Should Not Exist    ${CURDIR}${/}dir${/}other_file
    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    2    ${item_count}

Test Replace Broken Link Deep Link
    ${TARGET} =    Get Target
    Set Mode    replace
    # Creating broken symlink will not create intermediate directory.
    Create Directory    ${TARGET}
    # Break one of the symlinks and check that it will be replaced on another run.
    ${result} =    Run Process    ln    -s    foobar    ${TARGET}${/}file
    Should Be Equal As Strings    0    ${result.rc}
    Deep Link    ${CURDIR}${/}file
    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file

Test Replace Broken Link Shallow Link
    ${TARGET} =    Get Target
    Set Mode    replace
    # Creating broken symlink will not create intermediate directory.
    Create Directory    ${TARGET}
    # Break one of the symlinks and check that it will be replaced on another run.
    ${result} =    Run Process    ln    -s    foobar    ${TARGET}${/}dir
    Should Be Equal As Strings    0    ${result.rc}
    Shallow Link    dir
    Link Should Exist    ${CURDIR}${/}dir    ${TARGET}${/}dir

Test Replace Existing Link Deep Link
    ${TARGET} =    Get Target
    Set Mode    replace

    # Original targets for the symlinks.
    Create File    ${TARGET}${/}target${/}file
    Create Directory    ${TARGET}${/}target${/}dir
    Create File    ${TARGET}${/}target${/}dir${/}dir_file

    ${result} =    Run Process    ln    -s    ${TARGET}${/}target${/}file    ${TARGET}${/}file
    Should Be Equal As Strings    0    ${result.rc}
    ${result} =    Run Process    ln    -s    ${TARGET}${/}target${/}dir    ${TARGET}${/}dir
    Should Be Equal As Strings    0    ${result.rc}

    Deep Link    file    dir
    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    # Original links should have been replaced, but their targets should still be present.
    File Should Exist    ${TARGET}${/}target${/}file
    Directory Should Exist    ${TARGET}${/}target${/}dir
    File Should Exist    ${TARGET}${/}target${/}dir${/}dir_file

Test Replace Existing Link Shallow Link
    ${TARGET} =    Get Target
    Set Mode    replace

    # Original targets for the symlinks.
    Create File    ${TARGET}${/}target${/}file
    Create Directory    ${TARGET}${/}target${/}dir
    Create File    ${TARGET}${/}target${/}dir${/}dir_file

    ${result} =    Run Process    ln    -s    ${TARGET}${/}target${/}file    ${TARGET}${/}file
    Should Be Equal As Strings    0    ${result.rc}
    ${result} =    Run Process    ln    -s    ${TARGET}${/}target${/}dir    ${TARGET}${/}dir
    Should Be Equal As Strings    0    ${result.rc}

    Shallow Link    file    dir
    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}dir    ${TARGET}${/}dir
    File Should Exist    ${TARGET}${/}dir${/}dir_file
    # Original links should have been replaced, but their targets should still be present.
    File Should Exist    ${TARGET}${/}target${/}file
    Directory Should Exist    ${TARGET}${/}target${/}dir
    File Should Exist    ${TARGET}${/}target${/}dir${/}dir_file

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

Test Links When Passed Nonexistant Files
    ${TARGET} =    Get Target
    ${error} =     Set Variable    FileNotFoundError: /test/robot/link/nonexistant does not exist or has no glob matches.
    Run Keyword And Expect Error    ${error}    Deep Link    nonexistant
    Run Keyword And Expect Error    ${error}    Shallow Link    nonexistant
    # Even if only one of the inputs does not exist, an error should still be raised.
    Run Keyword And Expect Error    ${error}    Deep Link    dir    nonexistant
    Directory Should Not Exist    ${TARGET}/dir
    Run Keyword And Expect Error    ${error}    Shallow Link    nonexistant    dir
    Directory Should Not Exist    ${TARGET}/dir
