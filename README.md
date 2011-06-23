Cibass
======

*This is a speculative README. Nothing in here works yet.*

Cibass ("Sea-bass") is a continuous integration server for git projects that supports:

* Pipelines
* Artifact repositories
* Version controlled configuration
* Manual stages

It uses a lot of git, HTTP, and unix.

Usage
-----

Create a configuration file named 'Cibass'and store it in the root directory of
a git repository. It can be your main project, or a separate one, it doesn't
matter.

    Cibass.configure do |config|
      config.create_pipeline(:main) do |pipe|
        # Each pipeline consist of one or more stages that a commit must pass
        # through.
        pipe.add_stage(:unit,
          :command => 'rvm 1.9.2 rake test:unit'
        )

        # A stage will not be run until after all of its dependencies have
        # been successfully run.
        pipe.add_stage(:acceptance,
          :command      => 'rvm 1.9.2 rake test:acceptance'
          :dependencies => [:unit]
        )

        # Stages can be run concurrently if they have the same dependencies.
        # You can also run arbitrary scripts inside your source tree.
        pipe.add_stage(:nonfunctional,
          :command      => 'bin/nonfunctional'
          :dependencies => [:unit]
        )

        # If no command is given, the stage must be completed manually. No
        # restraints are placed on what a manual stage entails, all cibass
        # does is wait for an HTTP request telling it the result of the stage,
        # and any metadata it should store. You should build up your own tooling
        # if you want to use this functionality, see the examples directory
        # for a starting point.
        pipe.add_stage(:uat)
      end

      config.connect('git://path/to/your/repo', :to => :main)
    end

Then start cibass:

    # Create a working directory
    mkdir ~/cibass

    # Start the server
    cibass --working-dir ~/cibass --config git://path/to/your/config/repo --port 9999

This starts an HTTP server on port 9999 and a background worked that is ready
for action. To trigger a build, post the commit ref you want to run to the
pipeline:

    # Set common curl options to let us get JSON responses back
    echo '-H "Accept: application/json"' > json

    GITREF=54ef36
    curl -k json -X POST http://ci/main/$GITREF

    # Recent builds
    curl -k json http://ci/main

    # Information about a specific build
    curl http://ci/main/$GITREF

    # Detailed information about a specific stage
    curl -k json http://ci/main/$GITREF/unit
    curl http://ci/main/$GITREF/acceptance

Use the PUT verb to mark manual stages as complete, and DELETE to remove a
stage or commit (if for instance, a CI environment issues caused it to fail).
