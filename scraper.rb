require 'capybara'
require 'capybara-webkit'

Capybara.default_driver = :webkit
Capybara.default_wait_time = 1

class Parser
  include Capybara::DSL

  attr_accessor :url, :results

  def initialize(url)
    @url = url
    @results = []
  end

  def parse
    visit url

    while(nextpage = page.find('.paginalink u', text: 'Següent'))
      read_list
      nextpage.click
    end
  end

  def read_list
    count = page.all('.item_list').length

    count.times do |time|
      page.all('.item_list')[time].click
      read_architect
      find('input[name="tornar"]').click
    end
  end

  def read_architect
    architect = {
      email: find_field('a[href^="mailto:"]')
    }

    puts architect
    @results << architect
  end

  def find_field(selector)
    return nil unless has_css?(selector)

    first(selector).text
  end
end

parser = Parser.new("http://www.coac.net/arquitectes/arquitectes/llistat.php")
results = parser.parse

File.write('results.json', results.to_json)