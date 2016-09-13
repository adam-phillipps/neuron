require_relative 'job'

module Smash
  class Task < Smash::Job

    attr_reader :identity, :instance_url, :params
    def initialize(id, msg)
      @params = JSON.parse(msg.body)
      instance_url # sets the url <- hostname in instance metadata
      @start_time = Time.now.to_i
      super(id, msg)
    end

    def run
      message = sitrep(
        run_time: (Time.now.to_i - @start_time).to_s,
        extraInfo: @params
      )
      logger.info "Task starting... #{message}"
      pipe_to(:status_stream) { message }
    end

    def valid?
      @valid ||= @params.kind_of? Hash
    end
  end
end
