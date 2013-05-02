# encoding: UTF-8
require 'socket'
require 'timeout'
require 'yaml'

module CKIP
  
  class Client
    
    def self.get( sys , text )
      begin
        text.encode("Big5-UAO")
      rescue Encoding::UndefinedConversionError
        trans_text = text.encode("Big5-UAO", :undef => :replace).encode("UTF-8")
        un_w = text.delete( trans_text )
        puts "!!contains unsupported character: #{un_w}!!"
        raise $!
      end
      text_encoding = text.encoding.to_s
      unless ['Big5','Big5-UAO','UTF-8'].include? text_encoding
        raise 'Encoding ERROR!! CKIP_Client only support UTF-8 or Big5 or Big5-UAO encodings.'
      end
      input_encoding = (text_encoding == 'Big5-UAO')? 'Big5' : text_encoding
      sst = 1.6 - 1020.0 / (text.size + 640)
      config = YAML::load( File.open( File.dirname(__FILE__) + "/config/#{sys}.yml" ).read )
      request = "<?xml version=\"1.0\" ?>
<wordsegmentation version=\"0.1\" charsetcode=\"#{input_encoding.downcase}\">
<option showcategory=\"1\" />
<authentication username=\"#{config['username']}\" password=\"#{config['password']}\" />
<text>#{text}</text>
</wordsegmentation>"
      begin
        Timeout::timeout(5) {
          socket = TCPSocket.open( config['host'] , config['port'] )
          socket.write( request )
          @xml_result = socket.gets.force_encoding( text_encoding )
          socket.close
        }
        sleep (rand + 0.25) * sst
        return @xml_result
      rescue Timeout::Error
        puts "CKIP Connection Timeout!!!"
        raise Timeout::Error
      end
    end
    
    def self.xml2str( xml )
      xml.encode!('UTF-8')
      sleep (rand * 0.1 + 0.05)
      if /<result>(.*?)<\/result>/m.match( xml )
        return $1.gsub(/<\/sentence>\r?\n?\t*?\s*?<sentence>/,"\n").gsub("\n　\n","\n\n").sub(/\t*?\s*?<sentence>　?/,'').sub(/<\/sentence>/,'').gsub("\n　", "\n")
      elsif /<processstatus code="\d">(.*?)<\/processstatus>/.match( xml )
        raise $1
      else
        raise "XML result format error!!"
      end
    end
    
  end
  
  def self.segment( text , mode = nil )
    output = Client.xml2str( Client.get( 'segment' , text ) )
    if ['compact','neat'].include?( mode )
      return output.gsub!(/\([A-Za-z]+\)/,'')
    else
      return output
    end
  end
  
  def self.parser( text , mode = nil )
    text.encode!('Big5-UAO') if text.encoding.to_s == 'UTF-8'
    
    output = Client.xml2str( Client.get( 'parser' , text ) )
    if ['compact','neat'].include?( mode )
      return output.gsub(/[A-Za-z]+?:/,'').gsub(/[A-Za-z]+?\(/,'(').gsub(/[A-Za-z]+?‧.+?\(/,'(').gsub!(/[#%]/,'').gsub!(/^\d+:\d+.\[\d+\]\s/,'').gsub(/\([A-Z]+?\)$/,'')
    else
      return output
    end
  end
  
end