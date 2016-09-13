require 'dotenv'
Dotenv.load('.neuron.env')
require_relative 'job'
require_relative './lib/cloud_powers/aws_resources'
require_relative './lib/cloud_powers/auth'
require_relative './lib/cloud_powers/delegator'
require_relative './lib/cloud_powers/helper'
require_relative './lib/cloud_powers/self_awareness'
require_relative './lib/cloud_powers/smash_error'
require_relative './lib/cloud_powers/synapse/pipe'
require_relative './lib/cloud_powers/synapse/queue'

module Smash
  class Neuron
    extend Delegator
    include Smash::CloudPowers::Auth
    include Smash::CloudPowers::AwsResources
    include Smash::CloudPowers::Helper
    include Smash::CloudPowers::SelfAwareness
    include Smash::CloudPowers::Synapse

    attr_accessor :instance_id, :job_status, :workflow_status, :instance_url

    def initialize
      begin
        @boot_time = Time.now.to_i # TESTING: remove
        logger.info "Neuron waking up..."

        # Smash::CloudPowers::SmashError.build(:ruby, :workflow, :task)

        get_awareness! # sets self instance info and sets job info

        @status_thread = Thread.new do
          send_frequent_status_updates(interval: 5, identity: 'neuron')
        end
        until should_stop? do work end

      rescue Exception => e
        error_message = format_error_message(e)
        logger.fatal "Rescued in initialize method: #{error_message}"
        die!
      end
    end

    def current_ratio
      backlog = get_count(backlog_address)
      wip = get_count(bot_counter_address)

      ((efficiency_limit * backlog) - wip).ceil
    end

    def more_work?
      !!(current_ratio <= efficiency_limit)
    end

    def efficiency_limit
      @efficiency_limit ||= (1.0 / env('ratio_denominator').to_f)
    end

    def work
      possible_job = pluck_message(:backlog) # FIX: pluck doesn't delete
      job = Job.build(instance_id, possible_job)
      job.valid? ? process(job) : process_invalid(job)
    end

    def process(job)
      logger.info("Job found: #{job.message_body}")

      pipe_to(:status_stream) do
        job.sitrep(content: 'workflowStarted', extraInfo: job.params)
      end

      until job.done?
        job.workflow.next!
        pipe_to(:status_stream) do
          job.sitrep(content: 'workflowInProgress', extraInfo: { state: job.state })
        end
        job.run
      end
    end

    def process_invalid(job)
      logger.info "invalid job:\n#{job.inspect}"
      sqs.delete_message(
        queue_url: backlog_address,
        receipt_handle: job.receipt_handle
      )
      # TODO: make sure this is sending a message to needs_attention too
    end

    def should_stop?
      time_is_up? ? more_work? : false
    end

    def time_is_up?
      # returns true when the hour mark approaches
      an_hours_time = 60 * 60
      five_minutes_time = 60 * 5

      return false if run_time < five_minutes_time
      run_time % an_hours_time < five_minutes_time
    end

    def current_ratio
      backlog = get_count(:backlog_queue_address)
      wip = get_count(:count_queue_address)

      ((efficiency_limit * backlog) - wip).ceil
    end
  end
end

Smash::Neuron.new
