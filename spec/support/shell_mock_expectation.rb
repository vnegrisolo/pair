class ShellMockExpectation
  attr_accessor :params, :output

  def initialize(params)
    @params = params
    @output = ''
  end

  def and_return(output)
    @output = output
  end
end
