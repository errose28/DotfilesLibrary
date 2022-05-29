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
### Ignore with deep link and wildcard tests ###
Test Ignore All Hidden and Non Hidden
    ${TARGET} =    Get Target
    Add Ignore    *
    Deep Link    *

    Directory Should Not Exist    ${TARGET}

Test Ignore Leading *
    ${TARGET} =    Get Target
    Add Ignore    */subdir
    Deep Link    *

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file

    Directory Should Not Exist    ${TARGET}${/}dir${/}subdir

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}

Test Ignore Leading **
    ${TARGET} =    Get Target
    Add Ignore    **/subdir_file
    Deep Link    *

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file

    Directory Should Not Exist    ${TARGET}${/}dir${/}subdir
    File Should Not Exist    ${TARGET}${/}dir${/}subdir/subdir_file

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}

Test Ignore Middle **
    ${TARGET} =    Get Target
    Add Ignore    dir/**/subdir_file
    Deep Link    *

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file

    Directory Should Not Exist    ${TARGET}${/}dir${/}subdir
    File Should Not Exist    ${TARGET}${/}dir${/}subdir/subdir_file

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}

Test Ignore Trailing **
    ${TARGET} =    Get Target
    Add Ignore    dir/**
    Deep Link    *

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file

    Directory Should Not Exist    ${TARGET}${/}dir

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    3    ${item_count}

Test Ignore Trailing *
    ${TARGET} =    Get Target
    Add Ignore    dir/*
    Deep Link    *

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file

    Directory Should Not Exist    ${TARGET}${/}dir

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    3    ${item_count}

Test Ignore Single File
    ${TARGET} =    Get Target
    Add Ignore    dir/subdir/subdir_file
    Deep Link    *

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file

    File Should Not Exist    ${TARGET}${/}dir${/}subdir/subdir_file

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}

Test Ignore Single Directory
    ${TARGET} =    Get Target
    Add Ignore    dir/subdir
    Deep Link    *

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file

    Directory Should Not Exist    ${TARGET}${/}dir${/}subdir

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    4    ${item_count}

### Add and set ignore tests ###

Test Set Then Add Ignore Twice
    ${TARGET} =    Get Target
    Set Ignore    dir
    Add Ignore    file
    Add Ignore    .hidden_file
    Deep Link    *

    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file

    Directory Should Not Exist    ${TARGET}${/}dir
    File Should Not Exist    ${TARGET}${/}file
    File Should Not Exist    ${TARGET}${/}.hidden_file

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    1    ${item_count}

Test Add Then Set Ignore
    ${TARGET} =    Get Target
    Add Ignore    dir
    Set Ignore    file
    Deep Link    *

    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir${/}.hidden_dir_file    ${TARGET}${/}.hidden_dir${/}.hidden_dir_file
    # dir should have been cleared from the ignore list.
    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file
    Link Should Exist    ${CURDIR}${/}dir${/}subdir${/}subdir_file    ${TARGET}${/}dir${/}subdir${/}subdir_file

    File Should Not Exist    ${TARGET}${/}file

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    3    ${item_count}

Test Clear Ignore With No Arguments
    ${TARGET} =    Get Target
    Add Ignore    dir
    Set Ignore
    Deep Link    dir/dir_file

    Link Should Exist    ${CURDIR}${/}dir${/}dir_file    ${TARGET}${/}dir${/}dir_file

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    1    ${item_count}

### Ignore with shallow link tests ###

Test Ignore Shallow Link
    ${TARGET} =    Get Target
    Add Ignore    dir
    Shallow Link    *

    Link Should Exist    ${CURDIR}${/}file    ${TARGET}${/}file
    Link Should Exist    ${CURDIR}${/}.hidden_file    ${TARGET}${/}.hidden_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir    ${TARGET}${/}.hidden_dir

    Directory Should Not Exist    ${TARGET}${/}dir

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    3    ${item_count}

Test Ignore File In Shallow Link
    ${TARGET} =    Get Target
    Add Ignore    dir/dir_file
    Shallow Link    dir    .hidden_dir

    # When an ignore path is a subpath of a directory to be shallow linked, the ignore path should be disregarded.
    Link Should Exist    ${CURDIR}${/}dir    ${TARGET}${/}dir
    File Should Exist    ${TARGET}${/}dir${/}dir_file
    Directory Should Exist    ${TARGET}${/}dir${/}subdir
    File Should Exist    ${TARGET}${/}dir${/}subdir${/}subdir_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir    ${TARGET}${/}.hidden_dir

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    2    ${item_count}

Test Ignore Directory In Shallow Link
    ${TARGET} =    Get Target
    Add Ignore    dir/subdir
    Shallow Link    dir    .hidden_dir

    # When an ignore path is a subpath of a directory to be shallow linked, the ignore path should be disregarded.
    Link Should Exist    ${CURDIR}${/}dir    ${TARGET}${/}dir
    File Should Exist    ${TARGET}${/}dir${/}dir_file
    Directory Should Exist    ${TARGET}${/}dir${/}subdir
    File Should Exist    ${TARGET}${/}dir${/}subdir${/}subdir_file
    Link Should Exist    ${CURDIR}${/}.hidden_dir    ${TARGET}${/}.hidden_dir

    ${item_count} =    Count Items In Directory    ${TARGET}
    Should Be Equal As Integers    2    ${item_count}