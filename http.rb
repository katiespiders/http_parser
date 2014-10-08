class Http

  def bronze(string)
    elements_hash = {}
    elements = string.split("&")
    elements.each do |element|
      key, value = element.split("=")
      m = /\[.+\]/.match(key)
      if m
        outer_key = m.pre_match
        # if m.to_s[1...-1].index("[]")
        #   gold(m)
        # end
        inner_key = m.to_s[1...-1]
        # if inner_key.index("[]")
        #   gold(inner_key)
        # end
        if elements_hash[outer_key]
          elements_hash[outer_key][inner_key] = value
        else
          elements_hash[outer_key] = {inner_key => value}
        end
      else
        elements_hash[key] = value
      end
    end
    elements_hash
  end

  def silver(string)
    bronze(string.gsub("%20", " "))
  end

  def gold(string)
    puts string
  end
end

bronze_test_string = "market[name]=Cap Hill Market&market[description]=A good place to buy produce"

silver_test_string = "market[name]=Cap%20Hill%20Market&market[description]=A%20good%20place%20to%20buy%20produce"

# gold_test_string = "market[name]=Cap%20Hill%20Market&market[description]=A%20good%20place%20to%20buy%20produce&market[vendors_attributes][][name]=Jules%20Produce"


parser = Http.new
puts parser.bronze(bronze_test_string)
puts parser.silver(silver_test_string)
# puts parser.silver(gold_test_string)
