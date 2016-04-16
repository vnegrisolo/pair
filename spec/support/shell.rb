class Shell
  def initialize
    @stubs = [
      git_stub,
      curl_stub,
    ]
  end

  def pair(params = '')
    command = ['. pair.sh', @stubs, "pair #{params}"].flatten.join('; ')
    `#{command}`
  end

  def git_stub
    'git() { echo "GIT={{$@}}"; }'
  end

  def curl_stub
    "curl() { echo '#{github_user_response}'; }"
  end

  def github_user_response
    fixture :github_user
  end
end
