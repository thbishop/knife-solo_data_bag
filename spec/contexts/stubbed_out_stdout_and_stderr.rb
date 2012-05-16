shared_context 'stubbed_out_stdout_and_stderr' do
  before do
    @stdout = StringIO.new
    @stderr = StringIO.new
    @knife.ui.stub!(:stdout).and_return(@stdout)
    @knife.ui.stub!(:stderr).and_return(@stderr)
  end
end
