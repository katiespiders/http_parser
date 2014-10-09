class HttpParser
  attr_accessor :method, :path, :elements_hash

  def bronze(string)
    @elements_hash = {}
    elements = string.split("&")
    elements.each do |element|
      key, value = element.split("=")
      m = /\[.+\]/.match(key)
      if m
        outer_key = m.pre_match
        inner_key = m.to_s

        if inner_key.index("[]")
          gold(inner_key, value)
        else
          inner_key = inner_key.slice(1...-1)
          if @elements_hash[outer_key]
            @elements_hash[outer_key][inner_key] = value
          else
            @elements_hash[outer_key] = {inner_key => value}
          end
        end

      else
        @elements_hash[key] = value
      end
    end
    @elements_hash
  end

  def silver(string)
    bronze(string.gsub("%20", " "))
  end

  def gold(string, value)
    m = /\[\]/.match(string)
    outer_key = m.pre_match.slice(1...-1)
    inner_key = m.post_match.slice(1...-1)
    if @elements_hash[outer_key]
      @elements_hash[outer_key] << {inner_key => value}
    else
      @elements_hash[outer_key] = [{inner_key => value}]
    end
  end

  def platinum(string)
    m = /\n\n/.match(string)
    @elements_hash = silver(m.post_match)
    @method = /\ \//.match(m.pre_match).pre_match
    @path = /\/\w*/.match(m.pre_match)
  end
end


#
# bronze_test_string = "market[name]=Cap Hill Market&market[description]=A good place to buy produce"
#
# silver_test_string = "market[name]=Cap%20Hill%20Market&market[description]=A%20good%20place%20to%20buy%20produce"

# gold_test_string = "market[name]=Cap%20Hill%20Market&market[description]=A%20good%20place%20to%20buy%20produce&market[vendors_attributes][][name]=Jules%20Produce"

platinum_test_string = <<-EOS
GET /markets HTTP/1.1
User-Agent: curl/7.30.0
Host: localhost:3000
Content-Length: 141
Accept: */*

market[name]=Cap%20Hill%20Market&market[description]=A%20good%20place%20to%20buy%20produce&market[vendors_attributes][][name]=Jules%20Produce
EOS

parser = HttpParser.new
parser.platinum(platinum_test_string)
puts parser.method, parser.path, parser.elements_hash
