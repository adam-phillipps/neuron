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

- Alternatively, you can use a 1-liner to add the environment var and the script
# this has not been tested but it _should_ work (famous last words).
```
$ -e "\$aTESTING=true" \
    && ruby neuron.rb
```
For production:
/bin/bash ./runNeuron