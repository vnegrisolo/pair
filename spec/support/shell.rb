class Shell
  def initialize(*mocks)
    @mocks = mocks.map { |mock| [mock, ShellMock.new(mock)] }.to_h
    @variables = {}
    @answers = []
  end

  def allow(mock)
    @mocks[mock]
  end

  def export(variable, value)
    @variables[variable] = value
  end

  def type(*answers)
    @answers += answers
  end

  def run(command, params = '')
    full_command = Shell.join(
      @variables.map { |k, v| "export #{k}='#{v}'" },
      @mocks.values.map(&:to_shell),
      ". #{command}.sh",
      "#{command} #{params} <<< $'#{@answers.join('\n')}'",
      "printenv"
    )

    `#{full_command}`
  end

  def self.join(*args)
    args.flatten.compact.join("\n")
  end
end
