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

    def custom_sitrep(opts = {})
      # TODO: move this method to a demo specific class ASAP
      unless opts.kind_of? Hash
        m = opts.to_s
        opts = { extraInfo: { message: m } }
      end
      custom_info = { identity: identity, url: instance_url }.merge(opts)
      sitrep_message(custom_info)
    end

    def finished_task
      # TODO: move identity to a demo specific class ASAP
      custom_sitrep(extraInfo: { task: @params })
    end

    def identity
      # TODO: move this method to a demo specific class ASAP
      @identity ||= @params['identity'].to_s || 'not-aquired'
    end

    def instance_url
      # TODO: ??? move this method to a demo specific class ASAP???
      @instance_url ||= 'https://test-url.com'
      # @url ||= HTTParty.get('http://169.254.169.254/latest/meta-data/hostname').parsed_response
    end

    def run
      message = lambda { custom_sitrep(extraInfo: @params) }
      logger.info "Task starting... #{message.call}"
      pipe_to(:status_stream) { message.call }

      @task_thread = Thread.new do
        logger.info "Task running... #{message.call}"
        send_frequent_status_updates(message.call.merge(interval: 3))
        # job specific run instructions
        # TODO: move this method to a demo specific Task class ASAP
        # @updates_thread = Thread.new do
        #   system_command =
        #     "java -jar -DmodelIndex=\"#{identity}\" " +
        #     '-DuseLocalFiles=false roas-simulator-1.0.jar'
        #   error, results, status = Open3.capture3(system_comand)
        # end
      end
      # testing begins
      sleep rand(30..60)
      # testing ends
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
