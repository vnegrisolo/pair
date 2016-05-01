class Shell
  def initialize(*mocks)
    @mocks = mocks.map { |mock| [mock, ShellMock.new(mock)] }.to_h
    @variables = {}
  end

  def allow(mock)
    @mocks[mock]
  end

  def export(variable, value)
    @variables[variable] = value
  end

  def run(command, params = '')
    full_command = Shell.join(
      @variables.map { |k, v| "export #{k}='#{v}'" },
      @mocks.values.map(&:to_shell),
      ". #{command}.sh",
      "#{command} #{params}",
      "printenv"
    )

    `#{full_command}`
  end

  def self.join(*args)
    args.flatten.compact.join("\n")
  end
end
