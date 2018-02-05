require 'selenium-webdriver'
require 'dotenv'

Dotenv.load

# see https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings
@prefs = {
  prompt_for_download: false,
  default_directory: "/tmp"
}

@options = Selenium::WebDriver::Chrome::Options.new

def setup
  @options.add_argument('--ignore-certificate-errors')
  @options.add_argument('--disable-popup-blocking')
  @options.add_argument('--disable-translate')
  @driver = Selenium::WebDriver.for(:chrome, options: @options)
end

def login
  @driver.navigate.to ENV['WORDPRESS_URL']
  @driver.find_element(id: 'user_login').send_keys(ENV['WORDPRESS_ADMIN'])
  @driver.find_element(id: 'user_pass').send_keys(ENV['WORDPRESS_PASSWORD'])
  @driver.find_element(id: 'wp-submit').click

  puts @driver.title
end

def posts
  posts_page = ENV['WORDPRESS_URL'] + "/edit.php"
  puts posts_page
  @driver.navigate.to posts_page

  post_table = @driver.find_elements(id: 'the-list')

  elems = @driver.find_elements_by_xpath("the-list//a[@href]")

  puts elems.inspect



end

def cleanup
  @driver.quit
end

setup
login
posts

cleanup
