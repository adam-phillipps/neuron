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
      custom_sitrep(extraInfo: { task: @params })
    end

    def done?
      !!@done
    end

    def identity
      @identity ||= @params['identity'].to_s || 'not-aquired'
    end

    def run
      # super
      system_command =
        "java -jar -DmodelIndex=\"#{identity}\" " +
        '-DuseLocalFiles=false roas-simulator-1.0.jar'

      # returns [error, results, status]
      Open3.capture3(system_command)

      # TOOD: figure out how to find success and possibly status
      @done = true if error.size < 1 # this should be set to true if the jar ran
    end

    def sitrep(opts = {})
      # super
      unless opts.kind_of? Hash
        m = opts.to_s
        opts = { extraInfo: { message: m } }
      end
      custom_info = { identity: identity, url: instance_url }.merge(opts)
      sitrep_message(custom_info)
    end

    def valid?
      @valid ||= !@params['identity'].nil?
    end
  end
end
