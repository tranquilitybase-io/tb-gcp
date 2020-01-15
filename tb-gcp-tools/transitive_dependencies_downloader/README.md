# Transitive Dependency Downloader
The **Transitive Dependency Downloader** is a python script that will parse a requirements text file and output a text file listing all the top-level and transitive dependencies and their respective licenses. This can be optionally presented in a tree structure or flat structure, the first of which looks like this: 
```text
oauth2client==4.1.3 | License: Apache 2.0  
  - httplib2 [required: >=0.9.1, installed: 0.14.0] | License: MIT  
  - pyasn1 [required: >=0.1.7, installed: 0.4.8] | License: BSD  
  - pyasn1-modules [required: >=0.0.5, installed: 0.2.7] | License: BSD-2-Clause  
    - pyasn1 [required: >=0.4.6,<0.5.0, installed: 0.4.8] | License: BSD  
  - rsa [required: >=3.1.4, installed: 4.0] | License: ASL 2  
    - pyasn1 [required: >=0.1.3, installed: 0.4.8] | License: BSD  
  - six [required: >=1.6.1, installed: 1.13.0] | License: MIT
```

## Pre-requisites
There are a number of set-up tasks required to get **Transitive Dependency Downloader** to work correctly.

 - Creation of virtual environment

> More information can be found here: [https://docs.python.org/3/library/venv.html](https://docs.python.org/3/library/venv.html)

 - Installing of packages from requirements text file you'd like to retrieve dependency tree and licenses for. For example:

```python
pip install -r requirements.txt
```

 - Installing dependencies for **TDD**: *pip-licenses* and *pipdeptree* 

```python
pip install pip-licenses
pip install pipdeptree
```

## Running TDD
To execute TDD run the following command while your python virtual environment is setup and you're in the directory where your requirements file is located:

```python
python list_dependencies.py -f
```
> The '-f' option is used to output a file in the working directory of a flat file in addition to the dependency tree structure.
