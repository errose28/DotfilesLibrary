class EmitListener:
    ROBOT_LISTENER_API_VERSION = 2

    def start_keyword(self, name, attrs):
        if name == 'DotfilesLibrary.Emit':
            with open('/file', 'w+') as output_file:
                output_file.write(' '.join(attrs['args']))

