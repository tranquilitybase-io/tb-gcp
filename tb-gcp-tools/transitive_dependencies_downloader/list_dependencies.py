# -*- coding: utf-8 -*-
"""Listing dependency tree and licenses

Description: This short program will takes as input a requirements.txt file
 which lists a project dependent packages and outputs a text file listing
 the top level and transitive dependencies along with their respective software
 licenses.
Author: Thomas Bailey
"""

import os
import re
import json
import sys

def remove_requirements_versioning(requirements):
    """ Returns list of requirements without their version
    specified. ie. Flask==1.1.3. Note: this is done because
     pipdeptree will only accept a package name and will take
     the currently installed version.

     :param requirements: package requirements
     :return: list of requirements without versions"""

    return [req.split('==')[0] if '==' in req else req for req in requirements]

def append_license(license_val, line):
    """ Add software license to the line corresponding to a package. """

    line += ' | License: ' + license_val
    output_file.write(line + '\n')

def process_requirement(req):
    """ Output a file listing all top-level and transitive dependencies
    and their respective licenses named transitive_dependencies.txt 
    with indentation.

    """

    print('Processing package ' + req)

    # retrieve transitive dependencies
    output = os.popen("pipdeptree -p " + str(req)).read()
    output_line = list(filter(None, output.split('\n')))

    # retrieve licenses for each transitive and top level dependency
    for count, line in enumerate(output_line):

        # top level processing
        if count == 0:

            tmp_dict = list(filter(lambda person: person['Name'] == req, licenses_dict))
        # transitive dependency processing
        else:

            trans_dependencies = re.findall('[A-Za-z0-9\-]+ \[', line)

            if trans_dependencies:
                trans_dependencies = trans_dependencies[0].replace(' [', '')
                tmp_dict = list(filter(lambda person: person['Name'] == trans_dependencies, licenses_dict))

        #if no match found between dependency and license append 'not found'
        if len(tmp_dict) == 0:
            append_license('not found', line)
        else:
            append_license(tmp_dict[0]['License'], line)

def flatten_file():
    """
    Output a file listing all top-level and transitive dependencies
    and their respective licenses named transitive_dependencies_flat.txt
    without indentation.

    """
    output_file_flat = open('transitive_dependencies_flat.txt', 'a+')
    file = open("transitive_dependencies.txt", "r")
    file_contents = file.read()
    lines = file_contents.split('\n')

    for line in lines:

        line = line.replace(' ', '')
        line = line.replace('-', '')
        line = line.replace('[', ' [')
        line = line.replace('|', ' | ')

        if len(line) < 2:
            continue

        print(line)
        output_file_flat.write(line + '\n')

if __name__ == '__main__':

    # accept option to output flat version of dependency tree
    if sys.argv[1]:

        file_option = sys.argv[1]

    else:
        file_option = ''

    # store python requirements as list
    f = open("requirements.txt", "r")
    f_contents = f.read()
    requirements = f_contents.split('\n')

    # create new file to append to
    output_file = open('transitive_dependencies.txt', 'a+')

    # store licenses for all packages in current environment
    licenses = os.popen("pip-licenses --format=json").read()
    licenses_dict = json.loads(licenses)

    # remove package versioning for processi
    requirements = remove_requirements_versioning(requirements)

    for req in requirements:

        process_requirement(req)
        output_file.write('\n')

    if file_option == '-f' or file_option == 'f':

        flatten_file()




