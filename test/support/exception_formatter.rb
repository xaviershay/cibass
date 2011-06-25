module ExceptionFormatter

  def format_exception(e)
    backtrace = e.backtrace.
      reject {|x| x.include?('minitest') }.
      map {|x|
        tokens = x.split(':')

        '  ' + [relativize_path(tokens[0]), *tokens[1..-1]].join(':')
      }.join("\n")

    "%s: %s\n%s" % [e.class.to_s, e.message, backtrace]
  end

  def relativize_path(path)
    relative_path = Pathname.new(File.expand_path(path)).
      relative_path_from(Pathname.new(Dir.pwd)).
      to_s

    if relative_path[0..2] == '../'
      path
    else
      relative_path
    end
  end

end
