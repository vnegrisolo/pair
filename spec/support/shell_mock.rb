class ShellMock
  def initialize(command)
    @command = command
    @output = "You Should Mock #{command}"
  end

  def and_return(output)
    @output = output
  end

  def to_shell
    output = shell_output(@output)
    "#{@command}() { #{output} }"
  end

  private

  def shell_output(output)
    "echo \"#{output.gsub(/"/, '\"')}\";"
  end
end
