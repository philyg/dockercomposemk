# DockerComposeMk - Easing Docker Compose Handling with Makefiles

![Build Status](https://github.com/philyg/dockercomposemk/actions/workflows/makefile.yml/badge.svg)
![License](https://img.shields.io/github/license/philyg/dockercomposemk)
![Release](https://img.shields.io/github/v/release/philyg/dockercomposemk)

https://github.com/philyg/dockercomposemk

> [!TIP]
> Download the latest generated Makefile directly:
>
> [Here](https://github.com/philyg/dockercomposemk/releases/latest/download/docker-compose.mk)
>
> or
>
>     curl -LO https://github.com/philyg/dockercomposemk/releases/latest/download/docker-compose.mk
>
> or
>
>     curl -Lo Makefile https://github.com/philyg/dockercomposemk/releases/latest/download/docker-compose.mk

## Motivation

Many simpler deployments of containers utilize docker-compose to configure containers using config files rather than command line switches.

While I very much like the entire concept, I very much dislike the tedious work of typing out `docker compose build && docker compose up -d && docker compose logs --tail 100 -f` to build and restart a container and look at the log output. Similarly, I dislike typing out `docker compose run --rm [servicename] bash` to start a shell into an image used by a service.

This project therefore has the goal to make the above examples as simple as `make build up logs` and `make shell`, respectively.

## Requirements

The project shall implement Makefiles that:
- Allow running general docker compose commands in a short and simple form
- Implement pre and post hooks for any additional commands that shall be run before or after the actual provided command
- Allow preimplemented targets to be overridden where needed
- Automatically detect the first defined service in compose files for opening shells into containers/images
- Are auto-generated from simple recipes so that they can easily be adapted

## Implementation

This project is implemented using two shell scripts:
- One to generate the general format of the Makefile (`generateMakefile.sh`) and
- One to define the actual targets to implement (`targets.inc.sh`).

These scripts are accompanied by a Makefile that generates the final docker-compose Makefile (`docker-compose.mk`).

## Usage

### Building

`docker-compose.mk` can be built simply by running `make`. Alternatively, pre-generated Makefiles can be downloaded from the Relases section.

### Deployment

To deploy the generated Makefile into docker-compose projects, either symlink the generated `docker-compose.mk` as `Makefile` into the project directory containing the `docker-compose.yml/yaml` file, or create a `Makefile` in this directory which includes the `docker-compose.mk`, as in:

````
include ../docker-compose.mk
````

Finally, for further configuration, create a `Makefile-custom` in the same directory. See below for configuration options.

### Configuration

The Makefile comes preconfigured with the following output for `make` and `make all`:

````
This is a dockercomposemk v0.1.0 Makefile. For more information see:
https://github.com/philyg/dockercomposemk


Available implemented targets:

up:             Create and start containers in background
fup:            Create and start containers in foreground
down:           Stop and remove containers and remove orphans

start:          Start stopped containers
stop:           Stop started containers
restart:        Restart containers

pause:          Pause containers
unpause:        Unpause containers

shell:          Open shell to first container if running
run:            Open shell to first container image

stats:          Show running status information
ps:             Show container list
logs:           Display and follow logs

build:          Build any buildable images
pull:           Pull any non-buildable images
rebuild:        Build any buildable images (no-cache)


Targets to be implemented by overriding in Makefile-custom as real-[NAME]:

reload:         Reload the service(s)
clean:          Cleanup any superfluous files
backup:         (Prepare for) backup of service data


All targets call pre-[NAME] and post-[NAME] targets for additional hooks in overriding
Makefile-custom files. The actual actions can also be changed by overriding real-[NAME].

Additionally, the following veriables can be defined in Makefile-custom:
force
SVC          The service to interact with when using the run and shell
             targets (uses first one in docker-compose.y*ml if undefined)
````

Each of these listed targets is actually implemented using three targets which dan be overridden where needed:
- `pre-[target]`: This target is run _before_ the actual action of the target is run.
- `real-[target]`: This target is the actual action to perform.
- `post-[target]`: This target is run _after_ the actual action of the target was run.

If `real-[target]` is defined, the listed actions are performed, otherwise the predefined action for this target, defined in `real-[target]-default` is performed.

For example, for `up`, if a target `real-up` is defined in `Makefile-custom`, the specified actions are performed. If no `real-up` target is defined, the target `real-up-default` is instead run, which per default runs `docker compose up -d`.

For the run and shell targets, the tool tries to ascertain the first defined target in the docker-compose project file using very simple parsing. If this yields the incorrect service, or another service shall be used anyways, the SVC variable can be defined in `Makefile-custom`, which sets the service to interact with to this value.

### Example
An example usage is shown in the `example` directory of this repository.
