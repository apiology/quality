# http://stackoverflow.com/questions/2108727/
#   which-in-ruby-checking-if-program-exists-in-path-from-ruby
module Quality
  # Determine where a given executable lives, like the UNIX 'which' command
  class Which
    def initialize(env: ENV,
                   file: File,
                   separator: File::PATH_SEPARATOR)
      @env = env
      @file = file
      @separator = separator
    end

    def which(cmd)
      exts = @env['PATHEXT'] ? @env['PATHEXT'].split(';') : ['']
      @env['PATH'].split(@separator).each do |path|
        exts.each do |ext|
          exe = @file.join(path, "#{cmd}#{ext}")
          return exe if @file.executable?(exe) && !@file.directory?(exe)
        end
      end
      nil
    end
  end
end
