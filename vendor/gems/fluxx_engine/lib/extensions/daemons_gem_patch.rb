# per https://gist.github.com/346160
#
# Deaemons gem monkey patch based on Greg Hazel's changes from 1.0.10 to 1.0.12.
#
# The daemons gem has had a bug for the past 2 years, without a fix being pushed.
# Greg Hazel (http://github.com/ghazel) has forked the gem and provided a fix,
# but his fix has not yet been incorporated into the official gem.
#
# Cause of this, I needed a way to use the official gem, but have the fixes
# provided by Greg. Hence this monkey patch. Simply require this file after you
# require deamons, and all should work.
#

module Daemons
  
  class Application
    def stop
      if options[:force] and not running?
        self.zap
        return
      end
      
      # Catch errors when trying to kill a process that doesn't
      # exist. This happens when the process quits and hasn't been
      # restarted by the monitor yet. By catching the error, we allow the
      # pid file clean-up to occur.
      pid = @pid.pid
      begin
        Process.kill(SIGNAL, pid)
        while Pid.running?(pid)
          sleep 0.1
        end
      rescue Errno::ESRCH => e
        puts "#{e} #{@pid.pid}"
        puts "deleting pid-file."
      end
      
      # We try to remove the pid-files by ourselves, in case the application
      # didn't clean it up.
      begin; @pid.cleanup; rescue ::Exception; end
      
    end
  end
  
  class Controller
    def run
      @options.update @optparse.parse(@controller_part).delete_if {|k,v| !v}
      
      setup_options()
      
      #pp @options

      @group = ApplicationGroup.new(@app_name, @options)
      @group.controller_argv = @controller_part
      @group.app_argv = @app_part
      
      @group.setup
      
      case @command
        when 'start'
          @group.new_application.start
        when 'run'
          @options[:ontop] ||= true
          @group.new_application.start
        when 'stop'
          @group.stop_all
        when 'restart'
          unless @group.applications.empty?
            @group.stop_all
            sleep 1
            @group.start_all
          else
            puts "Warning: no instances running. Starting..."
            @group.new_application.start
          end
        when 'zap'
          @group.zap_all
        when 'status'
          unless @group.applications.empty?
            @group.show_status
          else
            puts "#{@group.app_name}: no instances running"
          end
        when nil
          raise CmdException.new('no command given')
          #puts "ERROR: No command given"; puts
          
          #print_usage()
          #raise('usage function not implemented')
        else
          raise Error.new("command '#{@command}' not implemented")
      end
    end
  end
  
  class Monitor
    def stop
      begin
        pid = @pid.pid
        Process.kill(Application::SIGNAL, pid)
        while Pid.running?(pid)
          sleep 0.1
        end
      rescue ::Exception => e
        puts "#{e} #{pid}"
        puts "deleting pid-file."
      end
      
      # We try to remove the pid-files by ourselves, in case the application
      # didn't clean it up.
      begin; @pid.cleanup; rescue ::Exception; end
    end
  end
  
end
