class HelperMethods

#Declarations
@@all_addresses = Array.new
FILE_NAME = "./input.csv"

#parsing csv
def parse_csv
  csv_data = File.read(FILE_NAME)
  puts "Please wait ..."
  data = CSV.parse(csv_data, headers: true)
  @@all_addresses = set_addresses(data)
  puts "Built distributor based JSON"
  input = String.new
  puts "Note: provide comma separated input in accordance with CSV headers"
  puts "Enter name"
  distributor_name = gets.chomp
  puts "Enter locations to check, type 'exit' to stop"
  while input != 'exit'
   input = gets.chomp
   input_arr = input.split(",") if input.length>0
   status = check_permission(@@all_addresses, input_arr[0..-4],input_arr[-3], input_arr[-2], input_arr[-1])
   if status
    p "YES"
   else
    if input != 'exit'
     p "NO"
    end
   end
  end
end

# For search
def check_permission data, addresses_arr, city, state, country
  is_city_captured=false
  if country && !country.empty?
    current_country = data.select { |item| item[:countries] == country }.first
  end
  if state && !state.empty? && current_country && current_country[:states]
    current_state = current_country[:states].select { |item| item.include?(state) }
  end
  if state && !state.empty? && city && !city.empty? && current_country && current_country[:cities]
    is_city_captured = true
    current_city = current_country[:cities].select{|item| item[:"#{state}"] }.first != nil ? current_country[:cities].select{|item| item[:"#{state}"] }.first.values.first.include?(city) : nil
  end

  if country
    if current_country == nil
      return false
    end
  end
  if state
    if current_state && current_state.length == 0
      return false
    end
  end
  if city
    if is_city_captured && !current_city
      return false
    end
  end
  
  if addresses_arr.length > 0
    length = addresses_arr.length
    indexe = 0
    while length>0
     if !addresses_arr[length-1].empty?
       check = current_country[:addresses][0][indexe] != nil ? current_country[:addresses][0][indexe][:"address_#{length}"].select { |item| item == addresses_arr[length-1] } : true
       if check.length == 0 || !check
        return false
       end
     end
     length-=1
     indexe+=1
    end
  end
  return true
end

 #For input
 def set_addresses data
  addresses = []
  data.each do |row|
   state = row['state']
   current_country = addresses.select { |item| item[:countries] == row['country'] }.first
   current_state = addresses.select { |item| item[:states] == row['state'] }.first
   if !current_country
     addresses << { countries: row['country'], states: [row['state']].compact, cities: [ build_cities(row) ], addresses: [build_address(row,data)] }
   end

   if current_country && row['state'] && !current_country[:states].include?(row['state'])
    current_country[:states] << row['state']
   end

   if current_country && state
    current_city = current_country[:cities].select{|item| item[:"#{row['state']}"] }.first
    if current_city && !current_country[:cities].include?(row['city'])
     current_city[:"#{row['state']}"] << row['city']
    else
     current_country[:cities] << { "#{state}": [row['city']]}
    end
   end

   if current_country
     local_address_count = no_of_address(data)
     local_address_count = local_address_count -3
     index_arr = 0
     while local_address_count != 0
      current_country[:addresses][0][index_arr][:"address_#{local_address_count}"] << row["address_#{local_address_count}"]
      index_arr = index_arr + 1
      local_address_count = local_address_count - 1
     end
   end

   if !state && row['city']
    current_country[:cities] << { separates: [row['city']] }
   end
  end
  addresses
 end

 # For dynamic local addresses
 def no_of_address data
  no_of_addresses = 1
  data.headers.each do |item|
    if item != 'city'
     no_of_addresses+=1
    end
  end
  no_of_addresses
 end

 def build_cities row
   state = row['state']
   if state
    {"#{state}": [row['city']] }
   end
 end

 def build_address row, data
  address=[]
  local_address_count = no_of_address(data)
  local_address_count = local_address_count -3
  while local_address_count != 0
    address << { "address_#{local_address_count}": [row["address_#{local_address_count}"]] }
    local_address_count = local_address_count -1
  end
  address
 end

end