class Votigoto::Base

  def initialize(ip,mak)
    @ip = ip
    @mak = mak
  end

  attr_reader :ip, :mak, :doc

  def last_changed_date(reload=false)
    load(reload)
    Time.at(@doc.at("/tivocontainer/details/lastchangedate").inner_text.to_i(16))
  end

  def shows(reload=false)
    load(reload)
    @shows
  end

  alias_method :to_a, :shows

  def show(program_id,reload=false)
    show = shows(reload).select { |show| show.program_id == program_id.to_s }
    show.length == 1 ? show[0] : nil
  end

  def flush
    @doc = nil
    @shows = nil
  end

private

  def getxml(uri)
    begin
      uri = URI.parse "https://tivo:#{@mak}@#{@ip}/#{uri}"
    rescue URI::InvalidURIError
     puts 'Invalid TiVo URI'
    end
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    xml = ''
    begin
      Timeout::timeout(Votigoto::TIMEOUT) do
        http.start do |http|
          response = http.head uri.request_uri
          authorization = DigestAuth.gen_auth_header uri, response['www-authenticate']
          response = http.get uri.request_uri, 'Authorization' => authorization
          case response
          when Net::HTTPSuccess
            xml = response.body
          else
            response.error!
          end
        end
      end
    end
    Hpricot(xml)
  end

  def load(reload=false)
    flush() if reload
    load_all() unless @doc
  end

  def load_all
    offset = 0
    count = 20
    @shows = []
    while true do
      load_chunk(offset, count)
      parse_shows()
      offset = item_start + item_count
      break if offset >= total_items
    end
  end

  def load_chunk(offset, count)
    @doc = getxml("TiVoConnect?Command=QueryContainer&Container=%2FNowPlaying&Recurse=Yes&AnchorOffset=#{offset}&ItemCount=#{count}")
  end

  def parse_shows
    @doc.search("/tivocontainer/item").each do |show|
      @shows << Votigoto::Show.new(show)
    end
  end

  def total_items
    @doc.at("/tivocontainer/details/totalitems").inner_text.to_i
  end

  def item_count
    @doc.at("/tivocontainer/itemcount").inner_text.to_i
  end

  def item_start
    @doc.at("/tivocontainer/itemstart").inner_text.to_i
  end

end
