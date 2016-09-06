################################################################################
#                                       Neuron
################################################################################

This is the node in the brain project.  It uses the Smash::CloudPowers module,
which is a sub-module in git, as a wrapper around the AWS SDK.

## Configuration ##

1. ```$ cp .neuron.env.example .neuron.env```
2. add the required values to .neuron.env
3. Create a Task class.  You can use the default_task as a guide or
    you can use its code.  It should be set up genericly enough to use for most basic tasks that neurons can run.  _for now_...

## Running ##

For testing/development:
1. add the environment varialbe ```TESTING=true``` to the bottom line in your .env file then start the neuron with:
```$ ruby neuron.rb```

- Alternatively, you can use a 1-liner to set the environment then
    run the script
# this has not been tested but it _should_ work (famous last words).
```
$ sed -e "\$aTESTING=true" $(find . -type f -name *.env) \
    && ruby neuron.rb
```
For production:
/bin/bash ./runNeuron


################################################################################
##                           Nueron's workflow
################################################################################
1. Neuron starts
2. Neuron checks self-tags to find out which project environment it should be
    working in by the tags on the instance.
3. Neuron polls correct backlog queue for a job
4. Find a message then start the setup process.
    - messages look like this:
    ```Javasript
    {
      'extraInfo':{'any-useful-params':'or-other-good-stuff'},
      'task-env':'s3-location of task'
    }
    ```
5. Get the file indicated in the 'task-env' of the message.
6. Load the file.  This file is the specific tasks for running the .jar file
    or whatever other complicated math thing the big brains give the Neurons to run.
7. Run the task and send periodic status updates (status-update) or situation reports  (SitReps)
8. Repeat from step 3 until the time when the Neuron should shut itself down.
  * The method used to determine when an instance should shut itself down considers:
    * the current run time as it approaches the hour mark from when it was started,
    * the current ratio of instances vs the required ratio of instances to jobs
    * this method can be overriden in the custom Task file that is loaded from step 6


################################################################################
##                           Nueron's Architecture
################################################################################

* A Neuron is the base node in the computing piece of the Brain
* Nuerons are largely naive about everything except some information given to it
  in a tag.  The only required info to give a Neuron is a tag on the AWS instance
  used to run it.
  * The tag should contain the contractual name of the project.  That means that
    name is used as a contract to guarantee several things about the environment
    the project is going to run in, like SQS queue names, S3 buckets, etc.
* Neurons are created based on requests from the Cerebrum
  [Cerebrum Link]https://github.com/adam-phillipps/cerebrum
* The Neuron is responsible for _figuring out *1_ what work needs to be done and
  what context or "environment" it should work in.
  * The environment is received in a message which the Cerebrum delivers
    _the message is described above, in the workflow_.
  * The file it gets from S3 is a ruby file that has custom methods, like a
    `custom_sitrep` method and a `custom_run` method.  These are the methods that
    should be invoked and they build off the `DefaultTaks` class.  It also has
    the ability to override other task methods to better fit its needs.
* The Neuron uses the `Smash::CloudPowers` submodule, which is basically an
  Aws Ruby SDK wrapper.
  [CloudPowers Link]https://github.com/adam-phillipps/cloud_powers
* Nuerons can request other Smash resources to be built; For example:
  - a Cerebrum could span several Neurons that require other _Brains_
  to run on sub-sets of the larger Task that the Neuron was given.

##Notes:
* *1 "Figuring out" work means to have the ability to gather a work context,
      gather the correct work and then build or utilize required resources.
* *2