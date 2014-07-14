require 'spec_helper'

describe FiscalYear do
  it "should be correct for the last day of the fy" do
    expect(FiscalYear.for_date(Date.civil(2013,6,30)).year).to eq(2013)
  end

  it "should be correct for the first day of the fy" do
    expect(FiscalYear.for_date(Date.civil(2013,7,1)).year).to eq(2014)
  end

  it "should be correct for the first day of the year" do
    expect(FiscalYear.for_date(Date.civil(2014,1,1)).year).to eq(2014)
  end

  it "should generate the correct start date" do
    expect(FiscalYear.new(2015).start_date).to eq(Date.civil(2014,7,1))
  end

  it "should generate the correct end date" do
    expect(FiscalYear.new(2015).end_date).to eq(Date.civil(2015,6,30))
  end

  it "should create a range from the dates" do
    expect(FiscalYear.new(2015).range).to eq(Date.civil(2014,7,1)..Date.civil(2015,6,30))
  end
end