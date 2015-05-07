module Quality
  # Spawn a ruby process
  class RubySpawn
    def initialize(cmd, args)
      @cmd = cmd
      @args = args
    end

    def invocation
      if @args.size > 0
        "#{cmd_with_ruby_hack_prefix} #{@args}"
      else
        "#{cmd_with_ruby_hack_prefix}"
      end
    end

    def cmd_with_ruby_hack_prefix
      if defined?(RUBY_ENGINE) && (RUBY_ENGINE == 'jruby')
        "jruby -S #{@cmd}"
      elsif RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
        "#{@cmd}.bat"
      else
        @cmd
      end
    end
  end
end
