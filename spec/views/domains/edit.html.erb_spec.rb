require 'spec_helper'

describe "domains/edit.html.erb" do
  before(:each) do
    @domain = assign(:domain, stub_model(Domain,
      :new_record? => false,
      :folder => nil
    ))
  end

  it "renders the edit domain form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => domain_path(@domain), :method => "post" do
      assert_select "input#domain_folder", :name => "domain[folder]"
    end
  end
end
