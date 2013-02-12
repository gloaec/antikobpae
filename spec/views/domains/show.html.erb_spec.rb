require 'spec_helper'

describe "domains/show.html.erb" do
  before(:each) do
    @domain = assign(:domain, stub_model(Domain,
      :folder => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(//)
  end
end
