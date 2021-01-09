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
def enable_systemd_services(*services: str, user=False, now=True):
    now_flag = '--now' if now else None
    user_flag = '--user' if user else None

    for service in services:
        # Check if services are enabled first so user is not unnecessary prompted for password.
        is_enabled = (interactive('systemctl', '--quiet', 'is-enabled', service) == 0)

        if not is_enabled:
            cmd = ['systemctl']
            if user_flag:
                cmd += [user_flag]
            cmd += ['enable']
            if now_flag:
                cmd += [now_flag]
            cmd += [service]

            interactive(*cmd, fail_on_rc=True)
