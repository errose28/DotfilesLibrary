# Test that DotfilesLibrary utils can be used.
import DotfilesLibrary.Interactive

# Simulate install commands by writing output to files instead.

def installer1(pkg: str):
    with open('/installer1.out', 'w+') as out_file:
        out_file.write(pkg)

def installer2(pkg: str):
    with open('/installer2.out', 'w+') as out_file:
        out_file.write(pkg)

def installer3(pkg: str):
    with open('/installer3.out', 'w+') as out_file:
        out_file.write(pkg)