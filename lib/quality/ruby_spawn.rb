# frozen_string_literal: true

module Quality
  # Spawn a ruby process
  class RubySpawn
    def initialize(cmd, args)
      @cmd = cmd
      @args = args
    end

    def invocation
      if !@args.empty?
        "#{cmd_with_ruby_hack_prefix} #{@args}"
      else
        cmd_with_ruby_hack_prefix.to_s
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
