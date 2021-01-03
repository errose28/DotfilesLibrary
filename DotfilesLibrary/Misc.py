import subprocess
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger

@keyword
def interactive(*cmd: str, fail_on_rc=False, shell=False) -> int:
    cmd_str = ' '.join(cmd)
    logger.info(cmd_str)

    # TODO: Determine if this prints stderr and if we can log it.
    rc = subprocess.call(cmd, shell=shell)

    if fail_on_rc and rc != 0:
        raise ValueError(cmd_str + ' failed with exit code ' + str(rc))

    return rc

@keyword
def enable_systemd_services(*services: str, now=True):
    now_arg = '--now' if now else ''

    for service in services:
        # Check if services are enabled first so user is not unnecessary prompted for password.
        is_enabled = (interactive('systemctl', '--quiet', 'is-enabled', service) == 0)
        if not is_enabled:
            interactive('systemctl', 'enable', now_arg, service, fail_on_rc=True)
