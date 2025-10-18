#!/usr/bin/env python
import os
import sys

from setuptools import find_packages, setup


here = os.path.dirname(__file__)
changes_filename = os.path.join(here, "NEWS.txt")
with open(changes_filename) as changes_file:
    changes = changes_file.read().split("\n\n\n")
changes_in_latest_versions = "\n\n\n".join(changes[:3])

short_description = "A Gtk+ time tracking application"
long_description = short_description + "."  # for now

if sys.version_info < (3, 5, 0):
    sys.exit("Python 3.5 is the minimum required version")

setup(
    name="gtimelog",
    version="0.2.3",
    author="Marius Gedminas",
    author_email="marius@gedmin.as",
    url="https://gtimelog.org/",
    description=short_description,
    long_description=long_description + "\n\n" + changes_in_latest_versions,
    license="GPL",
    keywords="time log logging timesheets gnome gtk",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Environment :: X11 Applications :: GTK",
        "License :: OSI Approved :: GNU General Public License (GPL)",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: Implementation :: CPython",
        "Programming Language :: Python :: Implementation :: PyPy",
        "Topic :: Office/Business",
    ],
    python_requires=">= 3.6",
    packages=find_packages("src"),
    package_dir={"": "src"},
    include_package_data=True,
    test_suite="gtimelog.tests",
    zip_safe=False,
    entry_points="""
    [console_scripts]
    rltimelog = gtimelog.rltimelog:main
    [gui_scripts]
    gtimelog = gtimelog.main:main
    """,
    install_requires=["PyGObject"],
)
