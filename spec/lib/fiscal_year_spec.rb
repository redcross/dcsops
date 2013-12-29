require 'spec_helper'

describe FiscalYear do
  it "should be correct for the last day of the fy" do
    FiscalYear.for_date(Date.civil(2013,6,30)).year.should == 2013
  end

  it "should be correct for the first day of the fy" do
    FiscalYear.for_date(Date.civil(2013,7,1)).year.should == 2014
  end

  it "should be correct for the first day of the year" do
    FiscalYear.for_date(Date.civil(2014,1,1)).year.should == 2014
  end

  it "should generate the correct start date" do
    FiscalYear.new(2015).start_date.should == Date.civil(2014,7,1)
  end

  it "should generate the correct end date" do
    FiscalYear.new(2015).end_date.should == Date.civil(2015,6,30)
  end

  it "should create a range from the dates" do
    FiscalYear.new(2015).range.should == (Date.civil(2014,7,1)..Date.civil(2015,6,30))
  end
end