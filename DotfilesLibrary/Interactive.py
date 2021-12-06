import subprocess
from robot.api.deco import keyword
from robot.api import logger

@keyword
def interactive(*cmd: str, fail_on_rc=False, shell=False) -> int:
    cmd_str = ' '.join(cmd)
    logger.debug(f'Executing `{cmd_str}`')

    # TODO: Determine if this prints stderr and if we can log it.
    rc = subprocess.call(cmd, shell=shell)

    if fail_on_rc and rc != 0:
        raise ValueError(f'`{cmd_str}` failed with exit code {rc}')

    return rc
