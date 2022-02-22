class FixerClient
  attr_reader :uri

  def initialize(base, symbols)
    base_formatted = base.upcase
    symbols_formatted = [*symbols].select { |s| s.is_a? String }.map(&:upcase).map { |c| "#{base_formatted}_#{c}" }.join(',')
    raise ArgumentError, 'Symbols are blank' if symbols_formatted.blank?
    raise ArgumentError, 'Base currency is blank' if base.blank?

    fx_conv_api_key = ENV['CURRENCY_CONVERTER_API_KEY']

    @uri = URI(
      "https://free.currconv.com/api/v7/convert?apiKey=#{fx_conv_api_key}&q=#{symbols_formatted}"
    )
  end

  def fetch
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse response, symbolize_names: true

    return if parsed_response[:results].blank?

    parsed_response[:results].values
  rescue StandardError => _e
    nil
  end
end
