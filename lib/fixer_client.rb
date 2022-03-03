class FixerClient
  attr_reader :url
  attr_reader :url_exchange_rate
  attr_reader :symbols_query
  attr_reader :from_currency
  attr_reader :to_currency

  def initialize(base, symbols)
    base_formatted = base.upcase
    @symbols_query = [*symbols].select { |s| s.is_a? String }.map(&:upcase).map { |c| "#{base_formatted}_#{c}" }.join(',')
    raise ArgumentError, 'Symbols are blank' if symbols_query.blank?
    raise ArgumentError, 'Base currency is blank' if base.blank?

    fx_conv_api_key = ENV['CURRENCY_CONVERTER_API_KEY']
    exchange_rate_api_key = ENV['EXCHANGE_RATE_API_KEY']
    @from_currency, @to_currency = symbols_query.split("_")

    @url = URI(
      "https://free.currconv.com/api/v7/convert??compact=ultra&apiKey=#{fx_conv_api_key}&q=#{symbols_query}"
    )
    @url_exchange_rate = URI(
      "https://v6.exchangerate-api.com/v6/#{exchange_rate_api_key}/pair/#{from_currency}/#{to_currency}"
    )
  end

  def get_exchange_rate(url)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)

    https.request(request)
  end

  def fetch
    response = get_exchange_rate(url)
    if response.kind_of?(Net::HTTPSuccess)
      response_body = JSON.parse(response.body)
      rates = [
        {
          from: from_currency,
          to: to_currency,
          val: response_body[symbols_query]
        }
      ]
    else
      response = get_exchange_rate(url_exchange_rate)
      return unless response.kind_of?(Net::HTTPSuccess)
      response_body = JSON.parse(response.body)
      rates = [
        {
          from: from_currency,
          to: to_currency,
          val: response_body["conversion_rate"]
        }
      ]
    end
    rates
  end
end
