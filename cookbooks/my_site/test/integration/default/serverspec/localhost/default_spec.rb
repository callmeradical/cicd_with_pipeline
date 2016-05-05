require 'spec_helper'

# Tests go here
#
describe file('C:\temp.txt') do
  it { should be_file }
end
