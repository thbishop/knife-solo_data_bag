shared_context 'stubbed_out_stdout_and_stderr' do
  before do
    @stdout = StringIO.new
    @stderr = StringIO.new
    allow(@knife.ui).to receive(:stdout) { @stdout }
    allow(@knife.ui).to receive(:stderr) { @stderr }
  end
end
