_Smash::Brain API documentation_
################################################################################
#                                       Neuron
################################################################################

This is the node in the Brain project that actually 'works on' the difficult
'[link to: Smash::Job]job' the Brain has been given.
By the time the [link to: Smash::Task]work arrives to
the area of concern of the Neurons, it has been broken down into a
[link to: Smash::Task]task that is successful in the divide and concure method.
The only real requirement is that only 1 Neuron can exist in one
Ruby global namespace.  It can start and monitor a Tomcat server,
for example.  Neurons use the Smash::CloudPowers module, which is a sub-module
in git, as a wrapper around the AWS SDK.  The API for the Neuron project, just
like the other peices of the Brain, is geared toward generalization in every
respect possible, so that it can also extend other cloud services like Azure.
It is also intended to be written generally so it can provide any service.
Neurons have a job to run in a given context and it can create any 
[link to: Smash::Task]task, [link to: Smash::Task]Neron, 
[link to: Smash::Task]Cerebrum, etc. to do it.  It is also usually on the 
same server an extra app can be started, used and maintained.
_note: more time is needed to research individual Neuron optimization_
## Configuration ##

1. ```$ cp .neuron.env.example .neuron.env```
2. add the required values to .neuron.env
3. Create a Task class.  You can use the task as a guide or you can use its code.
    It should be set up genericly enough to use for most basic tasks that 
    Neurons can run.  _for now_...
    The Demo class (specific demo related job running instructions/support)
    inherits from the Task class, for example.

## Setting up/Running ##

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
    `sitrep` method and a `run` method.  These are the methods that
    should be invoked and they build off the `Task` class.  It also has
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