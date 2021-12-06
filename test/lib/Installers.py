# Check that robot can be accessed when this module is invoked.
import robot

def installer1(*args):
    with open('/installer1.out', 'w+') as out:
        out.write(' '.join(args))

def installer2(*args):
    with open('/installer2.out', 'w+') as out:
        out.write(' '.join(args))

def installer3(*args):
    with open('/installer3.out', 'w+') as out:
        out.write(' '.join(args))