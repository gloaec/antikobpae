require 'spec_helper'

describe "domains/new.html.erb" do
  before(:each) do
    assign(:domain, stub_model(Domain,
      :folder => nil
    ).as_new_record)
  end

  it "renders new domain form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => domains_path, :method => "post" do
      assert_select "input#domain_folder", :name => "domain[folder]"
    end
  end
end
