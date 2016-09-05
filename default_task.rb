require_relative 'job'

module Smash
  class DefaultTask < Job

    attr_reader :identity, :instance_url, :params
    def initialize(id, msg)
      @params = JSON.parse(msg.body)
      instance_url # sets the url <- hostname in instance metadata
      # sets the 'idetity' <- comes from backlog message and is only for demo
      # TODO: identity should be removed after the demo and abstracted into its
      # own 'Task' class, instead of living in the "example"-ish Task
      identity
      @start_time = Time.now.to_i
      super(id, msg)
    end

    def run
      message = lambda { custom_sitrep(extraInfo: @params) }
      logger.info "Task starting... #{message.call}"
      pipe_to(:status_stream) { message.call }

      error = nil
      report = nil
      status = nil
      @task_thread = Thread.new do
        logger.info "Task running... #{message.call}"
        send_frequent_status_updates(message.call.merge(interval: 3))
        logger.info "error: #{error} result: #{result} status: #{status}"
      end
      error, report, status = custom_run

      until @task_finished
        # testing begin
        sleep rand(30..60)
        @task_finished = true
        # end testing
      end

      Thread.kill(@task_thread)
    end

    def valid?
      # job specific validity check
      # TODO: move this to a demo specific class ASAP and replace with the
      # line below it for a default example
      @valid ||= !@params['identity'].nil?
      # @valid ||= @params.kind_of? Hash
    end
  end
end
