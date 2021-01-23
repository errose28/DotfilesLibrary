from setuptools import setup

setup(
  name = 'DotfilesLibrary',
  version = '0.1.0',
  author = 'Ethan Rose',
  author_email = 'errose28@gmail.com',
  packages = setuptools.find_packages(),
  url = 'https://github.com/errose28/DotfilesLibrary',
  description = 'A Robot Framework library for dotfile and other configuration management.',
  long_description = open('README.md').read(),
  license = 'Apache License 2.0',
  platforms = 'any',
  classifiers = [
    "Programming Language :: Python :: 3 :: Only",
    "License :: OSI Approved :: Apache Software License",
    "Operating System :: OS Independent",
    "Framework :: Robot Framework"
    "Framework :: Robot Framework :: Library"
  ],
  python_requires = '>=3.9, <4',
  install_requires = [ "robotframework" ]
)
