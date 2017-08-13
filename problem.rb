require 'csv'
require './helper_methods.rb'

class Problem

  #For input
  def input_details
      HelperMethods.new.parse_csv
  end
  
  #Function call
  problem = Problem.new
  problem.input_details 
end