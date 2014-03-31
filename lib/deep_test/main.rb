module DeepTest
  class Main
    attr_reader :central_command

    def initialize(options, deployment, runner, central_command = nil)
      @options = options
      @deployment = deployment
      @runner = runner
      @central_command = central_command || CentralCommand.start(options)
    end

    def load_files(files)
      @deployment.load_files files
    end
    
    def run(exit_when_done = true)
      passed = false

      begin
        @options.new_listener_list.before_starting_agents
        @deployment.deploy_agents
        begin
          DeepTest.logger.debug { "Main: About to process work units (#{$$})" }
          passed = @runner.process_work_units(central_command)
        ensure
          graceful_shutdown.join(60)
        end
      ensure
        DeepTest.logger.debug { "Main: Stopping CentralCommand" }
        @central_command.stop
      end

      Kernel.exit(passed ? 0 : 1) if exit_when_done
    end

    def graceful_shutdown
     shutdown
     Thread.new do
       loop do
         Thread.exit if !@central_command.switchboard.any_live_wires?
       end
     end
    end

    def shutdown
      DeepTest.logger.debug { "Main: Shutting Down" }
      @central_command.done_with_work
    end
  end
end
