class Shell
  def initialize
    @stubs = [
      ShellMock.new(:git, output: 'GIT={{$@}}'),
      ShellMock.new(:curl, output: fixture(:github_user)),
    ]
  end

  def pair(params = '')
    command = ['. pair.sh', @stubs.map(&:to_shell), "pair #{params}"].flatten.join('; ')
    `#{command}`
  end
end
