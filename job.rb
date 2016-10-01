require 'cloud_powers'

module Smash
  class Job
    extend Smash::Delegator
    include Smash::CloudPowers::Auth
    include Smash::CloudPowers::AwsResources
    include Smash::CloudPowers::Helper
    include Smash::CloudPowers::Synapse::Pipe
    include Smash::CloudPowers::Synapse::Queue

    attr_reader :instance_id, :message, :message_body, :state, :workflow

    def initialize(id, msg, opts = {})
      @workflow = opts.delete(:workflow) || Workflow.new([:backlog, :wip, :finished])
      @instance_id = id
      @message = msg
      @message_body = msg.body
      @board = build_board(@workflow.current) # TODO: implement a workflow
    end

    def sitrep_message(opts = {})
      # TODO: find better implementation of merging nested hashes
      # this should be fixed with ::Helper#update_message_body
        situation =
          @board.name == 'finished' ? 'workflow-completed' : 'workflow-in-progress'

        extra_info = {}
        if opts.kind_of?(Hash) && opts[:extraInfo]
          custom_info = opts.delete(:extraInfo)
          extra_info = { 'taskRunTime' => task_run_time }.merge(custom_info)
        else
          opts = {}
        end

        sitrep_alterations = {
          type: 'SitRep',
          content: situation,
          extraInfo: extra_info
        }.merge(opts)
        update_message_body(sitrep_alterations)
    end

    def state
      @workflow.current
    end

    def task_run_time
      # @start_time is in the Task class
      Time.now.to_i - @start_time
    end
  end
end
