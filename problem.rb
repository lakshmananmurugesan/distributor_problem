require 'csv'
require './helper.rb'

class Problem

  #For input
  def input_details
    puts "NOTE:: Region format considered as cityName,stateName,countryName"
    puts "Input number of distributor details"
    number = gets.chomp.to_i
    for i in 0..(number-1)
      include_regions = Array.new
      exclude_regions = Array.new
      include_input = String.new
      exclude_input = String.new
      puts "Enter name"
      distributor_name = gets.chomp
      puts "Enter include regions, type 'exit' to stop"
      while include_input != 'exit'
        include_regions << include_input if include_input.length>0
        include_input = gets.chomp
      end
      puts "Enter exclude regions, type 'exit' to stop"
      while exclude_input != 'exit'
        exclude_regions << exclude_input if exclude_input.length>0
        exclude_input = gets.chomp
      end
      helper = Helper.new distributor_name, include_regions, exclude_regions, i
      helper.parse_csv
    end
  end
  
  #Function call
  problem = Problem.new
  problem.input_details 
end