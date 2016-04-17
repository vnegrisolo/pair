class ShellMock
  def initialize(command)
    @command = command
    @output = "'#{command}' Should Be Mocked with='$*'"
    @expectations = []
  end

  def with(params)
    @expectations.push(ShellMockExpectation.new(params)).last
  end

  def and_return(output)
    @output = output
  end

  def to_shell
    Shell.join(
      "#{@command}() {",
      "#{@command}_ok=0",
      expectations_to_shell,
      "if [ $#{@command}_ok -eq 0 ]; then #{print(@output)}; fi",
      '}',
    )
  end

  private

  def expectations_to_shell
    @expectations.map do |e|
      "if [ \"$*\" = \"#{e.params}\" ]; then #{@command}_ok=1; #{print(e.output)}; fi"
    end
  end

  def print(output)
    "echo \"#{output.gsub(/"/, '\"')}\""
  end
end
