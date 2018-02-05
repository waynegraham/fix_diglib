require 'dotenv'
require 'mechanize'
require 'colorize'

Dotenv.load

@agent = Mechanize.new
@total_posts = 1045.0
@counter = 0

@agent = Mechanize.new do |agent|
  agent.follow_meta_refresh = true
end

def update_posts(post_list)
  post_list.each do |post|
    puts "Updating #{post['aria-label']}".light_blue
    @agent.get post['href'] do |post_page|
      form = post_page.form_with(id: 'post')
      button = form.button_with(value: 'Update')
      @agent.submit(form, button)
      @counter += 1
      @percentage = (@counter / @total_posts) * 100.0
      puts "\t#{sprintf("%.2f", @percentage)}% complete (#{@counter} of #{@total_posts})".red
    end
  end
end

def login(page)
  form = page.form_with(name: 'loginform')
  form.log = ENV['WORDPRESS_ADMIN']
  form.pwd = ENV['WORDPRESS_PASSWORD']
  form.submit
end

def get_posts(page)
  post_list = page.css('#the-list a[@class="row-title"]')
  update_posts(post_list)
end

@agent.get(ENV['WORDPRESS_URL']) do |login_page|

  @start = 9
  puts 'Logging in'.green
  login login_page

  puts 'Navigating to Posts page'.green
  url = ENV['WORDPRESS_URL'] + "/edit.php?paged=#{@start}"
  posts_page = @agent.get(url)

  while link = posts_page.at('[class=next-page]')
    page = @agent.get link[:href]
    @start += 1
    puts "Working on Posts from page #{@start}".yellow
    # puts page.title
    get_posts(page)
  end

end
