from robot.api.deco import keyword
from robot.api import logger

@keyword
def emit(*args):
    logger.debug(f'Emit called with argument tuple: {args}')
