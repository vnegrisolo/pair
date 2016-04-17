class Shell
  def initialize(*mocks)
    @mocks = mocks.map { |mock| [mock, ShellMock.new(mock)] }.to_h
  end

  def allow(mock)
    @mocks[mock]
  end

  def run(command, params = '')
    full_command = Shell.join(
      @mocks.values.map(&:to_shell),
      ". #{command}.sh",
      "#{command} #{params}",
    )

    `#{full_command}`
  end

  def self.join(*args)
    args.flatten.compact.join("\n")
  end
end
