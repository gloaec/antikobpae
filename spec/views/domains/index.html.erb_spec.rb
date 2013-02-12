require 'spec_helper'

describe "domains/index.html.erb" do
  before(:each) do
    assign(:domains, [
      stub_model(Domain,
        :folder => nil
      ),
      stub_model(Domain,
        :folder => nil
      )
    ])
  end

  it "renders a list of domains" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
