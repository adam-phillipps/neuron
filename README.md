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

## Nueron's workflow:
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
