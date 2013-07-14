# encoding: UTF-8
require 'socket'
require 'timeout'
require 'yaml'

module CKIP
  
  class Client
    
    def self.get( sys , text )
      text_encoding = text.encoding.to_s
      if text_encoding == "ASCII-8BIT"
        text.encode!("UTF-8")
        text_encoding = text.encoding.to_s
      end
      unless %w{Big5 Big5-UAO UTF-8}.include? text_encoding
        raise 'Encoding ERROR!! CKIP_Client only support UTF-8 or Big5 or Big5-UAO encodings.'
      end
      input_encoding = (text_encoding == 'Big5-UAO')? 'Big5' : text_encoding
      sst = 2.0 - 2304.0 / (text.size + 1280)
      config = YAML::load( File.open( File.dirname(__FILE__) + "/config/#{sys}.yml" ).read )
      sleep rand * 0.2 + 0.1
      request = "<?xml version=\"1.0\" ?>
<wordsegmentation version=\"0.1\" charsetcode=\"#{input_encoding.downcase}\">
<option showcategory=\"1\" />
<authentication username=\"#{config['username']}\" password=\"#{config['password']}\" />
<text>#{text}</text>
</wordsegmentation>"
      begin
        time0 = Time.now
        xml_result = Timeout::timeout(8.0 * (sst + 1.0)){
          @socket = TCPSocket.new( config['host'] , config['port'] )
          @socket.write( request )
          @socket.gets.force_encoding( text_encoding )
        }
        time1 = (Time.now - time0)
        sleep (rand + 0.5) * sst + time1 * 0.25
        
        if xml_result.valid_encoding?
          return xml_result.encode!('UTF-8')
        else
          trans_text = xml_result.encode("UTF-32", :undef => :replace, :invalid => :replace).encode( text_encoding )
          text2 = text.gsub(/[^[:word:]]+/ , "")
          trans_text.each_char{ |c| text2.delete!(c) }
          puts "!!contains unsupported character: #{text2}!!"
          raise Encoding::InvalidByteSequenceError
        end
      rescue Timeout::Error
        time1 = (Time.now - time0)
        puts "!!!Timeout: waited for #{time1.round(2)}s and no response from CKIP server!!!"
        raise $!
      end
    end
    
    def self.xml2str( xml )
      if /<result>(.*?)<\/result>/m.match( xml )
        return $1.gsub(/<\/sentence>\r?\n?\t*?\s*?<sentence>/,"\n").gsub("\n　\n","\n\n").sub(/\t*?\s*?<sentence>/,'').sub(/<\/sentence>/,'')
      elsif /<processstatus code="\d">(.*?)<\/processstatus>/.match( xml )
        raise $1
      else
        raise "XML return error!!"
      end
    end
    
  end
  
  def self.segment( text , mode = nil )
    output = Client.xml2str( Client.get( 'segment' , text ) )
    if ['compact','neat'].include?( mode )
      return output.gsub!(/\([A-Za-z_]+\)/,'')
    else
      return output
    end
  end
  
  def self.parser( text , mode = nil )
    text.encode!('Big5-UAO') if text.encoding.to_s == 'UTF-8'
    output = Client.xml2str( Client.get( 'parser' , text ) )
    if ['compact','neat'].include?( mode )
      return output.gsub(/[A-Za-z_]+?:/,'').gsub(/[A-Za-z_]+?\(/,'(').gsub(/[A-Za-z_]+?‧.+?\(/,'(').gsub!(/[#%]/,'').gsub!(/^\d+:\d+.\[\d+\]\s/,'').gsub(/\([A-Z]+?\)$/,'')
    else
      return output
    end
  end
  
end