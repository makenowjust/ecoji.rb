# frozen_string_literal: true

require 'js'
require 'ecoji'

puts Ecoji.encode('Ecoji.rb')

document = JS.global['document']
app = document.querySelector('#app')
app['innerHTML'] = <<~HTML
  <div class="demo">
    <div class="input">
      <label for="encode">Encode using <a href="https://github.com/makenowjust/ecoji.rb/">Ecoji.rb</a></label>
      <textarea id="encode" placeholder="๐ Let's type a text to encode here!"></textarea>
    </div>
    <div class="input">
      <label for="decode">Decode using <a href="https://github.com/makenowjust/ecoji.rb/">Ecoji.rb</a></label>
      <textarea id="decode" placeholder="๐ฅด๐๐งญ๐ฒ๐๐ช๐ง๐ค ๐๐๐ฏ๐ญ๐๐คโต๐ญ๐ฒ๐พโต๐ท๐๐ฉ๐ฅ๐ค๐ข๐ฅโช๐ญ๐๐ฅ๐โ"></textarea>
    </div>
    <div class="info">
      <p>Powered by <a href="https://github.com/ruby/ruby.wasm">ruby.wasm</a></p>
      <p>#{RUBY_DESCRIPTION}</p>
    </div>
  </div>
HTML

encode_element = document.querySelector('#encode')
decode_element = document.querySelector('#decode')

encode_element.addEventListener('input') do
  # `to_s` is necessary because it is `JS::Object` actually.
  input = encode_element['value'].to_s
  decode_element['value'] = Ecoji.encode(input)
end

decode_element.addEventListener('input') do
  # `to_s` is necessary because it is `JS::Object` actually.
  # `force_encoding` is also necessary because its encoding is `ASCII_8BIT`.
  input = decode_element['value'].to_s.force_encoding(Encoding::UTF_8)
  begin
    encode_element['value'] = Ecoji.decode(input)
  rescue Ecoji::Error
    encode_element['value'] = '๐คจ It seems that your input was not Ecojiโข encoded'
  end
end
