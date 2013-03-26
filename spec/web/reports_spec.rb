require 'spec_helper'

describe App::Reports do
  context "upload" do
    let(:processing) { "processing" }
    subject { last_response }

    before do
      mock(ReportProcessing).new("body"){ processing }
      mock(processing).process_delayed! { true }
      post "/reports/upload", "body"
    end

    it { should be_ok }
  end
end
