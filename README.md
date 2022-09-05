# Setup

## Pipenv

Pipenv is used for package management. The Pipfile is located in the root directory.
The project uses python 3.8.

## Python Source Code

Stored within `src`, which is within the root directory. When the container/application is executed, it looks for the `__main__.py` module within `src`. If this needs to be changed, it needs to also be reconfigured in `Dockerfile`.

## Dockerfile

Stored in the root directory. Relies on the Pipfile and source code being located in the directories stated above. 

Build the Dockerfile locally into an image using:
`docker build -t <desired_image_name> .`

Run container locally from image using:
`docker run <desired_image_name>`

The container will execute the simple print statement defined in the python `__main__.py` and exit.
