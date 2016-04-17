class Shell
  def initialize
    @stubs = {
      git: ShellMock.new(:git, output: 'GIT={{$@}}'),
      curl: ShellMock.new(:curl, output: fixture(:github_user)),
    }
  end

  def run(command, params = '')
    full_command = [
      ". #{command}.sh",
      @stubs.values.map(&:to_shell),
      "#{command} #{params}"
    ].flatten.join('; ')

    `#{full_command}`
  end
end
