require 'spec_helper'

describe App::Reports do
  context "upload" do
    let(:processing) { "processing" }
    subject { last_response }

    before do
      mock(ReportWorker).perform_async('body') { true }
      post "/reports/upload", "body"
    end

    it { should be_ok }
  end
end
