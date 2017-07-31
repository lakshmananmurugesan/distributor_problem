class Helper

#Declarations
@@all_cities = Hash.new
@@all_states = Hash.new
@@all_distributor_data = []
FILE_NAME = "./input.csv"

#Constructor
def initialize distributor_name, include_regions, exclude_regions, input_no
  @distributor_name = distributor_name
  @include_regions = include_regions
  @exclude_regions =  exclude_regions
  @input_no = input_no
end

#parsing csv
def parse_csv
  csv_data = File.read(FILE_NAME)
  puts "Please wait ..."
  data = CSV.parse(csv_data, headers: true)
  @all_countries = data['country_name'].uniq
  set_states_cities(data)
end
 
 #For setting states and cities from csv
 def set_states_cities data
  states_hash = Hash.new { |h,k| h[k] = [] }
  cities_hash = Hash.new { |h,k| h[k] = [] }
  data.each do |row|
    if !states_hash[row["country_name"]].include?(row["province_name"])
      states_hash[row["country_name"]] << row["province_name"]
    end
    if !cities_hash[row["province_name"]].include?(row["city_name"])
      cities_hash[row["province_name"]] << row["city_name"]
    end
  end
  @@all_cities = cities_hash
  @@all_states = states_hash
  build_result(@distributor_name, @include_regions, @exclude_regions)
 end

 #Result Json
 def build_result distributor_name, include_regions, exclude_regions
  result = []
  excludes = []
  result << { "name": distributor_name, "includes": build_include_regions(include_regions), 
              "excludes": build_exclude_regions(exclude_regions)
            }
  # puts "Distributor permission data"
  # puts result
  @@all_distributor_data << result
  check_permissions(@@all_distributor_data, result, distributor_name, include_regions, exclude_regions)
 end

 #Main permissions flow
 def check_permissions all_distributor_data, result, distributor_name, include_regions, exclude_regions
   inheritance = false
   input_location_detail(inheritance, result)
   # p all_distributor_data
   if @input_no == 1
    inheritance = true
    puts "Inherits details"
    puts "Enter distributor_name to inherit"
    distributor_name = gets.chomp
    input_location_detail(inheritance, all_distributor_data)
  end
 end

 #For location detail to validate
 def input_location_detail inheritance, result
  input = String.new
  city_captured = false
  state_captured = false
  country_captured = false
  puts "Check permissions, type 'exit' to Stop"
  puts "Enter location Format 'cityName,stateName,countryName'"
  while input != 'exit'
    input = gets.chomp
    if input.include?(",")
      city, state, country = input.split(",")
      if inheritance
        status = finders(result[1][0], city_captured, state_captured, country_captured, city, state, country)
        if !status
          status = finders(result[0][0], city_captured, state_captured, country_captured, city, state, country)
        end
      else
        status = finders(result[0], city_captured, state_captured, country_captured, city, state, country)
      end
      if !status
        puts "Input is not available in includes and excludes"
      end
   end
  end
 end

 #Finders methods
 def finders result, city_captured, state_captured, country_captured, city, state, country
   city_status = city_finder(result, city_captured, city, state, country)
   state_status = state_finder(result, state_captured, city, state, country)
   country_status = country_finder(result, country_captured, city, state, country)
   if !city_status && !state_status && !country_status
    return false
  end
  return true
end

 #City permission checking
 def city_finder result, city_captured, city, state, country
  if !city.empty? && !state.empty? && !country.empty?
    if result[:excludes].length>0 && result[:excludes][:cities][state].length>0 &&
      result[:excludes][:cities][state][0].include?(city)
      puts "NO"
      city_captured = true 
    end  
  end

  if !city_captured && !city.empty? && !state.empty? && !country.empty?
    if result[:includes].length>0 && result[:includes][:cities][state].length>0 &&
      result[:includes][:cities][state][0].include?(city)
      puts "YES" 
      city_captured = true
    end
  end
  city_captured
 end
 
#State permission checking
def state_finder result, state_captured, city, state, country
    if city.empty? && !state.empty? && !country.empty?
      if result[:excludes].length>0 && result[:excludes][:states][country].length>0 &&
        result[:excludes][:states][country].include?([state])
        puts "NO"
        state_captured = true 
      end  
    end

    if !state_captured && city.empty? && !state.empty? && !country.empty?
      if result[:includes].length>0 && result[:includes][:states][country].length>0 &&
        result[:includes][:states][country].include?([state])
        puts "YES" 
        state_captured = true
      end
    end
    state_captured
 end

 #Country permission checking
 def country_finder result, country_captured, city, state, country
  if city.empty? && state.empty? && !country.empty?
    if result[:excludes].length>0 && result[:excludes][:countries] &&
      result[:excludes][:countries].length>0 &&
      result[:excludes][:countries].include?(country)
      puts "NO" 
      country_captured = true
    end
  end

  if city.empty? && state.empty? && !country.empty?
    if result[:includes].length>0 && result[:includes][:countries] &&
       result[:includes][:countries].length>0 &&
       result[:includes][:countries].include?(country)
      puts "YES" 
      country_captured = true
    end
  end
  country_captured
 end

 #Result Json
 def build_include_regions include_regions
  includes = []
  cities = Hash.new { |h,k| h[k] = [] }
  states = Hash.new { |h,k| h[k] = [] }
  countries = Hash.new { |h,k| h[k] = [] }
  include_regions.each do |region|
    city, state, country = region.split(",")
    includes = {
      "cities": build_city_region(cities, city, state, country),
      "states": build_state_region(states, city, state, country),
      "countries": build_country_region(countries, city, state, country)
    }
  end
  return includes
 end

#Result Json
def build_exclude_regions exclude_regions
  excludes = []
  cities = Hash.new { |h,k| h[k] = [] }
  states = Hash.new { |h,k| h[k] = [] }
  countries = Hash.new { |h,k| h[k] = [] }
  exclude_regions.each do |region|
    city, state, country = region.split(",")
    excludes = {
      "cities": build_city_region(cities, city, state, country),
      "states": build_state_region(states, city, state, country),
      "countries": build_country_region(countries, city, state, country)
    }
  end
  return excludes
 end

 #Result Json
 def build_city_region cities, city, state, country
  if !city.empty? && !state.empty? && !country.empty?
    cities[state] << city
  elsif city.empty? && !state.empty? && !country.empty?
    cities[state] << @@all_cities[state]
  elsif city.empty? && state.empty? && !country.empty?
    @@all_states[country].each do |all_state|
      cities[all_state] << @@all_cities[all_state]
    end
  end
  return cities
 end

 #Result Json
 def build_state_region states, city, state, country
  if city.empty? && !state.empty? && !country.empty?
    states[country] << [state]
  elsif city.empty? && state.empty? && !country.empty?
    states[country] << @@all_states[country]
  end
  return states
 end

 #Result Json
 def build_country_region countries, city, state, country
  countries["countries"] << country if city.empty? && state.empty? && !country.empty?
 end

end