class ShellMock
  def initialize(command, output: nil)
    @command = command
    @output = output
  end

  def to_shell
    "#{@command}() { echo \"#{@output.gsub(/"/, '\"')}\"; }"
  end
end
