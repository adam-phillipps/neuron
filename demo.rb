require 'open3'
require_relative 'job'

module Smash
  class Demo < DefaultTask

    attr_reader :identity, :instance_url, :params
    def initialize(id, msg)
      super(id, msg)
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
      custom_sitrep(extraInfo: { task: @params })
    end

    def identity
      @identity ||= @params['identity'].to_s || 'not-aquired'
    end

    def custom_run
      system_command =
        "java -jar -DmodelIndex=\"#{identity}\" " +
        '-DuseLocalFiles=false roas-simulator-1.0.jar'

      # returns [error, results, status]
      Open3.capture3(system_command)

      # TOOD: figure out how to find success and possibly status
      @task_finished = false # this should be set to true if the jar ran
      end
    end

    def valid?
      @valid ||= !@params['identity'].nil?
    end
  end
end
