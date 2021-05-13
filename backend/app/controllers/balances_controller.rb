class BalancesController < ApplicationController
  TIMOUT = 600

  def import
    require 'csv'
    require 'selenium-webdriver'
    require 'webdriver-user-agent'

    download_path = File.absolute_path('./csv')

    download_preference = {
      'prompt_for_download' => false,
      'default_directory' => download_path,
      'directory_upgrade' => true
    }
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_preference(:download, download_preference)
    options.add_argument('--no-sandbox')
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--lang=ja-JP')
    options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36')
    driver = Selenium::WebDriver.for :chrome, options: options
    driver.manage.timeouts.implicit_wait = TIMOUT
    $wait = Selenium::WebDriver::Wait.new(:timeout => TIMOUT)

    begin
      driver.get('https://id.moneyforward.com/sign_in/email?client_id=2WND7CAYV1NsJDBzk13JRtjuk5g9Jtz-4gkAoVzuS_k&nonce=b0cb75eb0351729cd986cfcd1b8dc299&redirect_uri=https%3A%2F%2Fmoneyforward.com%2Fauth%2Fmfid%2Fcallback&response_type=code&scope=openid+email+profile+address&state=c5d7e1f6373ce5adb9e9ceb5dd8dad31')
      driver.find_element(:class, 'inputItem').send_keys('takayamayukihiro@gmail.com' || Rails.application.credentials.moneyforward[:email])
      driver.find_element(:class, 'submitBtn').click
      driver.find_element(:class, 'inputItem').send_keys('gatpvbn9' || Rails.application.credentials.moneyforward[:password])
      driver.find_element(:class, 'submitBtn').click
      driver.get('https://moneyforward.com/')
      driver.find_element(:class, 'web-sign-in').click
      driver.find_element(:class, 'submitBtn').click
      driver.get('https://moneyforward.com/accounts')
      driver.find_element(:class, 'aggregation-queue-all').find_element(:tag_name, 'a').click
      ids = driver.find_elements(:class, 'account-status').map { |ele| ele.find_element(:tag_name, 'span').attribute('id') }
      $wait.until do
        ids.map { |id| driver.find_element(:id, id).displayed? }.all?(false)
      end
      FileUtils.rm_rf('csv')
      driver.get("https://moneyforward.com/cf/csv?year=2021&month=4")
      Dir.chdir('csv')
      is_download = false
      until is_download
        download_incomplete_files = Dir.glob('*.crdownload')
        is_download = download_incomplete_files.blank?
      end
      filename = Dir.glob('*.csv').first
      file = File.open(filename, 'r')
      Balance.import!(file)
    rescue Selenium::WebDriver::Error::NoSuchElementError
    end

    driver.quit
  end
end
