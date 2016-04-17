class Shell
  def initialize(*mocks)
    @mocks = mocks.map { |mock| [mock, ShellMock.new(mock)] }.to_h
  end

  def expect(mock)
    @mocks[mock]
  end

  def run(command, params = '')
    full_command = [
      ". #{command}.sh",
      @mocks.values.map(&:to_shell),
      "#{command} #{params}"
    ].flatten.join('; ')

    `#{full_command}`
  end
end
