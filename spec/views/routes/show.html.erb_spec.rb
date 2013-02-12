require 'spec_helper'

describe "routes/show.html.erb" do
  before(:each) do
    @route = assign(:route, stub_model(Route,
      :domain => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(//)
  end
end
