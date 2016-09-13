require 'open3'
require_relative '../../task'

module Smash
  class Demo < Task
    attr_reader :identity, :instance_url, :params

    def initialize(id, msg)
      super(id, msg)
      # sets the 'idetity' <- comes from backlog message and is only for demo
      identity
    end

    def finished_task
      sitrep(extraInfo: { task: @params })
    end

    def done?
      !!@done
    end

    def identity
      @identity ||= @params['identity'].to_s || 'not-aquired'
    end

    def run
      super
      @task_thread = Thread.new do
        logger.info "Task running... #{message}"
        send_frequent_status_updates(message.merge(interval: 3))
      end
      system_command = 'printf "biscuits\n"'
        # "java -jar -DmodelIndex=\"#{identity}\" " +
        # '-DuseLocalFiles=false roas-simulator-1.0.jar'
      error, results, status = Open3.capture3(system_command)
      sleep rand(3..6)
      @done = true #if error.size < 1 # this should be set to true if the jar ran
      Thread.kill(@task_thread)
      [error, results, status]
    end

    def sitrep(opts = {})
      unless opts.kind_of? Hash
        m = opts.to_s
        opts = { extraInfo: { message: m } }
      end
      custom_info = { identity: identity, url: instance_url }.merge(opts)
      sitrep_message(custom_info)
    end

    def valid?
      !!(@valid ||= @params['identity'])
    end
  end
end
